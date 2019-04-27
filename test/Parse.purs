module Test.Parse where

import Prelude
import Data.Either (Either(..))
import Data.Foldable (class Foldable)
import Data.List (fromFoldable) as List
import Data.Tuple (Tuple(..))
import Text.Parsing.Parser (ParseError, runParser)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Configuration.Dotenv (Settings)
import Configuration.Dotenv.Parse (configParser)

parse :: String -> Either ParseError Settings
parse = flip runParser configParser

success :: forall f. Foldable f => f (Tuple String String) -> Either ParseError Settings
success = Right <<< List.fromFoldable

tests :: Spec Unit
tests = describe "configParser" do

  it "should skip blank lines" $
    parse "A=B\n\nC=D" `shouldEqual` success [ Tuple "A" "B", Tuple "C" "D" ]

  it "should skip commented lines" $
    parse "# Comment\nA=B\n# Comment\n# Comment\nC=D" `shouldEqual` success [ Tuple "A" "B", Tuple "C" "D" ]

  it "should parse empty values as empty strings" $
    parse "A=" `shouldEqual` success [ Tuple "A" "" ]
