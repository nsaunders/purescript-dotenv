-- | This module contains the logic for resolving `.env` values.

module Dotenv.Internal.Resolve (values) where

import Prelude
import Control.Alt ((<|>))
import Data.Array.NonEmpty (toArray)
import Data.Bifunctor (rmap)
import Data.Foldable (find)
import Data.Maybe (Maybe)
import Data.String (joinWith)
import Data.Traversable (sequence)
import Data.Tuple (Tuple, fst, snd)
import Dotenv.Internal.Types (Environment, Name, Settings, Value(..))
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
      ValueExpression vs        -> joinWith "" <$> (sequence $ toArray $ value' <$> vs)
      VariableSubstitution name -> lookup name env <|> (value' =<< snd <$> find (eq name <<< fst) settings)

-- | Given the environment and an array of `.env` settings, resolves the value of each setting.
values :: Environment -> Settings -> Array (Tuple Name (Maybe String))
values env settings = rmap (value env settings) <$> settings
