{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies, FlexibleInstances, DataKinds, TypeOperators, KindSignatures, GADTs, ExplicitForAll, StandaloneDeriving, PolyKinds, TypeFamilies, ConstraintKinds, UndecidableInstances, RankNTypes, AllowAmbiguousTypes #-}
module HeterogeneousArrow (
          HeterogeneousArrow
        , (>*>)
        )  where

import Control.Category
import Prelude hiding (id,(.))
import Arrows2 -- TODO : debug purposes
import GHC.Exts (Constraint)
import Control.Arrow
import Control.Monad.State

-------------
type family Map (f :: k -> l) (xs :: [k]) :: [l]
type instance Map f '[]       = '[]
type instance Map f (x ': xs) = f x ': Map f xs

type family ReverseAcc (xs :: [k]) (acc :: [k]) :: [k]
type instance ReverseAcc '[]       acc = acc
type instance ReverseAcc (x ': xs) acc = ReverseAcc xs (x ': acc)

type Reverse (xs :: [k]) = ReverseAcc xs '[]

type family (++) (xs :: [k]) (ys :: [k]) :: [k]
type instance (++) '[]       ys = ys
type instance (++) (x ': xs) ys = x ': (xs ++ ys)



type family Constraints (cs :: [Constraint]) :: Constraint
type instance Constraints '[]       = ()
type instance Constraints (c ': cs) = (c, Constraints cs)

type All (c :: k -> Constraint) (xs :: [k]) = Constraints (Map c xs)
-------------

class HeterogeneousArrow x y z | x y -> z where
    (>*>) :: x a b -> y b c -> z a c

-- infixr 5 >*>

instance (Category x) => HeterogeneousArrow x x x where
    f >*> g = g . f

-- HList
data HList :: [*] -> * where
    HNil    :: HList '[]
    HCons   :: t -> HList ts -> HList (t ': ts)

-- infixr 2 `HCons`

instance Show (HList '[]) where
    show _ = "H[]"

instance (Show e, Show (HList l)) => Show (HList (e ': l)) where
    show (HCons x l) = let 'H':'[':s = show l in "H[" ++ show x ++ 
                                                         (if s == "]" then s else ", " ++ s)

data Env :: [k] -> (k -> *) -> * where
  Nil  :: Env '[] f
  (:*) :: f a -> Env as f -> Env (a ': as) f

deriving instance All Show (Map f as) => Show (Env as f)

infixr 5 :*

zipWithE :: (forall a. f a -> g a -> h a)
         -> Env xs f -> Env xs g -> Env xs h
zipWithE op Nil       Nil       = Nil
zipWithE op (x :* xs) (y :* ys) = op x y :* zipWithE op xs ys

data HApL :: [*] -> [*] -> * where
  Nil2  :: HApL '[] '[]
  (:**) :: (a -> b) -> HApL as bs -> HApL (a ': as) (b ': bs)

-- deriving instance All Show (Map f as bs) => Show (Env as bs f)
infixr 5 :**

zipWithHApL :: HApL xs ys -> HList xs -> HList ys
zipWithHApL Nil2       HNil      = HNil
zipWithHApL (x :** xs) (HCons y ys) = x y `HCons` zipWithHApL xs ys


mg = runState (runKleisli genRanking "A")
ms = runState (runKleisli stabilize "A")
-- zipWithHApL (mg :** ms :** Nil2) ([] `HCons` 1 `HCons` HNil)

data REnv :: [*] -> * -> * -> (* -> * -> *) -> ((* -> *) -> * -> * -> *) -> * where
  Last  :: k (s t) i o                      -> REnv (t ': '[]) i o s k
  RCons :: k (s t) i o' -> REnv ts o' o s k -> REnv (t ': ts) i o s k

-- instance HeterogeneousArrow (Kleisli (State s)) (Kleisli (State s')) (Kleisli [(State s), (State s')]) where
-- instance HeterogeneousArrow (Kleisli (State (HList s)))
--                             (Kleisli (State (HList s')))
--                             (Kleisli (State (HList (s ++ s')))) where
--     f >*> g = _ --Kleisli $ \e -> do
        -- (ir, is) <- get
        -- let (rv, rs) = runState (runKleisli f e) ir
        -- let (sv, ss) = runState (runKleisli g rv) is
        -- put (rs, ss)
        -- return sv

c :: (Kleisli (State (HList s))) a b 
  -> (Kleisli (State (HList s'))) b c
  -> (Kleisli (State (HList (s ++ s')))) a c
c f g = Kleisli $ \e -> do
        is <- get
        let (rv, rs) = runState (runKleisli f e) _
        let (sv, ss) = runState (runKleisli g rv) _
        put (rs, ss)
        return sv

-- fstV :: HList (s ++ s') -> HList s
-- fstV HNil = HNil
-- fstV x = _

type family   HSplit (ts :: [k]) (xs :: [k]) :: ([k], [k])
type instance HSplit ts xs = (xs, SndHSplit ts xs)

type family   SndHSplit (ts :: [k]) (xs :: [k]) :: [k]
type instance SndHSplit ts '[] = ts
type instance SndHSplit (t ': ts) (x ': xs) = SndHSplit ts xs

splitV :: HList (s ++ s') -> (HList s, HList s')
splitV = _

-- stabilize :: Kleisli (State Counter) a (Maybe a)
-- genRanking :: Kleisli (State Ranking) Ticket Ranking
-- stabilizedRanking' :: Ticket -> State (Ranking, Counter) (Maybe Ranking)
-- stabilizedRanking' e = do
--     (ir, is) <- get
--     let (rv, rs) = runState (runKleisli genRanking e) ir
--     let (sv, ss) = runState (runKleisli stabilize rv) is
--     put (rs, ss)
--     return sv
