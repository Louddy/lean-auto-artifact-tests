#!bash
# This script is only compatible with Lean v4.15.0
# This script is only compatible with Mathlib4 29f9a66d622d9bab7f419120e22bb0d2598676ab, due to 'nonterminates'

decim_re='^[1-9][0-9]*$'
if [ "$#" -ne 1 ] || ! [[ $1 =~ $decim_re ]]; then
  echo "Illegal number of parameters"
  echo "Usage: ./<script_name> <number_of_processors>"
fi

echo "import Mathlib
import Auto.EvaluateAuto.TestTactics

open EvalAuto

set_option auto.testTactics.ensureAesop true
#eval evalTacticsAtMathlibHumanTheorems
  { tactics := #[.testUnknownConstant, .useRfl, .useSimpAll, .useSimpAllWithPremises, .useAesop 65536, .useAesopWithPremises 65536],
    resultFolder := \"./EvalTactics\",
    nonterminates := #[
      (.useRfl, \`\`IntermediateField.extendScalars_top),
      (.useAesop 65536, \`\`IntermediateField.extendScalars_top),
      (.useAesopWithPremises 65536, \`\`IntermediateField.extendScalars_top),
      (.useRfl, \`\`IntermediateField.extendScalars_inf),
      (.useAesop 65536, \`\`IntermediateField.extendScalars_inf),
      (.useAesopWithPremises 65536, \`\`IntermediateField.extendScalars_inf),
      (.useRfl, \`\`Field.Emb.Cardinal.succEquiv_coherence),
      (.useAesop 65536, \`\`Field.Emb.Cardinal.succEquiv_coherence),
      (.useAesopWithPremises 65536, \`\`Field.Emb.Cardinal.succEquiv_coherence),
      (.useAesop 65536, \`\`UniformConvergenceCLM.uniformSpace_eq),
      (.useAesopWithPremises 65536, \`\`UniformConvergenceCLM.uniformSpace_eq)
    ], nprocs := $1 }" | lake env lean --stdin