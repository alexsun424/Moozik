%{
  open Ast
%}

%token <string> ID
%token <int> C_NOTE C_SHARP_NOTE C_FLAT_NOTE
%token <int> D_NOTE D_SHARP_NOTE D_FLAT_NOTE
%token <int> E_NOTE E_SHARP_NOTE E_FLAT_NOTE
%token <int> F_NOTE F_SHARP_NOTE F_FLAT_NOTE
%token <int> G_NOTE G_SHARP_NOTE G_FLAT_NOTE
%token <int> A_NOTE A_SHARP_NOTE A_FLAT_NOTE
%token <int> B_NOTE B_SHARP_NOTE B_FLAT_NOTE
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
| vdecl_list_rule END SEMICOLON { { variables = $1;} }


vdecl_list_rule:
  /* empty */ { [] }
| vdecl_rule vdecl_list_rule { $1 :: $2 }

vdecl_rule:
  ID ASSIGN LBRACKET bar_list_rule RBRACKET { ($1, $4) }


bar_list_rule:
  /* empty */ { [] }
| note bar_list_rule { $1 :: $2 }
| SEMICOLON bar_list_rule { $2 }


note:
| C_NOTE                     { { pitch = C; duration = $1 } }
| C_SHARP_NOTE               { { pitch = CSharp; duration = $1 } }
| C_FLAT_NOTE                { { pitch = CFlat; duration = $1 } }
| D_NOTE                     { { pitch = D; duration = $1 } }
| D_SHARP_NOTE               { { pitch = DSharp; duration = $1 } }
| D_FLAT_NOTE                { { pitch = DFlat; duration = $1 } }
| E_NOTE                     { { pitch = E; duration = $1 } }
| E_SHARP_NOTE               { { pitch = ESharp; duration = $1 } }
| E_FLAT_NOTE                { { pitch = EFlat; duration = $1 } }
| F_NOTE                     { { pitch = F; duration = $1 } }
| F_SHARP_NOTE               { { pitch = FSharp; duration = $1 } }
| F_FLAT_NOTE                { { pitch = FFlat; duration = $1 } }
| G_NOTE                     { { pitch = G; duration = $1 } }
| G_SHARP_NOTE               { { pitch = GSharp; duration = $1 } }
| G_FLAT_NOTE                { { pitch = GFlat; duration = $1 } }
| A_NOTE                     { { pitch = A; duration = $1 } }
| A_SHARP_NOTE               { { pitch = ASharp; duration = $1 } }
| A_FLAT_NOTE                { { pitch = AFlat; duration = $1 } }
| B_NOTE                     { { pitch = B; duration = $1 } }
| B_SHARP_NOTE               { { pitch = BSharp; duration = $1 } }
| B_FLAT_NOTE                { { pitch = BFlat; duration = $1 } }
| R_NOTE                     { { pitch = R; duration = $1 } }


%%