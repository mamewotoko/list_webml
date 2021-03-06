OCAMLMAKEFILE=OCamlMakefile

LIST_WEBML_OPTS = RESULT=list_webml SOURCES=src/main.ml PACKS=nethttpd,xmlplaylist,netclient,uri,getopt
#SQLITE_SAMPLE_OPTS = RESULT=sqlite_sample SOURCES=sqlite_sample.ml PACKS=sqlite3
#ELIOM_OPTS = RESULT=eliom_sample SOURCES=src/eliom/eliom_main.ml PACKS=lwt,eliom

#client_sample sqlite_sample
all: list_webml 

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
