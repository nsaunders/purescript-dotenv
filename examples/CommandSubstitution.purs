module Example.CommandSubstitution (main) where

import Prelude

import Data.Maybe (maybe)
import Dotenv (loadContents) as Dotenv
import Effect (Effect)
import Effect.Aff (launchAff_, throwError)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (error)
import Node.Process (lookupEnv)

main :: Effect Unit
main = launchAff_ do
  Dotenv.loadContents "GREETING=Hello, $(whoami)!" -- Normally you'll use `loadFile` instead.
  liftEffect do
    greeting <- lookupEnv "GREETING"
    maybe (throwError $ error $ "Couldn't find GREETING!") log greeting