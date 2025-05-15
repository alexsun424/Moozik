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
  | "Measures"    { MEASURES }
  | "Bars"        { BARS }
  | "Playback"    { PLAYBACK }
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
  | '{'           { LBRACE }
  | '}'           { RBRACE }
  | ','           { COMMA }
  | '.'           { DOT }
  | '/'           { SLASH }
  | int as num    { INT(int_of_string num) } 
  | note accidental digit as note { NOTE(note) }
  (* | 'c' '-' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      C_FLAT_NOTE(dur) 
    }
  | 'c' digit+ as note { 
      let dur = int_of_string (String.sub note 1 ((String.length note) - 1)) in
      C_NOTE(dur) 
    }
  | 'd' '+' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      D_SHARP_NOTE(dur) 
    }
  | 'd' '-' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      D_FLAT_NOTE(dur) 
    }
  | 'd' digit+ as note { 
      let dur = int_of_string (String.sub note 1 ((String.length note) - 1)) in
      D_NOTE(dur) 
    }
  | 'e' '+' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      E_SHARP_NOTE(dur) 
    }
  | 'e' '-' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      E_FLAT_NOTE(dur) 
    }
  | 'e' digit+ as note { 
      let dur = int_of_string (String.sub note 1 ((String.length note) - 1)) in
      E_NOTE(dur) 
    }
  | 'f' '+' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      F_SHARP_NOTE(dur) 
    }
  | 'f' '-' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      F_FLAT_NOTE(dur) 
    }
  | 'f' digit+ as note { 
      let dur = int_of_string (String.sub note 1 ((String.length note) - 1)) in
      F_NOTE(dur) 
    }
  | 'g' '+' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      G_SHARP_NOTE(dur) 
    }
  | 'g' '-' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      G_FLAT_NOTE(dur) 
    }
  | 'g' digit+ as note { 
      let dur = int_of_string (String.sub note 1 ((String.length note) - 1)) in
      G_NOTE(dur) 
    }
  | 'a' '+' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      A_SHARP_NOTE(dur) 
    }
  | 'a' '-' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      A_FLAT_NOTE(dur) 
    }
  | 'a' digit+ as note { 
      let dur = int_of_string (String.sub note 1 ((String.length note) - 1)) in
      A_NOTE(dur) 
    }
  | 'b' '+' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      B_SHARP_NOTE(dur) 
    }
  | 'b' '-' digit+ as note { 
      let dur = int_of_string (String.sub note 2 ((String.length note) - 2)) in
      B_FLAT_NOTE(dur) 
    }
  | 'b' digit+ as note { 
      let dur = int_of_string (String.sub note 1 ((String.length note) - 1)) in
      B_NOTE(dur) 
  } *)
  (* | 'r' digit+ as note { 
      let dur = int_of_string (String.sub note 1 ((String.length note) - 1)) in
      R_NOTE(dur)
    } *)
  | id as s       { ID(s) }
  | '$'           { print_endline("$ eof"); EOF }
  | eof			      { print_endline("eof"); EOF }
  | _ as char     { raise (SyntaxError ("Unexpected character: " ^ Char.escaped char)) }