local SnakeGame = require("snake_game")

local PlayingState = {}
PlayingState.__index = PlayingState

local COLORS = {
    background = { 0.035, 0.065, 0.10, 1 },
    text = { 0.91, 0.96, 0.94, 1 },
    muted = { 0.55, 0.67, 0.71, 1 },
    panel = { 0.075, 0.12, 0.17, 1 },
    accent = { 0.31, 0.78, 0.55, 1 },
}

local function setColor(color)
    love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
end

function PlayingState.new(events, highScoreProvider)
    return setmetatable({
        game = SnakeGame.new(events),
        highScoreProvider = highScoreProvider or function() return 0 end,
        titleFont = love.graphics.newFont(24),
        bodyFont = love.graphics.newFont(16),
        smallFont = love.graphics.newFont(13),
        scoreFont = love.graphics.newFont(34),
    }, PlayingState)
end

function PlayingState:enter()
    self:restart()
end

function PlayingState:restart()
    self.game:reset()
end

function PlayingState:update(dt)
    self.game:update(dt)
end

function PlayingState:drawPanel(x, y, width, height)
    setColor(COLORS.panel)
    love.graphics.rectangle("fill", x, y, width, height, 14, 14)
    love.graphics.setColor(0.17, 0.27, 0.33, 1)
    love.graphics.rectangle("line", x, y, width, height, 14, 14)
end

function PlayingState:draw()
    love.graphics.clear(
        COLORS.background[1],
        COLORS.background[2],
        COLORS.background[3],
        COLORS.background[4]
    )
    local boardX = SnakeGame.BOARD_X
    local boardY = SnakeGame.BOARD_Y
    local boardSize = SnakeGame.BOARD_SIZE
    local sideX = boardX + boardSize + 30
    local sideWidth = 322

    love.graphics.setFont(self.titleFont)
    setColor(COLORS.text)
    love.graphics.print("SNAKE", boardX, 35)

    love.graphics.setFont(self.smallFont)
    setColor(COLORS.muted)
    love.graphics.printf("CLASSIC ARCADE  /  LUA + LÖVE", boardX + 124, 43, 430, "left")

    self.game:draw()

    self:drawPanel(sideX, boardY, sideWidth, 158)
    love.graphics.setFont(self.smallFont)
    setColor(COLORS.muted)
    love.graphics.print("CURRENT SCORE", sideX + 22, boardY + 20)
    love.graphics.setFont(self.scoreFont)
    setColor(COLORS.text)
    love.graphics.print(tostring(self.game.score), sideX + 20, boardY + 43)
    love.graphics.setFont(self.smallFont)
    setColor(COLORS.muted)
    love.graphics.print("BEST", sideX + 22, boardY + 108)
    setColor(COLORS.accent)
    love.graphics.print(tostring(self.highScoreProvider()), sideX + 77, boardY + 108)

    self:drawPanel(sideX, boardY + 176, sideWidth, 203)
    love.graphics.setFont(self.bodyFont)
    setColor(COLORS.text)
    love.graphics.print("HOW TO PLAY", sideX + 22, boardY + 198)
    love.graphics.setFont(self.smallFont)
    setColor(COLORS.muted)
    love.graphics.print("ARROWS / WASD", sideX + 22, boardY + 239)
    love.graphics.printf("Turn the snake", sideX + 22, boardY + 259, sideWidth - 44, "left")
    love.graphics.print("SPACE", sideX + 22, boardY + 300)
    love.graphics.printf("Start or restart", sideX + 22, boardY + 320, sideWidth - 44, "left")
    love.graphics.print("M", sideX + 22, boardY + 352)
    love.graphics.printf("Return to menu", sideX + 48, boardY + 352, sideWidth - 70, "left")

    self:drawPanel(sideX, boardY + 397, sideWidth, 166)
    love.graphics.setFont(self.bodyFont)
    setColor(COLORS.text)
    love.graphics.print("GAME STATUS", sideX + 22, boardY + 419)
    love.graphics.setFont(self.smallFont)
    setColor(COLORS.muted)
    if self.game.gameOver then
        love.graphics.setColor(1.00, 0.55, 0.48, 1)
        love.graphics.print(self.game.gameOverReason == "board_full" and "BOARD CLEARED" or "GAME OVER", sideX + 22, boardY + 459)
        setColor(COLORS.muted)
        love.graphics.printf("Press SPACE to play again", sideX + 22, boardY + 484, sideWidth - 44, "left")
    else
        setColor(COLORS.accent)
        love.graphics.print("RUNNING", sideX + 22, boardY + 459)
        setColor(COLORS.muted)
        love.graphics.printf("Collect fruit and grow longer", sideX + 22, boardY + 484, sideWidth - 44, "left")
    end
    love.graphics.printf("M  MENU     ESC  QUIT", sideX + 22, boardY + 528, sideWidth - 44, "left")

    if self.game.gameOver then
        love.graphics.setColor(0.025, 0.045, 0.07, 0.76)
        love.graphics.rectangle("fill", boardX, boardY, boardSize, boardSize, 14, 14)
        love.graphics.setFont(self.titleFont)
        setColor(COLORS.text)
        love.graphics.printf(self.game.gameOverReason == "board_full" and "BOARD CLEARED" or "GAME OVER", boardX + 24, boardY + boardSize / 2 - 48, boardSize - 48, "center")
        love.graphics.setFont(self.bodyFont)
        love.graphics.setColor(0.72, 0.83, 0.83, 1)
        love.graphics.printf("Score: " .. tostring(self.game.score) .. "   •   SPACE to restart", boardX + 24, boardY + boardSize / 2 + 5, boardSize - 48, "center")
    end
end

return PlayingState
