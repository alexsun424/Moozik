{ open Parser }

rule tokenize = parse
  [' ' '\t' '\r'] { tokenize lexbuf }
| '.' { instance_var lexbuf }
| '\n' { NEWLINE }
| '[' { LEFT_BRAC }
| ']' { RIGHT_BRAC }
| '(' { LEFT_PAREN }
| ')' { RIGHT_PAREN }
| ';' { SEMICOLON }
| '*' ['1'-'9']+ { STAR }
| ['a'-'g']+ ['1'-'9']+ (' '|'+'|'-') as note { NOTE(note) }
| '{' { chord lexbuf } 
| "playback(" { playback lexbuf } (* is it playback() or Moozik.playback() *)
| "Moozik.playback(" { playback lexbuf }
| '=' { EQUALS }
| "new" { NEW }
| "BEGIN" { BEGIN }
| "END" { END }
| "Composition" { COMPOSITION }
| "Track" { TRACK }
| "Section" { SECTION }
| "Measure" { MEASURE }
| (['a'-'z'] | ['0' - '9'])* as id { ID(id) }

and chord = parse
| '}' {tokenize lexbuf}
| _ as chord { CHORD(chord) }

and instance_var = parse
| (['a'-'z'] | ['0' - '9'])* {INSTANCE_VAR}
| _ {tokenize lexbuf}

and playback = parse
| ')' { tokenize lexbuf }
| '"' { playback_string lexbuf}

and playback_string = parse
| '"' {playback lexbuf}
| (['a'-'z'] | ['0' - '9'] | " ")* as pb { PLAYBACK_TEXT(pb) }



(* {
    let buf = Lexing.from_channel stdin in
    let f = tokenize buf in
    print_endline f
} *)