import Auto.EvaluateAuto.EnvAnalysis

open Lean EvalAuto

def Pseudo.randMathlibModules (num : Nat) : CoreM (Std.HashSet Name) := do
  let modules ← mathlibModules
  let (ret, _) := Array.pseudoRandPickNodup modules num ⟨1711426580, 396961328⟩
  return Std.HashSet.ofArray ret

def Pseudo.randMathlibModules?All (num? : Option Nat) : CoreM (Name → Bool) :=
  match num? with
  | .some num => do return (← Pseudo.randMathlibModules num).contains
  | .none => pure (fun _ => true)
