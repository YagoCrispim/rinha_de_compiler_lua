local json = require 'lib.json'
local io = require 'io'

--[[
  TODO: Write fn docs
]]

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

local interpreter = {
  symbolTable = {
    -- For now only global scope
    variables = {},
  },
  operations = {
    ["Eq"] = function (valA, valB)
      return valA == valB
    end,
    ["Sub"] = function (valA, valB)
      return valA - valB
    end,
    ["Add"] = function (valA, valB)
      return valA + valB
    end
  },

  interpret = function (self, ast)
    for _, v in pairs(ast) do
        if v.kind then
          self:visit(v)
        end
        
        if v.next then
          self:visit(v.next)
        end
      end
  end,

  visit = function (self, node)
    local kind = node.kind
    local visitor = self['visit' .. kind]
    return visitor(self, node)
  end,

  visitPrint = function (self, node)
    local kind = node.value.kind
    if kind == 'Str' or kind == 'Int' then
      local value = node.value.value
      print(value)
    end

    if kind == 'Call' then
      local value = self:visit(node.value)
      print(value)
    end
  end,

  -- Variable declaration
  visitLet = function (self, node)
    local name = node.name.text
    local value = self:visit(node.value)
    table.insert(self.symbolTable.variables, { name = name, value = value })
  end,

  -- Function declaration
  visitFunction = function (self, node)
    return node
  end,

  -- Function call
  visitCall = function (self, node)
    local fnNode = self:visit(node.callee)
    local fnRef = fnNode.value
    if not fnRef then
      error('Function not found')
    end

    local fnParams = {}
    local fnArgs = {}

    for _, v in pairs(fnRef.parameters) do
      table.insert(fnParams, v.text)
    end
    
    for _, v in pairs(node.arguments) do
      local arg = self:visit(v)
      table.insert(fnArgs, arg)
    end
    
    if #fnParams ~= #fnArgs then
      error('Invalid number of arguments')
    end

    for i = 1, #fnParams do
      local varName = fnParams[i]
      local varValue = fnArgs[i]
      table.insert(self.symbolTable.variables, { name = varName, value = varValue })
    end

    return self:visit(fnRef.value)
  end,

  visitIf = function (self, node)
    local condition = self:visit(node.condition)
    
    if condition then
      local thenNode = node['then']
      local result = self:visit(thenNode)
      return result.value
    else
      local result = self:visit(node.otherwise)
      return result
    end
  end,

  visitBinary = function (self, node)
    local left = self:visit(node.lhs)
    local right = self:visit(node.rhs)
    local operator = node.op
    
    local operation = self.operations[operator]
    if not operation then
      error('Invalid operation. ' .. 'Operator ' .. '"' .. operator .. '"' .. ' not found')
    end

    local result = operation(left.value, right)

    if operator == 'Eq' then
      return result
    end

    table.insert(self.symbolTable.variables, { name = left.name, value = result })
    return result
  end,

  visitVar = function (self, node)
    local name = node.text
    local value = nil
    for _, v in pairs(self.symbolTable.variables) do
      if v.name == name then
        value = v.value
      end
    end
    return { name = name, value = value }
  end,

  visitInt = function (self, node)
    local value = node.value
    return value
  end,
}

print('Interpreting "print - Hello world" AST')
local printAst = readFile(astPaths.print)
interpreter:interpret(json.decode(printAst))

print('\nInterpreting "sum" AST')
local sumAst = readFile(astPaths.sum)
interpreter:interpret(json.decode(sumAst))
