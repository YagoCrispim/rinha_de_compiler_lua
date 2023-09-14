local json = require 'lib.json'
local io = require 'io'

local function readFile(path)
    local file = io.open(path, 'r')
    if file == nil then
      return nil
    end
    local content = file:read('*a')
    file:close()
    return content
end

local function includes(table, value)
  for k, v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

local astPaths = {
  print = 'asts/print.json',
  combination = 'asts/combination.json',
  fib = 'asts/fib.json',
  sum = 'asts/sum.json'
}

local interpreter = {
  -- properties
  symbolTable = {},
  allowedStatements = { 'Print' },

  -- methods
  interpret = function (self, ast)
    for k, v in pairs(ast) do
      local kind = v.kind
        if includes(self.allowedStatements, kind) then
          local visitor = self['visit' .. kind]
          visitor(self, v)
        end
      end
  end,

  visitPrint = function (self, node)
    local value = node.value.value
    print(value)
  end
}

-- print
local print = readFile(astPaths.print)
interpreter:interpret(json.decode(print))

-- sum
-- local sum = readFile(astPaths.sum)
-- interpreter:interpret(json.decode(sum))
