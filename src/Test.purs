module Test.Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Aff.AVar (AVAR)
import Test.Unit.Console (TESTOUTPUT)
import Model.State.Test as State
import Model.Presentation.Test as Presentation
import Content.Slide.Test as Slide
import Content.Render.Test as Render
import Provision.Runtime.Test as Runtime
import UI.View.Test as View
import UI.Control.Test as Control

main :: ∀ fx. Eff ( console :: CONSOLE
                  , testOutput :: TESTOUTPUT
                  , avar :: AVAR
                  | fx
          ) Unit
main = do
  State.tests
  Presentation.tests
  Slide.tests
  Render.tests
  View.tests
  Control.tests
  Runtime.tests
