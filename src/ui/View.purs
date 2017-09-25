module UI.View (view) where

import Prelude (const, discard, show, ($), (<>))
import Data.Maybe (maybe)
import Text.Smolder.Markup (text, (#!), (!))
import Text.Smolder.HTML.Attributes (className, style)
import Data.Foldable (for_)
import Data.Lens ((^.))
import Text.Smolder.HTML (div, p, button, br)
import Pux.DOM.Events (onClick)
import Pux.DOM.HTML (HTML)
import Model.State (State, presentations)
import UI.Event(Event(..))

pbutton :: String -> HTML Event
pbutton url = do
    button ! className "btn" #! onClick (const (Location url)) $ text url
    br

view :: State -> HTML Event
view state = do
    div $ do
        div $ do
            button ! className "btn-lg" #! onClick (const Previous) $ text "Previous"
            button ! className "btn-lg" #! onClick (const Next) $ text "Next"
            button ! className "btn-lg" #! onClick (const Restart) $ text "Restart"
        div ! style "padding-top: 2em;" $ do
            for_ (state ^. presentations) pbutton
