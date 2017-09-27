module Google.Auth (
    IdentityToken,
    identityToken
) where

import Prelude
import Data.Maybe
import Data.Either
import AWS.Types
import Google.Auth
import Control.Monad.Eff
import Control.Monad.Eff.Exception
import Control.Monad.Aff

foreign import data IdentityToken :: Type

foreign import _identityToken :: forall eff. (Error -> Eff eff Unit) -> (IdentityToken -> Eff eff Unit) -> Eff eff Unit
foreign import _showIdentityToken :: IdentityToken -> String

instance showIdentityToken :: Show IdentityToken where
    show = _showIdentityToken
instance eqIdentityToken :: Eq IdentityToken where
    eq a b = eq (show a) (show b)


identityToken :: forall eff. Aff (aws :: AWS | eff) (Maybe IdentityToken)
identityToken = map (either (const Nothing) Just) (attempt (makeAff _identityToken))

