RESULT = list_webml
SOURCES = src/main.ml
PACKS = nethttpd
OCAMLMAKEFILE=OCamlMakefile

all: nc

include $(OCAMLMAKEFILE)
