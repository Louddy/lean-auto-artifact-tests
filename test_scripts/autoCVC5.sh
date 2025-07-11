#!/bin/bash
# This script is only compatible with Mathlib4 29f9a66d622d9bab7f419120e22bb0d2598676ab, due to 'nonterminates'

decim_re='^[1-9][0-9]*$'
if ! ( [ "$#" -eq 2 ] || ( [ "$#" -eq 3 ] && [[ $3 =~ $decim_re ]] ) ) || ! [[ $1 =~ $decim_re ]]; then
  echo "Illegal number of parameters"
  echo "Usage: ./<script_name> <number_of_processors> <path_to_hammertest_repo> [<number_of_mathlib_modules_to_test>]"
  exit
fi

filterchoice='.none'
if [ "$#" -eq 3 ]; then
  filterchoice="(.some $3)"
fi

cd $2

source ~/.elan/env

echo "import Mathlib
import Hammertest

open EvalAuto

set_option auto.testTactics.ensureAesop true
set_option auto.testTactics.ensureAuto true
set_option auto.testTactics.rebindNativeModuleName \"Hammertest.DuperInterfaceRebindRaw\"

#eval @id (Lean.CoreM Unit) do
  let mfilter ← Pseudo.randMathlibModules?All $filterchoice
  evalTacticsAtMathlibHumanTheorems
    { tactics := #[.testUnknownConstant, .useAuto true (.smt .cvc5) 10],
      resultFolder := \"./EvalAutoCVC5AsTactic\",
      moduleFilter := mfilter,
      nonterminates := #[
        (.useAuto true (.smt .cvc5) 10, \`\`Differentiable.exists_const_forall_eq_of_bounded),
        (.useAuto true (.smt .cvc5) 10, \`\`uniformContinuous_of_const),
        (.useAuto true (.smt .cvc5) 10, \`\`mem_pairSelfAdjointMatricesSubmodule'),
        (.useAuto true (.smt .cvc5) 10, \`\`mem_selfAdjointMatricesSubmodule),
        (.useAuto true (.smt .cvc5) 10, \`\`Equiv.Perm.cycleFactorsFinset_eq_list_toFinset),
        (.useAuto true (.smt .cvc5) 10, \`\`Polynomial.IsSplittingField.of_algEquiv),
        (.useAuto true (.smt .cvc5) 10, \`\`AffineMap.lineMap_injective),
        (.useAuto true (.smt .cvc5) 10, \`\`Subalgebra.restrictScalars_top),
        (.useAuto true (.smt .cvc5) 10, \`\`NonUnitalStarAlgebra.inf_toNonUnitalSubalgebra),
        (.useAuto true (.smt .cvc5) 10, \`\`StarSubalgebra.inf_toSubalgebra),
        (.useAuto true (.smt .cvc5) 10, \`\`NonUnitalStarAlgebra.top_toNonUnitalSubalgebra),
        (.useAuto true (.smt .cvc5) 10, \`\`StarSubalgebra.top_toSubalgebra),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBase.insert_dep),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.isBasis_iff_isBasis'_subset_ground),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.isBasis_subset),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.dep_of_ssubset),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Indep.subset_isBasis'_of_subset),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Indep.exists_isBase_subset_union_isBase),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.dual_isBase_iff'),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.dual_dual),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBase.compl_isBase_dual),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBase.compl_inter_isBasis_of_inter_isBasis),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.ground_not_isBase),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Coindep.exists_isBase_subset_compl),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.restrict_isBase),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.isBase_restrict),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.isBasis_restrict_of_subset),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.isBasis_isRestriction),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.of_isRestriction),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBase.isBasis_of_isRestriction),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.transfer),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Indep.exists_isBasis_subset_union_isBasis),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Indep.exists_insert_of_not_isBasis),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.exchange),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.eq_exchange_of_diff_eq_singleton),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Indep.augment),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Indep.closure_eq_setOf_isBasis_insert),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.subset_closure),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.indep_iff_forall_not_mem_closure_diff'),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Spanning.closure_eq_of_superset),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Spanning.exists_isBase_subset),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Coindep.compl_spanning),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.Coindep.closure_compl),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.ext_spanning),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.comapOn_dual_eq_of_bijOn),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.IsBasis.map),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.map_isBasis_iff),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.restrictSubtype_ground_isBase_iff),
        (.useAuto true (.smt .cvc5) 10, \`\`Matroid.restrictSubtype_ground_isBasis_iff)
      ], nprocs := $1 }" | lake env lean --stdin