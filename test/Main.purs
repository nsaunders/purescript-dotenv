module Test.Main where

import Prelude
import Configuration.Dotenv as Dotenv
import Data.Maybe (Maybe(Just))
import Effect (Effect)
import Effect.Aff (Aff, finally)
import Effect.Class (liftEffect)
import Node.Buffer (fromString) as Buffer
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff (writeFile)
import Node.FS.Sync (rename)
import Node.Process (lookupEnv, setEnv)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (run)

setup :: Aff Unit
setup = liftEffect $ rename ".env" ".env.bak"

teardown :: Aff Unit
teardown = liftEffect $ rename ".env.bak" ".env"

writeConfig :: String -> Aff Unit
writeConfig config = writeFile ".env" <=< liftEffect $ Buffer.fromString config UTF8

main :: Effect Unit
main = run [consoleReporter] do
  describe "loadFile" do

     it "should apply settings from .env" $ do
       setup
       writeConfig "TEST_ONE=hello"
       _ <- Dotenv.loadFile
       testOne <- liftEffect (lookupEnv "TEST_ONE")
       testOne `shouldEqual` (Just "hello")
       # finally teardown

     it "should not replace existing environment variables" $ do
       setup
       writeConfig "TEST_TWO=hi2"
       liftEffect $ setEnv "TEST_TWO" "hi"
       _ <- Dotenv.loadFile
       two <- liftEffect (lookupEnv "TEST_TWO")
       two `shouldEqual` Just "hi"
       # finally teardown

     it "should not throw an error when the .env file does not exist" $
       setup *> Dotenv.loadFile *> teardown
