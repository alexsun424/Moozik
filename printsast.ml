open Ast
open Parser
open Semant
open Sast

let () =
    let lexbuf = Lexing.from_channel stdin in
    let program = Parser.program_rule Scanner.token lexbuf in
    let sast = Semant.check program in
    print_endline (Sast.string_of_sprogram sast) 