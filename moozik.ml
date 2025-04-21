open Parser
open Lexing

(* Print every token with the exact lexeme seen *)
let rec dump_tokens lexbuf =
  try
    let token = Scanner.token lexbuf in
    Printf.printf "TOKEN: %-20s | LEXEME: %s\n"
      (Obj.magic token : string)  (* Debug trick — don't do this in prod *)
      (Lexing.lexeme lexbuf);
    if token = Parser.EOF then print_endline "EOF reached"
    else dump_tokens lexbuf
  with
  | Scanner.SyntaxError msg ->
      Printf.eprintf "Lexer error at offset %d: %s\n"
        (Lexing.lexeme_start lexbuf) msg
  | Parsing.Parse_error ->
      Printf.eprintf "Parser error at offset %d\n" (Lexing.lexeme_start lexbuf)

let () =
  print_endline "RUNNING MOOZIK...";

  let source = 
    "Composition testComp = new Composition();\n" ^
    "repeat(2) { begin; c1 c1; end; }\n" ^
    "for (int i = 0; i < 3; i++) { begin; d1 d1; end; }\n" ^
    "Track testTrack = new Track();\n" ^
    "Section testSection = new Section();\n" ^
    "Measure testMeasures = new Measure();\n" ^
    "testMeasures.measures = \n" ^
    "  begin;\n" ^
    "  e1 e1 e1 e1;\n" ^
    "  some_notes = [c+1 c-2;]\n" ^
    "  e1 e1 e1 e1;\n" ^
    "  i_see_you = [c2 c2;]\n" ^
    "  e1 e1 e1 e1;\n" ^
    "  e2 e2 e2 e2;\n" ^
    "  some_notes\n" ^
    "  end;\n" ^
    "testSection.addMeasures(testMeasures.measures);\n" ^
    "testTrack.addSection(testSection);\n" ^
    "testComp.addTrack(testTrack);"
  in

  print_endline "----- INPUT START -----";
  print_endline source;
  print_endline "-----  INPUT END  -----\n";

  let lexbuf = Lexing.from_string source in
  dump_tokens lexbuf
