local io = require 'io'
local json = require 'lib.json'
local Interpreter = require "src.interpreter"

local pathBaseName = 'asts/'

local function readFile(path)
  local file = io.open(path, 'r')
  if file == nil then
    return nil
  end
  local content = file:read('*a')
  file:close()
  return content
end

local testerFn = function(name, cb)
  print('---- ' .. name .. ' ----')
  local result = cb()
  if result then
    print('OK')
  else
    print('FAIL')
  end
  print('------------------')
end

local interpreter = Interpreter:new()

-- Fibonacci
testerFn('Fibonacci (10)', function()
  local res = interpreter:interpret(json.decode(readFile(pathBaseName .. 'fib.json')))
  return res == 55
end)

-- Sum
testerFn('Sum', function()
  local res = interpreter:interpret(json.decode(readFile(pathBaseName .. 'sum.json')))
  return res == 15
end)

-- Combination
testerFn('Combination', function()
  local res = interpreter:interpret(json.decode(readFile(pathBaseName .. 'combination.json')))
  return res == 45
end)

-- Print tuple
testerFn('Print tuple', function()
  local res = interpreter:interpret(json.decode(readFile(pathBaseName .. 'print_tuple.json')))
  return res == '(1, 2)'
end)

-- Concat
testerFn('Concat', function()
  local res = interpreter:interpret(json.decode(readFile(pathBaseName .. 'concate.json')))
  return res == '1 :11'
end)

-- Sub
testerFn('Sub', function()
  local res = interpreter:interpret(json.decode(readFile(pathBaseName .. 'sub.json')))
  return res == -9
end)
