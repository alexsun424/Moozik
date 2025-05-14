(* irgen_test.ml - Test file for irgen.ml *)

open Ast

(* Create a test music section *)
let test_section = {
  variables = [
    ("c_major", ["c4"; "e4"; "g4"]);      (* C major chord *)
    ("g_major", ["g4"; "b4"; "d5"]);      (* G major chord *)
  ];
  bars = [
    Notes ["c4"; "d4"; "e4"];             (* Scale fragment *)
    VarRef "c_major";                     (* C major chord *)
    Notes ["g4"; "a4"; "b4"];             (* Scale fragment *)
    VarRef "g_major";                     (* G major chord *)
    Repeat { 
      count = 2; 
      body = [Notes ["c5"; "b4"; "a4"; "g4"]] 
    }                                     (* Repeat descending pattern twice *)
  ]
}

(* Run the code generator *)
let () =
  print_endline "Testing IR generation...";
  Irgen.generate_ir test_section "test_output.mid";
  print_endline "Done! Check test_output.mid and midi.ll" 