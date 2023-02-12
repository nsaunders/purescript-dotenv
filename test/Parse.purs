module Test.Parser (tests) where

import Prelude

import Data.Either (Either(..))
import Data.Tuple.Nested ((/\))
import Dotenv.Internal.Parser (parser)
import Dotenv.Internal.Types (UnresolvedValue(..))
import Parsing (runParser)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

tests :: Spec Unit
tests = describe "parser" do

  it "skips blank lines" $
    let
      expected = Right [ "A" /\ LiteralValue "B", "C" /\ LiteralValue "D" ]
      actual = runParser "A=B\n\nC=D" parser
    in
      actual `shouldEqual` expected

  it "skips commented lines" $
    let
      expected = Right [ "A" /\ LiteralValue "B", "C" /\ LiteralValue "D" ]
      actual = runParser "# Comment\nA=B\n# Comment\n# Comment\nC=D" parser
    in
      actual `shouldEqual` expected

  it "skips comments on the same line after a setting" $
    let
      expected = Right
        [ "A" /\ LiteralValue "B"
        , "C" /\ LiteralValue "D"
        , "E" /\ LiteralValue "F"
        ]
      actual = runParser "A=B\nC=D # Testing\nE=F" parser
    in
      actual `shouldEqual` expected

  it "trims unquoted values" $
    let
      expected = Right [ "A" /\ LiteralValue "a" ]
      actual = runParser "A= \t a " parser
    in
      actual `shouldEqual` expected

  it "parses single-quoted values" $
    let
      expected = Right [ "A" /\ LiteralValue "a" ]
      actual = runParser "A='a'" parser
    in
      actual `shouldEqual` expected

  it "parses escaped single quotes" $
    let
      expected = Right [ "A" /\ LiteralValue "'a'" ]
      actual = runParser "A='\\'a\\''" parser
    in
      actual `shouldEqual` expected

  it "parses double-quoted values" $
    let
      expected = Right [ "A" /\ LiteralValue "a" ]
      actual = runParser "A=\"a\"" parser
    in
      actual `shouldEqual` expected

  it "parses escaped double quotes" $
    let
      expected = Right [ "A" /\ LiteralValue "\"a\"" ]
      actual = runParser "A=\"\\\"a\\\"\"" parser
    in
      actual `shouldEqual` expected

  it "parses multiline values" $
    let
      expected = Right [ "A" /\ LiteralValue "Testing\r\n123" ]
      actual = runParser "A=\"Testing\r\n123\"" parser
    in
      actual `shouldEqual` expected

  it "maintains inner quotes" $
    let
      expected = Right [ "JSON" /\ LiteralValue "{\"a\": \"aval\"}" ]
      actual = runParser "JSON={\"a\": \"aval\"}" parser
    in
      actual `shouldEqual` expected

  it "maintains leading and trailing whitespace within single-quoted values" $
    let
      expected = Right [ "A" /\ LiteralValue "\t \ta \t" ]
      actual = runParser "A='\t \ta \t'" parser
    in
      actual `shouldEqual` expected

  it "maintains leading and trailing whitespace within single-quoted values" $
    let
      expected = Right [ "A" /\ LiteralValue " \t a \t " ]
      actual = runParser "A=\" \t a \t \"" parser
    in
      actual `shouldEqual` expected

  it "parses variable substitutions within unquoted values" $
    let
      expected =
        Right
          [ "A" /\
              ValueExpression
                [ LiteralValue "Hi, "
                , VariableSubstitution "USER"
                , LiteralValue "!"
                ]
          ]
      actual = runParser "A=Hi, ${USER}!" parser
    in
      actual `shouldEqual` expected

  it "parses variable substitutions within quoted values" $
    let
      expected =
        Right
          [ "A" /\
              ValueExpression
                [ LiteralValue "Hi, "
                , VariableSubstitution "USER"
                , LiteralValue "!"
                ]
          ]
      actual = runParser "A=\"Hi, ${USER}!\"" parser
    in
      actual `shouldEqual` expected

  it "parses command substitutions within unquoted values" $
    let
      expected =
        Right
          [ "A" /\
              ValueExpression
                [ LiteralValue "Hello, "
                , CommandSubstitution "head" [ "-n", "1", "user.txt" ]
                , LiteralValue "!"
                ]
          ]
      actual = runParser "A=Hello, $(head -n 1 user.txt)!" parser
    in
      actual `shouldEqual` expected

  it "parses command substitutions within quoted values" $
    let
      expected =
        Right
          [ "A" /\
              ValueExpression
                [ LiteralValue "Hello, "
                , CommandSubstitution "head" [ "-n", "1", "user.txt" ]
                , LiteralValue "!"
                ]
          ]
      actual = runParser "A=\"Hello, $(head -n 1 user.txt)!\"" parser
    in
      actual `shouldEqual` expected