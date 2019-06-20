module Dotenv.Internal.ChildProcess where

import Prelude
import Control.Monad.Error.Class (throwError)
import Data.Maybe (Maybe(Nothing))
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Effect.Exception (error)
import Node.ChildProcess (Exit(..), defaultSpawnOptions)
import Run (FProxy, Run, lift)
import Sunde (spawn) as Sunde

type CHILD_PROCESS = FProxy (ChildProcessF)

data ChildProcessF a = Spawn String (Array String) (String -> a)

derive instance functorChildProcessF :: Functor ChildProcessF

_childProcess = SProxy :: SProxy "childProcess"

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

spawn :: forall r. String -> Array String -> Run (childProcess :: CHILD_PROCESS | r) String
spawn cmd args = lift _childProcess (Spawn cmd args identity)
