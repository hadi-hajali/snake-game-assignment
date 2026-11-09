local MenuState = {}
MenuState.__index = MenuState

function MenuState.new(gameState, highScoreProvider)
    return setmetatable({
        gameState = gameState,
        highScoreProvider = highScoreProvider or function() return 0 end,
        titleFont = love.graphics.newFont(72),
        subtitleFont = love.graphics.newFont(18),
        bodyFont = love.graphics.newFont(16),
        smallFont = love.graphics.newFont(13),
    }, MenuState)
end

function MenuState:update(_dt)
end

function MenuState:draw()
    local width, height = love.graphics.getDimensions()
    love.graphics.clear(0.035, 0.065, 0.10, 1)

    love.graphics.setColor(0.12, 0.20, 0.27, 0.42)
    for index = 1, 8 do
        local circleX = (index * 137) % width
        local circleY = (index * 89) % height
        love.graphics.circle("fill", circleX, circleY, 8 + (index % 3) * 4)
    end

    local cardWidth = 620
    local cardHeight = 470
    local cardX = (width - cardWidth) / 2
    local cardY = (height - cardHeight) / 2

    love.graphics.setColor(0.075, 0.12, 0.17, 0.96)
    love.graphics.rectangle("fill", cardX, cardY, cardWidth, cardHeight, 22, 22)
    love.graphics.setColor(0.18, 0.29, 0.35, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", cardX, cardY, cardWidth, cardHeight, 22, 22)

    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.47, 0.83, 0.67, 1)
    love.graphics.printf("LUA GAME PROGRAMMING", cardX, cardY + 37, cardWidth, "center")

    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(0.91, 0.97, 0.94, 1)
    love.graphics.printf("SNAKE", cardX, cardY + 74, cardWidth, "center")

    love.graphics.setFont(self.subtitleFont)
    love.graphics.setColor(0.66, 0.76, 0.79, 1)
    love.graphics.printf("A clean, classic arcade game built with Lua and LÖVE", cardX + 28, cardY + 167, cardWidth - 56, "center")

    local buttonX = cardX + 178
    local buttonY = cardY + 228
    local buttonWidth = cardWidth - 356
    love.graphics.setColor(0.27, 0.72, 0.50, 1)
    love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, 55, 12, 12)
    love.graphics.setFont(self.bodyFont)
    love.graphics.setColor(0.035, 0.10, 0.08, 1)
    love.graphics.printf("PRESS SPACE TO PLAY", buttonX, buttonY + 18, buttonWidth, "center")

    love.graphics.setFont(self.bodyFont)
    love.graphics.setColor(0.86, 0.91, 0.91, 1)
    love.graphics.printf("Best score   " .. tostring(self.highScoreProvider()), cardX, cardY + 318, cardWidth, "center")

    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.53, 0.66, 0.70, 1)
    love.graphics.printf("Move with ARROW KEYS or WASD   |   ESC to quit", cardX + 25, cardY + 374, cardWidth - 50, "center")
    love.graphics.printf("Eat the red fruit. Avoid the walls and your own tail.", cardX + 25, cardY + 402, cardWidth - 50, "center")
end

return MenuState
