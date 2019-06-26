module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Aff (launchAff_)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
--import Test.Load as Load
import Test.Parse as Parse
import Test.Resolve as Resolve

main :: Effect Unit
main = launchAff_ $ runSpec [ consoleReporter ] do
  --Load.tests
  Parse.tests
  Resolve.tests
