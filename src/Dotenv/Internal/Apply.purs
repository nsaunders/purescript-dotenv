module Dotenv.Internal.Apply where 

import Prelude
import Data.Maybe (fromMaybe, isJust)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Dotenv.Internal.Environment (ENVIRONMENT, lookupEnv, setEnv)
import Dotenv.Internal.Types (ResolvedValue, Setting)
import Run (Run)

applySettings
  :: forall r
   . Array (Setting ResolvedValue)
  -> Run (environment :: ENVIRONMENT | r) (Array (Setting ResolvedValue))
applySettings = traverse applySetting

applySetting :: forall r. Setting ResolvedValue -> Run (environment :: ENVIRONMENT | r) (Setting ResolvedValue)
applySetting (Tuple name resolvedValue) = do
  currentValue <- lookupEnv name
  if isJust currentValue
    then pure $ Tuple name currentValue
    else do
      when (isJust resolvedValue) (setEnv name $ fromMaybe "" resolvedValue)
      pure $ Tuple name resolvedValue
