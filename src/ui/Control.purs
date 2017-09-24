module UI.Control (
  reduce
) where

import Prelude (id)
import Model.State (State)
import UI.Event (Event)

reduce :: Event -> State -> State
reduce _  = id
