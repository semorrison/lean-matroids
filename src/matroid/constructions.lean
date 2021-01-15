
import boolalg.basic boolalg.induction boolalg.collections boolalg.examples 
import .rankfun .indep 

namespace boolalg 


section truncation 

noncomputable theory 

variables {U : boolalg}

def trunc.indep (M : indep_family U) {n : ℤ}(hn : 0 ≤ n) : U → Prop :=  
  λ X, M.indep X ∧ size X ≤ n

lemma trunc.I1 (M : indep_family U) {n : ℤ} (hn : 0 ≤ n): 
  satisfies_I1 (trunc.indep M hn) := 
  ⟨M.I1, by {rw size_bot, assumption}⟩

lemma trunc.I2 (M : indep_family U) {n : ℤ} (hn : 0 ≤ n) : 
  satisfies_I2 (trunc.indep M hn) := 
  λ I J hIJ hJ, ⟨M.I2 I J hIJ hJ.1, le_trans (size_monotone hIJ) hJ.2⟩ 

lemma trunc.I3 (M : indep_family U) {n : ℤ} (hn : 0 ≤ n): 
  satisfies_I3 (trunc.indep M hn) := 
begin
  intros I J hIJ hI hJ, 
  cases (M.I3 _ _ hIJ hI.1 hJ.1) with e he, 
  refine ⟨e, ⟨he.1, ⟨he.2,_ ⟩ ⟩⟩, 
  by_contra h_con, push_neg at h_con, 
  rw [(add_nonelem_size (elem_diff_iff.mp he.1).2)] at h_con, 
  linarith [int.le_of_lt_add_one h_con, hIJ, hJ.2], 
end

def truncate (M : rankfun U){n : ℤ}(hn : 0 ≤ n) : rankfun U := 
  let M_ind := rankfun_to_indep_family M in 
  indep_family_to_rankfun ⟨trunc.indep M_ind hn, trunc.I1 M_ind hn, trunc.I2 M_ind hn, trunc.I3 M_ind hn⟩

-- in retrospect it would probably have been easier to define truncation in terms of rank. This is at least possible though. 
lemma truncate_rank (M : rankfun U){n : ℤ}(hn : 0 ≤ n)(X : U) :
  (truncate M hn).r X = min n (M.r X) :=
begin
  apply indep.I_to_r_eq_iff.mpr, 
  unfold indep.is_set_basis trunc.indep rankfun_to_indep_family, 
  simp only [and_imp, not_and, not_le, ne.def, ssubset_iff], 
  cases exists_basis_of M X with B hB, 
  rw basis_of_iff_indep_full_rank at hB, 
  rcases hB with ⟨hBX, ⟨hBI, hBS⟩⟩, 
  by_cases n ≤ size B,
  rcases has_subset_of_size hn h with ⟨B₀,⟨hB₀,hB₀s⟩⟩, 
  rw hBS at h, 
  refine ⟨B₀, ⟨⟨_,⟨⟨I2 hB₀ hBI,(eq.symm hB₀s).ge⟩,λ J hBJ1 hBJ2 hJX hJind, _⟩⟩,by finish⟩⟩, 
  from subset_trans hB₀ hBX, 
  linarith [size_strict_monotone ⟨hBJ1, hBJ2⟩], 
  push_neg at h, 
  rw hBS at h, 
  refine ⟨B, ⟨⟨hBX,⟨⟨hBI,by linarith⟩,λ J hBJ1 hBJ2 hJX hJind, _⟩⟩,_⟩⟩, 
  rw indep_iff_r at hBI hJind, 
  linarith [R2 M hJX, R2 M hBJ1, size_strict_monotone ⟨hBJ1, hBJ2⟩], 
  have := le_of_lt h, 
  rw min_comm, 
  finish, 
end


section uniform


def free_matroid_on (U : boolalg): rankfun U := 
  { 
    r := size,
    R0 := size_nonneg,
    R1 := λ X, le_refl (size X),
    R2 := λ X Y hXY, size_monotone hXY,
    R3 := λ X Y, le_of_eq (size_modular X Y),  
  } 

lemma free_matroid_indep {U : boolalg}(X : U) :
  is_indep (free_matroid_on U) X  := 
  by rw [free_matroid_on, indep_iff_r]

lemma free_iff_top_indep {U : boolalg}{M : rankfun U}: 
   M = free_matroid_on U ↔ is_indep M ⊤ := 
begin
  refine ⟨λ h, _, λ h,_⟩, 
  rw [indep_iff_r,h], finish,  
  ext X, simp_rw [free_matroid_on, ←indep_iff_r, I2 (subset_top X) h], 
end


def loopy_matroid_on (U : boolalg) : rankfun U := 
  {
    r := λ X, 0, 
    R0 := λ X, le_refl 0, 
    R1 := λ X, size_nonneg X, 
    R2 := λ X Y hXY, le_refl 0, 
    R3 := λ X Y, rfl.ge
  }

def loopy_iff_top_rank_zero {U : boolalg}{M : rankfun U}:
  M = loopy_matroid_on U ↔ M.r ⊤ = 0 := 
begin
  refine ⟨λ h, by finish, λ h,_⟩,  
  ext X, simp_rw [loopy_matroid_on], 
  have := R2 M (subset_top X), 
  rw h at this, 
  linarith [R0 M X], 
end


def uniform_matroid_on (U : boolalg){r : ℤ}(hr : 0 ≤ r) : rankfun U := 
  truncate (free_matroid_on U) hr 

@[simp] lemma uniform_matroid_rank (U : boolalg)(X : U){r : ℤ}(hr : 0 ≤ r) :
  (uniform_matroid_on U hr).r X = min r (size X) := 
  by apply truncate_rank

lemma uniform_matroid_indep (U : boolalg)(X : U){r : ℤ}{hr : 0 ≤ r}  : 
  is_indep (uniform_matroid_on U hr) X ↔ size X ≤ r := 
  by {rw [indep_iff_r, uniform_matroid_rank], finish}

lemma uniform_dual (U : boolalg){r : ℤ}(hr : 0 ≤ r)(hrn : r ≤ size (⊤ : U)): 
  dual (uniform_matroid_on U hr) = uniform_matroid_on U (by linarith : 0 ≤ size (⊤ : U) - r) :=
begin
  ext X, 
  simp_rw [dual, uniform_matroid_rank, compl_size, min_eq_left hrn], 
  rw [←min_add_add_left, ←(min_sub_sub_right), min_comm], simp, 
end

def circuit_matroid_on {U : boolalg} (hU : nontrivial U) : rankfun U := 
  uniform_matroid_on U (by linarith [nontrivial_size hU] : 0 ≤ top_size U - 1)

@[simp] lemma circuit_matroid_rank {U : boolalg}(hU : nontrivial U)(X : U):
  (circuit_matroid_on hU).r X = min (size (⊤ : U) - 1) (size X) := 
  uniform_matroid_rank _ _ _ 

lemma circuit_matroid_iff_top_circuit {U : boolalg} (hU : nontrivial U){M : rankfun U}:
  M = circuit_matroid_on hU ↔ is_circuit M ⊤ := 
begin
  refine ⟨λ h, _, λ h, _⟩, 
  rw [circuit_iff_r, h], 
  simp_rw circuit_matroid_rank, 
  from ⟨min_eq_left (by linarith), λ Y hY, min_eq_right (by linarith [size_strict_monotone hY])⟩, 
  ext X, rw circuit_matroid_rank, 
  rw circuit_iff_r at h, 
  have h' : X ⊂ ⊤ ∨ X = ⊤ := _ , 
  cases h', 
  rw [h.2 X h', eq_comm], from min_eq_right (by linarith [size_strict_monotone h']), 
  rw [h', h.1, eq_comm], from min_eq_left (by linarith), 
  from subset_ssubset_or_eq (subset_top _), 
end


end uniform



end truncation 

section relax
variables {U : boolalg}[decidable_eq U] 

def relax.r (M : rankfun U)(C : U) : U → ℤ := 
  λ X, ite (X = C) (M.r X + 1) (M.r X)

lemma relax.r_of_C_eq_top {M : rankfun U}{C : U}(hC : is_circuit_hyperplane M C) :
  relax.r M C C = M.r ⊤ := 
  by {simp_rw [relax.r, if_pos rfl], linarith [circuit_hyperplane_rank hC]}

lemma relax.r_of_C {M : rankfun U}{C : U}(hC : is_circuit_hyperplane M C) :
  relax.r M C C = M.r C + 1 := 
  by {simp_rw [relax.r, if_pos rfl]}

lemma relax.r_of_not_C {M : rankfun U}{C X: U}(hC : is_circuit_hyperplane M C)(hXC : X ≠ C):
  relax.r M C X = M.r X := 
  by {unfold relax.r, finish}

lemma r_le_relax_r (M : rankfun U)(C X : U) :
  M.r X ≤ relax.r M C X := 
begin
  unfold relax.r, by_cases X = C, 
  rw if_pos h, linarith, 
  rw if_neg h,
end

lemma relax.r_le_top {M : rankfun U}{C : U}(hC : is_circuit_hyperplane M C)(X : U):
  relax.r M C X ≤ M.r ⊤ := 
begin
  by_cases h : X = C, 
  rw [h, relax.r_of_C hC, circuit_hyperplane_rank hC], linarith, 
  rw [relax.r_of_not_C hC h], apply rank_le_top, 
end 


lemma relax.R0 (M : rankfun U)(C : U) : 
  satisfies_R0 (relax.r M C) := 
  λ X, le_trans (M.R0 X) (r_le_relax_r M C X)

lemma relax.R1 {M : rankfun U}{C : U}(hC : is_circuit_hyperplane M C) : 
  satisfies_R1 (relax.r M C) := 
begin
  intro X, unfold relax.r, by_cases h : X = C, 
  rw if_pos h, 
  rcases hC with ⟨h₁,h₂⟩, 
  rw circuit_iff_r at h₁, 
  rw h, linarith,  
  rw if_neg h, 
  from M.R1 X, 
end

lemma relax.R2 {M : rankfun U}{C : U}(hC : is_circuit_hyperplane M C) : 
  satisfies_R2 (relax.r M C) :=
begin
  intros X Y hXY,
  by_cases h: X = C, 
  rw [h, relax.r_of_C_eq_top hC], 
  rw h at hXY, 
  cases subset_ssubset_or_eq hXY with h' h',
  linarith [circuit_hyperplane_ssupset_rank hC h', relax.r_of_not_C hC (h'.2.symm)],
  rw [←h', relax.r_of_C_eq_top], from hC, 
  linarith [relax.r_of_not_C hC h, r_le_relax_r M C Y, R2 M hXY],  
end

lemma relax.R3 {M : rankfun U}{C : U}(hC : is_circuit_hyperplane M C) : 
  satisfies_R3 (relax.r M C) :=
begin
  intros X Y, 
  by_cases hi : X ∩ Y = C;
  by_cases hu : X ∪ Y = C, 
  simp only [ eq_of_union_eq_inter (eq.trans hu hi.symm), inter_idem, union_idem], 
  rw hi, 
  have hCY : C ⊆ Y := by {rw ← hi, apply inter_subset_right},
  have hCX : C ⊆ X := by {rw ← hi, apply inter_subset_left},
  by_cases hX: X = C; by_cases hY: Y = C, 
  rw [hX, hY, union_idem] at hu, 
  from false.elim (hu rfl), 
  rw [relax.r_of_not_C hC hu, relax.r_of_not_C hC hY, hX],
  linarith [rank_le_top M (C ∪ Y), circuit_hyperplane_ssupset_rank hC ⟨hCY, ne.symm hY⟩], 
  rw [relax.r_of_not_C hC hu, relax.r_of_not_C hC hX, hY],
  linarith [rank_le_top M (X ∪ C), circuit_hyperplane_ssupset_rank hC ⟨hCX, ne.symm hX⟩], 
  rw [relax.r_of_not_C hC hX, relax.r_of_not_C hC hY, 
        circuit_hyperplane_ssupset_rank hC ⟨hCX, ne.symm hX⟩, circuit_hyperplane_ssupset_rank hC ⟨hCY, ne.symm hY⟩] ,
  linarith [relax.r_le_top hC (X ∪ Y), relax.r_le_top hC C], 
  by_cases hX : X = C; by_cases hY : Y = C, 
  rw [hu, hX, hY, inter_idem], 
  rw [hu, hX], linarith [relax.R2 hC _ _ (inter_subset_right C Y)], 
  rw [hu, hY], linarith [relax.R2 hC _ _ (inter_subset_left X C)], 
  have hXC : X ⊂ C := ⟨by {rw ←hu, apply subset_union_left},hX⟩,
  have hYC : Y ⊂ C := ⟨by {rw ←hu, apply subset_union_right},hY⟩,
  have hXY : X ∩ Y ⊂ C := inter_of_ssubsets _ _ _ hXC , 
  rw [relax.r_of_not_C hC hX, relax.r_of_not_C hC hY, relax.r_of_not_C hC hi, hu, relax.r_of_C hC, circuit_hyperplane_rank_size hC],
  rw [← hu, circuit_hyperplane_ssubset_rank hC hXC, circuit_hyperplane_ssubset_rank hC hYC, circuit_hyperplane_ssubset_rank hC hXY],
  linarith [size_modular X Y],
  rw [relax.r_of_not_C hC hi, relax.r_of_not_C hC hu], 
  linarith [r_le_relax_r M C X, r_le_relax_r M C Y, M.R3 X Y], 
end

def relax (M : rankfun U)(C : U)(hC : is_circuit_hyperplane M C) : rankfun U := 
  ⟨relax.r M C, relax.R0 M C, relax.R1 hC, relax.R2 hC, relax.R3 hC⟩ 

theorem relax.dual {M : rankfun U}{C : U}(hC : is_circuit_hyperplane M C) :
  dual (relax M C hC) = relax (dual M) Cᶜ (circuit_hyperplane_dual.mp hC) := 
let hCc := circuit_hyperplane_dual.mp hC in 
begin
  ext X, 
  have hCtop : ⊤ ≠ C := λ h, 
    by {have := circuit_hyperplane_rank hC, rw ←h at this, linarith}, 
  by_cases h : X = Cᶜ,   
  simp_rw [dual_r, h, compl_compl, relax, relax.r_of_C hC, relax.r_of_C hCc],
  rw [dual_r, compl_compl, relax.r_of_not_C hC hCtop], linarith, 
  have h' : Xᶜ ≠ C := λ hcon, by {rw [←hcon, compl_compl] at h, finish}, 
  simp_rw [relax, dual_r, relax.r_of_not_C hCc h, relax.r_of_not_C hC h', dual_r],
  rw relax.r_of_not_C hC hCtop,  
end

theorem single_rank_disagreement_is_relaxation {M₁ M₂ : rankfun U}{X : U}: 
  M₁.r ⊤ = M₂.r ⊤ → M₁.r X < M₂.r X → (∀ Y, Y ≠ X → M₁.r Y = M₂.r Y) → ∃ h : is_circuit_hyperplane M₁ X, M₂ = relax M₁ X h :=
begin
  intros hr hX h_other, 
  have hne : M₁ ≠ M₂ := λ h, by {rw h at hX, from lt_irrefl _ hX },
  cases circuit_ind_of_distinct hne with X' hX', 
  have hXX' : X' = X := by
  {
    by_contra hXX', 
    simp_rw [circuit_iff_r, indep_iff_r] at hX', 
    cases hX';
    linarith [h_other _ hXX'], 
  },
  simp_rw hXX' at hX', 
  have : is_circuit M₁ X ∧ is_indep M₂ X := by 
  {
    cases hX', assumption, 
    simp_rw [circuit_iff_r, indep_iff_r] at hX', 
    linarith, 
  },
  cases this with hXcct hXind, 
  have hdne : dual M₁ ≠ dual M₂ := λ heq, hne (dual_inj heq), 
  cases circuit_ind_of_distinct hdne with Z hZ, 
  have hXZ : Zᶜ = X := by 
  {
    by_contra hXZ, 
    repeat {rw [←is_cocircuit] at hZ}, 
    simp_rw [cocircuit_iff_r, coindep_iff_r] at hZ,
    cases hZ;
    linarith [h_other _ hXZ], 
  },
  have : is_circuit (dual M₁) Z ∧ is_indep (dual M₂) Z := by 
  {
    cases hZ, 
    assumption, 
    rw [←is_cocircuit, cocircuit_iff_r, coindep_iff_r, hXZ] at hZ, 
    linarith,   
  },
  rw (compl_pair hXZ) at this, 
  cases this with hXhp _, 
  rw [←is_cocircuit, cocircuit_iff_compl_hyperplane, compl_compl] at hXhp,
  let hch : is_circuit_hyperplane M₁ X := ⟨hXcct, hXhp⟩, 
  use hch,
  ext Y,
  by_cases hYX : Y = X,   
  simp_rw [hYX, relax, relax.r_of_C hch],   
  linarith [r_cct hXcct, r_indep hXind], 
  simp_rw [relax, relax.r_of_not_C hch hYX, eq_comm],
  from h_other Y hYX,  
end

lemma single_rank_disagreement_top (hU : nontrivial U){M₁ M₂ : rankfun U}:
   M₁.r ⊤ < M₂.r ⊤ → (∀ X, X ≠ ⊤ → M₁.r X = M₂.r X) → M₁ = circuit_matroid_on hU ∧ M₂ = free_matroid_on U  := 
begin
  intros htop hother, 
  rw [circuit_matroid_iff_top_circuit, free_iff_top_indep], 
  have hM₁M₂ : M₁ ≠ M₂ := λ h, by {rw h at htop, from lt_irrefl _ htop}, 
  cases circuit_ind_of_distinct hM₁M₂ with Z hZ, 
  by_cases Z = ⊤; cases hZ, 
  rw h at hZ, assumption, 
  rw [h,circuit_iff_r, indep_iff_r] at hZ, linarith,
  rw [circuit_iff_r, indep_iff_r] at hZ, linarith [hother Z h], 
  rw [circuit_iff_r, indep_iff_r] at hZ, linarith [hother Z h], 
end

end relax 



end boolalg 