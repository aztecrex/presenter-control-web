module Content.Slide.Test (tests) where

import Prelude (Unit, ($), (==), pure, (<<<), (<>), discard)
import Data.List (List(..), (:))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Aff.AVar (AVAR)
import Text.Markdown.SlamDown (SlamDown, SlamDownP(..))
import Text.Markdown.SlamDown.Syntax (Block(..), Inline(..))
import Test.Unit (suite, test)
import Test.Unit.Console (TESTOUTPUT)
import Test.Unit.Main (runTest)
import Test.Unit.Assert (assert)

import Content.Slide (slides)


p1 :: ∀ a. Block a
p1 = Paragraph $ Str "paragraph 1" : Nil

p2 :: ∀ a. Block a
p2 = Paragraph $ Str "paragraph 2" : Nil

p3 :: ∀ a. Block a
p3 = Paragraph $ Str "paragraph 3" : Nil

slam :: ∀ a. Block a -> SlamDownP a
slam = SlamDown <<< pure

blank :: ∀ a. SlamDownP a
blank = SlamDown Nil

tests :: ∀ fx. Eff ( console :: CONSOLE
                  , testOutput :: TESTOUTPUT
                  , avar :: AVAR
                  | fx
          ) Unit
tests = do
  runTest do
    suite "Content.Slide" do
        test "break into slides" do
            let actual = slides $ SlamDown ( p1 : Rule : p2 : p3 : Rule : p1 : Rule : Rule : p2 : Nil) :: SlamDown
            let expected = slam p1 : (slam p2 <> slam p3) : slam p1 : blank : slam p2 : Nil
            assert "break at rules" $ actual == expected
        test "start and end with rules" do
            let actual = slides $ SlamDown ( Rule : p2 : p3 : Rule : Nil) :: SlamDown
            let expected = blank : (slam p2 <> slam p3) : blank : Nil
            assert "break at rules" $ actual == expected
        test "just rules" do
            let actual = slides $ SlamDown ( Rule : Rule : Rule : Nil) :: SlamDown
            let expected = blank : blank : blank : blank : Nil
            assert "break at rules" $ actual == expected
