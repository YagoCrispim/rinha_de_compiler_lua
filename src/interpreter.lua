local class = require "lib.class"
local SymbolTable = require "src.symtab"

local Op = {
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
  end,
}

local Interpreter = class({
  constructor = function (self)
    self._symtab = SymbolTable:new()
    self._allowLog = false
    self._operations = Op
  end,
  methods = {
    interpret = function (self, ast)
      if ast.expression then
        return self:interpret(ast.expression)
      end
      return self[ast.kind](self, ast)
    end,

    Print = function (self, ast)
      print(self:interpret(ast.value))
    end,

    Str = function (_, ast)
      return ast.value
    end,

    Let = function (self, ast)
      self._symtab:define(ast.name.text, ast.value)
      return self:interpret(ast.next)
    end,

    Call = function (self, ast)
      local fnDecl = self:interpret(ast.callee)
      self._symtab:pushScope()

      for i, v in pairs(ast.arguments) do
        local arg = self:interpret(v)
        self._symtab:define(fnDecl.parameters[i].text, arg)
      end

      local result = self:interpret(fnDecl.value)
      self._symtab:popScope()
      return result
    end,

    Var = function (self, ast)
      return self._symtab:lookup(ast.text)
    end,

    Int = function (_, ast)
      return ast.value
    end,

    If = function (self, ast)
      local condition = self:interpret(ast.condition)
      if condition then
        return self:interpret(ast['then'])
      else
        return self:interpret(ast.otherwise)
      end
    end,

    Binary = function (self, ast)
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

      return op(valA, valB)
    end
  }
})

return Interpreter
