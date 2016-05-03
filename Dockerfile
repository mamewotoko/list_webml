FROM ocaml/opam:ubuntu
MAINTAINER Takashi Masuyama <mamewotoko@gmail.com>
USER opam
RUN mkdir /home/opam/build
RUN chown opam /home/opam/build
WORKDIR /home/opam
RUN opam update
ADD setup-opam ./setup-opam
RUN sh setup-opam

EXPOSE 8080
VOLUME ["/home/opam/build"]
WORKDIR /home/opam/build
