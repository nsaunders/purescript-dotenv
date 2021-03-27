module Test.Apply (tests) where

import Prelude
import Data.Foldable (find)
import Data.Map (Map, insert, lookup, singleton)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..), fst, snd)
import Dotenv.Internal.Apply (applySettings)
import Dotenv.Internal.Environment (EnvironmentF(..), _environment)
import Dotenv.Internal.Types (ResolvedValue, Setting)
import Run (Run, case_, extract, interpret, on)
import Run.Writer (WRITER, runWriter, tell)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual, shouldNotContain)

settings :: Array (Setting ResolvedValue)
settings = [ Tuple "VAR_ONE" $ Just "one", Tuple "VAR_TWO" $ Just "two" ]

predefinedVariables :: Map String String
predefinedVariables = singleton "VAR_TWO" "2" # insert "VAR_THREE" "3"

handleEnvironment :: forall r. EnvironmentF ~> Run (WRITER (Array (Tuple String String)) r)
handleEnvironment =
  case _ of
    LookupEnv name callback ->
      pure $ callback (lookup name predefinedVariables)
    SetEnv name value next -> do
      tell [Tuple name value]
      pure next

applySettingsResult :: Tuple (Array (Tuple String String)) (Array (Setting ResolvedValue))
applySettingsResult =
  extract $ runWriter $ interpret (case_ # on _environment handleEnvironment) $ applySettings settings

appliedSettings :: Array (Tuple String String)
appliedSettings = fst applySettingsResult

returnedSettings :: Array (Setting ResolvedValue)
returnedSettings = snd applySettingsResult

tests :: Spec Unit
tests = describe "applySettings" do

  it "should apply settings where the environment variable is not already defined" $
    (snd <$> find (eq "VAR_ONE" <<< fst) appliedSettings) `shouldEqual` Just "one"
 
  it "should not apply settings where the environment variable is already defined" $
    (fst <$> appliedSettings) `shouldNotContain` "VAR_TWO"

  it "should return the specified settings with the values defined in the environment as a result" $
    returnedSettings `shouldEqual` [Tuple "VAR_ONE" $ Just "one", Tuple "VAR_TWO" $ Just "2"]
