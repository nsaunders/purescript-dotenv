module Test.Main where

import Prelude

import Effect (Effect)
import Test.Apply as Apply
import Test.Parser as Parser
import Test.Resolve as Resolve
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)

main :: Effect Unit
main = runSpecAndExitProcess [ consoleReporter ] do
  Apply.tests
  Parser.tests
  Resolve.tests
