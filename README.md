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
1. stop 

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
* get podcast xml using HTTP
  * async job
* simple configuration to serve static file
  * use other http server like [ocsigen](http://ocsigen.org/)
  * use "404 Not Found" instead of "500 Internal Server Error"
    when requested resource is not found
* access log
* cache 
* login
  * with google account?
* database

Appendix: using eliom + docker
-------------------------------
* environment
  * ruuning on docker on Ubuntu15.10
  * not running docker on OS X
* make sample app with following command. mysite directory is created

  ```
  eliom-distillery -name mysite -template basic.ppx -target-directory mysite
  ```
* Build
  1. build conainer

    ```
    docker build -t eliom eliom_docker
    ```
  2. run (build eliom app & run it)

    ```
    run_eliom.sh
    ```
  3. browse http://localhost:8080

Appendix: using eliom
---------------------
* Install
  * install opam
  * install ocaml4.02.3 and eliom package

    ```
    opam switch 4.02.3
    eval `opam config env`
    opam install eliom
    ```

----
Takashi Masuyama < mamewotoko@gmail.com >  
http://mamewo.ddo.jp/
