local json = require 'lib.json'
local io = require 'io'
local interpreter = require "src.interpreter"

-- global
D = require "lib.tabledump"

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
  local ast = readFile(v)
  interpreter:new():interpret(json.decode(ast), {})
  print('------------------')
end
