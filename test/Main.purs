module Test.Main where

import Prelude
import Effect (Effect)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (run)
import Test.Load as Load
import Test.Parse as Parse

main :: Effect Unit
main = run [ consoleReporter ] do
--  Load.tests
  Parse.tests
