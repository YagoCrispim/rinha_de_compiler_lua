local class = require "lib.class"
local SymbolTable = require "src.symtab"

local interpreter = class({
  constructor = function (self)
    self.c = 0
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
      return self:interpret(ast.next)
    end,

    Call = function (self, ast)
      local fnDecl = self:interpret(ast.callee)

      -- push a new scope for the function
      self._symtab:pushScope()

      -- load the arguments into the new scope
      for i, v in pairs(ast.arguments) do
        local arg = self:interpret(v)
        self._symtab:define(fnDecl.parameters[i].text, arg)
      end

      -- interpret the function body
      local result = self:interpret(fnDecl.value)

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

    If = function (self, ast)
      local condition = self:interpret(ast.condition)
      if condition then
        -- breakpoint cond: ast['then'].kind == 'Int' and ast['then'].value == 1 and self.c == 89
        return self:interpret(ast['then'])
      else
        return self:interpret(ast.otherwise)
      end
    end,

    Binary = function (self, ast)
      self.c = self.c + 1

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
