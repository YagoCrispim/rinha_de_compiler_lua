local class = require "lib.class"
local Op = require "src.operations"
local SymbolTable = require "src.symtab"

------- temp -------
local typeFn = 'fn'
local typeTuple = 'tuple'
--------------------

local Interpreter = class({
    constructor = function(self)
        self._symtab = SymbolTable:new()
        self._operations = Op
    end,
    methods = {
        interpret = function(self, ast)
            if not ast then return nil end
            if ast.expression then
                return self:interpret(ast.expression)
            end
            return self[ast.kind](self, ast)
        end,

        Print = function(self, ast)
            local value = self:interpret(ast.value)
            local result = value

            if type(value) == "table" and value._type then
                if value._type == typeTuple then
                    result = ('(' .. tostring(value.first) .. ', ' .. tostring(value.second) .. ')')
                end

                if value._type == typeFn then
                    result = "<#closure>"
                end
            end
            print(result)
        end,

        Str = function(_, ast)
            return ast.value
        end,

        Let = function(self, ast)
            if ast.value.kind ~= typeFn then
                local value = self:interpret(ast.value)
                self._symtab:define(ast.name.text, value)
                return self:interpret(ast.next)
            end

            local node = self:interpret(ast.value)
            self._symtab:define(ast.name.text, node)
            return self:interpret(ast.next)
        end,

        Call = function(self, ast)
            local node = self:interpret(ast.callee)
            local fnDecl = nil
            local scope = nil

            if node._type == typeFn then
                fnDecl = node.value
                scope = node.scope
            else
                fnDecl = node
            end

            local fnArgs = {}

            for i, v in pairs(ast.arguments) do
                local arg = self:interpret(v)
                fnArgs[fnDecl.parameters[i].text] = arg
            end

            if scope then
                self._symtab.currentScope = scope
            else
                self._symtab:pushScope()
            end

            for i, v in pairs(fnArgs) do
                self._symtab:define(i, v)
            end
            local result = self:interpret(fnDecl.value)

            if type(result) == "table" and result._type == typeFn then
                result.scope = self._symtab.currentScope
            end

            self._symtab:popScope()
            return result
        end,

        Var = function(self, ast)
            return self._symtab:lookup(ast.text)
        end,

        Int = function(_, ast)
            return ast.value
        end,

        If = function(self, ast)
            local condition = self:interpret(ast.condition)
            if condition then
                return self:interpret(ast['then'])
            else
                return self:interpret(ast.otherwise)
            end
        end,

        Binary = function(self, ast)
            local op = self._operations[ast.op]
            local valA = self:interpret(ast.lhs)
            local valB = self:interpret(ast.rhs)
            return op(valA, valB)
        end,

        Tuple = function(self, ast)
            return {
                _type = typeTuple,
                first = self:interpret(ast.first),
                second = self:interpret(ast.second),
            }
        end,

        First = function(self, ast)
            local tuple = self:interpret(ast.value)
            return tuple.first
        end,

        Bool = function(_, ast)
            return ast.value
        end,

        Second = function(self, ast)
            local tuple = self:interpret(ast.value)
            return tuple.second
        end,

        Function = function(_, ast)
            return {
                _type = typeFn,
                value = ast,
            }
        end,
    }
})

return Interpreter
