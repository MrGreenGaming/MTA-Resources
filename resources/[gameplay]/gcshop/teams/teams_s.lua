local team_price = 2500
local teams = {}	-- [teamid] = <teamelement>
local teamwars = {} -- i = {player element challenger, player element victim}
local playerteams = {}
local playertimestamp = {}
local invites = {}
local duration = 1
local team_duration = 30 * 24 * 60 * 60

local team_sql = [[CREATE TABLE IF NOT EXISTS `team` (
	`teamid` smallint(5) unsigned NOT NULL AUTO_INCREMENT, 
	`owner` mediumint(8) NOT NULL, 
	`create_timestamp` int(11) NOT NULL, 
	`renew_timestamp` int(11) NOT NULL COMMENT 'timestamp when last renewed', 
	`name` varchar(20) NOT NULL, 
	`tag` varchar(6) NOT NULL, 
	`colour` varchar(7) NOT NULL, 
	`message` varchar(255) DEFAULT NULL, 
	PRIMARY KEY (`teamid`), 
	KEY `teamname` (`name`) USING BTREE, 
	KEY `teamtag` (`tag`) USING BTREE, 
	KEY `teamowner` (`owner`) USING BTREE, 
	CONSTRAINT `Team owner forumid` FOREIGN KEY (`owner`) REFERENCES `mrgreen_forums`.`x_utf_l4g_members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8;
]]
local teammem_sql = [[
 CREATE TABLE IF NOT EXISTS `team_members` (
	`forumid` mediumint(8) NOT NULL, 
	`teamid` smallint(5) unsigned NOT NULL, 
	`join_timestamp` int(11) NOT NULL COMMENT 'timestamp when joined current team', 
	`status` int(11) NOT NULL COMMENT '1 = in team', 
	PRIMARY KEY (`forumid`), 
	KEY `teamid` (`teamid`), 
	CONSTRAINT `Forum account` FOREIGN KEY (`forumid`) REFERENCES `mrgreen_forums`.`x_utf_l4g_members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE, 
	CONSTRAINT `Team members` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8;]]

addEventHandler('shopStarted', root, function()
	-- Create tables if they don't exist yet on shop start
	dbExec ( handlerConnect, team_sql )
	dbExec ( handlerConnect, teammem_sql )
end)

addEventHandler('onShopInit', root, function()
end)

addEventHandler("onGCShopLogin", root, function()
	checkPlayerTeam ( source, true )
	triggerClientEvent(source, "teamLogin", resourceRoot)
end)

addEventHandler("onGCShopLogout", root, function()
	playerteams[source] = nil
	leaveTeam (source)
	triggerClientEvent(source, "teamLogout", resourceRoot)
end)

addEvent('buyTeam', true)
addEventHandler("buyTeam", resourceRoot, function(teamname, teamtag, teamcolour, teammsg)
	local player = client
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	local r = playerteams[player]
	if (not forumID) then
		return outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
	-- Check if there are no previous teams in the last 30 days
	elseif r and r.status ~= 1 and (getRealTime().timestamp - r.join_timestamp) < duration then
		return outputChatBox('[TEAMS] You were in a team less than 30 days ago. Wait before creating another team', player, 0,255,0)
	-- Check if it's renewing a team
	elseif r and r.status == 1 then
		if type(teamcolour) ~= 'string' or #teamcolour < 1 then teamcolour = string.format('#%06X', math.random(0, 255*255*255)) end
		if type(teammsg) ~= 'string' or #teammsg < 1 then teammsg = nil end
		
		if type(teamname) ~= 'string' or #teamname < 3 then
			outputChatBox('Not a valid teamname', player, 255, 0, 0 )
			return
		elseif type(teamtag) ~= 'string' or #teamtag < 3 then
			outputChatBox('Not a valid teamtag', player, 255, 0, 0 )
			return
		elseif type(teamcolour) ~= 'string' or not getColorFromString(teamcolour) then
			outputChatBox('Not a valid teamcolour', player, 255, 0, 0 )
			return
		end
		local result, error = gcshopBuyItem ( player, team_price, 'Team renew: ' .. tostring(r.teamid) )
		if result == true then
			local added
			if r.owner ~= forumID then
				added = dbExec(handlerConnect, [[UPDATE `team` SET `renew_timestamp`=? WHERE `teamid`=?]], math.max(getRealTime().timestamp + team_duration, math.min(r.renew_timestamp + team_duration, getRealTime().timestamp + 2 * team_duration)), r.teamid)
			else
				added = dbExec(handlerConnect, [[UPDATE `team` SET `renew_timestamp`=?, `name`=?, `tag`=?, `colour`=?, `message`=? WHERE `teamid`=?]], math.max(getRealTime().timestamp + team_duration, math.min(r.renew_timestamp + team_duration, getRealTime().timestamp + 2 * team_duration)), teamname, teamtag, teamcolour, teammsg, r.teamid)
				setTeamName(teams[r.teamid], teamtag .. ' ' .. teamname)
				setTeamColor(teams[r.teamid], getColorFromString(teamcolour))
			end
			addToLog ( '"' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought Team renew: ' .. tostring(r.teamid) )
			outputChatBox ('Team renewed.', player, 0, 255, 0)
			checkPlayerTeam ( player )
			return
		end
		if error then
			outputChatBox( 'An error occured, try reconnecting and notify an admin if you lost GC!', player, 255, 0, 0 )
			addToLog ( 'Error: "' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought Team renew: ' .. tostring(r.teamid) .. ' Result=' .. tostring(result) .. ' Error=' .. tostring(error))
		end
	-- Buying a new team
	else
		-- Check input
		if type(teamcolour) ~= 'string' or #teamcolour < 1 then teamcolour = string.format('#%06X', math.random(0, 255*255*255)) end
		if type(teammsg) ~= 'string' or #teammsg < 1 then teammsg = nil end
		
		if type(teamname) ~= 'string' or #teamname < 3 then
			outputChatBox('Not a valid teamname', player, 255, 0, 0 )
			return
		elseif type(teamtag) ~= 'string' or #teamtag < 3 then
			outputChatBox('Not a valid teamtag', player, 255, 0, 0 )
			return
		elseif type(teamcolour) ~= 'string' or not getColorFromString(teamcolour) then
			outputChatBox('Not a valid teamcolour', player, 255, 0, 0 )
			return
		end
	
		local result, error = gcshopBuyItem ( player, team_price, 'Team: ' .. table.concat({teamname, teamtag, teamcolour, teammsg}, ', ') )
		if result == true then
			local added = addTeamToDatabase( forumID, teamname, teamtag, teamcolour, teammsg )
			addToLog ( '"' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought Team: ' .. table.concat({teamname, teamtag, teamcolour, teammsg}, ', ') )
			outputChatBox ('Team \"' .. teamname  .. '\" (' .. tostring(teamtag) .. ') bought.', player, 0, 255, 0)
			checkPlayerTeam ( player )
			return
		end
		if error then
			outputChatBox( 'An error occured, try reconnecting and notify an admin if you lost GC!', player, 255, 0, 0 )
			addToLog ( 'Error: "' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought Team: ' .. table.concat({teamname, teamtag, teamcolour, teammsg}, ', ') .. ' Result=' .. tostring(result) .. ' Error=' .. tostring(error))
		end
	end
end)

function addTeamToDatabase( forumID, teamname, teamtag, teamcolour, teammsg )
	local teamcreate = [[INSERT INTO `team`(`owner`, `create_timestamp`, `renew_timestamp`, `name`, `tag`, `colour`, `message`) VALUES (?,?,?,?,?,?,?)]]
	dbExec(handlerConnect, teamcreate, forumID, getRealTime().timestamp, getRealTime().timestamp + team_duration, teamname, teamtag, teamcolour, teammsg)
	local teammember = [[REPLACE INTO `team_members`(`forumid`, `teamid`, `join_timestamp`, `status`) VALUES (?,LAST_INSERT_ID(),?,?)]]
	return dbExec(handlerConnect, teammember, forumID, getRealTime().timestamp, 1)
end

function addPlayerToTeamDatabase ( forumID, teamid )
	local teammember = [[REPLACE INTO `team_members`(`forumid`, `teamid`, `join_timestamp`, `status`) VALUES (?,?,?,?)]]
	return dbExec(handlerConnect, teammember, forumID, teamid, getRealTime().timestamp, 1)
end


-- Looks up which team the player is in and puts him in it
function checkPlayerTeam ( player, bLogin )
	dbQuery ( checkPlayerTeam2, { player, bLogin }, handlerConnect, [[SELECT * FROM `team_members` INNER JOIN `team`ON `team_members`.`teamid` = `team`.`teamid`  INNER JOIN `mrgreen_gc`.green_coins g ON `team_members`.`forumid` = g.forum_id ORDER BY `team`.`create_timestamp`, `join_timestamp`]] )
end

function checkPlayerTeam2 ( qh, player, bLogin )
	local result = dbPoll( qh, -1 )

	-- Check result and if player is still logged in
	if not (isElement(player) and exports.gc:getPlayerForumID ( player ) and result) or #result < 1 then
		playerteams[player] = nil
		return leaveTeam (player)
	end
	
	-- Store player and team data for later usage
	local r
	local forumid = tonumber(exports.gc:getPlayerForumID ( player ))
	for i, j in ipairs(result) do
		if j.forumid == forumid then
			r = j
			playerteams[player] = j
		end
		if j.forumid == j.owner then
			j.age = string.format("%.2f", (j.renew_timestamp - getRealTime().timestamp)/ (24 * 60 * 60))
		end
	end
	
	local age
	if r then
		-- Check team age
		age = (r.renew_timestamp - getRealTime().timestamp)
		r.age = string.format("%.2f", age/ (24 * 60 * 60))
		outputConsole('[TEAMS] Team days left: ' .. r.age, player)
	end
	
	triggerClientEvent('teamsData', resourceRoot, result, player, r)
	
	-- Check if player is in a team
	if not r then
		playerteams[player] = nil
		return leaveTeam (player)
	elseif r.status ~= 1 then
		return leaveTeam (player)
	end
	
	-- Check team age
	local age = (r.renew_timestamp - getRealTime().timestamp)
	outputConsole('[TEAMS] Team days left: ' .. r.age, player)
	if age < 0 then
		if bLogin then
			outputChatBox('[TEAMS] Your 30 days team has expired, go to the gcshop to renew it', player, 0, 255, 0)
		end
		return
	end
	
	-- Create team element if it doesn't exist yet
	local tr, tg, tb = getColorFromString(r.colour)
	if not teams[r.teamid] then
		teams[r.teamid] = createTeam(r.tag .. ' ' .. r.name, tr, tg, tb)
		setElementData(teams[r.teamid], 'gcshop.teamid', r.teamid)
		setElementData(teams[r.teamid], 'gcshop.owner', r.owner)
	end
	-- Don't use team elements in CTF
	if exports.race:getRaceMode() ~= "Capture the flag" then
		setPlayerTeam(player, teams[r.teamid])
	end
	-- Show personal team message
	if r.message and bLogin then
		outputChatBox('#00FF00[TEAMS] ' .. r.message, player, tr, tg, tb, true)
	end
end

-- Makes sure a player is not in a team, and if he was his team will be destroyed if it will be empty
function leaveTeam (player)
	if not isElement(player) then return end
	local teamid = getPlayerTeam(player) and getElementData(getPlayerTeam(player), 'gcshop.teamid')
	if teams[teamid] and countPlayersInTeam(teams[teamid]) < 2 then
		destroyElement ( teams[teamid] )
		teams[teamid] = nil
	end
	if exports.race:getRaceMode() ~= "Capture the flag" then
		setPlayerTeam(player, nil)
	end
	invites[player] = nil
end

addEvent('onGamemodeMapStop', true)
addEventHandler('onGamemodeMapStop', root, function()
	for player, r in pairs(playerteams) do
		if r.status == 1 then
			setPlayerTeam(player, teams[r.teamid])
		end
	end
end)


-- Sending invites, accepting, leaving team
function invite(sender, c, playername)
	local ownerid = tonumber(exports.gc:getPlayerForumID ( sender ))
	if not ownerid then return end
	
	-- Check if the player exists and is logged in
	local player = getPlayerFromName_(playername)
	if not player then
		return outputChatBox('[TEAMS] Could not find ' .. tostring(playername) .. ', please type the full nickname', sender, 0,255,0)
	elseif not tonumber(exports.gc:getPlayerForumID ( player )) then
		return outputChatBox('[TEAMS] ' .. tostring(playername) .. ' is not logged in to GC', sender, 0,255,0)
	-- Check if the sender is the owner and if the player can join the team
	elseif not (playerteams[sender] and playerteams[sender].status == 1 and playerteams[sender].owner == ownerid) then
		return outputChatBox('[TEAMS] Only team owners can send invites!', sender, 255,0,0)
	elseif playerteams[player] and playerteams[sender].status ~= 1 and playerteams[player].teamid == playerteams[sender].teamid then
		return outputChatBox('[TEAMS] ' .. tostring(playername) .. ' is already in your team', sender, 0,255,0)
	elseif playerteams[player] and playerteams[player].teamid ~= playerteams[sender].teamid  and (getRealTime().timestamp - playerteams[player].join_timestamp) < duration then
		return outputChatBox('[TEAMS] ' .. tostring(playername) .. ' is or has been in a team less than 30 days ago and can\'t join other teams', sender, 0,255,0)
	end
	
	outputChatBox('[TEAMS] You invited ' .. getPlayerName(player), sender, 0,255,0)
	outputChatBox('[TEAMS] ' .. getPlayerName(sender) .. ' has sent you an invite to join his team: ' .. tostring(playerteams[sender].name), player, 0,255,0)
	outputChatBox('[TEAMS] Type /accept to join his team', player, 0,255,0)
	invites[player] = {team = playerteams[sender], sender = sender}
end
addCommandHandler('invite', invite)

function accept(player)
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	if not invites[player] then
		return outputChatBox('[TEAMS] You are not invited to any teams!', player, 0,255,0)
	elseif not forumID then
		return outputChatBox('[TEAMS] You are not logged in to GC', sender, 0,255,0)
	-- elseif playerteams[player] and (getRealTime().timestamp - playerteams[player].join_timestamp) < duration then
		-- return outputChatBox('[TEAMS] You were in a team less than 30 days ago. Wait before joining another team', sender, 0,255,0)
	end
	
	outputChatBox('[TEAMS] You accepted the invite and joined the team ' .. tostring(invites[player].team.name), player, 202,255,112)
	if isElement(invites[player].sender) then
		outputChatBox('[TEAMS] ' .. getPlayerName(player) .. ' accepted the invite', invites[player].sender, 202,255,112)
	end
	addPlayerToTeamDatabase ( forumID, invites[player].team.teamid )
	checkPlayerTeam ( player )
	invites[player] = nil
end
addCommandHandler('accept', accept)

function leave(player)
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	if not forumID then
		return outputChatBox('[TEAMS] You are not logged in to GC', sender, 0,255,0)
	elseif playerteams[player].status~=1 then
		return outputChatBox('[TEAMS] You are not logged in a team', sender, 0,255,0)
	end
	
	outputChatBox('[TEAMS] You left your team', player, 0,255,0)
	dbExec(handlerConnect, [[UPDATE `team_members` SET `status`=0 WHERE `forumid`=?]], forumID)
	checkPlayerTeam ( player )
end
addCommandHandler('leave', leave)

function rejoin(player)
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	if not forumID then
		return outputChatBox('[TEAMS] You are not logged in to GC', sender, 0,255,0)
	elseif playerteams[player].status~=0 then
		return outputChatBox('[TEAMS] You can\' rejoin your team', sender, 0,255,0)
	end
	
	outputChatBox('[TEAMS] You rejoined your team', player, 0,255,0)
	dbExec(handlerConnect, [[UPDATE `team_members` SET `status`=1, `join_timestamp`=? WHERE `forumid`=? AND `status`=0]], getRealTime().timestamp, forumID)
	checkPlayerTeam ( player )
end
addCommandHandler('rejoin', rejoin)

function makeowner(sender, c, playername)
	local ownerid = tonumber(exports.gc:getPlayerForumID ( sender ))
	if not ownerid then return end
	
	-- Check if the player exists and is logged in
	local player = getPlayerFromName_(playername)
	if not player then
		return outputChatBox('[TEAMS] Could not find ' .. tostring(playername) .. ', please type the full nickname', sender, 0,255,0)
	elseif not tonumber(exports.gc:getPlayerForumID ( player )) then
		return outputChatBox('[TEAMS] ' .. tostring(playername) .. ' is not logged in to GC', sender, 0,255,0)
	-- Check if the sender is the owner and if the player can join the team
	elseif not (playerteams[sender] and playerteams[sender].status == 1 and playerteams[sender].owner == ownerid) then
		return outputChatBox('[TEAMS] Only team owners can do this!', sender, 255,0,0)
	elseif playerteams[player] and (playerteams[player].status~=1 or playerteams[player].teamid ~= playerteams[sender].teamid) then
		return outputChatBox('[TEAMS] ' .. tostring(playername) .. ' is not in your team', sender, 0,255,0)
	end
	
	dbExec(handlerConnect, [[UPDATE `team` SET `owner`=? WHERE `teamid`=?]], exports.gc:getPlayerForumID ( player ), playerteams[sender].teamid)
	for k, r in pairs(playerteams) do
		if r.teamid == playerteams[sender].teamid then
			outputChatBox('[TEAMS] ' .. getPlayerName(sender) .. ' made ' .. getPlayerName(player) .. ' the new team owner', k, 0,255,0)
			checkPlayerTeam(k)
		end
	end
end
addCommandHandler('makeowner', makeowner)

function teamkick(sender, c, forumid)
	local ownerid = tonumber(exports.gc:getPlayerForumID ( sender ))
	forumid = tonumber(forumid)
	if forumid == ownerid or not ownerid or not forumid then return end
	
	-- Check if the sender is the owner and if the player can join the team
	if not (playerteams[sender] and playerteams[sender].status == 1 and playerteams[sender].forumid == ownerid) then
		return outputChatBox('[TEAMS] Only team owners can do this!', sender, 255,0,0)
	end
	
	dbExec(handlerConnect, [[UPDATE `team_members` SET `status`=-1 WHERE `forumid`=? AND `teamid`=?]], forumid, playerteams[sender].teamid)
	for k, r in pairs(playerteams) do
		if r.teamid == playerteams[sender].teamid then
			outputChatBox('[TEAMS] ' .. getPlayerName(sender) .. ' kicked ' .. forumid .. ' from the team', k, 0,255,0)
			checkPlayerTeam(k)
		end
	end
end
addCommandHandler('teamkick', teamkick)

addEvent('cmd', true)
addEventHandler('cmd', resourceRoot, function(c, a) executeCommandHandler(c, client, a) end)

-- Utility
local getPlayerName_ = getPlayerName

local function getPlayerName ( player )
	return getPlayerName_(player) and string.gsub(getPlayerName_(player),"#%x%x%x%x%x%x","")
end

function getPlayerFromName_ ( name )
	if type(name) ~= 'string' then return false end
	
	for k,v in ipairs(getElementsByType'player') do
		if string.gsub(getPlayerName(v),"#%x%x%x%x%x%x",""):lower() == string.gsub(name,"#%x%x%x%x%x%x",""):lower() then
			return v
		end
	end
	return false
end

-------------------
--Team War update--
-------------------

function xmlCreate()
	local xml
	xml = xmlLoadFile("teams/teamwars.xml")
	if not xml then
		xml = xmlCreateFile("teams/teamwars.xml", "maps")
		xmlSaveFile(xml)
	end
	xmlUnloadFile(xml)
end
addEventHandler('onResourceStart', getResourceRootElement(),xmlCreate)

function fetchMaps(p)
	local teamid, isOwner = isTeamOwner(p)
	if not isOwner then
		outputChatBox("[Team Wars] #ffffffOnly team owners are allowed to choose maps for a team war.", p, 206, 163, 131, true)
		return
	end
	
	local raceMaps = exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName("race"))
	if not raceMaps then return false end
	
	local t = {}
    for a,b in ipairs(raceMaps) do
        local name = getResourceInfo(b,"name")
        local author = getResourceInfo(b,"author")
        local resname = getResourceName(b)

        if not name then name = resname end
        if not author then author = "N/A" end
		
        local r = {name, author, resname}
		
        table.insert(t,r)
    end

	table.sort(t,function(a,b) return tostring(a[1]) < tostring(b[1]) end)
	
	triggerClientEvent(p,"gcshop_teams_fetchMaps_c",resourceRoot,t)
end
addEvent("gcshop_teams_fetchMaps_s",true)
addEventHandler("gcshop_teams_fetchMaps_s",root,fetchMaps)

function fetchQueue_s(p)
	local t = fetchQueue(p)
	triggerClientEvent(p,"gcshop_teams_updateTWQueue_c",resourceRoot,t)
end
addEvent("gcshop_teams_fetchQueue_s",true)
addEventHandler("gcshop_teams_fetchQueue_s",root,fetchQueue_s)

function fetchQueue(p)
	local teamid, isOwner = isTeamOwner(p)
	
	local xml = xmlLoadFile("teams/teamwars.xml")
	if not xml then return end
	local tms = xmlNodeGetChildren(xml)
	local t = {}
	for a,b in ipairs(tms) do
		if xmlNodeGetAttribute(b, "teamid") == tostring(teamid) then
			local mps = xmlNodeGetChildren(b)
			for c,d in ipairs (mps) do
				local map = xmlNodeGetValue(d)
				if not map then break end
				
				local name = getResourceInfo(getResourceFromName(map), "name")
				local author = getResourceInfo(getResourceFromName(map), "author")
				if not author then author = "N/A" end
				
				t[c] = {name, author, map}
			end
		end
	end
	xmlUnloadFile(xml)
	
	return t
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

function isTeamOwner(p)
	local forumID = tonumber(exports.gc:getPlayerForumID(p))
	local members = fetchMembers()
	local teams = fetchTeams()
	if not forumID or not members or not teams then return end
	
	local teamid = false
	for a,b in ipairs(members) do
		if b.forumid == forumID then teamid = b.teamid end
	end
	if not teamid then return end
	
	local owner = false
	for a,b in ipairs(teams) do
		if b.teamid == teamid then owner = b.owner end
	end
	if not owner then return end
	
	local isOwner = false
	if forumID == owner then isOwner = true end
	
	return teamid, isOwner
end

function addMaps(p, resname)
	local teamid, isOwner = isTeamOwner(p)
	
	local bool = false
	local xml = xmlLoadFile("teams/teamwars.xml")
	if not xml then return end
	local tms = xmlNodeGetChildren(xml)
	for a,b in ipairs(tms) do
		if xmlNodeGetAttribute(b, "teamid") == tostring(teamid) then
			bool = true
			local mps = xmlNodeGetChildren(b)
			if #mps >= 3 then
				outputDebugString("Maximum maps added", 0)
			else
				local map = xmlCreateChild(b, "map")
				xmlNodeSetValue(map, resname)
			end
		end
	end
	if bool == false then
		local child = xmlCreateChild(xml, "team")
		xmlNodeSetAttribute(child, "teamid", teamid)
		local map = xmlCreateChild(child, "map")
		xmlNodeSetValue(map, resname)
	end
	
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end
addEvent("gcshop_teams_addMaps_s",true)
addEventHandler("gcshop_teams_addMaps_s",root,addMaps)

function removeMaps(p, resname)
	local teamid, isOwner = isTeamOwner(p)
	
	local xml = xmlLoadFile("teams/teamwars.xml")
	if not xml then return end
	local tms = xmlNodeGetChildren(xml)
	for a,b in ipairs(tms) do
		if xmlNodeGetAttribute(b, "teamid") == tostring(teamid) then
			local mps = xmlNodeGetChildren(b)
			for c,d in ipairs(mps) do
				local map = xmlNodeGetValue(d)
				if map == resname then
					xmlDestroyNode(d)
					break
				end
			end
		end
	end
	
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end
addEvent("gcshop_teams_removeMaps_s",true)
addEventHandler("gcshop_teams_removeMaps_s",root,removeMaps)

function startTW(p, cmd, arg)
	if arg then
		sendTWRequest(p, arg)
	else
		acceptTWRequest(p)
	end
end
addCommandHandler("teamwar", startTW, true, true)

function sendTWRequest(challengerPlayer, arg)
	local challengerTeam, isOwner = isTeamOwner(challengerPlayer)
	
	if not isOwner then
		outputChatBox("[Team Wars] #ffffffOnly team owners are allowed to start a team war.", challengerPlayer, 206, 163, 131, true)
		return
	end
	
	if getResourceFromName('eventmanager') and getResourceState(getResourceFromName('eventmanager')) == 'running' and exports.eventmanager:isAnyMapQueued(true) then
		outputChatBox("[Team Wars] #ffffffIt's not possible to start team wars during events.", challengerPlayer, 206, 163, 131, true)
		return
	end
	
	local teams = fetchTeams()
	local t = {}
	for a,b in ipairs(teams) do
		local match = false
		local f = string.find(string.lower( tostring(b.name) ),arg)
		if type(f) == "number" then match = true end
		if match then table.insert(t,{b.teamid, b.owner, b.name}) end
	end
	
	local players = getElementsByType("player")
	local members = fetchMembers()
	local m = {}
	for a,b in ipairs(players) do
		local forumID = tonumber(exports.gc:getPlayerForumID(b))
		for c,d in ipairs(members) do
			if tostring(d.forumid) == tostring(forumID) then
				table.insert(m,{b, d.forumid, d.teamid})
			end
		end
	end
	if #m == 0 then return end
	
	local r1 = {}
	for a,b in ipairs(m) do
		local match = false
		for c,d in ipairs(r1) do
			if tostring(d) == tostring(b[3]) then match = true end
		end
		if not match then table.insert(r1,b[3]) end
	end
	
	local victimTeam
	local r2 = {}
	for a,b in ipairs(r1) do
		local match = false
		for c,d in ipairs(t) do
			if tostring(b) == tostring(d[1]) then
				match = true
				outputDebugString("Matching team: " .. d[3],0)
			end
		end
		if match then table.insert(r2, b) end
	end
	if #r2 > 1 then
		outputChatBox("[Team Wars] #ffffffFound more than 1 matching team, try to choose something more specific.", challengerPlayer, 206, 163, 131, true)
		return
	else
		victimTeam = r2[1]
	end
	
	local challengerTeamName
	local victimTeamName
	for a,b in ipairs(teams) do
		if tostring(b.teamid) == tostring(challengerTeam) then challengerTeamName = b.name end
		if tostring(b.teamid) == tostring(victimTeam) then victimTeamName = b.name end
	end
	
	local victimForumID
	for a,b in ipairs(t) do
		if tostring(b[1]) == tostring(victimTeam) then
			victimForumID = b[2]
		end
	end
	
	local victimPlayer
	for a,b in ipairs(m) do
		if tostring(b[2]) == tostring(victimForumID) then
			victimPlayer = b[1]
		end
	end
	
	local match = false
	for a,b in ipairs(teamwars) do
		if b[1] == challengerPlayer and b[2] == victimPlayer then match = true end
	end
	if match then
		outputChatBox("[Team Wars] #ffffffYou already challenged " .. victimTeamName .. ".", challengerPlayer, 206, 163, 131, true)
		return
	else
		cleanupTW(challengerPlayer, victimPlayer)
		table.insert(teamwars, {challengerPlayer, victimPlayer})
		outputChatBox("[Team Wars] #ffffffYou challenged " .. victimTeamName .. " for a team war.", challengerPlayer, 206, 163, 131, true)
		outputChatBox("[Team Wars] #ffffff" .. challengerTeamName .. " challenged you for a team war!", victimPlayer, 206, 163, 131, true)
		outputChatBox("[Team Wars] #ffffffType /teamwar to accept the challenge.", victimPlayer, 206, 163, 131, true)
	end
end

function acceptTWRequest(victimPlayer)
	local challengerPlayer
	local match = false
	for a,b in ipairs(teamwars) do
		if b[2] == victimPlayer then
			match = true
			challengerPlayer = b[1]
		end
	end
	if getResourceFromName('eventmanager') and getResourceState(getResourceFromName('eventmanager')) == 'running' and exports.eventmanager:isAnyMapQueued(true) then
		outputChatBox("[Team Wars] #ffffffIt's not possible to start team wars during events.", victimPlayer, 206, 163, 131, true)
		return
	end
	if not match then
		outputChatBox("[Team Wars] #ffffffYou are not challenged for a team war.", victimPlayer, 206, 163, 131, true)
		outputChatBox("[Team Wars] #ffffffType /teamwar <team name> to challenge a team.", victimPlayer, 206, 163, 131, true)
		return
	else
		cleanupTW(challengerPlayer, victimPlayer)
	end
	
	local challengerTeam, isChallengerOwner = isTeamOwner(challengerPlayer)
	local victimTeam, isVictimOwner = isTeamOwner(victimPlayer)
	
	if not isChallengerOwner or not isVictimOwner then
		--outputChatBox("at least 1 player is not owner")
		return
	end
	
	local teams = fetchTeams()
	local t = {}
	for a,b in ipairs(teams) do
		table.insert(t,{b.teamid, b.owner, b.name})
	end
	
	local challengerTeamName
	local victimTeamName
	for a,b in ipairs(t) do
		if tostring(b[1]) == tostring(challengerTeam) then challengerTeamName = b[3] end
		if tostring(b[1]) == tostring(victimTeam) then victimTeamName = b[3] end
	end
	
	outputChatBox("[Team Wars] #ffffff" .. challengerTeamName .. " accepted your team war!", challengerPlayer, 206, 163, 131, true)
	
	local cha_t = fetchQueue(challengerPlayer)
	local vic_t = fetchQueue(victimPlayer)
	local maps = {}
	for a,b in ipairs(cha_t) do table.insert(maps,b) end
	for a,b in ipairs(vic_t) do table.insert(maps,b) end
	
	local bool = exports.eventmanager:startTeamWar(challengerTeam, victimTeam, maps)
	if bool then
		outputChatBox("[Team Wars] #ffffffA team war between " .. challengerTeamName .. " and " .. victimTeamName .. " will start shortly!", getRootElement(), 206, 163, 131, true)
	else
		outputChatBox("[Team Wars] #ffffffOops, something went wrong. The team war was not started.", challengerPlayer, 206, 163, 131, true)
		outputChatBox("[Team Wars] #ffffffOops, something went wrong. The team war was not started.", victimPlayer, 206, 163, 131, true)
	end
end

function cleanupTW(p1, p2)
	local i = #teamwars
	while i > 0 do
		if teamwars[i][1] == p1 or teamwars[i][2] == p2 or not getPlayerNametagText(teamwars[i][1]) or not getPlayerNametagText(teamwars[i][2]) then
			table.remove(teamwars, i)
		end
		i = i - 1
	end
end