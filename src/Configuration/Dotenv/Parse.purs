-- | This module encapsulates the parsing logic for a `.env` file.

module Configuration.Dotenv.Parse (configParser) where

import Prelude
import Control.Alt ((<|>))
import Data.Array (fromFoldable) as Array
import Data.Array (many)
import Data.List (List, catMaybes)
import Data.Tuple (Tuple(..))
import Data.String.CodeUnits (fromCharArray) as String
import Text.Parsing.Parser (Parser)
import Text.Parsing.Parser.Combinators ((<?>), manyTill, optionMaybe, sepEndBy, skipMany)
import Text.Parsing.Parser.String (anyChar, char, noneOf)

-- | A `.env` file parser
configParser :: Parser String (List (Tuple String String))
configParser = do
  skipMany comment
  variables <- optionMaybe variable `sepEndBy` (eol *> skipMany comment)
  pure $ catMaybes variables

-- | Parses the end of a line.
eol :: Parser String Char
eol = newline <|> crlf <?> "new-line"
  where
    newline = char '\n' <?> "lf new-line"
    crlf = char '\r' *> char '\n' <?> "crlf new-line"

-- | Parses a comment in the form of `# Comment`.
comment :: Parser String String
comment = char '#' *> ((String.fromCharArray <<< Array.fromFoldable) <$> manyTill anyChar eol)

-- | Parses a variable in the form of `KEY=value`.
variable :: Parser String (Tuple String String)
variable = do
  name <- String.fromCharArray <$> many (noneOf ['=', '\r', '\n'])
  _ <- char '='
  value <- String.fromCharArray <$> many (noneOf ['\r', '\n'])
  pure $ Tuple name value
