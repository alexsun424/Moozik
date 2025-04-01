type token =
  | NEWLINE
  | VARIABLE of (
# 4 "parser.mly"
        string
# 7 "parser.mli"
)
  | LEFT_BRAC
  | RIGHT_BRAC
  | LEFT_PAREN
  | RIGHT_PAREN
  | SEMICOLON
  | PLAYBACK_TEXT of (
# 8 "parser.mly"
        string
# 17 "parser.mli"
)
  | EQUALS
  | NEW
  | COMPOSITION
  | TRACK
  | SECTION
  | MEASURE

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
