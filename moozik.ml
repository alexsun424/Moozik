open Ast

let () =

  let input = "Composition comp1 = new Composition();\n\
               Track testTrack = new Track();\n\
               Section testSection = new Section();\n\
               Measure testMeasures = new Measure();\n\
               testMeasures.addMeasures(e);" in

  let lexbuf = Lexing.from_string input in
  try
  
    let result = Parser.program Scanner.tokenize  lexbuf in
    Printf.printf "Parsing succeeded.\n"

  with e ->

    Printf.printf "Parsing failed: %s\n" (Printexc.to_string e)
(* 
let _ =
  let lexbuf = Lexing.from_channel stdin in
  let program = Parser.program Scanner.tokenize lexbuf in
  print_endline ("finished") *)

let playback_text _ =
  print_endline "Track: testTrack (Instrument: Piano)";
  print_endline "Key: C, Time: 4/4";
  print_endline "Measure: C quarter, D quarter, E half";
  print_endline "Measure: G whole"
