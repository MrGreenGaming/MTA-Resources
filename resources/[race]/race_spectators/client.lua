local showSpectators = true
local screenFadedOut = false
local spectators = {}
local currentWatchedTarget = false

local screenW, screenH = guiGetScreenSize()
local posX = screenW - 10
local posY = 160
local font = "default-bold"
local scale = 1.0
local lineHeight = dxGetFontHeight(scale, font) + 2

local function isRaceRunning()
    local raceRes = getResourceFromName("race")
    return raceRes and getResourceState(raceRes) == "running"
end

local function getCurrentTarget()
    if not isRaceRunning() then
        return localPlayer
    end

    if getElementData(localPlayer, "race.spectating") then
        local watched = exports.race:getWatchedPlayer()
        if isElement(watched) and watched ~= localPlayer then
            return watched
        end
        return false
    end

    return localPlayer
end

local function rebuildSpectatorList()
    spectators = {}
    local target = getCurrentTarget()
    if not isElement(target) then
        return
    end

    for _, player in ipairs(getElementsByType("player")) do
        if player ~= target and getElementData(player, "race.spectating") and getElementData(player, "race.spectatingTarget") == target then
            local r, g, b = 255, 255, 255
            local team = getPlayerTeam(player)
            local rawName = getPlayerName(player)
            local cleanName = rawName:gsub("#%x%x%x%x%x%x", "")
            local name = getElementData(player, "vip.colorNick") or rawName
            if team then
                r, g, b = getTeamColor(team)
                if not getElementData(team, "gcshop.teamid") then
                    name = getElementData(player, "vip.colorNick") or cleanName
                end
            end
            local isAway = getElementData(player, "player state") == "away" or getElementData(player, "state") == "away"
            if isAway then
                name = name .. " #AAAAAA(AFK)"
                cleanName = cleanName .. " (AFK)"
            end
            table.insert(spectators, {
                name = name,
                cleanName = cleanName,
                color = tocolor(r, g, b, 255)
            })
        end
    end
end

local function syncLocalSpectateTarget()
    local myTarget = false
    if isRaceRunning() and getElementData(localPlayer, "race.spectating") then
        local watched = exports.race:getWatchedPlayer()
        if isElement(watched) and watched ~= localPlayer then
            myTarget = watched
        end
    end

    if getElementData(localPlayer, "race.spectatingTarget") ~= myTarget then
        setElementData(localPlayer, "race.spectatingTarget", myTarget)
    end

    currentWatchedTarget = getCurrentTarget()
    rebuildSpectatorList()
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(syncLocalSpectateTarget, 250, 0)
    syncLocalSpectateTarget()
    rebuildSpectatorList()
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if getElementData(localPlayer, "race.spectatingTarget") then
        setElementData(localPlayer, "race.spectatingTarget", false)
    end
end)

addEventHandler("onClientElementDataChange", root, function(dataName)
    if getElementType(source) == "player" and (dataName == "race.spectatingTarget" or dataName == "race.spectating" or dataName == "vip.colorNick" or dataName == "player state" or dataName == "state") then
        rebuildSpectatorList()
    end
end)

addEventHandler("onClientPlayerJoin", root, rebuildSpectatorList)
addEventHandler("onClientPlayerQuit", root, rebuildSpectatorList)
addEventHandler("onClientPlayerChangeNick", root, function()
    setTimer(rebuildSpectatorList, 50, 1)
end)

addEvent("onClientScreenFadedOut", true)
addEventHandler("onClientScreenFadedOut", root, function()
    screenFadedOut = true
end)

addEvent("onClientScreenFadedIn", true)
addEventHandler("onClientScreenFadedIn", root, function()
    screenFadedOut = false
end)

addEventHandler("onClientRender", root, function()
    if not showSpectators or screenFadedOut or #spectators == 0 then
        return
    end

    local headerText = string.format("Spectators (%d)", #spectators)
    dxDrawText(headerText, 0, posY + 1, posX + 1, posY + lineHeight + 1, tocolor(0, 0, 0, 200), scale, font, "right", "top", false, false, false, false)
    dxDrawText(headerText, 0, posY, posX, posY + lineHeight, tocolor(255, 255, 255, 255), scale, font, "right", "top", false, false, false, false)

    for i, spec in ipairs(spectators) do
        local y = posY + (i * lineHeight)
        dxDrawText(spec.cleanName, 0, y + 1, posX + 1, y + lineHeight + 1, tocolor(0, 0, 0, 200), scale, font, "right", "top", false, false, false, false)
        dxDrawText(spec.name, 0, y, posX, y + lineHeight, spec.color, scale, font, "right", "top", false, false, false, true)
    end
end)

function showSpectatorList()
    showSpectators = true
end

function hideSpectatorList()
    showSpectators = false
end

