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

  it "skips blank lines" $
    parse "A=B\n\nC=D" `shouldEqual` success [ Tuple "A" "B", Tuple "C" "D" ]

  it "skips commented lines" $
    parse "# Comment\nA=B\n# Comment\n# Comment\nC=D" `shouldEqual` success [ Tuple "A" "B", Tuple "C" "D" ]

  it "parses empty values as empty strings" $
    parse "A=" `shouldEqual` success [ Tuple "A" "" ]

  it "trims unquoted values" $
    parse "A= a " `shouldEqual` success [ Tuple "A" "a" ]

  it "parses single-quoted values" $
    parse "A='a'" `shouldEqual` success [ Tuple "A" "a" ]

  it "parses double-quoted values" $
    parse "A=\"Testing\"" `shouldEqual` success [ Tuple "A" "Testing" ]

  it "parses multiline values" $
    parse "A=\"Testing\n123\"" `shouldEqual` success [ Tuple "A" "Testing\n123" ]

  it "maintains inner quotes" $
    parse "JSON={\"a\": \"aval\"}" `shouldEqual` success [ Tuple "JSON" "{\"a\": \"aval\"}" ]

  it "maintains leading and trailing whitespace within single-quoted values" $
    parse "A=' a '" `shouldEqual` success [ Tuple "A" " a " ]

  it "maintains leading and trailing whitespace within double-quoted values" $
    parse "A=' a '" `shouldEqual` success [ Tuple "A" " a " ]
