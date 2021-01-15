
import boolalg.basic boolalg.single 
open boolalg 

variables {U : boolalg}

section rank 

def satisfies_R0 : (U → ℤ) → Prop := 
  λ r, ∀ X, 0 ≤ r X 

def satisfies_R1 : (U → ℤ) → Prop := 
  λ r, ∀ X, r X ≤ size X

def satisfies_R2 : (U → ℤ) → Prop := 
  λ r, ∀ X Y, X ⊆ Y → r X ≤ r Y 

def satisfies_R3 : (U → ℤ) → Prop := 
  λ r, ∀ X Y, r (X ∪ Y) + r (X ∩ Y) ≤ r X + r Y

@[ext] structure rankfun (B : boolalg) :=
  (r : B → ℤ)
  (R0 : satisfies_R0 r)
  (R1 : satisfies_R1 r)
  (R2 : satisfies_R2 r)
  (R3 : satisfies_R3 r)

end rank 

section indep 

def satisfies_I1 : (U → Prop) → Prop := 
  λ indep, indep ⊥ 

def satisfies_I2 : (U → Prop) → Prop := 
  λ indep, ∀ I J: U, I ⊆ J → indep J → indep I

def satisfies_I3 : (U → Prop) → Prop := 
  λ indep, ∀ I J, size I < size J → indep I → indep J → ∃ e, e ∈ J \ I ∧ indep (I ∪ e)

@[ext] structure indep_family (U : boolalg):= 
  (indep : U → Prop)
  (I1 : satisfies_I1 indep)
  (I2 : satisfies_I2 indep)
  (I3 : satisfies_I3 indep)

end indep 

section cct 

def satisfies_C1 : (U → Prop) → Prop := 
  λ is_cct, ¬ is_cct ⊥ 

def satisfies_C2 : (U → Prop) → Prop := 
  λ is_cct, ∀ C₁ C₂, is_cct C₁ → is_cct C₂ → ¬(C₁ ⊂ C₂)

def satisfies_C3 : (U → Prop) → Prop := 
  λ is_cct, ∀ C₁ C₂ e, C₁ ≠ C₂ → is_cct C₁ → is_cct C₂ → e ∈ (C₁ ∩ C₂) → ∃ C₀ , is_cct C₀ ∧ C₀ ⊆ (C₁ ∪ C₂) \ e

@[ext] structure cct_family (U : boolalg) :=
  (cct : U → Prop)
  (C1 : satisfies_C1 cct)
  (C2 : satisfies_C2 cct)
  (C3 : satisfies_C3 cct)

end cct

section basis

def satisfies_B1 : (U → Prop) → Prop :=
  λ basis, ∃ B, basis B.

def satisfies_B2 : (U → Prop) → Prop  :=
  λ basis, ∀ B₁ B₂, basis B₁ → basis B₂ → ∀ b₁, b₁ ∈ B₁ \ B₂ → ∃ b₂, (b₂ ∈ B₂ \ B₁) ∧ basis (B₁ \ b₁ ∪ b₂) 

@[ext] structure basis_family (U : boolalg) :=
  (basis : U → Prop)
  (B1 : satisfies_B1 basis)
  (B2 : satisfies_B2 basis)

end basis 

section cl 

def satisfies_cl1 : (U → U) → Prop := 
  λ cl, ∀ X, X ⊆ cl X

def satisfies_cl2 : (U → U) → Prop := 
  λ cl, ∀ X, cl (cl X) = cl X

def satisfies_cl3 : (U → U) → Prop := 
  λ cl, ∀ X Y, X ⊆ Y → cl X ⊆ cl Y 

def satisfies_cl4 : (U → U) → Prop :=
  λ cl, ∀ (X : U) (e f : single U), (e ∈ cl (X ∪ f) \ X) → (f ∈ cl (X ∪ e) \ X)

structure clfun (U : boolalg) := 
  (cl : U → U)
  (cl1 : satisfies_cl1 cl)
  (cl2 : satisfies_cl2 cl)
  (cl3 : satisfies_cl3 cl)
  (cl4 : satisfies_cl4 cl)

end cl 