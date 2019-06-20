-- | This module contains the logic for resolving `.env` values.

module Dotenv.Internal.Resolve (values) where

import Prelude
import Control.Alt ((<|>))
import Data.Bifunctor (rmap)
import Data.Foldable (find)
import Data.Maybe (Maybe)
import Data.String (joinWith)
import Data.Traversable (sequence)
import Data.Tuple (fst, snd)
import Dotenv.Internal.Types (Environment, Settings, Value(..))
import Dotenv.Types (Settings) as Public
import Foreign.Object (lookup)

-- | Given the environment and an array of `.env` settings, resolves the specified value.
value
  :: Environment
  -> Settings
  -> Value
  -> Maybe String
value env settings val =
  let
    value' = value env settings
  in
    case val of
      LiteralValue v            -> pure v
      CommandSubstitution c _   -> pure c
      ValueExpression vs        -> joinWith "" <$> (sequence $ value' <$> vs)
      VariableSubstitution name -> lookup name env <|> (value' =<< snd <$> find (eq name <<< fst) settings)

-- | Given the environment and an array of `.env` settings, resolves the value of each setting.
values :: Environment -> Settings -> Public.Settings
values env settings = rmap (value env settings) <$> settings
