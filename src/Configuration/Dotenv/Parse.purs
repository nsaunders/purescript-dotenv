-- | This module encapsulates the parsing logic for a `.env` file.

module Configuration.Dotenv.Parse (configParser) where

import Prelude hiding (between)
import Control.Alt ((<|>))
import Data.Array ((:), many)
import Data.List (List)
import Data.String.CodeUnits (fromCharArray)
import Data.Tuple (Tuple(..))
import Data.String.Common (trim)
import Text.Parsing.Parser (Parser)
import Text.Parsing.Parser.Combinators (between, sepEndBy, skipMany)
import Text.Parsing.Parser.String (char, noneOf, oneOf)
import Text.Parsing.Parser.Token (alphaNum)

-- | Newline characters (carriage return / line feed)
newlineChars :: Array Char
newlineChars = ['\r', '\n']

-- | A `.env` file parser
configParser :: Parser String (List (Tuple String String))
configParser = do
  skipMany (void comment <|> void (oneOf newlineChars))
  variable `sepEndBy` (oneOf newlineChars *> skipMany (void comment <|> void (oneOf newlineChars)))

-- | Parses a comment in the form of `# Comment`.
comment :: Parser String String
comment = char '#' *> (fromCharArray <$> many (noneOf newlineChars))

-- | Parses a variable name.
name :: Parser String String
name = fromCharArray <$> many (alphaNum <|> char '_') <* char '='

-- | Parses an unquoted variable value.
unquotedValue :: Parser String String
unquotedValue = trim <<< fromCharArray <$> many (noneOf $ '#' : newlineChars)

-- | Parses a quoted variable value enclosed within the specified type of quotation mark.
quotedValue :: Char -> Parser String String
quotedValue q = between (char q) (char q) (fromCharArray <$> many (noneOf [q]))

-- | Parses a variable value.
value :: Parser String String
value = quotedValue '"' <|> quotedValue '\'' <|> unquotedValue

-- | Parses a variable in the form of `KEY=value`.
variable :: Parser String (Tuple String String)
variable = Tuple <$> name <*> value
