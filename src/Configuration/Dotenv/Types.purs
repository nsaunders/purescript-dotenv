module Configuration.Dotenv.Types (Config(..), defaultConfig) where

import Prelude
import Node.Path (FilePath)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)

newtype Config = Config
  { path :: Array FilePath
  , examplePath :: Array FilePath
  , override :: Boolean
  }

derive instance eqConfig :: Eq Config
derive instance genericConfig :: Generic Config _

instance showConfig :: Show Config where
  show = genericShow

defaultConfig :: Config
defaultConfig = Config
  { examplePath: []
  , override: false
  , path: [".env"]
  }
