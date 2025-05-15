(* Define the necessary types directly here *)
type note = string

(* Semantically-checked music items *)
type smusic_item = 
  | SNotes of note list
  | SVarRef of string
  | SRepeat of srepeat_expr

(* Semantically-checked repeat expression *)
and srepeat_expr = {
  scount: int;
  sbody: smusic_item list;
}

(* Semantically-checked music section with variables and measures *)
type smusic_section = {
  svariables: (string * note list) list;
  sbars: smusic_item list
}

(* Semantically-checked statements *)
type sstmt =
  | SCompDecl of string                            (* Composition testComp; *)
  | STrackDecl of string                           (* Track testTrack; *)
  | SSectionDecl of string                         (* Section testSection; *)
  | SMeasureDecl of string                         (* Measure testMeasures; *)
  | SMeasuresAssign of string * smusic_section     (* testMeasures.measures = begin; ..end; *)
  | SAddMeasures of string * string                (* testSection.addMeasures(testMeasures.measures); *)
  | SAddSection of string * string                 (* testTrack.addSection(testSection); *)
  | SAddTrack of string * string                   (* testComp.addTrack(testTrack); *)
  | SSetKey of string * int                        (* testSection.setKey(100); *)
  | SSetInstrument of string * string              (* testTrack.setInstrument(piano); *)
  | SSetTiming of int * int                        (* testSection.setTiming(4/4); *)

(* Semantically-checked program *)
type sprogram = sstmt list

(* Pretty-printing functions *)
let rec string_of_smusic_item = function
  | SNotes notes -> String.concat " " notes
  | SVarRef var_name -> var_name
  | SRepeat repeat_expr -> 
      "repeat(" ^ string_of_int repeat_expr.scount ^ "){\n\t" ^ 
      String.concat "\n\t" (List.map string_of_smusic_item repeat_expr.sbody) ^
      "\n}"

let string_of_svar (name, notes) =
  name ^ " = [" ^ String.concat " " notes ^ "]"

let string_of_smusic_section section =
  "begin;\n"
  ^ String.concat "\n" (List.map string_of_svar section.svariables)
  ^ (if section.svariables <> [] then "\n" else "")
  ^ String.concat "\n" (List.map string_of_smusic_item section.sbars)
  ^ "\nend;"

let string_of_sstmt = function
  | SCompDecl id -> "Composition " ^ id ^ ";"
  | STrackDecl id -> "Track " ^ id ^ ";"
  | SSectionDecl id -> "Section " ^ id ^ ";"
  | SMeasureDecl id -> "Measure " ^ id ^ ";"
  | SMeasuresAssign (id, section) -> 
      id ^ ".measures = " ^ string_of_smusic_section section
  | SAddMeasures (section_id, measures_id) ->
      section_id ^ ".addMeasures(" ^ measures_id ^ ".measures);"
  | SAddSection (track_id, section_id) ->
      track_id ^ ".addSection(" ^ section_id ^ ");"
  | SAddTrack (comp_id, track_id) ->
      comp_id ^ ".addTrack(" ^ track_id ^ ");"
  | SSetKey (section_id, key) ->
      section_id ^ ".setKey(" ^ string_of_int key ^ ");"
  | SSetInstrument (track_id, instrument) ->
      track_id ^ ".setInstrument(" ^ instrument ^ ");"  
  | SSetTiming (num, denom) ->
      "Composition's timing is set to(" ^ string_of_int num ^ "/" ^ string_of_int denom ^ ");"

let string_of_sprogram sstmts =
  "\n\nSemantically checked program: \n\n" ^
  String.concat "\n" (List.map string_of_sstmt sstmts) 