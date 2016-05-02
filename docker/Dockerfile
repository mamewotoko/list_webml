FROM ocaml/opam:ubuntu
MAINTAINER Takashi Masuyama <mamewotoko@gmail.com>
USER opam
RUN mkdir /home/opam/build
RUN chown opam /home/opam/build
RUN opam update
RUN opam install -y ocamlnet
#webapp
EXPOSE 8080
VOLUME ["/home/opam/build"]
WORKDIR /home/opam/build
