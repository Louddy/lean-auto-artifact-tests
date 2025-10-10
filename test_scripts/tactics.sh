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
#eval @id (Lean.CoreM Unit) do
  let mfilter ← Pseudo.randMathlibModules?All $filterchoice
  let tactics := #[
    .testUnknownConstant,
    .useRfl,
    .useSimpAll,
    .useSimpAllWithPremises,
    -- .useAesop 65536,
    .useAesopWithPremises 65536,
    -- .useAesopPSafeNew 65536,
    -- .useAesopPSafeOld 65536,
    .useAesopPUnsafeNew 65536,
    .useAesopPUnsafeOld 65536,
    -- .useSaturateNewDAesop,
    -- .useSaturateOldDAesop,
    .useSaturateNewDAss,
    .useSaturateOldDAss,
  ]
  evalTacticsAtMathlibHumanTheorems
    { tactics
      resultFolder := \"./EvalTactics\",
      moduleFilter := mfilter,
      nonterminates :=
        let decls := #[
          \`\`IntermediateField.extendScalars_top,
          \`\`IntermediateField.extendScalars_inf,
          \`\`Field.Emb.Cardinal.succEquiv_coherence,
          \`\`UniformConvergenceCLM.uniformSpace_eq,
        ]
        tactics.flatMap fun tac => decls.map fun decl => (tac, decl),
      nprocs := $1
    }" | lake env lean -j1 --stdin
