module Configuration.Dotenv where

import Prelude
import Configuration.Dotenv.Parse (configParser)
import Control.Monad.Error.Class (class MonadThrow, throwError)
import Data.Either (Either(..))
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

loadFile
  :: forall m
   . MonadAff m
  => MonadThrow Error m
  => m (List (Tuple String String))
loadFile = readConfig >>= parseConfig >>= applySettings

readConfig
  :: forall m
   . MonadAff m
  => MonadThrow Error m
  => m String
readConfig = liftAff $ readTextFile UTF8 ".env"

parseConfig
  :: forall m
   . MonadThrow Error m
  => String
  -> m (List (Tuple String String))
parseConfig config =
  case runParser config configParser of
    Left err ->
      throwError $ error $ show err <> config
    Right settings ->
      pure settings

applySettings
  :: forall m
   . MonadAff m
  => List (Tuple String String)
  -> m (List (Tuple String String))
applySettings = traverse applySetting

applySetting
  :: forall m
   . MonadAff m
  => Tuple String String
  -> m (Tuple String String)
applySetting setting@(Tuple key value) = liftEffect (lookupEnv key) >>=
  case _ of
    Nothing ->
      liftEffect (setEnv key value) *> pure setting
    Just existingValue ->
      pure $ Tuple key existingValue
