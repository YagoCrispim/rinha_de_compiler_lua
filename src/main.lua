local Interpreter = require "src.interpreter"
local readJson = require 'src.utils.file'.readJson

local sourceFile = arg[1]

if not sourceFile then
  print('[ERROR]: No file specified')
  os.exit(1)
end

if sourceFile == '--docker' then
  sourceFile = '/var/rinha/source.rinha.json'
else
  sourceFile = 'asts/' .. sourceFile .. '.json'
end

local interpreter = Interpreter:new()
interpreter:interpret(readJson(sourceFile))
