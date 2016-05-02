NAME     = list_webml

OCAMLC   = ocamlfind ocamlc
OCAMLOPT = ocamlfind ocamlopt
OCAMLDEP = ocamldep

BYTE_OBJECTS  = src/main.cmo 
OPT_OBJECTS = src/main.cmx

BYTE_APP  = $(NAME).byte
OPT_APP = $(NAME).opt

REQUIRES = nethttpd
PREDICATES =

.PHONY: all opt
all: $(BYTE_APP)
opt: $(OPT_APP)

$(BYTE_APP): $(BYTE_OBJECTS)
	$(OCAMLC) -o $(BYTE_APP) -package "$(REQUIRES)" -linkpkg \
	 $(BYTE_OBJECTS)
$(OPT_APP): $(OPT_OBJECTS)
	$(OCAMLOPT) -o $(OPT_APP) -package "$(REQUIRES)" -linkpkg \
	$(OPT_OBJECTS)

.SUFFIXES: .cmo .cmi .cmx .ml .mli

.ml.cmo:
	$(OCAMLC) -package "$(REQUIRES)" -predicates "$(PREDICATES)" \
	          -c $<
.mli.cmi:
	$(OCAMLC) -package "$(REQUIRES)" -predicates "$(PREDICATES)" \
	          -c $<
.ml.cmx:
	$(OCAMLOPT) -package "$(REQUIRES)" -predicates "$(PREDICATES)" \
	          -c $<

depend: src/*.ml 
	 $(OCAMLDEP) src/*.ml >depend
include depend

.PHONY: install uninstall
install: all
	 { test ! -f $(XARCHIVE) || extra="$(XARCHIVE) "`basename $(XARCHIVE) .cmxa`.a }; \
	 ocamlfind install $(NAME) *.mli *.cmi $(ARCHIVE) META $$extra

uninstall:
	 ocamlfind remove $(NAME)

.PHONY: clean
clean:
	 rm -f *.cmi *.cmo *.cmx *.cma *.cmxa $(BYTE_APP) $(OPT_APP)
