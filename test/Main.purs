module Test.Main where

import Prelude
import Configuration.Dotenv as Dotenv
import Data.Maybe (Maybe(Just))
import Effect (Effect)
import Effect.Aff (finally)
import Effect.Class (liftEffect)
import Node.Buffer (fromString) as Buffer
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff (unlink, writeFile)
import Node.Process (lookupEnv, setEnv)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (run)

main :: Effect Unit
main = run [consoleReporter] do
  describe "loadFile" do
     it "should apply settings from .env" do
       writeFile ".env" =<< liftEffect (Buffer.fromString "TEST_ONE=hello" UTF8)
       Dotenv.loadFile *> liftEffect (lookupEnv "TEST_ONE") >>= shouldEqual (Just "hello")
         # finally (unlink ".env")
     it "should not replace existing environment variables" do
       writeFile ".env" =<< liftEffect (Buffer.fromString "TEST_TWO=hi2" UTF8)
       finally (unlink ".env") do
         liftEffect $ setEnv "TEST_TWO" "hi"
         _ <- Dotenv.loadFile
         two <- liftEffect (lookupEnv "TEST_TWO")
         two `shouldEqual` Just "hi"
     it "should not throw an error when the .env file does not exist" $
       Dotenv.loadFile *> pure unit
