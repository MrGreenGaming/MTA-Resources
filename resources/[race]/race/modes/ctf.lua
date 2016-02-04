local maxWins = 3
local defendColSize = 150
local maxHitDetectionDuration = 15000 -- In ms (hit detection time)

CTF = setmetatable({}, RaceMode)
CTF.__index = CTF

CTF:register('ctf')

function CTF:isMapValid()
	-- Check if there is only one object for each flag in the map
	local redFlagObjects, blueFlagObjects = #getElementsByType(self.red.FlagType), #getElementsByType(self.blue.FlagType)
	if redFlagObjects ~= 1 or blueFlagObjects ~= 1 then
		outputRace('Error. CTF map should have one red flag(' .. redFlagObjects .. ') and one blue flag(' .. blueFlagObjects .. ')')
		return false 
	elseif self.getNumberOfCheckpoints() > 0 then
		outputRace('Error. CTF map shouldn\'t have checkpoints')
		return false 
	else
		local error = false
		for i, spawn in ipairs(g_Spawnpoints) do
			local team = spawn.team
			if not (team == self.red.SpawnType or team == self.blue.SpawnType) then
				error = true
				outputRace('Error. CTF spawnpoint #' .. i .. ' "' .. getElementID(spawn) .. '" has no team assigned')
			end
		end
		if error then return false end
	end
	return true
end

function CTF:start()
	self:cleanup()

	exports.scoreboard:removeScoreboardColumn('race rank')
	exports.scoreboard:removeScoreboardColumn('checkpoint')

	-- Initialize
	self:initTeam(self.red)
	self:initTeam(self.blue)
end

function CTF:initTeam(teamTable)
	teamTable.Team = createTeam(teamTable.name, teamTable.r, teamTable.g, teamTable.b)
	teamTable.points = 0
	teamTable.serials = {}
	
	local flagElement = getElementsByType(teamTable.FlagType)[1]
	local x,y,z = getElementPosition(flagElement)
	teamTable.flagObject= createObject(teamTable.FlagModel, x,y,z)
	teamTable.Flag = Flag:new(teamTable, teamTable.flagObject)

	-- Make Colshape for defend area
	local halfsize = defendColSize/2
	teamTable["defendColShape"] = createColRectangle(x-halfsize, y-halfsize, defendColSize, defendColSize)
	triggerEvent("sendCTFDefendColshape",root,teamTable["defendColShape"],teamTable.name)
end


function CTF:onPlayerJoin(player, spawnpoint)
	self.checkpointBackups[player] = {}
	self.checkpointBackups[player][0] = { vehicle = spawnpoint.vehicle, position = spawnpoint.position, rotation = {0, 0, spawnpoint.rotation}, velocity = {0, 0, 0}, turnvelocity = {0, 0, 0}, geardown = true }
	if spawnpoint.team == CTF.red.SpawnType then
		self:setPlayerTeam(player, self.red)
	else
		self:setPlayerTeam(player, self.blue)
	end
	clientCall(player, 'ctfStart', self.red.Flag:getObject(), self.blue.Flag:getObject(), self:getMaxWins())
end

function CTF:setPlayerTeam(player, teamTable)
	setPlayerTeam(player, teamTable.Team)
	teamTable.serials[getPlayerSerial(player)] = true
	local r, g, b = getTeamColor(teamTable.Team)
	createBlipAttachedTo(player, 0, 1, r, g, b)
	setVehicleColor(g_CurrentRaceMode.getPlayerVehicle( player ), r, g, b, r, g, b, r, g, b, r, g, b)
	clientCall(root,'applyTeamColorShader',player) 
	showMessage("You have been assigned to the " .. teamTable.name .. "!", r, g, b, player)
end

local g_DoubleUpPos = 0
-- this also decides in which team the player will be added
function CTF:pickFreeSpawnpoint(ignore)
	-- if the player is in a team, filter only his teams spawnpoints
	local g_OriginalSpawnpoints = g_Spawnpoints
	local g_Spawnpoints = {}
	local redPlayers, bluePlayers = countPlayersInTeam(self.red.Team), countPlayersInTeam(self.blue.Team)
	if getPlayerTeam(ignore) == CTF.red.Team or getPlayerTeam(ignore) == CTF.blue.Team then
		for i, spawn in ipairs(g_OriginalSpawnpoints) do
			if (spawn.team == CTF.red.SpawnType and getPlayerTeam(ignore) == CTF.red.Team) or (spawn.team == CTF.blue.SpawnType and getPlayerTeam(ignore) == CTF.blue.Team) then
				table.insert(g_Spawnpoints, spawn)
			end
		end
	-- else filter the team with the least players
	elseif (redPlayers < bluePlayers) or self.red.serials[getPlayerSerial(ignore)] then
		for i, spawn in ipairs(g_OriginalSpawnpoints) do
			if (spawn.team == CTF.red.SpawnType) then
				table.insert(g_Spawnpoints, spawn)
			end
		end
	elseif (redPlayers > bluePlayers) or self.blue.serials[getPlayerSerial(ignore)] then
		for i, spawn in ipairs(g_OriginalSpawnpoints) do
			if (spawn.team == CTF.blue.SpawnType) then
				table.insert(g_Spawnpoints, spawn)
			end
		end
	-- else random spawn
	else
		for k,v in pairs(g_OriginalSpawnpoints) do
			g_Spawnpoints[k] = v
		end
	end
	-- Use the spawnpoints from #1 to #numplayers as a pool to use
    local numToScan = math.min(getPlayerCount(), #g_Spawnpoints)
    -- Starting at a random place in the pool...
    local scanPos = math.random(1,numToScan)
    -- ...loop through looking for a free spot
    for i=1,numToScan do
        local idx = (i + scanPos) % numToScan + 1
        if hasSpaceAroundSpawnpoint(ignore,g_Spawnpoints[idx], 1) then
            return g_Spawnpoints[idx]
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

function CTF:restorePlayer(id, player, bNoFade, bDontFix)
	if not isValidPlayer(player) then
		return
	end
	if not bNoFade then
		clientCall(player, 'remoteStopSpectateAndBlack')
	end
	
	local bkp = {}
	local spawnpoint = self:pickFreeSpawnpoint(player)
	bkp.position = spawnpoint.position
	bkp.rotation = {0, 0, spawnpoint.rotation}
	bkp.geardown = true                 -- Fix landing gear state
	bkp.vehicle = spawnpoint.vehicle    -- Fix spawn'n'blow
	--setVehicleID(self.getPlayerVehicle(player), spawnpoint.vehicle)
	-- Validate some bkp variables
	if type(bkp.rotation) ~= "table" or #bkp.rotation < 3 then
		bkp.rotation = {0, 0, 0}
	end
	spawnPlayer(player, 0, 0, 0, 0, getElementModel(player))

	local vehicle = self.getPlayerVehicle(player)
	if vehicle then
        setElementVelocity( vehicle, 0,0,0 )
        setVehicleTurnVelocity( vehicle, 0,0,0 )
		setElementPosition(vehicle, unpack(bkp.position))
		local rx, ry, rz = unpack(bkp.rotation)
		setElementRotation(vehicle, rx or 0, ry or 0, rz or 0)
		if not bDontFix then
			fixVehicle(vehicle)
		end
		-- Edit #4, gcshop perk, dont reset health
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
		TimerManager.createTimerFor("map","unfreeze",player):setTimer(self.restorePlayerUnfreeze, 2000, 1, self, id, player, bDontFix)
	end
    setCameraTarget(player)
	setPlayerStatus( player, "alive", "" )
	clientCall(player, 'remoteSoonFadeIn', bNoFade )
	local team = getPlayerTeam(player)
	local r, g, b = getTeamColor(team)
	setVehicleColor(g_CurrentRaceMode.getPlayerVehicle( player ), r, g, b, r, g, b, r, g, b, r, g, b)
	clientCall(root,'applyTeamColorShader',player) 
end



function CTF:onPlayerPickUpRacePickup(player, pickup)
	if pickup.type == 'vehiclechange' then
		local team = getPlayerTeam(player)
		local r, g, b = getTeamColor(team)
		setVehicleColor(g_CurrentRaceMode.getPlayerVehicle( player ), r, g, b, r, g, b, r, g, b, r, g, b)
		clientCall(root,'applyTeamColorShader',player) 
	end
end

function CTF:isRanked()
	return false
end

function CTF:forceRespawnRestore()
	return true
end

function CTF:isFlagSnatchingAllowed()
	-- if self:getTakenFlag() then
		-- return false
	-- else
		return true
	-- end
end

function CTF:setFlagTaken(Flag, bTaken)
	self.takenFlag = bTaken and Flag or false
	if (Flag) then
		-- outputDebugString('CTF: ' .. Flag:getTeamName() .. '(' .. tostring(Flag) .. ') flag is ' .. (bTaken and 'on the move' or 'home'))
	else
		-- outputDebugString('CTF: Taken Flag reset')
	end
end

function CTF:getTakenFlag()
	return self.takenFlag
end

function CTF:getFlagCarriedBy(player)
	local flag = self.red.flag
	if (flag and flag:getCarrier() == player) then
		return flag
	end
	local flag = self.blue.flag
	if (flag and flag:getCarrier() == player) then
		return flag
	end
	-- if (self:getTakenFlag() and self:getTakenFlag():getCarrier() == player) then
		-- return self:getTakenFlag()
	-- end
end

function CTF:onPlayerWasted(player)
	self:dropPlayerFlag(player)
	
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
end

function CTF:onPlayerQuit(player)
	self:removePlayerFlag(player)

	self.checkpointBackups[player] = nil
	removeActivePlayer( player )
	if g_MapOptions.respawn == 'none' then
		if getActivePlayerCount() < 1 and g_CurrentRaceMode.running then
			self:endMap()
		end
	end
end

function CTF:playerSpectating(player)
	-- self:removePlayerFlag(player)
	self:dropPlayerFlag(player)
end

function CTF:removePlayerFlag(player)
	if self:getTakenFlag() then
		if (self:getTakenFlag():getCarrier() == player) then
			self:getTakenFlag():resetToBase()
		end
	end
end

function CTF:dropPlayerFlag(player)
	local playerFlag
	for k, flag in ipairs(Flag.instances) do 
		if flag:getCarrier() == player then
			playerFlag = flag
		end
	end
	if playerFlag then
		playerFlag:dropFlag(player)
	end
end

function CTF:addPoint(teamTable, player)
	teamTable.points = teamTable.points + 1
	setElementData ( teamTable.Team, 'ctf.points', teamTable.points )
	clientCall(root, 'ctfTeamPoints', teamTable.Team, teamTable.points)
	if teamTable.points >= self:getMaxWins() then
		self:teamWon(teamTable, player)
	end
end

function CTF:getMaxWins()
	return self.maxWins
end

function CTF:teamWon(teamTable, player)
	self:endMap(teamTable, player)
	clientCall(g_Root, 'raceTimeout')
end

function CTF:showWin(teamTable, player)
	showMessage(teamTable.name .. ' wins!', teamTable.r, teamTable.g, teamTable.b)
	triggerEvent('onCTFTeamWon', teamTable.Team, player)

	if CTF.red.Flag then CTF.red.Flag:destroy() end
	if CTF.blue.Flag then CTF.blue.Flag:destroy() end
end
addEvent('onCTFTeamWon')

function CTF:endMap(teamTable, player)
	if (player) then
		self:showWin(teamTable, player)
	elseif (CTF.red.points > CTF.blue.points) then
		self:showWin(CTF.red)
	elseif (CTF.red.points < CTF.blue.points) then
		self:showWin(CTF.blue)
	end
    RaceMode.endMap(self)
end



function CTF:cleanup()
	-- Cleanup for next mode

	clientCall(root, 'ctfStop')

	local destroy = {
		CTF.red.Team, CTF.blue.Team,
		CTF.red.marker, CTF.blue.marker,
		CTF.red.col, CTF.blue.col,
		CTF.red.defendColShape, CTF.blue.defendColShape,
		CTF.red.flagObject, CTF.blue.flagObject,
	}



	for _, v in pairs(destroy) do
		if isElement(v) then destroyElement(v) end
	end
	if CTF.red.Flag then CTF.red.Flag:destroy() end
	if CTF.blue.Flag then CTF.blue.Flag:destroy() end
	self:setFlagTaken()
end

function CTF:destroy()
	self:cleanup()
	exports.scoreboard:addScoreboardColumn('race rank')
	exports.scoreboard:addScoreboardColumn('checkpoint')
	if self.rankingBoard then
		self.rankingBoard:destroy()
		self.rankingBoard = nil
	end
	TimerManager.destroyTimersFor("checkpointBackup")
	RaceMode.instances[self.id] = nil
end

CTF.name = 'Capture the flag'
CTF.maxWins = maxWins

CTF.red = {
	name = "Red team",
	r = 255,
	g = 0,
	b = 0,
	Flag = nil,
	Team = nil,
	col = nil,
	base = {},
	basemarker = nil,
	basecol = nil,
	marker = nil,
	FlagType = 'ctfred',
	FlagModel = 2914,
	FlagBlip = 19,
	SpawnType = 'red',
	points = 0,
	defendColShape = nil,
	serials = {},
	flagObject = nil,
}

CTF.blue = {
	name = "Blue team",
	r = 0,
	g = 0,
	b = 255,
	Flag = nil,
	Team = nil,
	col = nil,
	base = {},
	basemarker = nil,
	basecol = nil,
	marker = nil,
	FlagType = 'ctfblue',
	FlagModel = 2048,
	FlagBlip = 53,
	SpawnType = 'blue',
	points = 0,
	defendColShape = nil,
	serials = {},
	flagObject = nil,
}


CTF.modeOptions = {
	duration = 5 * 60 * 1000,
	respawn = 'timelimit',
	respawntime = 5,
	autopimp = false,
	autopimp_map_can_override = false,
	ghostmode = false,
	ghostmode_map_can_override = false,
}

-- Flag class
Flag = {}
Flag.__index = Flag
Flag.instances = {}

function Flag:new(teamTable, object)
	local id = #Flag.instances + 1
	local x, y, z = getElementPosition(object)
	local t = {}
	t.id = id
	t.teamTable = teamTable
	t.object = object
	
	t.base = {x=x, y=y, z=z}
	t.basemarker = createMarker(x,y,z, 'cylinder', 1.5, teamTable.r, teamTable.g, teamTable.b, 100)
	t.basecol = createColSphere(x, y, z, 2)
	t.blip = createBlipAttachedTo(t.basemarker, 0, 4, teamTable.r, teamTable.g, teamTable.b)
	addEventHandler('onColShapeHit', t.basecol, Flag.hit)
	
	t.marker = createMarker(x, y, z, 'corona', 1.5, teamTable.r, teamTable.g, teamTable.b, 100)
	attachElements( t.marker, t.object)
	setElementParent( t.marker, t.object)

	t.col = createColSphere(x, y, z,2)
	addEventHandler('onColShapeHit', t.col, Flag.hit)
	attachElements( t.col, t.object)
	setElementParent( t.col, t.object)
	
	-- outputDebugString("New " .. teamTable.name .. " flag (".. id .. ') ' .. tostring((object)) .. " event=" .. tostring(t.col))
	Flag.instances[id] = setmetatable(t, self)
	return Flag.instances[id]
end

function Flag:hitColshape(player)
	-- outputDebugString(getPlayerName(player) .. '(' .. getTeamName(getPlayerTeam(player)) .. ') hit the flag of the ' .. self:getTeam().name .. '(snatching=' .. tostring(self:isTakeAble()) ..')')
	if not self:getCarrier() and self:isTakeAble() and getPlayerTeam(player) ~= self:getTeam().Team and not g_CurrentRaceMode:getFlagCarriedBy(player) then
		self:setCarrier(player)
		g_CurrentRaceMode:setFlagTaken(self, true)
		self:startCarrierTimer(self:getCarrier())
		playSoundFrontEnd(root, 13)
		local r, g, b = self:getTeamColor()
		for _,p in ipairs(getPlayersInTeam(getPlayerTeam(player))) do
			showMessage("Your team grabbed the enemy's flag!", r, g, b, p)
		end
		for _,p in ipairs(getPlayersInTeam(self:getTeam().Team)) do
			showMessage("The enemy has grabbed your flag!", r, g, b, p)
		end
		if not self.dropped then
			triggerEvent('onCTFFlagTaken', self:getCarrier())
		end
	end
end
addEvent('onCTFFlagTaken')

function Flag:hitBaseCol(player)
	local playerFlag = g_CurrentRaceMode:getFlagCarriedBy(player)
	for k, flag in ipairs(Flag.instances) do 
		if flag:getCarrier() == player then
			playerFlag = flag
		end
	end
	-- outputDebugString(getPlayerName(player) .. '(' .. getTeamName(getPlayerTeam(player)) .. ') hit the base of the ' .. self:getTeam().name .. '(snatching=' .. tostring(g_CurrentRaceMode:isFlagSnatchingAllowed()) ..')' .. '(flag=' .. tostring(playerFlag and playerFlag:getTeamName()) ..')')
	-- if playerFlag and playerFlag ~= self and not g_CurrentRaceMode:isFlagSnatchingAllowed() and getPlayerTeam(player) == self:getTeam().Team then
	if playerFlag and playerFlag ~= self and getPlayerTeam(player) == self:getTeam().Team then
		playerFlag:resetToBase()
		playSoundFrontEnd(root, 28)
		local r, g, b = self:getTeamColor()
		for _,p in ipairs(getPlayersInTeam(getPlayerTeam(player))) do
			showMessage("The enemy has delivered your flag!", r, g, b, p)
		end
		for _,p in ipairs(getPlayersInTeam(self:getTeam().Team)) do
			showMessage("Your team delivered the enemy flag!", r, g, b, p)
		end
		triggerEvent('onCTFFlagDelivered', player)
		g_CurrentRaceMode:addPoint(self:getTeam(), player)
	end
end
addEvent('onCTFFlagDelivered')


function Flag:isTakeAble()
	return g_CurrentRaceMode:isFlagSnatchingAllowed() or self.dropped
end

function Flag:dropFlag(player)
	if (player ~= self:getCarrier()) then return outputDebugString('Flag:dropFlag; wrong player! ' .. self:getTeamName() .. ' player=' .. tostring(isElement(player) and getPlayerName(player))) end
	if isVehicleOnGround(self:getCarrierVeh()) then
		if getElementAttachedTo(self:getObject()) then
			detachElements(self:getObject())
		end
		local x, y, z = getElementPosition(player)
		self:setPosition(x, y, z)
		local r, g, b = self:getTeamColor()
		showMessage(self:getTeamName() .. '\'s flag was dropped. Returning the flag in 20 secs!', r, g, b)
		self:setCarrier(false)
		self:startDroppedTimer()
		self.dropped = true

		local teamName = self:getTeamName()
		triggerEvent("onCTFFlagDropped",player)
	else
		self:resetToBase()
	end
end
addEvent("onCTFFlagDropped")

function Flag.hit(hitElement)
	if not (getElementType(hitElement) == 'vehicle' and getVehicleController(hitElement)) then return end
	for k, v in pairs(Flag.instances) do
		if (v:getColshape() == source) then
			return v:hitColshape(getVehicleController(hitElement))
		elseif (v:getBaseColshape() == source) then
			return v:hitBaseCol(getVehicleController(hitElement))
		end
	end
end

function Flag:resetToBase()
	if getElementAttachedTo(self:getObject()) then
		detachElements(self:getObject())
	end
	
	local pos = self:getBase()
	self:setPosition(pos.x, pos.y, pos.z)
	playSoundFrontEnd(root, 14)
	showMessage(self:getTeamName() .. "\'s flag has been returned to base!", self:getTeamColor())
	self:setCarrier(false)
	g_CurrentRaceMode:setFlagTaken(self, false)
	self:resetTimers()
	triggerEvent("onCTFFlagReturned",getTeamFromName(self:getTeamName()))
end
addEvent("onCTFFlagReturned")

function Flag:setPosition(x, y, z)
	setElementPosition(self:getObject(), x, y, z)
end

function Flag:startCarrierTimer(player)
	self:resetTimers()
	self.carrierTimer = Countdown.create(60, self.onCarrierTimerEnd, "Time to deliver the flag: ", 0, 255, 0, 0.05, 2, true, self)
	self.carrierTimer:start(player)
	-- outputDebugString(self:getTeamName() .. "\'s flag return timer started " .. tostring(self.carrierTimer))
end

function Flag:onCarrierTimerEnd()
	-- outputDebugString(self:getTeamName() .. "\'s flag return timer ended, resetting")
	self:resetToBase()
end

function Flag:startDroppedTimer()
	self:resetTimers()
	local r, g, b = self:getTeamColor()
	self.droppedTimer = Countdown.create(20, self.onDroppedTimerEnd, self:getTeamName() .. "\'s flag returns in: ", r, g, b, 0.10, 2.5, true, self)
	self.droppedTimer:start()
	-- outputDebugString(self:getTeamName() .. "\'s flag dropped timer started " .. tostring(self.droppedTimer))
end

function Flag:onDroppedTimerEnd()
	-- outputDebugString(self:getTeamName() .. "\'s flag dropped timer ended, resetting")
	self:resetToBase()
end

function Flag:resetTimers()
	for id,countdown in pairs(Countdown.instances) do
		if countdown == self.carrierTimer then
			self.carrierTimer:destroy()
			self.carrierTimer = nil
			-- outputDebugString(self:getTeamName() .. "\'s flag return timer removed")
			break
		end
	end
	for id,countdown in pairs(Countdown.instances) do
		if countdown == self.droppedTimer then
			self.droppedTimer:destroy()
			self.droppedTimer = nil
			-- outputDebugString(self:getTeamName() .. "\'s flag dropped timer removed")
			break
		end
	end
	self.dropped = false
end

function Flag:setCarrier(player)
	if player == false then
		self.carrier = nil
		clientCall(root, 'ctfCarrier', self:getTeam().Team, nil)
	elseif isElement(player) then
		self.carrier = player
		attachElements(self:getObject(), getPedOccupiedVehicle(player), 0, 0, 2)
		clientCall(root, 'ctfCarrier', self:getTeam().Team, self:getCarrier())
	end
end

function Flag:destroy()
	local destroy = {
		self:getBaseColshape(),
		self:getColshape(),
		self:getMarker(),
		self:getBaseMarker(),
		self:getBlip(),
		self:getObject(),
	}
	for _, v in ipairs(destroy) do
		if v and isElement(v) then destroyElement(v) end
	end
	
	self:resetTimers()
	self.carrier = nil
	self.teamTable = nil
	
	Flag.instances[self.id] = nil
end

function Flag:getCarrier()
	return isElement(self.carrier) and self.carrier or false
end

function Flag:getCarrierName()
	return isElement(self.carrier) and getPlayerName(self.carrier) or false
end

function Flag:getCarrierVeh()
	return (isElement(self.carrier) and g_CurrentRaceMode.getPlayerVehicle(self.carrier) ) and g_CurrentRaceMode.getPlayerVehicle(self.carrier) or false
end

function Flag:getObject()
	return self.object
end

function Flag:getColshape()
	return self.col
end

function Flag:getBaseColshape()
	return self.basecol
end

function Flag:getBaseMarker()
	return self.basemarker
end

function Flag:getMarker()
	return self.marker
end

function Flag:getBlip()
	return self.blip
end

function Flag:getTeam()
	return self.teamTable
end

function Flag:getTeamName()
	return self.teamTable.name
end

function Flag:getTeamColor()
	return self.teamTable.r, self.teamTable.g, self.teamTable.b
end

function Flag:getBase()
	return self.base
end

addEvent("ctf_clientVehChange",true)
local function receiveVehSwitch()
	if getElementType(client) ~= "player" then return end
	clientCall(root,'applyTeamColorShader',client) 
end
addEventHandler("ctf_clientVehChange",root,receiveVehSwitch)