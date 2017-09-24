module AWS.IoT where

import Prelude
import Control.Monad.Eff
import Control.Monad.Eff.Exception
import Control.Monad.Eff.Class
import Control.Monad.Eff.Console
import Control.Monad.Aff
import Signal
import Signal.Channel
import Signal.Time
import AWS.Types (AWS, Credentials)
import AWS

-- foreign import data Update :: Type
foreign import _update :: forall eff.
    Credentials
    -> (String -> Eff (aws :: AWS | eff) Unit)
    -> Eff (aws :: AWS | eff) Unit

updates :: forall eff.
    (String -> Eff (channel :: CHANNEL, aws :: AWS | eff) Unit)
    -> Aff
        ( channel :: CHANNEL, aws :: AWS
        | eff
        )
        Unit
updates dest = do
    creds <- credentials
    ch <- liftEff $ channel "init"
    let sink = send ch
    liftEff $ _update creds sink
    liftEff $ runSignal $ subscribe ch ~> dest
    -- pure unit

chupdates :: forall eff.
    Eff
        ( channel :: CHANNEL, aws :: AWS, exception :: EXCEPTION
        | eff
        )
        (Signal String)
chupdates = do
    ch <- channel "init"
    let sink = send ch
    void $ launchAff $ do
        creds <- credentials
        liftEff $ _update creds sink
    pure $ subscribe ch


foreign import times2 :: forall eff.  (String -> Eff eff Unit) -> Eff eff Unit
updates2 :: forall eff.
      Eff
        ( channel :: CHANNEL, aws :: AWS
        | eff
        )
        (Signal String)
updates2 = do
    ch <- channel "one"
    let sink = send ch :: forall e. String -> Eff (channel :: CHANNEL | e) Unit
    times2 sink
    pure $ subscribe ch

