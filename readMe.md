Hi! We tried really hard to get the scanner and parser to be up and running. Thus far, when given this as input:

Composition comp1 = new Composition();
Track testTrack = new Track();
Section testSection = new Section();
Measure testMeasures = new Measure();
testMeasures.measures = 
  begin;
  
  e1 e1 e1 e1;
  d2 d2;

  end;

testTrack.addSection(testSection);
testComp.addTrack("testTrack", testTrack);

It fails at two main points:
1) At this snippet:

  e1 e1 e1 e1;
  d2 d2;

For some reason, our scanner only reads in only the first e1 as a NOTE token. The second e1 is read as an ID token, which breaks the parser. A lot of time was spent on debugging the scanner,
but we still couldn't find why this doesn't work. However, when we change the snipped above to:

  e1; e1; e1; e1;
  d2; d2;

Then this snipped is processed correctly, but that doesn't follow the rules or our language.

2) For any function invocation, ie.

testTrack.addSection(testSection);

This will fail because the right parenthesis is not read properly by the scanner. Same as problem 1, we double-checked the scanner multiple times, but everything seems correct programatically,
so we weren't really sure how to proceed. But for some reason, when we get rid of the right parenthesis

testTrack.addSection(testSection;

This line gets processed properly, which is incredibly strange.

Any help or ideas would be much appreciated!! Let us know if you have any questions
