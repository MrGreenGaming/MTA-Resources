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
        local minutes = (hourOfRestart - currentTime.hour) * 60 - currentTime.minute
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
            exports.discord:send("chat.message.text", { author = "Server", text = "SERVER WILL RESTART IN " .. minutes .. " MINUTES!" })
        end
    else
        outputChatBox("SERVER WILL RESTART SHORTLY!", root, 255, 0, 0)
        if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
            exports.discord:send("chat.message.text", { author = "Server", text = "SERVER WILL RESTART SHORTLY!" })
        end
    end
end

function restartServer()
    notifyPlayers()
    setTimer(function()
        shutdown("AUTOMATED SERVER RESTART")
    end, 5000, 1)
end
