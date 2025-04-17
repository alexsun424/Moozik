(* Note pitch representation with accidentals *)
(* type pitch =
  | C | CSharp | CFlat
  | D | DSharp | DFlat
  | E | ESharp | EFlat
  | F | FSharp | FFlat
  | G | GSharp | GFlat
  | A | ASharp | AFlat
  | B | BSharp | BFlat
  | R  Rest *)

(* Note value (duration) *)
(* type duration = int   *)
(* 1 = quarter note, 2 = half note, 4 = whole note, etc. *)

(* Accidental type *)
(* type accidental = 
  | Sharp
  | Flat
  | Natural *)

(* Note representation *)
type note = string

(* A sequence of notes *)
type measures = note list

(* Variable declaration in music section *)
type var = string * measures

(* Music section with variables and measures *)
type music_section = {
  variables: var list;
  bars: measures list
  (* measures: measures; *)
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

let string_of_music_section section =
  "begin;\n"
  ^ String.concat "\n" (List.map string_of_var section.variables)
  ^ (if section.variables <> [] then "\n" else "")
  ^ String.concat "\n" (List.map string_of_bar section.bars)
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

let string_of_program stmts =
  "\n\nParsed program: \n\n" ^
  String.concat "\n" (List.map string_of_stmt stmts)