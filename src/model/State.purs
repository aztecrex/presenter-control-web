module Model.State
(
  State,
  newState,
  page,
  url,
  presentations,
  presentationInput,
  maybeUser,
  User(..)
)
where

import Prelude (class Eq, class Show, Unit, show, (&&), (<<<), (<>), (==))
import Data.Maybe (Maybe(..))
import Data.Generic
import Data.Newtype (class Newtype, unwrap)
import Data.Symbol (SProxy(..))
import Data.Lens (Iso', Lens', iso)
import Data.Lens.Record (prop)

data User = User Unit

derive instance genericUser :: Generic User

derive instance eqUser :: Eq User

instance showUser :: Show User where
  show = gShow

type StateR = {
  _page :: Int,
  _url :: String,
  _presentations :: Array String,
  _presentationInput :: String,
  _maybeUser :: Maybe User
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

_presentations :: forall r. Lens' { _presentations :: (Array String) | r } (Array String)
_presentations = prop (SProxy :: SProxy "_presentations")

presentations :: Lens' State (Array String)
presentations = _record <<< _presentations

_presentationInput :: forall r. Lens' { _presentationInput :: String | r } String
_presentationInput = prop (SProxy :: SProxy "_presentationInput")

presentationInput :: Lens' State String
presentationInput = _record <<< _presentationInput

_maybeUser :: forall r. Lens' { _maybeUser :: (Maybe User) | r } (Maybe User)
_maybeUser = prop (SProxy :: SProxy "_maybeUser")

maybeUser :: Lens' State (Maybe User)
maybeUser = _record <<< _maybeUser

newState :: State
newState = State
  {
    _page: 1,
    _url: "https://raw.githubusercontent.com/aztecrex/presenter-webui/master/README.md",
    -- _presentations: [
    --   "https://raw.githubusercontent.com/aztecrex/presenter-webui/master/README.md",
    --   "https://raw.githubusercontent.com/aztecrex/presenter-control-web/master/README.md"
    -- ],
    _presentations: [],
    _presentationInput: "",
    _maybeUser: Nothing
  }
