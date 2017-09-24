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
import Content.Interop (getSource)
import UI.View (view)
import UI.Event (Event(..))
import UI.Control (reduce)
import Model.State (State, newState)
import Signal.Channel (CHANNEL)
import Signal ((~>), runSignal, constant)
import AWS.Types
import AWS
import AWS.IoT


logCredentials :: forall eff. Aff (aws :: AWS, console :: CONSOLE | eff) (Maybe Event)
logCredentials = do
  liftEff $ log "about to get credentials"
  creds <- credentials
  liftEff $ log $ "credentials: " <> show creds
  pure Nothing

logMessage :: forall eff. String -> Aff (aws :: AWS, console :: CONSOLE | eff) (Maybe Event)
logMessage message = do
  liftEff $ log $ "LOG: " <> message
  pure Nothing

initialState :: State
initialState = newState

type AppEffects = (console :: CONSOLE, ajax :: AJAX, aws :: AWS, channel :: CHANNEL)

foldp :: Event -> State -> EffModel State Event AppEffects
foldp RequestContent s = { state: reduce RequestContent s,
  effects: [do
    liftEff $ log "content requested!!!"
    src <- getSource
    pure $ Just $ Content src
  ] }
foldp (Log msg) s = {state: s, effects: [logMessage msg]}
foldp ev s = { state: reduce ev s, effects: [logCredentials] }

main :: Eff (CoreEffects AppEffects) Unit
main = do
  upds <- chupdates
  -- runSignal $ upd ~> log
  -- void $ launchAff $ updates log
  app <- start
    { initialState
    , view
    , foldp
    , inputs: [ constant RequestContent, map Log upds ]
    }
  renderToDOM "#app" app.markup app.input


slideSource :: String
slideSource = """
# Slide One

On this slide we have lots of coolness.

---
# Slide Two

## Let me tell you

This is weird.

## Let me tell you something else

_Really_ weird.

---
# Final Slide

Wasn't that just the greatest presentation?

"""
