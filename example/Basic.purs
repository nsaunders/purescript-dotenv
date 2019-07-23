module Example.Basic (main) where

import Prelude
import Dotenv (loadFile) as Dotenv
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import Node.Process (lookupEnv)

main :: Effect Unit
main = launchAff_ do
  _ <- Dotenv.loadFile
  liftEffect do
    testVar <- lookupEnv "GREETING"
    logShow testVar
