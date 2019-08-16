module Data.Propagator.Example.CtoFBidirectional where

import Control.Monad.ST (ST)
import Data.Propagator (Cell, cell, content, known, lift2, watch, with, write)
import Data.Propagator.Example.AdderLift2 (adder)

type Celsius = Double
type Fahrenheit = Double

ctofBidirectionalExample :: ST s (Maybe Double)
ctofBidirectionalExample = do
  celsius    <- cell
  fahrenheit <- cell

  write fahrenheit 451

  ctof celsius fahrenheit

  content celsius

ctof :: Cell s Celsius -> Cell s Fahrenheit -> ST s ()
ctof c f = do
  ninefifths <- known (9/5)
  intermediate <- cell
  lift2 (*) c ninefifths intermediate
  lift2 (/) intermediate ninefifths c
  thirtytwo <- known 32
  adder intermediate thirtytwo f
