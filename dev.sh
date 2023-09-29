#!/bin/bash

# Hot reload simulator
FILE="src/main_cp.lua"
AST=$1

function clear_screen() {
    clear
}

clear_screen

lua $FILE $AST &
PID=$!
trap "kill $PID" SIGINT

while inotifywait -r -q -e modify .; do
    kill $PID
    clear_screen
    lua $FILE $AST &
    PID=$!
done
