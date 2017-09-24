module Content.Render (render) where

import Prelude ((<>), ($), show )
import Data.Traversable(traverse_)
import Data.Foldable(intercalate, foldMap)
import Text.Markdown.SlamDown(SlamDownP(..), Block(..), Inline(..), CodeBlockType(..), ListType(..), LinkTarget(..))
import Text.Smolder.Markup (Markup, text, (!), parent)
import Text.Smolder.HTML (p, div, code, pre, ol, ul, li, blockquote, a, strong, em, br, img)
import Text.Smolder.HTML.Attributes (className, href, src, alt)

render :: forall a b. SlamDownP a -> Markup b
render (SlamDown blocks) = div $ traverse_ renderBlock blocks

renderBlock :: forall a b. Block a -> Markup b
renderBlock (Paragraph spans) = p $ traverse_ renderInline spans
renderBlock (CodeBlock (Fenced _ "") lines) = pre $ code $ text $ intercalate "\n" lines
renderBlock (CodeBlock (Fenced _ language) lines) = pre $ code ! className ("language-" <> language) $ text $ intercalate "\n" lines
renderBlock (CodeBlock Indented lines) = pre $ code $ text $ intercalate "\n" lines
renderBlock (Lst (Ordered _) items) = ol $ traverse_ (traverse_ paragraphToLine) items
renderBlock (Lst (Bullet _) items) = ul $ traverse_ (traverse_ paragraphToLine) items
renderBlock (Blockquote blocks) = blockquote $ traverse_ renderBlock blocks
renderBlock (Header level spans) = parent ("h" <> show level) $ traverse_ renderInline spans
renderBlock (LinkReference label dest) = a ! href dest $ text label
renderBlock _ = p (text "Block conversion not implemented.")

renderInline :: forall a b. Inline a -> Markup b
renderInline (Str txt) = text txt
renderInline Space = text " "
renderInline (Code _ txt) = code $ text txt
renderInline (Strong spans) = strong $ traverse_ renderInline spans
renderInline (Emph spans) = em $ traverse_ renderInline spans
renderInline SoftBreak = text "\n"
renderInline LineBreak = br
renderInline (Entity txt) = text txt
renderInline (Link spans (InlineLink dest)) = a ! href dest $ traverse_ renderInline spans
renderInline (Image spans dest) = img ! src dest ! alt (foldMap stringPart spans)
renderInline _ = text "Inline conversion not implemented."

stringPart :: forall a. Inline a -> String
stringPart (Str txt) = txt
stringPart Space = " "
stringPart _ = ""

paragraphToLine :: forall a b. Block a -> Markup b
paragraphToLine (Paragraph spans) = li $ traverse_ renderInline spans
paragraphToLine b = renderBlock b
