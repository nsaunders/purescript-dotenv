-- | This module contains the logic for resolving `.env` values.

module Dotenv.Internal.Resolve (values) where

import Prelude
import Control.Alt ((<|>))
import Data.Array (unzip, zip)
import Data.Bifunctor (rmap)
import Data.Foldable (find)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Data.Traversable (sequence, traverse)
import Data.Tuple (Tuple(..), fst, snd)
import Dotenv.Internal.ChildProcess (CHILD_PROCESS, spawn)
import Dotenv.Internal.Environment (ENVIRONMENT, lookupEnv)
import Dotenv.Internal.Types (Environment, Name, Settings, Value(..))
import Dotenv.Types (Settings) as Public
import Foreign.Object (lookup)
import Run (Run)

type Resolution r = (childProcess :: CHILD_PROCESS, environment :: ENVIRONMENT | r)

resolveValue' :: forall r. Settings -> Value -> Run (Resolution r) (Maybe String)
resolveValue' settings = case _ of
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
            resolveValue' settings unresolvedValue
          Nothing ->
            pure Nothing
  ValueExpression unresolvedValues -> do
    resolvedValues <- traverse (resolveValue' settings) unresolvedValues
    pure $ joinWith "" <$> sequence resolvedValues

resolveValues' :: forall r. Settings -> Run (Resolution r) Public.Settings
resolveValues' settings =
  let
    (Tuple names values) = unzip settings
  in
    zip names <$> traverse (resolveValue' settings) values

-- | Given the environment and an array of `.env` settings, resolves the specified value.
value
  :: Environment
  -> Settings
  -> Value
  -> Maybe String
value env settings val =
  let
    value' = value env settings
  in
    case val of
      LiteralValue v            -> pure v
      CommandSubstitution c _   -> pure c
      ValueExpression vs        -> joinWith "" <$> (sequence $ value' <$> vs)
      VariableSubstitution name -> lookup name env <|> (value' =<< snd <$> find (eq name <<< fst) settings)

-- | Given the environment and an array of `.env` settings, resolves the value of each setting.
values :: Environment -> Settings -> Public.Settings
values env settings = rmap (value env settings) <$> settings
