type token =
  | NOTE of (
# 3 "parser.mly"
        string
# 6 "parser.mli"
)
  | CHORD of (
# 4 "parser.mly"
        string
# 11 "parser.mli"
)
  | STAR
  | ID of (
# 6 "parser.mly"
        string
# 17 "parser.mli"
)
  | INSTANCE_VAR of (
# 7 "parser.mly"
        string
# 22 "parser.mli"
)
  | LEFT_BRAC
  | RIGHT_BRAC
  | LEFT_PAREN
  | RIGHT_PAREN
  | LEFT_CURLY
  | RIGHT_CURLY
  | PARAM of (
# 11 "parser.mly"
        string
# 33 "parser.mli"
)
  | SEMICOLON
  | PLAYBACK_TEXT of (
# 13 "parser.mly"
        string
# 39 "parser.mli"
)
  | ASSIGN
  | NEW
  | REPEAT
  | COMPOSITION of (
# 17 "parser.mly"
        string
# 47 "parser.mli"
)
  | TRACK of (
# 18 "parser.mly"
        string
# 52 "parser.mli"
)
  | SECTION of (
# 19 "parser.mly"
        string
# 57 "parser.mli"
)
  | MEASURE of (
# 20 "parser.mly"
        string
# 62 "parser.mli"
)
  | NUMBER of (
# 21 "parser.mly"
        int
# 67 "parser.mli"
)
  | BEGIN
  | END
  | EOF

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
