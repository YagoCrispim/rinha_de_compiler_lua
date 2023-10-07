#!/bin/bash

FILENAME=$1
docker run -v ./asts/$FILENAME:/var/rinha/source.rinha.json --memory=2gb rinha-de-compiler-lua