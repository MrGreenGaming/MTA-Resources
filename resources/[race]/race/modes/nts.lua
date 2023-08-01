NTS = setmetatable({}, RaceMode)
NTS.__index = NTS

NTS:register('nts')

function NTS:isMapValid()
	if self.getNumberOfCheckpoints() < 1 then
		outputRace('Error starting NTS map: At least 1 CP needed')
		return false
	end
	for _, checkpoint in ipairs(self.getCheckpoints()) do
		if not self:isValidCheckpoint(checkpoint) then
			outputChatBox('Error starting NTS map: Problem with NTS checkpoint #' .. _ .. ' (' .. checkpoint.id .. ')')
			return false
		end
	end
	return true
end

function NTS:isValidCheckpoint(checkpoint)
	return checkpoint.nts == 'vehicle' or checkpoint.nts == 'boat' or checkpoint.nts == 'air' or checkpoint.nts == 'custom'
end

function NTS:onPlayerWasted(player)
	if not self.checkpointBackups[player] then
		return
	end
	TimerManager.destroyTimersFor("checkpointBackup",player)
	if not self.isPlayerFinished(source) then
        -- See if its worth doing a respawn
        local respawnTime = self:getRespawntime(player)
        if self:getTimeRemaining() - respawnTime > 3000 then
            Countdown.create(respawnTime/1000, self.restorePlayer, 'You will respawn in:', 255, 255, 255, 0.25, 2.5, true, self, self.id, player):start(player)
        end
	    if respawnTime >= 5000 then
		    TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
	    end
	end
end

function NTS:start()
	NTS.custom = {nil}
	math.randomseed(getTickCount())
end

function NTS:playerUnfreeze(player, bDontFix)
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
	addVehicleUpgrade(vehicle, 1010)
end

function NTS:getCheckpoint(i)
	local realcheckpoint = g_Checkpoints[i]
	local checkpoint = {}
	for k,v in pairs(realcheckpoint) do
		checkpoint[k] = v
	end
	checkpoint.vehicle = self:getRandomVehicle(checkpoint)
	return checkpoint
end

local function betterRandom(floor,limit)
	if not limit or not floor then return false end
	local randomPlayer = getAlivePlayers()
	local randomPlayer = randomPlayer[math.random(1,#randomPlayer)]

	local x,y,z = getElementPosition(randomPlayer)
	local seed = math.ceil((getTickCount()+math.abs(x)+math.abs(y)+math.abs(z))*math.random(1,10))

	math.randomseed(seed)
	local rand = math.random(limit)

	return rand
end



function NTS:getRandomVehicle(checkpoint)
	if checkpoint.nts == 'boat' then
		list = NTS._boats
	elseif checkpoint.nts == 'air' then
		list = NTS._planes
	elseif checkpoint.nts == 'vehicle' then
		list = NTS._cars
	elseif checkpoint.nts == 'custom' then
		local models = tostring(checkpoint.models)
		if models then
			if NTS.custom[checkpoint.id] then
				if #NTS.custom[checkpoint.id] == 0 then return false end
				list = NTS.custom[checkpoint.id]
			else
				NTS.custom[checkpoint.id] = {}
				local modelCount = 1
				for model in string.gmatch(models, "([^;]+)") do
					if tonumber(model) then
						if getVehicleNameFromModel(model) == "" then
							outputDebugString("Model " .. model .. " not valid for checkpoint " .. checkpoint.id, 0, 255, 0, 213)
						else
							NTS.custom[checkpoint.id][modelCount] = model
							modelCount = modelCount + 1
						end
					end
				end
				if #NTS.custom[checkpoint.id] == 0 then return false end
				list = NTS.custom[checkpoint.id]
			end
		else
			return false
		end
	else
		return false
	end
	return list[betterRandom(1, #list)]
end

NTS._cars = { 602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585,
	405, 587, 409, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 581, 510, 509, 522, 481, 461, 462, 448, 521, 468, 463, 586, 485, 552, 431,
	438, 437, 574, 420, 525, 408, 416, 596, 433, 597, 427, 599, 490, 528, 601, 407, 428, 544, 523, 470, 598, 499, 588, 609, 403, 498, 514, 524,
	423, 532, 414, 578, 443, 486, 406, 531, 573, 456, 455, 459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 536, 575, 534,
	567, 535, 576, 412, 402, 542, 603, 475, 568, 557, 424, 471, 504, 495, 457, 539, 483, 508, 571, 500, 411, 515,
	444, 556, 429, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458 }
-- rc's: 441, 464, 594, 501, 465, 564
-- tank: 432,
NTS._planes = {592, 577, 511, 548, 512, 593, 425, 520, 417, 487, 553, 488, 497, 563, 476, 447, 519, 460, 469, 513}
NTS._boats = {472,473,493,595,484,430,453,452,446,454}


NTS.name = 'Never the same'
NTS.modeOptions = {
	respawn = 'timelimit',
	respawntime = 5,
	autopimp = false,
	autopimp_map_can_override = false,
	vehicleweapons = false,
	vehicleweapons_map_can_override = false,
	hunterminigun = false,
	hunterminigun_map_can_override = false,
--	ghostmode = true,
--	ghostmode_map_can_override = false,
}
