module AWS.Types (AWS, Credentials) where

import Prelude (class Show)
import Control.Monad.Eff(kind Effect)

foreign import data AWS :: Effect

foreign import data Credentials :: Type

foreign import _showCredentials :: Credentials -> String

instance showCredentials :: Show Credentials where
  show = _showCredentials



