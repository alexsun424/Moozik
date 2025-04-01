%{open Ast %}

%token NEWLINE
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

%start program
%type <Ast.program> program


%%

program:
PLAYBACK_TEXT  { Playback($1) }



// SP:
// |LEFT ASSIGN SPP

// SPP:
// |NEW CLASS
// |BEGIN MEASURES END
// |LEFT_BRAC MEASURES RIGHT_BRAC

// CLASS:
// |COMPOSITION
// |TRACK
// |SECTION

// MEASURES:
// |BAR SEMICOLON MEASURES
// |BAR SEMICOLON

// BAR:
// |VAR
// |






