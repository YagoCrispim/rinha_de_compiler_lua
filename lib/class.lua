local fns = {
    wasSuperCalled = 0,
    _runConstructor = function(_, instance, constructor, params)
        if constructor and type(constructor) == "function" then
            constructor(instance, params)
        end
        return instance
    end,

    _setMethods = function(_, instance, methods)
        if methods and type(methods) == "table" then
            for name, method in pairs(methods) do
                instance[name] = method
            end
        end
        return instance
    end,

    _setInheritance = function(self, instance, superClass)
        if superClass and type(superClass) == "table" then
            instance.super = function(parameters)
                self.wasSuperCalled = 1
                local superInstance = superClass:new(parameters)
                setmetatable(instance, { __index = superInstance })
            end
        end
        return instance
    end,

    _validateSuperCall = function(self, classDef)
        if classDef.extends and self.wasSuperCalled == 0 then
            self.wasSuperCalled = 0
            if self.classDefinition.name and self.classDefinition.name ~= "" then
                print("[ERROR]: Super constructor was not called in " .. self.classDefinition.name .. ".")
                os.exit(1)
            else
                print("[ERROR]: Some class is missing a super constructor call.")
                os.exit(1)
            end
        end
    end,
}

local function class(classDefinition)
    return {
        new = function(_, constructorParams)
            local blueprint = {}
            if classDefinition == nil then return blueprint end
            blueprint = fns:_setMethods(blueprint, classDefinition.methods)
            blueprint = fns:_setInheritance(blueprint, classDefinition.extends)
            blueprint = fns:_runConstructor(blueprint, classDefinition.constructor, constructorParams)
            fns:_validateSuperCall(classDefinition)
            return blueprint
        end,
    }
end

return class
