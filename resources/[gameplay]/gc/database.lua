local devMode = get "devmode" == true

--[[
Quickly enable development mode: /srun set("*gc.devmode", true)

Development mode skips the need to run a fork of the website when testing GCs.
You can login to GreenCoins with any username, the password is always 'admin'.

If you want to login with a specific forumID, input it as the username:
/gclogin 546 admin
--]]

function getPlayerLoginInfo(email, pw, callback)
    if not email or not pw then
        outputDebugString("getPlayerLoginInfo: Missing details", 1)
        callback(false)
        return
    end

    if devMode then
        -- /gclogin <choose a forumID> <admin>
        if pw == 'admin' then
            local forumID = math.floor(math.abs(tonumber(email))) or 1337
            callback(forumID)
        else
            callback(false)
        end
        return
    end

    local fetchOptions = {
        queueName = "API",
        connectionAttempts = 3,
        connectTimeout = 4000,
        method = "POST",
        postData = toJSON({
            user = email,
            password = pw,
            appId = get("appId"),
            appSecret = get("appSecretPass")
        }, true),
        headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }
    }

    fetchRemote("https://mrgreengaming.com/api/account/login", fetchOptions, function(res, info)
        if not info.success or not res then
            if not res then
                res = "EMPTY"
            end
            outputDebugString("getPlayerLoginInfo: invalid response (status " .. info.statusCode .. "). Res: " .. res, 1)
            callback(false)
            return
        end

        local result = fromJSON(res)
        if not result or result.error then
            callback(false)
            return
        end

        callback(result.userId, result.name, result.emailAddress, result.profile, result.joinTimestamp, result.coinsBalance)
    end)
end

function getForumAccountDetails(forumID, callback)
    if devMode then
        callback(forumID)
        return
    end

    if not forumID then
        outputDebugString("getForumAccountDetails: Missing details", 1)
        callback(false)
        return
    end

    local fetchOptions = {
        queueName = "API-User" .. forumID,
        connectionAttempts = 3,
        connectTimeout = 4000,
        method = "POST",
        postData = toJSON({
            userId = forumID,
            appId = get("appId"),
            appSecret = get("appSecretPass")
        }, true),
        headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }
    }

    fetchRemote("https://mrgreengaming.com/api/account/details", fetchOptions, function(res, info)
        if not info.success or not res then
            if not res then
                res = "EMPTY"
            end
            outputDebugString("getForumAccountDetails: invalid response (status " .. info.statusCode .. "). Res: " .. res, 1)
            callback(false)
            return
        end

        local result = fromJSON(res)
        if not result or result.error then
            outputDebugString("getForumAccountDetails: api error! " .. result.error .. ' ' .. tostring(result.errorMessage), 1)
            callback(false)
            return
        end

        callback(result.userId, result.name, result.emailAddress, result.profile, result.joinTimestamp, result.coinsBalance)
    end)
end

function getMultipleForumAccountDetails(forumids, callback)
	if devMode then
        callback(forumids)
        return
    end

    if not forumids then
        outputDebugString("getMultipleForumAccountDetails: Missing details", 1)
        callback(false)
        return
    end

    local fetchOptions = {
        queueName = "API-MultipleUsers",
        connectionAttempts = 3,
        connectTimeout = 4000,
        method = "POST",
        postData = toJSON({
            users = forumids,
            appId = get("appId"),
            appSecret = get("appSecretPass")
        }, true),
        headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }
    }

    fetchRemote("https://mrgreengaming.com/api/account/details-multiple", fetchOptions, function(res, info)
        if not info.success or not res then
            if not res then
                res = "EMPTY"
            end
            outputDebugString("getMultipleForumAccountDetails: invalid response (status " .. info.statusCode .. "). Res: " .. res, 1)
            callback(false)
            return
        end

        local result = fromJSON(res)
        if not result or result.error then
            outputDebugString("getMultipleForumAccountDetails: api error! " .. result.error .. ' ' .. tostring(result.errorMessage), 1)
            callback(false)
            return
        end
		
		local output = {}
		for _, p in ipairs(result.users) do
		  table.insert(output, { forumid = p.users, name = p.name, joinDate = p.joinDate, joinTimestamp = p.joinTimestamp, coinsBalance = p.coinsBalance, profile = p.profile })
		end
		
		callback(output)
    end)
end

function getForumAccountDetailsMultiple(forumids, result, r, eventToTrigger)
	getMultipleForumAccountDetails(forumids, function(resp)
		triggerEvent(eventToTrigger, root, resp, result, r)
	end)
end

function setAccountGCInfo(forumID, amount)
    if devMode then
        return true
    end

    local fetchOptions = {
        queueName = "API-User" .. forumID,
        connectionAttempts = 3,
        connectTimeout = 5000,
        method = "POST",
        postData = toJSON({
            amount = amount,
            appId = get("appId"),
            appSecret = get("appSecretPass")
        }, true),
        headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }
    }

    --We'd rather use submitTransaction but we would need to handle transaction denies and such
    fetchRemote("https://mrgreengaming.com/api/users/" .. forumID .. "/coins/changeBalance", fetchOptions, function(res, info)
        if not info.success or not res then
            if not res then
                res = "EMPTY"
            end
            outputDebugString("setAccountGCInfo: invalid response (status " .. info.statusCode .. "). Res: " .. res, 1)
            callback(false)
            return
        end

        local result = fromJSON(res)
        if not result or result.error then
            outputDebugString("setAccountGCInfo: api error " .. result.error .. ' ' .. tostring(result.errorMessage), 1)
            callback(false)
            return
        end
    end)
end

---------------------------------------------------------------------------
--
-- getRealDateTimeNowString()
--
-- current date and time as a sortable string
-- eg '2010-12-25 15:32:45'
--
---------------------------------------------------------------------------
function getRealDateTimeNowString()
    return getRealDateTimeString(getRealTime())
end

function getRealDateTimeString(time)
    return string.format('%04d-%02d-%02d %02d:%02d:%02d', time.year + 1900, time.month + 1, time.monthday, time.hour, time.minute, time.second)
end
