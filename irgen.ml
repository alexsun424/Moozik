open Ast
open Sast

(* Track state to store time signature and other track-specific information *)
type track_state = {
  time_sig_num: int;
  time_sig_denom: int;
  notes: string list;
}

let default_track_state = {
  time_sig_num = 4;
  time_sig_denom = 4;
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
let generate_midi_bytes notes time_sig_num time_sig_denom instrument =
  (* MIDI file header *)
  let header = [|
    (* MThd header *)
    0x4D; 0x54; 0x68; 0x64;  (* "MThd" *)
    0x00; 0x00; 0x00; 0x06;  (* header length = 6 *)
    0x00; 0x00;              (* format type = 0 *)
    0x00; 0x01;              (* number of tracks = 1 *)
    0x00; 0x60;              (* division = 96 ticks per quarter note *)
  |] in
  
  (* Track events *)
  let events = ref [] in
  let current_time = ref 0 in
  
  (* Calculate power of 2 for time signature denominator *)
  let rec power_of_2 n acc =
    if n = 1 then acc
    else if n mod 2 = 0 then power_of_2 (n / 2) (acc + 1)
    else failwith "Time signature denominator must be a power of 2"
  in
  
  (* Add time signature meta event *)
  let time_sig_event = [
    0x00; 0xFF; 0x58; 0x04;  (* Time signature meta event *)
    time_sig_num;             (* Numerator *)
    power_of_2 time_sig_denom 0;  (* Denominator as power of 2 *)
    0x18;                     (* MIDI clocks per metronome click *)
    0x08;                     (* 32nd notes per 24 MIDI clocks *)
  ] in
  events := !events @ time_sig_event;
  
  (* Add instrument (Program Change) event *)
  let instrument_num = get_instrument_number instrument in
  let instrument_event = [
    0x00; 0xC0; instrument_num;  (* Program Change event: channel 0, instrument number *)
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
        let ticks = beats * ticks_per_beat in
        
        if midi_value >= 0 then begin  (* Only generate events for non-rest notes *)
          (* Note On event *)
          events := !events @ (to_delta_time !current_time) @ [0x90; midi_value; 0x50];
          current_time := 0;  (* Reset for next event *)
          
          (* Note Off event *)
          current_time := !current_time + ticks;
          events := !events @ (to_delta_time !current_time) @ [0x80; midi_value; 0x40];
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
  
  (* Combine everything *)
  Array.append header (Array.append track_header (Array.of_list !events))

(* Process a music section and write to MIDI file *)
let generate_midi section filename time_sig_num time_sig_denom instrument =
  let notes = flatten_music_section section in
  let midi_data = generate_midi_bytes notes time_sig_num time_sig_denom instrument in
  
  (* Write to file *)
  let oc = open_out_bin filename in
  Array.iter (fun byte -> output_byte oc byte) midi_data;
  close_out oc;
  
  Printf.printf "Wrote %s!\n" filename

(* Main entry point for IR generation *)
let generate_ir section outfile time_sig_num time_sig_denom instrument =
  let notes = flatten_music_section section in
  generate_midi section outfile time_sig_num time_sig_denom instrument;
  
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
  let midi_data = generate_midi_bytes notes time_sig_num time_sig_denom instrument in
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
  Llvm.print_module "midi.ll" the_module;
  
  Printf.printf "Generated LLVM IR for MIDI file generation\n";
  
  the_module

(* Main function for testing directly *)
let _ =
  if Array.length Sys.argv > 1 then
    let section = { 
      variables = [("test", ["c4"; "e4"; "g4"])]; 
      bars = [Notes ["c4"; "d4"; "e4"; "f4"; "g4"; "a4"; "b4"; "c5"]] 
    } in
    ignore (generate_ir section Sys.argv.(1) 4 4 "piano")

(* Main entry point for SAST to LLVM translation *)
let translate sast =
  (* Extract music sections, time signatures, and instrument from the program *)
  let extract_section_timing_and_instrument sast =
    let rec find_sections_timing_and_instrument stmts =
      match stmts with
      | [] -> (None, 4, 4, "piano")  (* Default 4/4 time signature and piano *)
      | SMeasuresAssign(_, section) :: rest -> 
          let (_, num, denom, instr) = find_sections_timing_and_instrument rest in
          (Some section, num, denom, instr)
      | SSetTiming(_, num, denom) :: rest ->
          let (section, _, _, instr) = find_sections_timing_and_instrument rest in
          (section, num, denom, instr)
      | SSetInstrument(_, instrument) :: rest ->
          let (section, num, denom, _) = find_sections_timing_and_instrument rest in
          (section, num, denom, instrument)
      | _ :: rest -> find_sections_timing_and_instrument rest
    in
    
    match find_sections_timing_and_instrument sast with
    | (Some section, num, denom, instr) -> (section, num, denom, instr)
    | (None, num, denom, instr) -> ({ svariables = []; sbars = [] }, num, denom, instr)
  in
  
  let (section, time_sig_num, time_sig_denom, instrument) = extract_section_timing_and_instrument sast in
  
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
  
  let ast_section = to_ast_section section in
  
  (* Get input filename from command line arguments *)
  let input_file = 
    if Array.length Sys.argv > 2 then
      Sys.argv.(2)  (* The filename is the second argument after -l *)
    else
      failwith "No input file specified"
  in
  let output_file = 
    if String.ends_with ~suffix:".mz" input_file then
      String.sub input_file 0 (String.length input_file - 3) ^ ".mid"
    else
      input_file ^ ".mid"
  in
  
  (* Generate the MIDI file *)
  generate_midi ast_section output_file time_sig_num time_sig_denom instrument;
  
  (* Generate and return the LLVM module *)
  let llvm_module = generate_ir ast_section output_file time_sig_num time_sig_denom instrument in
  
  (* Write the LLVM IR to a file for direct use with lli *)
  Llvm.print_module "example.ll" llvm_module;
  
  llvm_module