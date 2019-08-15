module Data.Propagator.Example.AdderForward where

import Control.Monad.ST (ST)
import Data.Propagator

adderForwardExample :: ST s (Maybe Int)
adderForwardExample = do
  inL <- cell
  inR <- cell
  out <- cell

  adder inL inR out

  write inL 3
  write inR 7

  content out

adder :: Cell s Int -> Cell s Int -> Cell s Int -> ST s ()
adder inL inR out = do
  watch inL $ \l -> with inR $ \r -> write out (l+r)
  watch inR $ \l -> with inL $ \r -> write out (l+r)