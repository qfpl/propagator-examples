module Data.Propagator.Example.AdderBackward where

import Control.Monad.ST (ST)
import Data.Propagator

adderBackwardExample :: ST s (Maybe Int)
adderBackwardExample = do
  inL <- cell
  inR <- cell
  out <- cell

  adder inL inR out

  write out 10
  write inL 3

  content inR

adder :: Cell s Int -> Cell s Int -> Cell s Int -> ST s ()
adder inL inR out = do
  watch inL $ \l -> do
    with inR $ \r -> write out (l+r)
    with out $ \o -> write inR (o-l)
  watch inR $ \r -> do
    with inL $ \l -> write out (l+r)
    with out $ \o -> write inL (o-r)
  watch out $ \o -> do
    with inR $ \r -> write inL (o-r)
    with inL $ \l -> write inR (o-l)
