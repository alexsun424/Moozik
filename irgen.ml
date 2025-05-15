open Ast
open Sast

module StringMap = Map.Make(String)

(* Track state to store track-specific information *)
type track_state = {
  notes: string list;
}

let default_track_state = {
  notes = [];
}

let get_midi_value note_str =
  (* Convert note strings to MIDI note numbers *)
  let note_to_base = function
    | 'c' -> 60
    | 'd' -> 62
    | 'e' -> 64
    | 'f' -> 65
    | 'g' -> 67
    | 'a' -> 69
    | 'b' -> 71
    | 'r' -> -1  (* Special value for rest *)
    | _ -> 60 (* default to middle C *)
  in
  
  let note_char = String.get note_str 0 in
  if note_char = 'r' then
    (* Handle rest *)
    let beats = 
      if String.length note_str > 1 then
        try int_of_string (String.sub note_str 1 (String.length note_str - 1))
        with _ -> 1
      else 1
    in
    (-1, beats)  (* -1 indicates rest *)
  else
    let base_value = note_to_base note_char in
    
    (* Parse accidental and duration *)
    let (accidental_offset, beats) =
      if String.length note_str > 1 then
        match String.get note_str 1 with
        | '+' | '#' -> 
            let dur_str = String.sub note_str 2 (String.length note_str - 2) in
            (1, try int_of_string dur_str with _ -> 1)
        | '-' | 'b' -> 
            let dur_str = String.sub note_str 2 (String.length note_str - 2) in
            (-1, try int_of_string dur_str with _ -> 1)
        | _ -> 
            let dur_str = String.sub note_str 1 (String.length note_str - 1) in
            (0, try int_of_string dur_str with _ -> 1)
      else (0, 1)
    in
    
    (base_value + accidental_offset, beats)

let flatten_music_section (section : music_section) =
  (* Convert variables list to hashtable for lookup *)
  let vars_tbl = Hashtbl.create (List.length section.variables) in
  List.iter (fun (name, notes) -> Hashtbl.add vars_tbl name notes) section.variables;

  let rec expand_item item =
    match item with
    | Notes bar -> bar
    | VarRef name -> 
        (try Hashtbl.find vars_tbl name
         with Not_found -> []) (* Return empty list if variable not found *)
    | Repeat { count; body } ->
        List.flatten (List.init count (fun _ -> 
          List.flatten (List.map expand_item body)))
  in
  
  List.flatten (List.map expand_item section.bars)

(* Map instrument names to MIDI program numbers *)
let get_instrument_number = function
  | "piano" -> 0   (* Acoustic Grand Piano *)
  | "violin" -> 40 (* Violin *)
  | "flute" -> 73  (* Flute *)
  | "guitar" -> 24 (* Acoustic Guitar (nylon) *)
  | "drums" -> 0   (* For drums we'll need to use channel 9 and different note numbers *)
  | _ -> 0         (* Default to piano *)

(* Generate MIDI bytes for a sequence of notes with time signature *)
let generate_midi_bytes notes time_sig_num time_sig_denom instrument track_number =
  (* Track events *)
  let events = ref [] in
  let current_time = ref 0 in
  
  (* Calculate power of 2 for time signature denominator *)
  let rec power_of_2 n acc =
    if n = 1 then acc
    else if n mod 2 = 0 then power_of_2 (n / 2) (acc + 1)
    else failwith "Time signature denominator must be a power of 2"
  in
  
  (* Add time signature meta event only to first track *)
  if track_number = 0 then begin
    Printf.printf "Adding time signature %d/%d to first track\n" time_sig_num time_sig_denom;
    let time_sig_event = [
      0x00; 0xFF; 0x58; 0x04;  (* Time signature meta event *)
      time_sig_num;             (* Numerator *)
      power_of_2 time_sig_denom 0;  (* Denominator as power of 2 *)
      0x18;                     (* MIDI clocks per metronome click *)
      0x08;                     (* 32nd notes per 24 MIDI clocks *)
    ] in
    events := !events @ time_sig_event;
  end;
  
  (* Add instrument (Program Change) event *)
  let instrument_num = get_instrument_number instrument in
  let channel = track_number in  (* Use track number as channel number *)
  Printf.printf "Track %d: Setting instrument %s (MIDI program %d) on channel %d\n" 
    track_number instrument instrument_num channel;
  let instrument_event = [
    0x00; 0xC0 lor channel; instrument_num;  (* Program Change event: channel, instrument number *)
  ] in
  events := !events @ instrument_event;
  
  (* Convert absolute time to MIDI delta time *)
  let to_delta_time time =
    if time > 127 then
      let high_byte = (time lsr 7) land 0x7F in
      let low_byte = time land 0x7F in
      [0x80 lor high_byte; low_byte]
    else
      [time]
  in
  
  (* Add each note as Note On followed by Note Off events *)
  let rec process_notes remaining_notes =
    match remaining_notes with
    | [] -> ()
    | note :: rest ->
        let (midi_value, beats) = get_midi_value note in
        let ticks_per_beat = 96 in  (* Standard MIDI resolution *)
        (* Adjust ticks based on time signature *)
        let ticks = 
          let base_ticks = beats * ticks_per_beat in
          (* For 3/4, make notes 1.33x longer to maintain tempo *)
          if time_sig_num = 3 && time_sig_denom = 4 then
            int_of_float (float_of_int base_ticks *. 1.33)
          (* For 6/8, make notes 0.67x shorter to make it faster *)
          else if time_sig_num = 6 && time_sig_denom = 8 then
            int_of_float (float_of_int base_ticks *. 0.67)
          else
            base_ticks
        in
        
        if midi_value >= 0 then begin  (* Only generate events for non-rest notes *)
          (* Note On event *)
          let note_on = [0x90 lor channel; midi_value; 0x50] in
          Printf.printf "Track %d: Note On: channel=%d note=%d velocity=%d\n" 
            track_number channel midi_value 0x50;
          events := !events @ (to_delta_time !current_time) @ note_on;
          current_time := 0;  (* Reset for next event *)
          
          (* Note Off event *)
          current_time := !current_time + ticks;
          let note_off = [0x80 lor channel; midi_value; 0x40] in
          Printf.printf "Track %d: Note Off: channel=%d note=%d velocity=%d\n" 
            track_number channel midi_value 0x40;
          events := !events @ (to_delta_time !current_time) @ note_off;
          current_time := 0;  (* Reset for next event *)
        end else begin
          (* For rests, just advance the time *)
          current_time := !current_time + ticks;
        end;
        
        (* Process next note *)
        process_notes rest
  in
  
  (* Process all notes *)
  process_notes notes;
  
  (* End of track meta event *)
  events := !events @ [0x00; 0xFF; 0x2F; 0x00];
  
  (* Calculate track length *)
  let track_length = List.length !events in
  let track_header = [|
    (* MTrk header *)
    0x4D; 0x54; 0x72; 0x6B;  (* "MTrk" *)
    (* Track length as 4 bytes (big endian) *)
    (track_length lsr 24) land 0xFF;
    (track_length lsr 16) land 0xFF;
    (track_length lsr 8) land 0xFF;
    track_length land 0xFF;
  |] in
  
  (* Return track data *)
  Array.append track_header (Array.of_list !events)

(* Process a music section and write to MIDI file *)
let generate_midi sections filename time_sig_num time_sig_denom instrument =
  (* MIDI file header *)
  let header = [|
    (* MThd header *)
    0x4D; 0x54; 0x68; 0x64;  (* "MThd" *)
    0x00; 0x00; 0x00; 0x06;  (* header length = 6 *)
    0x00; 0x01;              (* format type = 1 (multiple tracks) *)
    0x00; 0x02;              (* number of tracks = 2 *)
    0x00; 0x60;              (* division = 96 ticks per quarter note *)
  |] in
  
  (* Generate MIDI data for each section *)
  let track_data = List.mapi (fun i section ->
    let notes = flatten_music_section section in
    generate_midi_bytes notes time_sig_num time_sig_denom instrument i
  ) sections in
  
  (* Combine all track data *)
  let combined_data = Array.concat (header :: track_data) in
  
  (* Write to file *)
  let oc = open_out_bin filename in
  Array.iter (fun byte -> output_byte oc byte) combined_data;
  close_out oc;
  
  Printf.printf "Wrote %s!\n" filename

(* Main entry point for IR generation *)
let generate_ir sections outfile time_sig_num time_sig_denom instrument =
  (* Also create LLVM IR that generates the MIDI file *)
  let context = Llvm.global_context () in
  let the_module = Llvm.create_module context "midi_module" in
  let builder = Llvm.builder context in
  
  (* Define types *)
  let i8_t = Llvm.i8_type context in
  let i32_t = Llvm.i32_type context in
  let i8ptr_t = Llvm.pointer_type i8_t in
  
  (* Declare external C functions *)
  let fopen_t = Llvm.function_type i8ptr_t [| i8ptr_t; i8ptr_t |] in
  let fopen_func = Llvm.declare_function "fopen" fopen_t the_module in
  
  let fwrite_t = Llvm.function_type i32_t [| i8ptr_t; i32_t; i32_t; i8ptr_t |] in
  let fwrite_func = Llvm.declare_function "fwrite" fwrite_t the_module in
  
  let fclose_t = Llvm.function_type i32_t [| i8ptr_t |] in
  let fclose_func = Llvm.declare_function "fclose" fclose_t the_module in
  
  (* Define main function *)
  let main_t = Llvm.function_type i32_t [||] in
  let main_func = Llvm.define_function "main" main_t the_module in
  let entry_bb = Llvm.append_block context "entry" main_func in
  Llvm.position_at_end entry_bb builder;
  
  (* Generate MIDI data as a global constant array *)
  let midi_data = generate_midi_bytes (flatten_music_section (List.hd sections)) time_sig_num time_sig_denom instrument 0 in
  
  let midi_array = Llvm.const_array i8_t (Array.map (Llvm.const_int i8_t) midi_data) in
  let midi_global = Llvm.define_global "midi_data" midi_array the_module in
  
  (* Create filename string *)
  let filename_str = Llvm.build_global_stringptr outfile "filename" builder in
  let mode_str = Llvm.build_global_stringptr "wb" "mode" builder in
  
  (* Open file *)
  let file_ptr = Llvm.build_call fopen_func [| filename_str; mode_str |] "file_ptr" builder in
  
  (* Write MIDI data to file *)
  let data_ptr = Llvm.build_bitcast midi_global i8ptr_t "data_ptr" builder in
  let size = Llvm.const_int i32_t 1 in
  let count = Llvm.const_int i32_t (Array.length midi_data) in
  ignore (Llvm.build_call fwrite_func [| data_ptr; size; count; file_ptr |] "write_result" builder);
  
  (* Close file *)
  ignore (Llvm.build_call fclose_func [| file_ptr |] "close_result" builder);
  
  (* Return 0 *)
  ignore (Llvm.build_ret (Llvm.const_int i32_t 0) builder);
  
  (* Print module to file *)
  Llvm.print_module "example.ll" the_module;
  
  the_module

(* Main entry point for SAST to LLVM translation *)
let translate sast input_file =
  (* Extract music sections, time signatures, and instrument from the program *)
  let extract_section_timing_and_instrument sast =
    (* First collect all measure definitions *)
    let rec collect_measure_defs stmts =
      match stmts with
      | [] -> StringMap.empty
      | SMeasuresAssign(id, section) :: rest ->
          let rest_map = collect_measure_defs rest in
          StringMap.add id section rest_map
      | _ :: rest -> collect_measure_defs rest
    in
    
    (* Then collect section assignments *)
    let rec collect_section_assignments stmts =
      match stmts with
      | [] -> []
      | SAddMeasures(section_id, measures_id) :: rest ->
          (section_id, measures_id) :: collect_section_assignments rest
      | _ :: rest -> collect_section_assignments rest
    in
    
    (* Then find timing and instrument settings *)
    let rec find_timing_and_instrument stmts =
      match stmts with
      | [] -> (4, 4, "piano")  (* Default 4/4 time signature and piano *)
      | SSetTiming(num, denom) :: rest ->
          let (_, _, instr) = find_timing_and_instrument rest in
          (num, denom, instr)
      | SSetInstrument(_, instrument) :: rest ->
          let (num, denom, _) = find_timing_and_instrument rest in
          (num, denom, instrument)
      | _ :: rest -> find_timing_and_instrument rest
    in
    
    let measure_defs = collect_measure_defs sast in
    let section_assignments = collect_section_assignments sast in
    let (time_sig_num, time_sig_denom, _) = find_timing_and_instrument sast in
    
    (* Get all unique section IDs *)
    let section_ids = 
      List.fold_left (fun acc (section_id, _) -> 
        if List.mem section_id acc then acc else section_id :: acc) 
        [] section_assignments
    in
    
    (* Combine all measures for each section *)
    let combine_section_measures section_id =
      let assignments = List.filter (fun (s_id, _) -> s_id = section_id) section_assignments in
      
      (* Process all assignments for this section *)
      let rec process_assignments acc = function
        | [] -> acc
        | (_, measures_id) :: rest ->
            let measures = 
              try StringMap.find measures_id measure_defs
              with Not_found -> { svariables = []; sbars = [] }
            in
            let new_acc = 
              if acc.svariables = [] && acc.sbars = [] then
                measures
              else
                { svariables = acc.svariables @ measures.svariables;
                  sbars = acc.sbars @ measures.sbars }
            in
            process_assignments new_acc rest
      in
      
      process_assignments { svariables = []; sbars = [] } assignments
    in
    
    (* Process all sections *)
    let rec process_sections acc = function
      | [] -> acc
      | section_id :: rest ->
          let section = combine_section_measures section_id in
          process_sections (StringMap.add section_id section acc) rest
    in
    
    let sections = process_sections StringMap.empty section_ids in
    
    (* Convert SAST music section to AST format for existing code *)
    let to_ast_section section =
      let variables = section.svariables in
      
      let rec convert_item item =
        match item with
        | SNotes notes -> Notes notes
        | SVarRef name -> VarRef name
        | SRepeat { scount; sbody } -> 
            Repeat { count = scount; body = List.map convert_item sbody }
      in
      
      { variables = variables; bars = List.map convert_item section.sbars }
    in
    
    (* Convert all sections to AST format *)
    let ast_sections = 
      StringMap.fold (fun _ section acc ->
        (to_ast_section section) :: acc
      ) sections []
    in
    
    (* Get instruments for each track *)
    let rec get_track_instruments stmts =
      match stmts with
      | [] -> []
      | SSetInstrument(track_id, instrument) :: rest ->
          Printf.printf "Found instrument %s for track %s\n" instrument track_id;
          (track_id, instrument) :: get_track_instruments rest
      | _ :: rest -> get_track_instruments rest
    in
    
    let track_instruments = get_track_instruments sast in
    
    (* Map section IDs to instruments *)
    let section_instruments = 
      List.fold_left (fun acc (track_id, instrument) ->
        Printf.printf "Mapping track %s to instrument %s\n" track_id instrument;
        StringMap.add track_id instrument acc
      ) StringMap.empty track_instruments
    in
    
    (* Get track IDs *)
    let rec get_track_ids stmts =
      match stmts with
      | [] -> []
      | STrackDecl id :: rest -> 
          Printf.printf "Found track %s\n" id;
          id :: get_track_ids rest
      | _ :: rest -> get_track_ids rest
    in
    
    let track_ids = get_track_ids sast in
    
    (* Get track to section mapping *)
    let rec get_track_sections stmts =
      match stmts with
      | [] -> []
      | SAddSection(track_id, section_id) :: rest ->
          Printf.printf "Found section %s in track %s\n" section_id track_id;
          (track_id, section_id) :: get_track_sections rest
      | _ :: rest -> get_track_sections rest
    in
    
    let track_sections = get_track_sections sast in
    
    (* Map sections to their tracks *)
    let section_to_track = 
      List.fold_left (fun acc (track_id, section_id) ->
        Printf.printf "Mapping section %s to track %s\n" section_id track_id;
        StringMap.add section_id track_id acc
      ) StringMap.empty track_sections
    in
    
    (* Create a map from track IDs to their index *)
    let track_to_index = 
      List.fold_left (fun acc (track_id, i) ->
        StringMap.add track_id i acc
      ) StringMap.empty (List.mapi (fun i id -> (id, i)) track_ids)
    in
    
    (ast_sections, time_sig_num, time_sig_denom, section_instruments, section_to_track, section_ids, track_to_index)
  in
  
  let (sections, time_sig_num, time_sig_denom, section_instruments, section_to_track, section_ids, track_to_index) = 
    extract_section_timing_and_instrument sast in
  
  let output_file = 
    if String.ends_with ~suffix:".mz" input_file then
      String.sub input_file 0 (String.length input_file - 3) ^ ".mid"
    else
      input_file ^ ".mid"
  in
  
  (* Generate the MIDI file *)
  let track_data = List.mapi (fun i section ->
    let section_id = List.nth section_ids i in
    Printf.printf "Processing section %s\n" section_id;
    let track_id = StringMap.find section_id section_to_track in
    Printf.printf "Found track %s for section %s\n" track_id section_id;
    let track_index = StringMap.find track_id track_to_index in
    Printf.printf "Track %s has index %d\n" track_id track_index;
    let instrument = 
      try 
        let instr = StringMap.find track_id section_instruments in
        Printf.printf "Using instrument %s for track %s\n" instr track_id;
        instr
      with Not_found -> 
        Printf.printf "No instrument found for track %s, using piano\n" track_id;
        "piano"
    in
    let notes = flatten_music_section section in
    Printf.printf "Generating MIDI data for track %d with instrument %s\n" track_index instrument;
    generate_midi_bytes notes time_sig_num time_sig_denom instrument track_index
  ) sections in
  
  (* MIDI file header *)
  let header = [|
    (* MThd header *)
    0x4D; 0x54; 0x68; 0x64;  (* "MThd" *)
    0x00; 0x00; 0x00; 0x06;  (* header length = 6 *)
    0x00; 0x01;              (* format type = 1 (multiple tracks) *)
    0x00; 0x02;              (* number of tracks = 2 *)
    0x00; 0x60;              (* division = 96 ticks per quarter note *)
  |] in
  
  (* Combine all track data *)
  let combined_data = Array.concat (header :: track_data) in
  
  (* Write to file *)
  let oc = open_out_bin output_file in
  Array.iter (fun byte -> output_byte oc byte) combined_data;
  close_out oc;
  
  Printf.printf "Wrote %s!\n" output_file;
  
  (* Generate and return the LLVM module *)
  let llvm_module = generate_ir sections output_file time_sig_num time_sig_denom "piano" in
  
  (* Write the LLVM IR to a file for direct use with lli *)
  Llvm.print_module "example.ll" llvm_module;
  
  llvm_module