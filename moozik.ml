open Ast
open Sast
open Semant

let _ =
  let input = "Composition  testComp = new Composition();
Track testTrack = new Track();
Track testTrack2 = new Track();
Section testSection = new Section();
Section testSection2 = new Section();
Measure testMeasures = new Measure();
testMeasures.measures = 
	begin; 
i_see_you = [c2 c2;]
  some_notes = [c+1 c-2;]
  e1 e1 e1 e1;

e1 e1 e1 e1;

e1 e1 e1 e1;
e2 e2 e2 e2;
some_notes
repeat(3) {
  e1 e1 e1 e1;
  i_see_you
}
e2 e2 e2 e2;
some_notes

repeat(2) {
  e1 e1 e1 e1;
  i_see_you
  repeat(3) {
    a1 b+1 c-1 d1;
    some_notes
  }
}

	end;
testSection.addMeasures(testMeasures.measures);
testTrack.addSection(testSection);
testTrack.addSection(testSection2);
testTrack.setInstrument(piano);
testComp.addTrack(testTrack);
testComp.addTrack(testTrack2);
testSection.setTiming(4/4);
testSection.setKey(100);
 $" in
  let lexbuf = Lexing.from_string  input in
  let program = Parser.program_rule Scanner.token lexbuf in
  print_endline (string_of_program program);
  print_endline (string_of_sprogram (check program))

  (* 
testSection.setTiming(4.4); *)