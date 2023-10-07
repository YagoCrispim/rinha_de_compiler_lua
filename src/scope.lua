local class = require "lib.class"

local Scope = class({
  constructor = function (self, params)
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
    end,

    define = function (self, name, value)
        self.symbols[name] = value
    end
  }
})

return Scope
