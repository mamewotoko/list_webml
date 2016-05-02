Dockerfile for ocamlnet
=======================

Build docker container
----------------------
```
docker build -t ocamlnet .
```

Run
---
1. 
```
cd sample-ocamlnet
```
2. start ocamlnet docker container
```
docker run -p 8080:8080 -v $PWD:/home/opam/build -it ocamlnet bash
```
3. build sample application
```
./configure && make all
```
4. run
```
./main.native 8080
```
5. browse  http://DOCKER=HOST-IP:8080/

----
Takashi Masuyama < mamewotoko@gmail.com >
http://mamewo.ddo.jp/
