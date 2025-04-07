%{open Ast %}

%token NEWLINE
%token SHARP FLAT NATURAL
%token STAR
%token <string> VARIABLE
%token LEFT_BRAC RIGHT_BRAC 
%token LEFT_PAREN RIGHT_PAREN 
%token SEMICOLON
%token <string> PLAYBACK_TEXT
%token EQUALS
%token NEW
%token COMPOSITION TRACK SECTION MEASURE

%left LEFT_BRAC LEFT_PARENT
%right RIGHT_BRAC RIGHT_PAREN

%start composition
%type <Ast.composition> composition


%%

composition:
|assign_left ASSIGN value composition
|assign_left ASSIGN value
|PLAYBACK_TEXT composition
|PLAYBACK_TEXT

assign_left:
|class ID
|ID INSTANCE_VAR
|ID 

value:
|NEW class LEFT_PAREN RIGHT_PAREN
|measures 
|LEFT_BRAC measures RIGHT_BRAC
|LEFT_PAREN measures RIGHT_PAREN

class:
|COMPOSITION
|TRACK
|SECTION

measures:
|bar SEMICOLON measures
|bar SEMICOLON

bar:
|id SEMICOLON { measures($1) }
|note star bar { measures($1) }
|note star SEMICOLON { measures($1) }
|note bar { measures($1) }
|note SEMICOLON { measures($1) }
|STAR SEMICOLON bar { measures($1) }
|STAR SEMICOLON { measures($1) }

star:
|bar { $1 }

note:
NOTE DUR sign { note($1, $2, $3) }

sign:
        { $1 }
SHARP   { $1 }
FLAT    { $1 }
NATURAL { $1 }







