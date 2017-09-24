module AWS.IoT where

import Prelude (Unit, bind, discard, pure, void, ($))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Aff (Aff, launchAff)
import Signal (Signal, runSignal, (~>))
import Signal.Channel (CHANNEL, channel, send, subscribe)
import AWS.Types (AWS, Credentials)
import AWS (credentials)

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

