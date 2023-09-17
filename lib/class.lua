--[[
    Responsible for:
        - Get the path and line of the class declaration
        - Get the path and line of the class instantiation
    
    @params
        - number::levels - Number of levels to go up in the stack trace
            - optional
            - default = 3
]]
local function getCurrentPathAndLine(levels)
    local levesToGoUp = levels or 3
    return {
        path = debug.getinfo(levesToGoUp, "S").source,
        line = debug.getinfo(levesToGoUp, "l").currentline,
    }
end

--[[
    Responsible for:
        - Copy the methods declaration to blueprint
        - Execute the constructor that is in the class definition
        - Execute the constructor of the parent class, if exists
        - Make available to the blueprint what is declared in the super class
    
    @params
        - table::classDefinition
            - Table with the class definition:
                - function::constructor
                    - Function that will be executed when instantiating the class
                - table::methods
                    - Table containing the methods of the class
                - table::extends
                    - Table containing the parent class
]]
local function class(classDefinition)
    local wasSuperCalled = 0

    return {
        new = function(self, constructorParams)
            local function _runConstructor(instance, constructor, params)
                if constructor and type(constructor) == "function" then
                    constructor(instance, params)
                end
                return instance
            end

            local function _setMethods(instance, methods)
                if methods and type(methods) == "table" then
                    for name, method in pairs(methods) do
                        instance[name] = method
                    end
                end
                return instance
            end

            local function _setInheritance(instance, superClass)
                if superClass and type(superClass) == "table" then
                    instance.super = function(parameters)
                        wasSuperCalled = 1
                        local superInstance = superClass:new(parameters)
                        setmetatable(instance, { __index = superInstance })
                    end
                end
                return instance
            end

            local function validateSuperCall(classDef)
                if classDef.extends and wasSuperCalled == 0 then
                    if classDefinition.name and classDefinition.name ~= "" then
                        Err("[ERROR]: Super constructor was not called in " .. classDefinition.name .. ".")
                        os.exit(1)
                    else
                        Err("[ERROR]: Some class is missing a super constructor call.")
                        os.exit(1)
                    end
                end
            end

            local blueprint = {
                __path = getCurrentPathAndLine().path,
                __line = getCurrentPathAndLine().line,
            }

            if classDefinition == nil then
                return blueprint
            end

            blueprint = _setMethods(blueprint, classDefinition.methods)
            blueprint = _setInheritance(blueprint, classDefinition.extends)
            blueprint = _runConstructor(blueprint, classDefinition.constructor, constructorParams)
            validateSuperCall(classDefinition)
            return blueprint
        end,
    }
end

return class
