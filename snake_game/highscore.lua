local HighScore = {}

local LUA54_SAVE_SOURCE = [=[
    return function(path, score)
        local file <close> = io.open(path, "w")
        if not file then
            return false, "Could not open the high score file for writing"
        end

        local ok, err = file:write(tostring(score), "\n")
        if not ok then
            return false, err
        end
        return true
    end
]=]

local LUA54_READ_SOURCE = [=[
    return function(path)
        local file <close> = io.open(path, "r")
        if not file then
            return nil
        end
        return file:read("*a")
    end
]=]

local function compileLua54(source, chunkName)
    if _VERSION ~= "Lua 5.4" or type(load) ~= "function" then
        return nil
    end

    local environment = { io = io, tostring = tostring }
    local chunk, err = load(source, chunkName, "t", environment)
    if not chunk then
        return nil, err
    end
    return chunk()
end

local saveWithToBeClosed = compileLua54(LUA54_SAVE_SOURCE, "@highscore_save")
local readWithToBeClosed = compileLua54(LUA54_READ_SOURCE, "@highscore_read")

local function getFilePath()
    if love and love.filesystem then
        love.filesystem.createDirectory("data")
        return love.filesystem.getSaveDirectory() .. "/data/highscore.txt"
    end
    return "highscore.txt"
end

local function readWithManualClose(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end

    local ok, content = pcall(file.read, file, "*a")
    pcall(file.close, file)
    if ok then
        return content
    end
    return nil
end

local function saveWithManualClose(path, score)
    local file, openError = io.open(path, "w")
    if not file then
        return false, openError
    end

    local ok, writeResult, writeError = pcall(file.write, file, tostring(score), "\n")
    local closeOk, closeError = pcall(file.close, file)
    if not ok then
        return false, writeResult
    end
    if not writeResult then
        return false, writeError
    end
    if not closeOk then
        return false, closeError
    end
    return true
end

function HighScore.load()
    local path = getFilePath()
    local content
    if readWithToBeClosed then
        local ok, result = pcall(readWithToBeClosed, path)
        if ok then
            content = result
        end
    else
        content = readWithManualClose(path)
    end

    local score = tonumber(content)
    if not score or score < 0 then
        return 0
    end
    return math.floor(score)
end

function HighScore.save(score)
    local safeScore = math.max(0, math.floor(tonumber(score) or 0))
    local path = getFilePath()
    if saveWithToBeClosed then
        local ok, result, err = pcall(saveWithToBeClosed, path, safeScore)
        if ok then
            return result, err
        end
        return false, result
    end
    return saveWithManualClose(path, safeScore)
end

return HighScore
