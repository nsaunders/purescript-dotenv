-- | This module contains the data types representing parsed `.env` content.

module Dotenv.Internal.Types (Environment, Name, Setting, Settings, Value(..)) where

import Prelude
import Data.Array.NonEmpty (NonEmptyArray)
import Data.Tuple (Tuple)
import Foreign.Object (Object)

-- | The name of a setting
type Name = String

-- | The value of a setting
data Value = LiteralValue String | VariableSubstitution String | ValueExpression (NonEmptyArray Value)

derive instance eqValue :: Eq Value

instance showValue :: Show Value where
  show (LiteralValue v) = "(LiteralValue \"" <> v <> "\")"
  show (VariableSubstitution v) = "(VariableSubstitution \"" <> v <> "\")"
  show (ValueExpression vs) = "(ValueExpression " <> show vs <> ")"

-- | The conjunction of a setting name and value
type Setting = Tuple Name Value

-- | A collection of settings
type Settings = Array (Tuple Name Value)

-- | Environment variables
type Environment = Object String
