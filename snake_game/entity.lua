local Vector2 = require("vector2")

local Entity = {}
Entity.__index = Entity

function Entity.new()
    return setmetatable({ components = {} }, Entity)
end

function Entity:addComponent(name, component)
    assert(type(name) == "string", "component name must be a string")
    assert(type(component) == "table", "component must be a table")
    self.components[name] = component
    return self
end

function Entity:getComponent(name)
    return self.components[name]
end

function Entity:hasComponent(name)
    return self.components[name] ~= nil
end

function Entity.position(x, y)
    return { value = Vector2.new(x, y) }
end

function Entity.movement(dx, dy)
    return { direction = Vector2.new(dx or 0, dy or 0) }
end

function Entity.renderer(color, size)
    return {
        color = color or { 0.30, 0.82, 0.52, 1 },
        size = size or 22,
    }
end

return Entity
