(* Note pitch representation with accidentals *)
type pitch =
  | C | CSharp | CFlat
  | D | DSharp | DFlat
  | E | ESharp | EFlat
  | F | FSharp | FFlat
  | G | GSharp | GFlat
  | A | ASharp | AFlat
  | B | BSharp | BFlat
  | R  (* Rest *)

(* Note value (duration) *)
type duration = int  (* 1 = quarter note, 2 = half note, 4 = whole note, etc. *)

(* Accidental type *)
type accidental = 
  | Sharp
  | Flat
  | Natural

(* Note representation *)
type note = {
  pitch: pitch;
  duration: duration;
}

(* A sequence of notes *)
type measures = note list

(* Variable declaration in music section *)
type var = string * measures

(* Music section with variables and measures *)
type music_section = {
  variables: var list;
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
let string_of_pitch = function
  | C -> "C"
  | CSharp -> "C#"
  | CFlat -> "Cb"
  | D -> "D"
  | DSharp -> "D#"
  | DFlat -> "Db"
  | E -> "E"
  | ESharp -> "E#"
  | EFlat -> "Eb"
  | F -> "F"
  | FSharp -> "F#"
  | FFlat -> "Fb"
  | G -> "G"
  | GSharp -> "G#"
  | GFlat -> "Gb"
  | A -> "A"
  | ASharp -> "A#"
  | AFlat -> "Ab"
  | B -> "B"
  | BSharp -> "B#"
  | BFlat -> "Bb"
  | R -> "Rest"

let string_of_duration = function
  | 1 -> "quarter note"
  | 2 -> "half note"
  | 4 -> "whole note"
  | n -> string_of_int n ^ " duration"

let string_of_note note =
  Printf.sprintf "%s (%s)" (string_of_pitch note.pitch) (string_of_duration note.duration)

let detailed_string_of_measures measures =
  String.concat ", " (List.map string_of_note measures)

let string_of_measures measures =
  String.concat " " (List.map (fun note -> 
    let base_note = match note.pitch with
      | C | CSharp | CFlat -> "c"
      | D | DSharp | DFlat -> "d"
      | E | ESharp | EFlat -> "e"
      | F | FSharp | FFlat -> "f"
      | G | GSharp | GFlat -> "g"
      | A | ASharp | AFlat -> "a"
      | B | BSharp | BFlat -> "b"
      | R -> "r"
    in
    let accidental = match note.pitch with
      | CSharp | DSharp | ESharp | FSharp | GSharp | ASharp | BSharp -> "+"
      | CFlat | DFlat | EFlat | FFlat | GFlat | AFlat | BFlat -> "-"
      | _ -> ""
    in
    base_note ^ accidental ^ string_of_int note.duration
  ) measures)

let string_of_var (name, notes) =
  name ^ " = [" ^ (detailed_string_of_measures notes) ^ "]"


let string_of_music_section section =
  "begin;\n" ^
  String.concat "\n" (List.map string_of_var section.variables) ^
  (if List.length section.variables > 0 then "\n" else "") ^
  (* string_of_measures section.measures ^ *)
  "\nend;"

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