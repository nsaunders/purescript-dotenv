-- | This module encapsulates the parsing logic for a `.env` file.

module Configuration.Dotenv.Parse (configParser) where

import Prelude
import Control.Alt ((<|>))
import Data.Array (many)
import Data.List (List, catMaybes)
import Data.Tuple (Tuple(..))
import Data.String.CodeUnits (fromCharArray)
import Text.Parsing.Parser (Parser)
import Text.Parsing.Parser.Combinators ((<?>), optionMaybe, sepBy)
import Text.Parsing.Parser.String (char, noneOf)

-- | A `.env` file parser
configParser :: Parser String (List (Tuple String String))
configParser = do
  variables <- optionMaybe variable `sepBy` eol
  pure $ catMaybes variables

-- | Parses the end of a line.
eol :: Parser String Char
eol = newline <|> crlf <?> "new-line"
  where
    newline = char '\n' <?> "lf new-line"
    crlf = char '\r' *> char '\n' <?> "crlf new-line"

-- | Parses a variable in the form of `KEY=value`.
variable :: Parser String (Tuple String String)
variable = do
  name <- fromCharArray <$> many (noneOf ['=', '\r', '\n'])
  _ <- char '='
  value <- fromCharArray <$> many (noneOf ['\r', '\n'])
  pure $ Tuple name value
