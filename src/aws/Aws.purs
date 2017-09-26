module AWS (anonymous, credentials, fetch, save, awsLogin) where

import Prelude
import Control.Monad.Eff(Eff, kind Effect)
import Control.Monad.Eff.Exception (Error)
import Control.Monad.Aff (makeAff, Aff)
import AWS.Types (AWS, Credentials)
import Google.Auth (IdentityToken)


foreign import _authorizeGoogleUser :: forall eff. IdentityToken -> Eff eff Unit
foreign import _credentials :: forall eff. (Error -> Eff eff Unit) -> (Credentials -> Eff eff Unit) -> Eff eff Unit

authorizeGoogleUser :: forall eff. IdentityToken -> Eff (aws :: AWS | eff) Unit
authorizeGoogleUser token = makeAff $ _authorizeGoogleUser token

credentials :: forall eff. Aff (aws :: AWS | eff) Credentials
credentials = makeAff _credentials

foreign import _fetch :: forall eff. String -> (Error -> Eff eff Unit) -> (String -> Eff eff Unit) -> Eff eff Unit
foreign import _save :: forall eff. String -> String ->  (Error -> Eff eff Unit) -> (Unit -> Eff eff Unit) -> Eff eff Unit

fetch :: forall eff. String -> Aff (aws :: AWS | eff) String
fetch name = makeAff $ _fetch name

save :: forall eff. String -> String -> Aff (aws :: AWS | eff) Unit
save name content = makeAff $ _save name content
