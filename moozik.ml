open Ast

let _ =
  let input = "Composition testComp = new Composition();
Track testTrack = new Track();
Section testSection = new Section();
Measure testMeasures = new Measure();
testMeasures.measures = 
	begin; 
some_notes = [c+1 c-2;]
i_see_you = [c2 c2;]
	end;
testSection.addMeasures(testMeasures.measures);
testTrack.addSection(testSection);
testComp.addTrack(testTrack); $" in
  let lexbuf = Lexing.from_string  input in
  let program = Parser.program_rule Scanner.token lexbuf in
  print_endline (string_of_program program)
