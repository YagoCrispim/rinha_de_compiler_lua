local class = require "lib.class"

local Scope = class({
  constructor = function (self, params)
    self.name = params.name
    self.level = params.level
    self.parentScope = params.parentScope
    self.symbols = {}
  end,
  methods = {
    lookup = function (self, name)
      local symbol = self.symbols[name]
      if symbol then
        return symbol
      end
      if self.parentScope then
        return self.parentScope:lookup(name)
      end
      return nil
    end,

    define = function (self, name, value)
      self.symbols[name] = value
    end,

    _log = function (self, ...)
      if self._allowLog then
        print('[SymTab]: ' .. ...)
      end
    end
  }
})

local SymbolTable = class({
  constructor = function (self)
    self.parentScope = nil
    self.currentScope = Scope:new({
      name = 'global',
      level = 0,
      parentScope = nil
    })
  end,
  methods = {
    pushScope = function (self)
      local parentScope = self.currentScope
      self.currentScope = Scope:new({
        name = 'scope' .. self.currentScope.level + 1,
        level = self.currentScope.level + 1,
        parentScope = parentScope
      })
    end,

    popScope = function (self)
      local currentScope = self.currentScope.parentScope
      currentScope.level = currentScope.level - 1
      self.currentScope = currentScope
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
