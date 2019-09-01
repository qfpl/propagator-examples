module Data.Propagator.Example.BuildingHeight where

import Control.Monad (unless)
import Control.Monad.ST (ST)
import Data.Propagator
import Numeric.Interval (Interval, (...), singleton)

type Seconds = Interval Double
type Height = Interval Double

measureBuilding :: ST s (Maybe Height)
measureBuilding = do

  -- cells
  buildingHeight <- cell
  fallTime <- known (2.9 ... 3.1)
  buildingShadow <- known (54.9 ... 55.1)
  barometerHeight <- known (0.3 ... 0.32)
  barometerShadow <- known (0.36 ... 0.37)

  -- propagators
  fallDuration fallTime buildingHeight
  similarTriangles barometerShadow barometerHeight buildingShadow buildingHeight

  content buildingHeight

fallDuration :: Cell s Seconds -> Cell s Height -> ST s ()
fallDuration t h = do
  g <- known (9.789 ... 9.832)
  half <- known (singleton 0.5)
  tSquared <- cell
  gtSquared <- cell
  squarer t tSquared
  multiplier g tSquared gtSquared
  multiplier half gtSquared h

similarTriangles :: Cell s Height -> Cell s Height -> Cell s Height -> Cell s Height -> ST s ()
similarTriangles barometerShadow barometerHeight buildingShadow buildingHeight = do
  ratio <- cell
  divider barometerHeight barometerShadow ratio
  multiplier buildingShadow ratio buildingHeight

multiplier :: (Eq a, Fractional a) => Cell s a -> Cell s a -> Cell s a -> ST s ()
multiplier inL inR out = do
  lift2 (*) inL inR out
  divide out inR inL
  divide out inL inR
    where
      divide l r o = do
        with r $ \denom ->
          unless (denom == 0) $
            with l $ \numer ->
              write o (numer / denom)

divider :: (Eq a, Fractional a) => Cell s a -> Cell s a -> Cell s a -> ST s ()
divider numer denom out = multiplier out denom numer

squarer :: Floating a => Cell s a -> Cell s a -> ST s ()
squarer input output = do
  lift1 (\x -> x*x) input output
  lift1 sqrt output input
