-- | This module encapsulates the logic for applying settings to the environment.

module Dotenv.Internal.Apply (applySettings) where 

import Prelude
import Data.Maybe (fromMaybe, isJust)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Dotenv.Internal.Environment (ENVIRONMENT, lookupEnv, setEnv)
import Dotenv.Internal.Types (ResolvedValue, Setting)
import Run (Run)

-- | Applies the specified settings to the environment.
applySettings
  :: forall r
   . Array (Setting ResolvedValue)
  -> Run (ENVIRONMENT r) (Array (Setting ResolvedValue))
applySettings = traverse \(Tuple name resolvedValue) -> do
  currentValue <- lookupEnv name
  if isJust currentValue
    then pure $ Tuple name currentValue
    else do
      when (isJust resolvedValue) (setEnv name $ fromMaybe "" resolvedValue)
      pure $ Tuple name resolvedValue
