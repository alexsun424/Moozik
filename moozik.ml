open Ast

let playback_text string =
    print_endline(string)


let eval = function
  |Playback(string) -> playback_text string 


  let _ =
    let lexbuf = Lexing.from_channel stdin in
    let expr = Parser.program Scanner.tokenize lexbuf in
    eval expr