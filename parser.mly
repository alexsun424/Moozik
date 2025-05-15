%{
  open Ast
%}

%token <string> ID
%token <string> NOTE
%token <int> INT  
%token <int> R_NOTE
%token PLAYBACK COMPOSITION TRACK SECTION MEASURE MEASURES BARS
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

music_object:
  | COMPOSITION      { Composition }
  | TRACK            { Track }
  | SECTION          { Section }
  | BARS             { Bars }
  | MEASURES         { Measures }

stmt:
 COMPOSITION ID ASSIGN NEW COMPOSITION LPAREN RPAREN SEMICOLON
   { CompDecl($2) }
| TRACK ID ASSIGN NEW TRACK LPAREN RPAREN SEMICOLON
   { TrackDecl($2) }
| SECTION ID ASSIGN NEW SECTION LPAREN RPAREN SEMICOLON
   { SectionDecl($2) }
| MEASURE ID ASSIGN NEW MEASURE LPAREN RPAREN SEMICOLON
   { MeasureDecl($2) }
| ID DOT ID ASSIGN music_section SEMICOLON
   { if $3 = "measures" then MeasuresAssign($1, $5)
     else failwith ("Unknown property: " ^ $3) }
| ID DOT ID LPAREN expr RPAREN SEMICOLON
   { find_function $1 $3 $5 }
| PLAYBACK LPAREN music_object RPAREN SEMICOLON
   { playback $3 }

music_section:
| BEGIN music_stmts END { $2 }

music_stmts:
    /* empty */                     { { variables = []; bars = [] } }
  | music_stmts vdecl_rule          { { variables = $1.variables @ [ $2 ]; bars = $1.bars } }
  | music_stmts music_item          { { variables = $1.variables; bars = $1.bars @ [ $2 ] } }

vdecl_rule:
  ID ASSIGN LBRACKET bar_rule RBRACKET { ($1, $4) }

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
  /* end */ SEMICOLON { [] }
| note_list bar_rule  { $1 :: $2 }
| chord_rule bar_rule { $1 :: $2 }

chord_rule:
  LBRACE note_list RBRACE { ($2) }

note_list:
  /* empty */    { [] }
| NOTE note_list { $1 :: $2 }

%%