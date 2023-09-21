local class = require "lib.class"
local SymbolTable = require "src.symtab"

local memo = {}

local Op = {
  Eq = function (valA, valB)
    return valA == valB
  end,
  Sub = function (valA, valB)
    return valA - valB
  end,
  Add = function (valA, valB)
    if type(valA) == 'string' and type(valB) ~= 'string' then
      return valA .. tostring(valB)
    end
    if type(valA) ~= 'string' and type(valB) == 'string' then
      return tostring(valA) .. valB
    end
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
      local value = self:interpret(ast.value)
      
      if type(value) == "table" and value._type and value._type == "Tuple" then
        local result = ('(' .. value.first .. ', ' .. value.second .. ')')
        print(result)
        return result
      end
      print(value)
      return value
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
      local fnArgs = {}

      local memoizedFn = nil
      for i, v in pairs(ast.arguments) do
        local arg = self:interpret(v)

        if #ast.arguments == 1 then
          memoizedFn = ast.callee.text .. arg
        end

        fnArgs[fnDecl.parameters[i].text] = arg
      end

      if memoizedFn and memo[memoizedFn] then
        return memo[memoizedFn]
      end
      
      self._symtab:pushScope()
      for i, v in pairs(fnArgs) do
        self._symtab:define(i, v)
      end
      local result = self:interpret(fnDecl.value)

      if memoizedFn then
        memo[memoizedFn] = result
      end

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
    
      local result = op(valA, valB)

      return result
    end,

    Tuple = function (self, ast)
      return {
        _type = "Tuple",
        first = self:interpret(ast.first),
        second = self:interpret(ast.second),
      }
    end,
  }
})

return Interpreter
