module Main where

import Prelude (Unit, bind, discard, ($), pure, void, unit, (#))
import Data.Maybe (Maybe(..), maybe)
import Data.Lens ((^.), (.~))
import Data.String (split, Pattern(..), trim)
import Data.Foldable (intercalate)
import Signal (constant)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Aff (Aff, launchAff)
import Pux (CoreEffects, EffModel, start)
import Pux.Renderer.React (renderToDOM)
import UI.View (view)
import UI.Event (Event(..))
import UI.Control (reduce)
import Model.State (State, newState, url, page, presentations, maybeUser, User(..))
import AWS (authorizeGoogleUser, fetch, save)
import AWS.Types (AWS)
import AWS.IoT (createDevice, Device, updateDevice)
import Google.Auth (identityToken, logout)

initialState :: State
initialState = newState

update :: forall eff. Device -> String -> Int -> Aff (aws :: AWS, exception :: EXCEPTION | eff) (Maybe Event)
update dev url page = do
  liftEff $ updateDevice dev url page
  pure Nothing

stEffects :: forall eff. Device -> State -> Array (Aff (aws :: AWS, exception :: EXCEPTION | eff) (Maybe Event))
stEffects device s = [update device (s ^. url) (s ^. page)]

requestPresentations :: forall eff. Aff (aws :: AWS, exception :: EXCEPTION | eff) (Maybe Event)
requestPresentations = do
  presentations <- fetch "presentations.txt"
  pure $ Just $ Presentations $ split (Pattern "\n") (trim presentations)

savePresentations :: forall eff. (Array String) -> Aff (aws :: AWS | eff) (Maybe Event)
savePresentations items = do
  save "presentations.txt" $ intercalate "\n" items
  pure Nothing

effectLogout :: forall eff. Aff (aws :: AWS | eff) (Maybe Event)
effectLogout = do
  liftEff logout
  pure Nothing


makeFoldP :: forall eff. Device -> Event -> State -> EffModel State Event (aws :: AWS, exception :: EXCEPTION | eff)
makeFoldP _ FetchPresentationsRequest s = {state: reduce FetchPresentationsRequest s, effects: [requestPresentations]}
makeFoldP _ Logout s = { state: reduce Logout s, effects: [effectLogout]}
makeFoldP _ AddPresentation s = {state: s', effects: [savePresentations (s' ^. presentations)]}
  where s' = reduce AddPresentation s
makeFoldP device Next s = { state: s', effects: stEffects device s' }
  where s' = reduce Next s
makeFoldP device Previous s = { state: s', effects: stEffects device s' }
  where s' = reduce Previous s
makeFoldP device Restart s = { state: s', effects: stEffects device s' }
  where s' = reduce Restart s
makeFoldP device ev@(Location _) s = { state: s', effects: stEffects device s' }
  where s' = reduce ev s
makeFoldP _ ev s = foldp ev s

foldp :: forall eff. Event -> State -> EffModel State Event (aws :: AWS, exception :: EXCEPTION | eff)
foldp ev s = {state: reduce ev s, effects: [] }



main :: Eff (CoreEffects (aws :: AWS, exception :: EXCEPTION, exception :: EXCEPTION)) Unit
main = do
    void $ launchAff $ do
      maybeAuthorized <- identityToken
      config <- maybe unauthorizedConfig authorizedConfig maybeAuthorized
      app <- liftEff $ start config
      liftEff $ renderToDOM "#app" app.markup app.input
  where
    unauthorizedConfig =
        pure { initialState
            , view
            , foldp: foldp
            , inputs: []
          }

    authorizedConfig token = do
      void $ authorizeGoogleUser token
      device <- createDevice
      pure
        { initialState: initialState # maybeUser .~ Just (User unit)
          , view
          , foldp: makeFoldP device
          , inputs: [constant FetchPresentationsRequest]
        }

