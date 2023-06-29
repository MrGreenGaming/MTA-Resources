Shooter = setmetatable({}, RaceMode)
Shooter.__index = Shooter

Shooter:register('Shooter')

-- Options
local shooterJumpHeight = 0.25 -- Standard shooter jump height
local shooterAutoRepairTimer = false


local shooterMode = "shooter"
function getShooterMode()
	return shooterMode
end

function Shooter:isApplicable()
	return not self.checkpointsExist() --and self.getMapOption('respawn') == 'none'
end

Shooter.playerRanks = {}
function Shooter:getPlayerRank(player)
	if shooterMode == "shooter" then
		return #getActivePlayers()
	elseif shooterMode == "cargame" then
		for rank,p in ipairs(Shooter.playerRanks) do
			if player == p then
				-- outputChatBox("p: "..getPlayerName(player).."   : "..tostring(rank))
				return rank
			end
		end
		return #getActivePlayers()
	end
end

-- Copy of old updateRank
function Shooter:updateRanks()
	if shooterMode == "shooter" then
		for i,player in ipairs(g_Players) do
			if not isPlayerFinished(player) then
				local rank = self:getPlayerRank(player)
				if not rank or rank > 0 then
					setElementData(player, 'race rank', rank)
				end
			end
		end
		-- Make text look good at the start
		if not self.running then
			for i,player in ipairs(g_Players) do
				setElementData(player, 'race rank', '' )
				setElementData(player, 'checkpoint', '' )
			end
		end
	elseif shooterMode == "cargame" then


		local pTable = getActivePlayers()
		for i,p in ipairs(pTable) do

			if not Shooter.playerLevels[p] then return table.remove(pTable,i) end
			if not Shooter.playerLevels[p].level then return table.remove(pTable,i) end
		end

		if #pTable > 1 then
			table.sort(pTable,
				function(a,b)
					local levelA = Shooter.playerLevels[a].level or 1
					local levelAtime = Shooter.playerLevels[a].levelTime or getTickCount()
					local levelB = Shooter.playerLevels[b].level or 1
					local levelBtime = Shooter.playerLevels[b].levelTime or getTickCount()

					if levelA == levelB then
						return levelAtime < levelBtime
					else
						return levelA > levelB
					end
					-- return levelA > levelB or (levelA == levelB and levelAtime < levelBtime )

				end)
		end

		Shooter.playerRanks = pTable

		for rank,player in ipairs(pTable) do
			setElementData(player,"race rank",rank)
		end

		return pTable

	end
end


function Shooter:timeout()
	if shooterMode == "cargame" then
		Shooter:handlePlayerWin(self:updateRanks()[1],Shooter.playerLevels)
	else
		local activePlayers = getActivePlayers()

		if #activePlayers == 2 then
			if type(getElementData(activePlayers[1], "kills")) == "number" and type(getElementData(activePlayers[2], "kills")) == "number" then
				--outputChatBox(getPlayerName(activePlayers[1])..": "..getElementData(activePlayers[1], "kills").." - "..getPlayerName(activePlayers[2])..": "..getElementData(activePlayers[2], "kills"))
				if getElementData(activePlayers[1], "kills") < getElementData(activePlayers[2], "kills") then
					self:handleFinishActivePlayer(activePlayers[1])
				elseif getElementData(activePlayers[2], "kills") < getElementData(activePlayers[1], "kills") then
					self:handleFinishActivePlayer(activePlayers[2])
				end
			elseif type(getElementHealth(getPedOccupiedVehicle(activePlayers[1]))) == "number" and type(getElementHealth(getPedOccupiedVehicle(activePlayers[2]))) == "number" then
				--outputChatBox(getPlayerName(activePlayers[1])..": "..getElementHealth(getPedOccupiedVehicle(activePlayers[1])).." - "..getPlayerName(activePlayers[2])..": "..getElementHealth(getPedOccupiedVehicle(activePlayers[2])))
				if getElementHealth(getPedOccupiedVehicle(activePlayers[1])) < getElementHealth(getPedOccupiedVehicle(activePlayers[2])) then
					self:handleFinishActivePlayer(activePlayers[1])
				elseif getElementHealth(getPedOccupiedVehicle(activePlayers[2])) < getElementHealth(getPedOccupiedVehicle(activePlayers[1])) then
					self:handleFinishActivePlayer(activePlayers[2])
				end
			else
				self:handleFinishActivePlayer(activePlayers[math.random(1, 2)])
			end
		elseif #activePlayers >= 2 then
			for i=1, #activePlayers do
				self:handleFinishActivePlayer(activePlayers[i])
			end
		end
	end
end



addEvent("onCarGamePlayerKill")
function Shooter:onPlayerKilled(killer,suicide)
	if shooterMode == "cargame" then

		if getElementType(source) == "player" then

			-- setTimer(outputChatBox,500,50,getElementType(source) or type(source))
			-- local victim = source

			local a = getPlayerName(source)
			local b = getPlayerName(killer)

			if killer == source or suicide then -- If player kmz
				setElementData(source,"cg_suicideChecker",true)
				Shooter:onPlayerSuicide(source)
				if killer ~= source then
					exports.messages:outputGameMessage("You killed " .. a, killer, 2.5, 255, 255, 255)
				end
			else

				exports.messages:outputGameMessage("You got killed by " .. b, source, 2.5, 255, 255, 255)
				exports.messages:outputGameMessage("You killed " .. a, killer, 2.5, 255, 255, 255)

				setElementData(source,"cg_suicideChecker",false)



				if killer and killer ~= source then
					Shooter.firstKill = false
					Shooter:handleLevelChange(killer,1)
				end
			end
		end

	end
end
addEvent('cargamekill', true)
addEventHandler('cargamekill', root, Shooter.onPlayerKilled)


function Shooter:onPlayerSuicide(player) -- Checks and handles if player suicided
	setTimer(function()
		if getElementData(player,"cg_suicideChecker") ~= false then -- false = no suicide

			if Shooter.playerRespawnTimers[player] then
				Shooter.playerRespawnTimers[player]:destroy()
	        	Shooter.playerRespawnTimers[player] = Countdown.create(15, g_CurrentRaceMode.restorePlayer, '(Suicide) You will respawn in:', 255, 0, 0, 0.25, 2.5, true, g_CurrentRaceMode, g_CurrentRaceMode.id, player)
	        	Shooter.playerRespawnTimers[player]:start(player)
	        	TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
	    	end
		end
		setElementData(player,"cg_suicideChecker",nil)
	end,250,1)
end
addEvent("onRacePlayerSuicide")
addEventHandler("onRacePlayerSuicide",root,
	function()
		if Shooter.UpdateLevels and shooterMode == "cargame" then
			Shooter:onPlayerSuicide(source)
		end
	end)


function Shooter:onPlayerWasted(player)
	if shooterMode == "cargame" then




		local respawnTime       = Shooter.getMapOption('respawntime')

	    if self:getTimeRemaining() - respawnTime > 3000 then
	        Shooter.playerRespawnTimers[player] = Countdown.create(respawnTime/1000, self.restorePlayer, 'You will respawn in:', 255, 255, 255, 0.25, 2.5, true, self, self.id, player)
	        Shooter.playerRespawnTimers[player]:start(player)
	    end



		if isKeyBound(player, 'vehicle_fire', 'down', self.shoot) then
			unbindKey(player, 'vehicle_fire', 'both', self.shoot)
		end
		if isKeyBound(player, 'vehicle_secondary_fire', 'down', self.jump) then
			unbindKey(player, 'vehicle_secondary_fire', 'both', self.jump)
		end
		if isKeyBound(player, 'mouse2', 'down', self.jump) then
			unbindKey(player, 'mouse2', 'both', self.jump)
		end
		if isKeyBound(player, 'lshift', 'down', self.jump) then
			unbindKey(player, 'lshift', 'both', self.jump)
		end


	else
		if isActivePlayer(player) then
			self:handleFinishActivePlayer(player)
			if getActivePlayerCount() <= 1 then
				self:endMap()
			else
				local veh = g_CurrentRaceMode.getPlayerVehicle(player)
				local x, y, z = getElementPosition(veh)
				TimerManager.createTimerFor("map",player):setTimer(setElementPosition, 1950, 1, veh, x + 5000, y + 5000, z + 5000)
				TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
			end
		end
		self.setPlayerIsFinished(player)
		showBlipsAttachedTo(player, false)
		clientCall(player, 'showOnlyHealthBar', false)
		clientCall(player, 'initShooterClient', false)
	end
end


function Shooter:forceRespawnRestore()
	if shooterMode == "cargame" then
		return true
	end
	return false
end

function Shooter:playerSpectating(player)
	if shooterMode == "cargame" then
		-- Remove a level when player is spectating
		if Shooter.spawnProtectionCountdown[player] then
			Shooter.spawnProtectionCountdown[player]:destroy()
		end

		Shooter:handleLevelChange(player,-1)
	end
end

function Shooter:onPlayerJoin(player, spawnpoint)
	if shooterMode == "cargame" then

		-- set player levels table
		if not Shooter.playerLevels then
			Shooter.playerLevels = {}
		end
		local tick = getTickCount()
		Shooter.playerLevels[player] = {level = 1, addTick = tick}
		setElementData(player,"level",1)


		setVehicleID(self.getPlayerVehicle(player), Shooter._Levels[1])

		if Shooter.hasLaunched then

			clientCall(player, 'showLevelDX', true)
			clientCall(player, 'cgStart')
			clientCall(player, 'sh_initTimeBars')

			setTimer(function()
				if isPlayerSpectating(player) then
					clientCall(player, "Spectate.stop", 'auto' )
					self.restorePlayer(self,self.id,player)
				end
			end,5000,1)
			-- Countdown.create(1, self.restorePlayer, 'You will spawn in:', 255, 255, 255, 0.25, 2.5, true, self, self.id, player):start(player)
			setTimer(showMessage, 6500, 1, "Press fire to shoot rockets and alt-fire/rmb to jump!", 0, 0, 255, player)
		end

		if not self.cooldowns then self.cooldowns = {} end
		if not self.spawnProtection then self.spawnProtection = {} end



		local tick = getTickCount() + 5000


		bindKey(player, "vehicle_fire", "down", self.shoot)
		bindKey(player, "vehicle_secondary_fire", "down", self.jump)
		bindKey(player, "mouse2", "down", self.jump)
		bindKey(player, 'lshift', 'down', self.jump)
		self.cooldowns[player] = {shoot = tick, jump = tick}
		self.spawnProtection[player] = false



	    -- if self:getTimeRemaining() - respawnTime > 3000 then
	    -- end


	end

end

function Shooter:restorePlayer(id, player, bNoFade, bDontFix)
	if shooterMode == "cargame" then
		if not isValidPlayer(player) then
			return
		end
		if not bNoFade then
			clientCall(player, 'remoteStopSpectateAndBlack')
		end

		bindKey(player, "vehicle_fire", "down", self.shoot)
		bindKey(player, "vehicle_secondary_fire", "down", self.jump)
		bindKey(player, "mouse2", "down", self.jump)
		bindKye(player, "lshift", "down", self.jump)

		local bkp = {}
		local spawnpoint = self:pickFreeSpawnpoint(player)
		bkp.position = spawnpoint.position
		bkp.rotation = {0, 0, spawnpoint.rotation}
		bkp.geardown = true                 -- Fix landing gear state
		bkp.vehicle = spawnpoint.vehicle    -- Fix spawn'n'blow
		-- Validate some bkp variables
		if type(bkp.rotation) ~= "table" or #bkp.rotation < 3 then
			bkp.rotation = {0, 0, 0}
		end
		spawnPlayer(player, 0, 0, 0, 0, getElementModel(player))

		local vehicle = self.getPlayerVehicle(player)
		if vehicle then
			setVehicleDamageProof(vehicle,true)
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

			-- Set Player Level Vehicle
			local theVehLevel = Shooter._Levels[Shooter.playerLevels[player].level]
			setVehicleID(vehicle, theVehLevel)


			warpPedIntoVehicle(player, vehicle)

	        setVehicleLandingGearDown(vehicle,bkp.geardown)

			self:playerFreeze(player, true, bDontFix)
	        outputDebug( 'MISC', 'restorePlayer: setElementFrozen true for ' .. tostring(getPlayerName(player)) .. '  vehicle:' .. tostring(vehicle) )
	        removeVehicleUpgrade(vehicle, 1010) -- remove nitro
			TimerManager.destroyTimersFor("unfreeze",player)
			TimerManager.createTimerFor("map","unfreeze",player):setTimer(self.restorePlayerUnfreeze, 2000, 1, self, id, player, bDontFix)

			-- Set Spawn Protection
			self.spawnProtection[player] = true
			if Shooter.spawnProtectionCountdown[player] then
				Shooter.spawnProtectionCountdown[player]:destroy()
				Shooter.spawnProtectionCountdown[player] = nil
			end
			setTimer(function()
				-- Countdown.create(5, self.removeSpawnProtection, 'Spawn Protection will be removed in:', 255, 255, 255, 0.20, 2.5, true,self, self.id, player):start(player)
				setVehicleDamageProof(vehicle,true)
				-- Set control state so that forward and reverse arent pressed anymore (for spawn protection detection)
				bindKey(player, "accelerate", "down", startSpawnProtectionCountdown)
				bindKey(player, "brake_reverse", "down", startSpawnProtectionCountdown)
				toggleControl(player,"accelerate",false)
				toggleControl(player,"brake_reverse",false)


			end,2001,1)



			setElementData( player, "overrideCollide.cargame", 0 )
			setElementData( player, "overrideAlpha.cargame", 110 )
		end
	    setCameraTarget(player)
		setPlayerStatus( player, "alive", "" )
		clientCall(player, 'remoteSoonFadeIn', bNoFade )
	end
end

function startSpawnProtectionCountdown(player)
	if isPlayerSpectating(player) or not Shooter.UpdateLevels then return end
	if g_CurrentRaceMode:checkSpawnProtection(player) == true then
		unbindKey(player, "accelerate", "down", startSpawnProtectionCountdown)
		unbindKey(player, "brake_reverse", "down", startSpawnProtectionCountdown)
		toggleControl(player,"accelerate",true)
		toggleControl(player,"brake_reverse",true)
		g_CurrentRaceMode.spawnProtection[player] = "countdown"
		Shooter.spawnProtectionCountdown[player] = Countdown.create(5, Shooter.removeSpawnProtection, 'Spawn Protection will be removed in:', 255, 255, 255, 0.20, 2.5, true,g_CurrentRaceMode,player)
		Shooter.spawnProtectionCountdown[player]:start(player)



	else -- Only admins are able to spectate spam
		-- Bugged toggleControl fix (spectate spam?)
		toggleControl(player,"accelerate",true)
		toggleControl(player,"brake_reverse",true)
	end
end


function Shooter:removeSpawnProtection(player)

	if shooterMode == "cargame" then
		if not player then return end
		if not getElementType(player) == "player" then return end
		local vehicle = self.getPlayerVehicle(player)

		Shooter.spawnProtectionCountdown[player] = nil
		setVehicleDamageProof(vehicle,false)
		setElementData( player, "overrideCollide.cargame", nil )
		setElementData( player, "overrideAlpha.cargame", nil )
		self.spawnProtection[player] = false
	end
end

function Shooter:restorePlayerUnfreeze(id, player, bDontFix)
	if shooterMode == "cargame" then
		if not isValidPlayer(player) then
			return
		end
		self:playerUnfreeze(player, bDontFix)
		local vehicle = self.getPlayerVehicle(player)
	end

end


function Shooter:handlePlayerWin(p,lTab)
	if shooterMode == "cargame" then

		Shooter.UpdateLevels = false

		local pTable = self:updateRanks()


		local theTime = getTimePassed()


		local rankingTable = {}
		for i,player in ipairs(pTable) do
			local pName = getPlayerName(player)
			local t = {name = pName, player = player, level = lTab[player].level or 1, time = theTime, kills = getElementData(player,"kills") or 0, rank = i,name = getPlayerName(player) }
			table.insert(rankingTable,t)
		end



		showMessage(getPlayerName(p) .. ' won the game!', 0, 255, 0)
		triggerEvent( "onPlayerWinCarGame",p,rankingTable )
		Shooter.setMapOption("respawn","none")
		setTimer(function() self:endMap() end,10000,1)

	end
end
addEvent('onPlayerFinishCarGame')
addEvent('onPlayerWinCarGame')

function Shooter:onPlayerQuit(player)
	if isActivePlayer(player) then
		self:handleFinishActivePlayer(player)
		Shooter.playerLevels[player] = nil
		if getActivePlayerCount() <= 1 then
			self:endMap()
		end
	end
end



function Shooter:handleFinishActivePlayer(player)
	-- REMOVED rankingboard handler, now handled with events
	if shooterMode == "cargame" then

		finishActivePlayer(player)

		if #getActivePlayers() == 1 then

			Shooter:handlePlayerWin(getActivePlayers()[1],Shooter.playerLevels)

		end




	else

		local timePassed = self:getTimePassed()
		-- self.rankingBoard:add(player, timePassed)
		-- Do remove
		local rank = self:getPlayerRank(player)
		finishActivePlayer(player)
		if rank and rank > 1 then
			triggerEvent( "onPlayerFinishShooter",player,tonumber( rank ),timePassed )
		end
		-- Update ranking board if one player left
		local activePlayers = getActivePlayers()

		-- --? Reduces amount of time when 3 players are left to 1 minute (if 10 players are online)

		-- -- Amount of players required to be online to reduce the time
		-- local nRequiredPlayers = 10
		-- -- Time to reduce to in milliseconds
		-- local timeToReduce = 60 * 1000
		-- -- Amount of players left when to reduce
		-- local reduceWhenNPlayers = 3
		-- if #activePlayers == reduceWhenNPlayers and getPlayerCount() >= nRequiredPlayers then
		-- 	RaceMode.setTimeLeft(self, timeToReduce)
		-- end

		if #activePlayers == 1 then
			-- self.rankingBoard:add(activePlayers[1], timePassed)
			showMessage((string.gsub((getElementData(activePlayers[1], 'vip.colorNick') or getPlayerName(activePlayers[1])), '#%x%x%x%x%x%x', '')) .. ' is the final survivor!', 0, 255, 0)
			triggerEvent( "onPlayerWinShooter",activePlayers[1],1,timePassed )
		end
	end
end
addEvent('onPlayerFinishShooter')
addEvent('onPlayerWinShooter')

function Shooter:launch()
	RaceMode.launch(self)

    local activePlayers = getActivePlayers()
    _outputChatBox("[DEBUG] There are " .. #activePlayers .. " active players in the server", root, 255, 0, 0);
	if #activePlayers <= 1 then
        _outputChatBox("You are the only active player in the server, you can't play Shooter alone!", root, 255, 0, 0);
        self:endMap();
    end

	-- Read jump height from map
	local jumpHeightSetting = (getNumber(g_MapInfo.resname..".shooter_jumpheight",0.25))
	if jumpHeightSetting ~= 0.25 then
		-- Map has different setting for jump height
		-- Check if its within range
		if jumpHeightSetting then
			jumpHeightSetting = jumpHeightSetting / 10
		end
		local minJumpHeight = 0.2
		local maxJumpHeight = 1.1
		if not jumpHeightSetting then
			jumpHeightSetting = shooterJumpHeight
		elseif jumpHeightSetting < minJumpHeight or jumpHeightSetting > maxJumpHeight then
			outputDebugString('Shooter: Map has a custom jump height, but is is outside of accepted range (Map setting: '..(jumpHeightSetting*10)..', min: - '..(minJumpHeight*10)..', max: '..(maxJumpHeight*10)..')')
			jumpHeightSetting = shooterJumpHeight
		else
			outputDebugString('Shooter: Map has set custom jump height to: '..(jumpHeightSetting*10))
		end
	end

	-- Check and init auto repair
	local autoRepairSetting = getBool(g_MapInfo.resname..".shooter_autorepair",false)
	if autoRepairSetting then
		if isTimer(shooterAutoRepairTimer) then
			killTimer(shooterAutoRepairTimer)
		end
		-- Set auto repair timer
		outputDebugString('Shooter: Auto repair initiated')
		shooterAutoRepairTimer = setTimer( Shooter.autoRepair, 500, 0)
	end

	-- Send jump height and autorepair to clients
	clientCall(root, 'clientReceiveShooterSettings', jumpHeightSetting or false, autoRepairSetting)

	if shooterMode == "cargame" then
		Shooter.hasLaunched = true
		clientCall(root, 'showLevelDX', true)
		clientCall(root, 'cgStart')
	-- Set Level 1 vehicle for everyone
		for _,player in ipairs(getActivePlayers()) do
			local veh = self.getPlayerVehicle(player)
			if getElementModel(veh) ~= Shooter._Levels[1] then
				setVehicleID(veh, Shooter._Levels[1])
			end

		end

		-- if math.random(2) == 1 then clientCall(g_Root, 'showOnlyHealthBar', true) end
		cg_noShootTimer = setTimer(showMessage, 4500, 1, "Press fire to shoot rockets and alt-fire/rmb to jump!", 0, 0, 255, root)
		setTimer(function() clientCall(g_Root, 'sh_initTimeBars') end,4500,1)
	else
		--if math.random(2) == 1 then clientCall(g_Root, 'showOnlyHealthBar', true) end -- Use this to hide names 50% of the time
		clientCall(g_Root, 'showOnlyHealthBar', true) -- Use this to hide names 100% of the time
		-- Add binds for rockets/jumps and cooldown at start
		self.cooldowns = {}
		local tick = getTickCount() + 5000
		for k, player in ipairs(getActivePlayers()) do

			-- bindKey(player, "vehicle_fire", "down", self.shoot)
			-- bindKey(player, "vehicle_secondary_fire", "down", self.jump)
			-- bindKey(player, "mouse2", "down", self.jump)
			-- bindKey(player, 'lshift', 'down', self.jump)
			self.cooldowns[player] = {shoot = tick, jump = tick}
		end

		if isTimer(launchTimer) then killTimer(launchTimer) end
		launchTimer = setTimer(function()
			showMessage("Press fire to shoot rockets and alt-fire/rmb/lshift to jump!", 0, 0, 255, root)
			clientCall(g_Root, 'initShooterClient', true)
			clientCall(g_Root, 'sh_initTimeBars')
			KillDzinyMaster()
		end,4500,1)
	end
end


Shooter.__Levels = { -- cache Levels with all possible vehicles in it, will get chosen in .launch
	[1] = {411},
	[2] = {429,411,541,559,415,561,480,560,562,506,565,451,434,558,494,555,502,477,503}, -- Street Racers
	[3] = {445,467,604,426,507,547,585,405,587,409,466,550,492,566,546,540,551,421,516,529}, -- 4-Door and Luxury cars
	[4] = {602,545,496,517,401,410,518,600,527,436,589,580,419,439,533,549,526,491,474}, -- 2-Door and Compact cars
	[5] = {402,542,603,475}, -- Muscle Cars
	[6] = {536,575,534,567,535,576,412}, -- Lowriders
	[7] = {459,543,422,482,478,605,554,418,582,413,440}, -- Light Trucks and Vans
	[8] = {459,543,422,482,478,605,554,418,582,413,440,536,575,534,567,535,576,412,402,542, -- Mix of previous
		   603,475,602,545,496,517,401,410,518,600,527,436,589,580,419,439,533,549,526,491,474,411,429, -- Mix of previous
		   411,541,559,415,561,480,560,562,506,565,451,434,558,494,555,502,477,503,445,467,604,426,507, -- Mix of previous
		   547,585,405,587,409,466,550,492,566,546,540,551,421,516,529}, -- Mix of previous

	[9] = {581,522,461,462,448,521,468,463,586}, -- Bikes
	[10] = {432,432}, -- Max Level (when player reaches this level, game ends)
}

function Shooter:start()
	local currentMap = exports.mapmanager:getRunningGamemodeMap()
	--Uncomment this if you want to make SH->CG->SH order (1st round SH, 2nd CG, 3rd SH)
	--[[local round = (times[currentMap] or 0) + 1
	if round == 1 then
		shooterMode = "shooter"
	elseif round == 2 or round > 3 then
		shooterMode = "cargame"
	elseif round == 3 then
		shooterMode = "shooter"
	end]]

	if shooterMode == "cargame" then
		--outputChatBox("Shooter launched in CarGame mode, next mode : Shooter",root,0,255,0)
		Shooter.spawnProtectionCountdown = {}
		Shooter.playerRespawnTimers = {}
		Shooter.UpdateLevels = true
		Shooter._Levels = {}
		Shooter.maxLevel = #Shooter.__Levels
		Shooter.playerLevels = {}
		Shooter.playerRanks = {}
		Shooter.firstKill = true
		for level,vehicles in ipairs(Shooter.__Levels) do -- Choose vehicles for levels
			-- CarGame._Levels[level] = CarGame._Levels[level][math.random(1,#CarGame._Levels[level])]
			table.insert(Shooter._Levels,Shooter.__Levels[level][ math.random(1,#Shooter.__Levels[level]) ] )
		end

		local tick = getTickCount()

		for _,player in ipairs(getElementsByType("player")) do
			Shooter.playerLevels[player] = {level = 1, addTick = tick}
		end




		-- exports.scoreboard:removeScoreboardColumn('race rank')
		exports.scoreboard:removeScoreboardColumn('checkpoint')
		exports.scoreboard:scoreboardAddColumn("level", root, 40, "Level", 5)

		local options = {
			duration = 10 * 60 * 1000,
			respawn = 'timelimit',
			respawntime = 3000,
			autopimp = false,
			autopimp_map_can_override = false,
			vehicleweapons = false,
			vehicleweapons_map_can_override = false,
			hunterminigun = false,
			hunterminigun_map_can_override = false,
			ghostmode = false,
			ghostmode_map_can_override = false,
		}
		for key,value in pairs(options) do
			Shooter.setMapOption(key,value)
		end

	else
		--outputChatBox("Shooter launched in Shooter mode, next mode : CarGame",root,0,255,0)
		local options = {
			duration = 4 * 60 * 1000,
			respawn = 'none',
			autopimp = false,
			autopimp_map_can_override = false,
			vehicleweapons = false,
			vehicleweapons_map_can_override = false,
			hunterminigun = false,
			hunterminigun_map_can_override = false,
			ghostmode = false,
			ghostmode_map_can_override = false,
		}
		for key,value in pairs(options) do
			Shooter.setMapOption(key,value)
		end
	end


end


function Shooter:onGamemodeMapStart()
	if shooterMode == "cargame" then
		for _,player in ipairs(getActivePlayers()) do
			local veh = self.getPlayerVehicle(player)
			setVehicleID(veh, Shooter._Levels[1][1])
		end
	end
end

function Shooter.autoRepair()
	for i,player in ipairs(g_Players) do
		local theVeh = getPedOccupiedVehicle(player)
		if getElementType(player) == "player" and theVeh and getElementHealth(theVeh) > 249 and not isPlayerFinished(player) then
			for i=0, 6 do
				setVehiclePanelState(theVeh,i,0)
				setVehicleDoorState(theVeh,i,0)
			end
		end
	end
end

function Shooter.shoot(player, key, keyState)
	if shooterMode == "cargame" then
		if isPlayerSpectating(player) then return end
		if isTimer(cg_noShootTimer) then return end
		if g_CurrentRaceMode:checkSpawnProtection(player) then return end
		if not (isActivePlayer( player ) and g_CurrentRaceMode:checkAndSetShootCooldown(player)) then return end
		-- outputDebugString('CarGame ' .. 'shoot ' .. getPlayerName(player))
		clientCall(player, 'cgRocket')
	else
		if not (isActivePlayer( player ) and g_CurrentRaceMode:checkAndSetShootCooldown(player)) then return end
		-- outputDebugString('Shooter ' .. 'shoot ' .. getPlayerName(player))
		clientCall(player, 'createRocket')
	end
end

function Shooter.jump(player, key, keyState)
	if shooterMode == "cargame" then
		if isPlayerSpectating(player) then return end
		if not isActivePlayer( player ) then return end
		local veh = g_CurrentRaceMode.getPlayerVehicle(player)

		if not g_CurrentRaceMode:checkAndSetJumpCooldown(player) then return end
		-- outputDebugString('CarGame ' .. 'jump ' .. getPlayerName(player))
		clientCall(player, 'cgJump')
	else

		if not isActivePlayer( player ) then return end
		local veh = g_CurrentRaceMode.getPlayerVehicle(player)

		if not g_CurrentRaceMode:checkAndSetJumpCooldown(player) then return end
		-- outputDebugString('Shooter ' .. 'jump ' .. getPlayerName(player))
		clientCall(player, 'shooterJump')
	end
end

function Shooter:checkAndSetShootCooldown ( player )
	if (getTickCount() > self.cooldowns[player].shoot) then
		self.cooldowns[player].shoot = getTickCount() + 3000
		return true
	else
		return false
	end
end

function Shooter:checkSpawnProtection(player)
	if shooterMode == "cargame" then
		return self.spawnProtection[player] or false
	end
end

function Shooter:checkAndSetJumpCooldown ( player )
	if (getTickCount() > self.cooldowns[player].jump) then
		self.cooldowns[player].jump = getTickCount() + 2000
		return true
	else
		return false
	end

end



function Shooter:handleLevelChange(player,amount)

	if shooterMode == "cargame" then

		if not player or not Shooter.UpdateLevels then return end

		local oldLeader = Shooter.playerRanks[1]


		local o = Shooter.playerLevels[player].level
		local n = o + amount

		if n < 1 then
			n = 1
		end

		-- SOUNDS --
		if o < n then -- lvl up
			playSoundFrontEnd(player,12)

			if getPedOccupiedVehicle(player) then
				if getElementHealth(getPedOccupiedVehicle(player)) > 350 then
					setTimer(function() if getPedOccupiedVehicle(player) and getElementHealth(getPedOccupiedVehicle(player)) > 101 then fixVehicle(getPedOccupiedVehicle(player)) end end,200,1 ) -- Fix vehicle after a delay (anti kmz)

				end
			end

		elseif o > n then -- lvl down
			playSoundFrontEnd(player,11)
		end

		-- LEVEL HANDLING --
		if n == Shooter.maxLevel then -- Player won the game

			setElementData(player,"level",n)
			Shooter.playerLevels[player].level = n
			Shooter.playerLevels[player].levelTime = getTickCount()
			clientCall(player,"onClientCGLevelChange",o,n)
			self:handlePlayerWin(player,Shooter.playerLevels)
			setVehicleID(self.getPlayerVehicle(player), 432)

			return true
		else
			Shooter.playerLevels[player].level = n
			Shooter.playerLevels[player].levelTime = getTickCount()
		end

		if getElementModel(self.getPlayerVehicle(player)) ~= Shooter._Levels[n] and n <= Shooter.maxLevel then
			setVehicleID(self.getPlayerVehicle(player), Shooter._Levels[n])
		end


		setElementData(player,"level",n)
		clientCall(player,"onClientCGLevelChange",o,n)
		local newLeader = self:updateRanks()
		if oldLeader ~= newLeader[1] and Shooter.playerLevels[newLeader[1]].level and not Shooter.firstKill then
			-- Output new leader
			exports.messages:outputGameMessage(string.gsub (getPlayerName(newLeader[1]), '#%x%x%x%x%x%x', '' ) .. " took the lead! (level:" .. tostring(Shooter.playerLevels[newLeader[1]].level) ..")", root, 3, 0, 255, 0)
		end
		return true
	end
end



function Shooter:cleanup()
	-- Reset Map custom jump/autorepair
	clientCall(root, 'clientReceiveShooterSettings', false, false)
	if shooterMode == "cargame" then

		-- Remove binds and element data
		for k, v in ipairs(getElementsByType'player') do
			setElementData(v,"level",nil)

			if isKeyBound(v, 'vehicle_fire', 'down', self.shoot) then
				unbindKey(v, 'vehicle_fire', 'both', self.shoot)
			end
			if isKeyBound(v, 'vehicle_secondary_fire', 'down', self.jump) then
				unbindKey(v, 'vehicle_secondary_fire', 'both', self.jump)
			end
			if isKeyBound(v, 'mouse2', 'down', self.jump) then
				unbindKey(v, 'mouse2', 'both', self.jump)
			end
			if isKeyBound(v, 'lshift', 'down', self.jump) then
				unbindKey(v, 'lshift', 'both', self.jump)
			end

			if isKeyBound(v,"accelerate", "down", startSpawnProtectionCountdown) then
				unbindKey(v,"accelerate", "down", startSpawnProtectionCountdown)
			end

			if isKeyBound(v,"brake_reverse", "down", startSpawnProtectionCountdown) then
				unbindKey(v,"brake_reverse", "down", startSpawnProtectionCountdown)
			end
		end

	else
		if isTimer(launchTimer) then killTimer(launchTimer) end
		clientCall(g_Root, 'sh_stopTimeBars')
		clientCall(root, 'initShooterClient', false)
	end
	if isTimer(shooterAutoRepairTimer) then
		killTimer(shooterAutoRepairTimer)
	end
end

function Shooter:endMap()
	self:cleanup()
	RaceMode.endMap(self)
end

function Shooter:destroy()
	if shooterMode == "cargame" then

		for k, v in ipairs(getElementsByType'player') do -- Extra unbind, for some reason doesnt work with everyone the first time
			if isKeyBound(v, 'vehicle_fire', 'down', self.shoot) then
				unbindKey(v, 'vehicle_fire', 'both', self.shoot)
			end
			if isKeyBound(v, 'vehicle_secondary_fire', 'down', self.jump) then
				unbindKey(v, 'vehicle_secondary_fire', 'both', self.jump)
			end
			if isKeyBound(v, 'mouse2', 'down', self.jump) then
				unbindKey(v, 'mouse2', 'both', self.jump)
			end
			if isKeyBound(v, 'lshift', 'down', self.jump) then
				unbindKey(v, 'lshift', 'both', self.jump)
			end

			if isKeyBound(v,"accelerate", "down", startSpawnProtectionCountdown) then
				unbindKey(v,"accelerate", "down", startSpawnProtectionCountdown)
			end

			if isKeyBound(v,"brake_reverse", "down", startSpawnProtectionCountdown) then
				unbindKey(v,"brake_reverse", "down", startSpawnProtectionCountdown)
			end
		end


		exports.scoreboard:scoreboardAddColumn("checkpoint")

		clientCall(g_Root, 'showLevelDX', false)
		clientCall(root, 'cgEnd')
		Shooter._Levels = {}
		Shooter.playerLevels = {}
		Shooter.firstKill = true
		Shooter.hasLaunched = false
		exports.scoreboard:scoreboardRemoveColumn("level")
		Shooter.playerRanks = {}
		Shooter.spawnProtectionCountdown = {}
		Shooter.playerRespawnTimers = {}
	end

	if self.rankingBoard then
		self.rankingBoard:destroy()
		self.rankingBoard = nil
	end
	clientCall(g_Root, 'initShooterClient', false)
	self:cleanup()
	RaceMode.destroy(self)
end


Shooter.modeOptions = {
	duration = 4 * 60 * 1000,
	respawn = 'none',
	autopimp = false,
	autopimp_map_can_override = false,
	vehicleweapons = false,
	vehicleweapons_map_can_override = false,
	hunterminigun = false,
	hunterminigun_map_can_override = false,
	ghostmode = false,
	ghostmode_map_can_override = false,
}

-- Map manager jumpheight command
function Shooter.setNewJumpHeight(p, cmd, amount)
	local acc = getAccountName(getPlayerAccount( p ))
	if acc ~= 'guest' and isObjectInACLGroup( 'user.'..acc, aclGetGroup('mapmanager') ) then
		local minJumpHeight = 2
		local maxJumpHeight = 11
		if amount and tonumber(amount) then
			amount = tonumber(amount)
		end
		if amount > maxJumpHeight then
			outputChatBox('Jumpheight '..tostring(amount)..' is higher than the maximum: '..tostring(maxJumpHeight), p)
			return
		elseif amount < minJumpHeight then
			outputChatBox('Jumpheight '..tostring(amount)..' is lower than the minimum: '..tostring(minJumpHeight), p)
			return
		elseif not g_MapInfo or g_MapInfo.metamode ~= 'shooter' then
			outputChatBox('This command only works with shooter maps!', p)
			return
		else

			local file = xmlLoadFile( ':'..g_MapInfo.resname..'/meta.xml' )
			if not file then
				outputChatBox('Could not open '..tostring(g_MapInfo.resname)..'/meta.xml', p)
				return
			end
			local settings = xmlFindChild( file, 'settings', 0 )
			if not settings then
				settings = xmlCreateChild( file, 'settings' )
			end
			local children = xmlNodeGetChildren( settings )
			local jumpHeightNode = false
			for i, node in ipairs(children) do
				if xmlNodeGetAttribute( node, 'name' ) == '#shooter_jumpheight' then
					jumpHeightNode = node
					break
				end
			end
			if not jumpHeightNode then
				jumpHeightNode = xmlCreateChild(settings, 'setting')
				xmlNodeSetAttribute( jumpHeightNode, 'name', '#shooter_jumpheight' )
				xmlNodeSetAttribute( jumpHeightNode, 'value', amount )
			else
				xmlNodeSetAttribute(jumpHeightNode, 'value', amount)
			end
			xmlSaveFile( file )
			xmlUnloadFile( file )
			outputDebugString(getPlayerName(p)..' set '..g_MapInfo.resname..' jumpheight to '..amount)
			outputChatBox('Succesfully set '..g_MapInfo.resname..' jump height to '..amount, p)
			clientCall(root, 'clientReceiveShooterSettings', amount/10, getBool(g_MapInfo.resname..".shooter_autorepair",false))
		end
	end
end
addCommandHandler('setjumpheight', Shooter.setNewJumpHeight)

-- Kill DzinyMaster logic --

function KillDzinyMaster()
	if getBool("race.killDzinyShooter", false) == false then return end
	for id, player in ipairs(getElementsByType("player")) do
		local serial = getPlayerSerial(player)

		if serial == get("race.serialDziny") then
			killPed(player, player)
			outputChatBox("Nie możesz grać w ten tryb gry", player, 255, 0, 0)
		end
	end
end

function getBool(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return result == 'true'
end
