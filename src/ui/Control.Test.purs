module UI.Control.Test (tests) where

import Prelude (Unit, discard, (#), ($), (<<<))
import Partial.Unsafe (unsafePartial)
import Data.Either (fromRight)
import Data.Maybe (Maybe(..))
import Data.Lens ((+~), (-~), (.~))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Aff.AVar (AVAR)
import Test.Unit (suite, test)
import Test.Unit.Console (TESTOUTPUT)
import Test.Unit.Main (runTest)
import Test.Unit.Assert (equal)
import UI.Event (Event(..))
import Model.Presentation (Presentation, create, number)
import Model.State (State, _presentation, newState, presentation)

import UI.Control (reduce)

tests :: ∀ fx. Eff ( console :: CONSOLE
                  , testOutput :: TESTOUTPUT
                  , avar :: AVAR
                  | fx
          ) Unit
tests = do
  runTest do
    suite "UI.Control" do
        test "change slides" do
          let event = Content testSource
          let initial = newState # presentation .~ Just (makePres "# was")
          let actual = reduce event initial
          let expected = newState # presentation .~ Just testPres
          equal expected actual
        test "install slides" do
          let event = Content testSource
          let initial = newState
          let actual = reduce event initial
          let expected = newState # presentation .~ Just testPres
          equal expected actual
        test "next" do
          let event = Next
          let initial = testState
          let actual = reduce event initial
          let expected = initial # _presentation <<< number +~ 1
          equal expected actual
        test "previous" do
          let event = Previous
          let initial = testState # _presentation <<< number .~ 3
          let actual = reduce event initial
          let expected = initial # _presentation <<< number -~ 1
          equal expected actual
        test "restart" do
          let event = Restart
          let initial = testState # _presentation <<< number .~ 3
          let actual = reduce event initial
          let expected = initial # _presentation <<< number .~ 1
          equal expected actual

testState :: State
testState = newState # presentation .~ Just testPres

makePres :: String -> Presentation
makePres src = unsafePartial $ fromRight $ create src

testPres :: Presentation
testPres = makePres testSource

testSource :: String
testSource = """# Slide 1
---
# Slide 2
---
# Slide 3
---
# Slide 4
---
# Slide 5
"""
