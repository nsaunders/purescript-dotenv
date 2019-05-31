-- | This module encapsulates the parsing logic for a `.env` file.

module Dotenv.Internal.Parse where

import Prelude hiding (between)
import Control.Alt ((<|>))
import Data.Array (fromFoldable, head, length, many, some)
import Data.Maybe (fromMaybe)
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
  skipMany notSetting
  (setting <* many (noneOf newlineChars)) `sepEndBy` skipMany notSetting
  where
    notSetting = void comment <|> void (oneOf newlineChars)

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

-- | Parses a command substitution, i.e. `$(whoami)`.
commandSubstitution :: Parser String Value
commandSubstitution = string "$(" *> (CommandSubstitution <<< fromCharArray <$> some (noneOf [')'])) <* char ')'

-- | Parses a quoted value, enclosed in the specified type of quotation mark.
quotedValue :: Char -> Parser String Value
quotedValue q =
  let
    literal = LiteralValue <<< fromCharArray <$> some (noneOf ['$', q] <|> try (char '$' <* notFollowedBy (char '{')))
  in
    valueFromValues <$> (char q *> (some $ variableSubstitution <|> commandSubstitution <|> literal) <* char q)

-- | Parses an unquoted value.
unquotedValue :: Parser String Value
unquotedValue =
  let
    literal = map
      ( LiteralValue <<< fromCharArray )
      $ some 
          $ try (noneOf (['$', '#'] <> whitespaceChars <> newlineChars))
        <|> try (char '$' <* notFollowedBy (oneOf ['{', '(']))
        <|> try (oneOf whitespaceChars <* lookAhead (noneOf $ ['#'] <> whitespaceChars <> newlineChars))
  in
    valueFromValues <$> (whiteSpace *> (some $ variableSubstitution <|> commandSubstitution <|> literal))

-- | Assembles a single value from a series of values.
valueFromValues :: Array Value -> Value
valueFromValues v
  | length v == 1 = fromMaybe (ValueExpression []) (head v)
  | otherwise     = ValueExpression v

-- | Parses a setting value.
value :: Parser String Value
value = (quotedValue '"' <|> quotedValue '\'' <|> unquotedValue) <?> "variable value"

-- | Parses a setting in the form of `NAME=value`.
setting :: Parser String Setting
setting = Tuple <$> name <*> value
