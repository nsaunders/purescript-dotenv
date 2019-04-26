module Test.Parse where

import Prelude
import Data.Either (Either(..))
import Data.List (fromFoldable) as List
import Data.Tuple (Tuple(..))
import Text.Parsing.Parser (runParser)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Configuration.Dotenv.Parse (configParser)

tests :: Spec Unit
tests = describe "configParser" do

  it "should skip blank lines" $
    runParser "A=B\n\nC=D" configParser `shouldEqual` Right (List.fromFoldable [ Tuple "A" "B", Tuple "C" "D" ])
