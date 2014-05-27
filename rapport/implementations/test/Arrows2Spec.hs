module Arrows2Spec (main, spec) where

import Test.Hspec
import Arrows2
import Data.Monoid

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
    describe "Given genRanking" $ do
        it "When inserting A should be A1" $ do
            processMany genRanking [] ["A"] `shouldBe` [Rank "A" 1]
        it "When inserting AA should be A2" $ do
            processMany genRanking [] ["A", "A"] `shouldBe` [Rank "A" 2]
        it "When inserting AAB should be A2B1" $ do
            processMany genRanking [] ["A", "A", "B"] `shouldBe` [Rank "A" 2, Rank "B" 1]
        it "When inserting BAA should be A2B1" $ do
            processMany genRanking [] ["B", "A", "A"] `shouldBe` [Rank "A" 2, Rank "B" 1]
        it "When inserting ABA should be A2B1" $ do
            processMany genRanking [] ["A", "B", "A"] `shouldBe` [Rank "A" 2, Rank "B" 1]

    describe "Given stabilize" $ do
        it "When inserting nothing should be []" $ do
            processManyLoop stabilize 0 ([] :: [String]) `shouldBe` []
        it "When inserting A should be []" $ do
            processManyLoop stabilize 0 ["A"] `shouldBe` []
        it "When inserting AB should be []" $ do
            processManyLoop stabilize 0 ["A", "B"] `shouldBe` []
        it "When inserting ABC should be [C]" $ do
            processManyLoop stabilize 0 ["A", "B", "C"] `shouldBe` ["C"]
        it "When inserting ABCD should be [C]" $ do
            processManyLoop stabilize 0 ["A", "B", "C", "D"] `shouldBe` ["C"]
        it "When inserting ABCDE should be [C]" $ do
            processManyLoop stabilize 0 ["A", "B", "C", "D", "E"] `shouldBe` ["C"]
        it "When inserting ABCDEF should be [CF]" $ do
            processManyLoop stabilize 0 ["A", "B", "C", "D", "E", "F"] `shouldBe` ["C", "F"]
        it "When inserting ABCDEFG should be [CF]" $ do
            processManyLoop stabilize 0 ["A", "B", "C", "D", "E", "F", "G"] `shouldBe` ["C", "F"]
