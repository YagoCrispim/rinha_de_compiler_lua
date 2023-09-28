local class = require "lib.class"
local json = require 'lib.json'
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
    if type(valA) == "string" or type(valB) == "string" then
      return tostring(valA) .. tostring(valB)
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

      if type(value) == "table" and value._type then
        local result = nil
 
        if value._type == "Tuple" then
          result = ('(' .. tostring(value.first) .. ', ' .. tostring(value.second) .. ')')
        end

        if value._type == "fn" then
          result = "<#closure>"
        end

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
      if ast.value.kind ~= 'Function' then
        local value = self:interpret(ast.value)
        self._symtab:define(ast.name.text, value)
        return self:interpret(ast.next)
      end

      local node = self:interpret(ast.value)
      self._symtab:define(ast.name.text, node)
      return self:interpret(ast.next)
    end,

    Call = function (self, ast)
      local node = self:interpret(ast.callee)
      local fnDecl = nil
      local pure = false
      local scope = nil

      if node._type == 'fn' then
        fnDecl = node.value
        pure = node.pure
        scope = node.scope
      else
        fnDecl = node
      end

      local fnArgs = {}

      local memoizedFn = nil
      for i, v in pairs(ast.arguments) do
        local arg = self:interpret(v)

        if pure then
          if #ast.arguments == 1 then
            memoizedFn = ast.callee.text .. arg
          end
        end

        fnArgs[fnDecl.parameters[i].text] = arg
      end

      if pure and memoizedFn and memo[memoizedFn] then
        return memo[memoizedFn]
      end

      if scope then
        self._symtab.currentScope = scope
      else
        self._symtab:pushScope()
      end

      for i, v in pairs(fnArgs) do
        self._symtab:define(i, v)
      end
      local result = self:interpret(fnDecl.value)

      if pure and memoizedFn then
        memo[memoizedFn] = result
      end

      if type(result) == "table" and result._type == 'fn' then
        result.scope = self._symtab.currentScope
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

      return op(valA, valB)
    end,

    Tuple = function (self, ast)
      return {
        _type = "Tuple",
        first = self:interpret(ast.first),
        second = self:interpret(ast.second),
      }
    end,

    First = function (self, ast)
      local tuple = self:interpret(ast.value)
      return tuple.first
    end,

    Second = function (self, ast)
      local tuple = self:interpret(ast.value)
      return tuple.second
    end,

    Function = function (self, ast)
      --[[
      TODO
        Check if the fn is accessing a variable from the outer scope
        Check if the fn is calling another fn that is not pure
      ]]
      local fnNodeStr = json.encode(ast)
      local result = {
        _type = 'fn',
        pure = true,
        value = ast,
      }
      local isPure = string.find(fnNodeStr, '"kind":"Print"')
      
      if isPure then
        result.pure = false
      end

      return result
    end,
  }
})

return Interpreter
