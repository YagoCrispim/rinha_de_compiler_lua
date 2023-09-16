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

print('Interpreting "print - Hello world" AST')
local printAst = readFile(astPaths.print)
interpreter:interpret(json.decode(printAst))

print('\nInterpreting "sum" AST')
local sumAst = readFile(astPaths.sum)
interpreter:interpret(json.decode(sumAst))

-- print('\nInterpreting "fib" AST')
-- local sumAst = readFile(astPaths.fib)
-- interpreter:interpret(json.decode(sumAst))
