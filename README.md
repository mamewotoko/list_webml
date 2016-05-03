Web app [![Build Status](https://travis-ci.org/mamewotoko/list_webml.svg?branch=master)](https://travis-ci.org/mamewotoko/list_webml)
=======
Overview
--------
* display and edit list on web
* run on host or docker container

Build (on host)
---------------
1. [install ocaml & opam](https://ocaml.org/docs/install.html)
2. install nethttpd package
```
opam install -y nethttpd
```
4. build
```
make 
```

Run (on host)
------------
1. start
```
./list_webml 9090
```
2. browse http://localhost:9090/

Build & Run (on docker container)
--------------------------------
1. 
```
sh run_on_docker.sh
```

Stop (on docker container)
--------------------------
1.
```
sh stop_on_docker.sh
```

Files
-----
* list_web: binary
* resource/: css, javascript served as static file
* src/: source

TODO
----
* use [ocsigen](http://ocsigen.org/)
* get external xml using HTTP
  * async job
* simple configuration to serve static file
  * use other http server?
  * use "404 Not Found" instead of "500 Internal Server Error"
    when requested resource is not found
* access log
* cache 
* login
* database

----
Takashi Masuyama < mamewotoko@gmail.com >
http://mamewo.ddo.jp/
