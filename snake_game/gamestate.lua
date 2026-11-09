local MenuState = require("states.menu_state")
local PlayingState = require("states.game_state")

local GameState = {}
GameState.__index = GameState

function GameState.new(events, highScoreProvider)
    local self = setmetatable({
        current = "menu",
        states = {},
    }, GameState)

    self.states.menu = MenuState.new(self, highScoreProvider)
    self.states.playing = PlayingState.new(events, highScoreProvider)
    return self
end

function GameState:switch(newState)
    assert(self.states[newState], "Unknown game state: " .. tostring(newState))
    if self.current == newState then
        return
    end

    local oldState = self.states[self.current]
    if oldState and oldState.exit then
        oldState:exit()
    end

    self.current = newState
    local activeState = self.states[self.current]
    if activeState.enter then
        activeState:enter()
    end
end

function GameState:startOrRestart()
    if self.current == "menu" then
        self:switch("playing")
        return
    end

    local playing = self.states.playing
    if playing.game.gameOver then
        playing:restart()
    end
end

function GameState:restart()
    if self.current ~= "playing" then
        self:switch("playing")
    else
        self.states.playing:restart()
    end
end

function GameState:changeDirection(dx, dy)
    if self.current == "playing" then
        self.states.playing.game:changeDirection(dx, dy)
    end
end

function GameState:update(dt)
    self.states[self.current]:update(dt)
end

function GameState:draw()
    self.states[self.current]:draw()
end

return GameState
