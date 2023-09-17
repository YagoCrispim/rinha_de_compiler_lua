local class = require "lib.class"
local SymbolTable = require "src.symtab"

local interpreter = class({
  constructor = function (self)
    self._symtab = SymbolTable:new()
    self._allowLog = false
    self._operations = {
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
  end,
  methods = {
    interpret = function (self, ast)
      if ast.expression then
        return self:interpret(ast.expression)
      end
      self:_log('Calling', ast.kind)
      return self[ast.kind](self, ast)
    end,

    Print = function (self, ast)
      local value = self:interpret(ast.value)
      print(value)
    end,

    Str = function (self, ast)
      return ast.value
    end,

    Let = function (self, ast)
      self._symtab:define(ast.name.text, ast.value)
      self:interpret(ast.next)
    end,

    Call = function (self, ast)
      local fnDecl = self:interpret(ast.callee)

      -- push a new scope for the function
      self._symtab:pushScope()

      -- define the parameters in the new scope
      local fn = self:interpret(fnDecl)

      -- load the arguments into the new scope
      for i, v in pairs(ast.arguments) do
        local arg = self:interpret(v)
        self._symtab:define(fnDecl.parameters[i].text, arg)
      end

      -- interpret the function body
      local result = self:interpret(fn)

      -- pop the scope
      self._symtab:popScope()

      return result
    end,

    Var = function (self, ast)
      return self._symtab:lookup(ast.text)
    end,

    Int = function (self, ast)
      return ast.value
    end,

    Function = function (self, ast)
      for _, v in pairs(ast.parameters) do
        self._symtab:define(v.text, nil)
      end
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

      print(valA, opName, valB)
      local result = op(valA, valB)
      return result
    end,

    _log = function (self, ...)
      if self._allowLog then
        local currentLine = debug.getinfo(2).currentline
        print('[Line: ' .. currentLine .. ']' .. ' >>> ',  ...)
      end
    end,
  }
})

return interpreter
