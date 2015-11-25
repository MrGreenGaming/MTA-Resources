local team_price = 2500
local teams = {}	-- [teamid] = <teamelement>
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
	if player then playerteams[player] = nil end
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
				added = dbExec(handlerConnect, [[UPDATE `team` SET `renew_timestamp`=? WHERE `teamid`=?]], getRealTime().timestamp, r.teamid)
			else
				added = dbExec(handlerConnect, [[UPDATE `team` SET `renew_timestamp`=?, `name`=?, `tag`=?, `colour`=?, `message`=? WHERE `teamid`=?]], getRealTime().timestamp, teamname, teamtag, teamcolour, teammsg, r.teamid)
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
	dbExec(handlerConnect, teamcreate, forumID, getRealTime().timestamp, getRealTime().timestamp, teamname, teamtag, teamcolour, teammsg)
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
			break
		end
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
	local age = (getRealTime().timestamp - r.renew_timestamp) 
	outputConsole('[TEAMS] Team age in days: ' .. tostring(age/ (24 * 60 * 60)), player)
	if age > team_duration then
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
