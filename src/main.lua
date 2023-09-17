local json = require 'lib.json'
local io = require 'io'
local interpreter = require "src.interpreter"

local function readFile(path)
  local file = io.open(path, 'r')
  if file == nil then
    return nil
  end
  local content = file:read('*a')
  file:close()
  return content
end

local astPaths = {
  print = 'asts/print.json',
  combination = 'asts/combination.json',
  fib = 'asts/fib.json',
  sum = 'asts/sum.json'
}

for k, v in pairs({
  -- print = astPaths.print,
  -- sumAst = astPaths.sum,
  fibAst = astPaths.fib -- expected: 55 || 13
}) do
  print('Interpreting "' .. k .. '" AST')
  local ast = readFile(v)
  interpreter:new():interpret(json.decode(ast), {})
  print('------------------')
end
