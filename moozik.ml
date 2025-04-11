open Ast

let _ =
  let input = "Composition testComp = new Composition();
Track testTrack = new Track();
Section testSection = new Section();
Measure testMeasures = new Measure();
testMeasures.measures = 
	begin; 
	c1 c+1 c-1 d1;
	c+2 c-2;
	e4; r5;
	end;
testSection.addMeasures(testMeasures.measures);
testTrack.addSection(testSection);
testComp.addTrack(testTrack); $" in
  let lexbuf = Lexing.from_string  input in
  let program = Parser.program_rule Scanner.token lexbuf in
  print_endline (string_of_program program)
