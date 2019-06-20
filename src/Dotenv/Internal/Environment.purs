module Dotenv.Internal.Environment where

import Prelude
import Data.Maybe (Maybe)
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Foreign.Object (Object)
import Node.Process (getEnv, lookupEnv, setEnv) as P
import Run (FProxy, Run, lift)

type ENVIRONMENT = FProxy (EnvironmentF)

data EnvironmentF a
  = GetEnv (Object String -> a)
  | LookupEnv String (Maybe String -> a)
  | SetEnv String String a

derive instance functorEnvironmentF :: Functor EnvironmentF

_environment = SProxy :: SProxy "environment"

handleEnvironment :: EnvironmentF ~> Aff
handleEnvironment op = liftEffect $
  case op of
    GetEnv callback -> do
      env <- P.getEnv
      pure $ callback env
    LookupEnv name callback -> do
      value <- P.lookupEnv name
      pure $ callback value
    SetEnv name value next -> do
      P.setEnv name value
      pure next

getEnv :: forall r. Run (environment :: ENVIRONMENT | r) (Object String)
getEnv = lift _environment (GetEnv identity)

lookupEnv :: forall r. String -> Run (environment :: ENVIRONMENT | r) (Maybe String)
lookupEnv name = lift _environment (LookupEnv name identity)

setEnv :: forall r. String -> String -> Run (environment :: ENVIRONMENT | r) Unit
setEnv name value = lift _environment (SetEnv name value unit)
