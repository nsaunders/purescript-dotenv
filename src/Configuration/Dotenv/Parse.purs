-- | This module encapsulates the parsing logic for a `.env` file.

module Configuration.Dotenv.Parse where

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
tillEnd :: Parser String String
tillEnd = unfoldToString <$> manyTill anyChar (lookAhead eol <|> eof)

-- | Parses a comment in the form of `# Comment`.
comment :: Parser String String
comment = char '#' *> tillEnd

unquotedValue :: Parser String (List Char)
unquotedValue = manyTill anyChar (lookAhead eol <|> eof)

quotedValue :: Char -> Parser String (List Char)
quotedValue q = char q *> manyTill anyChar (char q)

-- | Parses a variable in the form of `KEY=value`.
variable :: Parser String (Tuple String String)
variable = do
  name <- unfoldToString <$> manyTill anyChar (char '=')
  value <- trim <<< unfoldToString <$> (quotedValue '"' <|> unquotedValue)
  pure $ Tuple name value

-- | Creates a `String` from a character list.
unfoldToString :: forall f. Foldable f => f Char -> String
unfoldToString = String.fromCharArray <<< Array.fromFoldable
