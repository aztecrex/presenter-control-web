module Main where

import Prelude (Unit, bind, discard, ($), pure, void, unit)
import Data.Maybe (Maybe(..))
import Data.Either(Either(..))
import Data.Lens ((^.))
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
import Model.State (State, newState, url, page)
import Signal.Channel (CHANNEL)
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

effects :: forall eff. Device -> State -> Array (Aff (aws :: AWS, exception :: EXCEPTION | eff) (Maybe Event))
effects device s = [update device (s ^. url) (s ^. page)]

makeFoldP :: forall eff. Device -> Event -> State -> EffModel State Event (aws :: AWS, exception :: EXCEPTION | eff)
makeFoldP device ev s = { state: s', effects: effects device s' }
  where s' = reduce ev s

main :: Eff (CoreEffects AppEffects) Unit
main = do
  void $ launchAff $ do
    device <- createDevice
    eitherApp <- liftEff' $ start
      { initialState
        , view
        , foldp: makeFoldP device
        , inputs: []
      }
    case eitherApp of
      Left _ -> pure $ Right unit
      Right app -> liftEff' $ renderToDOM "#app" app.markup app.input

