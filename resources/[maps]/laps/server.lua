local laps = {}

function mapStarting(mapInfo, mapOptions, gameOptions)
    laps = {}

    local lapList = get(mapInfo.resname..".laps")

    if lapList then
        for item in string.gmatch(lapList, '([^,]+)') do
            local lap = tonumber(item)
            if lap then
                table.insert(laps, lap)
            end
        end

        setElementData(source, "race.totalLaps", #laps + 1, true)

    else
        laps = {}
        setElementData(source, "race.totalLaps", nil, true)
    end

    for i, player in ipairs(getElementsByType("player")) do
        setElementData(player, "race.lap", nil, true)
    end
end
addEvent("onMapStarting")
addEventHandler("onMapStarting", resourceRoot, mapStarting)

addEventHandler("onPlayerReachCheckpoint", root, function(checkpoint, time_)
    if #laps == 0 then return end

    local newLap = findIndex(laps, checkpoint)
    if not newLap then return end

    setElementData(source, "race.lap", newLap + 1, true)
end)

function findIndex(table, element)
    for i, value in ipairs(table) do
        if value == element then
            return i
        end
    end
    return nil
end
