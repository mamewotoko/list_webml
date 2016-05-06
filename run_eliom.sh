#! /bin/sh
docker run -it --rm -p 8080:8080 -v $PWD:/home/opam/build eliom sh -c "cd mysite; make test.byte"
