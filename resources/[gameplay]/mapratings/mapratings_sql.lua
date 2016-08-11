local theCon = false

addEventHandler('onResourceStart', resourceRoot,
	function()
		theCon = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname", get("*gcshop.user"), get("*gcshop.pass"))
		dbExec( theCon, "CREATE TABLE IF NOT EXISTS `mapratings` ( `forumid` INT, `serial` TINYTEXT, `playername` TINYTEXT, `mapresourcename` VARCHAR(70) BINARY NOT NULL, `rating` BOOLEAN NOT NULL, `time` TIMESTAMP on update CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP )" )
	end
)

function rate (player, cmd)
	if not exports.gc:isPlayerLoggedInGC(player) then outputChatBox("You have to be logged into GCs to access this command. Press f6",player, 255,0,0) return end
	local mapresourcename = getResourceName( exports.mapmanager:getRunningGamemodeMap() )
	local forumid = exports.gc:getPlayerForumID(player)
	local serial = getPlayerSerial(player)
	local rating = cmd=="like" and 1 or 0
	if not (forumid and mapresourcename and theCon) then return end
	local mapname = getResourceInfo(exports.mapmanager:getRunningGamemodeMap() , "name") or mapresourcename

	local theQuery = dbQuery(theCon, "SELECT rating FROM mapratings WHERE mapresourcename=? AND (forumid=? OR serial=? OR playername=?)", mapresourcename, forumid, serial, _getPlayerName(player))
	local sql = dbPoll(theQuery,-1)

	if #sql > 0 then
		 dbExec( theCon, "UPDATE mapratings SET rating=?, forumid=? WHERE mapresourcename=? AND (forumid=? OR serial=? OR playername=?)", rating, forumid, mapresourcename, forumid, serial, _getPlayerName(player) )
		 if sql[1].rating == rating then
			outputChatBox("You already "..cmd.."d this map.", player, 255, 0, 0, true)
		else
			outputChatBox("Changed from "..(rating==1 and "dislike" or "like").." to "..cmd..".", player, 225, 170, 90, true)
		end
	else
		if dbExec( theCon, "INSERT INTO mapratings (forumid, mapresourcename,rating) VALUES (?,?,?)", forumid, mapresourcename, rating) then
			outputChatBox("You "..cmd.."d the map: "..mapname, player, 225, 170, 90, true)
		end
	end
	triggerEvent("onSendMapRating", root, getMapRating(mapresourcename, true) or "unrated")
end
addCommandHandler('like', rate, false, false)
addCommandHandler('dislike', rate, false, false)

local ratingCache = {}
function getMapRating(mapresourcename, forceUpdate)
	if not ratingCache[mapresourcename] or forceUpdate then
		local sql_like_query = dbQuery(theCon,"SELECT COUNT(rating) AS count FROM mapratings WHERE rating=? AND mapresourcename=?",1,mapresourcename)
		local sql_like = dbPoll(sql_like_query,-1)

		local sql_hate_query = dbQuery(theCon,"SELECT COUNT(rating) AS count FROM mapratings WHERE rating=? AND mapresourcename=?",0,mapresourcename)
		local sql_hate = dbPoll(sql_hate_query,-1)
		
		ratingCache[mapresourcename] = {likes = sql_like[1].count , hates = sql_hate[1].count}
	end
	return ratingCache[mapresourcename] or {false}
end

function getTableOfRatedMaps()
	local mapTable = {}
	local query = dbQuery(theCon,"SELECT * FROM mapratings")
	local sql = dbPoll(query,-1)
	if #sql > 0 then
		for i, j in ipairs(sql) do 
			if not mapTable[sql[i].mapresourcename] then
				mapTable[sql[i].mapresourcename] = {}
				mapTable[sql[i].mapresourcename].likes = 0
				mapTable[sql[i].mapresourcename].dislikes = 0
			end
			if sql[i].rating == 1 then
				mapTable[sql[i].mapresourcename].likes = mapTable[sql[i].mapresourcename].likes + 1
			elseif sql[i].rating == 0 then
				mapTable[sql[i].mapresourcename].dislikes = mapTable[sql[i].mapresourcename].dislikes + 1
			end
		end
		return mapTable
	end
	return false
end

-- remove color coding from string
function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end
function _getPlayerName ( player )
	return removeColorCoding ( getPlayerName ( player ) )
end

--[[
addCommandHandler('convertratingsfromsqlitetomysql', function()
	local theCon2 = dbConnect("sqlite","mapratings.db")
	local query = dbQuery(theCon2,"SELECT * FROM mapRate")
	local sql = dbPoll(query,-1)
	local resources = getResources()
	local link = {}
	local inserts = {}
	
	if #sql > 0 then
		for _, j in ipairs(sql) do
			if not link[j.mapname] then
				local i
				for k,v in pairs(resources) do
					if getResourceInfo(v, 'name') == j.mapname or getResourceName(v) == j.mapname then
						link[j.mapname] = v
						i = k
						break
					end
				end
				if i then resources[i] = nil end
				link[j.mapname] = link[j.mapname] or true
				outputDebugString('MAP ' .. j.mapname .. ' ' .. tostring(link[j.mapname]), link[j.mapname]== true and 2 or 3)
			end
		end
		for _, j in ipairs(sql) do
			local res = link[j.mapname]
			if res and res ~= true then
				if j.serial then
					-- outputDebugString(' *RES ' .. getResourceName(res) .. j.serial)
					table.insert(inserts, {q = "INSERT INTO mapratings (serial, playername, mapresourcename,rating) VALUES (?,?,?,?)", args = {j.serial, removeColorCoding(j.playername), getResourceName(res), j.rating=="like" and 1 or 0}})
					-- dbExec( theCon, "INSERT INTO mapratings (serial, playername, mapresourcename,rating) VALUES (?,?,?,?)", removeColorCoding(j.playername), j.serial, getResourceName(res), j.rating )
				else
					-- outputDebugString(' *RES ' .. getResourceName(res) .. j.playername)
					table.insert(inserts, {q = "INSERT INTO mapratings (playername, mapresourcename,rating) VALUES (?,?,?)", args = {removeColorCoding(j.playername), getResourceName(res), j.rating=="like" and 1 or 0}})
					-- dbExec( theCon, "INSERT INTO mapratings (playername, mapresourcename,rating) VALUES (?,?,?)", removeColorCoding(j.playername), getResourceName(res), j.rating )
				end
			end
		end
	end
	return insertNext(inserts)
end)

function insertNext(inserts)
	for x = 1,1000 do
		if #inserts < 1 then return end
		local i = table.remove(inserts)
		-- outputDebugString(' *RES ' .. i.args[2] .. i.args[1])
		dbExec(theCon, i.q, unpack(i.args))
	end
	outputChatBox("Todo: " .. #inserts)
	setTimer(insertNext, 50, 1, inserts)
end
--]]