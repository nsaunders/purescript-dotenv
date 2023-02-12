module Example.Contents where

import Prelude

import Dotenv (loadContents) as Dotenv
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import Node.Process (lookupEnv)

main :: Effect Unit
main = launchAff_ do
  Dotenv.loadContents """GREETING="Hello, Sailor!" """
  liftEffect $ lookupEnv "GREETING" >>= logShow
