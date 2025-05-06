-- { [player]: timer}
local afkTimers = {}


-- EVENTS --

local function start()
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "player state") == "away" then
            StartAfkTimer(player)
        end
    end
end
addEventHandler("onResourceStart", resourceRoot, start)

local function playerQuit()
    StopAfkTimer(source)
end
addEventHandler("onPlayerQuit", root, playerQuit)

local function stateChange(theKey, oldValue, newValue)
    if getElementType(source) == "player" and theKey == "player state" then
        if newValue == "away" and oldValue ~= "away" then
            StartAfkTimer(source)
        elseif newValue ~= "away" then
            StopAfkTimer(source)
        end
    end
end
addEventHandler("onElementDataChange", root, stateChange)

-- FUNCTIONS --

function StartAfkTimer(player)
    if (isElement(player) and getElementType(player) == "player") then
        local afkTime = get("anti.afkTimeBeforeKick") or 120
        if (not afkTimers[player]) then
            afkTimers[player] = setTimer(function()
                kickPlayer(player, "FastFurKick", "AFK? We race, not nap!")
            end, afkTime * 60 * 1000, 1)
        end
    end
end

function StopAfkTimer(player)
    if (isElement(player) and getElementType(player) == "player") then
        if (afkTimers[player] and isTimer(afkTimers[player])) then
            killTimer(afkTimers[player])
            afkTimers[player] = nil
        end
    end
end
