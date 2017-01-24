local gcData = {
    host = get"*gcshop.host",
    username = get("*gcshop.user"),
    password = get("*gcshop.pass"),
    database = "mrgreen_gc",
    gcTable = "green_coins"
}


local forumData = {
    host = get"*gcshop.host",
    username = get("*gcshop.user"),
    password = get("*gcshop.pass"),
    database = "mrgreen_forums",
    fTable = "x_utf_l4g_members"
}

local devmode = get"devmode" == true
useSQL = false

--[[--
Quickly enable devmode: /srun set("*gc.devmode", true)

Devmode skips the need for a mysql db installed to test stuff with GC.
You can login to GreenCoins with any username, the password is always 'admin'.

If you want to login with a specific forumID, input it as the username:
/gclogin 546 admin
--]]--


function connect()
	if isElement(handlerForum) and isElement(handlerGC) then
		destroyElement(handlerForum)
		destroyElement(handlerGC)
	end
	if devmode then
		return outputDebugString("GreenCoins started in devmode")
	end
	handlerForum = dbConnect( 'mysql', 'host='..forumData.host..';dbname='..forumData.database, forumData.username, forumData.password)
	if not handlerForum then return false end
	handlerGC = dbConnect( 'mysql', 'host='..gcData.host..';dbname='..gcData.database, gcData.username, gcData.password) 
end

addEventHandler("onResourceStart", resourceRoot, connect)

function gcConnected()
	return (handlerForum and handlerGC and true) or false
end

local accountDetailsCache = {}

function getPlayerLoginInfo(email, pw, callback)
	if devmode then
		-- /gclogin <choose a forumID> <admin>
		if pw == 'admin' then
			local forumID = math.floor(math.abs(tonumber(email))) or 1337
			return callback(forumID)
		end
		return callback(false)
	end

	if handlerForum and email and pw then
		local url = 'http://api.mrgreengaming.com:8080/account/login'	-- returns {"error":0,"userId":591,"user":"SDK","name":"SDK","emailAddress":"sdk@gmail.com","greenCoins":0,"profile.photo":"http://forum_avatar.jpg","profile.photoThumb":"http://forum_avatar.jpg","profile.title":"custom forum title"}
		local post = toJSON{ user = email, password = pw, appId = get"appId", appSecret = get"appSecretPass" }
		-- outputDebugString(post)
		fetchRemote(url, function(r,e)
			if e ~= 0 then
				outputDebugString("getPlayerLoginInfo: fetchRemote query failed! " .. e, 1)
				return callback(false)
			elseif not fromJSON(r) then
				outputDebugString("getPlayerLoginInfo: api query error! " .. r, 1)
				return callback(false)
			else
				local result = fromJSON(r)
				if result.error ~= 0 then
					if result.error ~=2 then --ignore wrong passwords
						outputDebugString("getPlayerLoginInfo: api login error! " .. result.error .. ' ' .. tostring(result.errorMessage), 1)
					end
					return callback(false)
				else
					-- outputDebugString(tostring(r))
					accountDetailsCache[result.userId] = result  
					return callback(result.userId, result.name, result.emailAddress, result.profile, result.joinTimestamp)
				end
			end
		end, post)
	else
		outputDebugString("getPlayerLoginInfo: No db connection or missing details!", 1)
		return callback(false)
	end
end

function getForumAccountDetails(forumID, callback)
	if devmode then
		return callback(forumID)
	end
	
	if handlerForum and forumID then
		if accountDetailsCache[forumID] then return callback(accountDetailsCache[forumID].name, accountDetailsCache[forumID].emailAddress, accountDetailsCache[forumID].profile, accountDetailsCache[forumID].joinTimestamp) end
		local url = 'http://api.mrgreengaming.com:8080/account/details'	-- returns {"error":0,"userId":591,"name":"SDK","emailAddress":"sdk@gmail.com","greenCoins":0,"profile.photo":"http://forum_avatar.jpg","profile.photoThumb":"http://forum_avatar.jpg","profile.title":"custom forum title"}
		local post = toJSON{ userId = forumID, appId = get"appId", appSecret = get"appSecretPass" }
		fetchRemote(url, function(r,e)
			if e ~= 0 then
				outputDebugString("getPlayerLoginInfo: fetchRemote query failed! " .. e, 1)
				return callback(false)
			elseif not fromJSON(r) then
				outputDebugString("getPlayerLoginInfo: api query error! " .. tostring(r), 1)
				return callback(false)
			else
				local result = fromJSON(r)
				if result.error ~= 0 then
					outputDebugString("getForumAccountDetails: api error! " .. result.error .. ' ' .. tostring(result.errorMessage), 1)
					return callback(false)
				else
					-- outputDebugString(tostring(r))
					accountDetailsCache[forumID] = result
					return callback(result.name, result.emailAddress, result.profile, result.joinTimestamp)
				end
			end
		end, post)
	else
		outputDebugString("getForumAccountDetails: No db connection or missing details!", 1)
		return callback(false)
	end
end

function getPlayerGCInfo(forumID)
	if devmode then
		if tonumber(forumID) then
			return tonumber(forumID) * 10, 99999 --gcID and gcAmount
		end
		return false
	end
	
    if handlerGC and forumID then
        local cmd = "SELECT * FROM "..gcData.gcTable.." WHERE forum_id = ? AND valid = 1"
        local query = dbQuery(handlerGC, cmd, forumID )
        if query then
			local result = dbPoll(query, -1)
			if not result then outputDebugString("Error: Query not ready or error") dbFree(query) return false end
			if not result[1] then dbFree(query) return false end
			if not result[1].id or not result[1].amount_current then       --DEBUG PURPOSES.
				outputDebugString('ERROR: Couldn\'t find GC columns for forumid: '..tostring(forumID))
			end	
            return result[1].id, result[1].amount_current
        else
            outputDebugString("getPlayerGCInfo: SELECT query failed!", 1)
        end
    else
        outputDebugString("getPlayerGCInfo: No db connection!", 1)
    end
    return false
end


function setAccountGCInfo(account, gcID, amount, quick)
	if devmode then
		return true
	end

	local cmd
	local query
	local result
	local gc
	if not quick then
		if handlerGC then
			cmd = "UPDATE "..gcData.gcTable.." SET amount_current = amount_current + ?, mta_name = ?, last_edit = ? WHERE id = ? AND valid = 1"
			dbExec(handlerGC, cmd, amount, getPlayerName(account.player), getRealDateTimeNowString(), gcID)		
		else
			outputDebugString("setPlayerGCInfo: No db connection!", 1)
		end
		return false
	else
		 if handlerGC then
			cmd = "SELECT * FROM "..gcData.gcTable.." WHERE id = ? AND valid = 1"
			query = dbQuery(handlerGC, cmd, gcID)
			if query then
				result = dbPoll(query, -1)
				if not result then outputDebugString("Error: Query not ready or error") dbFree(query) return end
				gc = result[1].amount_current + amount
				cmd = "UPDATE "..gcData.gcTable.." SET amount_current = ?, mta_name = ?, last_edit = ? WHERE id = ? AND valid = 1"
				dbExec(handlerGC, cmd, tostring(gc), removeColorCoding(getPlayerName(account.player)), getRealDateTimeNowString(), gcID)
			else
				outputDebugString("mysql_query failed: (") 
			end	
		else
			outputDebugString("setPlayerGCInfo: No db connection!", 1)
		end
		return false
	end	
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
	return getRealDateTimeString( getRealTime() )
end

function getRealDateTimeString( time )
	return string.format( '%04d-%02d-%02d %02d:%02d:%02d'
						,time.year + 1900
						,time.month + 1
						,time.monthday
						,time.hour
						,time.minute
						,time.second
						)
end
