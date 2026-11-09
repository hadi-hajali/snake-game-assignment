local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
    return setmetatable({ x = x or 0, y = y or 0 }, Vector2)
end

function Vector2.__add(left, right)
    return Vector2.new(left.x + right.x, left.y + right.y)
end
function Vector2.__sub(left, right)
    return Vector2.new(left.x - right.x, left.y - right.y)
end

function Vector2.__eq(left, right)
    return getmetatable(left) == Vector2
        and getmetatable(right) == Vector2
        and left.x == right.x
        and left.y == right.y
end

function Vector2.__tostring(vector)
    return string.format("Vector2(%.2f, %.2f)", vector.x, vector.y)
end

return Vector2
