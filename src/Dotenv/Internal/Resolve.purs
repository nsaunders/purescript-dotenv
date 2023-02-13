-- | This module encapsulates the logic for resolving `.env` values.

module Dotenv.Internal.Resolve
  ( resolve
  ) where

import Prelude

import Data.Foldable (elem, lookup)
import Data.List (List, (:))
import Data.Maybe (Maybe(..))
import Data.String (joinWith, trim)
import Data.Traversable (sequence, traverse)
import Dotenv.Internal.ChildProcess (CHILD_PROCESS, spawn)
import Dotenv.Internal.Environment (ENVIRONMENT, lookupEnv)
import Dotenv.Internal.Types (Name, ResolvedValue, Setting, UnresolvedValue(..))
import Run (Run)
import Type.Row (type (+))

-- | Resolves a value according to its expression.
resolve
  :: forall r
   . Array (Setting UnresolvedValue)
  -> List Name
  -> UnresolvedValue
  -> Run (CHILD_PROCESS + ENVIRONMENT + r) ResolvedValue
resolve settings refs = case _ of
  LiteralValue value ->
    pure $ Just value
  CommandSubstitution cmd args -> do
    value <- spawn cmd args
    pure $ Just (trim value)
  VariableSubstitution var | elem var refs ->
    pure Nothing
  VariableSubstitution var | otherwise -> do
    envValueMaybe <- lookupEnv var
    case envValueMaybe of
      Just value ->
        pure $ Just value
      Nothing -> do
        case lookup var settings of
          Just unresolvedValue ->
            resolve settings (var : refs) unresolvedValue
          Nothing ->
            pure Nothing
  ValueExpression unresolvedValues -> do
    resolvedValues <- traverse (resolve settings refs) unresolvedValues
    pure $ joinWith "" <$> sequence resolvedValues