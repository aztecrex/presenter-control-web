module Main where

import Prelude (Unit, bind, ($), pure, discard, show, (<>), void, map)
import Data.Maybe (Maybe(..))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Aff (Aff, launchAff)
import Pux (CoreEffects, EffModel, start)
import Pux.Renderer.React (renderToDOM)
import Network.HTTP.Affjax (AJAX)
import UI.View (view)
import UI.Event (Event(..))
import UI.Control (reduce)
import Model.State (State, newState)
import Signal.Channel (CHANNEL)
import Signal ((~>), runSignal, constant)
import AWS.Types
import AWS
import AWS.IoT


initialState :: State
initialState = newState

type AppEffects = (console :: CONSOLE, aws :: AWS, channel :: CHANNEL)

foldp :: Event -> State -> EffModel State Event AppEffects
foldp ev s = { state: reduce ev s, effects: [] }

main :: Eff (CoreEffects AppEffects) Unit
main = do
  app <- start
    { initialState
    , view
    , foldp
    , inputs: [ ]
    }
  renderToDOM "#app" app.markup app.input

