all : moozik.out

moozik : parser.cmo scanner.cmo moozik.cmo
	ocamlc -w A -o moozik $^

%.cmo : %.ml
	ocamlc -w A -c $<

%.cmi : %.mli
	ocamlc -w A -c $<

scanner.ml : scanner.mll
	ocamllex $^

parser.ml parser.mli : parser.mly
	ocamlyacc $^

moozik.out : moozik moozik.mz
	./moozik < moozik.mz > moozik.out

# Depedencies from ocamldep
moozik.cmo : scanner.cmo parser.cmi ast.cmi
moozik.cmx : scanner.cmx parser.cmx ast.cmi
parser.cmo : ast.cmi parser.cmi
parser.cmx : ast.cmi parser.cmi
scanner.cmo : parser.cmi
scanner.cmx : parser.cmx
##############################


.PHONY : clean
clean :
	rm -rf *.cmi *.cmo parser.ml parser.mli scanner.ml moozik.out moozik


