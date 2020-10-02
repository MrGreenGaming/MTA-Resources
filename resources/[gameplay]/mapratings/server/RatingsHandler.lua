RatingsHandler = {}

local MESSAGE_PREFIX = "[Map Ratings] "

function RatingsHandler.handlePlayerRate (player, cmd)
    iprint(player, cmd)
    local forumid = exports.gc:getPlayerForumID(player)
	if not forumid then outputChatBox(MESSAGE_PREFIX .. "You have to be logged in to a Green-Coins account to rate a map.", player, 255,0,0) return end

    local playerCooldownSeconds = RatingsCooldown.getPlayerCooldownSeconds(player)
    if playerCooldownSeconds then
        outputChatBox(MESSAGE_PREFIX .. "Please wait ".. playerCooldownSeconds .. " seconds before rating a map.", player, 255,0,0)
        return
    end

    local mapresourcename = getResourceName( exports.mapmanager:getRunningGamemodeMap() )
    local rating = cmd == "like" and 1 or 0
    local mapname = getResourceInfo(exports.mapmanager:getRunningGamemodeMap() , "name") or mapresourcename
    if not (forumid and mapresourcename and Database.connection) then return end

    local currentRating = CurrentMapRatings.getByForumID(forumid)
    if currentRating == cmd then
        if cmd == "like" then
            outputChatBox(MESSAGE_PREFIX .. "You already liked this map.", player, 255, 0, 0, true)
        else
            outputChatBox(MESSAGE_PREFIX .. "You already disliked this map.", player, 255, 0, 0, true)
        end
        return
    end

    local save = dbExec(Database.connection,"INSERT INTO mapratings (forumid, mapresourcename, rating) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE rating = ?", forumid, mapresourcename, rating, rating)
    if save then
        if currentRating == "neutral" then
            if cmd == "like" then
                outputChatBox(MESSAGE_PREFIX .. "You liked the map: "..mapname, player, 225, 170, 90, true)
            else
                outputChatBox(MESSAGE_PREFIX .. "You disliked the map: "..mapname, player, 225, 170, 90, true)
            end
        else
            if cmd == "like" then
                outputChatBox(MESSAGE_PREFIX .. "Changed from dislike to like.", player, 225, 170, 90, true)
            else
                outputChatBox(MESSAGE_PREFIX .. "Changed from like to dislike.", player, 225, 170, 90, true)
            end
        end

        -- Update ratings, recount and trigger updates
        CurrentMapRatings.setByForumID(forumid, rating)
        Broadcaster.broadcastCurrentMap()
    else
        outputChatBox(MESSAGE_PREFIX .. "Something went wrong while saving your map rating. Please try again or inform a developer.", player, 255, 0, 0, true)
        return
    end
end
addCommandHandler('like', RatingsHandler.handlePlayerRate, false, false)
addCommandHandler('dislike', RatingsHandler.handlePlayerRate, false, false)
