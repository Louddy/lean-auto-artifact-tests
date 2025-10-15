#!/bin/bash

# --- Parse required arguments ---
if [ "$#" -lt 2 ]; then
  echo "Illegal number of parameters"
  echo "Usage: $0 <number_of_processors> <path_to_hammertest_repo> <nMod> <static> <timeM> <timeT> <mem> <threads>"
  exit 1
fi

num_procs="$1"
repo_path="$2"
nMod="$3"
static= "4"
timeM="$5"
timeT="$6"
mem="$7"
threads="$8"

cd "$2"

source ~/.elan/env

echo "import Mathlib
import Hammertest

open EvalAuto

set_option auto.testTactics.ensureAesop true
#eval @id (Lean.CoreM Unit) do
  let mfilter ← Pseudo.randMathlibModules?All $nMod $static
  let tactics := #[
    .testUnknownConstant,
    .useRfl,
    .useSimpAll,
    .useSimpAllWithPremises,
    .useAesop,
    .useAesopWithPremises,
    -- .useAesopPSafeNew,
    -- .useAesopPSafeOld,
    .useAesopPUnsafeNew,
    .useAesopPUnsafeOld,
    -- .useSaturateNewDAesop,
    -- .useSaturateOldDAesop,
    .useSaturateNewDAss,
    .useSaturateOldDAss,
  ]
  evalTacticsAtMathlibHumanTheorems
    { tactics
      maxHeartbeats := 10000000000000000000  -- effectively unlimited
      timeout?      := $timeT         -- 10s
      resultFolder := \"./EvalTactics\"
      moduleFilter := mfilter
      nonterminates :=
        let decls := #[
          \`\`IntermediateField.extendScalars_top,
          \`\`IntermediateField.extendScalars_inf,
          \`\`Field.Emb.Cardinal.succEquiv_coherence,
          \`\`UniformConvergenceCLM.uniformSpace_eq,
        ]
        tactics.flatMap fun tac => decls.map fun decl => (tac, decl)
      nprocs := $num_procs
      nthreads := $threads
      memoryLimitKb := $mem
      timeLimitS := $timeM
    }" | lake env lean -j"$threads" --stdin
