local minimumFreeSlots = 5 -- minimum amount of slots that will seem available, if less slots than this are available, the limit will be incremented ( eg if 5 then 36/40 -> 36/50)
local increments = 10 -- multiplier for server slots (eg if 10 then /10 /20 /30 /40 ...)
local minimumSlots = 20 -- dont go lower than this (eg if 20 then 4/10 -> 4/20)

addEventHandler('onPlayerJoin', root, function()
    local newLimit = math.min(getServerConfigSetting("maxplayers"), math.max(minimumSlots, math.ceil((getPlayerCount() + minimumFreeSlots) / increments) * increments))
    if getMaxPlayers() ~= newLimit then
        setMaxPlayers(newLimit)
        outputDebugString('New slots limit ' .. newLimit)
    end
end)