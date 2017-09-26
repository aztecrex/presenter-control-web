module Main where

import Prelude (Unit, bind, discard, ($), pure, void, unit, show, map)
import Data.Maybe (Maybe(..))
import Data.Either(Either(..))
import Data.Lens ((^.))
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
import Model.State (State, newState, url, page, presentations, maybeDevice)
import Signal.Channel (CHANNEL)
import Signal (constant, (~>), runSignal)
import AWS(fetch, save, awsLogin)
import AWS.Types (AWS)
import AWS.IoT (createDevice, Device, updateDevice)
import Google.Auth(authUpdates, AuthUpdate(..))

initialState :: State
initialState = newState

type AppEffects = (exception :: EXCEPTION, console :: CONSOLE, aws :: AWS, channel :: CHANNEL)

-- device :: forall eff. Aff (aws :: AWS | eff) Device
-- device = createDevice

update :: forall eff. Device -> String -> Int -> Aff (aws :: AWS, exception :: EXCEPTION | eff) (Maybe Event)
update dev url page = do
  liftEff $ updateDevice dev url page
  pure Nothing

stEffects :: forall eff. Maybe Device -> State -> Array (Aff (aws :: AWS, exception :: EXCEPTION | eff) (Maybe Event))
stEffects (Just device) s = [update device (s ^. url) (s ^. page)]
stEffects _ _ = []

requestPresentations :: forall eff. Aff (aws :: AWS, exception :: EXCEPTION | eff) (Maybe Event)
requestPresentations = do
  presentations <- fetch "presentations.txt"
  pure $ Just $ Presentations $ split (Pattern "\n") (trim presentations)

savePresentations :: forall eff. (Array String) -> Aff (aws :: AWS | eff) (Maybe Event)
savePresentations items = do
  save "presentations.txt" $ intercalate "\n" items
  pure Nothing

obtainDevice :: forall eff. String -> Aff (aws :: AWS | eff) (Maybe Event)
obtainDevice token = do
  liftEff $ awsLogin token
  dev <- createDevice
  pure $ Just $ NewDevice dev

foldp :: forall eff. Event -> State -> EffModel State Event (aws :: AWS, exception :: EXCEPTION | eff)
foldp FetchPresentationsRequest s = {state: reduce FetchPresentationsRequest s, effects: [requestPresentations]}
foldp AddPresentation s = {state: s', effects: [savePresentations (s' ^. presentations)]}
  where s' = reduce AddPresentation s
foldp Next s = { state: s', effects: stEffects (s' ^. maybeDevice) s' }
  where s' = reduce Next s
foldp Previous s = { state: s', effects: stEffects (s' ^. maybeDevice) s' }
  where s' = reduce Previous s
foldp Restart s = { state: s', effects: stEffects (s' ^. maybeDevice) s' }
  where s' = reduce Restart s
foldp ev@(Location _) s = { state: s', effects: stEffects (s' ^. maybeDevice) s' }
  where s' = reduce ev s
foldp ev@(Login _ _ token) s = {state: s', effects: [obtainDevice token]}
  where s' = reduce ev s
foldp ev s = { state: reduce ev s, effects: [] }

authEvent :: AuthUpdate -> Event
authEvent Signout = Logout
authEvent (Signin name email token) = Login name email token

main :: Eff (CoreEffects AppEffects) Unit
main = do
  auths <- authUpdates
  let authEvents = map authEvent auths
  -- runSignal $ (map show authEvents) ~> log
  void $ launchAff $ do
    eitherApp <- liftEff' $ start
      { initialState
        , view
        , foldp: foldp
        , inputs: [authEvents]
      }
    case eitherApp of
      Left _ -> pure $ Right unit
      Right app -> liftEff' $ renderToDOM "#app" app.markup app.input

