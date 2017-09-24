module Model.Presentation.Test (tests) where

import Prelude (Unit, discard, map, negate, (#), ($), (+), (-), (/=), (==))
import Data.List (List, length, (!!))
import Data.Either (fromRight)
import Data.Maybe (fromJust)
import Partial.Unsafe (unsafePartial)
import Data.Lens ((+~), (-~), (.~), (^.))
import Text.Markdown.SlamDown (SlamDown)
import Text.Markdown.SlamDown.Parser (parseMd)
import Content.Slide (slides)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Aff.AVar (AVAR)
import Test.Unit (suite, test)
import Test.Unit.Main (runTest)
import Test.Unit.Assert (assert, equal)
import Test.Unit.Console (TESTOUTPUT)

import Model.Presentation (Presentation, content, create, number, size)

tests :: ∀ fx. Eff ( console :: CONSOLE
                  , testOutput :: TESTOUTPUT
                  , avar :: AVAR
                  | fx
          ) Unit
tests = do
  runTest do
    suite "ModelPresentation" do
      test "size" do
        let actual = testPres ^. size
        let expected = length testSlides
        equal expected actual
      test "slide content" do
        let actual = testPres ^. content
        let expected = testSlide 0
        equal expected actual
      test "get slide number" do
        let actual = testPres ^. number
        equal 1 actual
      test "change slide number" do
        let n = 3
        let updated = testPres # number .~ n
        let actualContent = updated ^. content
        let actualNumber = updated ^. number
        let expectedContent = testSlide (n - 1)
        equal expectedContent actualContent
        equal n actualNumber
      test "slide upper bound" do
        let updated = testPres # number .~ 300
        let actualContent = updated ^. content
        let actualNumber = updated ^. number
        let expectedContent = testSlide (length testSlides - 1)
        let expectedNumber = length testSlides
        equal expectedContent actualContent
        equal expectedNumber actualNumber
      test "slide lower bound" do
        let updated = testPres # number .~ (-300)
        let actualContent = updated ^. content
        let actualNumber = updated ^. number
        let expectedContent = testSlide 0
        let expectedNumber = 1
        equal expectedContent actualContent
        equal expectedNumber actualNumber
      test "relative slide change" do
        let up = 2
        let down = 1
        let moved = (testPres # number +~ up) # number -~ down
        equal (testSlide (up - down)) $ moved ^. content
        equal (1 + up - down) $ moved ^. number
      test "presentation equal" do
         let src = "# Slide"
         let a = unsafeCreatePres src
         let b = unsafeCreatePres src
         assert "they are equal" $ a == b
         assert "commutative" $ b == a
         assert "same" $ a == a
      test "presentation nequal" do
         let a = unsafeCreatePres "# Slide 1\n---\n# Slide 2"
         let b = unsafeCreatePres "# Slide"
         assert "they are noe equal" $ a /= b
         assert "commutative" $ b /= a




unsafeCreatePres :: String -> Presentation
unsafeCreatePres src = unsafePartial $ fromRight $ create src

testSlides :: List SlamDown
testSlides = unsafePartial fromRight $ map slides $ parseMd testSource

testSlide :: Int -> SlamDown
testSlide i = unsafePartial fromJust $ testSlides !! i

testPres :: Presentation
testPres = unsafeCreatePres testSource

testSource :: String
testSource = """
# Slide One

On this slide we have lots of coolness.

---
# Slide Two

## Let me tell you

This is weird.

## Let me tell you something else

_Really_ weird.

---
# Final Slide

Wasn't that just the greatest presentation?

"""
