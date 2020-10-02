RatingsCooldown = {}

local RATE_COOLDOWN_MS = 0.5 * 60 * 1000
local cooldowns = {
    -- [playerElement] = getTickCount()
}

function RatingsCooldown.isPlayerInCooldown(player)
    if cooldowns[player] and getTickCount() - cooldowns[player] < RATE_COOLDOWN_MS then
        return true
    end
    return false
end

function RatingsCooldown.getPlayerCooldownSeconds(player)
    if not RatingsCooldown.isPlayerInCooldown(player) then return false end
    return math.ceil((RATE_COOLDOWN_MS * 1000) - (getTickCount() - cooldowns[player]) / 1000)
end

function RatingsCooldown.setPlayerInCooldown(player)
    cooldowns[player] = getTickCount()
end

setTimer(function()
    for player, cooldown in pairs(cooldowns) do
        if not RatingsCooldown.isPlayerInCooldown(player) then
            cooldowns[player] = nil
        end
    end
end, 1 * 60 * 1000, 0)
addEventHandler("onPlayerQuit", root, function() cooldowns[source] = nil end)
