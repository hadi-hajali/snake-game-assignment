local Input = {}
Input.__index = Input

function Input.new()
    return setmetatable({ commands = {} }, Input)
end

function Input:bind(key, command)
    assert(type(key) == "string", "key must be a string")
    assert(type(command) == "function", "command must be a function")
    self.commands[key] = command
end

function Input:handleKey(key)
    local command = self.commands[key]
    if command then
        command()
        return true
    end
    return false
end

return Input
