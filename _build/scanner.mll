{
  open Parser 
  let in_music_mode = ref false
}


rule tokenize = parse
  [' ' '\t' '\r'] { tokenize lexbuf }
| '\n' { tokenize lexbuf }
| '.' { instance_var lexbuf }
| '{' { LEFT_CURLY }
| '}' { RIGHT_CURLY } 
| "playback(" { playback lexbuf } (* is it playback() or Moozik.playback() *)
| "Moozik.playback(" { playback lexbuf }
| "=" {  ASSIGN }
| "new" {  NEW }
| "repeat(" {REPEAT}
| "begin" { in_music_mode := true; BEGIN }
| "Composition" as comp { COMPOSITION(comp) }
| "Track" as tr { TRACK(tr) }
| "Section" as sec { SECTION(sec) }
| "Measure" as mes { MEASURE(mes) }
| '(' { parameters lexbuf }
| ';' { if !in_music_mode then measures lexbuf else SEMICOLON }
| '*' ['1'-'9']+ { STAR }
| (['0'-'9'] | ['A'-'Z'] | ['a'-'z'])+ as id {  print_endline(id); ID(id) }
| eof {  print_endline("eof"); EOF }

and parameters = parse
| ')' { tokenize lexbuf }
| ',' { parameters lexbuf }
| (['0'-'9'] | ['A'-'Z'] | ['a'-'z'] | ' ')+ as param { PARAM(param) }
| _ { parameters lexbuf }

and repeat = parse
| ['1'-'9']+ as num {NUMBER(int_of_string num)}
| _ {tokenize lexbuf}

and measures = parse
  [' ' '\t' '\r'] { print_endline("hit"); measures lexbuf }
| '\n' { measures lexbuf }
| '{' {chord lexbuf}
| '[' { LEFT_BRAC }
| ']' { LEFT_BRAC }
| ['a'-'g']+ ['1'-'9']+ ('0'|'+'|'-')* as note { print_endline(note); NOTE(note) }
| "end" {print_endline("music end"); in_music_mode := false; END }
| ';' {print_endline("music semi"); if !in_music_mode then SEMICOLON else tokenize lexbuf}

and chord = parse
| '}' {measures lexbuf}
| ['a'-'g']+ ['1'-'9']+ ('0'|'+'|'-')* as chord { CHORD(chord) }

and instance_var = parse
| '(' { parameters lexbuf }
| (['0'-'9'] | ['A'-'Z'] | ['a'-'z'])+ as iv { print_endline(iv); INSTANCE_VAR(iv) }
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