#!/bin/bash

FLAG=$1

function echotitle() {
    echo "--------------------"
    echo "Running with $1"
    echo "--------------------"
}

if [ "$USEJIT" = "jit" ]; then
    echotitle "luajit"
    time luajit src/main.lua
else
    echotitle "lua"
    time lua src/main.lua
fi
