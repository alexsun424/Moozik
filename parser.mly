%{
  open Ast
%}

%token <string> ID
%token <string> NOTE
// %token <int> D_NOTE D_SHARP_NOTE D_FLAT_NOTE
// %token <int> E_NOTE E_SHARP_NOTE E_FLAT_NOTE
// %token <int> F_NOTE F_SHARP_NOTE F_FLAT_NOTE
// %token <int> G_NOTE G_SHARP_NOTE G_FLAT_NOTE
// %token <int> A_NOTE A_SHARP_NOTE A_FLAT_NOTE
// %token <int> B_NOTE B_SHARP_NOTE B_FLAT_NOTE
%token <int> R_NOTE
%token COMPOSITION TRACK SECTION MEASURE
%token DOT_MEASURES DOT_ADDMEASURES DOT_ADDSECTION DOT_ADDTRACK
%token NEW BEGIN END
%token ASSIGN SEMICOLON LPAREN RPAREN LBRACKET RBRACKET COMMA
%token EOF

%start program_rule
%type <Ast.program> program_rule
%type <Ast.music_section> music_section

%%

program_rule:
  stmts EOF { $1 }


stmts:
  /* empty */ { [] }
| stmt stmts { $1 :: $2 }


stmt:
  COMPOSITION ID ASSIGN NEW COMPOSITION LPAREN RPAREN SEMICOLON
    { CompDecl($2) }
| TRACK ID ASSIGN NEW TRACK LPAREN RPAREN SEMICOLON
    { TrackDecl($2) }
| SECTION ID ASSIGN NEW SECTION LPAREN RPAREN SEMICOLON
    { SectionDecl($2) }
| MEASURE ID ASSIGN NEW MEASURE LPAREN RPAREN SEMICOLON
    { MeasureDecl($2) }
| ID DOT_MEASURES ASSIGN BEGIN SEMICOLON music_section 
    { MeasuresAssign($1, $6) }
| ID DOT_ADDMEASURES LPAREN ID DOT_MEASURES RPAREN SEMICOLON
    { AddMeasures($1, $4) }
| ID DOT_ADDSECTION LPAREN ID RPAREN SEMICOLON
    { AddSection($1, $4) }
| ID DOT_ADDTRACK LPAREN ID RPAREN SEMICOLON
    { AddTrack($1, $4) }

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