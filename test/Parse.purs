module Test.Parse (tests) where

import Prelude
import Data.Either (Either(..))
import Data.List (List(Nil), (:))
import Data.Tuple (Tuple(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Text.Parsing.Parser (runParser)
import Configuration.Dotenv.Parse (settings)
import Configuration.Dotenv.Types (Value(..))

tests :: Spec Unit
tests = describe "settings parser" do

  it "skips blank lines" $
    let
      expected = Right $ Tuple "A" (LiteralValue "B") : Tuple "C" (LiteralValue "D") : Nil
      actual = "A=B\n\nC=D" `runParser` settings
    in
      actual `shouldEqual` expected
 
  it "skips commented lines" $
    let
      expected = Right $ Tuple "A" (LiteralValue "B") : Tuple "C" (LiteralValue "D") : Nil
      actual = "# Comment\nA=B\n# Comment\n# Comment\nC=D" `runParser` settings
    in
      actual `shouldEqual` expected

  it "skips comments on the same line after a setting" $
    let
      expected = Right $ Tuple "A" (LiteralValue "B") : Tuple "C" (LiteralValue "D") : Nil
      actual = "A=B\nC=D # Testing" `runParser` settings
    in
      actual `shouldEqual` expected

  it "trims unquoted values" $
    let
      expected = Right $ Tuple "A" (LiteralValue "a") : Nil
      actual = "A= \t a " `runParser` settings
    in
      actual `shouldEqual` expected

  it "parses single-quoted values" $
    let
      expected = Right $ Tuple "A" (LiteralValue "a") : Nil
      actual = "A='a'" `runParser` settings
    in
      actual `shouldEqual` expected

  it "parses double-quoted values" $
    let
      expected = Right $ Tuple "A" (LiteralValue "a") : Nil
      actual = "A=\"a\"" `runParser` settings
    in
      actual `shouldEqual` expected

  it "parses multiline values" $
    let
      expected = Right $ Tuple "A" (LiteralValue "Testing\r\n123") : Nil
      actual = "A=\"Testing\r\n123\"" `runParser` settings
    in
      actual `shouldEqual` expected

  it "maintains inner quotes" $
    let
      expected = Right $ Tuple "JSON" (LiteralValue "{\"a\": \"aval\"}") : Nil
      actual = "JSON={\"a\": \"aval\"}" `runParser` settings
    in
      actual `shouldEqual` expected

  it "maintains leading and trailing whitespace within single-quoted values" $
    let
      expected = Right $ Tuple "A" (LiteralValue "\t \ta \t") : Nil
      actual = "A='\t \ta \t'" `runParser` settings
    in
      actual `shouldEqual` expected

  it "maintains leading and trailing whitespace within single-quoted values" $
    let
      expected = Right $ Tuple "A" (LiteralValue " \t a \t ") : Nil
      actual = "A=\" \t a \t \"" `runParser` settings
    in
      actual `shouldEqual` expected
