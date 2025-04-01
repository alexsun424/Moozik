{ open Parser }

rule tokenize = parse
  [' ' '\t' '\r'] { tokenize lexbuf }
| '\n' { NEWLINE }
| '[' { LEFT_BRAC }
| ']' { RIGHT_BRAC }
| '(' { LEFT_PAREN }
| ')' { RIGHT_PAREN }
| "playback(" { playback lexbuf } (* is it playback() or Moozik.playback() *)
| ["Moozik.playback(" ] { playback lexbuf }
| '=' { EQUALS }
| "new" { NEW }
| "Composition" { COMPOSITION }
| "Track" { TRACK }
| "Section" { SECTION }
| "Measure" { MEASURE }
| (['a'-'z']* | ['0' - '9']*)(['a'-'z']+ | ['0' - '9']+) as id = { VARIABLE(id) }

rule playback = parse
| ')' { tokenize lexbuf }
| '"' {playback_string lexbuf}

rule playback_string = parse
| '"' {playback lexbuf}
| _ { PLAYBACK }
