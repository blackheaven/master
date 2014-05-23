module Arrows (
          Node(..)
        , Ticket(..)
        , Rank(..)
        , genRanking
        , stabilize
        )  where

import Control.Arrow
import Control.Category
import Prelude hiding (id,(.))


data Node a b = Node { process :: a -> b }

instance Category Node where
    id = Node id
    (Node g) . (Node f) = Node (g . f)


instance Arrow Node where
    arr = Node
    first (Node f) = Node (\ ~(b, c) -> (f b, c))

-- Node Ticket Rank     -- Ordonne
-- Node Rank Rank -- Ralentit

type Ticket = ()
type Rank = ()

genRanking :: Node Ticket Rank
genRanking = arr undefined

stabilize :: Node Rank Rank
stabilize = arr undefined
