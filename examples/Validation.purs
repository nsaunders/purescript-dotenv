module Example.Validation (main) where

import Prelude
import Data.Either (Either(..), note)
import Data.Int (fromString) as Int
import Data.List.Lazy (replicateM)
import Dotenv (loadFile) as Dotenv
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Foreign.Object (Object, lookup)
import Node.Process (getEnv)

type Config =
  { greeting :: String
  , count :: Int
  }

readConfig :: Object String -> Either String Config
readConfig env = { greeting: _, count: _ }
  <$> value "GREETING"
  <*> (value "COUNT" >>= Int.fromString >>> note "COUNT must be an integer.")

  where
    value name = note ("Missing variable " <> name) $ lookup name env

main :: Effect Unit
main = launchAff_ do
  _ <- Dotenv.loadFile
  liftEffect do
    eitherConfig <- readConfig <$> getEnv
    case eitherConfig of
      Left error ->
        log $ "Configuration error: " <> error
      Right { greeting, count } -> do
        _ <- replicateM count $ log greeting
        pure unit
