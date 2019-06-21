-- | This module contains the logic for resolving `.env` values.

module Dotenv.Internal.Resolve where

import Prelude
import Data.Array (unzip, zip)
import Data.Foldable (find)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Data.Traversable (sequence, traverse)
import Data.Tuple (Tuple(..), fst, snd)
import Dotenv.Internal.ChildProcess (CHILD_PROCESS, spawn)
import Dotenv.Internal.Environment (ENVIRONMENT, lookupEnv)
import Dotenv.Internal.Types (ResolvedValue, Setting, UnresolvedValue(..))
import Run (Run)

-- | A row that tracks the effects involved in value resolution
type Resolution r = (childProcess :: CHILD_PROCESS, environment :: ENVIRONMENT | r)

-- | Resolves a value according to its expression.
resolveValue :: forall r. Array (Setting UnresolvedValue) -> UnresolvedValue -> Run (Resolution r) ResolvedValue
resolveValue settings = case _ of
  LiteralValue value ->
    pure $ Just value
  CommandSubstitution cmd args -> do
    value <- spawn cmd args
    pure $ Just value
  VariableSubstitution var -> do
    envValueMaybe <- lookupEnv var
    case envValueMaybe of
      Just value ->
        pure $ Just value
      Nothing -> do
        case (snd <$> find (eq var <<< fst) settings) of
          Just unresolvedValue ->
            resolveValue settings unresolvedValue
          Nothing ->
            pure Nothing
  ValueExpression unresolvedValues -> do
    resolvedValues <- traverse (resolveValue settings) unresolvedValues
    pure $ joinWith "" <$> sequence resolvedValues

-- | Resolves the values within an array of settings.
resolveValues :: forall r. Array (Setting UnresolvedValue) -> Run (Resolution r) (Array (Setting ResolvedValue))
resolveValues settings =
  let
    (Tuple names unresolvedValues) = unzip settings
  in
    zip names <$> traverse (resolveValue settings) unresolvedValues
