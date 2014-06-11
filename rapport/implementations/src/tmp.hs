{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies, FlexibleInstances, DataKinds, TypeOperators, KindSignatures, GADTs, ExplicitForAll, StandaloneDeriving, PolyKinds, TypeFamilies, ConstraintKinds, UndecidableInstances, RankNTypes #-}

data HList :: [*] -> * where
    HNil    :: HList '[]
    (:*)   :: t -> HList ts -> HList (t ': ts)

infixr 5 :*

data HApL :: [*] -> [*] -> * where
  Nil2  :: HApL '[] '[]
  (:**) :: (a -> b) -> HApL as bs -> HApL (a ': as) (b ': bs)

infixr 5 :**

zipWithE2 :: HApL xs ys -> HList xs -> HList ys
zipWithE2 Nil2       HNil      = HNil
zipWithE2 (x :** xs) (y :* ys) = x y :* zipWithE2 xs ys
