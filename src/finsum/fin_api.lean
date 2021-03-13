import .fincard 

open_locale big_operators classical 

universes u v w 

-- this file contains versions of the finsum lemma that require finiteness assumptions, where the finiteness
-- comes from [fintype α] instances. To disambiguate, they are all in the 'fin' namespace 


namespace fin

variables {α : Type*} {β : Type*} [fintype α] {M: Type*} {f g : α → M} {s t : set α} {a b : α}

lemma finsum_le_finsum [ordered_add_comm_monoid M] (hfg : ∀ x, f x ≤ g x) :
  ∑ᶠ (i : α), f i ≤ ∑ᶠ (i : α), g i := 
by {apply finsum_le_finsum hfg; {apply set.finite.of_fintype}}

lemma finsum_in_le_finsum_in [ordered_add_comm_monoid M] (hfg : ∀ x ∈ s, f x ≤ g x) : 
  ∑ᶠ i in s, f i ≤ ∑ᶠ i in s, g i  := 
by {apply finsum_in_le_finsum_in hfg, apply set.finite.of_fintype}

@[simp] lemma finsum_in_eq_zero_iff [canonically_ordered_add_monoid M]:
  ∑ᶠ x in s, f x = 0 ↔ ∀ x ∈ s, f x = 0 := 
by {apply finsum_in_eq_zero_iff, apply set.finite.of_fintype}

@[simp] lemma finsum_eq_zero_iff [canonically_ordered_add_monoid M]:
  ∑ᶠ x, f x = 0 ↔ ∀ x, f x = 0 := 
by {apply finsum_eq_zero_iff, apply set.finite.of_fintype}

lemma finsum_in_eq_zero_iff_of_nonneg [ordered_add_comm_monoid M] (hf : ∀ x ∈ s, 0 ≤ f x) : 
  ∑ᶠ x in s, f x = 0 ↔ ∀ x ∈ s, f x = 0 := 
by {apply finsum_in_eq_zero_iff_of_nonneg _ hf, apply set.finite.of_fintype}

lemma finsum_eq_zero_iff_of_nonneg [ordered_add_comm_monoid M] (hf : ∀ x, 0 ≤ f x) : 
  ∑ᶠ x, f x = 0 ↔ ∀ x, f x = 0 := 
by {apply finsum_eq_zero_iff_of_nonneg _ hf, apply set.finite.of_fintype}

@[simp] lemma fincard_eq_zero_iff_empty {s : set α} :
  fincard s = 0 ↔ s = ∅ := 
by {apply fincard_eq_zero_iff_empty, apply set.finite.of_fintype}

lemma finsum_in_insert [add_comm_monoid M] (f : α → M) (h : a ∉ s) :
  ∑ᶠ i in insert a s, f i = f a + ∑ᶠ i in s, f i :=
by {apply finsum_in_insert' _ h, apply set.finite.of_fintype}

lemma finsum_in_add_distrib [add_comm_monoid M] (f g : α → M) (s : set α) :
  ∑ᶠ i in s, (f + g) i = ∑ᶠ i in s, f i + ∑ᶠ i in s, g i :=
by {apply finsum_in_add_distrib, apply set.finite.of_fintype}

lemma finsum_add_distrib [add_comm_group M] (f g : α → M) :
  ∑ᶠ i, (f + g) i = ∑ᶠ i, f i + ∑ᶠ i, g i :=
by {apply finsum_add_distrib; apply set.finite.of_fintype}

lemma finsum_in_sub_distrib [add_comm_group M] (f g : α → M) (s : set α) :
  ∑ᶠ i in s, (f - g) i = ∑ᶠ i in s, f i - ∑ᶠ i in s, g i :=
by {apply finsum_in_sub_distrib, apply set.finite.of_fintype}

lemma finsum_sub_distrib [add_comm_group M] (f g : α → M) :
  ∑ᶠ i, (f - g) i = ∑ᶠ i, f i - ∑ᶠ i, g i :=
by {apply finsum_sub_distrib; apply set.finite.of_fintype}

lemma sum_fincard_fiber_eq_fincard (s : set α) (f : α → β) :
  ∑ᶠ (b : β), fincard {a ∈ s | f a = b} = fincard s := 
by {exact sum_fincard_fiber_eq_fincard _ (set.finite.of_fintype _),}

lemma finsum_in_exists_lt_of_finsum_lt [linear_ordered_cancel_add_comm_monoid M]
(hlt : ∑ᶠ x in s, f x < ∑ᶠ x in s, g x) : 
  ∃ i ∈ s, f i < g i := 
by {apply finsum_in_exists_lt_of_finsum_lt _ _ hlt; 
    apply set.finite.of_fintype, }

lemma finsum_exists_lt_of_finsum_lt [linear_ordered_cancel_add_comm_monoid M]
(hlt : ∑ᶠ x, f x < ∑ᶠ x, g x) : 
  ∃ i, f i < g i := 
by {apply finsum_exists_lt_of_finsum_lt _ _ hlt; 
    apply set.finite.of_fintype, }

lemma finsum_in_lt_finsum_in [ordered_cancel_add_comm_monoid M]
(hle : ∀ i ∈ s, f i ≤ g i) (hlt : ∃ i ∈ s, f i < g i) : 
  ∑ᶠ i in s, f i < ∑ᶠ i in s, g i := 
by {apply finsum_in_lt_finsum_in _ _ hle hlt; 
    apply (set.finite.of_fintype _); apply_instance, }

lemma finsum_lt_finsum [ordered_cancel_add_comm_monoid M]
(hle : ∀ i, f i ≤ g i) (hlt : ∃ i, f i < g i) : 
  ∑ᶠ i, f i < ∑ᶠ i, g i := 
by {apply finsum_lt_finsum _ _ hle hlt; 
    apply (set.finite.of_fintype _); apply_instance, }

lemma finsum_in_eq_finsum_in_iff_of_le [ordered_cancel_add_comm_monoid M]
(hfg : ∀ x ∈ s, f x ≤ g x) : 
  ∑ᶠ i in s, f i = ∑ᶠ i in s, g i ↔ ∀ i ∈ s, f i = g i := 
by {apply finsum_in_eq_finsum_in_iff_of_le _ _ hfg; 
    apply set.finite.of_fintype, }

lemma finsum_eq_finsum_iff_of_le [ordered_cancel_add_comm_monoid M]
(hfg : ∀ x, f x ≤ g x) : 
  ∑ᶠ i, f i = ∑ᶠ i, g i ↔ ∀ i, f i = g i := 
by {apply finsum_eq_finsum_iff_of_le _ _ hfg; 
    apply set.finite.of_fintype, }




end fin