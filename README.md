## Build and run the frontend
```
ocamlbuild moozik.native
./moozik.native 
```
- Change your testing string in moozik.ml

Testing code snippet
```
Composition testComp = new Composition();
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
testComp.addTrack(testTrack);
```