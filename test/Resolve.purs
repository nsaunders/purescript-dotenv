module Test.Resolve (tests) where

import Prelude
import Data.Foldable (find)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..), fst, snd)
import Dotenv.Internal.Resolve (values) as Resolve
import Dotenv.Internal.Types (Name, Value(..))
import Dotenv.Types (Settings)
import Foreign.Object (singleton)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

settings :: Settings
settings = Resolve.values (singleton "DB_PASSWORD" "asdf") $
  [ Tuple "DB_HOSTNAME" $ LiteralValue "localhost"
  , Tuple "DB_HOST" $ VariableSubstitution "DB_HOSTNAME"
  , Tuple "DB_USER" $ LiteralValue "nick"
  , Tuple "DB_PASS" $ VariableSubstitution "DB_PASSWORD"
  , Tuple "DB_NAME" $ LiteralValue "development"
  , Tuple "DB_CRED" $
      ValueExpression
        [ VariableSubstitution "DB_USER"
        , LiteralValue ":"
        , VariableSubstitution "DB_PASS"
        ]
  , Tuple "DB_CONNECTION_STRING" $
      ValueExpression
        [ LiteralValue "db://"
        , VariableSubstitution "DB_CRED"
        , LiteralValue "@"
        , VariableSubstitution "DB_HOST"
        , LiteralValue "/"
        , VariableSubstitution "DB_NAME"
        ]
  ]

settingValue :: Name -> Maybe String
settingValue name = join $ snd <$> find (eq name <<< fst) settings

tests :: Spec Unit
tests = describe "value resolver" do

  it "resolves literal values" $
    settingValue "DB_HOST" `shouldEqual` Just "localhost"

  it "resolves variable substitutions from the environment" $
    settingValue "DB_PASS" `shouldEqual` Just "asdf"

  it "resolves variable substitutions from the settings" $
    settingValue "DB_HOST" `shouldEqual` Just "localhost"

  it "resolves value expressions" $
    settingValue "DB_CRED" `shouldEqual` Just "nick:asdf"

  it "resolves value expressions recursively" $
    settingValue "DB_CONNECTION_STRING" `shouldEqual` Just "db://nick:asdf@localhost/development"
