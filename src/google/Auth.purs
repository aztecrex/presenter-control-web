module Google.Auth (
    IdentityToken,
    identityToken
) where

import Prelude (class Eq, class Show, Unit, const, eq, map, show)
import Data.Maybe (Maybe(..))
import Data.Either (either)
import AWS.Types (AWS)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Control.Monad.Aff (Aff, attempt, makeAff)

foreign import data IdentityToken :: Type

foreign import _identityToken :: forall eff. (Error -> Eff eff Unit) -> (IdentityToken -> Eff eff Unit) -> Eff eff Unit
foreign import _showIdentityToken :: IdentityToken -> String

instance showIdentityToken :: Show IdentityToken where
    show = _showIdentityToken
instance eqIdentityToken :: Eq IdentityToken where
    eq a b = eq (show a) (show b)


identityToken :: forall eff. Aff (aws :: AWS | eff) (Maybe IdentityToken)
identityToken = map (either (const Nothing) Just) (attempt (makeAff _identityToken))

