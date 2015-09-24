local achsTable = 'achievements'

allAchievements = {}


function onStart()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname", get("*gcshop.user"), get("*gcshop.pass"))
	if not handlerConnect then
		return outputDebugString('race_achs: could not connect to the mysql db')
	end
	queryAchievementsAll()
end
addEventHandler('onResourceStart', resourceRoot, onStart)

function gcLogin ( forumID, amount )
	getAchievements ( { forumID } )
end
addEventHandler("onGCLogin" , root, gcLogin )

function gcLogout ( forumID )
	allAchievements[forumID] = nil
end
addEventHandler("onGCLogout" , root, gcLogout )

function onClientGUI ()
	triggerClientEvent(client, 'showAchievementsGUI', resourceRoot, achievementList, getPlayerAchievements ( client ) )
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
	local qh = dbQuery ( handlerConnect, "SELECT * FROM `??` WHERE forumID IN (??)", achsTable, forumids)
	local results = dbPoll ( qh, -1 )
	if results and #results > 0 then
		for _, row in ipairs(results) do
			local ach = getAchievement ( row.achievementID )
			-- outputDebugString(string.format('%d %s %d %d / %d %s' , row.forumID, ach.s, row.unlocked, row.progress or 0, ach.max or 0, row.unlockedDate ) )
			if not allAchievements[row.forumID] then allAchievements[row.forumID] = {} end
			allAchievements[row.forumID][row.achievementID] = row
		end
	end
end




-- checkplayer, returns true if the player can unlock the achievement, false if not logged in or already unlocked
function checkPlayer (player, achID)
	local resGC = getResourceFromName'gc'
	if not handlerConnect or not resGC or getResourceState ( resGC ) ~= 'running' then return false end
	
	if not exports.gc:isPlayerLoggedInGC ( player ) then return false end
	
	local playerAchievements = getPlayerAchievements ( player )
		
	return not playerAchievements[achID] or playerAchievements[achID].unlocked ~= 1
end

function getPlayerAchievements ( player )
	return allAchievements[exports.gc:getPlayerForumID ( player )] or {}
end


function addPlayerAchievement ( player, achID )
	if isMapTesting() or not checkPlayer (player, achID) then return end

	local ach = getAchievement ( achID )
	local forumID = exports.gc:getPlayerForumID ( player )
	local query = "INSERT INTO `??` (forumID, achievementID, unlocked) VALUES (?,?,?)"
	dbExec ( handlerConnect, query, achsTable, forumID, achID, 1 )
	outputChatBox( getPlayerName(player):gsub("#%x%x%x%x%x%x", "") .. " has unlocked the achievement: " .. ach.s, root, 255, 0, 0)
	exports.gc:addPlayerGreencoins(player, ach.reward)
	getAchievements ( { forumID } )
end


function addAchievementProgress ( players, achID, progress )		-- expects checkplayer is done beforehand
	if type(players) ~= 'table' then players = {players} end
	if isMapTesting() or #players < 1 then return end
	local progressForumids, unlockedForumids, forumids = {}, {}, {}
	local ach = getAchievement ( achID )
	local maxProgress = ach.max
	for _, player in ipairs(players) do
		if checkPlayer (player, achID) then
			local forumID = exports.gc:getPlayerForumID(player)
			table.insert ( forumids, forumID )
			local playerAch = allAchievements[forumID] and allAchievements[forumID][achID] or false
			if (playerAch and playerAch.progress + progress >= maxProgress) or (progress >= maxProgress) then
				table.insert ( unlockedForumids, string.format('(%d,%d,1,%d)', forumID, achID, maxProgress) )
				outputChatBox( getPlayerName(player):gsub("#%x%x%x%x%x%x", "") .. " has unlocked the achievement: " .. ach.s, root, 255, 0, 0)
				exports.gc:addPlayerGreencoins(player, ach.reward)
			else
				table.insert ( progressForumids, string.format('(%d,%d,0,%d)', forumID, achID, progress) )
			end
		end
	end
	if (#progressForumids > 0) then
		progressForumids = table.concat ( progressForumids, ',' )
		-- outputDebugString ( 'PROGRESS ' .. progressForumids )
		local progressQuery = "INSERT INTO `??` (forumID, achievementID, unlocked, progress) VALUES ?? ON DUPLICATE KEY UPDATE progress = progress + ?"
		-- outputDebugString ( 'PROGRESS ' .. progressQuery )
		dbExec ( handlerConnect, progressQuery, achsTable, progressForumids, progress )
	end
	if (#unlockedForumids > 0) then
		unlockedForumids = table.concat ( unlockedForumids, ',' )
		-- outputDebugString ( 'PROGRESS ' .. unlockedForumids )
		local unlockedQuery = "INSERT INTO `??` (forumID, achievementID, unlocked, progress) VALUES ?? ON DUPLICATE KEY UPDATE unlocked = 1, progress = ?"
		-- outputDebugString ( 'UNLOCK ' .. unlockedQuery )
		dbExec ( handlerConnect, unlockedQuery, achsTable, unlockedForumids, maxProgress )
	end
	if #forumids > 0 then
		getAchievements ( forumids )
	end
end

local achs = {}
function getAchievement ( achID )
	if achs[achID] then return achs[achID] end
	for k,ach in ipairs(achievementList) do
		if ach.id == achID then
			achs[achID] = ach
			return ach
		end
	end
	return false
end

function isMapTesting()
	return getResourceInfo(exports.mapmanager:getRunningGamemodeMap(), 'newupload') == "true"
end