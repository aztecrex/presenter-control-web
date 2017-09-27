module AWS.IoT (createDevice, Device, updateDevice) where

import Prelude (Unit, bind, ($))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Aff (Aff)
import AWS.Types (AWS, Credentials)
import AWS (credentials)


foreign import data Device :: Type

foreign import  _create :: forall eff. Credentials -> Eff eff Device

createDevice :: forall eff. Aff (aws :: AWS | eff ) Device
createDevice = do
  creds <- credentials
  liftEff $ _create creds

foreign import _update :: forall eff. Device -> String -> Int -> Eff eff Unit

updateDevice :: forall eff.
    Device
    -> String
    -> Int
    -> Eff (aws :: AWS | eff) Unit
updateDevice = _update
