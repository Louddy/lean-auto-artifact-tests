#!bash
# This script is only compatible with Lean v4.15.0
# This script is only compatible with Mathlib4 29f9a66d622d9bab7f419120e22bb0d2598676ab, due to 'nonterminates'
# The number of processes chosen by this script is compatible with Amazon EC2 c5ad.16xlarge

cd lean-hammertest
source $HOME/.elan/env
lake build

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
    ], nprocs := 32 }" | lake env lean --stdin