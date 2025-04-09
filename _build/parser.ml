type token =
  | NOTE of (
# 3 "parser.mly"
        string
# 6 "parser.ml"
)
  | CHORD of (
# 4 "parser.mly"
        string
# 11 "parser.ml"
)
  | STAR
  | ID of (
# 6 "parser.mly"
        string
# 17 "parser.ml"
)
  | INSTANCE_VAR of (
# 7 "parser.mly"
        string
# 22 "parser.ml"
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
# 33 "parser.ml"
)
  | SEMICOLON
  | PLAYBACK_TEXT of (
# 13 "parser.mly"
        string
# 39 "parser.ml"
)
  | ASSIGN
  | NEW
  | REPEAT
  | COMPOSITION of (
# 17 "parser.mly"
        string
# 47 "parser.ml"
)
  | TRACK of (
# 18 "parser.mly"
        string
# 52 "parser.ml"
)
  | SECTION of (
# 19 "parser.mly"
        string
# 57 "parser.ml"
)
  | MEASURE of (
# 20 "parser.mly"
        string
# 62 "parser.ml"
)
  | NUMBER of (
# 21 "parser.mly"
        int
# 67 "parser.ml"
)
  | BEGIN
  | END
  | EOF

open Parsing
let _ = parse_error;;
# 1 "parser.mly"
open Ast 
# 77 "parser.ml"
let yytransl_const = [|
  259 (* STAR *);
  262 (* LEFT_BRAC *);
  263 (* RIGHT_BRAC *);
  264 (* LEFT_PAREN *);
  265 (* RIGHT_PAREN *);
  266 (* LEFT_CURLY *);
  267 (* RIGHT_CURLY *);
  269 (* SEMICOLON *);
  271 (* ASSIGN *);
  272 (* NEW *);
  273 (* REPEAT *);
  279 (* BEGIN *);
  280 (* END *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  257 (* NOTE *);
  258 (* CHORD *);
  260 (* ID *);
  261 (* INSTANCE_VAR *);
  268 (* PARAM *);
  270 (* PLAYBACK_TEXT *);
  274 (* COMPOSITION *);
  275 (* TRACK *);
  276 (* SECTION *);
  277 (* MEASURE *);
  278 (* NUMBER *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\003\000\003\000\005\000\004\000\004\000\
\006\000\006\000\006\000\006\000\008\000\008\000\009\000\009\000\
\009\000\009\000\009\000\007\000\007\000\010\000\010\000\010\000\
\010\000\011\000\011\000\011\000\012\000\012\000\012\000\013\000\
\013\000\014\000\014\000\016\000\015\000\015\000\000\000"

let yylen = "\002\000\
\002\000\000\000\002\000\001\000\005\000\003\000\000\000\003\000\
\003\000\003\000\004\000\001\000\002\000\001\000\002\000\003\000\
\003\000\003\000\001\000\000\000\002\000\001\000\001\000\001\000\
\001\000\000\000\002\000\002\000\000\000\003\000\003\000\000\000\
\002\000\000\000\002\000\001\000\001\000\001\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\012\000\000\000\022\000\023\000\024\000\
\025\000\039\000\000\000\000\000\004\000\000\000\000\000\000\000\
\000\000\000\000\001\000\003\000\000\000\000\000\013\000\000\000\
\000\000\009\000\000\000\008\000\019\000\000\000\000\000\000\000\
\010\000\021\000\011\000\000\000\037\000\038\000\036\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\005\000\018\000\000\000\000\000\033\000\035\000\
\016\000\028\000\017\000\027\000\000\000\030\000\031\000\006\000"

let yydgoto = "\002\000\
\010\000\011\000\012\000\013\000\051\000\014\000\026\000\015\000\
\033\000\016\000\048\000\049\000\041\000\042\000\043\000\044\000"

let yysindex = "\005\000\
\055\255\000\000\005\255\000\000\028\255\000\000\000\000\000\000\
\000\000\000\000\020\000\055\255\000\000\027\255\030\255\048\255\
\022\255\056\255\000\000\000\000\066\255\012\255\000\000\070\255\
\012\255\000\000\074\255\000\000\000\000\011\255\075\255\037\255\
\000\000\000\000\000\000\078\255\000\000\000\000\000\000\082\255\
\084\255\085\255\062\255\087\255\070\255\005\255\037\255\076\255\
\037\255\066\255\000\000\000\000\011\255\011\255\000\000\000\000\
\000\000\000\000\000\000\000\000\088\255\000\000\000\000\000\000"

let yyrindex = "\000\000\
\101\000\000\000\089\255\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\101\000\000\000\000\000\000\000\000\000\
\003\255\000\000\000\000\000\000\001\000\000\000\000\000\003\255\
\000\000\000\000\000\000\000\000\000\000\252\254\000\000\251\254\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\090\255\092\255\029\255\077\255\251\254\000\000\
\251\254\091\255\000\000\000\000\047\255\047\255\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\094\000\000\000\235\255\000\000\030\000\243\255\000\000\
\082\000\077\000\253\255\228\255\066\000\067\000\000\000\000\000"

let yytablesize = 274
let yytable = "\028\000\
\007\000\040\000\029\000\020\000\020\000\001\000\020\000\029\000\
\032\000\017\000\034\000\037\000\038\000\029\000\039\000\020\000\
\020\000\030\000\026\000\019\000\020\000\020\000\020\000\020\000\
\062\000\063\000\020\000\031\000\061\000\015\000\015\000\057\000\
\015\000\024\000\032\000\018\000\025\000\037\000\038\000\021\000\
\046\000\015\000\015\000\058\000\022\000\060\000\015\000\015\000\
\015\000\015\000\004\000\023\000\015\000\029\000\006\000\007\000\
\008\000\009\000\003\000\029\000\029\000\047\000\037\000\038\000\
\029\000\029\000\029\000\029\000\004\000\003\000\029\000\005\000\
\006\000\007\000\008\000\009\000\047\000\027\000\047\000\004\000\
\036\000\024\000\036\000\006\000\007\000\008\000\009\000\050\000\
\052\000\036\000\039\000\014\000\006\000\007\000\008\000\009\000\
\053\000\054\000\064\000\059\000\002\000\007\000\032\000\014\000\
\034\000\020\000\035\000\045\000\055\000\000\000\056\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\007\000\000\000\000\000\000\000\000\000\
\000\000\007\000"

let yycheck = "\021\000\
\000\000\030\000\007\001\001\001\002\001\001\000\004\001\013\001\
\013\001\005\001\024\000\001\001\002\001\002\001\004\001\013\001\
\014\001\006\001\024\001\000\000\018\001\019\001\020\001\021\001\
\053\000\054\000\024\001\016\001\050\000\001\001\002\001\045\000\
\004\001\012\001\023\001\008\001\015\001\001\001\002\001\013\001\
\004\001\013\001\014\001\047\000\015\001\049\000\018\001\019\001\
\020\001\021\001\014\001\004\001\024\001\007\001\018\001\019\001\
\020\001\021\001\004\001\013\001\014\001\032\000\001\001\002\001\
\018\001\019\001\020\001\021\001\014\001\004\001\024\001\017\001\
\018\001\019\001\020\001\021\001\047\000\022\001\049\000\014\001\
\004\001\012\001\009\001\018\001\019\001\020\001\021\001\010\001\
\007\001\013\001\004\001\015\001\018\001\019\001\020\001\021\001\
\013\001\013\001\011\001\024\001\000\000\011\001\013\001\015\001\
\013\001\012\000\025\000\031\000\043\000\255\255\044\000\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\011\001\255\255\255\255\255\255\255\255\
\255\255\017\001"

let yynames_const = "\
  STAR\000\
  LEFT_BRAC\000\
  RIGHT_BRAC\000\
  LEFT_PAREN\000\
  RIGHT_PAREN\000\
  LEFT_CURLY\000\
  RIGHT_CURLY\000\
  SEMICOLON\000\
  ASSIGN\000\
  NEW\000\
  REPEAT\000\
  BEGIN\000\
  END\000\
  EOF\000\
  "

let yynames_block = "\
  NOTE\000\
  CHORD\000\
  ID\000\
  INSTANCE_VAR\000\
  PARAM\000\
  PLAYBACK_TEXT\000\
  COMPOSITION\000\
  TRACK\000\
  SECTION\000\
  MEASURE\000\
  NUMBER\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'exec_tasks_list) in
    Obj.repr(
# 37 "parser.mly"
                     ( {body=_1} )
# 274 "parser.ml"
               : Ast.program))
; (fun __caml_parser_env ->
    Obj.repr(
# 44 "parser.mly"
                            ( [] )
# 280 "parser.ml"
               : 'exec_tasks_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'exec_tasks) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'exec_tasks_list) in
    Obj.repr(
# 45 "parser.mly"
                            ( _1 :: _2 )
# 288 "parser.ml"
               : 'exec_tasks_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr_list) in
    Obj.repr(
# 48 "parser.mly"
                                            ( Expr(_1) )
# 295 "parser.ml"
               : 'exec_tasks))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'body) in
    Obj.repr(
# 49 "parser.mly"
                                            ( Repeat(_3, _5) )
# 303 "parser.ml"
               : 'exec_tasks))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr_list) in
    Obj.repr(
# 52 "parser.mly"
                                                  ( Expr(_2) )
# 310 "parser.ml"
               : 'body))
; (fun __caml_parser_env ->
    Obj.repr(
# 59 "parser.mly"
                ( [] )
# 316 "parser.ml"
               : 'expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr_list) in
    Obj.repr(
# 60 "parser.mly"
                          ( _1 :: _3 )
# 324 "parser.ml"
               : 'expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'parameters) in
    Obj.repr(
# 63 "parser.mly"
                                               ( Call(Var(_1), ClassMethodLit(_2), _3))
# 333 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'assign_to) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'value) in
    Obj.repr(
# 64 "parser.mly"
                                               ( Asn(_1, _3) )
# 341 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'value) in
    Obj.repr(
# 65 "parser.mly"
                                               ( AsnInstVar(Var(_1), _2, _4) )
# 350 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 66 "parser.mly"
                                               ( Playback(_1) )
# 357 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'obj_class) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 69 "parser.mly"
                     ( Var(_2) )
# 365 "parser.ml"
               : 'assign_to))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 70 "parser.mly"
                     ( Var(_1) )
# 372 "parser.ml"
               : 'assign_to))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'obj_class) in
    Obj.repr(
# 73 "parser.mly"
                                ( ObjCallNoArgs(_2) :: [] )
# 379 "parser.ml"
               : 'value))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'obj_class) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'parameters) in
    Obj.repr(
# 74 "parser.mly"
                                ( ObjCallArgs(_2, _3) :: [] )
# 387 "parser.ml"
               : 'value))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'music) in
    Obj.repr(
# 75 "parser.mly"
                                ( print_endline("hello5");_2 )
# 394 "parser.ml"
               : 'value))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'measures) in
    Obj.repr(
# 76 "parser.mly"
                                ( Measures(_2) :: [] )
# 401 "parser.ml"
               : 'value))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 77 "parser.mly"
                                ( ChordLit(_1) :: [] )
# 408 "parser.ml"
               : 'value))
; (fun __caml_parser_env ->
    Obj.repr(
# 80 "parser.mly"
                   ( [] )
# 414 "parser.ml"
               : 'parameters))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'parameters) in
    Obj.repr(
# 81 "parser.mly"
                   ( Param(_1) :: _2 )
# 422 "parser.ml"
               : 'parameters))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 84 "parser.mly"
             ( ClassLit(_1) )
# 429 "parser.ml"
               : 'obj_class))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 85 "parser.mly"
             ( ClassLit(_1) )
# 436 "parser.ml"
               : 'obj_class))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 86 "parser.mly"
             ( ClassLit(_1) )
# 443 "parser.ml"
               : 'obj_class))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 87 "parser.mly"
             ( ClassLit(_1) )
# 450 "parser.ml"
               : 'obj_class))
; (fun __caml_parser_env ->
    Obj.repr(
# 95 "parser.mly"
                   ( [] )
# 456 "parser.ml"
               : 'music))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'measures) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'music) in
    Obj.repr(
# 96 "parser.mly"
                   ( print_endline("hello6"); Measures(_1) :: _2)
# 464 "parser.ml"
               : 'music))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'music) in
    Obj.repr(
# 97 "parser.mly"
                   ( Measures(_1 :: []) :: _2 )
# 472 "parser.ml"
               : 'music))
; (fun __caml_parser_env ->
    Obj.repr(
# 100 "parser.mly"
                               ( [] )
# 478 "parser.ml"
               : 'measures))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'notes_bar) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'measures) in
    Obj.repr(
# 101 "parser.mly"
                               ( print_endline("hello7");  Bar(_1) :: _3 )
# 486 "parser.ml"
               : 'measures))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'var_bar) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'measures) in
    Obj.repr(
# 102 "parser.mly"
                               ( print_endline("hello17");Bar(_1) :: _3 )
# 494 "parser.ml"
               : 'measures))
; (fun __caml_parser_env ->
    Obj.repr(
# 105 "parser.mly"
                        ( [] )
# 500 "parser.ml"
               : 'notes_bar))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'nonVarLit) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'notes_bar) in
    Obj.repr(
# 106 "parser.mly"
                        ( print_endline("hello8");  _1 :: _2 )
# 508 "parser.ml"
               : 'notes_bar))
; (fun __caml_parser_env ->
    Obj.repr(
# 109 "parser.mly"
                ( [] )
# 514 "parser.ml"
               : 'var_bar))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'var) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'var_bar) in
    Obj.repr(
# 110 "parser.mly"
                ( _1 :: _2 )
# 522 "parser.ml"
               : 'var_bar))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 113 "parser.mly"
     ( Var(_1) )
# 529 "parser.ml"
               : 'var))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 116 "parser.mly"
        ( print_endline("hello9"); NoteLit(_1) )
# 536 "parser.ml"
               : 'nonVarLit))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 117 "parser.mly"
        ( print_endline("hello10"); ChordLit(_1) )
# 543 "parser.ml"
               : 'nonVarLit))
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
