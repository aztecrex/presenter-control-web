module Model.State
(
  State,
  presentation,
  _presentation,
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
import Data.Lens.Record (prop)
import Model.Presentation (Presentation)

type StateR = {
  _maybePresentation :: Maybe Presentation
}
newtype State = State StateR

derive instance newtypeState :: Newtype State _

rEq :: StateR -> StateR -> Boolean
rEq a b = a._maybePresentation == b._maybePresentation

instance eqState :: Eq State where
  eq (State a) (State b) = rEq a b

rShow :: StateR -> String
rShow rec = "{" <> maybe "" prop rec._maybePresentation<> "}"
  where prop = map ("presentation: " <> _) show

instance showState :: Show State where
  show (State rec) = rShow rec

_record :: Iso' State StateR
_record = iso unwrap State

_pres :: forall r. Lens' { _maybePresentation :: Maybe Presentation | r } (Maybe Presentation)
_pres = prop (SProxy :: SProxy "_maybePresentation")

presentation :: Lens' State (Maybe Presentation)
presentation = _record <<< _pres

_presentation :: forall p. Strong p => Choice p => p Presentation Presentation -> p State State
_presentation = presentation <<< _Just

newState :: State
newState = State { _maybePresentation: Nothing }

