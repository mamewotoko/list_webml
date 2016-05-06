FROM ocaml/opam:ubuntu
MAINTAINER Takashi Masuyama <mamewotoko@gmail.com>
USER opam
RUN mkdir /home/opam/build
RUN chown opam /home/opam/build
WORKDIR /home/opam

# depext
RUN sudo apt-get update && sudo apt-get install -y pkg-config libpcre3-dev libssl-dev zlib1g-dev libgdbm-dev m4 ncurses-dev

RUN opam update
RUN eval `opam config env`
RUN opam switch 4.02.3
RUN eval `opam config env`
RUN opam switch
RUN opam install -y eliom
#RUN sh setup-opam
EXPOSE 8080
VOLUME ["/home/opam/build"]
WORKDIR /home/opam/build
