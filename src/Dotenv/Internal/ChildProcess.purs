-- | This module encapsulates the logic for running a child process.

module Dotenv.Internal.ChildProcess
  ( CHILD_PROCESS
  , ChildProcessF(..)
  , _childProcess
  , handleChildProcess
  , spawn
  ) where

import Prelude

import Control.Monad.Error.Class (throwError)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff, effectCanceler, makeAff)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import Effect.Ref as Ref
import Node.ChildProcess (errorH, exitH)
import Node.ChildProcess as CP
import Node.ChildProcess.Types (Exit(..), KillSignal, stringSignal)
import Node.Encoding (Encoding(..))
import Node.Errors.SystemError as OS
import Node.EventEmitter (on_)
import Node.Stream (dataHStr, setEncoding)
import Run (Run, lift)
import Type.Proxy (Proxy(..))

-- | A data type representing the supported operations
data ChildProcessF a = Spawn String (Array String) (String -> a)

derive instance functorChildProcessF :: Functor ChildProcessF

-- | The effect label used for a child process
_childProcess = Proxy :: Proxy "childProcess"

-- | The effect type used for a child process
type CHILD_PROCESS r = (childProcess :: ChildProcessF | r)

-- | The default interpreter for handling a child process
handleChildProcess :: ChildProcessF ~> Aff
handleChildProcess (Spawn cmd args callback) = do
  { stderr, stdout, exit } <- spawn_ { cmd, args, stdin: Nothing }
  case exit of
    Normally 0 ->
      pure $ callback stdout
    Normally code ->
      throwError (error $ "Exited with code " <> show code <> ": " <> stderr)
    BySignal signal ->
      throwError (error $ "Exited: " <> show signal)

-- | Constructs the value used to spawn a child process.
spawn :: forall r. String -> Array String -> Run (CHILD_PROCESS r) String
spawn cmd args = lift _childProcess (Spawn cmd args identity)

-- Following adapted from https://github.com/justinwoo/purescript-sunde/blob/master/src/Sunde.purs

spawn_
  :: { cmd :: String, args :: Array String, stdin :: Maybe String }
  -> Aff
       { stdout :: String
       , stderr :: String
       , exit :: Exit
       }
spawn_ = spawn' UTF8 (stringSignal "SIGTERM")

spawn'
  :: Encoding
  -> KillSignal
  -> { cmd :: String, args :: Array String, stdin :: Maybe String }
  -> Aff
       { stdout :: String
       , stderr :: String
       , exit :: Exit
       }
spawn' encoding killSignal { cmd, args } = makeAff \cb -> do
  stdoutRef <- Ref.new ""
  stderrRef <- Ref.new ""

  process <- CP.spawn cmd args

  liftEffect $ setEncoding (CP.stdout process) encoding
  CP.stdout process # on_ dataHStr \string ->
    Ref.modify_ (_ <> string) stdoutRef

  liftEffect $ setEncoding (CP.stderr process) encoding
  CP.stderr process # on_ dataHStr \string ->
    Ref.modify_ (_ <> string) stderrRef

  process # on_ errorH \err ->
    cb $ Left $ OS.toError err

  process # on_ exitH \exit -> do
    stdout <- Ref.read stdoutRef
    stderr <- Ref.read stderrRef
    cb <<< pure $ { stdout, stderr, exit }

  pure <<< effectCanceler <<< void $ CP.kill' killSignal process