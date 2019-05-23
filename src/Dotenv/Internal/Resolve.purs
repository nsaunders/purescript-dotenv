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
import Dotenv.Internal.Types (Name, Setting, Value(..))
import Foreign.Object (Object, lookup)

-- | Given the environment and an array of `.env` settings, resolves the specified value.
value
  :: Object String
  -> Array (Tuple Name Value)
  -> Value
  -> Maybe String
value env settings val =
  let
    value' = value env settings
  in
    case val of
      LiteralValue value        -> pure value
      ValueExpression values    -> joinWith "" <$> (sequence $ toArray $ value' <$> values)
      VariableSubstitution name -> lookup name env <|> (value' =<< snd <$> find (eq name <<< fst) settings)

-- | Given the environment and an array of `.env` settings, resolves the value of each setting.
values :: Object String -> Array (Tuple Name Value) -> Array (Tuple Name (Maybe String))
values env settings = rmap (value env settings) <$> settings
