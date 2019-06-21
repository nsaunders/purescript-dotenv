module Dotenv.Internal.Environment where

import Prelude
import Data.Maybe (Maybe)
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.Process (lookupEnv, setEnv) as P
import Run (FProxy, Run, lift)

type ENVIRONMENT = FProxy (EnvironmentF)

data EnvironmentF a
  = LookupEnv String (Maybe String -> a)
  | SetEnv String String a

derive instance functorEnvironmentF :: Functor EnvironmentF

_environment = SProxy :: SProxy "environment"

handleEnvironment :: EnvironmentF ~> Aff
handleEnvironment op = liftEffect $
  case op of
    LookupEnv name callback -> do
      value <- P.lookupEnv name
      pure $ callback value
    SetEnv name value next -> do
      P.setEnv name value
      pure next

lookupEnv :: forall r. String -> Run (environment :: ENVIRONMENT | r) (Maybe String)
lookupEnv name = lift _environment (LookupEnv name identity)

setEnv :: forall r. String -> String -> Run (environment :: ENVIRONMENT | r) Unit
setEnv name value = lift _environment (SetEnv name value unit)
