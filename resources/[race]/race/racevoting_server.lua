--UPDATE 6th December 2011
--NEW SETTING--
--Number of play agains allowed consecutively!
local maxPlayAgain = 2
---
---------------
g_MapInfoList = {}



--
-- racemidvote_server.lua
--
-- Mid-race random map vote and
-- NextMapVote handled in this file
--





local lastVoteStarterName = ''
local lastVoteStarterCount = 0

----------------------------------------------------------------------------
-- displayHilariarseMessage
--
-- Comedy gold
----------------------------------------------------------------------------
function displayHilariarseMessage( player )
	if not player then
		lastVoteStarterName = ''
	else
		local playerName = getPlayerName(player)
		local msg = ''
		if playerName == lastVoteStarterName then
			lastVoteStarterCount = lastVoteStarterCount + 1
			if lastVoteStarterCount == 5 then
				msg = playerName .. ' started a vote. Hardly a suprise.'
			elseif lastVoteStarterCount == 10 then
				msg = 'Guess what! '..playerName .. ' started ANOTHER vote!'
			elseif lastVoteStarterCount < 5 then
				msg = playerName .. ' started another vote.'
			else
				msg = playerName .. ' continues to abuse the vote system.'
			end
		else
			lastVoteStarterCount = 0
			lastVoteStarterName = playerName
			msg = playerName .. ' started a vote.'
		end
		outputRace( msg )
	end
end


----------------------------------------------------------------------------
-- displayKillerPunchLine
--
-- Sewing kits available in the foyer
----------------------------------------------------------------------------
function displayKillerPunchLine( player )
	if lastVoteStarterName ~= '' then
		outputRace( 'Offical news: Everybody hates ' .. lastVoteStarterName )
	end
end


----------------------------------------------------------------------------
-- startMidMapVoteForRandomMap
--
-- Start the vote menu if during a race and more than 30 seconds from the end
-- No messages if this was not started by a player
----------------------------------------------------------------------------
function startMidMapVoteForRandomMap(player)

	-- Check state and race time left
	-- if not stateAllowsRandomMapVote() or g_CurrentRaceMode:getTimeRemaining() < 30000 then
	if (not stateAllowsRandomMapVote()) or (not isPlayerInACLGroup(player, g_GameOptions.admingroup)) then
		if player then
			outputRace( "I'm afraid I can't let you do that, " .. getPlayerName(player) .. ".", player )
		end 
		return
	end

	displayHilariarseMessage( player )
	exports.votemanager:stopPoll()

	-- Actual vote started here
	local pollDidStart = exports.votemanager:startPoll {
			title='Do you want to change to a random map?',
			percentage=51,
			timeout=15,
			allowchange=true,
			visibleTo=getRootElement(),
			[1]={'Yes', 'midMapVoteResult', getRootElement(), true},
			[2]={'No', 'midMapVoteResult', getRootElement(), false;default=true},
	}

	-- Change state if vote did start
	if pollDidStart then
		gotoState('MidMapVote')
	end

end
addCommandHandler('new',startMidMapVoteForRandomMap, true, true)


----------------------------------------------------------------------------
-- event midMapVoteResult
--
-- Called from the votemanager when the poll has completed
----------------------------------------------------------------------------
addEvent('midMapVoteResult')
addEventHandler('midMapVoteResult', getRootElement(),
	function( votedYes )
		-- Change state back
		if stateAllowsRandomMapVoteResult() then
			gotoState('Running')
			if votedYes then
				startRandomMap()
			else
				displayKillerPunchLine()
			end
		end
	end
)



----------------------------------------------------------------------------
-- startRandomMap
--
-- Changes the current map to a random race map
----------------------------------------------------------------------------
function startRandomMap()

	-- Handle forced nextmap setting
	if maybeApplyForcedNextMap() then
		return
	end

	-- Get a random map chosen from the 10% of least recently player maps, with enough spawn points for all the players (if required)
	-- local map = getRandomMapCompatibleWithGamemode( getThisResource(), 10, g_GameOptions.ghostmode and 0 or getTotalPlayerCount() )
	local map = getRandomMapCompatibleWithGamemode( getThisResource(), 10, g_GameOptions.ghostmode and 0 or getTotalPlayerCount(), false, modes[currentmode] )
	if map then
		g_IgnoreSpawnCountProblems = map	-- Uber hack 4000
		if not exports.mapmanager:changeGamemodeMap ( map, nil, true ) then
			problemChangingMap()
		end
	currentmode = currentmode + 1
	if currentmode > #modes then currentmode = 1 end
	else
		outputWarning( 'startRandomMap failed' )
	end
end


----------------------------------------------------------------------------
-- outputRace
--
-- Race color is defined in the settings
----------------------------------------------------------------------------
function outputRace(message, toElement)
	toElement = toElement or g_Root
	local r, g, b = getColorFromString(string.upper(get("color")))
	if getElementType(toElement) == 'console' then
		outputServerLog(message)
	else
		if toElement == rootElement then
			outputServerLog(message)
		end
		if getElementType(toElement) == 'player' then
			message = '[PM] ' .. message
		end
		outputChatBox(message, toElement, r, g, b)
	end
end


----------------------------------------------------------------------------
-- problemChangingMap
--
-- Sort it
----------------------------------------------------------------------------
function problemChangingMap()
	outputRace( 'Changing to random map in 5 seconds' )
	local currentMap = exports.mapmanager:getRunningGamemodeMap()
	TimerManager.createTimerFor("resource","mapproblem"):setTimer(
        function()
			-- Check that something else hasn't already changed the map
			if currentMap == exports.mapmanager:getRunningGamemodeMap() then
	            startRandomMap()
			end
        end,
        math.random(4500,5500), 1 )
end



--
--
-- NextMapVote
--
--
--

local g_Poll

----------------------------------------------------------------------------
-- startNextMapVote
--
-- Start a votemap for the next map. Should only be called during the
-- race state 'NextMapSelect'
----------------------------------------------------------------------------
bintest = false
addCommandHandler('debugracevote',
function(player)
	if getPlayerName(player) == 'BinSlayer' then
		bintest = not bintest
	end	
end
)


function startNextMapVote()

	exports.votemanager:stopPoll()

	-- Handle forced nextmap setting
	if maybeApplyForcedNextMap() then
		return
	end

	
	local poll = {
		title="Next or Play again?",
		visibleTo=getRootElement(),
		percentage=51,
		timeout=7,
		allowchange=true;
		}
	
	local setEventMapQueue = false
	local usedGcMapQueue = false

	if getResourceFromName('eventmanager') and getResourceState(getResourceFromName('eventmanager')) == 'running' and exports.eventmanager:isAnyMapQueued(true) then
		-- Event next queued map
		-- [1] = mapResName, [2] = eventname
		local map = exports.eventmanager:getCurrentMapQueued(true)
		local mapRes = getResourceFromName(map[1])
		if mapRes then
			local mapName = getResourceInfo(mapRes, "name") or getResourceName(mapRes)
			local mapName = "["..map[2].."] "..mapName

			table.insert(poll, {mapName , 'nextMapVoteResult', getRootElement(), mapRes, "eventmanager", map[2]})
			setEventMapQueue = true
		else-- normal next map
			local mapName = getResourceInfo(_nextMap, "name") or getResourceName(_nextMap)
			table.insert(poll, {mapName , 'nextMapVoteResult', getRootElement(), _nextMap})
		end
	elseif getResourceFromName('gcshop') and getResourceState(getResourceFromName('gcshop')) == 'running' and exports.gcshop:isAnyMapQueued(true) and skipMapQueue ~= exports.mapmanager:getRunningGamemodeMap() then
		-- GCshop next queued map
		-- [1] = mapName, [2] = mapResName, [3] = gamemode, [4] = playername
		local map = exports.gcshop:getCurrentMapQueued(true)
		local mapRes = getResourceFromName(map[2])
		if map and mapRes then
			local mapName = getResourceInfo(mapRes, "name") or getResourceName(mapRes)
			local mapName = "[Maps-Center] "..mapName

			table.insert(poll, {mapName , 'nextMapVoteResult', getRootElement(), mapRes,"gcshop",map[4]})
			usedGcMapQueue = true
		else-- normal next map
			local mapName = getResourceInfo(_nextMap, "name") or getResourceName(_nextMap)
			table.insert(poll, {mapName , 'nextMapVoteResult', getRootElement(), _nextMap})
		end
	else -- Normal next map
		local mapName = getResourceInfo(_nextMap, "name") or getResourceName(_nextMap)
			table.insert(poll, {mapName , 'nextMapVoteResult', getRootElement(), _nextMap})
	end
	
	
	local currentMap = exports.mapmanager:getRunningGamemodeMap()
	local currentRes = currentMap
	if currentMap then
		if not times[currentMap] or times[currentMap] < maxPlayAgain+1 then
			table.insert(poll, {"Play again", 'nextMapVoteResult', getRootElement(), currentMap})
		elseif setEventMapQueue then -- Start event manager map
			outputChatBox('Maximum \'Play Again\' times('..maxPlayAgain..') has been reached. Changing to next event map ..')
			
			local map = exports.eventmanager:getCurrentMapQueued()
			if not exports.mapmanager:changeGamemodeMap ( getResourceFromName(map[1]), nil, true ) then
				outputWarning( 'Forced next map failed' )
				startRandomMap()
			else
				outputChatBox("["..map[2].."] Starting next map", root, 0, 255, 0)
			end
			return
		elseif usedGcMapQueue then -- Start GC mapcenter map
			outputChatBox('Maximum \'Play Again\' times('..maxPlayAgain..') has been reached. Changing to next map in Maps-Center queue ..')
			
			local map = exports.gcshop:getCurrentMapQueued()
			if not exports.mapmanager:changeGamemodeMap ( getResourceFromName(map[2]), nil, true ) then
				outputWarning( 'Forced next map failed' )
				startRandomMap()
			else
				outputChatBox("[Maps-Center] Starting queued map for " .. map[4]:gsub( '#%x%x%x%x%x%x', '' ), root, 0, 255, 0)
			end
			skipMapQueue = getResourceFromName(map[2])
			return
		else
			outputChatBox('Maximum \'Play Again\' times('..maxPlayAgain..') has been reached. Changing to random ..')
			startRandomMap()
			return
		end	
	end

	-- Allow addons to modify the poll
	g_Poll = poll
	triggerEvent('onPollStarting', g_Root, poll )
	poll = g_Poll
	g_Poll = nil

	local pollDidStart = exports.votemanager:startPoll(poll)

	if pollDidStart then
		gotoState('NextMapVote')
		addEventHandler("onPollEnd", getRootElement(), chooseRandomMap)
	end

	return pollDidStart
end

modes = {
        [1]='rtf',
        [2]='nts',
        [3]='ctf',
        [4]='shooter',
        [5]='race',
}
math.randomseed( getTickCount() % 50000 )
currentmode = math.random(#modes)

function calculateNextmap()
	-- local chance = math.random(1,6)
	local compatibleMaps
	-- if chance == 2 or chance == 4 then
		-- compatibleMaps =  getRandomMapCompatibleWithGamemode( getThisResource(), 1, 0 ) 
	-- else
		-- if getResourceFromName('race_mapratings') and getResourceState(getResourceFromName('race_mapratings')) == 'running' and exports.race_mapratings then
			-- compatibleMaps =  getRandomMapCompatibleWithGamemode( getThisResource(), 1, 0, false, modes[currentmode] )   --add a new parametr to specify we want the best rated maps
		-- else
			compatibleMaps =  getRandomMapCompatibleWithGamemode( getThisResource(), 1, 0, false, modes[currentmode] ) 
		-- end	
	-- end
	if compatibleMaps then
		triggerEvent('onNextmapSettingChange', root, compatibleMaps)
		return compatibleMaps
	else
		currentmode = currentmode + 1
		if currentmode > #modes then
			currentmode = 1
		end
		return calculateNextmap()
	end
end
addEvent('onNextmapSettingChange', true)




times = {}
local lastPlayed 
addEvent('onMapStarting', true)
addEventHandler('onMapStarting', getRootElement(),
function()
	g_ForcedNextMap = nil
	local currentMap = exports.mapmanager:getRunningGamemodeMap()
	if lastPlayed ~= currentMap then
		if lastPlayed == skipMapQueue then
			skipMapQueue = false
		end
		-- New map, reset again counter
		times[currentMap] = 0
		if lastPlayed then times[lastPlayed] = nil end
		lastPlayed = currentMap
	end
	_nextMap = calculateNextmap()
	times[currentMap] = times[currentMap] + 1

	triggerEvent("onRoundCountChange",root,times[currentMap],maxPlayAgain)
end
)



--[[ debugging purposes
addCommandHandler('view',
function()
	for _, k in pairs(times) do 
		outputChatBox(tostring(_)..' '..tostring(k))
	end
end
)]]

-- Used by addons in response to onPollStarting
addEvent('onPollModified')
addEventHandler('onPollModified', getRootElement(),
	function( poll )
		g_Poll = poll
	end
)


function chooseRandomMap (chosen)
	if not chosen then
		cancelEvent()
		math.randomseed(getTickCount())
		exports.votemanager:finishPoll(1)
	end
	removeEventHandler("onPollEnd", getRootElement(), chooseRandomMap)
end



----------------------------------------------------------------------------
-- event nextMapVoteResult
--
-- Called from the votemanager when the poll has completed
----------------------------------------------------------------------------
addEvent('nextMapVoteResult')
addEventHandler('nextMapVoteResult', getRootElement(),
	function( map, category, var )
		if stateAllowsNextMapVoteResult() then
			if not category then 
				if not exports.mapmanager:changeGamemodeMap ( map, nil, true ) then
					problemChangingMap()
				elseif lastPlayed ~= map then
					currentmode = currentmode + 1
					if currentmode > #modes then currentmode = 1 end
					-- outputDebugString('Next mode ' .. modes[currentmode] .. ' ' .. currentmode)
				end
			elseif category == "eventmanager" then -- var = Event name
				exports.eventmanager:getCurrentMapQueued()
				
				if not exports.mapmanager:changeGamemodeMap ( map, nil, true ) then
					problemChangingMap()
				else
					outputChatBox("["..var.."] Starting next map", root, 0, 255, 0)
				end
			elseif category == "gcshop" then -- var =  Mapcenter buyer
				exports.gcshop:getCurrentMapQueued() -- Removes from queue

				if not exports.mapmanager:changeGamemodeMap ( map, nil, true ) then
					problemChangingMap()
				else
					outputChatBox("[Maps-Center] Starting queued map for " .. var:gsub( '#%x%x%x%x%x%x', '' ), root, 0, 255, 0)
				end
				skipMapQueue = map
			end
		end
	end
)



----------------------------------------------------------------------------
-- startMidMapVoteForRestartMap
--
-- Start the vote menu to restart the current map if during a race
-- No messages if this was not started by a player
----------------------------------------------------------------------------
function startMidMapVoteForRestartMap(player)

	-- Check state and race time left
	if (not stateAllowsRestartMapVote()) or (not isPlayerInACLGroup(player, g_GameOptions.admingroup)) then
		if player then
			outputRace( "I'm afraid I can't let you do that, " .. getPlayerName(player) .. ".", player )
		end 
		return
	end

	displayHilariarseMessage( player )
	exports.votemanager:stopPoll()

	-- Actual vote started here
	local pollDidStart = exports.votemanager:startPoll {
			title='Do you want to restart the current map?',
			percentage=51,
			timeout=15,
			allowchange=true,
			visibleTo=getRootElement(),
			[1]={'Yes', 'midMapRestartVoteResult', getRootElement(), true},
			[2]={'No', 'midMapRestartVoteResult', getRootElement(), false;default=true},
	}

	-- Change state if vote did start
	if pollDidStart then
		gotoState('MidMapVote')
	end

end
addCommandHandler('voteredo',startMidMapVoteForRestartMap)


----------------------------------------------------------------------------
-- event midMapRestartVoteResult
--
-- Called from the votemanager when the poll has completed
----------------------------------------------------------------------------
addEvent('midMapRestartVoteResult')
addEventHandler('midMapRestartVoteResult', getRootElement(),
	function( votedYes )
		-- Change state back
		if stateAllowsRandomMapVoteResult() then
			gotoState('Running')
			if votedYes then
				if not exports.mapmanager:changeGamemodeMap ( exports.mapmanager:getRunningGamemodeMap(), nil, true ) then
					problemChangingMap()
				end
			else
				displayKillerPunchLine()
			end
		end
	end
)

addCommandHandler('redo',
	function( player, command, value )
		if isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			local currentMap = exports.mapmanager:getRunningGamemodeMap()
			if currentMap then
				outputChatBox('Map restarted by ' .. getPlayerName(player), g_Root, 0, 240, 0)
				if not exports.mapmanager:changeGamemodeMap (currentMap, nil, true) then
					problemChangingMap()
				end
			else
				outputRace("You can't restart the map because no map is running", player)
			end
		else
			outputRace("You are not an Admin", player)
		end
	end
)


addCommandHandler('random',
	function( player, command, value )
		if isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			-- if not stateAllowsRandomMapVote() or g_CurrentRaceMode:getTimeRemaining() < 1000 then
			local choice = {'curtailed', 'cut short', 'terminated', 'given the heave ho', 'dropkicked', 'expunged', 'put out of our misery', 'got rid of'}
			outputChatBox('Current map ' .. choice[math.random( 1, #choice )] .. ' by ' .. getPlayerName(player), g_Root, 0, 240, 0)
			startRandomMap()
		
		end
	end
)


----------------------------------------------------------------------------
-- maybeApplyForcedNextMap
--
-- Returns true if nextmap did override
----------------------------------------------------------------------------
function maybeApplyForcedNextMap()
	if g_ForcedNextMap then
		local map = g_ForcedNextMap
		g_ForcedNextMap = nil
		g_IgnoreSpawnCountProblems = map	-- Uber hack 4000
		if not exports.mapmanager:changeGamemodeMap ( map, nil, true ) then
			outputWarning( 'Forced next map failed' )
			return false
		end
		return true
	-- elseif getResourceFromName('gcshop') and getResourceState(getResourceFromName('gcshop')) == 'running' and exports.gcshop:isAnyMapQueued() and skipMapQueue ~= exports.mapmanager:getRunningGamemodeMap() then
	-- 	local map = exports.gcshop:getCurrentMapQueued()
	-- 	if not exports.mapmanager:changeGamemodeMap ( getResourceFromName(map[2]), nil, true ) then
	-- 		outputWarning( 'Forced next map failed' )
	-- 		return false
	-- 	else
	-- 		outputChatBox("[Maps-Center] Starting queued map for " .. map[4], root, 0, 255, 0)
	-- 	end
	-- 	skipMapQueue = getResourceFromName(map[2])
	-- 	return true
	end
	return false
end

---------------------------------------------------------------------------
--
-- Testing
--
--
--
---------------------------------------------------------------------------
addCommandHandler('forcevote',
	function( player, command, value )
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
		startNextMapVote()
	end
)


---------------------------------------------------------------------------
--
-- getRandomMapCompatibleWithGamemode 
--
-- This should go in mapmanager, but ACL needs doing
--
---------------------------------------------------------------------------

addEventHandler('onResourceStart', getRootElement(),
	function( res )
		if getResourceState(getResourceFromName'mapmanager') == 'running' and exports.mapmanager:isMap( res ) then
			if not g_MapInfoList[res] then
				g_MapInfoList[res] = {}
			end
			--setMapLastTimePlayed( res )
		end
	end
)

addEventHandler('onResourceStop', getRootElement(),
	function( res )
		if getResourceState(getResourceFromName'mapmanager') == 'running' and exports.mapmanager:isMap( res ) then
			setMapLastTimePlayed( res )
		end
	end
)



function getRandomMapCompatibleWithGamemode( gamemode, oldestPercentage, minSpawnCount, bestRated, nextmode )
	oldestPercentage = 4   --TEST to get more maps @ cutoff
	-- Get all relevant maps	
	local compatibleMaps = exports.mapmanager:getMapsCompatibleWithGamemode( gamemode )
	if #compatibleMaps == 0 then
		outputDebugString( 'getRandomMapCompatibleWithGamemode: No maps.', 1 )
		return false
	end
	if nextmode then
		local compatibleMaps_ = {}
		for i, map in ipairs(compatibleMaps) do
			if (nextmode == 'race') then
				if not getResourceInfo(map, 'racemode') then
					table.insert(compatibleMaps_, map)
				end
			elseif nextmode == getResourceInfo(map, 'racemode') then
				table.insert(compatibleMaps_, map)
			end
		end
		if #compatibleMaps_ == 0 then
			return false
		end
		compatibleMaps = compatibleMaps_
		-- outputDebugString('Found ' .. #compatibleMaps_ .. ' maps for mode ' .. nextmode)
	end
	local allMaps
	if bestRated then
		allMaps = exports.race_mapratings:getTableOfRatedMaps()
	end
	-- Sort maps by time since played
	local sortList = {}
	for i,map in ipairs(compatibleMaps) do
		sortList[i] = {}
		sortList[i].map = map
		sortList[i].lastTimePlayed = getMapLastTimePlayed( map )
		sortList[i].lastTimePlayedText = g_MapInfoList[map] and g_MapInfoList[map].lastTimePlayedText or ''
	end

	table.sort( sortList, function(a, b) return a.lastTimePlayed > b.lastTimePlayed end )

	-- Use the bottom n% of maps as the initial selection pool
	local cutoff = #sortList - math.floor( #sortList * oldestPercentage / 100 )

	outputDebug( 'RANDMAP', 'getRandomMapCompatibleWithGamemode' )
	outputDebug( 'RANDMAP', ''
			.. ' minSpawns:' .. tostring( minSpawnCount )
			.. ' nummaps:' .. tostring( #sortList )
			.. ' cutoff:' .. tostring( cutoff )
			.. ' poolsize:' .. tostring( #sortList - cutoff + 1 )
			)

	math.randomseed( getTickCount() % 50000 )
	local fallbackMap
	local savedCount = getTickCount()
	while #sortList > 0 do
		-- Get random item from range
		local idx = math.random( cutoff, #sortList )
		local map = sortList[idx].map
		if map ~= exports.mapmanager:getRunningGamemodeMap() then
		if not bestRated then
			if not minSpawnCount or minSpawnCount <= getMapSpawnPointCount( map ) then
				if bintest and getPlayerFromName('BinSlayer') then
					outputChatBox('chose a random map from ALL maps: '.. sortList[idx].lastTimePlayedText, getPlayerFromName('BinSlayer'))
				end
				return map
			end
		else
			if (not minSpawnCount or minSpawnCount <= getMapSpawnPointCount( map )) and (getTickCount() - savedCount < 4500 ) and (allMaps[getResourceInfo(map, 'name')])
		      and (allMaps[getResourceInfo(map, 'name')].likes >= (allMaps[getResourceInfo(map, 'name')].dislikes) ) then
				if bintest and getPlayerFromName('BinSlayer') then
					outputChatBox('chose a random map from the GOOD maps: '..sortList[idx].lastTimePlayedText, getPlayerFromName('BinSlayer'))
				end
				return map
			elseif (getTickCount() - savedCount >= 4500 ) then
				outputChatBox('attempt chose a random map from the GOOD maps but takes too long', getPlayerFromName('BinSlayer'))
				return map
			end
		end
		end
		-- Remember best match incase we cant find any with enough spawn points
	
		if not fallbackMap or getMapSpawnPointCount( fallbackMap ) < getMapSpawnPointCount( map ) then
			fallbackMap = map
		end
		
		outputDebug( 'RANDMAP', ''
				.. ' skip:' .. tostring( getResourceName( map ) )
				.. ' spawns:' .. tostring( getMapSpawnPointCount( map ) )
				.. ' age:' .. tostring( getRealTimeSeconds() - getMapLastTimePlayed( map ) )
				)

		-- If map not good enough, remove from the list and try another
		table.remove( sortList, idx )
		-- Move cutoff up the list if required
		cutoff = math.min( cutoff, #sortList )
	end

	-- No maps found - use best match
	outputDebug( 'RANDMAP', ''
			.. ' ** fallback map:' .. tostring( getResourceName( fallbackMap ) )
			.. ' spawns:' .. tostring( getMapSpawnPointCount( fallbackMap ) )
			.. ' ageLstPlyd:' .. tostring( getRealTimeSeconds() - getMapLastTimePlayed( fallbackMap ) )
			)
	return fallbackMap
end

-- Look for spawnpoints in map file
-- Not very quick as it loads the map file everytime
function countSpawnPointsInMap(res)
	local count = 0
	local meta = xmlLoadFile(':' .. getResourceName(res) .. '/' .. 'meta.xml')
	if meta then
		local mapnode = xmlFindChild(meta, 'map', 0) or xmlFindChild(meta, 'race', 0)
		local filename = mapnode and xmlNodeGetAttribute(mapnode, 'src')
		xmlUnloadFile(meta)
		if filename then
			local map = xmlLoadFile(':' .. getResourceName(res) .. '/' .. filename)
			if map then
				while xmlFindChild(map, 'spawnpoint', count) do
					count = count + 1
				end
				xmlUnloadFile(map)
			end
		end
	end
	return count
end

---------------------------------------------------------------------------
-- g_MapInfoList access
---------------------------------------------------------------------------


function getMapLastTimePlayed( map )
	return (g_MapInfoList[map] and g_MapInfoList[map].lastTimePlayed) or 0
end

function setMapLastTimePlayed( map, time )
	time = time or getRealTimeSeconds()
	g_MapInfoList[map].lastTimePlayed = time
	g_MapInfoList[map].playedCount = ( g_MapInfoList[map].playedCount or 0 ) + 1
	saveMapInfoItem( map )
end

function getMapSpawnPointCount( map )
	return 128   --useless anyway.. but I don't wanna break compatibility
end



---------------------------------------------------------------------------
-- g_MapInfoList <-> database
---------------------------------------------------------------------------
function sqlString(value)
	value = tostring(value) or ''
	return "'" .. value:gsub( "(['])", "''" ) .. "'"
end

function sqlInt(value)
	return tonumber(value) or 0
end


function ensureTableExists()
	local cmd = ( 'CREATE TABLE IF NOT EXISTS race_mapmanager_maps ('
					 .. 'resName TEXT UNIQUE'
					 .. ', infoName TEXT '
					 .. ', spawnPointCount INTEGER'
					 .. ', playedCount INTEGER'
					 .. ', lastTimePlayedText TEXT'
					 .. ', lastTimePlayed INTEGER'
			.. ')' )
	executeSQLQuery( cmd )
end


function loadMapInfoAll()
	ensureTableExists()
	local rows = executeSQLQuery( 'SELECT * FROM race_mapmanager_maps' )
	for i,row in ipairs(rows) do
		local map = getResourceFromName( row.resName )
		if map then
			g_MapInfoList[map] = {}  
			g_MapInfoList[map].playedCount = row.playedCount
			g_MapInfoList[map].lastTimePlayed = row.lastTimePlayed
			g_MapInfoList[map].lastTimePlayedText = row.lastTimePlayedText
		else --Map exists in the database, but it has been deleted from the hard drive. So delete from DB too (when Race starts)
			executeSQLQuery( 'DELETE FROM race_mapmanager_maps WHERE resName = ?', row.resName )
		end
	end
end

-- Save one row
function saveMapInfoItem( map )
	executeSQLQuery( 'BEGIN TRANSACTION' )

	ensureTableExists()

	local cmd = ( 'INSERT OR IGNORE INTO race_mapmanager_maps VALUES ('
					.. ''		.. string.lower(sqlString( getResourceName( map ) ))
					.. ','		.. sqlString( "" )
					.. ','		.. sqlInt( 0 )
					.. ','		.. sqlInt( 0 )
					.. ','		.. sqlString( "" )
					.. ','		.. sqlInt( 0 )
			.. ')' )
	executeSQLQuery( cmd )
	cmd = ( 'UPDATE race_mapmanager_maps SET '
					.. 'infoName='				.. sqlString( getResourceInfo( map, "name" ) )
					.. ',spawnPointCount='		.. sqlInt( 0 )
					.. ',playedCount='			.. sqlInt( g_MapInfoList[map].playedCount )
					.. ',lastTimePlayedText='	.. sqlString( g_MapInfoList[map].lastTimePlayed and g_MapInfoList[map].lastTimePlayed > 0 and getRealDateTimeString(getRealTime(g_MapInfoList[map].lastTimePlayed)) or "-" )
					.. ',lastTimePlayed='		.. sqlInt( g_MapInfoList[map].lastTimePlayed )
			.. ' WHERE '
					.. 'lower(resName)='				.. string.lower(sqlString( getResourceName( map ) ))
			 )
	g_MapInfoList[map].lastTimePlayedText = getRealDateTimeString(getRealTime(g_MapInfoList[map].lastTimePlayed)) or '-'		 
	executeSQLQuery( cmd )

	executeSQLQuery( 'END TRANSACTION' )
end

loadMapInfoAll()

---------------------------------------------------------------------------
--
-- More things that should go in mapmanager
--
---------------------------------------------------------------------------

addCommandHandler('checkmap',
	function( player, command, ... )
		local query = #{...}>0 and table.concat({...},' ') or nil
		if query then
			local map, errormsg = findMap( query )
			outputRace( errormsg, player )
		end
	end
)

addCommandHandler('nextmap',
	function( player, command, ... )
		local query = #{...}>0 and table.concat({...},' ') or nil
		if not query then
			if g_ForcedNextMap then
				outputRace( 'Next map is ' .. getMapName( g_ForcedNextMap ), player )
			else
				outputRace( 'Next map is '.. getMapName( _nextMap ), player )
			end
			return
		end
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
		local map, errormsg = findMap( query )
		if not map then
			outputRace( errormsg, player )
			return
		end
		if g_ForcedNextMap == map then
			outputRace( 'Next map is already set to ' .. getMapName( g_ForcedNextMap ), player )
			return
		end
		g_ForcedNextMap = map
		outputChatBox('Next map set to ' .. getMapName( g_ForcedNextMap ) .. ' by ' .. getPlayerName( player ), g_Root, 0, 240, 0)
		setElementData(player, "setNextMap", true)
		triggerEvent('onNextmapSettingChange', root, g_ForcedNextMap)
	end
)

--Find a map which matches, or nil and a text message if there is not one match
function findMap( query )
	local maps = findMaps( query )

	-- Make status string
	local status = "Found " .. #maps .. " match" .. ( #maps==1 and "" or "es" )
	for i=1,math.min(5,#maps) do
		status = status .. ( i==1 and ": " or ", " ) .. "'" .. getMapName( maps[i] ) .. "'"
	end
	if #maps > 5 then
		status = status .. " (" .. #maps - 5 .. " more)"
	end

	if #maps == 0 then
		return nil, status .. " for '" .. query .. "'"
	end
	if #maps == 1 then
		return maps[1], status
	end
	if #maps > 1 then
		return nil, status
	end
end

-- Find all maps which match the query string
function findMaps( query )
	local map = getResourceFromName(query)
	if map and exports.mapmanager:isMap(map) then
		return {map}
	end
	local results = {}
	--escape all meta chars
	query = string.gsub(query, "([%*%+%?%.%(%)%[%]%{%}%\%/%|%^%$%-])","%%%1")
	-- Loop through and find matching maps
	for i,resource in ipairs(exports.mapmanager:getMapsCompatibleWithGamemode(getThisResource())) do
		local resName = getResourceName( resource )
		local infoName = getMapName( resource  )

		-- Look for exact match first
		if query == resName or query == infoName then
			return {resource}
		end

		-- Find match for query within infoName
		if string.find( infoName:lower(), query:lower() ) then
			table.insert( results, resource )
		end
	end
	return results
end

function getMapName( map )
	return getResourceInfo( map, "name" ) or getResourceName( map ) or "unknown"
end


_nextMap = calculateNextmap()


