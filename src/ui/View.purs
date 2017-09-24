module UI.View (view) where

import Prelude (const, discard, show, ($), (<>))
import Data.Maybe (maybe)
import Text.Smolder.Markup (text, (#!))
import Text.Smolder.HTML (div, p, button, br)
import Pux.DOM.Events (onClick)
import Pux.DOM.HTML (HTML)
import Model.State (State)
import UI.Event(Event(..))


view :: State -> HTML Event
view pres = do
    button #! onClick (const Previous) $ text "Previous"
    button #! onClick (const Next) $ text "Next"
    button #! onClick (const Restart) $ text "Restart"
