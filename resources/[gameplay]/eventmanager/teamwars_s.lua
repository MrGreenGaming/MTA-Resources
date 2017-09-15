pointSystem = {25, 18, 15, 12, 10, 8, 6, 4, 2, 1} -- [rank] = points, according to the formula 1 point system

currentMap = {}
mapList = {}
playerTeamID = {}
ranking = {} -- [i] = {teamid, points}
teamMembers = nil
TWState = false

function startTeamWar(challengerTeam, victimTeam, maps)
	if #maps < 6 then
		local xml = xmlLoadFile("eventManager.xml")
		if not xml then return false end
		
		local events = xmlNodeGetChildren(xml)
		for a,b in ipairs(events) do
			if xmlNodeGetAttribute(b, "name") == "Circuits" then
				local mps = xmlNodeGetChildren(b)
				if #mps == 0 then break end
				local mps2 = mps
				
				while #maps <6 do
					if #mps2 == 0 then mps2 = mps end
					local r = math.random(1,#mps2)
					local map = xmlNodeGetValue(mps2[r])
					if not map then break end
					
					local name = getResourceInfo(getResourceFromName(map), "name")
					local author = getResourceInfo(getResourceFromName(map), "author")
					if not author then author = "N/A" end
					
					table.insert(maps,{name, author, map})
					table.remove(mps2, r)
				end
				
				break
			end
		end
		
		xmlUnloadFile(xml)
	end
	
	local t = {}
	while #maps > 0 do
		local r = math.random(1,#maps)
		table.insert(t,{maps[r][3], "Team War", "eventmanager_teamwars", challengerTeam, victimTeam})
		table.remove(maps, r)
	end
	
	triggerEvent("eventmanager_eventInject", root, t)
	return true
end

function teamwars(mapRow)
	table.insert(mapList, mapRow)
end
addEvent("eventmanager_teamwars",true)
addEventHandler("eventmanager_teamwars",root,teamwars)

function onMapStart(res)
	local match = false
	for a,b in ipairs(mapList) do
		if b[1] == getResourceName(res) then
			match = true
			break
		end
	end
	if not match then return end
	currentMap = mapList
	mapList = {}
	
	-- outputChatBox("start: " .. getTWState(true))
	if getTWState() == "started" then
		teamMembers = fetchMembers()
	end
	addEventHandler("onPlayerFinish", root, finish)
end
addEventHandler("onResourceStart", getRootElement(), onMapStart)

function onMapStop(res)
	local match = false
	for a,b in ipairs(currentMap) do
		if b[1] == getResourceName(res) then
			match = true
			break
		end
	end
	if not match then return end
	local challengerTeam = currentMap[1][4]
	local victimTeam = currentMap[1][5]
	currentMap = {}
	removeEventHandler("onPlayerFinish", root, finish)
	--outputChatBox("stop: " .. getTWState(true))
	if getTWState() == "stopped" then stopTeamWar(challengerTeam, victimTeam) end
	
end
addEventHandler("onResourceStop", getRootElement(), onMapStop)

function finish(rank, time)
	local points = pointSystem[rank]
	if not points then return end
	
	local p = source
	local teamid
	local match = false
	for a,b in ipairs(playerTeamID) do
		if b[1] == p then
			teamid = b[2]
			match = true
		end
	end
	if not match then
		teamid = getPlayerTeam(p)
		table.insert(playerTeamID, {p, teamid})
	end
	
	local match = false
	for a,b in ipairs(ranking) do
		if b[1] == teamid then
			local cPoints = b[2]
			b[2] = cPoints + points
			match = true
		end
	end
	if not match then
		table.insert(ranking, {teamid, points})
	end
end
addEvent("onPlayerFinish",true)

function stopTeamWar(challengerTeam, victimTeam)
	local teamid = false
	local points = 0
	for a,b in ipairs(ranking) do
		if b[1] == challengerTeam or b[1] == victimTeam then
			if b[2] > points then
				teamid = b[1]
				points = b[2]
			end
		end
	end
	if not teamid then return end
	
	local name
	local teams = fetchTeams()
	for a,b in ipairs(teams) do
		if b.teamid == teamid then
			name = b.name
		end
	end
	outputChatBox("[Team Wars] #ffffff" .. name .. " won the team war with " .. points .. " points!", getRootElement(), 206, 163, 131, true)
	
	currentMap = {}
	mapList = {}
	playerTeamID = {}
	ranking = {}
	teamMembers = nil
	TWState = false
end

function getTWState()
	local q = getCurrentQueue()
	local match = false
	for a,b in ipairs(q) do
		if b[3] == "eventmanager_teamwars" then match = true end
	end
	if mapList[1] then match = true end
	if currentMap[1] then match = true end
	
	
	if not TWState and not match then
		return "not running"
	elseif not TWState and match then
		TWState = true
		return "started"
	elseif TWState and match then
		return "running"
	elseif TWState and not match then
		TWState = false
		return "stopped"
	else
		return false
	end
end

function fetchTeams()
	local qh = dbQuery(handlerConnect, "SELECT * FROM `team`")
	local t = dbPoll(qh,-1)
	if not t then return false end
	return t
end

function fetchMembers()
	local qh = dbQuery(handlerConnect, "SELECT * FROM `team_members`")
	local t = dbPoll(qh,-1)
	if not t then return false end
	return t
end

function getPlayerTeam(p)
	local forumID = tonumber(exports.gc:getPlayerForumID(p))
	if teamMembers == nil then teamMembers = fetchMembers() end
	if not forumID or not teamMembers then return end
	
	local teamid = false
	for a,b in ipairs(teamMembers) do
		if b.forumid == forumID then teamid = b.teamid end
	end
	if not teamid then return end
	
	return teamid
end
