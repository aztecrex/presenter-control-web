module UI.View (view) where

import Prelude (const, discard, show, ($), (<>))
import Data.Maybe (maybe, isJust)
import Data.Monoid (mempty)
import Text.Smolder.Markup (text, (#!), (!))
import Text.Smolder.HTML.Attributes (id, className, style, value, href)
import Data.Foldable (for_)
import Data.Lens ((^.))
import Text.Smolder.HTML (div, p, button, br, h2, input, a)
import Pux.DOM.Events (onClick, onChange, targetValue)
import Pux.DOM.HTML (HTML)
import Model.State (State, presentations, presentationInput, maybeUser, User(..))
import UI.Event(Event(..))
import Google.Auth (attachLogin)

pbutton :: String -> HTML Event
pbutton url = do
    button ! className "btn" #! onClick (const (Location url)) $ text url
    br

authorizedView :: State -> HTML Event
authorizedView state = do
    div $ do
        div $ do
            div ! id "login" $ text $ maybe "" (\(User n _ _)  -> n) (state ^. maybeUser)
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
            text $ "Not authorized. "
            a ! href "login.html" $ text "Login here"
            text "."

view :: State -> HTML Event
view state = if isJust ( state ^. maybeUser )
    then authorizedView state
    else unauthorizedView state
