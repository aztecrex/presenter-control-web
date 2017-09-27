module Test.Main where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Lens
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Aff.AVar (AVAR)
import Test.Unit.Console (TESTOUTPUT)
import Model.State
import UI.Event
import UI.Control
import Test.Unit.Assert (assert, equal)
import Test.Unit.Main (runTest)
import Test.Unit (suite, test)


main :: ∀ fx. Eff ( console :: CONSOLE
                  , testOutput :: TESTOUTPUT
                  , avar :: AVAR
                  | fx
          ) Unit
main = log "it is well with my soul"
  -- runTest do
  --   suite "UI.Control" do
  --     test "updates user" do
  --       let state = newState
  --       let nextState = reduce  (Login "a" "b" "c") state
  --       equal (Just (User "a" "b" "c")) (nextState ^. maybeUser)
