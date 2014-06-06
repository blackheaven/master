module Arrows (
          Node(..)
        , Ticket(..)
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


data Node a b = Node { process :: a -> b }

instance Category Node where
    id = Node id
    (Node g) . (Node f) = Node (g . f)


instance Arrow Node where
    arr = Node
    first (Node f) = Node (\ ~(b, c) -> (f b, c))

type Ticket = String
data Rank = Rank { title :: String, visitors :: Int } deriving (Show, Eq)
type Ranking = [Rank]
type Counter = Int

genRanking :: Node (Ticket, Ranking) Ranking
genRanking = arr (uncurry updateRanking)

updateRanking :: Ticket -> Ranking -> Ranking
updateRanking t r = case b of
                        []          -> a ++ [Rank t 1]
                        (x : xs)    -> sortBy (flip compare `on` visitors) (Rank t (1 + visitors x) : a ++ xs)
    where (a, b) = break (\(Rank i _) -> i == t) r

stabilize :: Node (a, Counter) (Maybe a, Counter)
stabilize = arr (\(x, i) -> if i < 2 then (Nothing, i + 1) else (Just x, 0))

-- TODO : MT State Maybe into Kielsi arrow 
stabilizedRanking :: Node ((Ticket, Ranking), Counter) (Maybe Ranking, Counter)
stabilizedRanking = first genRanking >>> stabilize

-- helper
processMany :: Node (a, b) b -> b -> [a] -> b
processMany n = foldl (\a t -> process n (t, a))

processManyLoop :: Node (a, b) (Maybe a, b) -> b -> [a] -> [a]
processManyLoop n i = reverse . catMaybes . fst . foldl l ([], i)
    where  l (xs, s) x = let (a, ns) = process n (x, s) in (a : xs, ns)
