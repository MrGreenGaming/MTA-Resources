local team_price = 2500
local teams = {}	-- [teamid] = <teamelement>
local playerteams = {}
local invites = {}

local team_sql = [[CREATE TABLE IF NOT EXISTS `team` (
	`teamid` smallint(5) unsigned NOT NULL AUTO_INCREMENT, 
	`owner` mediumint(8) NOT NULL, 
	`timestamp` int(11) NOT NULL, 
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
	`timestamp` int(11) NOT NULL COMMENT 'timestamp when joined team', 
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
	checkPlayerTeam ( source )
	triggerClientEvent(source, "teamLogin", resourceRoot)
end)

addEventHandler("onGCShopLogout", root, function()
	local teamid = getPlayerTeam(source) and getElementData(getPlayerTeam(source), 'gcshop.teamid')
	if teams[teamid] and countPlayersInTeam(teams[teamid]) < 2 then
		destroyElement ( teams[teamid] )
		teams[teamid] = nil
	end
	playerteams[source] = nil
	invites[source] = nil
	triggerClientEvent(source, "teamLogout", resourceRoot)
end)

addEvent('buyTeam', true)
addEventHandler("buyTeam", resourceRoot, function(teamname, teamtag, teamcolour, teammsg)
	if not hasObjectPermissionTo(client, "command.deletemap", false) then return end
	
	local player = client
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	if type(teamcolour) ~= 'string' or #teamcolour < 1 then teamcolour = string.format('#%06X', math.random(0, 255*255*255)) end
	if type(teammsg) ~= 'string' or #teammsg < 1 then teammsg = nil end
	
	if (not forumID) then
		outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
		return
	elseif type(teamname) ~= 'string' or #teamname < 3 then
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
		-- triggerClientEvent( player, 'modshopLogin', player, vehicle_price, getUpgInDatabase(forumID) or false )
		return
	end
	if error then
		outputChatBox( 'An error occured, try reconnecting and notify an admin if you lost GC!', player, 255, 0, 0 )
		addToLog ( 'Error: "' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought Team: ' .. table.concat({teamname, teamtag, teamcolour, teammsg}, ', ') .. ' Result=' .. tostring(result) .. ' Error=' .. tostring(error))
	end
end)

function addTeamToDatabase( forumID, teamname, teamtag, teamcolour, teammsg )
	local teamcreate = [[INSERT INTO `team`(`owner`, `timestamp`, `name`, `tag`, `colour`, `message`) VALUES (?,?,?,?,?,?)]]
	dbExec(handlerConnect, teamcreate, forumID, getRealTime().timestamp, teamname, teamtag, teamcolour, teammsg)
	local teammember = [[REPLACE INTO `team_members`(`forumid`, `teamid`, `timestamp`, `status`) VALUES (?,LAST_INSERT_ID(),?,?)]]
	return dbExec(handlerConnect, teammember, forumID, getRealTime().timestamp, 1)
end

function addPlayerToTeamDatabase ( forumID, teamID )
	local teammember = [[REPLACE INTO `team_members`(`forumid`, `teamid`, `timestamp`, `status`) VALUES (?,?,?,?)]]
	return dbExec(handlerConnect, teammember, forumID, teamID, getRealTime().timestamp, 1)
end

-- Looks up which team the player is in and puts him in it
function checkPlayerTeam ( player )
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	dbQuery ( checkPlayerTeam2, {player}, handlerConnect, [[SELECT * FROM `team_members` INNER JOIN `team` ON `team_members`.`teamid` = `team`.`teamid` WHERE `forumid` = ? AND `status` = 1]], forumID )
end

function checkPlayerTeam2 ( qh, player )
	local result = dbPoll( qh, -1 )

	-- check result and if player is still logged in
	if not (isElement(player) and exports.gc:getPlayerForumID ( player ) and result and #result > 0) then
		local teamid = getPlayerTeam(player) and getElementData(getPlayerTeam(player), 'gcshop.teamid')
		if teams[teamid] and countPlayersInTeam(teams[teamid]) < 2 then
			destroyElement ( teams[teamid] )
			teams[teamid] = nil
		end
		setPlayerTeam(player, nil)
		playerteams[player] = nil
		return
	end
	local r = result[1]
	
	local tr, tg, tb = getColorFromString(r.colour)
	if not teams[r.teamid] then
		teams[r.teamid] = createTeam(r.tag .. ' ' .. r.name, tr, tg, tb)
		setElementData(teams[r.teamid], 'gcshop.teamid', r.teamid)
		setElementData(teams[r.teamid], 'gcshop.owner', r.owner)
	end
	if exports.race:getRaceMode() ~= "Capture the flag" then
		setPlayerTeam(player, teams[r.teamid])
	end
	playerteams[player] = r.teamid
	if r.message then
		outputChatBox(r.message, player, tr, tg, tb, true)
	end
end

function invite(sender, c, playername)
	local ownerid = tonumber(exports.gc:getPlayerForumID ( sender ))
	if not ownerid then return end
	
	-- Check if the player exists
	local player = getPlayerFromName(playername)
	if not player then
		return outputChatBox('[TEAMS] Could not find ' .. tostring(playername) .. ', please type the full nickname', sender, 0,255,0)
	elseif not tonumber(exports.gc:getPlayerForumID ( player )) then
		return outputChatBox('[TEAMS] ' .. tostring(playername) .. ' is not logged in to GC', sender, 0,255,0)
	end
	
	-- Check if it's the owner
	if not (playerteams[sender] and teams[playerteams[sender]] and getElementData(teams[playerteams[sender]], 'gcshop.owner') == ownerid) then
		return outputChatBox('Only team owners can send invites!', sender, 255,0,0)
	end
	
	outputChatBox('[TEAMS] You invited ' .. getPlayerName(player), sender, 0,255,0)
	outputChatBox('[TEAMS] ' .. getPlayerName(sender) .. ' has sent you an invite to join his team: ' .. tostring(getTeamName(teams[playerteams[sender]])), player, 0,255,0)
	outputChatBox('[TEAMS] Type /accept to join his team', player, 0,255,0)
	invites[player] = {playerteams[sender], sender}
end
addCommandHandler('invite', invite)

function accept(player)
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	if not invites[player] then
		return outputChatBox('[TEAMS] You are not invited to any teams!', player, 0,255,0)
	elseif not forumID then
		return outputChatBox('[TEAMS] You are not logged in to GC', sender, 0,255,0)
	end
	
	outputChatBox('[TEAMS] You accepted the invite', player, 0,255,0)
	if isElement(invites[player][2]) then
		outputChatBox('[TEAMS] ' .. getPlayerName(player) .. ' accepted the invite', invites[player][2], 0,255,0)
	end
	addPlayerToTeamDatabase ( forumID, invites[player][1] )
	checkPlayerTeam ( player )
	invites[player] = nil
end
addCommandHandler('accept', accept)

function leave(player)
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	if not forumID then
		return outputChatBox('[TEAMS] You are not logged in to GC', sender, 0,255,0)
	end
	
	outputChatBox('[TEAMS] You left your team', player, 0,255,0)
	dbExec(handlerConnect, [[UPDATE `team_members` SET `status`=0 WHERE `forumid`=?]], forumID)
	checkPlayerTeam ( player )
end
addCommandHandler('leave', leave)

local _getPlayerName = getPlayerName
local function getPlayerName(player)
	return string.gsub(_getPlayerName(player),"#%x%x%x%x%x%x","")
end

local _getPlayerFromName = getPlayerFromName
local function getPlayerFromName ( name )
	if type(name) ~= 'string' then return false end
	
	for k,v in ipairs(getElementsByType'player') do
		if string.lower(getPlayerName(v)) == string.lower(name) then
			return v
		end
	end
	return false
end
