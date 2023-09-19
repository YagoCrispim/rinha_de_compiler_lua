local io = require 'io'
local json = require 'lib.json'
local Interpreter = require "src.interpreter"

local function readFile(path)
  local file = io.open(path, 'r')
  if file == nil then
    return nil
  end
  local content = file:read('*a')
  file:close()
  return content
end

for k, v in pairs({
  print = 'asts/print.json',
  fib = 'asts/fib.json',
  sum = 'asts/sum.json',
  combination = 'asts/combination.json',
}) do
  print('Interpreting "' .. k .. '" AST')
  Interpreter:new():interpret(json.decode(readFile(v)))
  print('------------------')
end
