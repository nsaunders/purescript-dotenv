module Test.Main where

import Prelude
import Configuration.Dotenv as Dotenv
import Data.Maybe (Maybe(Just))
import Effect (Effect)
import Effect.Class (liftEffect)
import Node.Process (lookupEnv, setEnv)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (run)

main :: Effect Unit
main = run [consoleReporter] do
  describe "loadFile" do
     it "should apply settings from .env" $
       Dotenv.loadFile *> liftEffect (lookupEnv "ONE") >>= shouldEqual (Just "hello")
     it "should not replace existing environment variables" do
       liftEffect $ setEnv "TWO" "hello"
       _ <- Dotenv.loadFile
       two <- liftEffect (lookupEnv "TWO")
       two `shouldEqual` Just "hello"
