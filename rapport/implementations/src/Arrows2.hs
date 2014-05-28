module Arrows2 (
          Ticket(..)
        , Rank(..)
        , Ranking(..)
        , genRanking
        , stabilize
        , stabilizedRanking
        , processMany
        , processManyLoop
        )  where

import Control.Arrow
import Control.Category
import Data.List (sortBy)
import Data.Function (on)
import Data.Maybe (catMaybes)
import Prelude hiding (id,(.))
import Control.Monad.State

type Ticket = String
data Rank = Rank { title :: String, visitors :: Int } deriving (Show, Eq)
type Ranking = [Rank]

genRanking :: Kleisli (State Ranking) Ticket Ranking
genRanking = Kleisli $ \t -> get >>= put . updateRanking t >> get

updateRanking :: Ticket -> Ranking -> Ranking
updateRanking t r = case b of
                        []          -> a ++ [Rank t 1]
                        (x : xs)    -> sortBy (flip compare `on` visitors) (Rank t (1 + visitors x) : a ++ xs)
    where (a, b) = break (\(Rank i _) -> i == t) r

stabilize :: Kleisli (State Int) a (Maybe a)
stabilize = Kleisli $ \e -> get >>= \i ->  if i < 2
                                            then put (i + 1) >> return Nothing
                                            else put 0 >> return (Just e)

stabilizedRanking :: Kleisli (State (Ranking, Int)) Ticket (Maybe Ranking)
stabilizedRanking = Kleisli stabilizedRanking'

stabilizedRanking' :: Ticket -> State (Ranking, Int) (Maybe Ranking)
stabilizedRanking' e = do
    (ir, is) <- get
    let (rv, rs) = runState (runKleisli genRanking e) ir
    let (sv, ss) = runState (runKleisli stabilize rv) is
    put (rs, ss)
    return sv

-- helper
processMany :: Kleisli (State b) a b -> b -> [a] -> b
processMany n = foldl $ \a t -> evalState (runKleisli n t) a

processManyLoop :: Kleisli (State s) a (Maybe b) -> s -> [a] -> [b]
processManyLoop n i = reverse . catMaybes . fst . foldl f ([], i)
    where f (a, s) x = let (e, t) = runState (runKleisli n x) s in (e:a, t)
