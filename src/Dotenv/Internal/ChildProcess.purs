-- | This module encapsulates the logic for running a child process.

module Dotenv.Internal.ChildProcess (CHILD_PROCESS, ChildProcessF(..), _childProcess, handleChildProcess, spawn) where

import Prelude
import Control.Monad.Error.Class (throwError)
import Data.Maybe (Maybe(Nothing))
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Effect.Exception (error)
import Node.ChildProcess (Exit(..), defaultSpawnOptions)
import Run (FProxy, Run, lift)
import Sunde (spawn) as Sunde

-- | A data type representing the supported operations
data ChildProcessF a = Spawn String (Array String) (String -> a)

derive instance functorChildProcessF :: Functor ChildProcessF

-- | The effect label used for a child process
_childProcess = SProxy :: SProxy "childProcess"

-- | The effect type used for a child process
type CHILD_PROCESS = FProxy (ChildProcessF)

-- | The default interpreter for handling a child process
handleChildProcess :: ChildProcessF ~> Aff
handleChildProcess (Spawn cmd args callback) = do
  { stderr, stdout, exit } <- Sunde.spawn { cmd, args, stdin: Nothing } defaultSpawnOptions
  case exit of
    Normally 0 ->
      pure $ callback stdout
    Normally code ->
      throwError (error $ "Exited with code " <> show code <> ": " <> stderr)
    BySignal signal ->
      throwError (error $ "Exited: " <> show signal)

-- | Constructs the value used to spawn a child process.
spawn :: forall r. String -> Array String -> Run (childProcess :: CHILD_PROCESS | r) String
spawn cmd args = lift _childProcess (Spawn cmd args identity)
