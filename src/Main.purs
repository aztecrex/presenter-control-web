module Main where

import Prelude (Unit, bind, discard, ($), pure, void, unit, show, map, (#))
import Data.Maybe (Maybe(..), maybe)
import Data.Either(Either(..), either)
import Data.Lens ((^.), (.~))
import Data.String (split, Pattern(..), trim)
import Data.Foldable (intercalate)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Aff (Aff, launchAff, liftEff')
import Control.Monad.Eff.Console (CONSOLE, log)
import Pux (CoreEffects, EffModel, start)
import Pux.Renderer.React (renderToDOM)
import UI.View (view)
import UI.Event (Event(..))
import UI.Control (reduce)
import Model.State (State, newState, url, page, presentations, maybeUser, User(..))
import Signal.Channel (CHANNEL)
import Signal (constant, (~>), runSignal)
import AWS
import AWS.Types (AWS)
import AWS.IoT (createDevice, Device, updateDevice)
import Google.Auth

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


makeFoldP :: forall eff. Device -> Event -> State -> EffModel State Event (aws :: AWS, exception :: EXCEPTION | eff)
makeFoldP _ FetchPresentationsRequest s = {state: reduce FetchPresentationsRequest s, effects: [requestPresentations]}
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

foldp ev s = {state: reduce ev s, effects: [] }

unauthorizedConfig =
    pure { initialState
        , view
        , foldp: foldp
        , inputs: []
      }

authorizedConfig token = do
  liftEff $ authorizeGoogleUser token
  device <- createDevice
  pure
    { initialState: initialState # maybeUser .~ Just (User unit)
      , view
      , foldp: makeFoldP device
      , inputs: [constant FetchPresentationsRequest]
    }


main :: Eff (CoreEffects (aws :: AWS, exception :: EXCEPTION, exception :: EXCEPTION)) Unit
main = do
  void $ launchAff $ do
    maybeAuthorized <- identityToken
    config <- maybe unauthorizedConfig authorizedConfig maybeAuthorized
    app <- liftEff $ start config
    liftEff $ renderToDOM "#app" app.markup app.input

