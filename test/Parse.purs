module Test.Parse (tests) where

import Prelude
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))
import Dotenv.Internal.Parse (settings)
import Dotenv.Internal.Types (Value(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Text.Parsing.Parser (runParser)

tests :: Spec Unit
tests = describe "settings parser" do

  it "skips blank lines" $
    let
      expected = Right [ Tuple "A" $ LiteralValue "B", Tuple "C" $ LiteralValue "D" ]
      actual = "A=B\n\nC=D" `runParser` settings
    in
      actual `shouldEqual` expected
 
  it "skips commented lines" $
    let
      expected = Right [ Tuple "A" $ LiteralValue "B", Tuple "C" $ LiteralValue "D" ]
      actual = "# Comment\nA=B\n# Comment\n# Comment\nC=D" `runParser` settings
    in
      actual `shouldEqual` expected

  it "skips comments on the same line after a setting" $
    let
      expected = Right [ Tuple "A" $ LiteralValue "B", Tuple "C" $ LiteralValue "D", Tuple "E" $ LiteralValue "F" ]
      actual = "A=B\nC=D # Testing\nE=F" `runParser` settings
    in
      actual `shouldEqual` expected

  it "trims unquoted values" $
    let
      expected = Right [ Tuple "A" $ LiteralValue "a" ]
      actual = "A= \t a " `runParser` settings
    in
      actual `shouldEqual` expected

  it "parses single-quoted values" $
    let
      expected = Right [ Tuple "A" $ LiteralValue "a" ]
      actual = "A='a'" `runParser` settings
    in
      actual `shouldEqual` expected

  it "parses double-quoted values" $
    let
      expected = Right [ Tuple "A" $ LiteralValue "a" ]
      actual = "A=\"a\"" `runParser` settings
    in
      actual `shouldEqual` expected

  it "parses multiline values" $
    let
      expected = Right [ Tuple "A" $ LiteralValue "Testing\r\n123" ]
      actual = "A=\"Testing\r\n123\"" `runParser` settings
    in
      actual `shouldEqual` expected

  it "maintains inner quotes" $
    let
      expected = Right [ Tuple "JSON" $ LiteralValue "{\"a\": \"aval\"}" ]
      actual = "JSON={\"a\": \"aval\"}" `runParser` settings
    in
      actual `shouldEqual` expected

  it "maintains leading and trailing whitespace within single-quoted values" $
    let
      expected = Right [ Tuple "A" $ LiteralValue "\t \ta \t" ]
      actual = "A='\t \ta \t'" `runParser` settings
    in
      actual `shouldEqual` expected

  it "maintains leading and trailing whitespace within single-quoted values" $
    let
      expected = Right [ Tuple "A" $ LiteralValue " \t a \t " ]
      actual = "A=\" \t a \t \"" `runParser` settings
    in
      actual `shouldEqual` expected

  it "parses variable substitutions" $
    let
      expected =
        Right [ Tuple "A" $ ValueExpression [ LiteralValue "Hi, ", VariableSubstitution "USER", LiteralValue "!" ] ]
      actual = "A=Hi, ${USER}!" `runParser` settings
    in
      actual `shouldEqual` expected
