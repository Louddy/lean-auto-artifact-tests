import Lake
open Lake DSL

package "hammertest" where
  -- add package configuration options here

lean_lib «Hammertest» where
  -- add library configuration options here

require auto from "../lean-auto/"

require Duper from "../duper/"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

@[default_target]
lean_exe "hammertest" where
  root := `Main
