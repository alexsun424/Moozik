%{
  open Ast
%}

%token <string> ID
%token <string> NOTE
%token <int> INT  
// %token <int> D_NOTE D_SHARP_NOTE D_FLAT_NOTE
// %token <int> E_NOTE E_SHARP_NOTE E_FLAT_NOTE
// %token <int> F_NOTE F_SHARP_NOTE F_FLAT_NOTE
// %token <int> G_NOTE G_SHARP_NOTE G_FLAT_NOTE
// %token <int> A_NOTE A_SHARP_NOTE A_FLAT_NOTE
// %token <int> B_NOTE B_SHARP_NOTE B_FLAT_NOTE
%token <int> R_NOTE
%token COMPOSITION TRACK SECTION MEASURE
%token DOT
%token NEW BEGIN END
%token ASSIGN SEMICOLON LPAREN RPAREN LBRACKET RBRACKET COMMA
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
  | music_stmts bar_rule            { { variables = $1.variables; bars = $1.bars @ [ $2 ] } }
  | music_stmts var_ref_rule        { { variables = $1.variables; bars = $1.bars @ [ $2 ] } }

var_ref_rule:
 ID { [$1] }

vdecl_rule:
  ID ASSIGN LBRACKET bar_rule RBRACKET { ($1, $4) }

bar_rule:
| note_list SEMICOLON { $1 }

note_list:
| NOTE { [$1] }
| NOTE note_list { $1 :: $2}


%%