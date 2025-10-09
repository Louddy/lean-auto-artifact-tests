import Lake
open Lake DSL

package hammertest

@[default_target]
lean_lib Hammertest

require auto from git "https://github.com/Louddy/lean-auto-tests.git" @ "saturate"

require Duper from git "https://github.com/leanprover-community/duper.git"
  @ "f444c7ece7df389b5c80e003b525dbc1a88844f5"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.20.0"
