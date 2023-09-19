local json = require 'lib.json'
local io = require 'io'
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

local interpreter = Interpreter:new()
for k, v in pairs({
  print = 'asts/print.json',
  fib = 'asts/fib.json',
  sum = 'asts/sum.json',
  combination = 'asts/combination.json',
}) do
  print('Interpreting "' .. k .. '" AST')
  local ast = readFile(v)
  interpreter:interpret(json.decode(ast), {})
  print('------------------')
end
