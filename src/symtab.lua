local Scope = require "src.scope"

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
