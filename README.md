# Moozik Programming Language

A music-focused programming language that allows users to create MIDI sequences through code.

## Features

- Define musical notes and phrases
- Create repeating patterns
- Store and reference melodic patterns as variables
- Generate MIDI files from your musical code

## Building the Project

You will need OCaml and LLVM installed to build this project.

### Option 1: Using OCamlbuild (Recommended)

Similar to the MicroC workflow:

```bash
# Build the Moozik compiler
ocamlbuild -pkgs llvm,unix moozik.native
```

### Option 2: Using Make

```bash
# Build the main compiler
make

# Build the MIDI generator
make irgen
```

## Running the Compiler

### Generate and Run LLVM IR

```bash
# Generate LLVM IR from a Moozik source file
./moozik.native -l example.mz > example.ll

# Run the LLVM IR directly to generate a MIDI file
lli example.ll
```

This will:
1. Compile your Moozik code to LLVM IR
2. Execute the LLVM IR code with `lli`
3. Generate a MIDI file named "output.mid"

### Other Options

```bash
# Only print the AST (default behavior)
./moozik.native example.mz
```

## Understanding the MIDI Translation

Each note in Moozik is translated to a corresponding MIDI note number:
- Basic notes: c, d, e, f, g, a, b
- Beat (how long a note is palyed) is specified by integer  (e.g., c4 middle c 4 beats played)
- Accidentals: + for sharp, - for flat (e.g., c+4, or c-4)

The MIDI generator creates:
1. A standard MIDI file with header
2. Multiple tracks containing notes, with an instrument assigned, and each track's octave is the same.
3. Simple note-on/note-off events with fixed velocity and duration
4. LLVM IR code that can be compiled to create the same MIDI file

## Example Music Section

```
begin; 
	first = 
	[
	 e2 d1 c2 d1;
  	 e2 e1 e2 r3;
	]
	
	second = 
	[
	 e1 d1 c1 d1;
  	 e1 e1 e1 e1;
  	 d1 d1 e1 d1;
  	 c1 r1 r1 r1;
	]

	first
	e2 d1 c2 d1;
	e2 e1 e2 r3;
	d1 d1 d1 r1;
	e1 g1 g1 r1;

	repeat (3) {
		first
		c1 r1;
		repeat (2) {
			c1 r1;
			second
		}
	}

end;
```

## Testing

```bash
# Generate the LLVM IR for our example file
./moozik.native -l example.mz > example.ll

# Run the LLVM IR to create a MIDI file
lli example.ll

# Verify that example.mid was created
ls -la example.mid
```
## Debugging
If you want to debug after making changes to the front-end (parser/scanner/ast) 
without running entire llvm, you can run these commands
```bash
make clean
make printast
cat example.mz | ./printast.native
```


