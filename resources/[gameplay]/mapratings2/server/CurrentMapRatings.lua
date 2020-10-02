CurrentMapRatings = {}
CurrentMapRatings.isCurrentMapFetched = false
local mapRatings = {
    -- [forumid] = 0 OR 1
}
local mapLikes = 0
local mapDislikes = 0

local function parseRecievedRatings(toParse)
    local parsed = {}
    for _, row in ipairs(toParse) do
        if type(row.forumid) == "number" and row.rating and (row.rating == 0 or row.rating == 1) then
            parsed[row.forumid] = row.rating
        end
    end
    mapRatings = parsed
end

local function broadcastRateChange()
    triggerEvent("onCurrentMapRateChange", root, {likes = mapLikes, dislikes = mapDislikes})
end

local function countLikesAndDislikes()
    local l, d = 0, 0
    for _, rate in ipairs(mapRatings) do
        if rate == 0 then
            d = d + 1
        else
            l = l + 1
        end
    end
    mapLikes = l
    mapDislikes = d
end

function CurrentMapRatings.clear()
    CurrentMapRatings.isCurrentMapFetched = false
    mapRatings = {}
    mapLikes = 0
    mapDislikes = 0
    broadcastRateChange()
end

function CurrentMapRatings.receiveRatingsFromDatabase(resname, ratings)
    if resname == getResourceName(exports.mapmanager:getRunningGamemodeMap()) then
        ratings = parseRecievedRatings(ratings)
        countLikesAndDislikes()
        CurrentMapRatings.isCurrentMapFetched = true
    end
end

function CurrentMapRatings.getRating(forceRecount)
    if forceRecount then countLikesAndDislikes() end
    return {likes = mapLikes, dislikes = mapDislikes}
end

-- Returns "liked" OR "disliked" OR false
function CurrentMapRatings.getByForumID(id)
    assert(type(id) == "number", "Invalid argument supplied. Expected number, got " .. type(id))
    return mapRatings[id] ~= nil and (mapRatings[id] == 1 and "like" or "dislike") or false
end

-- Returns "like" OR "dislike" OR false
function CurrentMapRatings.getByPlayer(player)
    assert(isElement(player) and getElementType(player) == "player", "Invalid argument supplied. Expected player element, got " .. type(player))
    local id = exports.gc:getPlayerForumID(player)
    if not id then return false end
    return CurrentMapRatings.getByForumID(id)
end

function CurrentMapRatings.setByForumID(id, rate)
    assert(type(id) == "number", "Invalid argument supplied. Expected number, got " .. type(id))
    if type(rate) == "number" then
        -- If type is number, it must be 0 for dislike or 1 for like
        assert(rate ~= 0 and rate ~= 1, "Invalid rate for ID " .. id .. ". When supplying a number, it should be 0 for dislike or 1 for like. Got: " .. tostring(rate))
        mapRatings[id] = rate
    elseif type(rate) == "string" then
        -- If type is string, it must be "like" or "dislike"
        assert(rate ~= "like" and rate ~= "dislike", "Invalid rate for ID " .. id .. ". When supplying a string, it should be 'dislike' for dislike or 'like' for like. Got: " .. rate)
        mapRatings[id] = rate == "like" and 1 or 0
    else
        error("Invalid rate argument. Should be either 'like', 'dislike' or 1, 0. Got " .. tostring(rate))
        return false
    end
    countLikesAndDislikes()
    return true
end

function CurrentMapRatings.setByPlayer(player, rate)
    assert(isElement(player) and getElementType(player) == "player", "Invalid argument supplied. Expected player element, got " .. type(player))
    local id = exports.gc:getPlayerForumID(player)
    assert(id, "Player is not logged in to a greencoins account")
    return CurrentMapRatings.setByForumID(id, rate)
end

