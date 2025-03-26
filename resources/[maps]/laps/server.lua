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
        setElementData(player, "race.lap.text", "1/"..#laps + 1, true)
    end
    exports.scoreboard:scoreboardAddColumn("race.lap.text", root, 78, "Lap", 6)
end

addEvent("onMapStarting")
addEventHandler("onMapStarting", resourceRoot, mapStarting)

addEventHandler("onPlayerJoin", root, function()
    if #laps > 0 then
        setElementData(source, "race.totalLaps", #laps + 1, true)
        setElementData(source, "race.lap.text", "1/"..#laps + 1, true)
    end
end)

addEventHandler("onPlayerReachCheckpoint", root, function(checkpoint, time_)
    if #laps == 0 then return end

    local newLap = findIndex(laps, checkpoint)
    if not newLap then return end

    setElementData(source, "race.lap", newLap + 1, true)
    setElementData(source, "race.lap.text", newLap + 1 .."/"..#laps + 1, true)

    updateLapTime(time_, source, newLap)
end)

addEventHandler("onPlayerFinish", root, function(rank, time_)
    updateLapTime(time_, source, #laps + 1)
end)

addEventHandler("onPostFinish", root, function()
    if #laps == 0 then return end
    local bestPlayer = nil
    local bestTime = nil

    for player, time_ in pairs(lapTimes) do
        if not bestTime or time_ < bestTime then
            bestPlayer = player
            bestTime = time_
        end
    end

    if not bestPlayer then return end

	local minutes, seconds, milliseconds = msToTime(bestTime)
	local text = minutes .. ':' .. seconds .. '.' .. milliseconds

    if isElement(bestPlayer) then
        outputChatBox(getFullPlayerName(bestPlayer) .. "#bababa had the best lap time: #00ff00" .. text.. "#bababa!", root, 255, 255, 255, true)
    else
        outputChatBox("#bababaThe player with the best time left... They had: #00ff00" .. text .. "#bababa!", root, 255, 255, 255, true)
    end
end)

function updateLapTime(time_, player, lap)
    if prevLapTimes[player] and lap <= prevLapTimes[player].lap then return end

    if lapTimes[player] then
        local lapTime = time_ - prevLapTimes[player].time
        if lapTime < lapTimes[player] then
            lapTimes[player] = lapTime
            setElementData(source, "race.bestlap", lapTimes[player], true)
        end
    else
        lapTimes[player] = time_
        setElementData(source, "race.bestlap", lapTimes[player], true)
    end
    prevLapTimes[player] = {
        time = time_,
        lap = lap
    }
end

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

function getFullPlayerName(player)
    local playerName = getElementData( player, "vip.colorNick" ) or getPlayerName( player )
    local teamColor = "#FFFFFF"
    local team = getPlayerTeam(player)
    if (team) then
        r,g,b = getTeamColor(team)
        teamColor = string.format("#%.2X%.2X%.2X", r, g, b)
    end
    return "" .. teamColor .. playerName
end

function msToTime(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	if #minutes == 1 then
		minutes = '0' .. minutes
	end
	return minutes, seconds, centiseconds
end

function upsertTagsToMap(playerSource, _, ...)
    if not ... then 
        return outputChatBox("Incorrect usage, use '/maptag tag1 tag2 tag3' to set the tags", playerSource, 255, 0, 0)
    end
    
    local tags = table.concat({...}, ", ")

    -- Load the meta.xml file
    local metaXml = xmlLoadFile(":" .. currentMapRes .. "/meta.xml")
    if metaXml then
        -- Find the info node
        local infoNode = xmlFindChild(metaXml, "info", 0)
        -- Set or update the 'tags' attribute
        xmlNodeSetAttribute(infoNode, "tags", tags)

        -- Save the updated meta.xml
        xmlSaveFile(metaXml)
        xmlUnloadFile(metaXml)

        outputChatBox("Tags '".. tags .. "' saved to " .. currentMapRes, playerSource, 0, 255, 0)
        outputChatBox("Tags will start showing on 'server restart' or 'map replay' due to technical limitations.", playerSource, 255, 100, 0)
    else
        outputChatBox("Error: Unable to load meta.xml.", playerSource, 255, 0, 0)
    end
end
addCommandHandler("maptag", upsertTagsToMap, true, false)
addCommandHandler("maptags", upsertTagsToMap, true, false)

function toggleClassicVehicleSetting(playerSource)
    local metaXml = xmlLoadFile(":" .. currentMapRes .. "/meta.xml")
    if metaXml then
        local settingsNode = xmlFindChild(metaXml, "settings", 0)
        if not settingsNode then
            settingsNode = xmlCreateChild(metaXml, "settings")
        end

        local settingNode
        local existingSettings = xmlNodeGetChildren(settingsNode)
        for _, node in ipairs(existingSettings) do
            if xmlNodeGetAttribute(node, "name") == "#classicchangez" then
                settingNode = node
                break
            end
        end

        if settingNode then
            -- Toggle the boolean value
            local currentValue = xmlNodeGetAttribute(settingNode, "value")
            local newValue = (currentValue == "true") and "false" or "true"
            xmlNodeSetAttribute(settingNode, "value", newValue)
            outputChatBox("Toggled '#classicchangez' setting to: " .. newValue .." for " .. currentMapRes .. ". Starts working next time map is started.", playerSource, 0, 255, 0)
        else
            -- Create the setting if it doesn't exist
            settingNode = xmlCreateChild(settingsNode, "setting")
            xmlNodeSetAttribute(settingNode, "name", "#classicchangez")
            xmlNodeSetAttribute(settingNode, "value", "true")
            outputChatBox("Created '#classicchangez' setting with value: true for " .. currentMapRes .. ". Starts working next time map is started.", playerSource, 0, 255, 0)
        end

        -- Save the updated meta.xml
        xmlSaveFile(metaXml)
        xmlUnloadFile(metaXml)
    else
        outputChatBox("Error: Unable to load meta.xml.", playerSource, 255, 0, 0)
    end
end
addCommandHandler("classicVehicleChange", toggleClassicVehicleSetting, true, false)
addCommandHandler("cvc", toggleClassicVehicleSetting, true, false)