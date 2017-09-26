module Google.Auth (
    authUpdates,
    AuthUpdate(..),
    attachLogin
) where

import Prelude
import AWS.Types
import Data.Generic
import Control.Monad.Eff
import Control.Monad.Eff.Class
import Control.Monad.Aff
import Control.Monad.Eff.Exception
import Signal.Channel
import Signal

foreign import data ForeignUpdate :: Type
foreign import _updates :: forall eff.
    (ForeignUpdate -> Eff eff Unit)
     -> Eff eff Unit

data AuthUpdate = Signout | Signin String String String

derive instance genericAuthUpdate :: Generic AuthUpdate
derive instance eqAuthUpdate :: Eq AuthUpdate
instance showAuthUpdate :: Show AuthUpdate where
    show Signout = "Signout"
    show (Signin name email token) = "Signin" <> name <> " " <> email <> " " <> token

foreign import _updName :: ForeignUpdate -> String
foreign import _updEmail :: ForeignUpdate -> String
foreign import _updToken :: ForeignUpdate -> String
foreign import _updAuthorized :: ForeignUpdate -> Boolean

fromForeign :: ForeignUpdate -> AuthUpdate
fromForeign fu = if _updAuthorized fu
    then Signin (_updName fu) (_updEmail fu) (_updToken fu)
    else Signout

fromUpdates :: forall eff.
    (AuthUpdate -> Eff (aws :: AWS | eff) Unit)
    -> Eff (aws :: AWS | eff) Unit
fromUpdates handle = _updates  (\fu -> handle (fromForeign fu))


authUpdates :: forall eff.
    Eff
        ( channel :: CHANNEL, aws :: AWS, exception :: EXCEPTION
        | eff
        )
        (Signal AuthUpdate)
authUpdates = do
    ch <- channel Signout
    let sink = send ch
    void $ launchAff $ do
        liftEff $ fromUpdates sink
    pure $ subscribe ch


foreign import _attachLogin :: forall eff. String -> Eff eff Unit

attachLogin :: forall eff. String -> Eff (aws :: AWS | eff) Unit
attachLogin = _attachLogin
