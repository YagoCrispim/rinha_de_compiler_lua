#!/bin/bash

lua src/interpreter.lua

#!/bin/bash

# first argument
FILE="src/interpreter.lua"
eval $(luarocks path)

function clear_screen() {
    clear
}

clear_screen

lua $FILE &

# get the PID of the last process
PID=$!

# kill the server when the server is modified
trap "kill $PID" SIGINT

# watch for changes
# while inotifywait -r -q -e modify src; do
while inotifywait -r -q -e modify .; do
    eval $(luarocks path)
    # kill the server
    kill $PID

    # clear the screen and write header
    clear_screen

    # start the server
    lua $FILE &

    # get the PID of the last process
    PID=$!
done
