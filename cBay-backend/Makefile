MODULES= user item offer basic itemstate marketplace userstate transaction transactionstate mp_server
OBJECTS=$(MODULES:=.cmo)
MLS=$(MODULES:=.ml)
MLIS=$(MODULES:=.mli)
TEST=test.byte
SERVER= mp_server.byte
OCAMLBUILD=ocamlbuild -use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)'
PKGS=unix,ounit2,str,qcheck,lwt,cohttp,cohttp-lwt-unix,conduit-lwt,ocamlbuild

default: build
	utop

build:
	$(OCAMLBUILD) $(OBJECTS)

test:
	BISECT_COVERAGE=YES $(OCAMLBUILD) -tag 'debug' $(TEST) && ./$(TEST) -runner sequential

server:
	$(OCAMLBUILD) $(SERVER)
	
run:
	./$(SERVER)

zip:
	zip cBay-backend.zip *.ml* *.json _tags Makefile
	
docs: docs-public docs-private
	
docs-public: build
	mkdir -p doc.public
	ocamlfind ocamldoc -I _build -package $(PKGS),yojson \
		-html -stars -d doc.public $(MLIS)

docs-private: build
	mkdir -p doc.private
	ocamlfind ocamldoc -I _build -package $(PKGS),yojson \
		-html -stars -d doc.private \
		-inv-merge-ml-mli -m A $(MLIS) $(MLS)

clean:
	ocamlbuild -clean
	rm -rf doc.public doc.private marketplace.zip

bisect: clean test
	bisect-ppx-report html