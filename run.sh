#!/bin/bash

SCRIPTS_DIR="./scripts"
FILENAME=$1
ARG=$2

if [ "$ARG" == "--exec" ]; then
    ./scripts/single-run.sh $FILENAME
    exit 0
fi

# get the list of the scripts in folder, list them with a number and ask the user to choose one

# get the list of the scripts in folder
SCRIPTS=()
for SCRIPT in $SCRIPTS_DIR/*.sh; do
    SCRIPTS+=($(basename $SCRIPT))
done

# list them with a number
for i in "${!SCRIPTS[@]}"; do
    printf "%s: %s\n" "$i" "${SCRIPTS[$i]}"
done

# ask the user to choose one
read -p "Choose a script: " SCRIPT_CHOICE

# run the script
$SCRIPTS_DIR/${SCRIPTS[$SCRIPT_CHOICE]} $ARG
