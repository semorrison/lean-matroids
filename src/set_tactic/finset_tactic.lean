import data.finset.basic
import data.fintype.basic 
import .extensionality

namespace extensionality
instance finset_ext_lemmas (T : Type) [decidable_eq T] :
  (boolalg_ext_lemmas (finset T) T) :=
{
  simpl_eq := by tidy,
  ext_bot := by tidy,
  ext_sdiff := by tidy,
  ext_le := by tidy, 
  ext_meet := by tidy,
  ext_join := by simp only [finset.inf_eq_inter, forall_const, iff_self, finset.mem_inter, forall_true_iff],
}

instance finset_ext_lemmas_compl (T : Type) [fintype T] [decidable_eq T] :
  (boolalg_ext_lemmas_compl (finset T) T) :=
{
  ext_compl := by apply finset.mem_compl
}

instance finset_ext_lemmas_top (T : Type) [fintype T] [decidable_eq T] :
  (boolalg_ext_lemmas_top (finset T) T) :=
{
  ext_top := by unfold_projs; finish,
}
end extensionality

namespace cleanup 
lemma finset_union_sup (T : Type) [decidable_eq T] (A B : finset T) : (A ∪ B) = (A ⊔ B) := by refl
lemma finset_inter_inf (T : Type) [decidable_eq T] (A B : finset T) : (A ∩ B) = (A ⊓ B) := by refl
lemma finset_subset_le (T : Type) [decidable_eq T] (A B : finset T) : (A ⊆ B) = (A ≤ B) := by refl

meta def finset_cleanup : tactic unit :=
  `[simp only [cleanup.finset_union_sup, cleanup.finset_inter_inf, cleanup.finset_subset_le] at *]
end cleanup