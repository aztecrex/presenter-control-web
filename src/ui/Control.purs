module UI.Control (
  reduce
) where

import Prelude ((#), (<<<))
import Data.Maybe(Maybe(..))
import Model.State (State, page, url, presentationInput, presentations, maybeUser)
import UI.Event (Event (..))
import Data.Lens

reduce :: Event -> State -> State
reduce Next s = s # page +~ 1
reduce Previous s = s # page -~ 1
reduce Restart s = s # page .~ 1
reduce (Location loc) s = s # url .~ loc # page .~ 1
reduce (PresentationInputChange value) s = s # presentationInput .~ value
reduce AddPresentation s = (clearInput <<< appendLocation) s
  where clearInput s' = s' # presentationInput .~ ""
        appendLocation s' = s' # presentations <>~ [s' ^. presentationInput ]
reduce (Presentations ps) s = s # presentations .~ ps
reduce Logout s = s # maybeUser .~ Nothing
reduce _ s = s
