RaceMode = {}
RaceMode.__index = RaceMode

RaceMode.registeredModes = {}
RaceMode.instances = {}

function RaceMode:register(name)
	RaceMode.registeredModes[string.lower(name)] = self
	self.name = name
end

function RaceMode.getApplicableMode()
	-- Edit #0
	if RaceMode.registeredModes[string.lower(g_MapInfo.metamode)] then
		return RaceMode.registeredModes[string.lower(g_MapInfo.metamode)]
	end
	for modeName,mode in pairs(RaceMode.registeredModes) do
		if mode:isApplicable() then
			return mode
		end
	end
	return RaceMode
end

function RaceMode:start()
	return false
end

function RaceMode:isMapValid()
	return true
end

function RaceMode:getName()
	return self.name
end

function RaceMode.getCheckpoints()
	return g_Checkpoints
end

function RaceMode:getCheckpoint(i)
	return g_Checkpoints[i]
end

function RaceMode.getNumberOfCheckpoints()
	return #g_Checkpoints
end

function RaceMode.checkpointsExist()
	return #g_Checkpoints > 0
end

function RaceMode.getSpawnpoints()
	return g_Spawnpoints
end

function RaceMode.getNumberOfSpawnpoints()
	return #g_Spawnpoints
end

function RaceMode.getSpawnpoint(i)
	return g_Spawnpoints[i]
end

function RaceMode.getMapOption(option)
	return g_MapOptions[option]
end

function RaceMode.setMapOption(option,value)
	g_MapOptions[option] = value
	return true
end

function RaceMode:isMapRespawn()
	return self.getMapOption('respawn') == 'timelimit'
end

function RaceMode.getPlayers()
	return g_Players
end

function RaceMode.setPlayerIsFinished(player)
	setPlayerFinished(player, true)
end

function RaceMode.isPlayerFinished(player)
	return isPlayerFinished(player)
end

function RaceMode.getPlayerVehicle(player)
	return g_Vehicles[player]
end

function RaceMode:setTimeLeft(timeLeft)
	if g_MapOptions.duration - self:getTimePassed() > timeLeft then
		g_MapOptions.duration = self:getTimePassed() + timeLeft
		TimerManager.destroyTimersFor("raceend")
		TimerManager.createTimerFor("map","raceend"):setTimer(raceTimeout, timeLeft, 1)
		clientCall(g_Root, 'setTimeLeft', timeLeft)
	end
end

function RaceMode:timeout()
end

function RaceMode:endMap()
    if stateAllowsPostFinish() then
        gotoState('PostFinish')
        local text = g_GameOptions.randommaps and 'Next map starts in:' or 'Vote for next map starts in:'
        Countdown.create(5, self.startNextMapSelect, text, 255, 255, 255, 0.6, 2.5 ):start()
		triggerEvent('onPostFinish', g_Root)
    end
end

function RaceMode.startNextMapSelect()
	if stateAllowsNextMapSelect() then
		gotoState('NextMapSelect')
		Countdown.destroyAll()
		destroyAllMessages()
		if g_GameOptions.randommaps then
			startRandomMap()
		else
			startNextMapVote()
		end
	end
end

-- Default functions

function RaceMode.isApplicable()
	return false
end

function RaceMode:create()
	local id = #RaceMode.instances + 1
	RaceMode.instances[id] = setmetatable(
		{
			id = id,
			checkpointBackups = {},  -- { player = { goingback = true/false, i = { vehicle = id, position = {x, y, z}, rotation = {x, y, z}, velocity = {x, y, z} } } }
			activePlayerList = {},
			finishedPlayerList = {},
		},
		self
	)
	return RaceMode.instances[id]
end

function RaceMode:launch()
	self.startTick = getTickCount()
	for _,spawnpoint in ipairs(self.getSpawnpoints()) do
		spawnpoint.used = nil
	end
	-- Put all relevant players into the active player list
	for _,player in ipairs(getElementsByType("player")) do
		if not isPlayerFinished(player) then
			addActivePlayer( player )
		end
	end
end

function RaceMode:getTimePassed()
	if self.startTick then
		return getTickCount() - self.startTick
	else
		return 0
	end
end

function RaceMode:getTimeRemaining()
	if self.startTick then
		return self.startTick + g_MapOptions.duration - getTickCount()
	else
		return 0
	end
end

function RaceMode:forceRespawnRestore()
	return false
end

function RaceMode:playerSpectating(player)
end

function RaceMode:isRanked()
	return true
end

function RaceMode:getPlayerRank(queryPlayer)
	local rank = 1
	local queryCheckpoint = getPlayerCurrentCheckpoint(queryPlayer)
	local checkpoint

	-- Figure out rank amoung the active players
	for i,player in ipairs(getActivePlayers()) do
		if player ~= queryPlayer then
			checkpoint = getPlayerCurrentCheckpoint(player)
			if self.isPlayerFinished(player) or checkpoint > queryCheckpoint then
				rank = rank + 1
			elseif checkpoint == queryCheckpoint then
				if distanceFromPlayerToCheckpoint(player, checkpoint) < distanceFromPlayerToCheckpoint(queryPlayer, checkpoint) then
					rank = rank + 1
				end
			end
		end
	end

	-- Then add on the players that have finished
	rank = rank + getFinishedPlayerCount()
	return rank
end

function RaceMode:updateRanks()
	-- Faster version of old updateRank

	-- Make a table with the active players
	local sortinfo = {}
	for i,player in ipairs(getActivePlayers()) do
		sortinfo[i] = {}
		sortinfo[i].player = player
		sortinfo[i].checkpoint = getPlayerCurrentCheckpoint(player)
		sortinfo[i].cpdist = distanceFromPlayerToCheckpoint(player, sortinfo[i].checkpoint )
	end
	-- Order by cp
	table.sort( sortinfo, function(a,b)
						return a.checkpoint > b.checkpoint or
							   ( a.checkpoint == b.checkpoint and a.cpdist < b.cpdist )
					  end )
	-- Copy back into active players list to speed up sort next time
	for i,info in ipairs(sortinfo) do
		g_CurrentRaceMode.activePlayerList[i] = info.player
	end
	-- Update data
	local rankOffset = getFinishedPlayerCount()
	for i,info in ipairs(sortinfo) do
		setElementData(info.player, 'race rank', i + rankOffset )
		setElementData(info.player, 'checkpoint', info.checkpoint-1 .. '/' .. #g_Checkpoints )
	end
	-- Make sure cp text looks good for finished players
	for i,player in ipairs(g_Players) do
		if isPlayerFinished(player) then
			setElementData(player, 'checkpoint', #g_Checkpoints .. '/' .. #g_Checkpoints )
		end
	end
	-- Make text look good at the start
	if not self.running then
		for i,player in ipairs(g_Players) do
			setElementData(player, 'race rank', 1 )
			setElementData(player, 'checkpoint', '0/' .. #g_Checkpoints )
		end
	end
end

function RaceMode:onPlayerJoin(player, spawnpoint)
	self.checkpointBackups[player] = {}
	self.checkpointBackups[player][0] = { vehicle = spawnpoint.vehicle, position = spawnpoint.position, rotation = {0, 0, spawnpoint.rotation}, velocity = {0, 0, 0}, turnvelocity = {0, 0, 0}, geardown = true}
end

function RaceMode:onPlayerPickUpRacePickup(player, pickup)
end

function RaceMode:onPlayerReachCheckpoint(player, checkpointNum, nitroLevel, nitroActive)
	local rank = self:getPlayerRank(player)
	local time = self:getTimePassed()
	if checkpointNum < self.getNumberOfCheckpoints() then
		-- Regular checkpoint
		local vehicle = self.getPlayerVehicle(player)
		-- Edit #1, data for shop perk
		self.checkpointBackups[player][checkpointNum] = { vehicle = getElementModel(vehicle), position = { getElementPosition(vehicle) }, rotation = { getVehicleRotation(vehicle) }, velocity = { getElementVelocity(vehicle) }, turnvelocity = { getElementAngularVelocity(vehicle) }, health = getElementHealth(vehicle), healthtick = getTickCount(), geardown = getVehicleLandingGearDown(vehicle) or false, nitroLevel = nitroLevel, nitroActive = nitroActive}	
		
		self.checkpointBackups[player].goingback = true
		TimerManager.destroyTimersFor("checkpointBackup",player)
		-- Edit #2, edit respawn time based on shop perk
		TimerManager.createTimerFor("map","checkpointBackup",player):setTimer(lastCheckpointWasSafe, tonumber(getElementData(player, 'gcshop.saferespawn')) or 5000, 1, self.id, player)
	else
		-- Finish reached
		rank = getFinishedPlayerCount() + 1
		self.setPlayerIsFinished(player)
		finishActivePlayer( player )
		setPlayerStatus( player, nil, "finished" )
		if rank == 1 then
            gotoState('SomeoneWon')
			showMessage('You have won the race!', 0, 255, 0, player)
			if self.rankingBoard then	-- Remove lingering labels
				self.rankingBoard:destroy()
			end
			self.rankingBoard = RankingBoard:create()
			if g_MapOptions.duration then
				self:setTimeLeft( g_GameOptions.timeafterfirstfinish )
			end
		else
			showMessage('You finished ' .. rank .. ( (rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th' ) .. '!', 0, 255, 0, player)
		end
		--Output a killmessage
		if getResourceFromName"killmessages" and getResourceState(getResourceFromName"killmessages") == "running" then
			exports.killmessages:outputMessage(
				{
					{"image",path="img/killmessage.png",resource=getThisResource(),width=24},
					getPlayerName(player),
				},
				g_Root,
				255,0,0
			)
		end
		-- self.rankingBoard:add(player, time)
		if getActivePlayerCount() > 0 then
			TimerManager.createTimerFor("map",player):setTimer(clientCall, 5000, 1, player, 'Spectate.start', 'auto')
		else
			TimerManager.createTimerFor("map"):setTimer(
				function()
					gotoState('EveryoneFinished')
					self:setTimeLeft( 0 )
					self:endMap()
				end,
				50, 1 )
		end
	end
	return rank, time
end

function lastCheckpointWasSafe(id, player)
	if not isValidPlayer(player) then
		return
	end
	local self = RaceMode.instances[id]
	if self.checkpointBackups[player] then
		self.checkpointBackups[player].goingback = false
	end
end

function isValidPlayer(player)
 	return g_Players and table.find(g_Players, player)
end

function isValidPlayerVehicle(player,vehicle)
	if isValidPlayer(player) then
		if vehicle and g_Vehicles[player] == vehicle then
			return true
		end
	end
	return false
end


function RaceMode:onPlayerWasted(player)
	if not self.checkpointBackups[player] then
		return
	end
	TimerManager.destroyTimersFor("checkpointBackup",player)
	if self.getMapOption('respawn') == 'timelimit' and not self.isPlayerFinished(source) then
        -- See if its worth doing a respawn
        local respawnTime       = tonumber(getElementData(player, 'gcshop.respawntime')) or self.getMapOption('respawntime')
        if self:getTimeRemaining() - respawnTime > 3000 then
            Countdown.create(respawnTime/1000, self.restorePlayer, 'You will respawn in:', 255, 255, 255, 0.25, 2.5, true, self, self.id, player):start(player)
        end
	    if respawnTime >= 5000 then
		    TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
	    end
	end
	if g_MapOptions.respawn == 'none' then
		removeActivePlayer( player )
		TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
		if getActivePlayerCount() < 1 and g_CurrentRaceMode.running then
			self:endMap()
		end
	end
end


function distanceFromVehicleToSpawnpoint(vehicle, spawnpoint)
    if vehicle then
	    local x, y, z = getElementPosition(vehicle)
	    return getDistanceBetweenPoints3D(x, y, z, unpack(spawnpoint.position))
    end
    return 0
end

function getSpaceAroundSpawnpoint(ignore,spawnpoint)
    local space = 100000
    for i,player in ipairs(g_Players) do
		if player ~= ignore then
			space = math.min(space, distanceFromVehicleToSpawnpoint(g_Vehicles[player], spawnpoint))
		end
    end
    return space
end

function hasSpaceAroundSpawnpoint(ignore,spawnpoint, requiredSpace)
    for i,player in ipairs(g_Players) do
		if player ~= ignore then
			if distanceFromVehicleToSpawnpoint(g_Vehicles[player], spawnpoint) < requiredSpace then
				return false
			end
        end
    end
    return true
end

local g_DoubleUpPos = 0
function RaceMode:pickFreeSpawnpoint(ignore)
    -- Use the spawnpoints from #1 to #numplayers as a pool to use
    local numToScan = #g_Spawnpoints -- math.min(getPlayerCount(), #g_Spawnpoints)
    -- Starting at a random place in the pool...
    local scanPos = math.random(1,numToScan)
    -- ...loop through looking for a free spot
    for i=1,numToScan do
        local idx = (i + scanPos) % numToScan + 1
        if hasSpaceAroundSpawnpoint(ignore,g_Spawnpoints[idx], 1) then
            -- return g_Spawnpoints[idx]
        end
    end
    -- If one can't be found, find the spot which has the most space
    local bestSpace = 0
    local bestMatch = 1
    for i=1,numToScan do
        local idx = (i + scanPos) % numToScan + 1
        local space = getSpaceAroundSpawnpoint(ignore,g_Spawnpoints[idx])
        if space > bestSpace then
            bestSpace = space
            bestMatch = idx
        end
    end
	-- If bestSpace is too small, assume all spawnpoints are taken, and start to double up
	if bestSpace < 0.1 then
		g_DoubleUpPos = ( g_DoubleUpPos + 1 ) % #g_Spawnpoints
		bestMatch = g_DoubleUpPos + 1
	end
    return g_Spawnpoints[bestMatch]
end

function RaceMode:freeSpawnpoint(i)
	if self.getSpawnpoint(i) then
		self.getSpawnpoint(i).used = nil
	end
end

function RaceMode:restorePlayer(id, player, bNoFade, bDontFix)
	if not isValidPlayer(player) then
		return
	end
	if not bNoFade then
		clientCall(player, 'remoteStopSpectateAndBlack')
	end

	local checkpoint = getPlayerCurrentCheckpoint(player)
	if self.checkpointBackups[player].goingback and checkpoint > 1 then
		-- Edit #3, potential bugfix with respawn problem
		repeat
			checkpoint = checkpoint - 1
			setPlayerCurrentCheckpoint(player, checkpoint)
		until type(self.checkpointBackups[player][checkpoint - 1]) == 'table' or checkpoint <= 1
		-- Edit #3
	end
	self.checkpointBackups[player].goingback = true
	local bkp = self.checkpointBackups[player][checkpoint - 1]
	if not self.checkpointsExist() or checkpoint==1 then
		local spawnpoint = self:pickFreeSpawnpoint(player)
		bkp.position = spawnpoint.position
		bkp.rotation = {0, 0, spawnpoint.rotation}
		bkp.geardown = true                 -- Fix landing gear state
		bkp.vehicle = spawnpoint.vehicle    -- Fix spawn'n'blow
		--setVehicleID(self.getPlayerVehicle(player), spawnpoint.vehicle)
	end
	-- Validate some bkp variables
	if type(bkp.rotation) ~= "table" or #bkp.rotation < 3 then
		bkp.rotation = {0, 0, 0}
	end
	spawnPlayer(player, 0, 0, 0, 0, getElementModel(player))

	local vehicle = self.getPlayerVehicle(player)
	if vehicle then
        setElementVelocity( vehicle, 0,0,0 )
        setElementAngularVelocity( vehicle, 0,0,0 )
		setElementPosition(vehicle, unpack(bkp.position))
		local rx, ry, rz = unpack(bkp.rotation)
		setVehicleRotation(vehicle, rx or 0, ry or 0, rz or 0)
		if not bDontFix then
			fixVehicle(vehicle)
		end
		-- Edit #4, gcshop perk, dont reset health
		if bkp.healthtick and tonumber(bkp.healthtick) and bkp.healthtick + 5000 > getTickCount() then
			setElementHealth(vehicle, math.max(500, bkp.health))
			bDontFix = true
		end
		setVehicleID(vehicle, 481)	-- BMX (fix engine sound)
		if getElementModel(vehicle) ~= bkp.vehicle then
			setVehicleID(vehicle, bkp.vehicle)
		end
		warpPedIntoVehicle(player, vehicle)	
		
        setVehicleLandingGearDown(vehicle,bkp.geardown)
		

		self:playerFreeze(player, true, bDontFix)
        outputDebug( 'MISC', 'restorePlayer: setElementFrozen true for ' .. tostring(getPlayerName(player)) .. '  vehicle:' .. tostring(vehicle) )
        removeVehicleUpgrade(vehicle, 1010) -- remove nitro
		TimerManager.destroyTimersFor("unfreeze",player)
		TimerManager.createTimerFor("map","unfreeze",player):setTimer(self.restorePlayerUnfreeze, 2000, 1, self, id, player, bDontFix, bkp.nitroLevel, bkp.nitroActive)
	end
    setCameraTarget(player)
	setPlayerStatus( player, "alive", "" )
	clientCall(player, 'remoteSoonFadeIn', bNoFade )
end

function RaceMode:restorePlayerUnfreeze(id, player, bDontFix, nitroLevel, nitroActive)
	if not isValidPlayer(player) then
		return
	end
	self:playerUnfreeze(player, bDontFix)
	local vehicle = self.getPlayerVehicle(player)
    outputDebug( 'MISC', 'restorePlayerUnfreeze: vehicle false for ' .. tostring(getPlayerName(player)) .. '  vehicle:' .. tostring(vehicle) )
	local bkp = self.checkpointBackups[player][getPlayerCurrentCheckpoint(player)-1]
	setElementVelocity(vehicle, unpack(bkp.velocity))
	setElementAngularVelocity(g_Vehicles[player], unpack(bkp.turnvelocity))
	if nitroLevel then
		addVehicleUpgrade(vehicle, 1010)
		clientCall(root, 'setVehicleNitroLevel', vehicle, nitroLevel)
		clientCall(root, 'setVehicleNitroActivated', vehicle, not not nitroActive)
	end
end

--------------------------------------
-- For use when starting or respawing
--------------------------------------
function RaceMode:playerFreeze(player, bRespawn, bDontFix)
    toggleAllControls(player,true)
	clientCall( player, "updateVehicleWeapons" )
	local vehicle = self.getPlayerVehicle(player)

	-- Apply addon overrides at start of new map
	if not bRespawn then
		AddonOverride.applyAll( player )
	end

	-- Reset move away stuff
	Override.setCollideOthers( "ForSpectating", vehicle, nil )
	Override.setCollideOthers( "ForMoveAway", vehicle, nil )
	Override.setAlpha( "ForMoveAway", {player, vehicle}, nil )

	-- Setup ghost mode for this vehicle
	Override.setCollideOthers( "ForGhostCollisions", vehicle, g_MapOptions.ghostmode and 0 or nil )
	Override.setAlpha( "ForGhostAlpha", {player, vehicle}, g_MapOptions.ghostmode and g_GameOptions.ghostalpha and 180 or nil )

	-- Show non-ghost vehicles as semi-transparent while respawning
	Override.setAlpha( "ForRespawnEffect", {player, vehicle}, bRespawn and not g_MapOptions.ghostmode and 120 or nil )

	-- No collisions while frozen
	Override.setCollideOthers( "ForVehicleSpawnFreeze", vehicle, 0 )

	if not bDontFix then
		fixVehicle(vehicle)
	end
	setElementFrozen(vehicle, true)
    setVehicleDamageProof(vehicle, true)
	Override.setCollideWorld( "ForVehicleJudder", vehicle, 0 )
	Override.flushAll()
end

function RaceMode:playerUnfreeze(player, bDontFix)
	if not isValidPlayer(player) then
		return
	end
    toggleAllControls(player,true)
	clientCall( player, "updateVehicleWeapons" )
	local vehicle = self.getPlayerVehicle(player)
	if not bDontFix then
		fixVehicle(vehicle)
	end
    setVehicleDamageProof(vehicle, false)
    setVehicleEngineState(vehicle, true)
	setElementFrozen(vehicle, false)

	-- Remove things added for freeze only
	Override.setCollideWorld( "ForVehicleJudder", vehicle, nil )
	Override.setCollideOthers( "ForVehicleSpawnFreeze", vehicle, nil )
	Override.setAlpha( "ForRespawnEffect", {player, vehicle}, nil )
	Override.flushAll()
end
--------------------------------------

-- Handle admin panel unfreeze
addEventHandler ( "onPlayerFreeze", root,
	function ( state )
		local player = source
		if not state then
			TimerManager.createTimerFor("map",player):setTimer( clientCall, 200, 1, player, "updateVehicleWeapons" )
		end
	end
)

-- Handle admin panel change vehicle
addEventHandler ( "aPlayer", root,
	function ( player, cmd, arg )
		if cmd == "givevehicle" then
			TimerManager.createTimerFor("map",player):setTimer( clientCall, 200, 1, player, "updateVehicleWeapons" )
		end
	end
)


function RaceMode:onPlayerQuit(player)
	self.checkpointBackups[player] = nil
	removeActivePlayer( player )
	if g_MapOptions.respawn == 'none' then
		if getActivePlayerCount() < 1 and g_CurrentRaceMode.running then
			self:endMap()
		end
	end
end

function RaceMode:destroy()
	if self.rankingBoard then
		self.rankingBoard:destroy()
		self.rankingBoard = nil
	end
	TimerManager.destroyTimersFor("checkpointBackup")
	RaceMode.instances[self.id] = nil
end

------------------------------------------------------------
-- activePlayerList stuff
--

function isActivePlayer( player )
	return table.find( g_CurrentRaceMode.activePlayerList, player )
end

function addActivePlayer( player )
	table.insertUnique( g_CurrentRaceMode.activePlayerList, player )
end

function removeActivePlayer( player )
	table.removevalue( g_CurrentRaceMode.activePlayerList, player )
end

function finishActivePlayer( player )
	table.removevalue( g_CurrentRaceMode.activePlayerList, player )
	table.insertUnique( g_CurrentRaceMode.finishedPlayerList, _getPlayerName(player) )
end

function getFinishedPlayerCount()
	return #g_CurrentRaceMode.finishedPlayerList
end

function getActivePlayerCount()
	local count = 0
	for k, p in ipairs(g_CurrentRaceMode.activePlayerList) do
		local state = getElementData(p, 'state')
		if (state == 'alive' or state == 'dead') and getElementData(p, 'player state') ~= 'away' then
			count = count + 1
		end
	end
	return count
	-- return #g_CurrentRaceMode.activePlayerList
end

function getActivePlayers()
	return g_CurrentRaceMode.activePlayerList
end

function getFinishedPlayers()
	return g_CurrentRaceMode.finishedPlayerList
end

