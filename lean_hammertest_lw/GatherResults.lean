import Lean
import Mathlib
import Auto

open Lean Meta EvalAuto

def readETMHTEvaluateFilesCached (path : String) : CoreM (Array (Name × Array (Result × Nat × Nat))) := do
  if !(← System.FilePath.pathExists (path ++ "/gatheredResult")) then
    gatherETMHTResult
      { tactics := Inhabited.default, resultFolder := path,
        nonterminates := Inhabited.default,
        nprocs := Inhabited.default }
  readEvalTacticsAtModuleResult (path ++ "/gatheredResult")

def tactics (path : String) : CoreM (Array (Name × Array (Result × Nat × Nat))) :=
  readETMHTEvaluateFilesCached (path ++ "/EvalTactics")

/-
def autoNativeAsTactic (path : String) : CoreM (Array (Name × Array (Result × Nat × Nat))) := do
  readETMHTEvaluateFilesCached (path ++ "/EvalAutoNativeAsTactic")

def autoZ3AsTactic (path : String) : CoreM (Array (Name × Array (Result × Nat × Nat))) := do
  readETMHTEvaluateFilesCached (path ++ "/EvalAutoZ3AsTactic")

def autoCVC5AsTactic (path : String) : CoreM (Array (Name × Array (Result × Nat × Nat))) := do
  readETMHTEvaluateFilesCached (path ++ "/EvalAutoCVC5AsTactic")

def autoZipperpnAsTactic (path : String) : CoreM (Array (Name × Array (Result × Nat × Nat))) := do
  readETMHTEvaluateFilesCached (path ++ "/EvalAutoZipperpnAsTactic")
-/

/--
  Order of tactics:
    testUnknownConstant, useRfl, useSimpAll,
    useSimpAllWithPremises, useAesop 65536, useAesopWithPremises 65536,
    useAuto true .native 10, useAuto true (.smt .z3) 10,
    useAuto true (.smt .cvc5) 10, useAuto true (.tptp .zipperposition "zipperposition") 10
-/
def allResults (path : String) : CoreM (Array String × Array (Name × Array (Result × Nat × Nat))) := do
  let tt := Std.HashMap.ofList (← tactics path).toList
  -- let an := Std.HashMap.ofList (← autoNativeAsTactic path).toList
  -- let az := Std.HashMap.ofList (← autoZ3AsTactic path).toList
  -- let ac := Std.HashMap.ofList (← autoCVC5AsTactic path).toList
  -- let azp := Std.HashMap.ofList (← autoZipperpnAsTactic path).toList
  -- let namesets := #[tt, an, az, ac, azp].map (fun hmap => Std.HashSet.ofArray (hmap.toArray.map Prod.fst))
  let namesets := #[tt].map (fun hmap => Std.HashSet.ofArray (hmap.toArray.map Prod.fst))
  let names := Array.foldl (fun a b => Auto.mergeHashSet a b) Std.HashSet.empty namesets
  let names := names.toArray
  let mut ret := #[]
  let missingException : Exception := .error .missing m!"Not found in result file"
  let mR := (.exception missingException, 0, 0)
  for name in names do
    let ntt := tt.getD name #[mR, mR, mR, mR, mR, mR]
    /-
    let #[_, nan] := an.getD name #[mR, mR]
      | throwError "{decl_name%} :: Unexpected result"
    let #[_, naz] := az.getD name #[mR, mR]
      | throwError "{decl_name%} :: Unexpected result"
    let #[_, nac] := ac.getD name #[mR, mR]
      | throwError "{decl_name%} :: Unexpected result"
    let #[_, nazp] := azp.getD name #[mR, mR]
      | throwError "{decl_name%} :: Unexpected result"
    ret := ret.push (name, ntt ++ #[nan, naz, nac, nazp])
    -/
    ret := ret.push (name, ntt)
  let tactics := #[
    "testUnknownConstant", "rfl", "simpAll",
    "simpAllWithPremises", "aesop", "aesopWithPremises",
    -- "autoNative", "autoZ3", "autoCVC5", "autoZipperpn"
  ]
  return (tactics, ret)

def saveAllResults (path savepath : String) : CoreM Unit := do
  let fhandle ← IO.FS.Handle.mk savepath .write
  let (tactics, results) ← allResults path
  fhandle.putStrLn (String.intercalate " " tactics.toList)
  for ((name, result), idx) in results.zipWithIndex do
    let resultStrs := result.map (fun (r, time, hb) => s!"{r.concise} {time} {hb}")
    fhandle.putStrLn s!"{idx} {resultStrs} {Name.uniqRepr name}"

#eval saveAllResults "/home/lean_hammertest_lw" "/home/lean_hammertest_lw/allResults"
