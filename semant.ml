open Ast
open Sast

module StringMap = Map.Make(String)

(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong. *)

let check program =
  (* Maintain symbol tables of variable declarations by name *)
  let compositions = StringMap.empty in
  let tracks = StringMap.empty in
  let sections = StringMap.empty in
  let measures = StringMap.empty in

  let valid_time_signatures = 
    List.fold_left (fun map (num, denom) -> StringMap.add (string_of_int num ^ "/" ^ string_of_int denom) true map)
      StringMap.empty
      [(2, 4); (3, 4); (4, 4); (6, 8); (9, 8); (12, 8)]
  in

  (* Convert a music_item to a semantically checked smusic_item *)
  let rec check_music_item vars = function
    | Notes notes -> SNotes notes
    | VarRef name ->
        (* Check if the variable exists in the music section *)
        if List.exists (fun (var_name, _) -> var_name = name) vars
        then SVarRef name
        else raise (Failure ("undeclared variable " ^ name))
    | Repeat repeat_expr ->
        if repeat_expr.count <= 0 
        then raise (Failure ("repeat count must be greater than 0"))
        else
          SRepeat {
            scount = repeat_expr.count;
            sbody = List.map (check_music_item vars) repeat_expr.body
          }
  in

  let instruments =
    List.fold_left (fun map name -> StringMap.add name true map)
      StringMap.empty
      ["piano"; "violin"; "flute"; "guitar"; "drums"] 
  in
  
  (* Convert a music_section to a semantically checked smusic_section *)
  let check_music_section ms =
    (* Check for duplicate variable names *)
    let rec check_duplicates = function
      | [] -> ()
      | (name, _) :: rest ->
          if List.exists (fun (var_name, _) -> var_name = name) rest
          then raise (Failure ("duplicate variable " ^ name))
          else check_duplicates rest
    in
    check_duplicates ms.variables;
    
    (* Semantically check each music item *)
    {
      svariables = ms.variables;
      sbars = List.map (check_music_item ms.variables) ms.bars
    }
  in

  (* Build a map of declared variables *)
  let rec check_stmts (compositions, tracks, sections, measures, instruments, valid_time_signatures) = function
    | [] -> []
    | stmt :: rest ->
        match stmt with
        | CompDecl id ->
            (* Check if composition already declared *)
            if StringMap.mem id compositions
            then raise (Failure ("duplicate composition " ^ id))
            else 
              let compositions' = StringMap.add id true compositions in
              SCompDecl id :: check_stmts (compositions', tracks, sections, measures, instruments, valid_time_signatures) rest
              
        | TrackDecl id ->
            (* Check if track already declared *)
            if StringMap.mem id tracks
            then raise (Failure ("duplicate track " ^ id))
            else 
              let tracks' = StringMap.add id true tracks in
              STrackDecl id :: check_stmts (compositions, tracks', sections, measures, instruments, valid_time_signatures) rest
              
        | SectionDecl id ->
            (* Check if section already declared *)
            if StringMap.mem id sections
            then raise (Failure ("duplicate section " ^ id))
            else 
              let sections' = StringMap.add id true sections in
              SSectionDecl id :: check_stmts (compositions, tracks, sections', measures, instruments, valid_time_signatures) rest
              
        | MeasureDecl id ->
            (* Check if measure already declared *)
            if StringMap.mem id measures
            then raise (Failure ("duplicate measure " ^ id))
            else 
              let measures' = StringMap.add id true measures in
              SMeasureDecl id :: check_stmts (compositions, tracks, sections, measures', instruments, valid_time_signatures) rest
              
        | MeasuresAssign (id, section) ->
            (* Check if measure exists *)
            if not (StringMap.mem id measures)
            then raise (Failure ("undeclared measure " ^ id))
            else
              (* Semantically check the music section *)
              let checked_section = check_music_section section in
              SMeasuresAssign (id, checked_section) :: check_stmts (compositions, tracks, sections, measures, instruments, valid_time_signatures) rest
              
        | AddMeasures (section_id, measures_id) ->
            (* Check if section exists *)
            if not (StringMap.mem section_id sections)
            then raise (Failure ("AddMeasures: undeclared section " ^ section_id))
            (* Check if measure exists *)
            else if not (StringMap.mem measures_id measures)
            then raise (Failure ("undeclared measure " ^ measures_id))
            else
              SAddMeasures (section_id, measures_id) :: check_stmts (compositions, tracks, sections, measures, instruments, valid_time_signatures) rest
              
        | AddSection (track_id, section_id) ->
            (* Check if track exists *)
            if not (StringMap.mem track_id tracks)
            then raise (Failure ("AddSection: undeclared track " ^ track_id))
            (* Check if section exists *)
            else if not (StringMap.mem section_id sections)
            then raise (Failure ("AddSection: undeclared section " ^ section_id))
            else
              SAddSection (track_id, section_id) :: check_stmts (compositions, tracks, sections, measures, instruments, valid_time_signatures) rest
              
        | AddTrack (comp_id, track_id) ->
            (* Check if composition exists *)
            if not (StringMap.mem comp_id compositions)
            then raise (Failure ("undeclared composition " ^ comp_id))
            (* Check if track exists *)
            else if not (StringMap.mem track_id tracks)
            then raise (Failure ("undeclared track " ^ track_id))
            else
              SAddTrack (comp_id, track_id) :: check_stmts (compositions, tracks, sections, measures, instruments, valid_time_signatures) rest
              
        | SetKey (section_id, key) ->
            (* Check if section exists *)
            if not (StringMap.mem section_id sections)
            then raise (Failure ("SetKey:bundeclared section " ^ section_id))
            (* Check if key is valid (you can define your own validation rules) *)
            else if key < 0 || key > 127 (* MIDI note range is 0-127 *)
            then raise (Failure ("invalid key value " ^ string_of_int key))
            else
              SSetKey (section_id, key) :: check_stmts (compositions, tracks, sections, measures, instruments, valid_time_signatures) rest

        | SetInstrument (track_id, instrument) ->
              (* Check if track exists *)
              if not (StringMap.mem track_id tracks) 
              then raise (Failure ("SetInstrument: undeclared track " ^ track_id))
              (* Check if instrument is valid *)
              else if not (StringMap.mem instrument instruments)
              then raise (Failure ("SetInstrument: invalid instrument " ^ instrument))
              else
                SSetInstrument (track_id, instrument) :: check_stmts (compositions, tracks, sections, measures, instruments, valid_time_signatures) rest

      | SetTiming (section_id, num, denom) ->
            (* Check if section exists *)
            if not (StringMap.mem section_id sections)
            then raise (Failure ("SetTiming: undeclared section " ^ section_id))
            (* Check if time signature is valid *)
            else if not (StringMap.mem (string_of_int num ^ "/" ^ string_of_int denom) valid_time_signatures)
            then raise (Failure ("SetTiming: invalid time signature " ^ string_of_int num ^ "/" ^ string_of_int denom))
            else
              SSetTiming (section_id, num, denom) :: check_stmts (compositions, tracks, sections, measures, instruments, valid_time_signatures) rest
  in
            
  

  (* Start the checking with empty environment maps *)
  check_stmts (compositions, tracks, sections, measures, instruments, valid_time_signatures) program 