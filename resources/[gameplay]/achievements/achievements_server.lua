--MySQL tables
local achsTableMix = 'achievements'
local achsTableRace = 'achievements_race'

allAchievementsMix = {}
allAchievementsRace = {}

local achievements_race_sql = [[CREATE TABLE IF NOT EXISTS `achievements_race` (
	`forumID` INT(11) NOT NULL,
	`achievementID` INT(11) NOT NULL,
	`unlockedDate` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`unlocked` TINYINT(1) NOT NULL DEFAULT '0',
	`progress` INT(10) UNSIGNED NULL DEFAULT NULL,
	PRIMARY KEY (`forumID`,`achievementID`)
)
]]

function onStart()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))
	if not handlerConnect then
		return outputDebugString('achievements: could not connect to the mysql db')
	end
	queryAchievementsAll()
	
	
	-- Create tables if they don't exist yet on shop start
	dbExec ( handlerConnect, achievements_race_sql )
end
addEventHandler('onResourceStart', resourceRoot, onStart)

function gcLogin ( forumID, amount )
	getAchievements( { forumID } )
end
addEventHandler("onGCLogin" , root, gcLogin )

function gcLogout ( forumID )
	allAchievementsMix[forumID] = nil
	allAchievementsRace[forumID] = nil
end
addEventHandler("onGCLogout" , root, gcLogout )

function onClientGUI ()
	triggerClientEvent( client, 'showAchievementsGUI', resourceRoot, achievementListMix, getPlayerAchievementsMix ( client ), achievementListRace, getPlayerAchievementsRace ( client ) )
end
addEvent('onAchievementsBoxLoad', true)
addEventHandler('onAchievementsBoxLoad', resourceRoot, onClientGUI)

function queryAchievementsAll()
	local resGC = getResourceFromName'gc'
	if not resGC or getResourceState ( resGC ) ~= 'running' then return false end
	
	local forumids = {}
	for _, player in ipairs(getElementsByType'player') do 
		local forumID = exports.gc:getPlayerForumID ( player )
		if forumID then
			table.insert(forumids, forumID)
		end
	end
	if #forumids > 0 then
		getAchievements ( forumids )
	end
end

function getAchievements ( forumids )
	if not handlerConnect then return end
	forumids = table.concat(forumids, ',')
	local qhMix = dbQuery ( 
		function(qh) 
			local resultsMix = dbPoll ( qh, 0 )
			if resultsMix and #resultsMix > 0 then
				for _, row in ipairs(resultsMix) do
					local ach = getAchievementMix ( row.achievementID )
					-- outputDebugString(string.format('%d %s %d %d / %d %s' , row.forumID, ach.s, row.unlocked, row.progress or 0, ach.max or 0, row.unlockedDate ) )
					if not allAchievementsMix[row.forumID] then allAchievementsMix[row.forumID] = {} end
					allAchievementsMix[row.forumID][row.achievementID] = row
				end
			end
		end, handlerConnect, "SELECT * FROM `??` WHERE forumID IN (??)", achsTableMix, forumids)
	
	local qhRace = dbQuery ( 
		function(qh) 
			local resultsRace = dbPoll ( qh, 0 )
			if resultsRace and #resultsRace > 0 then
				for _, row in ipairs(resultsRace) do
					local ach = getAchievementRace ( row.achievementID )
					-- outputDebugString(string.format('%d %s %d %d / %d %s' , row.forumID, ach.s, row.unlocked, row.progress or 0, ach.max or 0, row.unlockedDate ) )
					if not allAchievementsRace[row.forumID] then allAchievementsRace[row.forumID] = {} end
					allAchievementsRace[row.forumID][row.achievementID] = row
				end
			end
		end, handlerConnect, "SELECT * FROM `??` WHERE forumID IN (??)", achsTableRace, forumids)	
end


-- checkPlayerMix, returns true if the player can unlock the achievement, false if not logged in or already unlocked
function checkPlayerMix (player, achID)
	local resGC = getResourceFromName'gc'
	if not handlerConnect or not resGC or getResourceState ( resGC ) ~= 'running' then return false end
	
	if not exports.gc:isPlayerLoggedInGC ( player ) then return false end
	
	local playerAchievementsMix = getPlayerAchievementsMix ( player )
		
	return not playerAchievementsMix[achID] or playerAchievementsMix[achID].unlocked ~= 1
end

-- checkPlayerRace, returns true if the player can unlock the achievement, false if not logged in or already unlocked
function checkPlayerRace (player, achID)
	local resGC = getResourceFromName'gc'
	if not handlerConnect or not resGC or getResourceState ( resGC ) ~= 'running' then return false end
	
	if not exports.gc:isPlayerLoggedInGC ( player ) then return false end
	
	local playerAchievementsRace = getPlayerAchievementsRace ( player )
		
	return not playerAchievementsRace[achID] or playerAchievementsRace[achID].unlocked ~= 1
end


function getPlayerAchievementsMix ( player )
	return allAchievementsMix[exports.gc:getPlayerForumID ( player )] or {}
end

function getPlayerAchievementsRace ( player )
	return allAchievementsRace[exports.gc:getPlayerForumID ( player )] or {}
end


function addPlayerAchievementMix ( player, achID )
	if isMapTesting() or not checkPlayerMix (player, achID) then return end

	local ach = getAchievementMix ( achID )
	local forumID = exports.gc:getPlayerForumID ( player )
	local query = "INSERT INTO `??` (forumID, achievementID, unlocked) VALUES (?,?,?)"
	dbExec ( handlerConnect, query, achsTableMix, forumID, achID, 1 )
	outputChatBox( getPlayerName(player):gsub("#%x%x%x%x%x%x", "") .. " has unlocked the achievement: " .. ach.s, root, 255, 0, 0)
	exports.gc:addPlayerGreencoins(player, ach.reward)
	getAchievements( { forumID } )
end

function addPlayerAchievementRace ( player, achID )
	if isMapTesting() or not checkPlayerRace (player, achID) then return end
	local count = getPlayerCount()
	if count < 5 then return end

	local ach = getAchievementRace ( achID )
	local forumID = exports.gc:getPlayerForumID ( player )
	local query = "INSERT INTO `??` (forumID, achievementID, unlocked) VALUES (?,?,?)"
	dbExec ( handlerConnect, query, achsTableRace, forumID, achID, 1 )
	outputChatBox( getPlayerName(player):gsub("#%x%x%x%x%x%x", "") .. " has unlocked the achievement: " .. ach.s, root, 255, 0, 0)
	exports.gc:addPlayerGreencoins(player, ach.reward)
	getAchievements( { forumID } )
end


function addAchievementProgressMix ( players, achID, progress )		-- expects checkPlayerMix is done beforehand
	if type(players) ~= 'table' then players = {players} end
	if isMapTesting() or #players < 1 then return end
	local progressForumidsMix, unlockedForumidsMix, forumids = {}, {}, {}
	local ach = getAchievementMix ( achID )
	local maxProgress = ach.max
	for _, player in ipairs(players) do
		if checkPlayerMix (player, achID) then
			local forumID = exports.gc:getPlayerForumID(player)
			table.insert ( forumids, forumID )
			local playerAch = allAchievementsMix[forumID] and allAchievementsMix[forumID][achID] or false
			if (playerAch and playerAch.progress + progress >= maxProgress) or (progress >= maxProgress) then
				table.insert ( unlockedForumidsMix, string.format('(%d,%d,1,%d)', forumID, achID, maxProgress) )
				outputChatBox( getPlayerName(player):gsub("#%x%x%x%x%x%x", "") .. " has unlocked the achievement: " .. ach.s, root, 255, 0, 0)
				exports.gc:addPlayerGreencoins(player, ach.reward)
			else
				table.insert ( progressForumidsMix, string.format('(%d,%d,0,%d)', forumID, achID, progress) )
			end
		end
	end
	if (#progressForumidsMix > 0) then
		progressForumidsMix = table.concat ( progressForumidsMix, ',' )
		-- outputDebugString ( 'PROGRESS ' .. progressForumidsMix )
		local progressQuery = "INSERT INTO `??` (forumID, achievementID, unlocked, progress) VALUES ?? ON DUPLICATE KEY UPDATE progress = progress + ?"
		-- outputDebugString ( 'PROGRESS ' .. progressQuery )
		dbExec ( handlerConnect, progressQuery, achsTableMix, progressForumidsMix, progress )
	end
	if (#unlockedForumidsMix > 0) then
		unlockedForumidsMix = table.concat ( unlockedForumidsMix, ',' )
		-- outputDebugString ( 'PROGRESS ' .. unlockedForumidsMix )
		local unlockedQuery = "INSERT INTO `??` (forumID, achievementID, unlocked, progress) VALUES ?? ON DUPLICATE KEY UPDATE unlocked = 1, progress = ?"
		-- outputDebugString ( 'UNLOCK ' .. unlockedQuery )
		dbExec ( handlerConnect, unlockedQuery, achsTableMix, unlockedForumidsMix, maxProgress )
	end
	if #forumids > 0 then
		getAchievements ( forumids )
	end
end

local achsMix = {}
function getAchievementMix ( achID )
	if achsMix[achID] then return achsMix[achID] end
	for k,achMix in ipairs(achievementListMix) do
		if achMix.id == achID then
			achsMix[achID] = achMix
			return achMix
		end
	end
	return false
end

local achsRace = {}
function getAchievementRace ( achID )
	if achsRace[achID] then return achsRace[achID] end
	for k,achRace in ipairs(achievementListRace) do
		if achRace.id == achID then
			achsRace[achID] = achRace
			return achRace
		end
	end
	return false
end

function isMapTesting()
	return getResourceInfo(exports.mapmanager:getRunningGamemodeMap(), 'newupload') == "true"
end


function addOrRemoveAchievement (player, command, server, forumID, achID)
	if not forumID or not server or not achID then return outputChatBox("Syntax: /addach ['race' or 'mix'] [forumID] [achID] /removeach ['race' or 'mix'] [forumID] [achID]", player, 255, 0, 0) end
	if not isObjectInACLGroup ("user."..getAccountName( getPlayerAccount( player ) ), aclGetGroup ( "ServerManager" )) then return end
	
	if server == "race" then
		sqlTable = achsTableRace
	elseif server == "mix" then
		sqlTable = achsTableMix
	end
	
	if command == "addach" then
		exec = dbExec ( handlerConnect, "INSERT INTO `??` (forumID, achievementID, unlocked) VALUES (?,?,?)", sqlTable, forumID, achID, 1)
		unique_text = "added to a"
	elseif command == "removeach"  then
		exec = dbExec ( handlerConnect, "DELETE FROM `??` WHERE forumID = ? and achievementID = ?", sqlTable, forumID, achID)
		unique_text = "removed from a"
	end	
	
	if exec then 
		outputChatBox(server.." achievement with ID "..achID.." was succesfully "..unique_text.." player with forum ID "..forumID, player, 0, 255, 0)
		getAchievements( { forumID } )
	end
end
addCommandHandler("addach", addOrRemoveAchievement)
addCommandHandler("removeach", addOrRemoveAchievement)