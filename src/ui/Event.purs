module UI.Event (Event(..)) where

import Prelude (class Eq)
import Data.Show (class Show)
import Data.Generic (class Generic, gShow, gEq)
import AWS.IoT

data Event =  Next
            | Previous
            | Restart
            | Location String
            | AddPresentation
            | PresentationInputChange String
            | Noop
            | Log String
            | FetchPresentationsRequest
            | Presentations (Array String)
            | SavePresentationsRequest (Array String)

-- derive instance genericEvent :: Generic Event

-- instance showEvent :: Show Event where
--   show = gShow

-- instance eqEvent :: Eq Event where
--   eq = gEq
