local GameState = require("gamestate")
local Input = require("input")
local Events = require("events")
local HighScore = require("highscore")

local gameState
local input
local events
local highScore = 0

local function bindDirection(key, x, y)
    input:bind(key, function()
        gameState:changeDirection(x, y)
    end)
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("smooth")
    love.math.setRandomSeed(os.time())

    highScore = HighScore.load()
    events = Events.new()
    events:subscribe("food_eaten", function(data)
        if data.score > highScore then
            highScore = data.score
            HighScore.save(highScore)
        end
    end)

    gameState = GameState.new(events, function()
        return highScore
    end)

    input = Input.new()
    input:bind("space", function()
        gameState:startOrRestart()
    end)
    input:bind("return", function()
        gameState:startOrRestart()
    end)
    input:bind("r", function()
        gameState:restart()
    end)
    input:bind("m", function()
        gameState:switch("menu")
    end)
    input:bind("escape", function()
        love.event.quit()
    end)

    bindDirection("up", 0, -1)
    bindDirection("w", 0, -1)
    bindDirection("down", 0, 1)
    bindDirection("s", 0, 1)
    bindDirection("left", -1, 0)
    bindDirection("a", -1, 0)
    bindDirection("right", 1, 0)
    bindDirection("d", 1, 0)
end

function love.update(dt)
    gameState:update(dt)
end

function love.draw()
    gameState:draw()
end

function love.keypressed(key, scancode, isrepeat)
    if not isrepeat then
        input:handleKey(key)
    end
end
