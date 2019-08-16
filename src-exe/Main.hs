{-# language RankNTypes #-}

module Main where

import Data.Propagator.Example.AdderForward (adderForwardExample)
import Data.Propagator.Example.AdderBackward (adderBackwardExample)
import Data.Propagator.Example.AdderLift2 (adderLift2Example)
import Data.Propagator.Example.CtoF (ctofExample)
import Data.Propagator.Example.CtoFBidirectional (ctofBidirectionalExample)
import Control.Monad.ST (ST, runST)

runNetwork :: Show a => (forall s . ST s (Maybe a)) -> IO ()
runNetwork st = print $ runST st

main = do
  runNetwork adderForwardExample
  runNetwork adderBackwardExample
  runNetwork adderLift2Example
  runNetwork ctofExample
  runNetwork ctofBidirectionalExample
