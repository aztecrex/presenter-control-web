module AWS (anonymous, credentials) where

import Prelude
import Control.Monad.Eff(Eff, kind Effect)
import Control.Monad.Eff.Exception (Error)
import Control.Monad.Aff (makeAff, Aff)
import AWS.Types (AWS, Credentials)


foreign import _anonymous :: forall eff. Eff (aws :: AWS | eff) Unit

anonymous :: forall eff. Aff (aws :: AWS | eff) Unit
anonymous = makeAff (\_ _ -> _anonymous)

foreign import _identity :: forall eff. (Error -> Eff (aws :: AWS | eff) Unit) -> (String -> Eff (aws :: AWS | eff) Unit) -> Eff (aws :: AWS | eff) Unit

identity :: forall eff. Aff (aws :: AWS | eff) String
identity = makeAff _identity

foreign import _credentials :: forall eff. String -> (Error -> Eff (aws :: AWS | eff) Unit) -> (Credentials -> Eff (aws :: AWS | eff) Unit) -> Eff (aws :: AWS | eff) Unit

identityCredentials :: forall eff. String -> Aff (aws :: AWS | eff) Credentials
identityCredentials cid = makeAff $ _credentials cid

credentials :: forall eff. Aff (aws :: AWS | eff) Credentials
credentials = do
    currentIdentity <- identity
    identityCredentials currentIdentity

