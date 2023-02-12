-- | This is the base module for the Dotenv library.

module Dotenv (Name, Setting, Settings, Value, loadFile, loadContents) where

import Prelude hiding (apply)

import Control.Monad.Error.Class (catchError, throwError)
import Data.Either (either)
import Data.Maybe (Maybe)
import Data.String.Common (trim)
import Data.Tuple (Tuple)
import Dotenv.Internal.Apply (apply)
import Dotenv.Internal.ChildProcess (_childProcess, handleChildProcess)
import Dotenv.Internal.Environment (_environment, handleEnvironment)
import Dotenv.Internal.Parser (parser)
import Dotenv.Internal.Types (Setting) as IT
import Dotenv.Internal.Types (UnresolvedValue)
import Effect.Aff (Aff)
import Effect.Exception (error)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff (readTextFile)
import Parsing (parseErrorMessage, runParser)
import Run (case_, interpret, on)

-- | The type of a setting name
type Name = String

-- | The type of a (resolved) value
type Value = Maybe String

-- | The type of a setting
type Setting = Tuple Name Value

-- | The type of settings
type Settings = Array Setting

-- | Loads the `.env` file into the environment.
loadFile :: Aff Unit
loadFile = readDotenv >>= parseSettings >>= processSettings

-- | Loads a `.env`-compatible string into the environment. This is useful when
-- | sourcing configuration from somewhere other than a local `.env` file.
loadContents :: String -> Aff Unit
loadContents = parseSettings >=> processSettings

-- | Reads the `.env` file.
readDotenv :: Aff String
readDotenv = (trim <$> readTextFile UTF8 ".env")
  # flip catchError (const $ pure "")

-- | Parses settings, mapping the result to `Aff`.
parseSettings :: String -> Aff (Array (IT.Setting UnresolvedValue))
parseSettings = flip runParser parser
  >>> either (parseErrorMessage >>> error >>> throwError) pure

-- | Processes settings by resolving their values and then applying them to the environment.
processSettings :: Array (IT.Setting UnresolvedValue) -> Aff Unit
processSettings = apply
  >>> interpret
    ( case_
        # on _childProcess handleChildProcess
        # on _environment handleEnvironment
    )