local class = require "src.class"
local d = require "lib.tabledump"

-- local log = true
local log = false
local interpreter = class({
  constructor = function (self)
    self._symtab = {}
    self._log = log
    self._operations = {
      ["Eq"] = function (valA, valB)
        return valA == valB
      end,
      ["Sub"] = function (valA, valB)
        return valA - valB
      end,
      ["Add"] = function (valA, valB)
        return valA + valB
      end,
      ["Lt"] = function (valA, valB)
        return valA < valB
      end
    }
  end,
  methods = {
    interpret = function (self, ast)
      if ast.expression then
        return self:interpret(ast.expression)
      end
      self:log('Calling', ast.kind)
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
      self._symtab[ast.name.text] = ast.value
      self:interpret(ast.next)
    end,

    Call = function (self, ast)
      local fn = self:interpret(ast.callee)
      local calleeArgs = ast.arguments
      local fnParams = fn.parameters
      local fnBody = fn.value

      for i, v in ipairs(fnParams) do
        local arg = self:interpret(calleeArgs[i])
        self._symtab[v.text] = arg
      end

      local result = self:interpret(fnBody)
      return result
    end,

    Var = function (self, ast)
      local res = self._symtab[ast.text]
      return res
    end,

    Int = function (self, ast)
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
      local op = self._operations[ast.op]
      local valA = self:interpret(ast.lhs)
      local valB = self:interpret(ast.rhs)
      local result = op(valA, valB)
      return result
    end,

    log = function (self, ...)
      if self._log then
        local currentLine = debug.getinfo(2).currentline
        print('[Line: ' .. currentLine .. ']' .. ' >>> ',  ...)
      end
    end,
  }
})

return interpreter
