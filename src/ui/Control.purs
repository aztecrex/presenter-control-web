module UI.Control (
  reduce
) where

import Prelude ((#))
import Model.State (State, page)
import UI.Event (Event (..))
import Data.Lens

reduce :: Event -> State -> State
reduce Next s = s # page +~ 1
reduce Previous s = s # page -~ 1
reduce Restart s = s # page .~ 1
reduce _ s = s
