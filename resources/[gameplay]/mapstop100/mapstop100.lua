handlerConnect = nil
canScriptWork = true
addEventHandler('onResourceStart', getResourceRootElement(),
function()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname", get("*gcshop.user"), get("*gcshop.pass"))
	if handlerConnect then
		dbExec( handlerConnect, "CREATE TABLE IF NOT EXISTS `mapstop100` ( `id` int(11) NOT NULL AUTO_INCREMENT, `mapresourcename` VARCHAR(70) BINARY NOT NULL, `mapname` VARCHAR(70) BINARY NOT NULL, `author` VARCHAR(70) BINARY NOT NULL, `gamemode` VARCHAR(70) BINARY NOT NULL, `rank` INTEGER, `votes` INTEGER, PRIMARY KEY (`id`) )" )
		dbExec( handlerConnect, "CREATE TABLE IF NOT EXISTS `votestop100` ( `id` int(11) NOT NULL AUTO_INCREMENT, `forumid` int(10) unsigned NOT NULL, `choice1` VARCHAR(70) BINARY NOT NULL, `choice2` VARCHAR(70) BINARY NOT NULL, `choice3` VARCHAR(70) BINARY NOT NULL, `choice4` VARCHAR(70) BINARY NOT NULL, `choice5` VARCHAR(70) BINARY NOT NULL, PRIMARY KEY (`id`) )" )
		else
		outputDebugString('Maps top 100 error: could not connect to the mysql db')
		canScriptWork = false
		return
	end
end
)

function maps100_fetchMaps(player)
    refreshResources()

    local mapList = {}

    -- Get race and uploaded maps
    local raceMps = exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName("race"))
    if not raceMps then return false end

    for _,map in ipairs(raceMps) do
        local name = getResourceInfo(map,"name")

        local author = getResourceInfo(map,"author")
        local resname = getResourceName(map)

        if not name then name = resname end
        if not author then author = "N/A" end
		
		local gamemode
        local t = {name = name, author = author, resname = resname, gamemode = "Race"}
		
        table.insert(mapList,t)
    end

    table.sort(mapList,function(a,b) return tostring(a.name) < tostring(b.name) end)
	
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

	triggerClientEvent(player,"maps100_receiveMapLists",resourceRoot,mapList,map100)
end

function maps100_command(p)
	maps100_fetchMaps(p)
	triggerClientEvent(p,"maps100_openCloseGUI",resourceRoot)
end
addCommandHandler("maps100", maps100_command, true, true)

function maps100_addMap(p, name, author, gamemode, resname)
	local qh = dbQuery(handlerConnect, "SELECT * FROM `mapstop100` WHERE `mapresourcename`=?", tostring(resname))
	local resCheck = dbPoll(qh,-1)
	if resCheck[1] then
		if tostring(resCheck[1].mapresourcename) == tostring(resname) then
			outputChatBox("Map already added", p)
			return
		end
	end
	local qh = dbQuery(handlerConnect, "INSERT INTO `mapstop100` (`mapresourcename`, `mapname`, `author`, `gamemode`, `rank`, `votes`) VALUES (?,?,?,?,?,?)", resname, name, author, gamemode, "0", "0" )
	if dbFree( qh ) then
		outputChatBox("Map added succesfully", p)
	end
	maps100_fetchMaps(p)
end
addEvent("maps100_addMap", true)
addEventHandler("maps100_addMap", resourceRoot, maps100_addMap)

function maps100_delMap(p, name, author, gamemode, resname)
	local qh = dbQuery(handlerConnect, "DELETE FROM `mapstop100` WHERE `mapresourcename`=?", resname)
	if dbFree( qh ) then
		outputChatBox("Map deleted succesfully", p)
	end
	maps100_fetchMaps(p)
end
addEvent("maps100_delMap", true)
addEventHandler("maps100_delMap", resourceRoot, maps100_delMap)

function maps100_fetchInsight(p)
	local voterList = {}
	local qh = dbQuery(handlerConnect, "SELECT * FROM `votestop100`")
	local map100_sql = dbPoll(qh,-1)
	if not map100_sql then return false end
    
	for _,row in ipairs(map100_sql) do
        local id = tostring(row.id)
        local forumid = tostring(row.forumid)
        local choice1 = tostring(row.choice1)
        local choice2 = tostring(row.choice2)
        local choice3 = tostring(row.choice3)
        local choice4 = tostring(row.choice4)
        local choice5 = tostring(row.choice5)
        local t = {id = id, forumid = forumid, choice1 = choice1, choice2 = choice2, choice3 = choice3, choice4 = choice4, choice5 = choice5}
        table.insert(voterList,t)
    end
    table.sort(voterList,function(a,b) return tostring(a.id) < tostring(b.id) end)
	
	local mapsList = {}
	local qh = dbQuery(handlerConnect, "SELECT * FROM `mapstop100`")
	local map100_sql = dbPoll(qh,-1)
	if not map100_sql then return false end
	
	for _,row in ipairs(map100_sql) do
        local id = tostring(row.id)
        local mapresourcename = tostring(row.mapresourcename)
        local rank = tostring(row.rank)
        local votes = tostring(row.votes)
        local mapname = tostring(row.mapname)
        local author = tostring(row.author)
        local gamemode = tostring(row.gamemode)
        local t = {id = id, mapresourcename = mapresourcename, rank = rank, votes = votes, mapname = mapname, author = author, gamemode = gamemode}
        table.insert(mapsList,t)
    end
    table.sort(mapsList,function(a,b) return tostring(a.rank) < tostring(b.rank) end)
	triggerClientEvent(p,"maps100_receiveInsight",resourceRoot,voterList,mapsList)
end
addEvent("maps100_fetchInsight", true)
addEventHandler("maps100_fetchInsight", resourceRoot, maps100_fetchInsight)

function maps100_removeVote(p, forumid, option)
	local qh = dbQuery(handlerConnect, "SELECT * FROM `votestop100` WHERE `forumid`=?", forumid)
	local votesList_sql = dbPoll(qh,-1)
	if not votesList_sql then return false end
	
	if votesList_sql[1] then
		local empty = ""
		if option == "all" then
			local qh = dbQuery(handlerConnect, "DELETE FROM `votestop100` WHERE `forumid`=?", forumid)
			if dbFree( qh ) then
				outputChatBox("Voter removed succesfully", p)
			end
		elseif option == "choice1" then
			local qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice1`=? WHERE `forumid`=?", empty, forumid)
			if dbFree( qh ) then
				outputChatBox("Vote ".. option .. " removed succesfully", p)
			end
		elseif option == "choice2" then
			local qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice2`=? WHERE `forumid`=?", empty, forumid)
			if dbFree( qh ) then
				outputChatBox("Vote ".. option .. " removed succesfully", p)
			end
		elseif option == "choice3" then
			local qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice3`=? WHERE `forumid`=?", empty, forumid)
			if dbFree( qh ) then
				outputChatBox("Vote ".. option .. " removed succesfully", p)
			end
		elseif option == "choice4" then
			local qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice4`=? WHERE `forumid`=?", empty, forumid)
			if dbFree( qh ) then
				outputChatBox("Vote ".. option .. " removed succesfully", p)
			end
		elseif option == "choice5" then
			local qh = dbQuery(handlerConnect, "UPDATE `votestop100` SET `choice5`=? WHERE `forumid`=?", empty, forumid)
			if dbFree( qh ) then
				outputChatBox("Vote ".. option .. " removed succesfully", p)
			end
		else
			outputChatBox("No option selected", p)
		end
		maps100_fetchInsight(p)
	else
		outputChatBox("Player not in database", p)
	end
end
addEvent("maps100_removeVote", true)
addEventHandler("maps100_removeVote", resourceRoot, maps100_removeVote)

function maps100_countVotes(p)
	local qh = dbQuery(handlerConnect, "SELECT * FROM `mapstop100`")
	local maps_sql = dbPoll(qh,-1)
	if not maps_sql then return false end
	
	local qh = dbQuery(handlerConnect, "SELECT * FROM `votestop100`")
	local votes_sql = dbPoll(qh,-1)
	if not votes_sql then return false end
	
	for _,row in ipairs(maps_sql) do
		local resname = tostring(maps_sql[_].mapresourcename)
		local votes = 0
		for i,rij in ipairs(votes_sql) do
			if tostring(votes_sql[i].choice1) == resname then votes = votes + 1 end
			if tostring(votes_sql[i].choice2) == resname then votes = votes + 1 end
			if tostring(votes_sql[i].choice3) == resname then votes = votes + 1 end
			if tostring(votes_sql[i].choice4) == resname then votes = votes + 1 end
			if tostring(votes_sql[i].choice5) == resname then votes = votes + 1 end
		end
		
		local qh = dbQuery(handlerConnect, "UPDATE `mapstop100` SET `votes`=? WHERE `mapresourcename`=?", votes, resname)
		if dbFree( qh ) then
		else
			outputChatBox("Could not set ".. votes .. " votes for " .. resname, p)
		end
	end
	
	local qh = dbQuery(handlerConnect, "SELECT * FROM `mapstop100` ORDER BY `votes` DESC")
	local maps_sql = dbPoll(qh,-1)
	if not maps_sql then return false end
	
	for _,row in ipairs(maps_sql) do
		local resname = tostring(maps_sql[_].mapresourcename)
		
		local qh = dbQuery(handlerConnect, "UPDATE `mapstop100` SET `rank`=? WHERE `mapresourcename`=?", _, resname)
		if dbFree( qh ) then
		else
			outputChatBox("Could not set ".. _ .. " rank for " .. resname, p)
		end
	end
	
	maps100_fetchInsight(p)
end
addEvent("maps100_countVotes", true)
addEventHandler("maps100_countVotes", resourceRoot, maps100_countVotes)