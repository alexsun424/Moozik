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
ocamlbuild -use-ocamlfind moozik.native
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
- Octave is specified by a digit (e.g., c4 is middle C)
- Accidentals: # or + for sharp, - or b for flat (e.g., c#4, c+4, or cb4, c-4)

The MIDI generator creates:
1. A standard MIDI file with header
2. A single track containing all notes
3. Simple note-on/note-off events with fixed velocity and duration
4. LLVM IR code that can be compiled to create the same MIDI file

## Example Music Section

```
	begin; 
chord_c = [c4 e4 g4]
chord_g = [g4 b4 d5]
c4 d4 e4;
chord_c;
g4 a4 b4;
chord_g;
repeat(2) {
  c5 b4 a4 g4;
}
end;
```

## Testing

```bash
# Generate the LLVM IR for our example file
./moozik.native -l example.mz > example.ll

# Run the LLVM IR to create a MIDI file
lli example.ll

# Verify that output.mid was created
ls -la output.mid
```
