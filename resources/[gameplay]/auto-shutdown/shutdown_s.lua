local hourOfRestart
local delayInMinutes = 5

local dayOfServerStart

function load()
    hourOfRestart = tonumber(get("hourOfRestart")) or 3

    local timeOfServerStart = getRealTime()
    dayOfServerStart = timeOfServerStart.yearday

    setTimer(function()
        local currentTime = getRealTime()
        if currentTime.yearday == dayOfServerStart then return end
        local minutes = (hourOfRestart * 60) - (currentTime.hour * 60 + currentTime.minute)
        if minutes > 0 and minutes <= delayInMinutes then
            notifyPlayers(minutes)
        elseif minutes <= 0 and minutes >= -delayInMinutes then
            restartServer()
        end
    end, 60000, 0)
end
addEventHandler("onResourceStart", resourceRoot, load)

function notifyPlayers(minutes)
    if minutes then
        outputChatBox("SERVER WILL RESTART IN " .. minutes .. " MINUTES!", root, 255, 0, 0)
        if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
            exports.discord:send("chat.message.text", { author = "Console", text = "Server will restart in " .. minutes .. " minutes!" })
        end
    else
        outputChatBox("SERVER WILL RESTART SHORTLY!", root, 255, 0, 0)
        if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
            exports.discord:send("chat.message.text", { author = "Console", text = "Server will restart :wave:" })
        end
    end
end

function restartServer()
    notifyPlayers()
    setTimer(function()
        for _, player in ipairs(getElementsByType("player")) do
            triggerEvent('onRequestRedirect', root, player)
        end
     end, 3000, 1)
    setTimer(function()
        shutdown("AUTOMATED SERVER RESTART")
    end, 10000, 1)
end
