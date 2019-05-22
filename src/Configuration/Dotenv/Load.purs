module Configuration.Dotenv.Load where

import Prelude
import Configuration.Dotenv.Types (Name, Value(..))
import Control.Alt ((<|>))
import Data.Array.NonEmpty (toArray)
import Data.Bifunctor (rmap)
import Data.Foldable (find)
import Data.Maybe (Maybe)
import Data.String (joinWith)
import Data.Traversable (sequence)
import Data.Tuple (Tuple, fst, snd)
import Foreign.Object (Object, lookup)

resolveValue
  :: Object String
  -> Array (Tuple Name Value)
  -> Value
  -> Maybe String
resolveValue env settings val =
  let
    resolveValue' = resolveValue env settings
  in
    case val of
      LiteralValue value        -> pure value
      ValueExpression values    -> joinWith "" <$> (sequence $ toArray $ resolveValue' <$> values)
      VariableSubstitution name -> lookup name env <|> (resolveValue' =<< snd <$> find (eq name <<< fst) settings)

resolveValues :: Object String -> Array (Tuple Name Value) -> Array (Tuple String (Maybe String))
resolveValues env settings = rmap (resolveValue env settings) <$> settings
