local d = require "lib.tabledump"
local log = function (...)
  local currentLine = debug.getinfo(2).currentline
  print(currentLine, ...)
end

local interpreter = {
  _logVisitorName = false,
  --[[
    Description: Represents the symbol table.

    @wip: scopes
    @return: any
  ]]
  _symbolTable = {
    variables = {},
  },

  --[[
    Description: Represents the operations supported by the interpreter.
    
    @return: any
  ]]
  _operations = {
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
  },

  --[[
    Description: Interprets the AST.
    
    @param ast: AST
    @return: nil
  ]]
  interpret = function (self, ast)
    for _, v in pairs(ast) do
        if v.kind then
          self:_visit(v)
        end
        
        if v.next then
          self:_visit(v.next)
        end
      end
  end,

  _visit = function (self, node)
    if self._logVisitorName then
      log('Visiting: ' .. '_visit' .. node.kind)
    end

    local kind = node.kind
    local visitor = self['_visit' .. kind]
    return visitor(self, node)
  end,

  --[[
      Description: Prints any values
      Returns: nil
  ]]
  _visitPrint = function (self, node)
    local kind = node.value.kind
    if kind == 'Str' or kind == 'Int' then
      local value = node.value.value
      print(value)
    end

    if kind == 'Call' then
      local value = self:_visit(node.value)
      print(value)
    end
  end,

  --[[
      Insert the given variable into the symbol table -|-
      If the variable already exists, update its value (while there is no scope support yet)

      @param node: AST node kind "Let"
      @return: nil
      @return type: nil
  ]]
  _visitLet = function (self, node)
    local name = node.name.text
    local value = self:_visit(node.value)
    self:_insert(name, value)
  end,

  --[[
    Description: Represents the function declaration.

    @param node: AST node kind "Function"
    @return: AST node kind "Function"
    @return type: table

    @example:
      {
        value: table with all the function node
      }
  ]]
  _visitFunction = function (self, node)
    return node
  end,

  --[[
    Description: Represents the function call
    @return: AST node kind "Call"
    @return type: table
    WIP
  ]]
  _visitCall = function (self, node)
    local fnNode = self:_visit(node.callee)
    local fnBody = fnNode.value.value

    if not fnNode then
      self._err('Function not defined')
    end

    if #fnNode.value.parameters ~= #node.arguments then
      self._err('Invalid number of arguments')
    end

    local fnArgs = {}
    for i, v in pairs(fnNode.value.parameters) do
      local param = v.text
      local argument = self:_visit(node.arguments[i])
      table.insert(fnArgs, { name = param, value = argument.value })
    end

    for _, argument in pairs(fnArgs) do
      local name = argument.name
      local value = argument.value
      self:_insert(name, value)
    end
    return self:_visit(fnBody)
  end,

  --[[
    Description: Represents a boolean expression
    
    @param node: AST node kind "If" containing the block of code to be executed if the condition is true.
    The otherwise block is optional.

    @return:
    {
      value: any | nil
    }
  ]]
  _visitIf = function (self, node)
    local condition = self:_visit(node.condition)
    local result = nil

    if condition.value then
      local thenNode = node['then']
      local conditionResult = self:_visit(thenNode)
      result = conditionResult.value
    else
      if node.otherwise then
        local conditionResult = self:_visit(node.otherwise)
        result = conditionResult.value
      end
    end
    return result
  end,

  _visitBinary = function (self, node)
    local left = self:_visit(node.lhs)
    local operator = node.op
    local right = self:_visit(node.rhs)

    local operation = self._operations[operator]
    if not operation then
      self._err('Invalid operation. ' .. 'Operator ' .. '"' .. operator .. '"' .. ' not found')
    end

    local standardizeValue = function (val)
      if type(val) == "table" and val.value ~= nil then
        return val.value
      else
        return val
      end
    end

    -- gamb
    local leftValue = standardizeValue(left)
    local rightValue = standardizeValue(right)
    local result = operation(leftValue, rightValue)

    if operator == 'Eq' or operator == 'Lt' then
      return { value = result }
    end

    self:_insert(left.name, result)
    return { value = result }
  end,

  --[[
    Description: Represents the variable reference.
    
    @return value
      {
        name: string,
        value: any | nil
      }
  ]]
  _visitVar = function (self, node)
    local name = node.text
    local result = nil

    for _, v in pairs(self._symbolTable.variables) do
      if v.name == name then
        result = v
      end
    end
    return result
  end,

  --[[
    Description: Represents the string literal.
    
    @return value
      {
        value: string
      }
  ]]
  _visitInt = function (self, node)
    return {
      value = node.value
    }
  end,

  -- #####################################################
  -- #                                                   #
  -- #                     Helpers                       #
  -- #                                                   #
  -- #####################################################

  --[[
    Description: Lookup for a variable in the symbol table.
    
    @param name: string
    @return:
      {
        value: any | nil
      }
  ]]
  _lookup = function (self, name)
    local result = nil
    for _, v in pairs(self._symbolTable.variables) do
      if v.name == name then
        result = v
      end
    end
    return result
  end,

  --[[
    Description: Insert a variable into the symbol table.
    
    @param name: string
    @param value: any
    @return: nil
  ]]
  _insert = function (self, name, value)
      table.insert(self._symbolTable.variables, { name = name, value = value })
  end,

  --[[
    Description: Prints an error message.
    
    @param message: string
    @return: nil
  ]]
  _err = function (...)
    log('\n')
    log('[ERROR]: ' .. ...)
    log('\n')
  end
}

return interpreter