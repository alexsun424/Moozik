{
open Parser
exception SyntaxError of string
}

let digit = ['0'-'9']
let note = (['a'-'g'] | 'r')
let accidental = ('0'|'-'|'+')*
let alpha = ['a'-'z' 'A'-'Z']
let id = alpha (alpha | digit | '_')*
let whitespace = [' ' '\t' '\r']
let newline = '\n'
let int = digit+


rule token = parse
  | whitespace    { token lexbuf }
  | newline       { Lexing.new_line lexbuf; token lexbuf }
  | "Composition" { COMPOSITION }
  | "Track"       { TRACK }
  | "Section"     { SECTION }
  | "Measure"     { MEASURE }
  | "new"         { NEW }
  | "begin"       { BEGIN }
  | "end"         { END }
  | "repeat"      { REPEAT }
  | '='           { ASSIGN }
  | ';'           { SEMICOLON }
  | '('           { LPAREN }
  | ')'           { RPAREN }
  | '['           { LBRACKET }
  | ']'           { RBRACKET }
  | '<'           { LVECT }
  | '>'           { RVECT }
  | '{'           { LBRACE }
  | '}'           { RBRACE }
  | ','           { COMMA }
  | '.'           { DOT }
  | '/'           { SLASH }
  | int as num    { INT(int_of_string num) } 
  | note accidental digit as note { NOTE(note) }
  | id as s       { ID(s) }
  | '$'           { print_endline("$ eof"); EOF }
  | eof			      { print_endline("eof"); EOF }
  | _ as char     { raise (SyntaxError ("Unexpected character: " ^ Char.escaped char)) }