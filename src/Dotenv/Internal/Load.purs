module Dotenv.Internal.Load where

import Prelude
import Control.Monad.Error.Class (throwError)
import Data.Either (either)
import Data.Maybe (fromMaybe, isJust)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Dotenv.Internal.ChildProcess (_childProcess, handleChildProcess)
import Dotenv.Internal.Environment (_environment, handleEnvironment, lookupEnv, setEnv)
import Dotenv.Internal.Parse (settings) as Parse
import Dotenv.Internal.Resolve (resolveValues)
import Dotenv.Internal.Types (ResolvedValue, Setting)
import Effect.Aff (Aff)
import Effect.Exception (error)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff (readTextFile)
import Run (case_, interpret, on)
import Text.Parsing.Parser (parseErrorMessage, runParser)

-- | Loads the `.env` file into the environment.
loadFile :: Aff (Array (Setting ResolvedValue))
loadFile = either protest applySettings =<< (flip runParser Parse.settings <$> readTextFile UTF8 ".env")
  where
    protest err = throwError $ error ("Parse error: " <> parseErrorMessage err)
    applySettings unresolvedSettings =
      interpret (case_ # on _childProcess handleChildProcess # on _environment handleEnvironment) do
        resolvedSettings <- resolveValues unresolvedSettings
        flip traverse resolvedSettings \(Tuple name resolvedValue) -> do
          currentValue <- lookupEnv name
          if isJust currentValue
            then pure $ Tuple name currentValue
            else do
              when (isJust resolvedValue) (setEnv name $ fromMaybe "" resolvedValue)
              pure $ Tuple name resolvedValue

