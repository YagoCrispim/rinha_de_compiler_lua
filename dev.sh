#!/bin/bash

# Hot reload simulator

FILE="src/main.lua"

function clear_screen() {
    clear
}

clear_screen

lua $FILE &
PID=$!
trap "kill $PID" SIGINT

while inotifywait -r -q -e modify .; do
    kill $PID
    clear_screen
    lua $FILE &
    PID=$!
done
