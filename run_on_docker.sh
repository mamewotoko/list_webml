#! /bin/sh
. ./docker.env

sh build.sh
docker rm -f ${CONTAINER} 2> /dev/null
docker run -d --name ${CONTAINER} -v ${PWD}:/home/opam/build -p ${PORT}:8080 ${IMAGE} sh -c "make && ./list_webml 8080"
# docker logs ${IMAGE}_container
