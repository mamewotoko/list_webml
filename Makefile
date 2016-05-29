OCAMLMAKEFILE=OCamlMakefile

LIST_WEBML_OPTS = RESULT=list_webml SOURCES=src/main.ml PACKS=nethttpd,xmlplaylist,netclient,uri
CLIENT_SAMPLE_OPTS = RESULT=client_sample SOURCES=src/client.ml PACKS=netclient
ELIOM_OPTS = RESULT=eliom_sample SOURCES=src/eliom/eliom_main.ml PACKS=lwt,eliom

all: list_webml client_sample

list_webml: src/main.ml
	make -f $(OCAMLMAKEFILE) $(LIST_WEBML_OPTS) nc

client_sample: src/client.ml
	make -f $(OCAMLMAKEFILE) $(CLIENT_SAMPLE_OPTS) nc

eliom_sample: src/eliom/eliom_main.ml
	make -f $(OCAMLMAKEFILE) $(ELIOM_OPTS) nc

clean:
	make -f $(OCAMLMAKEFILE) $(LIST_WEBML_OPTS) clean
	make -f $(OCAMLMAKEFILE) $(CLIENT_SAMPLE_OPTS) clean
	make -f $(OCAMLMAKEFILE) $(ELIOM_OPTS) clean
