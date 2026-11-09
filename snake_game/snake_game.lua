local Entity = require("entity")
local Vector2 = require("vector2")

local SnakeGame = {}
SnakeGame.__index = SnakeGame

SnakeGame.GRID = 20
SnakeGame.CELL = 28
SnakeGame.BOARD_X = 34
SnakeGame.BOARD_Y = 106
SnakeGame.BOARD_SIZE = SnakeGame.GRID * SnakeGame.CELL
SnakeGame.STEP_TIME = 0.12

local HEAD_COLOR = { 0.48, 0.94, 0.63, 1 }
local BODY_COLOR = { 0.22, 0.69, 0.45, 1 }
local FOOD_COLOR = { 1.00, 0.38, 0.36, 1 }

local function setColor(color)
    love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
end

local function gridRandom(maximum)
    if love and love.math then
        return love.math.random(1, maximum)
    end
    return math.random(1, maximum)
end

local function createSegment(x, y, isHead)
    local size = isHead and SnakeGame.CELL - 4 or SnakeGame.CELL - 7
    local color = isHead and HEAD_COLOR or BODY_COLOR
    local entity = Entity.new()
    entity:addComponent("position", Entity.position(x, y))
    entity:addComponent("movement", Entity.movement(0, 0))
    entity:addComponent("renderer", Entity.renderer(color, size))
    return entity
end

local function segmentPosition(segment)
    return segment:getComponent("position").value
end

function SnakeGame.new(events)
    local self = setmetatable({ events = events }, SnakeGame)
    self:reset()
    return self
end

function SnakeGame:reset()
    self.snake = {
        createSegment(10, 10, true),
        createSegment(9, 10, false),
        createSegment(8, 10, false),
    }
    self.direction = Vector2.new(1, 0)
    self.nextDirection = Vector2.new(1, 0)
    self.score = 0
    self.gameOver = false
    self.gameOverReason = nil
    self.timer = 0
    self.food = nil
    self:spawnFood()
end

function SnakeGame:finish(reason)
    if self.gameOver then
        return
    end
    self.gameOver = true
    self.gameOverReason = reason
    if self.events then
        self.events:emit("game_over", {
            score = self.score,
            reason = reason,
        })
    end
end

function SnakeGame:spawnFood()
    if #self.snake >= self.GRID * self.GRID then
        self.food = nil
        self:finish("board_full")
        return
    end

    local occupied = {}
    for _, segment in ipairs(self.snake) do
        local position = segmentPosition(segment)
        occupied[position.x .. ":" .. position.y] = true
    end

    local x, y
    repeat
        x = gridRandom(self.GRID)
        y = gridRandom(self.GRID)
    until not occupied[x .. ":" .. y]

    self.food = Entity.new()
    self.food:addComponent("position", Entity.position(x, y))
    self.food:addComponent("renderer", Entity.renderer(FOOD_COLOR, self.CELL - 8))
end

function SnakeGame:changeDirection(dx, dy)
    local candidate = Vector2.new(dx, dy)
    if math.abs(candidate.x) + math.abs(candidate.y) ~= 1 then
        return false
    end
    if candidate.x == -self.direction.x and candidate.y == -self.direction.y then
        return false
    end

    self.nextDirection = candidate
    return true
end

function SnakeGame:update(dt)
    if self.gameOver then
        return
    end

    self.timer = self.timer + dt
    while self.timer >= self.STEP_TIME and not self.gameOver do
        self.timer = self.timer - self.STEP_TIME
        self:moveSnake()
    end
end

function SnakeGame:moveSnake()
    self.direction = self.nextDirection
    local head = segmentPosition(self.snake[1])
    local newHeadPosition = head + self.direction
    local foodPosition = self.food and segmentPosition(self.food) or nil
    local willEat = foodPosition ~= nil and newHeadPosition == foodPosition

    if newHeadPosition.x < 1 or newHeadPosition.x > self.GRID
        or newHeadPosition.y < 1 or newHeadPosition.y > self.GRID then
        self:finish("wall")
        return
    end

    -- The tail moves away on a normal step, so moving into that cell is safe.
    for index, segment in ipairs(self.snake) do
        local isVacatingTail = index == #self.snake and not willEat
        if not isVacatingTail and segmentPosition(segment) == newHeadPosition then
            self:finish("self")
            return
        end
    end

    local newHead = createSegment(newHeadPosition.x, newHeadPosition.y, true)
    newHead:getComponent("movement").direction = self.direction
    table.insert(self.snake, 1, newHead)

    if willEat then
        self.score = self.score + 1
        if self.events then
            self.events:emit("food_eaten", { score = self.score })
        end
        self:spawnFood()
    else
        table.remove(self.snake)
    end

    for index = 2, #self.snake do
        local movement = self.snake[index]:getComponent("movement")
        local current = segmentPosition(self.snake[index])
        local following = segmentPosition(self.snake[index - 1])
        movement.direction = following - current
    end
end

function SnakeGame:draw()
    local x = self.BOARD_X
    local y = self.BOARD_Y
    local size = self.BOARD_SIZE

    love.graphics.setColor(0.08, 0.13, 0.19, 1)
    love.graphics.rectangle("fill", x, y, size, size, 14, 14)

    love.graphics.setColor(0.15, 0.22, 0.29, 0.65)
    for index = 1, self.GRID - 1 do
        local offset = index * self.CELL
        love.graphics.line(x + offset, y, x + offset, y + size)
        love.graphics.line(x, y + offset, x + size, y + offset)
    end

    if self.food then
        local position = segmentPosition(self.food)
        local renderer = self.food:getComponent("renderer")
        local centerX = x + (position.x - 0.5) * self.CELL
        local centerY = y + (position.y - 0.5) * self.CELL
        setColor(renderer.color)
        love.graphics.circle("fill", centerX, centerY, renderer.size / 2)
        love.graphics.setColor(1, 0.78, 0.73, 0.8)
        love.graphics.circle("fill", centerX - 3, centerY - 3, 2)
    end

    for index, segment in ipairs(self.snake) do
        local position = segmentPosition(segment)
        local renderer = segment:getComponent("renderer")
        local inset = (self.CELL - renderer.size) / 2
        local left = x + (position.x - 1) * self.CELL + inset
        local top = y + (position.y - 1) * self.CELL + inset
        setColor(renderer.color)
        love.graphics.rectangle("fill", left, top, renderer.size, renderer.size, 7, 7)

        if index == 1 then
            self:drawEyes(left, top, renderer.size)
        end
    end
end

function SnakeGame:drawEyes(x, y, size)
    local centerX = x + size / 2
    local centerY = y + size / 2
    local direction = self.direction
    local forward = size * 0.22
    local side = size * 0.17
    local eyeRadius = 1.8

    love.graphics.setColor(0.05, 0.17, 0.13, 1)
    for _, sign in ipairs({ -1, 1 }) do
        local eyeX = centerX + direction.x * forward - direction.y * side * sign
        local eyeY = centerY + direction.y * forward + direction.x * side * sign
        love.graphics.circle("fill", eyeX, eyeY, eyeRadius)
    end
end

return SnakeGame
