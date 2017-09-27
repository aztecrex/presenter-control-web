module UI.View (view) where

import Prelude (const, discard, ($))
import Data.Maybe (isJust)
import Text.Smolder.Markup (text, (#!), (!))
import Text.Smolder.HTML.Attributes (className, href, style, value)
import Data.Foldable (for_)
import Data.Lens ((^.))
import Text.Smolder.HTML (div, p, button, br, h2, input, a)
import Pux.DOM.Events (onClick, onChange, targetValue)
import Pux.DOM.HTML (HTML)
import Model.State (State, maybeUser, presentationInput, presentations)
import UI.Event(Event(..))

pbutton :: String -> HTML Event
pbutton url = do
    button ! className "btn" #! onClick (const (Location url)) $ text url
    br

authorizedView :: State -> HTML Event
authorizedView state = do
    div $ do
        div $ do
            h2 $ text "Slide"
            button ! className "btn-lg" #! onClick (const Previous) $ text "Previous"
            button ! className "btn-lg" #! onClick (const Next) $ text "Next"
            button ! className "btn-lg" #! onClick (const Restart) $ text "Restart"
        div ! style "padding-top: 2em;" $ do
            h2 $ text "Presentations"
            for_ (state ^. presentations) pbutton
        div ! style "padding-top: 2em;" $ do
            input ! style "width: 65%;"
                ! value (state ^. presentationInput)
                #! onChange (\ev -> (PresentationInputChange (targetValue ev)))
            button #! onClick (const AddPresentation) $ text "Add"

unauthorizedView :: State -> HTML Event
unauthorizedView state = do
    div $ do
        p $ do
            text $ "Login to start."

authControl :: Boolean -> HTML Event
authControl true = button #! onClick (const Logout) $ text "Logout"
authControl false = a ! href "login.html" $ text "Login"

view :: State -> HTML Event
view state = do
    let authorized = isJust (state ^. maybeUser)
    div ! className "navbar navbar-inverse" $ do
      div ! className "container" $ do
        a ! className "navbar-brand" ! href "/" $ text "Presentation"
        div ! className "navbar-brand" ! style "float: right;" $ authControl authorized
    div ! className "container" $ do
        if authorized
            then authorizedView state
            else unauthorizedView state
