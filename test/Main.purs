module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Aff (launchAff_)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import Test.Apply as Apply
import Test.Parse as Parse
import Test.Resolve as Resolve

main :: Effect Unit
main = launchAff_ $ runSpec [ consoleReporter ] do
  Apply.tests
  Parse.tests
  Resolve.tests
