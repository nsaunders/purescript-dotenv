module Dotenv.Internal.Load where

import Prelude
import Control.Monad.Error.Class (throwError)
import Data.Either (either)
import Dotenv.Internal.Apply (applySettings)
import Dotenv.Internal.ChildProcess (_childProcess, handleChildProcess)
import Dotenv.Internal.Environment (_environment, handleEnvironment)
import Dotenv.Internal.Parse (settings) as Parse
import Dotenv.Internal.Resolve (resolveValues)
import Dotenv.Internal.Types (ResolvedValue, Setting, UnresolvedValue)
import Effect.Aff (Aff)
import Effect.Exception (error)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff (readTextFile)
import Run (case_, interpret, on)
import Text.Parsing.Parser (ParseError, parseErrorMessage, runParser)

loadFile :: Aff (Array (Setting ResolvedValue))
loadFile = either surfaceError processSettings =<< (flip runParser Parse.settings <$> readTextFile UTF8 ".env")

surfaceError :: forall a. ParseError -> Aff a
surfaceError e = throwError $ error ("Parse error: " <> parseErrorMessage e)

processSettings :: Array (Setting UnresolvedValue) -> Aff (Array (Setting ResolvedValue))
processSettings = (resolveValues >=> applySettings)
  >>> interpret
    ( case_
      # on _childProcess handleChildProcess
      # on _environment handleEnvironment
    )
