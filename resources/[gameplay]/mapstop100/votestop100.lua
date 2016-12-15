function votes100_fetch100(p)
	local map100 = {}
	local qh = dbQuery(handlerConnect, "SELECT * FROM `mapstop100`")
	local map100_sql = dbPoll(qh,-1)
	if not map100_sql then return false end
    
	for _,row in ipairs(map100_sql) do
        local name = tostring(row.mapname)
        local author = tostring(row.author)
        local resname = tostring(row.mapresourcename)
		local gamemode = tostring(row.gamemode)
        local t = {name = name, author = author, resname = resname, gamemode = gamemode}
        table.insert(map100,t)
    end
    table.sort(map100,function(a,b) return tostring(a.name) < tostring(b.name) end)
	
	local logged = exports.gc:isPlayerLoggedInGC(p)
	local castList = {}
	if logged then
		local forumid = exports.gc:getPlayerForumID(p)
		forumid = tostring(forumid)
		local qh = dbQuery(handlerConnect, "SELECT * FROM `votestop100` WHERE `forumid`=?", forumid)
		local castList_sql = dbPoll(qh,-1)
		if not castList_sql then return false end
		
		if castList_sql[1] then
			for _,row in ipairs(castList_sql) do
				for column in pairs(castList_sql[_]) do
					if column == "id" or column == "forumid" then
					else
						local map = tostring(castList_sql[_][column])
						local qh = dbQuery(handlerConnect, "SELECT * FROM `mapstop100` WHERE `mapresourcename`=?", map)
						local mapInfo = dbPoll(qh,-1)
						local name
						local author
						local resname
						local gamemode
						if mapInfo[1] then
							name = tostring(mapInfo[1].mapname)
							author = tostring(mapInfo[1].author)
							resname = tostring(mapInfo[1].mapresourcename)
							gamemode = tostring(mapInfo[1].gamemode)
						else
							name = ""
							author = ""
							resname = ""
							gamemode = ""
						end
						local t = {name = name, author = author, resname = resname, gamemode = gamemode}
						table.insert(castList,t)
					end
				end
			end
		end
	end
	triggerClientEvent(p,"votes100_receiveMap100",resourceRoot,map100,castList)
end

function votes100_command(p)
	votes100_fetch100(p)
	triggerClientEvent(p,"votes100_openCloseGUI",resourceRoot)
end
addCommandHandler("vote", votes100_command)

function votes100_voteMap(p, resname)
	local logged = exports.gc:isPlayerLoggedInGC(p)
	if logged then
		local forumid = exports.gc:getPlayerForumID(p)
		forumid = tostring(forumid)
		local qh = dbQuery(handlerConnect, "SELECT * FROM `votestop100` WHERE `forumid`=?", forumid)
		local castList_sql = dbPoll(qh,-1)
		if not castList_sql then return false end
		
		if castList_sql[1] then -- player already in database
			if castList_sql[1].choice1 == resname or castList_sql[1].choice2 == resname or castList_sql[1].choice3 == resname or castList_sql[1].choice4 == resname or castList_sql[1].choice5 == resname then
				outputChatBox("You already voted for this map", p)
			else
				local qh
				if castList_sql[1].choice1 == "" then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice1`=? WHERE `forumid`=?", resname, forumid)
				elseif castList_sql[1].choice2 == "" then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice2`=? WHERE `forumid`=?", resname, forumid)
				elseif castList_sql[1].choice3 == "" then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice3`=? WHERE `forumid`=?", resname, forumid)
				elseif castList_sql[1].choice4 == "" then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice4`=? WHERE `forumid`=?", resname, forumid)
				elseif castList_sql[1].choice5 == "" then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice5`=? WHERE `forumid`=?", resname, forumid)
				else qh = false
				end
				
				if qh == false then
					outputChatBox("You voted for the maximum number of maps!", p)
				else
					if dbFree( qh ) then
						outputChatBox("Map voted succesfully", p)
					end
				end
			end
		else -- player not yet in database
			local qh = dbQuery(handlerConnect, "INSERT INTO `votestop100` (`forumid`, `choice1`) VALUES (?,?)", forumid, resname)
			if dbFree( qh ) then
				outputChatBox("Map voted succesfully", p)
			end
		end
		votes100_fetch100(p)
	else
		outputChatBox("You're not logged in to Greencoins!", p)
	end
end
addEvent("votes100_voteMap", true)
addEventHandler("votes100_voteMap", resourceRoot, votes100_voteMap)

function votes100_removeMap(p, resname)
	local logged = exports.gc:isPlayerLoggedInGC(p)
	if logged then
		local forumid = exports.gc:getPlayerForumID(p)
		forumid = tostring(forumid)
		local qh = dbQuery(handlerConnect, "SELECT * FROM `votestop100` WHERE `forumid`=?", forumid)
		local castList_sql = dbPoll(qh,-1)
		if not castList_sql then return false end
		
		if castList_sql[1] then
			local qh
			if castList_sql[1].choice1 == resname then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice1`=? WHERE `forumid`=?", "", forumid)
			elseif castList_sql[1].choice2 == resname then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice2`=? WHERE `forumid`=?", "", forumid)
			elseif castList_sql[1].choice3 == resname then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice3`=? WHERE `forumid`=?", "", forumid)
			elseif castList_sql[1].choice4 == resname then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice4`=? WHERE `forumid`=?", "", forumid)
			elseif castList_sql[1].choice5 == resname then qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice5`=? WHERE `forumid`=?", "", forumid)
			else qh = false
			end
			if qh == false then
				outputChatBox("Error 1", p)
			else
				if dbFree( qh ) then
					outputChatBox("Map removed succesfully", p)
					votes100_fetch100(p)
				end
			end
		else
			outputChatBox("Error 2", p)
		end
	else
		outputChatBox("You're not logged in to Greencoins!", p)
	end
end
addEvent("votes100_removeMap", true)
addEventHandler("votes100_removeMap", resourceRoot, votes100_removeMap)

function votes100_sidebar(p)
	votes100_command(p)
end
addEvent("votes100_sidebarServer", true)
addEventHandler("votes100_sidebarServer", resourceRoot, votes100_sidebar)