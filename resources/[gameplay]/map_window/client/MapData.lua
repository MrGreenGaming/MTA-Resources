MapData = {}

MapData.nextMapRatings = {
    name = "",
    likes = 0,
    dislikes = 0
}

MapData.currentMapRatings = {
    name = "",
    likes = 0,
    dislikes = 0,
    description = ""
}

MapData.currentMapUserRate = false -- false OR 0 OR 1

MapData.currentMapInfo = {
    name = "",
    resourceName = "",
    timesPlayed = 0,
    author = "",
    description = "",
    lastTimePlayed = false,
}

MapData.mapRoundsInfo = {
    current = 1,
    maximum = 3
}


local function changeNextMapRatings(data)
    iprint("mapratings.nextmap", data)
    if data and table.keysExists(data, "name", "likes", "dislikes", "description") then
        MapData.currentMapRatings = data
    else
        MapData.nextMapRatings = {
            name = "",
            likes = 0,
            dislikes = 0
        }
    end
end

local function changeCurrentMapRatings(data)
    iprint("mapratings.currentmap", data)
    if data and table.keysExists(data, "name", "likes", "dislikes", "description") then
        MapData.currentMapRatings = data
    else
        MapData.currentMapRatings = {
            name = "",
            likes = 0,
            dislikes = 0,
            description = ""
        }
    end
end

local function changeCurrentMapInfo(data)
    iprint("map_window.currentMapInfo", data)
    if data and table.keysExists(data, "name", "resourceName", "timesPlayed", "author", "description", "lastTimePlayed") then
        MapData.currentMapInfo = data
        if MapData.currentMapInfo.lastTimePlayed then
            MapData.currentMapInfo.lastTimePlayed = os.date("%d %b %Y", MapData.currentMapInfo.lastTimePlayed) or false
        end

        if not MapData.currentMapInfo.author or MapData.currentMapInfo.author == "" then
            MapData.currentMapInfo.author = "Author not set"
        end

        if not MapData.currentMapInfo.description or MapData.currentMapInfo.description == "" then
            MapData.currentMapInfo.author = "Description not set"
        end
    else
        MapData.currentMapInfo = {
            name = "",
            resourceName = "",
            timesPlayed = 0,
            author = "Author not set",
            description = "Description not set",
            lastTimePlayed = false,
        }
    end
end

local function changeMapRounds(current, max)
    MapData.mapRoundsInfo = {
        current = tonumber(current) or 1,
        maximum = tonumber(max) or 3
    }
end
addEvent("onClientRoundCountChange", true)
addEventHandler("onClientRoundCountChange", root, changeMapRounds)

local dataChangeActions = {
    ["mapratings.nextmap"] = function(_,_,new) return changeNextMapRatings(new) end,
    ["mapratings.currentmap"] = function(_,_,new) return changeCurrentMapRatings(new) end,
    ["map_window.currentMapInfo"] = function(_,_,new) return changeCurrentMapInfo(new) end,
}

addEventHandler("onElementDataChange", root,
function(theKey, oldValue, newValue)
    if dataChangeActions[theKey] then
        dataChangeActions[theKey](theKey, oldValue, newValue)
    end
end)

addEvent("receiveUserMapRate", true)
addEventHandler("receiveUserMapRate", localPlayer, function(rate)
    MapData.currentMapUserRate = (rate == 0 or rate == 1) and rate or false
end)

function MapData.init()
    -- Init element data on resource start
    for key, func in pairs(dataChangeActions) do
        func(nil, nil, getElementData(root, key))
    end
end
addEventHandler("onClientResourceStart", resourceRoot, MapData.init)
