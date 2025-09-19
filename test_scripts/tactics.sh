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
  evalTacticsAtMathlibHumanTheorems
    { tactics := #[.testUnknownConstant, .useRfl, .useSimpAll, .useSimpAllWithPremises, .useAesop 65536,
                      .useAesopWithPremises 65536, .useAesopPSafeNew 65536, .useAesopPSafeOld 65536,
                      .useAesopPUnsafeNew 65536, .useAesopPUnsafeOld 65536, .useSaturateNewDAesop 65536,
                      .useSaturateOldDAesop 65536, .useSaturateNewDAss 65536, .useSaturateOldDAss 65536,],            
      resultFolder := \"./EvalTactics\",
      moduleFilter := mfilter,
      nonterminates := #[
        (.useRfl, \`\`IntermediateField.extendScalars_top),
        (.useAesop 65536, \`\`IntermediateField.extendScalars_top),
        (.useAesopWithPremises 65536, \`\`IntermediateField.extendScalars_top),
        (.useRfl, \`\`IntermediateField.extendScalars_inf),
        (.useAesop 65536, \`\`IntermediateField.extendScalars_inf),
        (.useAesopWithPremises 65536, \`\`IntermediateField.extendScalars_inf),
        (.useAesopPSafeNew 65536, \`\`IntermediateField.extendScalars_inf),
        (.useAesopPSafeOld 65536, \`\`IntermediateField.extendScalars_inf),
        (.useAesopPUnsafeNew 65536, \`\`IntermediateField.extendScalars_inf),
        (.useAesopPUnsafeOld 65536, \`\`IntermediateField.extendScalars_inf),
        (.useSaturateNewDAesop65536, \`\`IntermediateField.extendScalars_inf),
        (.useSaturateOldDAesop 65536, \`\`IntermediateField.extendScalars_inf),
        (.useSaturateNewDAss 65536, \`\`IntermediateField.extendScalars_inf),
        (.useSaturateOldDAss 65536, \`\`IntermediateField.extendScalars_inf),
        (.useRfl, \`\`Field.Emb.Cardinal.succEquiv_coherence),
        (.useAesop 65536, \`\`Field.Emb.Cardinal.succEquiv_coherence),
        (.useAesopWithPremises 65536, \`\`Field.Emb.Cardinal.succEquiv_coherence),
        (.useAesop 65536, \`\`UniformConvergenceCLM.uniformSpace_eq),
        (.useAesopWithPremises 65536, \`\`UniformConvergenceCLM.uniformSpace_eq)
      ], nprocs := $1 }" | lake env lean --stdin