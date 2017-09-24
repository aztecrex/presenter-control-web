module Content.Render.Test (tests) where

import Prelude (Unit, ($), (<>), (<<<), discard, map)
import Data.Either(Either)
import Data.List (singleton, (:), List(..))
import Text.Markdown.SlamDown.Parser(parseMd)
import Text.Markdown.SlamDown (SlamDown, SlamDownP(..), Block(..), Inline(..), CodeBlockType(..), ListType(..), LinkTarget(..))
import Text.Smolder.HTML (div, p, pre, code, ol, ul, li, blockquote, h1, h3, a, strong, em, br, img)
import Text.Smolder.HTML.Attributes (className, href, src, alt)
import Text.Smolder.Markup (text, Markup, (!))
import Text.Smolder.Renderer.String as MR
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Aff.AVar (AVAR)
import Test.Unit (suite, test, Test)
import Test.Unit.Console (TESTOUTPUT)
import Test.Unit.Main (runTest)
import Test.Unit.Assert (equal)

import Content.Render (render)

para :: forall a. String -> Block a
para txt = Paragraph $ singleton $ Str txt

blockp :: forall a. String -> Block a
blockp = para

singletonMd :: forall a. Block a -> SlamDownP a
singletonMd = SlamDown <<< singleton

paragraphMd :: forall a. String -> SlamDownP a
paragraphMd = singletonMd <<< blockp

parsed :: Either String SlamDown
parsed = parseMd "this is true: 7 &lt; 100 & 7 < 12"

tests :: ∀ fx. Eff ( console :: CONSOLE
                  , testOutput :: TESTOUTPUT
                  , avar :: AVAR
                  | fx
          ) Unit
tests = do
  runTest do
    suite "Content.Render block elements" do
        test "convert paragraph" do
            let ptext = "such text!"
            let source = paragraphMd ptext
            let expected = div $ do
                             p $ text ptext
            check source expected
        test "convert multiple paragraphs" do
            let ptext1 = "such text!"
            let ptext2 = "such more text!"
            let source = SlamDown (blockp ptext1 : blockp ptext2 : Nil)
            let expected = div $ do
                             p $ text ptext1
                             p $ text ptext2
            check source expected
        test "convert multiple text" do
            let ptext1 = "such text!"
            let ptext2 = "such more text!"
            let ptext3 = "with addition"
            let source = SlamDown (blockp ptext1 : Paragraph  (Str ptext2 : Str ptext3 : Nil) : Nil)
            let expected = div $ do
                  p $ text ptext1
                  p $ do
                    text ptext2
                    text ptext3
            check source expected
        test "convert fenced code block" do
          let line1 = "line 1"
          let line2 = "line 2"
          let line3 = "line 3"
          let lines = line1 : line2 : line3 : Nil
          let source = singletonMd $ CodeBlock (Fenced true "") lines
          let expected = div $ do
                pre $ code $ text $
                  line1 <> "\n" <> line2 <> "\n" <> line3
          check source expected
        test "convert fenced code block with language" do
          let line1 = "line 1"
          let line2 = "line 2"
          let line3 = "line 3"
          let lines = line1 : line2 : line3 : Nil
          let source = singletonMd $ CodeBlock (Fenced true "cpp") lines
          let expected = div $ do
                pre $ code ! className "language-cpp" $ text $
                  line1 <> "\n" <> line2 <> "\n" <> line3
          check source expected
        test "convert indented code block" do
          let line1 = "line 1"
          let line2 = "line 2"
          let line3 = "line 3"
          let lines = line1 : line2 : line3 : Nil
          let source = singletonMd $ CodeBlock Indented lines
          let expected = div $ do
                pre $ code $ text $
                  line1 <> "\n" <> line2 <> "\n" <> line3
          check source expected
        test "convert ordered list" do
          let itext1 = "line 1"
          let itext2 = "line 2"
          let itext3 = "line 3"
          let codetext = "int x = 3.302"
          let items1 = blockp itext1 : CodeBlock Indented (singleton codetext) : Nil
          let items2 = blockp itext2 : blockp itext3 : Nil
          let source = SlamDown $ singleton $ Lst (Ordered "1.") (items1 : items2 : Nil)
          let expected = div $ do
                ol $ do
                  li $ text itext1
                  pre $ code $ text codetext
                  li $ text itext2
                  li $ text itext3
          check source expected
        test "convert unordered list" do
          let itext1 = "line 1"
          let itext2 = "line 2"
          let itext3 = "line 3"
          let codetext = "int x = 3.302"
          let items1 = blockp itext1 : CodeBlock Indented (singleton codetext) : Nil
          let items2 = blockp itext2 : blockp itext3 : Nil
          let source = SlamDown $ singleton $ Lst (Bullet "*") (items1 : items2 : Nil)
          let expected = div $ do
                ul $ do
                  li $ text itext1
                  pre $ code $ text codetext
                  li $ text itext2
                  li $ text itext3
          check source expected
        test "convert block quote" do
            let ptext1 = "such text!"
            let ptext2 = "such more text!"
            let source = SlamDown $ singleton $ Blockquote (para ptext1 : para ptext2 : Nil)
            let expected = div $ blockquote $ do
                             p $ text ptext1
                             p $ text ptext2
            check source expected
        test "convert header" do
            let ptext1 = "Such"
            let ptext2 = " "
            let ptext3 = "Header"
            let ptext4 = "!"
            let source = SlamDown $ singleton $ Header 1 $ map Str (ptext1 : ptext2 : ptext3 : ptext4 : Nil)
            let expected = div $ h1 $ do
                             text ptext1
                             text ptext2
                             text ptext3
                             text ptext4
            check source expected
        test "convert header level" do
            let ptext1 = "Such"
            let ptext2 = " "
            let ptext3 = "Header"
            let ptext4 = "!"
            let source = SlamDown $ singleton $ Header 3 $ map Str (ptext1 : ptext2 : ptext3 : ptext4 : Nil)
            let expected = div $ h3 $ do
                             text ptext1
                             text ptext2
                             text ptext3
                             text ptext4
            check source expected
        test "convert link reference" do
            let label = "destination"
            let dest = "https://gregwiley.com"
            let source = SlamDown $ singleton $ LinkReference label dest
            let expected = div $ a ! href dest $ text label
            check source expected
    suite "Content.Render inline elements" do
        test "convert str" do
            let ptext = "such text!"
            let source = Str ptext
            let expected = text ptext
            checkInline source expected
        test "convert space" do
            let source = Space
            let expected = text " "
            checkInline source expected
        test "convert code" do
            let ptext = "such code!"
            let source = Code false ptext
            let expected = code $ text ptext
            checkInline source expected
        test "convert strong" do
            let ptext1 = "such "
            let ptext2 = "text!"
            let source = Strong $ map Str (ptext1 : ptext2 : Nil)
            let expected = strong $ do
                  text ptext1
                  text ptext2
            checkInline source expected
        test "convert emphasis" do
            let ptext1 = "such "
            let ptext2 = "text!"
            let source = Emph $ map Str (ptext1 : ptext2 : Nil)
            let expected = em $ do
                  text ptext1
                  text ptext2
            checkInline source expected
        test "convert soft break" do
            let source = SoftBreak
            let expected = text "\n"
            checkInline source expected
        test "convert line break" do
            let source = LineBreak
            let expected = br
            checkInline source expected
        test "convert entity (not what I really want to do but predicatable)" do
            let etext = "&nbsp;"
            let source = Entity etext
            let expected = text etext
            checkInline source expected
        test "convert link (inline only, reference not implemented)" do
            let ltext1 = "such "
            let ltext2 = "text!"
            let dest = "https://gjwiley.com"
            let source = Link (map Str (ltext1 : ltext2 : Nil)) (InlineLink dest)
            let expected = a ! href dest $ do
                  text ltext1
                  text ltext2
            checkInline source expected
        test "convert image" do
            let ltext1 = "such "
            let ltext2 = "text!"
            let loc = "https://gjwiley.com/images/fishbicycle.png"
            let source = Image (Str ltext1 : Space : Str ltext2 : Nil) loc
            let expected = img ! src loc ! alt (ltext1 <> " " <> ltext2)
            checkInline source expected

check :: forall e a. SlamDown -> Markup a -> Test (console :: CONSOLE | e)
check source expected = do
    let actual = render source
    equal (MR.render expected) (MR.render actual)

checkInline :: forall e a. Inline String -> Markup a -> Test (console :: CONSOLE | e)
checkInline source expected = do
    let embeddedSource = SlamDown $ singleton $ Paragraph $ singleton source
    let embeddedExpected = div $ p expected
    check embeddedSource embeddedExpected
