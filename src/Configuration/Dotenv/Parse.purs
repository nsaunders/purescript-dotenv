-- | This module encapsulates the parsing logic for a `.env` file.

module Configuration.Dotenv.Parse (configParser) where

import Prelude
import Control.Alt ((<|>))
import Data.Array (fromFoldable) as Array
import Data.Foldable (class Foldable)
import Data.List (List)
import Data.Tuple (Tuple(..))
import Data.String.CodeUnits (fromCharArray) as String
import Data.String.Common (trim)
import Text.Parsing.Parser (Parser)
import Text.Parsing.Parser.Combinators ((<?>), lookAhead, manyTill, notFollowedBy, sepEndBy, skipMany)
import Text.Parsing.Parser.String (anyChar, char)

-- | A `.env` file parser
configParser :: Parser String (List (Tuple String String))
configParser = do
  skipMany ((comment *> pure unit) <|> eol)
  variable `sepEndBy` (eol *> skipMany ((comment *> pure unit) <|> eol))

-- | Parses the end of a line.
eol :: Parser String Unit
eol = (newline <|> crlf <?> "newline") *> pure unit
  where
    newline = char '\n' <?> "lf newline"
    crlf = char '\r' *> char '\n' <?> "crlf newline"

-- | Parses the end of a file.
eof :: Parser String Unit
eof = notFollowedBy anyChar

-- | Parses the remainder of the line.
tillEnd :: Parser String (List Char)
tillEnd = manyTill anyChar (lookAhead eol <|> eof)

-- | Creates a `String` from a character list.
unfoldToString :: forall f. Foldable f => f Char -> String
unfoldToString = String.fromCharArray <<< Array.fromFoldable

-- | Parses a comment in the form of `# Comment`.
comment :: Parser String String
comment = unfoldToString <$> (char '#' *> tillEnd)

-- | Parses a variable name.
name :: Parser String String
name = unfoldToString <$> (manyTill anyChar $ char '=')

-- | Parses an unquoted variable value.
unquotedValue :: Parser String (List Char)
unquotedValue = manyTill anyChar ((lookAhead comment *> pure unit) <|> lookAhead eol <|> eof)

-- | Parses a quoted variable value enclosed within the specified type of quotation mark.
quotedValue :: Char -> Parser String (List Char)
quotedValue q = char q *> manyTill anyChar (char q)

-- | Parses a variable value.
value :: Parser String String
value = unfoldToString <$> (quotedValue '"' <|> quotedValue '\'') <|> trim <<< unfoldToString <$> unquotedValue

-- | Parses a variable in the form of `KEY=value`.
variable :: Parser String (Tuple String String)
variable = Tuple <$> name <*> value
