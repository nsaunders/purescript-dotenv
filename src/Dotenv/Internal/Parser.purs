-- | This module encapsulates the parsing logic for a `.env` file.

module Dotenv.Internal.Parser (parser) where

import Prelude hiding (between)

import Control.Alt ((<|>))
import Data.Array (fromFoldable, head, length, many, some, (:))
import Data.Maybe (fromMaybe)
import Data.String.CodeUnits (fromCharArray)
import Data.Tuple (Tuple(..))
import Dotenv.Internal.Types (Name, Setting, UnresolvedValue(..))
import Parsing (Parser)
import Parsing.Combinators
  ( lookAhead
  , notFollowedBy
  , sepEndBy
  , skipMany
  , try
  , (<?>)
  )
import Parsing.String (char, string)
import Parsing.String.Basic (noneOf, oneOf, whiteSpace)
import Parsing.Token (alphaNum)

-- | Newline characters (carriage return / line feed)
newlineChars :: Array Char
newlineChars = [ '\r', '\n' ]

-- | Whitespace characters (excluding newline characters)
whitespaceChars :: Array Char
whitespaceChars = [ ' ', '\t' ]

-- | Parses `.env` settings.
parser :: Parser String (Array (Setting UnresolvedValue))
parser = fromFoldable <$> do
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
variableSubstitution :: Parser String UnresolvedValue
variableSubstitution =
  string "${"
    *> (VariableSubstitution <<< fromCharArray <$> some (alphaNum <|> char '_'))
    <* char '}'

-- | Parses a command substitution, i.e. `$(whoami)`.
commandSubstitution :: Parser String UnresolvedValue
commandSubstitution = do
  _ <- string "$("
  command <- fromCharArray <$> (some (noneOf (')' : whitespaceChars)))
  arguments <- many
    (whiteSpace *> (fromCharArray <$> (some (noneOf (')' : whitespaceChars)))))
  _ <- whiteSpace *> char ')'
  pure $ CommandSubstitution command arguments

-- | Parses a quoted value, enclosed in the specified type of quotation mark.
quotedValue :: Char -> Parser String UnresolvedValue
quotedValue q =
  let
    literal =
      LiteralValue <<< fromCharArray <$> some
        ( (try $ char '\\' *> char q *> pure q) <|> noneOf [ '$', q ] <|> try
            (char '$' <* notFollowedBy (oneOf [ '{', '(' ]))
        )
  in
    valueFromValues <$>
      ( char q
          *> (some $ variableSubstitution <|> commandSubstitution <|> literal)
          <* char q
      )

-- | Parses an unquoted value.
unquotedValue :: Parser String UnresolvedValue
unquotedValue =
  let
    literal =
      map
        (LiteralValue <<< fromCharArray)
        $ some
        $ try (noneOf ([ '$', '#' ] <> whitespaceChars <> newlineChars))
            <|> try (char '$' <* notFollowedBy (oneOf [ '{', '(' ]))
            <|> try
              ( oneOf whitespaceChars <* lookAhead
                  (noneOf $ [ '#' ] <> whitespaceChars <> newlineChars)
              )
  in
    valueFromValues <$>
      ( whiteSpace *>
          (some $ variableSubstitution <|> commandSubstitution <|> literal)
      )

-- | Assembles a single value from a series of values.
valueFromValues :: Array UnresolvedValue -> UnresolvedValue
valueFromValues v
  | length v == 1 = fromMaybe (ValueExpression []) (head v)
  | otherwise = ValueExpression v

-- | Parses a setting value.
value :: Parser String UnresolvedValue
value = (quotedValue '"' <|> quotedValue '\'' <|> unquotedValue) <?>
  "variable value"

-- | Parses a setting in the form of `NAME=value`.
setting :: Parser String (Setting UnresolvedValue)
setting = Tuple <$> name <*> value
