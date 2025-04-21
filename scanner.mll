{
open Parser
exception SyntaxError of string
}

let digit = ['0'-'9']+
let note = (['a'-'g'] | 'r')
let accidental = ('0'|'-'|'+')*
let alpha = ['a'-'z' 'A'-'Z']
let id = alpha (alpha | digit | '_')*
let whitespace = [' ' '\t' '\r']
let newline = '\n'

rule token = parse
  | [' ' '\t' '\r'] {
    print_endline "SKIP → WHITESPACE";
    token lexbuf
  }
  | '\n' {
      print_endline "SKIP → NEWLINE";
      Lexing.new_line lexbuf;
      token lexbuf
  }

  | "Composition"      { print_endline "LEX → COMPOSITION"; COMPOSITION }
  | "Track"            { print_endline "LEX → TRACK"; TRACK }
  | "Section"          { print_endline "LEX → SECTION"; SECTION }
  | "Measure"          { print_endline "LEX → MEASURE"; MEASURE }

  | ".measures"        { print_endline "LEX → DOT_MEASURES"; DOT_MEASURES }
  | ".addMeasures"     { print_endline "LEX → DOT_ADDMEASURES"; DOT_ADDMEASURES }
  | ".addSection"      { print_endline "LEX → DOT_ADDSECTION"; DOT_ADDSECTION }
  | ".addTrack"        { print_endline "LEX → DOT_ADDTRACK"; DOT_ADDTRACK }

  | "new"              { print_endline "LEX → NEW"; NEW }
  | "begin"            { print_endline "LEX → BEGIN"; BEGIN }
  | "end"              { print_endline "LEX → END"; END }
  | "repeat"           { print_endline "LEX → REPEAT"; REPEAT }
  | "for"              { print_endline "LEX → FOR"; FOR }
  | "int"              { print_endline "LEX → INT_KW"; INT_KW }

  | '='                { print_endline "LEX → ASSIGN"; ASSIGN }
  | ';'                { print_endline "LEX → SEMICOLON"; SEMICOLON }
  | '('                { print_endline "LEX → LPAREN"; LPAREN }
  | ')'                { print_endline "LEX → RPAREN"; RPAREN }
  | '['                { print_endline "LEX → LBRACKET"; LBRACKET }
  | ']'                { print_endline "LEX → RBRACKET"; RBRACKET }
  | ','                { print_endline "LEX → COMMA"; COMMA }
  | '{'                { print_endline "LEX → LBRACE"; LBRACE }
  | '}'                { print_endline "LEX → RBRACE"; RBRACE }

  | "<"                { print_endline "LEX → LT"; LT }
  | "++"               { print_endline "LEX → INCR"; INCR }

  | digit+ as n        { print_endline ("LEX → INT(" ^ n ^ ")"); INT(int_of_string n) }
  | id as s            { print_endline ("LEX → ID(" ^ s ^ ")"); ID(s) }
  (*
  | note accidental digit as note {
    print_endline ("LEX → NOTE(" ^ note ^ ")");
    NOTE(note)
  }
  *)
  | eof                { print_endline "LEX → EOF"; EOF }

  | _ as c {
    Printf.printf "CHAR CHECK → %c (code %d)\n" c (Char.code c);
    flush stdout;
    raise (SyntaxError ("CRASH CHAR: " ^ Char.escaped c))
  }

