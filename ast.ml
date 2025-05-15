(* Note representation *)
type note = string

(* A sequence of notes *)
type measures = note list

(* Variable declaration in music section *)
type var = string * measures

(* Music items can be variables (ref), measures, or repeat blocks *)
type music_item = 
  | Notes of measures
  | VarRef of string
  | Repeat of repeat_expr

  (* Repeat expression *)
and repeat_expr = {
  count: int;
  body: music_item list;
}

(* Music section with variables and measures *)
type music_section = {
  variables: var list;
  bars: music_item list
}

(* Section contains measures *)
type section = {
  measures: music_section list;
}

(* Track contains sections *)
type track = {
  sections: section list;
}

(* Composition contains tracks *)
type composition = {
  tracks: track list;
}

type expr =
 | Ident   of string
 | Member  of expr * string
 | IntLit  of int 
 | TimeSig of int * int 

(* Statement types for our language *)
type stmt =
  | CompDecl of string                           (* Composition testComp; *)
  | TrackDecl of string                          (* Track testTrack; *)
  | SectionDecl of string                        (* Section testSection; *)
  | MeasureDecl of string                        (* Measure testMeasures; *)
  | MeasuresAssign of string * music_section     (* testMeasures.measures = begin; ..end; *)
  | AddMeasures of string * string               (* testSection.addMeasures(testMeasures.measures); *)
  | AddSection of string * string                (* testTrack.addSection(testSection); *)
  | AddTrack of string * string                  (* testComp.addTrack(testTrack); *)
  | SetKey of string * int                       (* testSection.setKey(100); *)
  | SetInstrument of string * string             (* testTrack.setInstrument(piano); *)
  | SetTiming of string * int * int              (* testSection.setTiming(4/4); *)

(* Program is a list of statements *)
type program = stmt list

(* String conversion functions *)
let string_of_measures measures =
  String.concat " " measures

let string_of_var (name, notes) =
  name ^ " = [" ^ string_of_measures notes ^ "]"

(* we no longer append “;”—we just print exactly what string_of_measures gives us *)
let string_of_bar measures =
  string_of_measures measures

let rec string_of_music_item = function
  | Notes measures -> string_of_measures measures
  | VarRef var_name -> var_name
  | Repeat repeat_expr -> 
      "repeat(" ^ string_of_int repeat_expr.count ^ "){\n\t" ^ 
      String.concat "\n\t" (List.map string_of_music_item repeat_expr.body) ^
      "\n}"

let string_of_music_section section =
  "begin;\n"
  ^ String.concat "\n" (List.map string_of_var section.variables)
  ^ (if section.variables <> [] then "\n" else "")
  ^ String.concat "\n" (List.map string_of_music_item section.bars)
  ^ "\nend;"

let string_of_stmt = function
  | CompDecl id -> "Composition " ^ id ^ ";"
  | TrackDecl id -> "Track " ^ id ^ ";"
  | SectionDecl id -> "Section " ^ id ^ ";"
  | MeasureDecl id -> "Measure " ^ id ^ ";"
  | MeasuresAssign (id, section) -> 
      id ^ ".measures = " ^ string_of_music_section section
  | AddMeasures (section_id, measures_id) ->
      section_id ^ ".addMeasures(" ^ measures_id ^ ".measures);"
  | AddSection (track_id, section_id) ->
      track_id ^ ".addSection(" ^ section_id ^ ");"
  | AddTrack (comp_id, track_id) ->
      comp_id ^ ".addTrack(" ^ track_id ^ ");"
  | SetKey (section_id, key) ->
      section_id ^ ".setKey(" ^ string_of_int key ^ ");"
  | SetInstrument (track_id, instrument) ->
    track_id ^ ".setInstrument(" ^ instrument ^ ");"
  | SetTiming (section_id, num, denom) ->
      section_id ^ ".setTiming(" ^ string_of_int num ^ "/" ^ string_of_int denom ^ ");"

let extract_id_of_expr = function
 | Ident s -> s
 | Member (Ident s, _) -> s
 | IntLit i -> string_of_int i 
 | TimeSig(_, _) -> failwith "Time signature cannot be used as an identifier"
 | _ -> failwith "Expected simple Ident, Member, or IntLit"

 let find_function receiver_name method_name arg_expr =
  match method_name with
    | "addMeasures" ->
        (* get just the ID of the argument to pass into the stmt *)
        let arg_id = extract_id_of_expr arg_expr in
        (* e.g. testSection.addMeasures(testMeasures.measures) *)
        let measures_id = arg_id in
        AddMeasures (receiver_name, measures_id)

    | "addSection" ->
        let arg_id = extract_id_of_expr arg_expr in
        let section_id = arg_id in
        AddSection (receiver_name, section_id)

    | "addTrack" ->
        let arg_id = extract_id_of_expr arg_expr in
        let track_id = arg_id in
        AddTrack (receiver_name, track_id)
    
    | "setKey" ->
      let key_value = match arg_expr with
        | IntLit i -> i
        | _ -> failwith "setKey expects an integer argument"
        in
        let () = Printf.printf "Parsed SetKey: %s -> %d\n%!"
          receiver_name key_value in
            SetKey (receiver_name, key_value)
    
    | "setInstrument" ->
        let instrument = match arg_expr with
          | Ident s -> s
          | _ -> failwith "setInstrument expects an instrument name"
        in
        SetInstrument (receiver_name, instrument)
    
    | "setTiming" ->
        let (num, denom) = match arg_expr with
          | TimeSig (n, d) -> (n, d)
          | _ -> failwith "setTiming expects a time signature"
        in
        SetTiming (receiver_name, num, denom)

    | other ->
        failwith ("Unknown method name in FindFunction: " ^ other)

let string_of_program stmts =
  "\n\nParsed program: \n\n" ^
  String.concat "\n" (List.map string_of_stmt stmts)