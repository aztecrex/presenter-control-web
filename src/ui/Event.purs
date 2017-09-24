module UI.Event (Event(..)) where

import Prelude (class Eq)
import Data.Show (class Show)
import Data.Generic (class Generic, gShow, gEq)

data Event =  Next
            | Previous
            | Restart
            | Content String
            | RequestContent
            | Noop
            | Log String


derive instance genericEvent :: Generic Event

instance showEvent :: Show Event where
  show = gShow

instance eqEvent :: Eq Event where
  eq = gEq
