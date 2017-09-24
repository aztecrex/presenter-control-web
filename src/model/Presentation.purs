module Model.Presentation (
  Presentation,
  create,
  content,
  number,
  size
) where

import Prelude (class Eq, class Show, clamp, compose, map, show, (#), ($), (&&), (+), (-), (<<<), (<>), (==))
import Data.List (List(..), (:), length, (!!))
import Data.Either (Either(..))
import Data.Maybe (fromJust)
import Partial.Unsafe (unsafePartial)
import Data.NonEmpty (NonEmpty, (:|), fromNonEmpty)
import Data.Newtype (class Newtype, unwrap)
import Data.Symbol (SProxy(..))
import Data.Lens
import Data.Lens.Record (prop)
import Text.Markdown.SlamDown (SlamDown)
import Text.Markdown.SlamDown.Parser (parseMd)
import Content.Slide (slides)

type Content = SlamDown
type ContentList = NonEmpty List Content
type PresentationR = {
    _index :: Int,
    _content :: ContentList
}
newtype Presentation = Pr PresentationR
derive instance newtypePresentation :: Newtype Presentation _

rShow :: PresentationR -> String
rShow {_index: i, _content : (c :| cs)} = "{page: " <> show (i + 1) <> ", content: " <> show (c :cs) <> "}"

instance showPresentation :: Show Presentation where
  show (Pr r) = rShow r

rEq :: PresentationR -> PresentationR -> Boolean
rEq a b = a._index == b._index && a._content == b._content

instance eqPresentation :: Eq Presentation where
  eq (Pr a) (Pr b) = rEq a b

contentListLength :: ContentList -> Int
contentListLength = fromNonEmpty $ (compose length) <<< Cons

contentAt :: Int -> ContentList -> Content
contentAt i (c :| cs) = unsafePartial $ fromJust $ (c : cs) !! i

_record :: Iso' Presentation PresentationR
_record = iso unwrap Pr

_index :: forall r. Lens' { _index :: Int | r } Int
_index = prop (SProxy :: SProxy "_index")

_content :: forall r. Lens' { _content :: ContentList | r } ContentList
_content = prop (SProxy :: SProxy "_content")

_length :: forall s. Fold' s ContentList Int
_length = to contentListLength

_clampedIndex :: forall r. Lens' { _index :: Int, _content :: ContentList | r} Int
_clampedIndex = lens get' set'
  where get' rec = rec ^. _index
        set' rec i = rec # _index .~ (clamp 0 ((rec ^. _content <<< _length) - 1) i)

_extract :: forall s r. Fold' s { _index :: Int, _content :: ContentList | r} Content
_extract = to get'
  where get' rec = contentAt rec._index rec._content

_oneOff :: Iso' Int Int
_oneOff = iso (_ + 1) (_ - 1)

size :: forall s. Fold' s Presentation Int
size = _record <<< _content <<< _length

number :: Lens' Presentation Int
number = _record <<< _clampedIndex <<< _oneOff

content :: forall s. Fold' s Presentation Content
content = _record <<< _extract

create :: String -> Either String Presentation
create source = case map slides $ parseMd source of
  Left _ -> Left "parse error"
  Right Nil -> Left "no content"
  Right (s : ss) -> Right $ Pr { _index: 0, _content: s :| ss }

