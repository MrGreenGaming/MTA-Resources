Broadcaster = {}

function Broadcaster.broadcastNextMap(nmap)
    -- Next Map
	local mapName = getResourceInfo(nmap, "name") or getResourceName(nmap)
	local rating = AllMapsRatings.getRating(getResourceName(nmap)) or {}

    local mapInfo = {
        name = getResourceInfo(nmap, "name") or getResourceName(nmap),
        resource = getResourceName(nmap),
        likes = rating.likes or 0,
        dislikes = rating.dislikes or 0
    }

	setElementData(root, 'mapratings.nextmap', mapInfo)
end
addEvent('onNextmapSettingChange', true)
addEventHandler('onNextmapSettingChange', root, Broadcaster.broadcastNextMap)

function Broadcaster.broadcastCurrentMap()
	local map = exports.mapmanager:getRunningGamemodeMap()
    if map then
        -- Current Map
		local mapName = getResourceInfo(map, "name") or getResourceName(map)
		local rating = CurrentMapRatings.getRating(true)

        local mapInfo = {
            name = getResourceInfo(map, "name") or getResourceName(map),
            resource = getResourceName(nmap),
            likes = rating.likes or 0,
            dislikes = rating.dislikes or 0
        }
        setElementData(root, 'mapratings.currentmap', mapInfo)
    end

    -- Broadcast player votes
    local rateValues = {
        like = 1,
        dislike = 0
    }

    for _, player in ipairs(getElementsByType("player")) do
        local playerRate = CurrentMapRatings.getByPlayer(player)
        triggerClientEvent(player, "receiveUserMapRate", player, playerRate and rateValues[playerRate] or false)
    end
end
addEvent("onCurrentMapRateChange")
addEventHandler("onCurrentMapRateChange", root, Broadcaster.broadcastCurrentMap)
addEvent("onMapStarting")
addEventHandler("onMapStarting", root, Broadcaster.broadcastCurrentMap)

local function protectElementData(key, old, new)
    if ( key == "mapratings.currentmap" or key == "mapratings.nextmap") and sourceResource ~= getThisResource() then
        outputDebugString("Element data: " .. key .. " changed outside of mapratings. Changing back to original value.", 1)
        setElementData(source, key, old)
    end
end
addEventHandler("onElementDataChange", root, protectElementData)
