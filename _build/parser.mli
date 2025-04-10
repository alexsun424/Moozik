type token =
  | ID of (
# 5 "parser.mly"
        string
# 6 "parser.mli"
)
  | C_NOTE of (
# 6 "parser.mly"
        int
# 11 "parser.mli"
)
  | C_SHARP_NOTE of (
# 6 "parser.mly"
        int
# 16 "parser.mli"
)
  | C_FLAT_NOTE of (
# 6 "parser.mly"
        int
# 21 "parser.mli"
)
  | D_NOTE of (
# 7 "parser.mly"
        int
# 26 "parser.mli"
)
  | D_SHARP_NOTE of (
# 7 "parser.mly"
        int
# 31 "parser.mli"
)
  | D_FLAT_NOTE of (
# 7 "parser.mly"
        int
# 36 "parser.mli"
)
  | E_NOTE of (
# 8 "parser.mly"
        int
# 41 "parser.mli"
)
  | E_SHARP_NOTE of (
# 8 "parser.mly"
        int
# 46 "parser.mli"
)
  | E_FLAT_NOTE of (
# 8 "parser.mly"
        int
# 51 "parser.mli"
)
  | F_NOTE of (
# 9 "parser.mly"
        int
# 56 "parser.mli"
)
  | F_SHARP_NOTE of (
# 9 "parser.mly"
        int
# 61 "parser.mli"
)
  | F_FLAT_NOTE of (
# 9 "parser.mly"
        int
# 66 "parser.mli"
)
  | G_NOTE of (
# 10 "parser.mly"
        int
# 71 "parser.mli"
)
  | G_SHARP_NOTE of (
# 10 "parser.mly"
        int
# 76 "parser.mli"
)
  | G_FLAT_NOTE of (
# 10 "parser.mly"
        int
# 81 "parser.mli"
)
  | A_NOTE of (
# 11 "parser.mly"
        int
# 86 "parser.mli"
)
  | A_SHARP_NOTE of (
# 11 "parser.mly"
        int
# 91 "parser.mli"
)
  | A_FLAT_NOTE of (
# 11 "parser.mly"
        int
# 96 "parser.mli"
)
  | B_NOTE of (
# 12 "parser.mly"
        int
# 101 "parser.mli"
)
  | B_SHARP_NOTE of (
# 12 "parser.mly"
        int
# 106 "parser.mli"
)
  | B_FLAT_NOTE of (
# 12 "parser.mly"
        int
# 111 "parser.mli"
)
  | COMPOSITION
  | TRACK
  | SECTION
  | MEASURE
  | DOT_MEASURES
  | DOT_ADDMEASURES
  | DOT_ADDSECTION
  | DOT_ADDTRACK
  | NEW
  | BEGIN
  | END
  | ASSIGN
  | SEMICOLON
  | LPAREN
  | RPAREN
  | EOF

val program_rule :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
