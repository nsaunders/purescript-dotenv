-- | This module encapsulates the parsing logic for a `.env` file.

module Dotenv.Internal.Parse (settings) where

import Prelude hiding (between)
import Control.Alt ((<|>))
import Data.Array (fromFoldable, many, some)
import Data.Array.NonEmpty (head, length, some) as NonEmpty
import Data.Array.NonEmpty (NonEmptyArray)
import Data.String.CodeUnits (fromCharArray)
import Data.Tuple (Tuple(..))
import Dotenv.Internal.Types (Name, Setting, Settings, Value(..))
import Text.Parsing.Parser (Parser)
import Text.Parsing.Parser.Combinators ((<?>), lookAhead, notFollowedBy, skipMany, sepEndBy, try)
import Text.Parsing.Parser.String (char, noneOf, oneOf, string, whiteSpace)
import Text.Parsing.Parser.Token (alphaNum)

-- | Newline characters (carriage return / line feed)
newlineChars :: Array Char
newlineChars = ['\r', '\n']

-- | Whitespace characters (excluding newline characters)
whitespaceChars :: Array Char
whitespaceChars = [' ', '\t']

-- | Parses `.env` settings.
settings :: Parser String Settings
settings = fromFoldable <$> do
  skipMany (void comment <|> void (oneOf newlineChars))
  setting `sepEndBy` (oneOf newlineChars *> skipMany (void comment <|> void (oneOf newlineChars)))

-- | Parses a comment in the form of `# Comment`.
comment :: Parser String String
comment = char '#' *> (fromCharArray <$> many (noneOf newlineChars))

-- | Parses a setting name.
name :: Parser String Name
name = fromCharArray <$> many (alphaNum <|> char '_') <* char '='

-- | Parses a variable substitution, i.e. `${VARIABLE_NAME}`.
variableSubstitution :: Parser String Value
variableSubstitution =
  string "${" *> (VariableSubstitution <<< fromCharArray <$> some (alphaNum <|> char '_')) <* char '}'

-- | Parses a quoted value, enclosed in the specified type of quotation mark.
quotedValue :: Char -> Parser String Value
quotedValue q = valueFromValues <$> (char q *> (NonEmpty.some $ variableSubstitution <|> literal) <* char q)
  where
    literal = LiteralValue <<< fromCharArray <$> some (noneOf ['$', q] <|> try (char '$' <* notFollowedBy (char '{')))

-- | Parses an unquoted value.
unquotedValue :: Parser String Value
unquotedValue = valueFromValues <$> (whiteSpace *> (NonEmpty.some $ variableSubstitution <|> literal))
  where
    literal = map
      ( LiteralValue <<< fromCharArray)
      $ some 
          $ try (noneOf (['$', '#'] <> whitespaceChars <> newlineChars))
        <|> try (char '$' <* notFollowedBy (char '{'))
        <|> try (oneOf whitespaceChars <* lookAhead (noneOf $ ['#'] <> whitespaceChars <> newlineChars))

-- | Assembles a single value from a series of values.
valueFromValues :: NonEmptyArray Value -> Value
valueFromValues v
  | NonEmpty.length v == 1 = NonEmpty.head v
  | otherwise              = ValueExpression v

-- | Parses a setting value.
value :: Parser String Value
value = (quotedValue '"' <|> quotedValue '\'' <|> unquotedValue) <?> "variable value"

-- | Parses a setting in the form of `NAME=value`.
setting :: Parser String Setting
setting = Tuple <$> name <*> value
