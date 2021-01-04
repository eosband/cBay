FROM ocaml/opam

WORKDIR /usr/src/app
COPY . .

# Install dependencies
RUN sudo apt-get install -y pkg-config
RUN sudo apt-get install -y m4
RUN sudo apt-get install -y ocaml-findlib
RUN opam install ppx_deriving_yojson 
RUN opam install cohttp-lwt-unix 
RUN opam install ocamlbuild
RUN opam install ocamlfind
RUN opam install ounit2

EXPOSE 8000

RUN sudo chown -R opam:nogroup .
RUN opam config exec make build
RUN opam config exec make server 
CMD opam config exec make run 