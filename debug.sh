#!/bin/bash

lua src/interpreter.lua
eval $(luarocks path)
