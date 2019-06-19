-- | This module contains data types representing parsed `.env` content and the unmodified environment.

module Dotenv.Internal.Types (Environment, Name, Setting, Settings, Value(..)) where

import Prelude
import Data.Tuple (Tuple)
import Foreign.Object (Object)

-- | The name of a setting
type Name = String

-- | The value of a setting
data Value = LiteralValue String | VariableSubstitution String | ValueExpression (Array Value)

derive instance eqValue :: Eq Value

instance showValue :: Show Value where
  show (LiteralValue v) = "(LiteralValue \"" <> v <> "\")"
  show (VariableSubstitution v) = "(VariableSubstitution \"" <> v <> "\")"
  show (ValueExpression vs) = "(ValueExpression " <> show vs <> ")"

-- | The conjunction of a setting name and the corresponding value
type Setting = Tuple Name Value

-- | A collection of settings
type Settings = Array (Tuple Name Value)

-- | Environment variables
type Environment = Object String
