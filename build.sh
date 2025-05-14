#!/bin/bash

# Clean up old files
make clean

# Generate scanner and parser
ocamlyacc parser.mly
ocamllex scanner.mll

# Compile with OCaml
ocamlfind ocamlopt -package llvm -c ast.ml
ocamlfind ocamlopt -package llvm -c parser.mli
ocamlfind ocamlopt -package llvm -c parser.ml
ocamlfind ocamlopt -package llvm -c scanner.ml
ocamlfind ocamlopt -package llvm -c irgen.ml
ocamlfind ocamlopt -package llvm -c moozik.ml
ocamlfind ocamlopt -package llvm -linkpkg ast.cmx parser.cmx scanner.cmx irgen.cmx moozik.cmx -o moozik.native

echo "Build complete. You can now run:"
echo "./moozik.native -l example_with_instruments.mz > example.ll"
echo "lli example.ll" 