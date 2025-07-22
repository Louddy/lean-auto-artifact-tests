import Lake
open Lake DSL

package «hammertest» where
  -- add package configuration options here

@[default_target]
lean_lib «Hammertest» where
  -- add library configuration options here

require auto from git "https://github.com/Louddy/lean-auto-tests.git" @ "v4.20"

require Duper from git "https://github.com/leanprover-community/duper.git" @ "hammer"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.20.0"

-- @[default_target]
-- lean_exe «hammertest» where
--   root := `Main
