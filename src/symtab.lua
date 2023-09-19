---@diagnostic disable: undefined-field

------ Scope table ------
local Scope = {
  name = '',
  level = 0,
  parentScope = nil,
  symbols = {},
}
Scope.__index = Scope

function Scope:new(params)
  local instance = {}
  setmetatable(instance, self)
  instance.name = params and params.name or ''
  instance.level = params and params.level or 0
  instance.parentScope = params and params.parentScope or nil
  instance.symbols = params and params.symbols or {}
  return instance
end

function Scope:lookup(name)
  local symbol = self.symbols[name]
  if symbol then
    return symbol
  end
  if self.parentScope then
    return self.parentScope:lookup(name)
  end
  return nil
end

function Scope:define(name, value)
    self.symbols[name] = value
end
------ End Scope table ------

------ SymbolTable table ------
local SymbolTable = {}
SymbolTable.__index = SymbolTable

function SymbolTable:new()
  local instance = {
    parentScope = nil,
    currentScope = {},
  }
  setmetatable(instance, self)
  instance.currentScope = Scope:new({
    name = 'global',
    level = 0,
    parentScope = nil
  })
  return instance
end

function SymbolTable:pushScope()
  self.currentScope.level = self.currentScope.level + 1
  local newScope = Scope:new({
    level = self.currentScope.level,
    name = 'scope' .. self.currentScope.level,
    parentScope = self.currentScope
  })
  self.currentScope = newScope
end

function SymbolTable:popScope()
  self.currentScope = self.currentScope.parentScope
  self.currentScope.level = self.currentScope.level - 1
end

function SymbolTable:lookup(name)
  return self.currentScope:lookup(name)
end

function SymbolTable:define(name, value)
  self.currentScope:define(name, value)
end

return SymbolTable
