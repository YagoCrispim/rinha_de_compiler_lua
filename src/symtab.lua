local class = require "lib.class"

local SymbolTable = class({
  constructor = function (self)
    self._allowLog = true
    self.scopeLevel = 0
    self.currentScope = {}
    self.parentScope = nil
    self._symbols = {}
  end,
  methods = {
    lookup = function (self, name)
      local symbol = self._symbols[name]
      if symbol then
        return symbol
      end
      if self.parentScope then
        return self.parentScope:lookup(name)
      end
      return nil
    end,

    define = function (self, name, value)
      self:_log('Defining "' .. name .. '" with value: ' .. tostring(value) .. ' in scope ' .. self.scopeLevel)
      self._symbols[name] = value
    end,

    pushScope = function (self)
      self.scopeLevel = self.scopeLevel + 1
      self.currentScope = {}
      self.parentScope = self
    end,

    popScope = function (self)
      self.scopeLevel = self.scopeLevel - 1
      self.currentScope = {}
      self.parentScope = nil
    end,

    _log = function (self, ...)
      if self._allowLog then
        print('[SymTab]: ' .. ...)
      end
    end
  }
})

return SymbolTable
