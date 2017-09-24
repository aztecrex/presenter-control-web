module Content.Interop (getSource) where

import Prelude (bind, pure, show, ($))
import Data.Either (either)
import Control.Monad.Aff (attempt, Aff)
import Network.HTTP.Affjax (AJAX, get)


getSource :: forall r.
      Aff
        ( ajax :: AJAX
        | r
        )
        String
getSource = do
  res <- attempt $ get "/functional-and-serverless.present.md"
  let decode r = r.response
  pure $ either show decode res
