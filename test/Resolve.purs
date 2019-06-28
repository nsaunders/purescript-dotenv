module Test.Resolve (tests) where

import Prelude
import Control.Monad.Error.Class (throwError)
import Data.Foldable (find)
import Data.Map (Map, lookup, singleton)
import Data.Maybe (Maybe(..))
import Data.String.Common (joinWith)
import Data.Tuple (Tuple(..), fst, snd)
import Dotenv.Internal.ChildProcess (ChildProcessF(..), _childProcess)
import Dotenv.Internal.Environment (EnvironmentF(..), _environment)
import Dotenv.Internal.Resolve (resolveValues)
import Dotenv.Internal.Types (ResolvedValue, Setting, UnresolvedValue(..))
import Effect.Aff (Aff)
import Effect.Exception (error)
import Run (case_, interpret, on)
import Test.Spec (Spec, before, describe, it)
import Test.Spec.Assertions (shouldEqual)

configuration :: Array (Setting UnresolvedValue)
configuration =
  [ Tuple "DB_HOSTNAME" $ LiteralValue "localhost"
  , Tuple "DB_HOST" $ VariableSubstitution "DB_HOSTNAME"
  , Tuple "DB_USER" $ CommandSubstitution "whoami" []
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

commands :: Map (Tuple String (Array String)) String
commands = singleton (Tuple "whoami" []) "user\n"

variables :: Map String String
variables = singleton "DB_PASSWORD" "p4s5w0rD!"

handleChildProcess :: ChildProcessF ~> Aff
handleChildProcess (Spawn cmd args callback) =
  case (lookup (Tuple cmd args) commands) of
    Just result ->
      pure $ callback result
    Nothing ->
      throwError $ error ("Unrecognized command: " <> cmd <> " " <> joinWith " " args)

handleEnvironment :: EnvironmentF ~> Aff
handleEnvironment op =
  case op of
    LookupEnv name callback ->
      pure $ callback (lookup name variables)
    SetEnv _ _ _ ->
      throwError $ error "The environment was modified while resolving values."

resolve :: Array (Setting UnresolvedValue) -> Aff (Array (Setting ResolvedValue))
resolve = resolveValues
  >>> interpret
    ( case_
      # on _childProcess handleChildProcess
      # on _environment handleEnvironment
    )

lookupSetting :: String -> Array (Setting ResolvedValue) -> ResolvedValue
lookupSetting name = join <<< map snd <<< find (eq name <<< fst)

tests :: Spec Unit
tests = describe "value resolver" do

  before (flip lookupSetting <$> resolve configuration) do

    it "resolves literal values" \setting -> do
      setting "DB_HOST" `shouldEqual` Just "localhost"

    it "resolves variable substitutions from the environment" \setting -> do
      setting "DB_PASS" `shouldEqual` Just "p4s5w0rD!"

    it "resolves variable substitutions from the settings" \setting -> do
      setting "DB_HOST" `shouldEqual` Just "localhost"

    it "resolves command substitutions" \setting -> do
      setting "DB_USER" `shouldEqual` Just "user"

    it "resolves value expressions" \setting -> do
      setting "DB_CRED" `shouldEqual` Just "user:p4s5w0rD!"

    it "resolves value expressions recursively" \setting -> do
      setting "DB_CONNECTION_STRING" `shouldEqual` Just "db://user:p4s5w0rD!@localhost/development"
