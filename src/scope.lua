local Scope = {
  name = '',
  level = 0,
  parentScope = {},
  symbols = {},
}
Scope.__index = Scope

function Scope:new(params)
  local instance = {}
  setmetatable(instance, self)
  instance.name = params.name
  instance.level = params.level
  instance.parentScope = params.parentScope
  instance.symbols = params.symbols or {}
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

return Scope
