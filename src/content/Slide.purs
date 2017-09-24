module Content.Slide (slides) where

import Prelude (map, class Eq, class Ord, (==), otherwise, ($))
import Data.Foldable (foldr)
import Text.Markdown.SlamDown (SlamDownP(..))
import Text.Markdown.SlamDown.Syntax (Block(Rule))
import Data.List (List(..), (:))
import Data.NonEmpty (NonEmpty, (:|), singleton, fromNonEmpty)

break :: ∀ a. NonEmpty List (List a) -> NonEmpty List (List a)
break (l :| ls) = Nil :| (l : ls)

prepend :: ∀ a. a -> NonEmpty List (List a) -> NonEmpty List (List a)
prepend elem (l :| ls) = (elem : l) :| ls

splitr :: ∀ a. Eq a => a -> a -> NonEmpty List (List a) -> NonEmpty List (List a)
splitr delim elem accum | elem == delim = break accum
                        | otherwise     = prepend elem accum

unwrap :: ∀ a. NonEmpty List a -> List a
unwrap = fromNonEmpty Cons

split :: ∀ a. (Eq a) => a -> List a -> NonEmpty List (List a)
split delim = foldr (splitr delim) (singleton Nil)

slides :: ∀ a. Eq a => Ord a => SlamDownP a -> List (SlamDownP a)
slides  (SlamDown bs) = map SlamDown $ unwrap $ split Rule bs
