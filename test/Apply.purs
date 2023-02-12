module Test.Apply (tests) where

import Prelude hiding (apply)

import Data.Foldable (lookup) as F
import Data.Map (Map, insert, lookup, singleton)
import Data.Maybe (Maybe(..))
import Data.Tuple (fst)
import Data.Tuple.Nested (type (/\), (/\))
import Dotenv.Internal.Apply (apply)
import Dotenv.Internal.ChildProcess (ChildProcessF(..), _childProcess)
import Dotenv.Internal.Environment (EnvironmentF(..), _environment)
import Dotenv.Internal.Types (Setting, UnresolvedValue(..))
import Run (Run, case_, extract, interpret, on)
import Run.Writer (WRITER, runWriter, tell)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual, shouldNotContain)

settings :: Array (Setting UnresolvedValue)
settings = [ "VAR_ONE" /\ LiteralValue "one", "VAR_TWO" /\ LiteralValue "two" ]

predefinedVariables :: Map String String
predefinedVariables = singleton "VAR_TWO" "2" # insert "VAR_THREE" "3"

handleChildProcess :: forall m. Monad m => ChildProcessF ~> m
handleChildProcess (Spawn _ _ callback) = pure $ callback mempty

handleEnvironment
  :: forall r. EnvironmentF ~> Run (WRITER (Array (String /\ String)) r)
handleEnvironment =
  case _ of
    LookupEnv name callback ->
      pure $ callback (lookup name predefinedVariables)
    SetEnv name value next -> do
      tell [ name /\ value ]
      pure next

applied :: Array (String /\ String)
applied =
  fst $ extract $ runWriter
    $ interpret
        ( case_ # on _childProcess handleChildProcess # on _environment
            handleEnvironment
        )
    $ apply settings

tests :: Spec Unit
tests = describe "apply" do

  it "should apply settings where the environment variable is not already set" $
    F.lookup "VAR_ONE" applied `shouldEqual` Just "one"

  it "should not apply settings where the environment variable is already set" $
    (fst <$> applied) `shouldNotContain` "VAR_TWO"