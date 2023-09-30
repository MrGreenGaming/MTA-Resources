local laps = {}

local lapTimes = {}
local prevLapTimes = {}

local currentMapRes

function mapStarting(mapInfo, mapOptions, gameOptions)
    laps = {}
    lapTimes = {}
    prevLapTimes = {}

    currentMapRes = mapInfo.resname

    local lapList = get(currentMapRes .. ".laps")

    if lapList then
        for item in string.gmatch(lapList, '([^,]+)') do
            local lap = tonumber(item)
            if lap then
                table.insert(laps, lap)
            end
        end

        for i, player in ipairs(getElementsByType("player")) do
            setElementData(player, "race.totalLaps", #laps + 1, true)
        end
    else
        for i, player in ipairs(getElementsByType("player")) do
            setElementData(player, "race.totalLaps", nil, true)
        end
    end

    for i, player in ipairs(getElementsByType("player")) do
        setElementData(player, "race.lap", nil, true)
        setElementData(player, "race.bestlap", nil, true)
    end
end

addEvent("onMapStarting")
addEventHandler("onMapStarting", resourceRoot, mapStarting)

addEventHandler("onPlayerJoin", root, function()
    if #laps > 0 then
        setElementData(source, "race.totalLaps", #laps + 1, true)
    end
end)

addEventHandler("onPlayerReachCheckpoint", root, function(checkpoint, time_)
    if #laps == 0 then return end

    local newLap = findIndex(laps, checkpoint)
    if not newLap then return end

    setElementData(source, "race.lap", newLap + 1, true)

    if lapTimes[source] then
        local lapTime = time_ - prevLapTimes[source]
        prevLapTimes[source] = lapTime
        if lapTime < lapTimes[source] then
            lapTimes[source] = lapTime
        end
    else
        lapTimes[source] = time_
        prevLapTimes[source] = time_
    end
    setElementData(source, "race.bestlap", lapTimes[source], true)
end)

addEventHandler("onPlayerFinish", root, function(rank, time_)
    if lapTimes[source] then
        local lapTime = time_ - lapTimes[source]
        if lapTime < lapTimes[source] then
            lapTimes[source] = lapTime
        end
    else
        lapTimes[source] = time_
    end
    setElementData(source, "race.bestlap", lapTimes[source], true)
end)

function addLapsToMap(playerSource, _, ...)
    if not ... then return outputChatBox("Incorrect usage, use '/addlaps 5 9 11' to mark checkpoint 5,9 and 11 as lap checkpoints", playerSource, 255, 0,0) end
    local args = { ... }

    local cps = {}
    for i, cp in ipairs(args) do
        if tonumber(cp) then
            table.insert(cps, tonumber(cp))
        end
    end

    if not cps then return outputChatBox("Incorrect usage, use '/addlaps 5 9 11' to mark checkpoint 5,9 and 11 as lap checkpoints", playerSource, 255, 0,0) end

    laps = cps

    for i, player in ipairs(getElementsByType("player")) do
        setElementData(player, "race.totalLaps", #cps + 1, true)
        setElementData(player, "race.lap", "?", true)
    end

    local metaXml = xmlLoadFile(":" .. currentMapRes .. "/meta.xml")
    if metaXml then
        local settingsNode = xmlFindChild(metaXml, "settings", 0)
        if not settingsNode then
            settingsNode = xmlCreateChild(metaXml, "settings")
        end

        -- Remove any existing 'laps' nodes
        local existingLapsNodes = xmlNodeGetChildren(settingsNode)
        for _, node in ipairs(existingLapsNodes) do
            if xmlNodeGetAttribute(node, "name") == "#laps" then
                xmlDestroyNode(node)
            end
        end

        local lapNode = xmlCreateChild(settingsNode, "setting")
        xmlNodeSetAttribute(lapNode, "name", "#laps")
        xmlNodeSetAttribute(lapNode, "value", table.concat(laps, ","))

        -- Save the updated meta.xml
        xmlSaveFile(metaXml)
        xmlUnloadFile(metaXml)
    end

    outputChatBox("Updated and saved new laps to " .. currentMapRes, playerSource, 0, 255, 0)
end
addCommandHandler("addlaps", addLapsToMap, true, false)


function findIndex(table, element)
    for i, value in ipairs(table) do
        if value == element then
            return i
        end
    end
    return nil
end
