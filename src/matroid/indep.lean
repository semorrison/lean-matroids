import .matroid 


variables {E : Type*} [finite E] {M : matroid E} {I J I' J' I₁ I₂ B B' X Y : set E} {e f : E}

open set
namespace matroid 

section indep 

lemma indep_iff_subset_base :
  M.indep I ↔ ∃ B, M.base B ∧ I ⊆ B :=
iff.rfl 

lemma empty_indep (M : matroid E) : M.indep ∅ := 
  exists.elim M.exists_base (λ B hB, ⟨_, hB, B.empty_subset⟩)

lemma indep_mono {M : matroid E} {I J : set E} (hIJ : I ⊆ J) (hJ : M.indep J) : M.indep I :=
by {obtain ⟨B, hB, hJB⟩ := hJ, exact ⟨B, hB, hIJ.trans hJB⟩}

lemma indep.exists_base_supset (hI : M.indep I) : 
  ∃ B, M.base B ∧ I ⊆ B :=
hI  

lemma indep.subset (hJ : M.indep J) (hIJ : I ⊆ J) : M.indep I :=
by {obtain ⟨B, hB, hJB⟩ := hJ, exact ⟨B, hB, hIJ.trans hJB⟩}

lemma indep.inter_right (hI : M.indep I) (X : set E) : 
  M.indep (I ∩ X) :=
hI.subset (inter_subset_left _ _)

lemma indep.inter_left (hI : M.indep I) (X : set E) : 
  M.indep (X ∩ I) :=
hI.subset (inter_subset_right _ _)

lemma indep.diff (hI : M.indep I) (X : set E) :
  M.indep (I \ X) :=
hI.subset (diff_subset _ _)

/-- The independence augmentation axiom; given independent sets `I,J` with `I` smaller than `J`, 
  there is an element `e` of `J \ I` whose insertion into `e` is an independent set.  -/
lemma indep.augment (hI : M.indep I) (hJ : M.indep J) (hIJ : I.ncard < J.ncard) : 
  ∃ x ∈ J, x ∉ I ∧ M.indep (insert x I) :=
begin
  suffices h_mod : ∀ {p} {I₁ I₂ B₁ B₂}, M.base B₁ → M.base B₂ → I₁ ⊆ B₁ → I₂ ⊆ B₂ →
    I₁.ncard < I₂.ncard → (B₂ \ (I₂ ∪ B₁)).ncard = p → ∃ x ∈ I₂, x ∉ I₁ ∧ M.indep (insert x I₁), 
  { obtain ⟨⟨BI,hBI,hIBI⟩,⟨BJ, hBJ, hJBJ⟩⟩ := ⟨hI,hJ⟩,
    exact h_mod hBI hBJ hIBI hJBJ hIJ rfl },         
  clear hI hJ hIJ I J,
  intro p, induction p with p IH, 
  all_goals 
  { intros _ _ _ _ hB₁ hB₂ hI₁B₁ hI₂B₂ h_lt h_le} , 
  { rw [ncard_eq_zero, diff_eq_empty] at h_le, 
    by_contra' h_con, 
    apply h_lt.not_le, 
    have h₁₂ : B₂ \ B₁ = I₂ \ I₁, 
    { apply subset_antisymm, 
      {  calc _ ⊆ _  : diff_subset_diff_left h_le  
            ... = _  : union_diff_right
             ... ⊆ _ : diff_subset_diff_right hI₁B₁}, 
      rintros x ⟨hxI₂, hxI₁⟩,  
      exact ⟨mem_of_mem_of_subset hxI₂ hI₂B₂, 
        λ hxB₁, h_con _ hxI₂ hxI₁ ⟨B₁, hB₁, insert_subset.mpr ⟨ hxB₁,hI₁B₁⟩⟩⟩}, 

    have hB₁ss : B₁ ⊆ I₁ ∪ B₂,
    { intros y hyB₁, 
      rw [mem_union, or_iff_not_imp_right],   
      intro hyB₂, 
      obtain ⟨x,hx, hB'⟩ := hB₁.exchange hB₂ ⟨hyB₁, hyB₂⟩,  
      obtain (hxI₂ | hxB₁') := mem_of_mem_of_subset hx.1 h_le, 
      swap, exact (hx.2 hxB₁').elim,
      by_contradiction hyI₁, 
      refine h_con x hxI₂ (not_mem_subset hI₁B₁ hx.2) 
        ⟨_, hB', insert_subset.mpr ⟨by simp, subset_trans _ (subset_insert _ _)⟩⟩,  
      apply subset_diff_singleton hI₁B₁ hyI₁},
    have hss₁ := calc B₁ \ B₂ ⊆ _       : diff_subset_diff_left hB₁ss  
                          ... = _       : union_diff_right
                          ... ⊆ I₁ \ I₂ : diff_subset_diff_right hI₂B₂,   


    have hle₁ := ncard_le_of_subset hss₁, 
    
    rwa [(ncard_eq_ncard_iff_ncard_diff_eq_ncard_diff (to_finite _) (to_finite _)).mp 
      (hB₁.card_eq_card_of_base hB₂), h₁₂, ← ncard_le_ncard_iff_ncard_diff_le_ncard_diff] at hle₁,
    
    -- , h₁₂, 
    --   ← ncard_le_ncard_iff_ncard_diff_le_ncard_diff] at hle₁
      
      },
  have h_ne : (B₂ \ (I₂ ∪ B₁)).nonempty, 
  { rw [←ncard_pos, h_le], apply nat.succ_pos _},
  obtain ⟨x, hxB₂, hx'⟩ := h_ne, 
  rw [set.mem_union, not_or_distrib] at hx', obtain ⟨hxI₂, hxB₁⟩:= hx',  
  obtain ⟨y, ⟨hyB₁, hyB₂⟩, hB'⟩ := hB₂.exchange hB₁ ⟨hxB₂,hxB₁⟩,  
  have hI₂B' : I₂ ⊆ insert y (B₂ \ {x}), 
  { rw ←union_singleton,  
    apply set.subset_union_of_subset_left, apply subset_diff_singleton hI₂B₂ hxI₂},

  
  refine IH hB₁ hB' hI₁B₁ hI₂B' h_lt _, 
  suffices h_set_eq : (insert y (B₂ \ {x})) \ (I₂ ∪ B₁) = (B₂ \ (I₂ ∪ B₁)) \ {x},   
  { rw [←nat.succ_inj', h_set_eq, ←h_le, nat.succ_eq_add_one, ncard_diff_singleton_add_one], 
    exact ⟨hxB₂, not_or hxI₂ hxB₁⟩},
  rw [insert_diff_of_mem _ (mem_union_right _ hyB₁)],
  rw [diff_diff_comm], 
end 

/-- The independence augmentation axiom in a form that finds a strict superset -/
lemma indep.ssubset_indep_of_card_lt (hI : M.indep I) (hJ : M.indep J) (hIJ : I.ncard < J.ncard) :
  ∃ I', M.indep I' ∧ I ⊂ I' ∧ I' ⊆ I ∪ J := 
begin
  obtain ⟨e, heJ, heI, hI'⟩ := hI.augment hJ hIJ, 
  exact ⟨_, hI', ssubset_insert heI, insert_subset.mpr ⟨or.inr heJ,subset_union_left _ _⟩⟩,  
end 

lemma base.indep (hB : M.base B) : M.indep B := ⟨B, hB, subset_rfl⟩ 

lemma base.eq_of_subset_indep (hB : M.base B) (hI : M.indep I) (hBI : B ⊆ I) : 
  B = I :=
begin
  apply eq_of_subset_of_ncard_le hBI, 
  obtain ⟨B', hB', hIB'⟩ := hI, 
  rw hB.card_eq_card_of_base hB', 
  exact ncard_le_of_subset hIB', 
end 

lemma base_iff_maximal_indep : 
  M.base B ↔ M.indep B ∧ ∀ I, M.indep I → B ⊆ I → B = I :=
begin
  refine ⟨λ h, ⟨h.indep, λ _, h.eq_of_subset_indep ⟩,λ h, _⟩, 
  obtain ⟨⟨B', hB', hBB'⟩, h⟩ := h, 
  rwa h _ hB'.indep hBB', 
end  

lemma base.dep_of_ssubset (hB : M.base B) (h : B ⊂ X) : 
  ¬M.indep X := 
λ hX, h.ne (hB.eq_of_subset_indep hX h.subset)  

lemma base.dep_of_insert (hB : M.base B) (he : e ∉ B) :
  ¬M.indep (insert e B) := 
hB.dep_of_ssubset (ssubset_insert he)

lemma indep_not_base : 
  M.base B → M.indep B' → B' ⊂ B → ¬ M.base B' :=
begin
  intros hB hB' hBB',
    by_contra,
    apply (ne_of_ssubset hBB') (base.eq_of_subset_base h hB (subset_of_ssubset hBB')),
end

/- This proof deliberately avoids cardinality -/
lemma base.exchange_base_of_indep (hB : M.base B) (he : e ∈ B) (hf : f ∉ B) 
(hI : M.indep (insert f (B \ {e}))) : 
  M.base (insert f (B \ {e})) :=
begin
  obtain ⟨B', hB', hIB'⟩ := hI,  
  have hBeB' := (subset_insert _ _).trans hIB', 
  have heB' : e ∉ B',
  { intro heB', 
    have hBB' : B ⊆ B',
    { refine subset_trans _ (insert_subset.mpr ⟨heB',hIB'⟩),   
      rw [insert_comm, insert_diff_singleton],
      refine (subset_insert _ _).trans (subset_insert _ _)},
    rw ←hB.eq_of_subset_indep hB'.indep hBB' at hIB',
    exact hf (hIB' (mem_insert _ _))},
  obtain ⟨y,hy,hy'⟩ := hB.exchange hB' ⟨he,heB'⟩,
  rw ←hy'.eq_of_subset_base hB' (insert_subset.mpr ⟨hy.1, hBeB'⟩) at hIB', 
  have : f = y, 
  { exact (mem_insert_iff.mp (hIB' (mem_insert _ _))).elim id 
      (λ h', (hf (diff_subset _ _ h')).elim)},
  rwa this, 
end 

lemma indep_not_base_ssubset : M.indep B' → ¬ M.base B' → ∃ (B : set E), M.base B ∧ B' ⊂ B :=
begin
  intros hB' hBn',
  rw indep_iff_subset_base at hB',
  rcases hB' with ⟨B, ⟨hB1, hB2⟩⟩,
  use B,
  refine ⟨hB1, _⟩,
  apply ssubset_of_ne_of_subset _ hB2,
  by_contra,
  apply hBn',
  rw ← h at hB1,
  exact hB1,  
end

lemma base_of_ncard_eq_indep : M.base B → M.indep B' ∧ B'.ncard = B.ncard → M.base B' :=
begin
  rintros hB ⟨hB', hBB'⟩,
  by_contra,
  rcases indep_not_base_ssubset hB' h with ⟨B2, ⟨hB21, hB22⟩⟩,
  have h2 := ncard_lt_ncard hB22,
  rw hBB' at h2,
  apply ne_of_lt h2,
  exact base.card_eq_card_of_base hB hB21,
end

lemma base.insert_dep (hB : M.base B) (h : e ∉ B) : ¬ M.indep (insert e B) :=
  λ h', (insert_ne_self.mpr h).symm ((base_iff_maximal_indep.mp hB).2 _ h' (subset_insert _ _)) 

lemma base.ssubset_dep (hB : M.base B) (h : B ⊂ X) : ¬ M.indep X :=
  λ h', h.ne ((base_iff_maximal_indep.mp hB).2 _ h' h.subset) 
  
lemma eq_of_indep_iff_indep_forall {M₁ M₂ : matroid E} (h : ∀ I, (M₁.indep I ↔ M₂.indep I)) : 
  M₁ = M₂ := 
begin
  ext B,
  have hI : M₁.indep = M₂.indep, by { ext ,apply h},
  simp_rw [base_iff_maximal_indep, hI],  
end 

end indep 

section basis

lemma basis.indep (hI : M.basis I X) : M.indep I := hI.1

lemma basis.subset (hI : M.basis I X) : I ⊆ X := hI.2.1

lemma basis_iff : 
  M.basis I X ↔ M.indep I ∧ I ⊆ X ∧ ∀ J, M.indep J → I ⊆ J → J ⊆ X → I = J := 
iff.rfl 

lemma basis.eq_of_subset_indep (hI : M.basis I X) {J : set E} (hJ : M.indep J) (hIJ : I ⊆ J) 
(hJX : J ⊆ X) : 
  I = J := 
hI.2.2 J hJ hIJ hJX

lemma basis.basis_subset (hI : M.basis I X) (hIY : I ⊆ Y) (hYX : Y ⊆ X) : 
  M.basis I Y :=
⟨hI.indep, hIY, λ J hJ hIJ hJY, hI.eq_of_subset_indep hJ hIJ (hJY.trans hYX)⟩
  
lemma basis.dep_of_ssubset (hI : M.basis I X) {Y : set E} (hIY : I ⊂ Y) (hYX : Y ⊆ X) :
  ¬ M.indep Y :=
λ hY, hIY.ne (hI.eq_of_subset_indep hY hIY.subset hYX)

lemma basis.insert_dep (hI : M.basis I X) (he : e ∈ X \ I) : 
  ¬M.indep (insert e I) :=
hI.dep_of_ssubset (ssubset_insert he.2) (insert_subset.mpr ⟨he.1,hI.subset⟩)

lemma basis.not_basis_of_ssubset (hI : M.basis I X) (hJI : J ⊂ I) :
  ¬ M.basis J X :=
λ h, hJI.ne (h.eq_of_subset_indep hI.indep hJI.subset hI.subset)

lemma indep.subset_basis_of_subset (hI : M.indep I) (hIX : I ⊆ X) : 
  ∃ J, I ⊆ J ∧ M.basis J X := 
begin
  obtain ⟨J, ⟨hJ,hIJ,hJX⟩, hJmax⟩ := finite.exists_maximal (λ J, M.indep J ∧ I ⊆ J ∧ J ⊆ X) 
    ⟨I, hI, rfl.subset, hIX⟩,  
  exact ⟨J, hIJ, hJ, hJX, λ K hK hJK hKX, hJmax K ⟨hK, hIJ.trans hJK, hKX⟩ hJK⟩, 
end 

lemma indep.le_card_basis (hI : M.indep I) (hIX : I ⊆ X) (hJX : M.basis J X) : 
  I.ncard ≤ J.ncard :=
begin
  refine le_of_not_lt (λ hlt, _), 
  obtain ⟨I', hI'⟩ := hJX.indep.ssubset_indep_of_card_lt hI hlt, 
  have := hJX.eq_of_subset_indep hI'.1 hI'.2.1.subset (hI'.2.2.trans (union_subset hJX.subset hIX)),
  subst this, 
  exact hI'.2.1.ne rfl, 
end 

lemma indep.eq_of_basis (hI : M.indep I) (hJ : M.basis J I) :
  J = I :=
hJ.eq_of_subset_indep hI hJ.subset subset.rfl

lemma indep.basis_self (hI : M.indep I) :
  M.basis I I :=
⟨hI, rfl.subset, λ J hJ, subset_antisymm⟩  

lemma exists_basis (M : matroid E) (X : set E) : 
  ∃ I, M.basis I X :=
by {obtain ⟨I, -, hI⟩ := M.empty_indep.subset_basis_of_subset (empty_subset X), exact ⟨_,hI⟩, }

lemma basis.exists_base (hI : M.basis I X) : 
  ∃ B, M.base B ∧ I = B ∩ X :=
begin
  obtain ⟨B,hB, hIB⟩ := hI.indep,   
  refine ⟨B, hB, subset_antisymm (subset_inter hIB hI.subset) _⟩,  
  rw hI.eq_of_subset_indep (hB.indep.inter_right X) (subset_inter hIB hI.subset)
    (inter_subset_right _ _), 
end   

lemma basis_iff_base_inter :
  M.basis I X ↔ ∃ B, M.base B ∧ I = B ∩ X ∧ 
    ∀ B', M.base B' → B ∩ X ⊆ B' ∩ X → B ∩ X = B' ∩ X :=
begin
  refine ⟨λ h, _,_⟩,   
  { obtain ⟨B,hB,rfl⟩ := h.exists_base, 
    refine ⟨B,hB,rfl,λ B' hB' hss, 
      h.eq_of_subset_indep (hB'.indep.inter_right X) hss (inter_subset_right _ _)⟩},
  rintros ⟨B,hB,rfl,hBmax⟩, 
  refine ⟨hB.indep.inter_right X, inter_subset_right _ _, _⟩,   
  rintros J ⟨B',hB',hB'J⟩ hBXJ hJX , 
  refine hBXJ.antisymm _, 
  rw hBmax B' hB' (subset_inter (hBXJ.trans hB'J) (inter_subset_right _ _)), 
  exact subset_inter hB'J hJX,
end  

lemma base_iff_basis_univ : 
  M.base B ↔ M.basis B univ := 
by {rw [base_iff_maximal_indep, basis], simp}

lemma base.basis_univ (hB : M.base B) : 
  M.basis B univ := 
base_iff_basis_univ.mp hB 

end basis

end matroid

section from_axioms 

/-- A collection of sets satisfying the independence axioms determines a matroid -/
def matroid_of_indep (indep : set E → Prop) 
(exists_ind : ∃ I, indep I)
(ind_mono : ∀ I J, I ⊆ J → indep J → indep I)
(ind_aug : ∀ I J, indep I → indep J → I.ncard < J.ncard →
  ∃ e ∈ J, e ∉ I ∧ indep (insert e I)) : 
  matroid E :=
{ base := λ B, indep B ∧ ∀ X, indep X → B ⊆ X → X = B,
  exists_base' := 
    by exact 
      (@set.finite.exists_maximal_wrt (set E) (set E) _ id indep (to_finite _) exists_ind).imp 
      (λ B hB, exists.elim hB (λ hB h, ⟨hB, λ X hX hBX, (h X hX hBX).symm⟩)), 
  base_exchange' := 
  begin  
    set is_base := λ (B : set E), indep B ∧ ∀ X, indep X → B ⊆ X → X = B with hbase, 
    rintro B₁ B₂ hB₁ hB₂ x ⟨hxB₁,hxB₂⟩,

    have h_base_iff : ∀ B B' (hB' : is_base B'),
      is_base B ↔ indep B ∧ B'.ncard ≤ B.ncard, 
    { intros B B' hB', split, 
      { refine λ hB, ⟨hB.1, le_of_not_lt (λ hlt, _)⟩, 
        obtain ⟨e,heB,heB',he⟩ := ind_aug B B' hB.1 hB'.1 hlt, 
        exact heB' (by simpa using hB.2 _ he (subset_insert _ _))},  
      rintros ⟨hBI, hB'B⟩ , 
      refine ⟨hBI, λ J hJ hBJ, (hBJ.antisymm (by_contra (λhJB, _))).symm⟩, 
      have hss := ssubset_of_subset_not_subset hBJ hJB, 
      obtain ⟨e,heJ,heB',he⟩ := 
        ind_aug B' J hB'.1 hJ (hB'B.trans_lt (ncard_lt_ncard hss)), 
      exact heB' (by simpa using hB'.2 _ he (subset_insert _ _))},
    
    simp_rw [h_base_iff _ _ hB₁, mem_diff], 
    have hcard : (B₁ \ {x}).ncard < B₂.ncard, 
    { rw [nat.lt_iff_add_one_le, ncard_diff_singleton_add_one hxB₁],
      exact ((h_base_iff _ _ hB₁).mp hB₂).2},

    obtain ⟨e,heB₂,heB₁x,he⟩ := 
      ind_aug (B₁ \ {x}) B₂ (ind_mono _ _ (diff_subset _ _) hB₁.1) hB₂.1 hcard, 
    have hex : e ≠ x := by {rintro rfl, exact hxB₂ heB₂},  
    have heB₁ : e ∉ B₁, 
    { simp only [mem_diff, mem_singleton_iff, not_and, not_not] at heB₁x,
      exact λ h', hex (heB₁x h')},
    
    refine ⟨e,⟨heB₂,heB₁⟩,he,_⟩, 
    rwa [ncard_insert_of_not_mem heB₁x, ncard_diff_singleton_add_one], 
  end  }

@[simp] lemma matroid_of_indep_base_iff {indep : set E → Prop} 
  (exists_ind : ∃ I, indep I)
  (ind_mono : ∀ I J, I ⊆ J → indep J → indep I)
  (ind_aug : ∀ I J, indep I → indep J → I.ncard < J.ncard →
    ∃ e ∈ J, e ∉ I ∧ indep (insert e I)) {B : set E }: 
(matroid_of_indep indep exists_ind ind_mono ind_aug).base B ↔ 
  indep B ∧ ∀ X, indep X → B ⊆ X → X = B :=
iff.rfl 

@[simp] lemma matroid_of_indep_apply {indep : set E → Prop} 
  (exists_ind : ∃ I, indep I)
  (ind_mono : ∀ I J, I ⊆ J → indep J → indep I)
  (ind_aug : ∀ I J, indep I → indep J → I.ncard < J.ncard →
    ∃ e ∈ J, e ∉ I ∧ indep (insert e I)) : 
  (matroid_of_indep indep exists_ind ind_mono ind_aug).indep = indep :=
begin
  ext I,
  simp_rw [matroid.indep_iff_subset_base, matroid_of_indep], 
  split, 
  { rintro ⟨B, ⟨hBi,hB⟩, hIB⟩, 
    exact ind_mono _ _ hIB hBi},
  intro hI, 
  obtain ⟨B,hBi, hB⟩ := 
    @set.finite.exists_maximal_wrt (set E) (set E) _ id {J | I ⊆ J ∧ indep J} (to_finite _)
    ⟨I, subset_refl I, hI⟩, 
  simp only [mem_set_of_eq, id.def, le_eq_subset, and_imp] at hB hBi, 
  exact ⟨B, ⟨hBi.2, λ X hX hBX, (hB _ (hBi.1.trans hBX) hX hBX).symm⟩, hBi.1⟩, 
end 

end from_axioms 




/- Another version of the independence axioms that doesn't mention cardinality. TODO -/
-- def matroid_of_indep' (indep : set E → Prop) (exists_ind : ∃ I, indep I)
-- (ind_mono : ∀ I J, I ⊆ J → indep J → indep I)
-- (ind_aug : ∀ I J, indep I → indep J → (∃ I', I ⊂ I' ∧ indep I') → (∀ J', J ⊂ J' → ¬indep J') 
--   → (∃ x ∈ J \ I, indep (insert x I))) :
--   matroid E :=
-- { base := λ B, indep B ∧ ∀ I, B ⊆ I → indep I → I = B,
--   exists_base' := 
--   begin
--     obtain ⟨B,hB,hBmax⟩ := finite.exists_maximal indep exists_ind, 
--     exact ⟨B, hB, λ I hBI hI, (hBmax _ hI hBI).symm⟩,   
--   end,
--   base_exchange' := 
--   begin
--     rintro B₁ B₂ ⟨hB₁,hB₁max⟩ ⟨hB₂,hB₂max⟩ x hx, 
--     obtain ⟨y,hy,hyI⟩ := ind_aug (B₁ \ {x}) B₂ (ind_mono _ _ (diff_subset _ _) hB₁) hB₂ 
--       ⟨B₁, diff_singleton_ssubset hx.1, hB₁⟩ 
--       (λ J hB₂J hJ, hB₂J.ne ((hB₂max _ hB₂J.subset hJ).symm)), 
--     refine ⟨y, mem_of_mem_of_subset hy _, hyI, λ I hyI hI, _⟩  , 
--     { rw [diff_diff_right, inter_singleton_eq_empty.mpr hx.2, union_empty]}, 
    

--     -- rintro I J hI hJ hImax ⟨J',hJJ',hJ'⟩,  
