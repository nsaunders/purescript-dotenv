-- | This is the base module for the Dotenv library.

module Dotenv (module Dotenv.Types, loadFile) where

import Prelude
import Control.Monad.Error.Class (class MonadThrow, catchError, throwError)
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Dotenv.Internal.Parse (settings) as Parse
import Dotenv.Internal.Resolve (values) as Resolve
import Dotenv.Internal.Types (Setting) as Internal
import Dotenv.Types (Setting, Settings)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Effect.Exception (Error, error)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff (readTextFile)
import Node.Process (getEnv, lookupEnv, setEnv)
import Text.Parsing.Parser (parseErrorMessage, runParser)

-- | Loads the `.env` file into the environment.
loadFile :: forall m. MonadAff m => MonadThrow Error m => m Settings
loadFile = (Resolve.values <$> liftEffect getEnv <*> (readSettings >>= parseSettings)) >>= applySettings

-- | Reads the `.env` file.
readSettings :: forall m. MonadAff m => m String
readSettings = liftAff $ readTextFile UTF8 ".env"
                       # flip catchError (const $ pure "")

-- | Parses the contents of a `.env` file.
parseSettings :: forall m. MonadThrow Error m => String -> m (Array Internal.Setting)
parseSettings settings = runParser settings Parse.settings
  # either (throwError <<< error <<< append "Invalid .env file: " <<< parseErrorMessage) pure

-- | Applies the specified settings to the environment.
applySettings :: forall m. MonadAff m => Settings -> m Settings
applySettings = traverse applySetting

-- | Applies the specified setting to the environment.
applySetting :: forall m. MonadAff m => Setting -> m Setting
applySetting setting@(Tuple key settingValue) = do
  envValue <- liftEffect $ lookupEnv key
  case envValue of
    Just value ->
      pure $ Tuple key $ Just value
    Nothing ->
      case settingValue of
        Just value -> do
          liftEffect $ setEnv key value
          pure setting
        Nothing ->
          pure setting
