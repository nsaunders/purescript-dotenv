-- | This module contains data types representing `.env` settings.

module Dotenv.Internal.Types (Name, ResolvedValue, Setting, UnresolvedValue(..)) where

import Prelude
import Data.Maybe (Maybe)
import Data.Tuple (Tuple)

-- | The name of a setting
type Name = String

-- | The expressed value of a setting, which has not been resolved yet
data UnresolvedValue
  = LiteralValue String
  | VariableSubstitution String
  | CommandSubstitution String (Array String)
  | ValueExpression (Array UnresolvedValue)

derive instance eqUnresolvedValue :: Eq UnresolvedValue

instance showUnresolvedValue :: Show UnresolvedValue where
  show (LiteralValue v) = "(LiteralValue \"" <> v <> "\")"
  show (VariableSubstitution v) = "(VariableSubstitution \"" <> v <> "\")"
  show (CommandSubstitution c a) = "(CommandSubstitution \"" <> c <> " " <> show a <> "\")"
  show (ValueExpression vs) = "(ValueExpression " <> show vs <> ")"

-- | The type of a resolved value
type ResolvedValue = Maybe String

-- | The product of a setting name and the corresponding value
type Setting v = Tuple Name v
