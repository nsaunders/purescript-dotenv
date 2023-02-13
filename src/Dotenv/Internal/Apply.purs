-- | This module encapsulates the logic for applying settings to the environment.

module Dotenv.Internal.Apply (apply) where

import Prelude

import Data.Maybe (isNothing)
import Data.Traversable (for_, traverse_)
import Data.Tuple.Nested ((/\))
import Dotenv.Internal.ChildProcess (CHILD_PROCESS)
import Dotenv.Internal.Environment (ENVIRONMENT, lookupEnv, setEnv)
import Dotenv.Internal.Resolve (resolve)
import Dotenv.Internal.Types (Setting, UnresolvedValue)
import Run (Run)
import Type.Row (type (+))

-- | Applies the specified settings to the environment.
apply
  :: forall r
   . Array (Setting UnresolvedValue)
  -> Run (CHILD_PROCESS + ENVIRONMENT + r) Unit
apply settings =
  for_ settings \(name /\ unresolvedValue) -> do
    currentValue <- lookupEnv name
    when (isNothing currentValue) do
      maybeValue <- resolve settings (pure name) unresolvedValue
      traverse_ (setEnv name) maybeValue