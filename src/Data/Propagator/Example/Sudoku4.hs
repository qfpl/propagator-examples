module Data.Propagator.Example.Sudoku4 where

import Control.Monad.ST (ST)
import Data.Foldable (toList, traverse_)
import Data.List (intercalate)
import Data.Propagator
import Data.Set (Set, (\\))
import qualified Data.Set as Set

data Number = One | Two | Three | Four deriving (Eq, Ord, Show)

newtype Square = Square { possibilities :: Set Number }

instance Propagated Square where
  merge (Square p) (Square q) =
    let
      overlap = Set.intersection p q
    in
      if Set.null overlap then
        Contradiction mempty "Impossible square"
      else
        Change (p /= overlap) (Square overlap)

data V4 a
  = V4
  { _1 :: a
  , _2 :: a
  , _3 :: a
  , _4 :: a
  } deriving (Eq, Ord)

instance Show a => Show (V4 a) where
  show = show . toList

newtype Grid s = Grid { ungrid :: V4 (V4 (Cell s Square)) }

newtype SudokuResult = Result { unresult :: V4 (V4 (Maybe Number))}

instance Show SudokuResult where
  show (Result vvmn) =
    intercalate "\n" . toList $ fmap (fmap showMN . toList) vvmn
      where
        showMN :: Maybe Number -> Char
        showMN Nothing = '?'
        showMN (Just n) = case n of
          One -> '1'
          Two -> '2'
          Three -> '3'
          Four -> '4'


instance Functor V4 where
  fmap f (V4 a b c d) = V4 (f a) (f b) (f c) (f d)

instance Foldable V4 where
  foldMap f (V4 a b c d) = f a <> f b <> f c <> f d

instance Traversable V4 where
  traverse f (V4 a b c d) = V4 <$> f a <*> f b <*> f c <*> f d

instance Applicative V4 where
  pure a = V4 a a a a
  V4 fa fb fc fd <*> V4 a b c d = V4 (fa a) (fb b) (fc c) (fd d)

sudokuExample :: ST s SudokuResult
sudokuExample = do
  grid <- initialGrid

  traverse_ allDifferent (rows grid)
  traverse_ allDifferent (columns grid) 
  traverse_ allDifferent (blocks grid)

  setup grid

  collect grid

-- This is naive. There are papers on making the allDifferent constraint fast
allDifferent :: V4 (Cell s Square) -> ST s ()
allDifferent = go . toList
  where
    go [] = pure ()
    go (x:xs) = traverse_ (different x) xs *> go xs


initialGrid :: ST s (Grid s)
initialGrid = Grid <$> traverse sequenceA (pure (pure cell))

setup :: Grid s -> ST s ()
setup grid = do
  -- ??3?
  -- ?4??
  -- ??2?
  -- ???1
  write' (_3._1) Three
  write' (_2._2) Four
  write' (_3._3) Two
  write' (_4._4) One

  where
    write' path n = write (path (ungrid grid)) (sq n)
    sq = Square . Set.singleton

different :: Cell s Square -> Cell s Square -> ST s ()
different s1 s2 = do
  lift1 diff s1 s2
  lift1 diff s2 s1
    where
      universe = Set.fromList[One,Two,Three,Four]
      diff s =
        Square $ case demand s of
          Nothing -> universe
          Just x  -> universe \\ Set.singleton x

collect :: Grid s -> ST s SudokuResult
collect = fmap Result . (traverse.traverse) readSquare . ungrid
  where
    readSquare :: Cell s Square -> ST s (Maybe Number)
    readSquare c = (>>= demand) <$> content c

demand :: Square -> Maybe Number
demand square =
  case Set.toList (possibilities square) of
    []    -> Nothing
    _:_:_ -> Nothing
    x:[]  -> Just x

rows :: Grid s -> V4 (V4 (Cell s Square))
rows = ungrid

columns :: Grid s -> V4 (V4 (Cell s Square))
columns = sequenceA . ungrid

blocks :: Grid s -> V4 (V4 (Cell s Square))
blocks grid = (fmap.fmap) select (V4 tl tr bl br)
  where
    select = ($ ungrid grid)
    tl = V4 (_1._1) (_1._2) (_2._1) (_2._2)
    tr = V4 (_1._3) (_1._4) (_2._3) (_2._4)
    bl = V4 (_3._1) (_3._2) (_4._1) (_4._2)
    br = V4 (_3._3) (_3._4) (_4._3) (_4._4)
