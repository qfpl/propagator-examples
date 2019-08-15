{-# language RankNTypes #-}

module Main where

import Data.Propagator.Example.AdderForward (adderForwardExample)
import Data.Propagator.Example.AdderBackward (adderBackwardExample)

import Control.Monad.ST (ST, runST)

runNetwork :: Show a => (forall s . ST s (Maybe a)) -> IO ()
runNetwork st = print $ runST st

main = do
  runNetwork adderForwardExample
  runNetwork adderBackwardExample