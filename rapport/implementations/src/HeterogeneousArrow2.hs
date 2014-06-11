{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies, FlexibleInstances, DataKinds, TypeOperators, KindSignatures, GADTs, ExplicitForAll, StandaloneDeriving, PolyKinds, TypeFamilies, ConstraintKinds, UndecidableInstances, RankNTypes, AllowAmbiguousTypes #-}
module HeterogeneousArrow2 (
          HeterogeneousArrow
        , (>*>)
        )  where

import Control.Category
import Prelude hiding (id,(.))
import Arrows2 -- TODO : debug purposes
import GHC.Exts (Constraint)
import Control.Arrow
import Control.Monad.State
class HeterogeneousArrow x y z | x y -> z where
    (>*>) :: x a b -> y b c -> z a c

-- infixr 5 >*>

-- instance (Category x) => HeterogeneousArrow x x x where
--     f >*> g = g . f


instance HeterogeneousArrow (Kleisli (State s)) (Kleisli (State s')) (Kleisli (State (s, s'))) where
    f >*> g = Kleisli $ \e -> do
        (ir, is) <- get
        let (rv, rs) = runState (runKleisli f e) ir
        let (sv, ss) = runState (runKleisli g rv) is
        put (rs, ss)
        return sv

-- stabilize :: Kleisli (State Counter) a (Maybe a)
-- genRanking :: Kleisli (State Ranking) Ticket Ranking
-- stabilizedRanking' :: Ticket -> State (Ranking, Counter) (Maybe Ranking)
-- stabilizedRanking' e = do
--     (ir, is) <- get
--     let (rv, rs) = runState (runKleisli genRanking e) ir
--     let (sv, ss) = runState (runKleisli stabilize rv) is
--     put (rs, ss)
--     return sv

newtype Fast s i o = F (Kleisli (State s) i o)
newtype Slow s i o = S (Kleisli (State s) i o)

encStabilize :: Slow Counter a (Maybe a)
encStabilize = S stabilize
encGenRanking :: Fast Ranking Ticket Ranking
encGenRanking = F genRanking

instance HeterogeneousArrow (Fast s) (Slow s') (Slow (s, s')) where
    F f >*> S g = S (f >*> g)
