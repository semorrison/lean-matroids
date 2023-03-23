import .ncard
import .helpers 

-- noncomputable theory 
open_locale classical 
open_locale big_operators

open set 

variables {E : Type*}

/-- A predicate `P` on sets satisfies the exchange property if, for all `X` and `Y` satisfying `P`
  and all `a ∈ X \ Y`, there exists `b ∈ Y \ X` so that swapping `a` for `b` in `X` maintains `P`.-/
def exchange_property (P : set E → Prop) : Prop :=
  ∀ X Y, P X → P Y → ∀ a ∈ X \ Y, ∃ b ∈ Y \ X, P (insert b (X \ {a})) 

/-- A `matroid` is a nonempty collection of sets satisfying the exchange property. Each such set 
  is called a `base` of the matroid. -/
@[ext] structure matroid (E : Type*) :=
  (base : set E → Prop)
  (exists_base' : ∃ B, base B) 
  (base_exchange' : exchange_property base)

-- variables {B B' B₁ B₂ I I' J I₁ I₂ J' X Y Z : set E} {x y : E} {M : matroid E} 

namespace matroid 
/- None of these definitions require finiteness -/

section defs

/-- A set is independent if it is contained in a base.  -/
def indep (M : matroid E) (I : set E) : Prop := 
  ∃ B, M.base B ∧ I ⊆ B   

/-- A basis for a set `X` is a maximal independent subset of `X`
  (Often in the literature, the word 'basis' is used to refer to what we call a 'base')-/
def basis (M : matroid E) (I X : set E) : Prop := 
  M.indep I ∧ I ⊆ X ∧ ∀ J, M.indep J → I ⊆ J → J ⊆ X → I = J 

/-- A circuit is a minimal dependent set -/
def circuit (M : matroid E) (C : set E) : Prop := 
  ¬M.indep C ∧ ∀ I ⊂ C, M.indep I 

/-- A flat is a maximal set having a given basis  -/
def flat (M : matroid E) (F : set E) : Prop := 
  ∀ I X, M.basis I F → M.basis I X → X ⊆ F    

/-- The closure of a set is the intersection of the flats containing it -/
def cl (M : matroid E) (X : set E) : set E :=
  ⋂₀ {F | M.flat F ∧ X ⊆ F}

/-- A hyperplane is a maximal proper subflat -/
def hyperplane (M : matroid E) (H : set E) : Prop :=
  M.flat H ∧ H ⊂ univ ∧ (∀ F, H ⊂ F → M.flat F → F = univ)  

/-- A cocircuit is the complement of a hyperplane -/
def cocircuit (M : matroid E) (K : set E) : Prop := 
  M.hyperplane Kᶜ  

/-- A coindependent set is one that contains no cocircuit -/
def coindep (M : matroid E) (I : set E) : Prop := 
  ¬ ∃ K ⊆ I, M.cocircuit K     

/-- A loop is a singleton circuit -/
def loop (M : matroid E) (e : E) : Prop :=
  M.circuit {e}

/-- A coloop is an element contained in every basis -/
def coloop (M : matroid E) (e : E) : Prop :=
  ∀ B, M.base B → e ∈ B

  
end defs 

section base

variables {B B₁ B₂ I : set E} {M : matroid E} {e f x y : E}

lemma exists_base (M : matroid E) : ∃ B, M.base B := M.exists_base'

lemma base.exchange (hB₁ : M.base B₁) (hB₂ : M.base B₂) (hx : x ∈ B₁ \ B₂) : 
  ∃ y ∈ B₂ \ B₁, M.base (insert y (B₁ \ {x}))  :=
M.base_exchange' B₁ B₂ hB₁ hB₂ _ hx

lemma base.exchange_mem (hB₁ : M.base B₁) (hB₂ : M.base B₂) (hxB₁ : x ∈ B₁) (hxB₂ : x ∉ B₂) : 
  ∃ y, (y ∈ B₂ ∧ y ∉ B₁) ∧ M.base (insert y (B₁ \ {x})) := 
by simpa using hB₁.exchange hB₂ ⟨hxB₁, hxB₂⟩ 

variables [finite E]


lemma base.card_eq_card_of_base (hB₁ : M.base B₁) (hB₂ : M.base B₂) :
  B₁.ncard = B₂.ncard := 
begin
  suffices h : ∀ i B B', M.base B → M.base B' → (B' \ B).ncard ≤ i → 
    B'.ncard ≤ B.ncard, from 
      (h _ _ _ hB₂ hB₁ rfl.le).antisymm (h _ _ _ hB₁ hB₂ rfl.le), 
  clear hB₁ B₁ hB₂ B₂, 
  intro i, 
  induction i with i IH, 
  { rintros B B' - - h, 
    rw [le_zero_iff, ncard_eq_zero, diff_eq_empty] at h, 
    exact ncard_le_of_subset h, },  
  refine λ B B' hB hB' hcard, le_of_not_lt (λ hlt, _ ) , 
  obtain ⟨x, hxB', hxB⟩ := exists_mem_not_mem_of_ncard_lt_ncard hlt,  
  have := hB'.exchange hB ⟨hxB',hxB⟩,
  obtain ⟨y, hy, hB''⟩ := hB'.exchange hB ⟨hxB',hxB⟩, 

  have hcard := IH B (insert y (B' \ {x}))  hB (by simpa using hB'') _, 
  { apply hlt.not_le, 
    rwa [ncard_insert_of_not_mem, ncard_diff_singleton_add_one hxB'] at hcard,
    simpa using hy.2},
  
  suffices hss : (insert y (B' \ {x})) \ B ⊂ B' \ B, 
  { exact nat.le_of_lt_succ ((ncard_lt_ncard hss).trans_le hcard)},

  refine (ssubset_iff_of_subset (λ a, _) ).mpr ⟨x,  _⟩, 
  { rw [mem_diff, mem_insert_iff, and_imp, mem_diff_singleton],
    rintro (rfl | ⟨haB',hax⟩) haB,
    { exact (haB hy.1).elim}, 
    exact ⟨haB',haB⟩},
  
  rw [exists_prop, mem_diff, mem_diff, not_and, not_not_mem, mem_insert_iff, mem_diff, 
    mem_singleton_iff, ne_self_iff_false, and_false, or_false], 
  exact ⟨⟨hxB', hxB⟩, by {rintro rfl, exact hy.1}⟩, 
end 

lemma base.eq_of_subset_base (hB₁ : M.base B₁) (hB₂ : M.base B₂) (hB₁B₂ : B₁ ⊆ B₂) : 
  B₁ = B₂ :=
begin
  suffices : B₂ \ B₁ = ∅, from hB₁B₂.antisymm (diff_eq_empty.mp this),
  by_contra' h, 
  obtain ⟨e,he⟩ := set.nonempty_iff_ne_empty.mpr h, 
  obtain ⟨y,hy,-⟩:=  hB₂.exchange hB₁ he, 
  exact hy.2 (hB₁B₂ hy.1), 
end 

end base 

section iso 

variables {E₀ E₁ E₂ : Type*} {M₀ : matroid E₀} {M₁ : matroid E₁} {M₂ : matroid E₂}

def is_iso (M₁ : matroid E₁) (M₂ : matroid E₂) (e : E₁ ≃ E₂) := 
  ∀ B, M₁.base B ↔ M₂.base (e '' B)  

structure iso (M₁ : matroid E₁) (M₂ : matroid E₂) := 
(to_fun : E₁ ≃ E₂)
(on_base : ∀ B, M₁.base B ↔ M₂.base (to_fun '' B))

infix ` ≃i ` :75 :=  matroid.iso

instance : has_coe_to_fun (M₁ ≃i M₂) (λ _, E₁ → E₂) :=
  ⟨λ e, e.to_fun⟩  

def iso.refl (M : matroid E) : M ≃i M := ⟨equiv.refl E, λ B, by simp⟩   
def iso.symm (e : M₁ ≃i M₂) : M₂ ≃i M₁ := ⟨e.to_fun.symm, λ B, by {rw e.on_base, simp, }⟩  
-- def iso.trans (e₀₁ : M₀ ≃i M₁) (e₁₂ : M₁ ≃i M₂) : M₀ ≃i M₂ := 
--   ⟨e₀₁.to_fun.trans  e₁₂.to_fun, λ B, by {simp, }⟩ 




end iso 

end matroid 

-- TODO : prove strong basis exchange (and hence define duality) in this file. 

-- lemma base.indep (hB : M.base B) : 
--   M.indep B := 
-- sorry 

-- lemma base.insert_dep (hB : M.base B) (h : e ∉ B) : 
--   ¬M.indep (insert e B) := sorry  

-- lemma base_iff_maximal_indep : 
--   M.base B ↔ M.indep B ∧ ∀ I, M.indep I → B ⊆ I → B = I := 
-- sorry 

-- lemma indep.unique_circuit_of_insert {e : E} (hI : M.indep I) (hI' : ¬M.indep (insert e I)) : 
--   ∃! C, C ⊆ insert e I ∧ M.circuit C ∧ e ∈ C := sorry 

-- lemma subset_cl (M : matroid E) (X : set E) :
--   X ⊆ M.cl X := sorry  

-- -- lemma base_iff_indep_card :
-- --   M.base B ↔ M.indep B ∧ B.ncard =  

-- -- Strong exchange -- 

-- /-- We can exchange in both directions at one -/
-- theorem base.strong_exchange (hB₁ : M.base B₁) (hB₂ : M.base B₂) (hx : x ∈ B₁ \ B₂) :
--   ∃ y ∈ B₂ \ B₁, M.base (insert x (B₂ \ {y})) ∧ M.base (insert y (B₁ \ {x})) :=
-- begin
--   by_contra, 
--   simp_rw [not_exists, not_and] at h, 
  
--   obtain ⟨C, ⟨hCB₂,hC⟩, hCunique⟩ :=   
--   hB₂.indep.unique_circuit_of_insert (hB₂.insert_dep hx.2), 
  
--   have hCss := diff_singleton_subset_iff.mpr hCB₂, 

--   simp only [exists_unique_iff_exists, exists_prop, and_imp] at hCunique, 
--   have hC_exchange : ∀ y ∈ C \ {x}, M.base (insert x (B₂ \ {y})), 
--   { simp_rw [base_iff_maximal_indep], 
--     rintros y ⟨hyC, hyx⟩, 
--     refine ⟨by_contra (λ hdep, _ ), λ I hI hssI, by_contra (λ hne, _)⟩,  
--     { obtain ⟨C',⟨hC'ss,hC'⟩,hC'min⟩ := finite.exists_minimal 
--       (λ D, D ⊆ insert x (B₂ \ {y}) ∧ ¬M.indep D)  ⟨_, rfl.subset, hdep⟩,
--       have hC'C := hCunique C' _ ⟨hC',λ I hIC, by_contra (λ hI, _)⟩ (by_contra (λ hxC', hC' _)),
--       { subst hC'C, 
--         obtain (rfl | mem_diff) := mem_insert_iff.mp (hC'ss hyC), 
--         {exact hyx rfl},
--         exact not_mem_diff_of_mem rfl mem_diff}, 
--       { exact hC'ss.trans (insert_subset_insert (diff_subset _ _))},
--       { exact hIC.ne.symm (hC'min I ⟨ hIC.subset.trans hC'ss, hI⟩ hIC.subset)},
--       rw subset_insert_iff_of_not_mem hxC' at hC'ss, 
--       exact ⟨B₂, hB₂, hC'ss.trans (diff_subset _ _)⟩},
--     obtain ⟨B',hB',hB'I⟩ := hI,  
--     have hlt := (ncard_lt_ncard (hssI.ssubset_of_ne hne)).trans_le (ncard_le_of_subset hB'I), 
    
--     rw [hB'.card_eq_card_of_base hB₂, nat.lt_iff_add_one_le, 
--       ncard_exchange hx.2 (hCss (mem_diff_singleton.mpr ⟨hyC,hyx⟩))] at hlt,
--     simpa only [add_le_iff_nonpos_right, le_zero_iff] using hlt},
  
--   have hcl : ∀ y ∈ B₂ \ M.cl (B₁ \ {x}), M.base (insert y (B₁ \ {x})), 
--   { rintro y ⟨hy₂, hy₁⟩, 
--     obtain rfl | hyx := em (y = x), 
--     { rwa [insert_diff_singleton, insert_eq_self.mpr hx.1]},
--     have hyB₁ : y ∉ B₁, from 
--       λ hyB₁, hy₁ (M.subset_cl (B₁ \ {x}) (mem_diff_singleton.mpr ⟨hyB₁, hyx⟩)), 

--     rw base_iff_maximal_indep, 

--     -- simp_rw [base_iff_indep_card, indep_iff_r_eq_card, ncard_exchange hyB₁ hx.1, 
--     --   hB₁.card, eq_self_iff_true, and_true, ←hB₁.card, not_mem_cl.mp hy₁, 
--     --   (hB₁.indep.diff {x}).r, ncard_diff_singleton_add_one hx.1]
      
--       },

--   -- have hss : C \ {x} ⊆ M.cl (B₁ \ {x}), 
--   -- from λ y hy, by_contra (λ hy', h _ ⟨hCss hy, λ hy₁, hy' (M.subset_cl _ ⟨hy₁,hy.2⟩)⟩ 
--   --     (hC_exchange y hy) (hcl _ ⟨hCss hy,hy'⟩)), 
  
--   -- have hx' := (hC.1.subset_cl_diff_singleton _).trans (cl_subset_cl_of_subset_cl hss) hC.2, 
--   -- rw [mem_cl, insert_diff_singleton, insert_eq_of_mem hx.1, hB₁.indep.r, (hB₁.indep.diff _).r, 
--   --   ←ncard_diff_singleton_add_one hx.1] at hx', 
--   -- simpa only [nat.succ_ne_self] using hx', 
-- end     



