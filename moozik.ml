open Ast

let playback string =
    print_endline(string)


let eval = function
  |Playback(string) -> playback string 


  let _ =
    let lexbuf = Lexing.from_channel stdin in
    let expr = Parser.program Scanner.tokenize lexbuf in
    let result = eval expr in
    print_endline (string_of_int result)