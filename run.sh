#!/bin/bash

FILE_NAME=$1
docker run -e file=$FILE_NAME -v $(pwd)/asts/:/app/asts rinha-de-compiler-lua
