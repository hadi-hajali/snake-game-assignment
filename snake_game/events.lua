local Events = {}
Events.__index = Events

function Events.new()
    return setmetatable({ listeners = {} }, Events)
end

function Events:subscribe(eventName, callback)
    assert(type(eventName) == "string", "event name must be a string")
    assert(type(callback) == "function", "event callback must be a function")

    local listeners = self.listeners[eventName]
    if not listeners then
        listeners = {}
        self.listeners[eventName] = listeners
    end

    local entry = { callback = callback, active = true }
    table.insert(listeners, entry)

    return function()
        entry.active = false
    end
end

function Events:emit(eventName, data)
    local listeners = self.listeners[eventName]
    if not listeners then
        return
    end

    -- Use a snapshot so subscriptions can safely change while an event is handled.
    local snapshot = {}
    for index, entry in ipairs(listeners) do
        snapshot[index] = entry
    end

    for _, entry in ipairs(snapshot) do
        if entry.active then
            entry.callback(data)
        end
    end

    local remaining = {}
    for _, entry in ipairs(listeners) do
        if entry.active then
            table.insert(remaining, entry)
        end
    end
    self.listeners[eventName] = remaining
end

return Events
