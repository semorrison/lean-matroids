import matroid.axioms  
import ftype.basic ftype.collections 

----------------------------------------------------------------
namespace ftype 

noncomputable theory 

section dual
variables {U : ftype}
 
lemma rank_empty {B : ftype} (M : rankfun B) :
  M.r ∅ = 0 :=
le_antisymm (calc M.r ∅ ≤ size (∅ : set B) : M.R1 ∅ ... = 0 : size_empty B) (M.R0 ∅)

-- Every matroid has a dual.
def dual :
  rankfun U → rankfun U :=
fun M, {
  r := (fun X, size X + M.r Xᶜ - M.r univ),
  R0 := (fun X,
    calc 0 ≤ M.r X  + M.r Xᶜ - M.r (X ∪ Xᶜ) - M.r (X ∩ Xᶜ) : by linarith [M.R3 X Xᶜ]
    ...    = M.r X  + M.r Xᶜ - M.r univ        - M.r ∅        : by rw [union_compl X, inter_compl X]
    ...    ≤ size X + M.r Xᶜ - M.r univ                       : by linarith [M.R1 X, rank_empty M]),
  R1 := (fun X, by {simp only, linarith [M.R2 _ _ (subset_univ Xᶜ)]}),
  R2 := (fun X Y h, let
    Z := Xᶜ ∩ Y,
    h₁ :=
      calc Yᶜ ∪ Z = (Xᶜ ∩ Y) ∪ Yᶜ        : by apply union_comm
      ...         = (Xᶜ ∪ Yᶜ) ∩ (Y ∪ Yᶜ) : by apply union_distrib_right
      ...         = (X ∩ Y)ᶜ ∩ univ         : by rw [compl_inter X Y, union_compl Y]
      ...         = (X ∩ Y)ᶜ             : by apply inter_univ
      ...         = Xᶜ                   : by rw [subset_def_inter_mp h],
    h₂ :=
      calc Yᶜ ∩ Z = (Xᶜ ∩ Y) ∩ Yᶜ : by apply inter_comm
      ...         = Xᶜ ∩ (Y ∩ Yᶜ) : by apply inter_assoc
      ...         = Xᶜ ∩ ∅        : by rw [inter_compl Y]
      ...         = ∅             : by apply inter_empty,
    h₃ :=
      calc M.r Xᶜ = M.r Xᶜ + M.r ∅              : by linarith [rank_empty M]
      ...         = M.r (Yᶜ ∪ Z) + M.r (Yᶜ ∩ Z) : by rw [h₁, h₂]
      ...         ≤ M.r Yᶜ + M.r Z              : by apply M.R3
      ...         ≤ M.r Yᶜ + size Z             : by linarith [M.R1 Z]
      ...         = M.r Yᶜ + size (Xᶜ ∩ Y)      : by refl
      ...         = M.r Yᶜ + size Y - size X    : by linarith [compl_inter_size_subset h]
    in by {simp only, linarith}),
  R3 := (fun X Y,
    calc  size (X ∪ Y) + M.r (X ∪ Y)ᶜ  - M.r univ + (size (X ∩ Y) + M.r (X ∩ Y)ᶜ  - M.r univ)
        = size (X ∪ Y) + M.r (Xᶜ ∩ Yᶜ) - M.r univ + (size (X ∩ Y) + M.r (Xᶜ ∪ Yᶜ) - M.r univ) : by rw [compl_union X Y, compl_inter X Y]
    ... ≤ size X       + M.r Xᶜ        - M.r univ + (size Y       + M.r Yᶜ        - M.r univ) : by linarith [size_modular X Y, M.R3 Xᶜ Yᶜ]),
}

-- The double dual of a matroid is itself.
lemma dual_dual (M : rankfun U) :
  dual (dual M) = M :=
begin
  apply rankfun.ext, apply funext, intro X, calc
  (dual (dual M)).r X = size X + (size Xᶜ + M.r Xᶜᶜ - M.r univ) - (size univ + M.r univᶜ - M.r univ) : rfl
  ...                 = size X + (size Xᶜ + M.r X   - M.r univ) - (size univ + M.r ∅  - M.r univ) : by rw [compl_compl, ftype.compl_univ]
  ...                 = M.r X                                                             : by linarith [size_compl X, rank_empty M]
end

lemma dual_inj {M₁ M₂ : rankfun U} :
  dual M₁ = dual M₂ → M₁ = M₂ := 
  λ h, by rw [←dual_dual M₁, ←dual_dual M₂, h]

lemma dual_r (M : rankfun U)(X : set U):
   (dual M).r X = size X + M.r Xᶜ - M.r univ := 
   rfl 

end /-section-/ dual

end ftype 