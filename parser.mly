%{open Ast %}

%token NEWLINE
%token <string>NOTE <string>CHORD
%token STAR
%token <string> ID
%token <string> INSTANCE_VAR
%token LEFT_BRAC RIGHT_BRAC 
%token LEFT_PAREN RIGHT_PAREN 
%token SEMICOLON
%token <string> PLAYBACK_TEXT
%token EQUALS
%token NEW
%token COMPOSITION TRACK SECTION MEASURE
%token BEGIN END

%left LEFT_BRAC LEFT_PARENT
%left SEMICOLON
%right RIGHT_BRAC RIGHT_PAREN
%right ASSIGN

%start program
%type <Ast.program> program


%%

program:
|expr 
|WHILE expr
|IF expr

expr:
|                                  { [] }
|assign_to ASSIGN value expr       { ASN($1, $3) }
|ID INSTANCE_VAR ASSIGN value expr { ASNInstVar($1, $2, $3) }
|PLAYBACK_TEXT expr

assign_to:
|class ID        { $2 } 
|ID              { $1 } 

value:
|NEW class LEFT_PAREN RIGHT_PAREN { $2 } 
|BEGIN measures END               { $1 }
|LEFT_BRAC measures RIGHT_BRAC    { $1 }
|CHORD                            { '{' ^ $1 ^ '}' }

class:
|COMPOSITION { $1 }
|TRACK       { $1 }
|SECTION     { $1 }

measures:
|                        { "" }
| bar SEMICOLON measures { $3 ^ $1 }

bar:
                  { "" }              
| nonVarLit bar   { $2 ^ $1 }                          
| var             { $1 }                 

var:
| ID { Var($1) } 

nonVarLit:
| NOTE  { $1 } 
| CHORD { '{' ^ $1 ^ '}' }













