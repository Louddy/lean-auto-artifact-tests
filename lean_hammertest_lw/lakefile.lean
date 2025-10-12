import Lake
open Lake DSL

package hammertest

@[default_target]
lean_lib Hammertest

require auto from git "https://github.com/Louddy/lean-auto-tests.git" @ "unify-tests"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.20.0"
