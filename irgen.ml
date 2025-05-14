open Ast
open Sast

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
    | _ -> 60 (* default to middle C *)
  in
  
  let note_char = String.get note_str 0 in
  let base_value = note_to_base note_char in
  
  (* Parse octave modifier if present *)
  let octave_offset = 
    if String.length note_str > 1 then
      try
        let octave = int_of_string (String.sub note_str 1 1) - 4 in
        octave * 12
      with _ -> 0
    else 0
  in
  
  (* Parse accidentals if present *)
  let accidental_offset =
    if String.length note_str > 2 then
      match String.get note_str 1 with
      | '+' | '#' -> 1
      | '-' | 'b' -> -1
      | _ -> 0
    else 0
  in
  
  base_value + octave_offset + accidental_offset

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

(* Generate MIDI bytes for a sequence of notes *)
let generate_midi_bytes notes =
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
  
  (* Add each note as Note On followed by Note Off events *)
  List.iter (fun note ->
    let midi_value = get_midi_value note in
    (* Note On event - delta-time 0, channel 0, note value, velocity 80 *)
    events := !events @ [0x00; 0x90; midi_value; 0x50];
    (* Note Off event - delta-time 96 (quarter note), channel 0, note value, velocity 40 *)
    events := !events @ [0x60; 0x80; midi_value; 0x40];
  ) notes;
  
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
let generate_midi section filename =
  let notes = flatten_music_section section in
  let midi_data = generate_midi_bytes notes in
  
  (* Write to file *)
  let oc = open_out_bin filename in
  Array.iter (fun byte -> output_byte oc byte) midi_data;
  close_out oc;
  
  Printf.printf "Wrote %s!\n" filename

(* Main entry point for IR generation *)
let generate_ir section outfile =
  let notes = flatten_music_section section in
  generate_midi section outfile;
  
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
  let midi_data = generate_midi_bytes notes in
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
    ignore (generate_ir section Sys.argv.(1))

(* Main entry point for SAST to LLVM translation *)
let translate sast =
  (* Extract music sections from the program *)
  let extract_section sast =
    let rec find_sections stmts =
      match stmts with
      | [] -> None
      | SMeasuresAssign(_, section) :: _ -> Some section
      | _ :: rest -> find_sections rest
    in
    
    match find_sections sast with
    | Some section -> section
    | None -> { svariables = []; sbars = [] }  (* Default empty section *)
  in
  
  let section = extract_section sast in
  
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
  
  (* Generate the MIDI file *)
  generate_midi ast_section "output.mid";
  
  (* Generate and return the LLVM module *)
  let llvm_module = generate_ir ast_section "output.mid" in
  
  (* Write the LLVM IR to a file for direct use with lli *)
  Llvm.print_module "example.ll" llvm_module;
  
  llvm_module