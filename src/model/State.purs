module Model.State
(
  State,
  newState,
  page,
  url
)
where

import Prelude (class Eq, class Show, map, show, (<<<), (<>), (==), (&&))
import Data.Maybe (Maybe(..), maybe)
import Data.Profunctor.Choice (class Choice)
import Data.Profunctor.Strong (class Strong)
import Data.Newtype (class Newtype, unwrap)
import Data.Symbol (SProxy(..))
import Data.Lens (Iso', Lens', _Just, iso)
import Data.Lens.Record (prop)

type StateR = {
  _page :: Int,
  _url :: String,
  _presentations :: Array String
}
newtype State = State StateR

derive instance newtypeState :: Newtype State _

_record :: Iso' State StateR
_record = iso unwrap State

rEq :: StateR -> StateR -> Boolean
rEq a b = a._page == b._page && a._url == b._url && a._presentations == b._presentations

instance eqState :: Eq State where
  eq (State a) (State b) = rEq a b

rShow :: StateR -> String
rShow rec = "{"
    <> "page: " <> show rec._page <> ","
    <> "url: " <> show rec._url <> ","
    <> "presentations: " <> show rec._presentations
    <> "}"

instance showState :: Show State where
  show (State rec) = rShow rec

_page :: forall r. Lens' { _page :: Int | r } Int
_page = prop (SProxy :: SProxy "_page")

page :: Lens' State Int
page = _record <<< _page

_url :: forall r. Lens' { _url :: String | r } String
_url = prop (SProxy :: SProxy "_url")

url :: Lens' State String
url = _record <<< _url


newState :: State
newState = State
  {
    _page: 1,
    _url: "http://the.initial.one/yeah.md",
    _presentations: [
      "http://the.initial.one/yeah.md",
      "http://the.other.one/letsgo.md"
    ]
  }
