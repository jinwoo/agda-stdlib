------------------------------------------------------------------------
-- Code for converting Vec₁ n A -> B to and from n-ary functions
------------------------------------------------------------------------

-- I want universe polymorphism.

module Data.Vec.N-ary1 where

open import Data.Nat
open import Data.Vec1
open import Relation.Binary.PropositionalEquality1

------------------------------------------------------------------------
-- N-ary functions

N-ary : ℕ -> Set1 -> Set1 -> Set1
N-ary zero    A B = B
N-ary (suc n) A B = A -> N-ary n A B

------------------------------------------------------------------------
-- Conversion

curryⁿ : forall {n A B} -> (Vec₁ A n -> B) -> N-ary n A B
curryⁿ {zero}  f = f []
curryⁿ {suc n} f = \x -> curryⁿ (\xs -> f (x ∷ xs))

_$ⁿ_ : forall {n A B} -> N-ary n A B -> (Vec₁ A n -> B)
f $ⁿ []       = f
f $ⁿ (x ∷ xs) = f x $ⁿ xs

------------------------------------------------------------------------
-- N-ary function equality

Eq : forall {A B} n -> (B -> B -> Set1) -> (f g : N-ary n A B) -> Set1
Eq zero    _∼_ f g = f ∼ g
Eq (suc n) _∼_ f g = forall x -> Eq n _∼_ (f x) (g x)

------------------------------------------------------------------------
-- Some lemmas

-- The two functions are inverses.

left-inverse : forall {n A B} (f : Vec₁ A n -> B) ->
               forall xs -> curryⁿ f $ⁿ xs ≡₁ f xs
left-inverse f []       = ≡₁-refl
left-inverse f (x ∷ xs) = left-inverse (\xs -> f (x ∷ xs)) xs

data Lift {A : Set1} (R : A -> A -> Set) x y : Set1 where
  lift : R x y -> Lift R x y

right-inverse : forall {A B} n (f : N-ary n A B) ->
                Eq n (Lift _≡₁_) (curryⁿ (_$ⁿ_ {n} f)) f
right-inverse zero    f = lift ≡₁-refl
right-inverse (suc n) f = \x -> right-inverse n (f x)

-- Conversion preserves equality.

curryⁿ-pres : forall {n A B _∼_} (f g : Vec₁ A n -> B) ->
              (forall xs -> f xs ∼ g xs) ->
              Eq n _∼_ (curryⁿ f) (curryⁿ g)
curryⁿ-pres {zero}  f g hyp = hyp []
curryⁿ-pres {suc n} f g hyp = \x ->
  curryⁿ-pres (\xs -> f (x ∷ xs)) (\xs -> g (x ∷ xs))
              (\xs -> hyp (x ∷ xs))

curryⁿ-pres⁻¹ : forall {n A B _∼_} (f g : Vec₁ A n -> B) ->
                Eq n _∼_ (curryⁿ f) (curryⁿ g) ->
                forall xs -> f xs ∼ g xs
curryⁿ-pres⁻¹ f g hyp []       = hyp
curryⁿ-pres⁻¹ f g hyp (x ∷ xs) =
  curryⁿ-pres⁻¹ (\xs -> f (x ∷ xs)) (\xs -> g (x ∷ xs)) (hyp x) xs

appⁿ-pres : forall {n A B _∼_} (f g : N-ary n A B) ->
            Eq n _∼_ f g ->
            (xs : Vec₁ A n) -> (f $ⁿ xs) ∼ (g $ⁿ xs)
appⁿ-pres f g hyp []       = hyp
appⁿ-pres f g hyp (x ∷ xs) = appⁿ-pres (f x) (g x) (hyp x) xs

appⁿ-pres⁻¹ : forall {n A B _∼_} (f g : N-ary n A B) ->
              ((xs : Vec₁ A n) -> (f $ⁿ xs) ∼ (g $ⁿ xs)) ->
              Eq n _∼_ f g
appⁿ-pres⁻¹ {zero}  f g hyp = hyp []
appⁿ-pres⁻¹ {suc n} f g hyp = \x ->
  appⁿ-pres⁻¹ (f x) (g x) (\xs -> hyp (x ∷ xs))
