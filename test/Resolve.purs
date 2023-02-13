module Test.Resolve (tests) where

import Prelude

import Control.Monad.Error.Class (throwError)
import Data.Foldable (lookup) as F
import Data.Map (Map, lookup, singleton)
import Data.Maybe (Maybe(..))
import Data.String.Common (joinWith)
import Data.Tuple.Nested (type (/\), (/\))
import Dotenv.Internal.ChildProcess (ChildProcessF(..), _childProcess)
import Dotenv.Internal.Environment (EnvironmentF(..), _environment)
import Dotenv.Internal.Resolve (resolve)
import Dotenv.Internal.Types (ResolvedValue, Setting, UnresolvedValue(..))
import Effect.Aff (Aff)
import Effect.Exception (error)
import Run (case_, interpret, on)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

configuration :: Array (Setting UnresolvedValue)
configuration =
  [ "DB_HOSTNAME" /\ LiteralValue "localhost"
  , "DB_HOST" /\ VariableSubstitution "DB_HOSTNAME"
  , "DB_USER" /\ CommandSubstitution "whoami" []
  , "DB_PASS" /\ VariableSubstitution "DB_PASSWORD"
  , "DB_NAME" /\ LiteralValue "development"
  , "DB_CRED" /\
      ValueExpression
        [ VariableSubstitution "DB_USER"
        , LiteralValue ":"
        , VariableSubstitution "DB_PASS"
        ]
  , "DB_CONNECTION_STRING" /\
      ValueExpression
        [ LiteralValue "db://"
        , VariableSubstitution "DB_CRED"
        , LiteralValue "@"
        , VariableSubstitution "DB_HOST"
        , LiteralValue "/"
        , VariableSubstitution "DB_NAME"
        ]
  , "SELF_REFERENCING" /\ ValueExpression
      [ LiteralValue ".", VariableSubstitution "SELF_REFERENCING" ]
  , "CIRCULAR_REF_A" /\ ValueExpression
      [ LiteralValue ".", VariableSubstitution "CIRCULAR_REF_B" ]
  , "CIRCULAR_REF_B" /\ ValueExpression
      [ LiteralValue ".", VariableSubstitution "CIRCULAR_REF_C" ]
  , "CIRCULAR_REF_C" /\ ValueExpression
      [ LiteralValue ".", VariableSubstitution "CIRCULAR_REF_A" ]
  ]

commands :: Map (String /\ Array String) String
commands = singleton ("whoami" /\ []) "user\n"

variables :: Map String String
variables = singleton "DB_PASSWORD" "p4s5w0rD!"

handleChildProcess :: ChildProcessF ~> Aff
handleChildProcess (Spawn cmd args callback) =
  case (lookup (cmd /\ args) commands) of
    Just result ->
      pure $ callback result
    Nothing ->
      throwError $ error
        ("Unrecognized command: " <> cmd <> " " <> joinWith " " args)

handleEnvironment :: EnvironmentF ~> Aff
handleEnvironment op =
  case op of
    LookupEnv name callback ->
      pure $ callback (lookup name variables)
    SetEnv _ _ _ ->
      throwError $ error "The environment was modified while resolving values."

resolve' :: String -> Aff ResolvedValue
resolve' name =
  case F.lookup name configuration of
    Nothing ->
      pure Nothing
    Just unresolvedValue ->
      resolve configuration (pure name) unresolvedValue
        # interpret
            ( case_
                # on _childProcess handleChildProcess
                # on _environment handleEnvironment
            )

tests :: Spec Unit
tests = describe "resolve" do

  it "resolves literal values" do
    resolved <- resolve' "DB_HOST"
    resolved `shouldEqual` Just "localhost"

  it "resolves variable substitutions from the environment" do
    resolved <- resolve' "DB_PASS"
    resolved `shouldEqual` Just "p4s5w0rD!"

  it "resolves variable substitutions from the settings" do
    resolved <- resolve' "DB_HOST"
    resolved `shouldEqual` Just "localhost"

  it "resolves command substitutions" do
    resolved <- resolve' "DB_USER"
    resolved `shouldEqual` Just "user"

  it "resolves value expressions" do
    resolved <- resolve' "DB_CRED"
    resolved `shouldEqual` Just "user:p4s5w0rD!"

  it "resolves value expressions recursively" do
    resolved <- resolve' "DB_CONNECTION_STRING"
    resolved `shouldEqual` Just "db://user:p4s5w0rD!@localhost/development"

  it "does not allow self-referencing variables" do
    resolved <- resolve' "SELF_REFERENCING"
    resolved `shouldEqual` Nothing

  it "does not allow circular references" do
    resolved <- resolve' "CIRCULAR_REF_A"
    resolved `shouldEqual` Nothing