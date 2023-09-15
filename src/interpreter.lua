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
    end,
    ["Lt"] = function (valA, valB)
      return valA < valB
    end
  },

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
    local kind = node.kind
    local visitor = self['_visit' .. kind]
    return visitor(self, node)
  end,

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

  -- Variable declaration
  _visitLet = function (self, node)
    local name = node.name.text
    local value = self:_visit(node.value)
    local varInTable = self:_lookup(name)
    if not varInTable then
      table.insert(self.symbolTable.variables, { name = name, value = value })
    else
      varInTable.value = value
    end
  end,

  -- Function declaration
  _visitFunction = function (self, node)
    return node
  end,

  -- Function call
  _visitCall = function (self, node)
    local fnNode = self:_visit(node.callee)
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
      local arg = self:_visit(v)
      table.insert(fnArgs, arg)
    end
    
    if #fnParams ~= #fnArgs then
      error('Invalid number of arguments')
    end

    for i = 1, #fnParams do
      local varName = fnParams[i]
      local varValue = fnArgs[i]

      local varInTable = self:_lookup(varName)
      if not varInTable then
        table.insert(self.symbolTable.variables, { name = varName, value = varValue })
      else
        varInTable.value = varValue
      end
    end

    return self:_visit(fnRef.value)
  end,

  _visitIf = function (self, node)
    local condition = self:_visit(node.condition)
    
    if condition then
      local thenNode = node['then']
      local result = self:_visit(thenNode)
      return result.value
    else
      local result = self:_visit(node.otherwise)
      return result
    end
  end,

  _visitBinary = function (self, node)
    local left = self:_visit(node.lhs)
    local operator = node.op
    local right = self:_visit(node.rhs)

    local operation = self.operations[operator]
    if not operation then
      error('Invalid operation. ' .. 'Operator ' .. '"' .. operator .. '"' .. ' not found')
    end

    -- gamb
    local leftValue = nil
    if type(left) == "table" and left.value ~= nil then
      leftValue = left.value
    else
      leftValue = left
    end
    local result = operation(leftValue, right)

    if operator == 'Eq' then
      return result
    end

    local varInTable = self:_lookup(left.name)
    if not varInTable then
      table.insert(self.symbolTable.variables, { name = left.name, value = result })
    else
      varInTable.value = left.value
    end
    return result
  end,

  _visitVar = function (self, node)
    local name = node.text
    local value = nil
    for _, v in pairs(self.symbolTable.variables) do
      if v.name == name then
        value = v.value
      end
    end
    return { name = name, value = value }
  end,

  _visitInt = function (self, node)
    local value = node.value
    return value
  end,

  -- helpers
  _lookup = function (self, name)
    local result = nil
    for _, v in pairs(self.symbolTable.variables) do
      if v.name == name then
        result = v
      end
    end
    return result
  end
}

return interpreter