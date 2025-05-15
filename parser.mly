%{
  open Ast
%}

%token <string> ID
%token <string> NOTE
%token <int> INT  
%token <int> R_NOTE
%token COMPOSITION TRACK SECTION MEASURE
%token DOT
%token NEW BEGIN END REPEAT
%token ASSIGN SEMICOLON LPAREN RPAREN LBRACKET RBRACKET COMMA LBRACE RBRACE
%token SLASH
%token EOF

%start program_rule
%type <Ast.program> program_rule
%type <Ast.music_section> music_section
%type <Ast.expr> expr


%%

program_rule:
  stmts EOF { $1 }


stmts:
  /* empty */ { [] }
| stmt stmts { $1 :: $2 }

expr:
 | ID                { Ident $1 }
 | INT               { IntLit $1 }
 | ID DOT ID         { Member (Ident $1, $3) }
 | INT SLASH INT     { TimeSig($1, $3) } 

stmt:
 COMPOSITION ID ASSIGN NEW COMPOSITION LPAREN RPAREN SEMICOLON
   { CompDecl($2) }
| TRACK ID ASSIGN NEW TRACK LPAREN RPAREN SEMICOLON
   { TrackDecl($2) }
| SECTION ID ASSIGN NEW SECTION LPAREN RPAREN SEMICOLON
   { SectionDecl($2) }
| MEASURE ID ASSIGN NEW MEASURE LPAREN RPAREN SEMICOLON
   { MeasureDecl($2) }
| ID DOT ID ASSIGN BEGIN SEMICOLON music_section
   { if $3 = "measures" then MeasuresAssign($1, $7)
     else failwith ("Unknown property: " ^ $3) }
| ID DOT ID LPAREN expr RPAREN SEMICOLON
   { find_function $1 $3 $5 }

music_section:
| music_stmts END SEMICOLON { $1 }

music_stmts:
    /* empty */                     { { variables = []; bars = [] } }
  | music_stmts vdecl_rule          { { variables = $1.variables @ [ $2 ]; bars = $1.bars } }
  | music_stmts music_item          { { variables = $1.variables; bars = $1.bars @ [ $2 ] } }

vdecl_rule:
  ID ASSIGN LBRACKET bar_list RBRACKET { 
    let all_notes = List.concat $4 in
    ($1, all_notes)
  }

bar_list:
  | bar_rule { [$1] }
  | bar_rule bar_list { $1 :: $2 }

music_item:
  | bar_rule                { Notes($1) }
  | var_ref_rule            { VarRef($1) } 
  | repeat_rule             { Repeat($1) }

repeat_rule:
  | REPEAT LPAREN INT RPAREN LBRACE music_item_list RBRACE 
      { { count = $3; body = $6 } }
  | error { 
      Printf.eprintf "Error parsing repeat expression\n"; 
      flush stderr;
      { count = 0; body = [] } 
    }

music_item_list:
  | /* empty */             { [] }
  | music_item music_item_list  { $1 :: $2 }

var_ref_rule:
| ID { $1 }

bar_rule:
| note_list SEMICOLON { $1 }

note_list:
| NOTE { [$1] }
| NOTE note_list { $1 :: $2 }


%%