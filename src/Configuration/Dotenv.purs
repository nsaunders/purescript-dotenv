module Configuration.Dotenv where

import Prelude
import Configuration.Dotenv.Parse (configParser)
import Control.Monad.Error.Class (class MonadThrow, throwError)
import Data.Either (either)
import Data.List (List)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Effect.Exception (Error, error)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff (readTextFile)
import Node.Process (lookupEnv, setEnv)
import Text.Parsing.Parser (runParser)

type Setting = Tuple String String

type Settings = List Setting

loadFile
  :: forall m
   . MonadAff m
  => m Settings
loadFile = readConfig >>= (liftAff <<< parseConfig) >>= applySettings

readConfig
  :: forall m
   . MonadAff m
  => m String
readConfig = liftAff $ readTextFile UTF8 ".env"

parseConfig
  :: forall m
   . MonadThrow Error m
  => String
  -> m Settings
parseConfig =
  either
    (throwError <<< error <<< append "Invalid .env file " <<< show)
    pure
  <<< flip runParser configParser

applySettings
  :: forall m
   . MonadAff m
  => Settings
  -> m (List (Tuple String String))
applySettings = traverse applySetting

applySetting
  :: forall m
   . MonadAff m
  => Setting
  -> m Setting
applySetting setting@(Tuple key value) = liftEffect (lookupEnv key) >>=
  case _ of
    Nothing ->
      liftEffect (setEnv key value) *> pure setting
    Just existingValue ->
      pure $ Tuple key existingValue
