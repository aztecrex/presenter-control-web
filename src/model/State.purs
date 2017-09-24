module Model.State
(
  State,
  newState
)
where

import Prelude (class Eq, class Show, map, show, (<<<), (<>), (==))
import Data.Maybe (Maybe(..), maybe)
import Data.Profunctor.Choice (class Choice)
import Data.Profunctor.Strong (class Strong)
import Data.Newtype (class Newtype, unwrap)
import Data.Symbol (SProxy(..))
import Data.Lens (Iso', Lens', _Just, iso)

type StateR = {
}
newtype State = State StateR

derive instance newtypeState :: Newtype State _

_record :: Iso' State StateR
_record = iso unwrap State

rEq :: StateR -> StateR -> Boolean
rEq _ _ = true

instance eqState :: Eq State where
  eq (State a) (State b) = rEq a b

rShow :: StateR -> String
rShow rec = "{}"

instance showState :: Show State where
  show (State rec) = rShow rec

newState :: State
newState = State {}

