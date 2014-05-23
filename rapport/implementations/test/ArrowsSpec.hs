module ThermometreSpec (main, spec) where

import Test.Hspec
import Arrows
import Data.Monoid

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
    describe "Given the constructor" $ do
        it "When it is initialized with the id function and we apply 3 Then it should be 3" $ do
            process (Node id) 3 `shouldBe` 3
