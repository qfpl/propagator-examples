module Main where

import Control.Monad.ST
import Data.Propagator

main :: IO ()
main = print $ runST $ do
  inL <- cell
  inR <- cell
  out <- cell
  watch inL $ \l -> watch inR $ \r -> write out (l+r)
  watch inR $ \r -> watch inL $ \l -> write out (l+r)
  write inL 5
