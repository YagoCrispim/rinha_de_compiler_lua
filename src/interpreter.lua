local SymbolTable = require "src.symtab"

local Interpreter = {
  _operations = {
    Eq = function (valA, valB)
      return valA == valB
    end,
    Sub = function (valA, valB)
      return valA - valB
    end,
    Add = function (valA, valB)
      return valA + valB
    end,
    Lt = function (valA, valB)
      return valA < valB
    end,
    Or = function (valA, valB)
      return valA or valB
    end
  }
}
Interpreter.__index = Interpreter

function Interpreter:new()
  local instance = {
    _symtab = SymbolTable:new(),
    _allowLog = false
  }
    setmetatable(instance, Interpreter)
    return instance
end

function Interpreter:interpret(ast)
  if ast.expression then
    return self:interpret(ast.expression)
  end
  return self[ast.kind](self, ast)
end

function Interpreter:Print(ast)
  local value = self:interpret(ast.value)
  print(value)
end

function Interpreter:Str(ast)
  return ast.value
end

function Interpreter:Let(ast)
  self._symtab:define(ast.name.text, ast.value)
  return self:interpret(ast.next)
end

function Interpreter:Call(ast)
  local fnDecl = self:interpret(ast.callee)

  self._symtab:pushScope()

  for i, v in pairs(ast.arguments) do
    local arg = self:interpret(v)
    self._symtab:define(fnDecl.parameters[i].text, arg)
  end

  local result = self:interpret(fnDecl.value)

  self._symtab:popScope()

  return result
end

function Interpreter:Var(ast)
  return self._symtab:lookup(ast.text)
end

function Interpreter:Int(ast)
  return ast.value
end

function Interpreter:If(ast)
  local condition = self:interpret(ast.condition)
  if condition then
    return self:interpret(ast['then'])
  else
    return self:interpret(ast.otherwise)
  end
end

function Interpreter:Binary(ast)
  local opName = ast.op
  local op = self._operations[opName]
  local valA = self:interpret(ast.lhs)
  local valB = self:interpret(ast.rhs)

  if type(valA) == 'table' then
    valA = self:interpret(valA)
  end

  if type(valB) == 'table' then
    valB = self:interpret(valB)
  end

  local result = op(valA, valB)
  return result
end

return Interpreter
