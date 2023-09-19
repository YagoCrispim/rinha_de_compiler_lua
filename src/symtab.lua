local class = require "lib.class"
local Scope = require "src.scope"

local SymbolTable = class({
  constructor = function (self)
    self.parentScope = nil
    self.currentScope = Scope:new({
      level = 0,
      parentScope = nil
    })
  end,
  methods = {
    pushScope = function (self)
      self.currentScope.level = self.currentScope.level + 1
      local newScope = Scope:new({
        level = self.currentScope.level,
        parentScope = self.currentScope
      })
      self.currentScope = newScope
    end,

    popScope = function (self)
      self.currentScope = self.currentScope.parentScope
      self.currentScope.level = self.currentScope.level - 1
    end,

    lookup = function (self, name)
      return self.currentScope:lookup(name)
    end,

    define = function (self, name, value)
      self.currentScope:define(name, value)
    end,
  }
})

return SymbolTable
