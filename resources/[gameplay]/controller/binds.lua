local registeredEvents = {}

-- key = cross, square, circle etc.
-- onPressed = Event to trigger when the key is pressed
-- onReleased = Event to trigger when the key is released
function bindControllerKey(key, onPressed, onReleased, ...)
    local name = getHandlerName(sourceResource, key, onPressed, onReleased)
    local args = {...}

    if not getKey(key) then
        return error("No such key: " .. key, 2)
    end
    if not onPressed and not onReleased then
        return error("No event handler function specified", 2)
    end
    if registeredEvents[name] then
        return error("Event handler function already exists: " .. name, 2)
    end

    if (not registeredEvents[name]) then
        registeredEvents[name] = function(actualKey, actualPressed)
            if actualKey == getKey(key) then
                if actualPressed then
                    if (not onPressed) then
                        return
                    end
                    triggerEvent(onPressed, root, key, unpack(args))
                else
                    if (not onReleased) then
                        return
                    end
                    triggerEvent(onReleased, root, key, unpack(args))
                end
            end
        end
    end
    addEventHandler("onClientKey", root, registeredEvents[name])

end

-- key = cross, square, circle etc.
-- onPressed = Event to trigger when the key is pressed
-- onReleased = Event to trigger when the key is released
function unbindControllerKey(key, onPressed, onReleased)
    local name = getHandlerName(sourceResource, key, onPressed, onReleased)
    if (not registeredEvents[name]) then
        return
    end
    removeEventHandler("onClientKey", root, registeredEvents[name])
    registeredEvents[name] = nil
end

-- generates a unique name for the event handler function based on the resource name, key, onPressed and onReleased
function getHandlerName(sourceResource, key, onPressed, onReleased)
    return tostring((sourceResource and getResourceName(sourceResource)) or getResourceName(getThisResource())) .. "_" .. tostring(key) .. tostring(onPressed) .. tostring(onReleased)
end


-- Removes all event handlers for the resource that stopped (if any), so the resource doesn't have to clean up the binds.
function resourceStop(resource)
    for name, handler in pairs(registeredEvents) do
        if string.find(name, getResourceName(resource) .. "_") then
            removeEventHandler("onClientKey", root, handler)
            registeredEvents[name] = nil
        end
    end
end
addEventHandler("onClientResourceStop", root, resourceStop)
