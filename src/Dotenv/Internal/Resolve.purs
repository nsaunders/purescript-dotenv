-- | This module encapsulates the logic for resolving `.env` values.

module Dotenv.Internal.Resolve
  ( resolve
  ) where

import Prelude

import Data.Foldable (find)
import Data.Maybe (Maybe(..))
import Data.String (joinWith, trim)
import Data.Traversable (sequence, traverse)
import Data.Tuple (fst, snd)
import Dotenv.Internal.ChildProcess (CHILD_PROCESS, spawn)
import Dotenv.Internal.Environment (ENVIRONMENT, lookupEnv)
import Dotenv.Internal.Types (ResolvedValue, Setting, UnresolvedValue(..))
import Run (Run)
import Type.Row (type (+))

-- | Resolves a value according to its expression.
resolve
  :: forall r
   . Array (Setting UnresolvedValue)
  -> UnresolvedValue
  -> Run (CHILD_PROCESS + ENVIRONMENT + r) ResolvedValue
resolve settings = case _ of
  LiteralValue value ->
    pure $ Just value
  CommandSubstitution cmd args -> do
    value <- spawn cmd args
    pure $ Just (trim value)
  VariableSubstitution var -> do
    envValueMaybe <- lookupEnv var
    case envValueMaybe of
      Just value ->
        pure $ Just value
      Nothing -> do
        case (snd <$> find (eq var <<< fst) settings) of
          Just unresolvedValue ->
            resolve settings unresolvedValue
          Nothing ->
            pure Nothing
  ValueExpression unresolvedValues -> do
    resolvedValues <- traverse (resolve settings) unresolvedValues
    pure $ joinWith "" <$> sequence resolvedValues