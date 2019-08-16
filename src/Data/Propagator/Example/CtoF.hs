module Data.Propagator.Example.CtoF where

import Control.Monad.ST (ST)
import Data.Propagator (Cell, cell, content, known, lift2, watch, with, write)

type Celsius = Double
type Fahrenheit = Double

ctofExample :: ST s (Maybe Double)
ctofExample = do
  celsius    <- cell
  fahrenheit <- cell

  write celsius 232.77777777777777

  ctof celsius fahrenheit

  content fahrenheit

ctof :: Cell s Celsius -> Cell s Fahrenheit -> ST s ()
ctof c f = do
  ninefifths   <- known (9/5)
  intermediate <- cell
  lift2 (*) c ninefifths intermediate
  thirtytwo <- known 32
  lift2 (+) intermediate thirtytwo f
