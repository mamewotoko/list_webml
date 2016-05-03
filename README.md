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
3. build
  ```
  make 
  ```

Run (on host)
------------
1. start app
  ```
  ./list_webml 8080
  ```
2. browse http://localhost:8080/

Build & Run (on docker container)
--------------------------------
1. build and run docker container
  ```
  sh run_on_docker.sh
  ```
2. browse http://localhost:8080/

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
* get external xml using HTTP
  * async job
* simple configuration to serve static file
  * use other http server like [ocsigen](http://ocsigen.org/)
  * use "404 Not Found" instead of "500 Internal Server Error"
    when requested resource is not found
* access log
* cache 
* login
* database

----
Takashi Masuyama < mamewotoko@gmail.com >  
http://mamewo.ddo.jp/
