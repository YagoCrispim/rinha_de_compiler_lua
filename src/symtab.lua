local class = require "lib.class"
local Scope = require "src.scope"

local SymbolTable = class({
  constructor = function (self)
    self.parentScope = nil
    self.currentScope = Scope:new({
      parentScope = nil
    })
  end,
  methods = {
    pushScope = function (self)
      self.currentScope = Scope:new({
        parentScope = self.currentScope
      })
    end,

    popScope = function (self)
      self.currentScope = self.currentScope.parentScope
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
