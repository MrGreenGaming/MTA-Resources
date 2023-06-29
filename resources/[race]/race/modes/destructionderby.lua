DestructionDerby = setmetatable({}, RaceMode)
DestructionDerby.__index = DestructionDerby

DestructionDerby:register('Destruction derby')

local ntsMode = true


local _carsFirstSpawn = { 602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585,
405, 587, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 581, 510, 509, 522, 481, 461, 462, 448, 521, 468, 463, 586, 485, 552,
438, 574, 420, 525, 416, 596, 597, 427, 599, 490, 528, 601, 428, 523, 470, 598, 499, 609, 498,
423, 414, 486, 531, 459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 536, 575, 534,
567, 535, 576, 412, 402, 542, 603, 475, 568, 424, 471, 504, 495, 457, 483, 571, 500,
429, 411, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458 }

local _cars = { 602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585,
405, 587, 409, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 581, 510, 509, 522, 481, 461, 462, 448, 521, 468, 463, 586, 485, 552, 431,
438, 437, 574, 420, 525, 408, 416, 596, 433, 597, 427, 599, 490, 432, 528, 601, 407, 428, 544, 523, 470, 598, 499, 588, 609, 403, 498, 514, 524,
423, 532, 414, 578, 443, 486, 406, 531, 573, 456, 455, 459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 536, 575, 534,
567, 535, 576, 412, 402, 542, 603, 475, 568, 557, 424, 471, 504, 495, 457, 483, 508, 571, 500,
444, 556, 429, 411, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458 }


function DestructionDerby:isApplicable()
	return not self.checkpointsExist() and self.getMapOption('respawn') == 'none'
end

function DestructionDerby:getPlayerRank(player)
	return #getActivePlayers()
end

-- Copy of old updateRank
function DestructionDerby:updateRanks()
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
end

function DestructionDerby:onPlayerWasted(player)
	if isActivePlayer(player) then
		self:handleFinishActivePlayer(player)
		if getActivePlayerCount() <= 1 then
			self:endMap()
		else
			TimerManager.createTimerFor("map",player):setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
		end
	end
	self.setPlayerIsFinished(player)
	showBlipsAttachedTo(player, false)
end

function DestructionDerby:onPlayerQuit(player)
	if isActivePlayer(player) then
		self:handleFinishActivePlayer(player)
		if getActivePlayerCount() <= 1 then
			self:endMap()
		end
	end
end

---[[ NTS
function DestructionDerby:onPlayerJoin(player, spawnpoint)
	if ntsMode then
		local newModel = _carsFirstSpawn[math.random(#_carsFirstSpawn)]
		setVehicleID(self.getPlayerVehicle(player), newModel)
	end
end

function DestructionDerby:start()
	ntsMode = true
	self:resetChangeTimer()
end


addEvent('startddgmTimer',true)
local function ddgmTimer(bln,time)
	if bln then

		ddGMCountDown = Countdown.create(time, ddgmTimer, "Ghostmode will stop in: ", 0, 255, 0, 0.25, 2.5, true, false)
		ddGMCountDown:start()
	elseif not bln then
		KillDzinyMaster()
		if ddGMCountDown then
			ddGMCountDown:destroy()
			ddGMCountDown = nil
		end
	end
end
addEventHandler('startddgmTimer',root,ddgmTimer)

function DestructionDerby:launch()
	RaceMode.launch(self)
	if ntsMode then
		self:startChangeTimer()
	end

    local activePlayers = getActivePlayers()
    outputChatBox("[DEBUG] There are " .. #activePlayers .. " active players in the server", root, 255, 0, 0);
	if #activePlayers <= 1 then
        outputChatBox("You are the only active player in the server, you can't play DD alone!", root, 255, 0, 0);

        setTimer(function()
            self:endMap();
        end, 2500, 1)
    end

end




local function outputGameMessageSmart(text, who)
	if getResourceFromName"messages" and getResourceState(getResourceFromName"messages") == "running" then
		exports.messages:outputGameMessage(text, who or root, nil, 0, 255, 0)
	else
		_outputChatBox(text, who or root,0,255,0)
	end
end

function DestructionDerby:startChangeTimer()
	self:resetChangeTimer()

	local changeTime = 15000
	self.changeTimer = setTimer(function()
		self:randomizeVehicles()
	end, changeTime, 1)

	--[[self.changeFirstWarningTimer = setTimer(function()
	outputGameMessageSmart("Vehicles change in 10 seconds")
end, changeTime - 10000, 1)]]

	self.changeSecondWarningTimer = setTimer(function()
		outputGameMessageSmart("Vehicles change in 5 seconds")
	end, changeTime - 5000, 1)
end

local function betterRandom(limit,player)
	if not limit or not player then return false end
	local x,y,z = getElementPosition(player)
	local seed = math.ceil((getTickCount()+math.abs(x)+math.abs(y)+math.abs(z))*math.random(1,10))

	math.randomseed(seed)
	local rand = math.random(limit)

	return rand
end

function DestructionDerby:randomizeVehicles()
	if not ntsMode then return end
	outputGameMessageSmart("Changed vehicles")

	for k, player in ipairs(getActivePlayers()) do
		local newModel = _cars[betterRandom(#_cars,player)]
		setVehicleID(self.getPlayerVehicle(player), newModel)
		clientCall(player, 'vehicleChanging', g_MapOptions.classicchangez, newModel)
	end

	self:startChangeTimer()
end

function DestructionDerby:resetChangeTimer()
	if self.changeTimer then
		if isTimer(self.changeTimer) then
			killTimer(self.changeTimer)
		end
		self.changeTimer = nil
	end

	if self.changeFirstWarningTimer then
		if isTimer(self.changeFirstWarningTimer) then
			killTimer(self.changeFirstWarningTimer)
		end
		self.changeFirstWarningTimer = nil
	end

	if self.changeSecondWarningTimer then
		if isTimer(self.changeSecondWarningTimer) then
			killTimer(self.changeSecondWarningTimer)
		end
		self.changeSecondWarningTimer = nil
	end
end

function DestructionDerby:endMap()
	self:resetChangeTimer()
	RaceMode.endMap(self)
end

function DestructionDerby:destroy()
	if self.rankingBoard then
		self.rankingBoard:destroy()
		self.rankingBoard = nil
	end
	self:resetChangeTimer()
	RaceMode.destroy(self)
end
--]]

function DestructionDerby:handleFinishActivePlayer(player)
	-- REMOVED rankingboard handler, now handled with events

	-- Update ranking board for player being removed
	-- if not self.rankingBoard then
	-- 	self.rankingBoard = RankingBoard:create()
	-- 	self.rankingBoard:setDirection( 'up', getActivePlayerCount() )
	-- end
	local timePassed = self:getTimePassed()
	-- self.rankingBoard:add(player, timePassed)
	-- -- Do remove
	local rank = self:getPlayerRank(player)
	finishActivePlayer(player)
	if rank and rank > 1 then
		triggerEvent( "onPlayerFinishDD",player,tonumber( rank ),timePassed )
	end
	-- Update ranking board if one player left
	local activePlayers = getActivePlayers()
	if #activePlayers == 1 then
		-- self.rankingBoard:add(activePlayers[1], timePassed)
		showMessage((string.gsub((getElementData(activePlayers[1], 'vip.colorNick') or getPlayerName(activePlayers[1])), '#%x%x%x%x%x%x', '')) .. ' is the final survivor!', 0, 255, 0)
		triggerEvent( "onPlayerWinDD",activePlayers[1],1,timePassed )
	end
end
addEvent('onPlayerFinishDD')
addEvent('onPlayerWinDD')


DestructionDerby.modeOptions = {
	duration = 5 * 60 * 1000,
	respawn = 'none',
	autopimp = false,
	autopimp_map_can_override = false,
	vehicleweapons = true,
	vehicleweapons_map_can_override = false,
	hunterminigun = true,
	hunterminigun_map_can_override = false,
	ghostmode = false,
	ghostmode_map_can_override = false,
}

function disableNTSModeForDD()
	ntsMode = false
end


-- Kill DzinyMaster logic --

function KillDzinyMaster()
	if getBool("race.killDzinyDerby", false) == false then return end
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
