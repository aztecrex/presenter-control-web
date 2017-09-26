module UI.Control (
  reduce
) where

import Prelude ((#), (<<<))
import Data.Maybe (Maybe(..))
import Model.State (State, page, url, presentationInput, presentations, maybeUser, maybeDevice, User(..))
import UI.Event (Event (..))
import Data.Lens

reduce :: Event -> State -> State
reduce Logout s = s # maybeUser .~ Nothing
reduce (Login name email token) s = s # maybeUser .~ (Just (User name email token))
reduce Next s = s # page +~ 1
reduce Previous s = s # page -~ 1
reduce Restart s = s # page .~ 1
reduce (Location loc) s = s # url .~ loc
reduce (PresentationInputChange value) s = s # presentationInput .~ value
reduce AddPresentation s = (clearInput <<< appendLocation) s
  where clearInput s = s # presentationInput .~ ""
        appendLocation s = s # presentations <>~ [s ^. presentationInput ]
reduce (Presentations ps) s = s # presentations .~ ps
reduce (NewDevice device) s = s # maybeDevice .~ Just device
reduce _ s = s
