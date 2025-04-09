%{open Ast %}

%token <string>NOTE 
%token <string>CHORD
%token STAR
%token <string> ID
%token <string> INSTANCE_VAR
%token LEFT_BRAC RIGHT_BRAC 
%token LEFT_PAREN RIGHT_PAREN 
%token LEFT_CURLY RIGHT_CURLY
%token <string> PARAM
%token SEMICOLON
%token <string> PLAYBACK_TEXT
%token ASSIGN
%token NEW
%token REPEAT
%token <string> COMPOSITION 
%token <string> TRACK 
%token <string> SECTION 
%token <string> MEASURE
%token <int> NUMBER
%token BEGIN END
%token EOF

%left LEFT_BRAC LEFT_PAREN
%left SEMICOLON
%right RIGHT_BRAC RIGHT_PAREN
%right ASSIGN

%start program
%type <Ast.program> program


%%

program:
|exec_tasks_list EOF { {body=$1} }

//Below is the "highest" level of the code; 
//Expr is essentially our equivalent of a block of code
//While loop is on a parallel level to a block of code

exec_tasks_list:
|                           { [] }
|exec_tasks exec_tasks_list { $1 :: $2 }

exec_tasks:
|expr_list                                  { Expr($1) }
|REPEAT LEFT_PAREN NUMBER RIGHT_PAREN body  { Repeat($3, $5) }

body:
| LEFT_CURLY expr_list RIGHT_CURLY                { Expr($2) }

//Bellow is the middle level of code;
//This represents what happens on a line by line level:
//For us, this means mostly just variable assignments and function invocations

expr_list:
|               { [] }
|expr SEMICOLON expr_list { $1 :: $3 }

expr:
|ID INSTANCE_VAR parameters                    { Call(Var($1), ClassMethodLit($2), $3)} 
|assign_to ASSIGN value                        { Asn($1, $3) }
|ID INSTANCE_VAR ASSIGN value                  { AsnInstVar(Var($1), $2, $4) }
|PLAYBACK_TEXT                                 { Playback($1) }

assign_to:
|obj_class ID        { Var($2) } 
|ID                  { Var($1) } 

value:
|NEW obj_class                  { ObjCallNoArgs($2) :: [] } 
|NEW obj_class parameters       { ObjCallArgs($2, $3) :: [] } 
|BEGIN music END                { print_endline("hello5");$2 }
|LEFT_BRAC measures RIGHT_BRAC  { Measures($2) :: [] }
|CHORD                          { ChordLit($1) :: [] }

parameters:
                   { [] }
| PARAM parameters { Param($1) :: $2 }

obj_class:
|COMPOSITION { ClassLit($1) }
|TRACK       { ClassLit($1) }
|SECTION     { ClassLit($1) }
|MEASURE     { ClassLit($1) }

//Below is the section where the actual musical notation section is processed
//This includes dealing with our version of literals (notes and chords)
//Assigning even local variables for measures and grouping all elements
//into the the correct datatype

music:
|                  { [] }
| measures music   { print_endline("hello6"); Measures($1) :: $2} 
| expr music       { Measures($1 :: []) :: $2 }

measures:
|                              { [] }
| notes_bar SEMICOLON measures { print_endline("hello7");  Bar($1) :: $3 } 
| var_bar SEMICOLON measures   { print_endline("hello17");Bar($1) :: $3 } 

notes_bar:
                        { [] }              
| nonVarLit notes_bar   { print_endline("hello8");  $1 :: $2 }       

var_bar:
                { [] } 
| var var_bar   { $1 :: $2 }   
              
var:
| ID { Var($1) } 

nonVarLit:
| NOTE  { print_endline("hello9"); NoteLit($1) } 
| CHORD { print_endline("hello10"); ChordLit($1) }













