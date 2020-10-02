AllMapsRatings = {}
local mapRatings = {
    -- [resourceName] = {likes = 0, dislikes = 0}
}

local function parseReceivedRatings(received)
    local allRatings = {}
    for _, v in ipairs(received) do
        allRatings[v.mapresourcename] = {likes = v.likes or 0, dislikes = v.dislikes or 0}
    end
end

function AllMapsRatings.getRating(resourceName)
    assert(type(resourceName) == "string", "Invalid argument, should be string. Got: " .. type(resourceName))
    return mapRatings[resourceName] and { likes=mapRatings[resourceName].likes, dislikes=mapRatings[resourceName].dislikes } or { likes=0, dislikes=0 }
end

function AllMapsRatings.receiveRatingsFromDatabase(ratings)
    mapRatings = parseReceivedRatings(ratings)
end

function AllMapsRatings.requestRatings()
    RatingsFetcher.requestAll()
end
