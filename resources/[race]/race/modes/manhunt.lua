Manhunt = setmetatable({}, RaceMode)
Manhunt.__index = Manhunt

Manhunt:register('Manhunt')

Manhunt.modeOptions = {
	duration = 5 * 60 * 1000,
	respawn = 'timelimit',
	respawntime = 5,
	autopimp = true,
	vehicleweapons = true,
}

Manhunt.name = 'Manhunt'
Manhunt.VictimTeamName = "Victim"
Manhunt.VictimColor = {0, 255, 0}
Manhunt.ManhuntersTeamName = "Manhunters"
Manhunt.ManhuntersColor = {255, 255, 255}
Manhunt.DamageList = {}

function Manhunt:isMapValid()
	if self.getNumberOfCheckpoints() > 0 then
		outputRace('Error. Manhunt map shouldn\'t have checkpoints')
		return false 
	end
	return true
end

function Manhunt:start()
	self:cleanup()
	addEventHandler("onManhuntVictimReportsDamage", resourceRoot, self.receiveDamageList)
	Manhunt.victimMarkerFadeTimer = setTimer(self.victimMarkerSizer, 20, 0)
	exports.scoreboard:removeScoreboardColumn('race rank')
	exports.scoreboard:removeScoreboardColumn('checkpoint')

	local vr, vg, vb = unpack(Manhunt.VictimColor)
	Manhunt.VictimTeam = createTeam ( Manhunt.VictimTeamName, vr, vg, vb )
	
	local mr, mg, mb = unpack(Manhunt.ManhuntersColor)
	Manhunt.ManhuntersTeam = createTeam ( Manhunt.ManhuntersTeamName, mr, mg, mb )
end

function Manhunt:onPlayerJoin(player, spawnpoint)
	self.checkpointBackups[player] = {}
	self.checkpointBackups[player][0] = { vehicle = spawnpoint.vehicle, position = spawnpoint.position, rotation = {0, 0, spawnpoint.rotation}, velocity = {0, 0, 0}, turnvelocity = {0, 0, 0}, geardown = true }
	local idx
	for i =1, #g_Spawnpoints do
		if g_Spawnpoints[i] == spawnpoint then 
			idx = i
			break
		end
	end
	if not self:getVictim() then
		self:setVictim(player, true)
	else
		self:setHunter(player)
	end
	bindKey(player, 'mouse2', 'both', self.handleDriveBy, self)
	-- clientCall(player, 'ctfStart', self.red.Flag:getObject(), self.blue.Flag:getObject())
end

function Manhunt:restorePlayer(id, player, bNoFade, bDontFix)
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
        setElementAngularVelocity( vehicle, 0,0,0 )
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

	if (self:getVictim() ~= player) then
		self:setHunter(player)
	end
end

function Manhunt.handleDriveBy(player, key, state, self)
	if not ( g_CurrentRaceMode.running and getElementData(player, 'state') == 'alive' and (getPedWeaponSlot(player) == 2 or getPedWeaponSlot(player) == 4) ) then
		return
	end
	if state == 'down' and not isPedDoingGangDriveby(player) then
		Manhunt.drivebyDelay[player] = getTickCount()
		setPlayerHudComponentVisible(player, 'ammo', true)
		setPedDoingGangDriveby(player, true)	
	elseif state == 'up' then
		if Manhunt.drivebyDelay[player] and getTickCount() - Manhunt.drivebyDelay[player] > 250 then
			setPedDoingGangDriveby(player, false)
			setPlayerHudComponentVisible(player, 'ammo', false)
		end
	elseif state == 'down' and isPedDoingGangDriveby(player) then
		setPedDoingGangDriveby(player, false)
		setPlayerHudComponentVisible(player, 'ammo', false)
	end	
end

function Manhunt:setHunter(player)
	takeAllWeapons(player)
	giveWeapon(player, 22, 100, true)
	setPlayerTeam(player, Manhunt.ManhuntersTeam)
end

function Manhunt:setVictim(player, bInit, oldVictim)
	clientCall(root, "Manhunt.startDamageDetection", false )
	clientCall(player, "Manhunt.startDamageDetection", true )
	Manhunt.DamageList = {}
	if isPlayerSpectating(player) then
		clientCall(player, "Spectate.stop", 'auto' )
		self.restorePlayer(self,self.id,player)
	end
	self:clearPickupBlips()
	if self:getVictim() then
		self:setHunter(self:getVictim())
		Manhunt.Victim = nil
	end
	takeAllWeapons(player)
	giveWeapon(player, 32, 300, true)
	setPlayerTeam(player, Manhunt.VictimTeam)
	local veh = g_CurrentRaceMode.getPlayerVehicle( player )
	if isElement(oldVictim) and g_CurrentRaceMode.getPlayerVehicle( oldVictim ) then
		setVehicleID(veh, getElementModel( g_CurrentRaceMode.getPlayerVehicle( oldVictim ) ))
	end
	local r, g, b = unpack(Manhunt.VictimColor)
	setVehicleColor(veh, r, g, b, r, g, b, r, g, b, r, g, b)
	if Manhunt.VictimBlip and isElement(Manhunt.VictimBlip) then destroyElement(Manhunt.VictimBlip) end
	if Manhunt.victimMarker and isElement(Manhunt.victimMarker) then destroyElement(Manhunt.victimMarker) end
	Manhunt.victimMarker = createMarker(0, 0, -100, "arrow", 1.5, 0, 255, 0, 150)
	attachElements(Manhunt.victimMarker, getPedOccupiedVehicle(player), 0, 0, 4)
	Manhunt.VictimBlip = createBlipAttachedTo(player, 60, 1.5, 200, 200, 200)
	self:addPickupBlips(player)
	Manhunt.Victim = player
	--outputDebugString('new victim: ' .. getPlayerName(player))
	if not bInit then 
		-- pick random spawnpoint for next victim
		local spawnpoint = self:pickFreeSpawnpoint()
		local bkp = {}
		bkp.position = spawnpoint.position
		bkp.rotation = {0, 0, spawnpoint.rotation}
		bkp.geardown = true                 -- Fix landing gear state
		bkp.vehicle = spawnpoint.vehicle    -- Fix spawn'n'blow
		setElementVelocity( veh, 0,0,0 )
		setElementAngularVelocity( veh, 0,0,0 )
		setElementPosition(veh, unpack(bkp.position))
		local rx, ry, rz = unpack(bkp.rotation)
		setElementRotation(veh, rx or 0, ry or 0, rz or 0)
		removeVehicleUpgrade(veh, 1010) -- remove nitro
			
		-- Fix up vehicle
		fixVehicle(veh)
		setVehicleDamageProof(veh, true)
		setTimer(setVehicleDamageProof, 3000, 1, veh, false)
		local marker = createMarker(0,0,0, 'corona', 4, 0, 0, 255, 150, root)
		attachElements(marker, veh)
		setTimer(destroyElement, 3000, 1, marker)
		setTimer(showMessage, 1500, 1, self:getVictimName() .. ' is now everybody\'s next Victim! Kill him!', 0, 255, 0)
	end
end

function Manhunt:getVictim()
	return Manhunt.Victim and isElement(Manhunt.Victim) and Manhunt.Victim or false
end

function Manhunt:getVictimName()
	return self:getVictim() and getPlayerName(self:getVictim())
end

function Manhunt:checkVictim(player, bLeft)
	if self:getVictim() == player then
		local new = self:pickNewVictimFrom(player)
		if not bLeft then
			self:addTime(player)
		end
		if new then
			self:setVictim(new, false, player)
		else
			self:endMap()
		end
	end
end

local fadeDir = "down"
local sizeMin = 0.4
local sizeMax = 1.2
function Manhunt.victimMarkerSizer()
	if (isElement(Manhunt.victimMarker)) then
		local fSize = getMarkerSize(Manhunt.victimMarker)
		if (fadeDir == "down" and fSize <= sizeMin) then 
			fadeDir = "up"
		elseif (fadeDir == "up" and fSize >= sizeMax) then
			fadeDir = "down"
		end
		setMarkerSize(Manhunt.victimMarker, fadeDir == "up" and fSize + 0.025 or fSize - 0.025)
	end
end

function Manhunt.receiveDamageList(list)
	-- Validate client to victim then overwrite
	if client == Manhunt.getVictim() and list then
		table.sort(list, function(a,b) return a.damage > b.damage end)
		Manhunt.DamageList = list
	end
end
addEvent("onManhuntVictimReportsDamage", true)


function Manhunt:pickNewVictimFrom(player)
	-- Pick top from damage list
	if (Manhunt.DamageList and #Manhunt.DamageList > 0) then
		-- Remove invalid players from damage list
		for i = #Manhunt.DamageList, 1, -1 do
			local player = Manhunt.DamageList[i].player
			local damage = Manhunt.DamageList[i].damage
			if not isElement(player) or getElementData(player, 'player state') == 'away' then
				table.remove(Manhunt.DamageList, i)
			end
		end
		
		if (#Manhunt.DamageList > 0) then
			-- Reward players with top 3 kill
			triggerEvent("onManhuntVictimKillList", root, Manhunt.DamageList)
			-- Pick first valid player as next victim
			for i, v in ipairs(Manhunt.DamageList) do
				return v.player
			end
		end

	end

	-- If we could not pick from damage list, use old method
	local activePlayers = getActivePlayers()
	--outputDebugString('picking new victim from ' .. #activePlayers .. ' activePlayers')
	local filtered = {}
	for k, v in ipairs(activePlayers) do
		-- if player ~= v and not isPlayerSpectating(v) and not (getElementData(v, 'state') ~= 'alive' or getElementHealth(v) == 0 or isPedDead(v)) then
		-- 	table.insert(filtered, v)
		-- end
		if player ~= v and getElementData(v, 'player state') ~= 'away' then
			table.insert(filtered, v)
		end
	end
	--outputDebugString('picking new victim from ' .. #filtered .. ' filtered')
	if #filtered < 1 then
		-- --outputDebugString('not enough players for a new victim, return false to stop the map')
		return false
	end
	
	local shortest = 100000
	local victim
	local pos1 = {getElementPosition(player)}
	for _, p in ipairs(filtered) do
		if p ~= player then
			local pos2 = {getElementPosition(p)}
			local dist = getDistanceBetweenPoints3D(pos1[1], pos1[2], pos1[3], pos1[1], pos1[2], pos1[3])
			if dist < shortest then
				dist = shortest
				victim = p
			end
		end
	end
	if victim then return victim end
	
	repeat
		victim = filtered[math.random(1, #filtered)]
	until victim and isElement(victim) and victim ~= player
	return victim
end

function Manhunt:timeout()
	self:addTime(self:getVictim())
end

function Manhunt:addTime(player)
	-- if not g_CurrentRaceMode.running then return end
	clientCall(g_Root, 'resetTimePassed') 
	local time = self.victimTick and (getTickCount() - self.victimTick) or self:getTimePassed()
	self.victimTick = getTickCount()
	local i = table.find(self.toptimes, 'player', player)
	if not i then
		table.insert(self.toptimes, {player = player, name = getPlayerName(player), time = time})
	elseif self.toptimes[i].time < time then 
		self.toptimes[i] = {player = player, name = getPlayerName(player), time = time}
	else
		return --outputDebugString('time was not improved')
	end
	table.sort(self.toptimes, function(a,b) return a.time > b.time end)

	triggerEvent( "onPlayerFinishManhunt", player, time)
end

function Manhunt:addPickupBlips(player)
	Manhunt.VictimPickupBlips = {}
	for _, pickup in ipairs(getElementsByType 'racepickup') do
		local blip = nil
		local x, y, z = getElementPosition(pickup)
		local type = getElementData(pickup, 'type')
		if type == 'repair' then
			blip = createBlip(x,y,z, 27, 2, 255, 255, 255, 255, 0, 99999.0, player)
		elseif type == 'nitro' then
			blip = createBlip(x,y,z, 42, 2, 255, 255, 255, 255, 0, 99999.0, player)		
		end
		if blip then 
			table.insert(Manhunt.VictimPickupBlips, blip)
		end
	end
end

function Manhunt:clearPickupBlips()
	for _, v in ipairs(Manhunt.VictimPickupBlips) do
		if v and isElement(v) then destroyElement(v) end
	end
	Manhunt.VictimPickupBlips = {}
end

function Manhunt:onPlayerPickUpRacePickup(player, pickup)
	if pickup.type == 'vehiclechange' then
		if player == self:getVictim() then
			local r, g, b = unpack(Manhunt.VictimColor)
			setVehicleColor(g_CurrentRaceMode.getPlayerVehicle(player), r, g, b, r, g, b, r, g, b, r, g, b)
		end
	elseif pickup.type == 'repair' then
		takeAllWeapons(player)
		giveWeapon(player, player == self:getVictim() and 32 or 22, 300, true)
	end
end

function Manhunt:onPlayerWasted(player)
	self:checkVictim(player)
	
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

function Manhunt:onPlayerQuit(player)
	self:checkVictim(player, false)

	self.checkpointBackups[player] = nil
	removeActivePlayer( player )
	if g_MapOptions.respawn == 'none' then
		if getActivePlayerCount() < 1 and g_CurrentRaceMode.running then
			self:endMap()
		end
	end
end

function Manhunt:playerSpectating(player)
	self:checkVictim(player)
end

function Manhunt:isRanked()
	return false
end

function Manhunt:cleanup()
	-- Cleanup for next mode
	removeEventHandler("onManhuntVictimReportsDamage", resourceRoot, self.receiveDamageList)
	for k, v in ipairs(getElementsByType'player') do
		if isKeyBound(v, 'mouse2', 'down', self.handleDriveBy) then
			unbindKey(v, 'mouse2', 'both', self.handleDriveBy)
		end
	end
	if (Manhunt.victimMarkerFadeTimer and isTimer(Manhunt.victimMarkerFadeTimer)) then
		killTimer(Manhunt.victimMarkerFadeTimer)
	end

	if Manhunt.victimMarker and isElement(Manhunt.victimMarker) then destroyElement(Manhunt.victimMarker) end
	Manhunt.drivebyDelay = {}
	Manhunt.toptimes = {}
	if Manhunt.VictimBlip and isElement(Manhunt.VictimBlip) then destroyElement(Manhunt.VictimBlip) end
	Manhunt.Victim = nil
	if isElement(Manhunt.VictimTeam) then 
		destroyElement(Manhunt.VictimTeam) 
		Manhunt.VictimTeam = nil
	end
	if isElement(Manhunt.ManhuntersTeam) then 
		destroyElement(Manhunt.ManhuntersTeam) 
		Manhunt.ManhuntersTeam = nil
	end
	
	self:clearPickupBlips()
end

function Manhunt:endMap()
	if self.toptimes[1] then
		showMessage('Longest survivor ' .. self.toptimes[1].name .. ' wins!', 0, 255, 0)
		triggerEvent( "onManhuntRoundEnded", root, self.toptimes )
	end

	self:cleanup()
    RaceMode.endMap(self)
end
addEvent('onManhuntRoundEnded')

function Manhunt:destroy()
	self:cleanup()
	
	exports.scoreboard:scoreboardAddColumn("race rank", root, 40, "Rank", 4)
	exports.scoreboard:scoreboardAddColumn("checkpoint", root, 77, "Checkpoint", 5)

	-- if self.rankingBoard then
	-- 	self.rankingBoard:destroy()
	-- 	self.rankingBoard = nil
	-- end
	TimerManager.destroyTimersFor("checkpointBackup")
	RaceMode.instances[self.id] = nil
end

Manhunt.Victim = nil
Manhunt.VictimTeam = nil
Manhunt.VictimBlip = nil
Manhunt.VictimPickupBlips = {}
Manhunt.ManhuntersTeam = nil
Manhunt.drivebyDelay = {}
Manhunt.rankingBoard = nil
Manhunt.toptimes = {}
