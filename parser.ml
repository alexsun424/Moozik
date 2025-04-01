type token =
  | NEWLINE
  | VARIABLE of (
# 4 "parser.mly"
        string
# 7 "parser.ml"
)
  | LEFT_BRAC
  | RIGHT_BRAC
  | LEFT_PAREN
  | RIGHT_PAREN
  | SEMICOLON
  | PLAYBACK_TEXT of (
# 8 "parser.mly"
        string
# 17 "parser.ml"
)
  | EQUALS
  | NEW
  | COMPOSITION
  | TRACK
  | SECTION
  | MEASURE

open Parsing
let _ = parse_error;;
# 1 "parser.mly"
open Ast 
# 30 "parser.ml"
let yytransl_const = [|
  257 (* NEWLINE *);
  259 (* LEFT_BRAC *);
  260 (* RIGHT_BRAC *);
  261 (* LEFT_PAREN *);
  262 (* RIGHT_PAREN *);
  263 (* SEMICOLON *);
  265 (* EQUALS *);
  266 (* NEW *);
  267 (* COMPOSITION *);
  268 (* TRACK *);
  269 (* SECTION *);
  270 (* MEASURE *);
    0|]

let yytransl_block = [|
  258 (* VARIABLE *);
  264 (* PLAYBACK_TEXT *);
    0|]

let yylhs = "\255\255\
\001\000\000\000"

let yylen = "\002\000\
\001\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\001\000\002\000"

let yydgoto = "\002\000\
\004\000"

let yysindex = "\255\255\
\249\254\000\000\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000"

let yytablesize = 1
let yytable = "\001\000\
\003\000"

let yycheck = "\001\000\
\008\001"

let yynames_const = "\
  NEWLINE\000\
  LEFT_BRAC\000\
  RIGHT_BRAC\000\
  LEFT_PAREN\000\
  RIGHT_PAREN\000\
  SEMICOLON\000\
  EQUALS\000\
  NEW\000\
  COMPOSITION\000\
  TRACK\000\
  SECTION\000\
  MEASURE\000\
  "

let yynames_block = "\
  VARIABLE\000\
  PLAYBACK_TEXT\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 23 "parser.mly"
               ( Playback(_1) )
# 106 "parser.ml"
               : Ast.program))
(* Entry program *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let program (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.program)
