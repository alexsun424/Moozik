#!/bin/bash

# Clean previous builds
echo "Cleaning previous builds..."
make clean

# Build the compiler
echo "Building the compiler..."
ocamlbuild -pkgs llvm,unix moozik.native

# Generate LLVM IR
echo "Generating LLVM IR..."
./moozik.native -l example.mz > example.ll

# Run the LLVM IR to generate MIDI
echo "Generating MIDI file..."
lli example.ll

echo "Done! Check output.mid for the generated MIDI file." 