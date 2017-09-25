module Main where

import Prelude (Unit, bind, discard, ($), pure, void, unit)
import Data.Maybe (Maybe(..))
import Data.Either(Either(..))
import Data.Lens ((^.))
import Data.String (split, Pattern(..), trim)
import Data.Foldable (intercalate)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Aff (Aff, launchAff, liftEff')
import Control.Monad.Eff.Console (CONSOLE)
import Pux (CoreEffects, EffModel, start)
import Pux.Renderer.React (renderToDOM)
import UI.View (view)
import UI.Event (Event(..))
import UI.Control (reduce)
import Model.State (State, newState, url, page, presentations)
import Signal.Channel (CHANNEL)
import Signal (constant)
import AWS(fetch, save)
import AWS.Types (AWS)
import AWS.IoT (createDevice, Device, updateDevice)

initialState :: State
initialState = newState

type AppEffects = (exception :: EXCEPTION, console :: CONSOLE, aws :: AWS, channel :: CHANNEL)

-- device :: forall eff. Aff (aws :: AWS | eff) Device
-- device = createDevice

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
makeFoldP device ev s = { state: reduce ev s, effects: [] }

main :: Eff (CoreEffects AppEffects) Unit
main = do
  void $ launchAff $ do
    device <- createDevice
    eitherApp <- liftEff' $ start
      { initialState
        , view
        , foldp: makeFoldP device
        , inputs: [constant FetchPresentationsRequest]
      }
    case eitherApp of
      Left _ -> pure $ Right unit
      Right app -> liftEff' $ renderToDOM "#app" app.markup app.input

