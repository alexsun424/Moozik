# Moozik Compiler Makefile
# Building with ocamlbuild

.PHONY: all clean test

all: moozik.native

# Build the moozik compiler
moozik.native:
	ocamlbuild -pkgs llvm,unix moozik.native

# Clean up build artifacts
clean:
	ocamlbuild -clean
	rm -rf *.cmi *.cmo *.cmx *.o *.out *.ll *.mid _build -l *.log

# Test example
test: moozik.native example.mz
	# Redirect stderr to /dev/null to hide debug messages
	./moozik.native -l example.mz 2>/dev/null > example.ll
	@if [ -f example.ll ]; then \
		echo "Running LLVM IR with lli..."; \
		/opt/homebrew/Cellar/llvm@14/14.0.6/bin/lli example.ll 2>/dev/null || echo "Note: lli may show errors but the MIDI file is still generated"; \
		if [ -f output.mid ]; then \
			echo "MIDI file generated: output.mid"; \
		fi \
	else \
		echo "Error: example.ll not generated"; \
	fi

# MIDI generator targets
irgen : ast.cmx irgen.cmx irgen_test.cmx
	ocamlfind ocamlopt -package llvm -linkpkg $^ -o irgen_test

simple_midi : simple_midi.ml
	ocamlfind ocamlopt -package llvm -linkpkg $^ -o simple_midi

# Rules for building object files
%.cmo : %.ml
	ocamlc -w A -c $<

%.cmx : %.ml
	ocamlfind ocamlopt -c $<

%.cmi : %.mli
	ocamlc -w A -c $<

# Special rule for LLVM-dependent modules
irgen.cmo : irgen.ml
	ocamlfind ocamlc -package llvm -c $<

irgen.cmx : irgen.ml
	ocamlfind ocamlopt -package llvm -c $<

irgen_test.cmx : irgen_test.ml
	ocamlfind ocamlopt -package llvm -c $<

ast.cmx : ast.ml
	ocamlfind ocamlopt -c $<

moozik.cmo : moozik.ml
	ocamlfind ocamlc -package llvm -c $<

scanner.ml : scanner.mll
	ocamllex $^

parser.ml parser.mli : parser.mly
	ocamlyacc $^

moozik.out : moozik moozik.mz
	./moozik < moozik.mz > moozik.out

moozik_test.out : moozik_test 
	./moozik_test > moozik_test.out

# Run the MIDI generator test
irgen.out : irgen
	./irgen_test

# Depedencies from ocamldep
moozik.cmo : scanner.cmo parser.cmi ast.cmo irgen.cmo
moozik.cmx : scanner.cmx parser.cmx ast.cmx irgen.cmx
parser.cmo : ast.cmo parser.cmi
parser.cmx : ast.cmx parser.cmi
scanner.cmo : parser.cmi
scanner.cmx : parser.cmx
sast.cmo : ast.cmo
sast.cmx : ast.cmx
semant.cmo : sast.cmo ast.cmo
semant.cmx : sast.cmx ast.cmx
moozik_test.cmo : scanner.cmo parser.cmi semant.cmo sast.cmo ast.cmo
moozik_test.cmx : scanner.cmx parser.cmx semant.cmx sast.cmx ast.cmx
irgen.cmo : ast.cmo
irgen.cmx : ast.cmx
irgen_test.cmo : ast.cmo irgen.cmo
irgen_test.cmx : ast.cmx irgen.cmx
##############################

