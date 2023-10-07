#!/bin/bash

# Hot reload simulator
FILE="src/main.lua"
AST=$1

function hi() {
    echo "Running $FILE"
}

function timestamp() {
    echo "Last updated at $(date +"%T")"
}

function clear_screen() {
    clear
}

clear_screen
hi
timestamp

lua $FILE $AST &
PID=$!
trap "kill $PID" SIGINT

while inotifywait -r -q -e modify .; do
    kill $PID
    clear_screen
    hi
    timestamp
    lua $FILE $AST &
    PID=$!
done
