Broadcaster = {}

function Broadcaster.broadcastCurrentMapInfo(map)
    local resName = map.resname
    local mapRes = getResourceFromName(resName)

    local mapInfo = {
        name = getResourceInfo(mapRes, "name"),
        resourceName = resName,
        timesPlayed = 0,
        author = getResourceInfo(mapRes, "author") or "",
        description = getResourceInfo(mapRes, "description") or "",
        lastTimePlayed = false,
        uploadDate = getResourceInfo(mapRes, "uploadtick") or ""
    }

    -- This should be async!!!
    local mapQuery = executeSQLQuery("SELECT infoName, playedCount, resName, lastTimePlayed FROM race_mapmanager_maps WHERE lower(resName) = ?", string.lower(resName))

    if #mapQuery >= 1 then
        mapInfo.timesPlayed = mapQuery[1].playedCount or 0
        mapInfo.lastTimePlayed = mapQuery[1].lastTimePlayed or false
    end

    setElementData(root, "map_window.currentMapInfo", mapInfo)
end
addEvent("onMapStarting")
addEventHandler("onMapStarting", root, Broadcaster.broadcastCurrentMapInfo)

function Broadcaster.clearCurrentMapInfo()
    removeElementData(root, "map_window.currentMapInfo")
end
addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", root, function(state) if state == "NoMap" then Broadcaster.clearCurrentMapInfo() end end)

local function protectElementData(key, old, new)
    if key == "map_window.currentMapInfo" and sourceResource ~= getThisResource() then
        outputDebugString("Element data: " .. key .. " changed outside of map_window. Changing back to original value.", 1)
        setElementData(source, key, old)
    end
end
addEventHandler("onElementDataChange", root, protectElementData)
