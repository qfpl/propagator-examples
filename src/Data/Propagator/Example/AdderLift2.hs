module Data.Propagator.Example.AdderLift2 where

import Control.Monad.ST (ST)
import Data.Propagator (Cell, cell, content, watch, with, write)

adderLift2Example :: ST s (Maybe Int)
adderLift2Example = do
  inL <- cell
  inR <- cell
  out <- cell

  adder inL inR out

  write out 10
  write inL 3

  content inR

lift2 :: (a -> b -> c) -> Cell s a -> Cell s b -> Cell s c -> ST s ()
lift2 f ca cb cc = do
  watch ca $ \a -> with cb $ \b -> write cc (f a b)
  watch cb $ \b -> with ca $ \a -> write cc (f a b)

adder :: Num a => Cell s a -> Cell s a -> Cell s a -> ST s ()
adder a b c = do
  lift2 (+) a b c
  lift2 (-) c b a
  lift2 (-) c a b
