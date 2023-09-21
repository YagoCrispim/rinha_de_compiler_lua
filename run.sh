#!/bin/bash

FILE_NAME=$1
docker run -e file=$FILE_NAME rinha-de-compiler-lua
