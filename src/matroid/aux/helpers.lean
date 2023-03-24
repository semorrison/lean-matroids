
import tactic 
import order.complete_lattice
import set_theory.cardinal.finite

noncomputable theory 
open_locale classical 

/-! 
A few helper lemmas for a separate PR 
-/


section finset 

variables {α : Type*} {X Y : finset α}

lemma finset.exists_mem_sdiff_of_card_lt_card (h : X.card < Y.card) : 
  ∃ e, e ∈ Y ∧ e ∉ X :=
begin
  refine by_contra (λ h', h.not_le (finset.card_mono (λ x hx, _))), 
  push_neg at h', 
  exact h' _ hx, 
end  

@[simp] lemma finset.card_inter_add_card_sdiff_eq_card (X Y : finset α) : 
  (X ∩ Y).card + (X \ Y).card = X.card :=
by {convert @finset.card_sdiff_add_card_eq_card _ _ _ _ _; simp}

lemma finset.card_sdiff_eq_card_sdiff_iff_card_eq_card {X Y : finset α} : 
  X.card = Y.card ↔ (X \ Y).card = (Y \ X).card :=
by rw [←finset.card_inter_add_card_sdiff_eq_card X Y, ←finset.card_inter_add_card_sdiff_eq_card Y X, 
    finset.inter_comm, add_right_inj]
 
lemma finset.card_le_card_iff_card_sdiff_le_card_sdiff {X Y : finset α} : 
  X.card ≤ Y.card ↔ (X \ Y).card ≤ (Y \ X).card := 
by rw [←finset.card_inter_add_card_sdiff_eq_card X Y, ←finset.card_inter_add_card_sdiff_eq_card Y X, finset.inter_comm, add_le_add_iff_left]

lemma finset.card_lt_card_iff_card_sdiff_lt_card_sdiff {X Y : finset α} : 
  X.card < Y.card ↔ (X \ Y).card < (Y \ X).card := 
by rw [←finset.card_inter_add_card_sdiff_eq_card X Y, ←finset.card_inter_add_card_sdiff_eq_card Y X, 
    finset.inter_comm, add_lt_add_iff_left]

lemma nat.card_eq_to_finset_card [fintype α] (S : set α) : 
  nat.card S = S.to_finset.card :=
by simp [nat.card_eq_fintype_card] 

end finset

open set 

theorem set.finite.exists_minimal_wrt {α β : Type*} [partial_order β] (f : α → β) (s : set α) 
  (h : s.finite) :
s.nonempty → (∃ (a : α) (H : a ∈ s), ∀ (a' : α), a' ∈ s → f a' ≤ f a → f a = f a') :=
@set.finite.exists_maximal_wrt α (order_dual β) _ f s h  

lemma set.finite.exists_maximal {α : Type*} [finite α] [partial_order α] (P : α → Prop) 
(h : ∃ x, P x) : 
  ∃ m, P m ∧ ∀ x, P x → m ≤ x → m = x :=
begin
  obtain ⟨m,⟨hm : P m,hm'⟩⟩ := set.finite.exists_maximal_wrt (@id α) (set_of P) (to_finite _) h, 
  exact ⟨m, hm, hm'⟩, 
end    

lemma set.finite.exists_minimal {α : Type*} [finite α] [partial_order α] (P : α → Prop) 
(h : ∃ x, P x) : ∃ m, P m ∧ ∀ x, P x → x ≤ m → m = x :=
@set.finite.exists_maximal (order_dual α) _ _ P h

lemma set.diff_singleton_ssubset_iff {α : Type*} {e : α} {S : set α} : 
  S \ {e} ⊂ S ↔ e ∈ S :=
⟨ λ h, by_contra (λ he, h.ne (by rwa [sdiff_eq_left, disjoint_singleton_right])), 
  λ h, ssubset_of_ne_of_subset 
    (by rwa [ne.def, sdiff_eq_left, disjoint_singleton_right, not_not_mem]) (diff_subset _ _)⟩

lemma set.diff_singleton_ssubset {α : Type*} {e : α} {S : set α} (heS : e ∈ S) : 
  S \ {e} ⊂ S :=
set.diff_singleton_ssubset_iff.mpr heS 


lemma insert_diff_singleton_comm {α : Type*} {X : set α} {e f : α} (hef : e ≠ f) : 
  insert e (X \ {f}) = (insert e X) \ {f} :=
by rw [←union_singleton, ←union_singleton, union_diff_distrib, 
  diff_singleton_eq_self (by simpa using hef.symm : f ∉ {e})]

lemma function.injective.compl_image {α β : Type*} {f : α → β} (hf : f.injective) (X : set α) :
  (f '' X)ᶜ = f '' (Xᶜ) ∪ (range f)ᶜ := 
begin
  apply compl_injective, 
  simp_rw [compl_union, compl_compl], 
  refine (subset_inter _ (image_subset_range _ _)).antisymm _, 
  { rintro x ⟨y, hy, rfl⟩ ⟨z,hz, hzy⟩,
    rw [hf hzy] at hz, 
    exact hz hy},
  rintro x ⟨hx, ⟨y, rfl⟩⟩, 
  exact ⟨y, by_contra (λ (hy : y ∈ Xᶜ), hx (mem_image_of_mem _ hy)), rfl⟩,    
end   

lemma singleton_inter_eq_of_mem {α : Type*} {x : α} {s : set α} (hx : x ∈ s) : 
  {x} ∩ s = {x} := 
(inter_subset_left _ _).antisymm (subset_inter subset_rfl (singleton_subset_iff.mpr hx))

lemma inter_singleton_eq_of_mem {α : Type*} {x : α} {s : set α} (hx : x ∈ s) : 
  s ∩ {x} = {x} := 
(inter_subset_right _ _).antisymm (subset_inter (singleton_subset_iff.mpr hx) subset_rfl)

@[simp] lemma diff_diff_cancel_right {α : Type*} (s t : set α) : 
  s \ (t \ s) = s :=  
(diff_subset _ _).antisymm (λ x hx, ⟨hx, λ h, h.2 hx⟩)
