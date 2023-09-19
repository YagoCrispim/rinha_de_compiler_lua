#!/bin/bash

FILE="src/main.lua"
eval $(luarocks path)

function clear_screen() {
    clear
}

clear_screen

lua $FILE &
PID=$!
trap "kill $PID" SIGINT

while inotifywait -r -q -e modify .; do
    eval $(luarocks path)
    kill $PID
    clear_screen
    lua $FILE &
    PID=$!
done
