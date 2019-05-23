-- | This module defines type aliases representing `.env` settings.

module Dotenv.Types (Name, Setting, Settings, Value) where

import Data.Maybe (Maybe)
import Data.Tuple (Tuple)

-- The type of a setting name
type Name = String

-- The type of a (resolved) value
type Value = Maybe String

-- The type of a setting
type Setting = Tuple Name Value

-- The type of settings
type Settings = Array Setting
