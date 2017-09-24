module Model.State.Test (tests) where

import Prelude (Unit, discard, (#), ($), (/=), (==), (<<<))
import Data.Either (fromRight)
import Data.Maybe (Maybe(..))
import Partial.Unsafe (unsafePartial)
import Data.Lens ((.~), (^.), (+~))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Aff.AVar (AVAR)
import Test.Unit (suite, test)
import Test.Unit.Main (runTest)
import Test.Unit.Assert (assert, equal)
import Test.Unit.Console (TESTOUTPUT)
import Model.Presentation (create, number, Presentation)

import Model.State (newState, presentation, _presentation)

tests :: ∀ fx. Eff ( console :: CONSOLE
                  , testOutput :: TESTOUTPUT
                  , avar :: AVAR
                  | fx
          ) Unit
tests = do
  runTest do
    suite "Model.State" do
      test "no initial presentation" do
        equal Nothing $ newState ^. presentation
      test "presentation" do
        let app = newState # presentation .~ Just testPres
        let actual = app ^. presentation
        equal (Just testPres) actual
      test "presentation just" do
        let app = newState # presentation .~ Just testPres
        let update = app # _presentation <<< number +~ 1
        let expected = testPres # number +~ 1
        equal (Just expected) $ update ^. presentation
      test "equality" do
        let a = newState # presentation .~ Just (makePres "# Slide")
        let b = newState # presentation .~ Just (makePres "# Slide")
        let other = newState # presentation .~ Just (makePres "not a slide")
        assert "equal" $ a == b
        assert "commute" $ b == a
        assert "symmetry" $ a == a
        assert "not equal" $ a /= newState
        assert "not equal" $ a /= other


makePres :: String -> Presentation
makePres src = unsafePartial $ fromRight $ create src

testPres :: Presentation
testPres = makePres testSource

testSource :: String
testSource = """
# Slide One

On this slide we have lots of coolness.

---
# Slide Two

## Let me tell you

This is weird.

## Let me tell you something else

_Really_ weird.

---
# Final Slide

Wasn't that just the greatest presentation?

"""
