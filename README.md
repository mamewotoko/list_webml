Web app [![Build Status](https://travis-ci.org/mamewotoko/list_webml.svg?branch=master)](https://travis-ci.org/mamewotoko/list_webml)
=======
Overview
--------
* display lists

Build
-----
1. install ocaml
2. install opam
3. install nethttpd package
```
opam install -y nethttpd
```
4. build
```
make 
```

Run
---
1. start
```
./list_webml 9090
```
2. browse http://localhost:9090/

Files
-----
 list_web: binary
 resource/: css, javascript served as static file
 src/: source

TODO
----
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

