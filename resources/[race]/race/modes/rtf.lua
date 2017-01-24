RTF = setmetatable({}, RaceMode)
RTF.__index = RTF

RTF:register('rtf')

function RTF:isMapValid()
	-- Check if there is only one object for each flag in the map
	local flagObjects = #getElementsByType'rtf'
	if flagObjects ~= 1 then
		outputRace('Error. RTF map should have 1 flag (' .. flagObjects .. ')')
		return false 
	elseif self.getNumberOfCheckpoints() > 0 then
		outputRace('Error. RTF map shouldn\'t have checkpoints')
		return false 
	end
	return true
end

function RTF:start()
	self:cleanup()

	local flagElement = getElementsByType'rtf'[1]
	self.object = createObject(self.FlagModel, getElementPosition(flagElement))
	self:createFlag(self.object)
end

function RTF:createFlag(object)
	local flag = {}
	local x, y, z = getElementPosition(object)
	flag.marker = createMarker ( x, y, z-0.5, 'corona', 1.5 )
	flag.col = createColSphere ( x, y, z+0.6, 5 )
	flag.blip = createBlipAttachedTo(object, 19, 5, 255, 255, 255, 255, 500)
	setElementParent(flag.marker, object)
	setElementParent(flag.col, object)
	setElementParent(flag.blip, object)
	setElementData(flag.blip,"customBlipPath",':race/model/Blipid53.png')
	addEventHandler('onColShapeHit', flag.col, RTF.hit)
	RTF.flags[object] = flag
	setElementData(object, 'race.rtf_flag', true)
end

function RTF.hit(hitElement)
	if not (getElementType(hitElement) == 'vehicle' and not isVehicleBlown(hitElement) and getVehicleController(hitElement) and getElementHealth(getVehicleController(hitElement)) ~= 0) then return end
	-- outputDebugString('hit col')
	for k, v in pairs(RTF.flags) do
		-- outputDebugString('checking hit known col')
		if (v.col == source) then
			-- outputDebugString('hit known col')
			return g_CurrentRaceMode:hitColshape(k, getVehicleController(hitElement))
		end
	end
end

function RTF:hitColshape(object, player)
	-- outputDebugString('player hit known col')
	self:playerWon(player)
end

function RTF:playerWon(player)

	if not isElement(player) then return end
	-- outputDebugString('player won')
	showMessage(getPlayerName(player) .. ' has reached the flag!', 0, 255, 0)
	playSoundFrontEnd(player, 11)
	self.setPlayerIsFinished(player)
	triggerEvent('onPlayerFinish', player, 1, self:getTimePassed())
	self:cleanup()
	self:endMap()
	clientCall(g_Root, 'raceTimeout')
end

function RTF:isRanked()
	return true
end

function RTF:updateRanks()
	-- Make a table with the active players
	local sortinfo = {}
	for i,player in ipairs(getActivePlayers()) do
		sortinfo[i] = {}
		sortinfo[i].player = player
		sortinfo[i].cpdist = self:shortestDistanceFromPlayerToFlag(player)
	end
	-- Order by cp
	table.sort( sortinfo, function(a,b)
						return  a.cpdist < b.cpdist 
					  end )
	-- Copy back into active players list to speed up sort next time
	for i,info in ipairs(sortinfo) do
		g_CurrentRaceMode.activePlayerList[i] = info.player
	end
	-- Update data
	local rankOffset = getFinishedPlayerCount()
	for i,info in ipairs(sortinfo) do
		setElementData(info.player, 'race rank', i + rankOffset )
	end
	-- Make text look good at the start
	if not self.running then
		for i,player in ipairs(g_Players) do
			setElementData(player, 'race rank', 1 )
		end
	end
end

function RTF:shortestDistanceFromPlayerToFlag(player)
	local shortest = 1000000
	local pos1 = {getElementPosition(player)}
	for object, _ in pairs(RTF.flags) do
		if isElement(object) then
			local pos2 = {getElementPosition(object)}
			local dist = getDistanceBetweenPoints3D (pos1[1], pos1[2], pos1[3], pos2[1], pos2[2], pos2[3])
			if dist < shortest then
				shortest = dist
			end
		end
	end
	return shortest
end

function RTF:cleanup()
	-- Cleanup for next mode

	-- clientCall(root, 'ctfStop')
	for object, flag in pairs(RTF.flags) do
		for _, ele in pairs(flag) do
			if ele and isElement(ele) then
				destroyElement(ele)
			end
		end
		if object and isElement(object) then
			destroyElement(object)
		end
		RTF.flags[object] = nil
	end
	RTF.flags = {}
	RTF.object = nil
end

function RTF:destroy()
	self:cleanup()
	if self.rankingBoard then
		self.rankingBoard:destroy()
		self.rankingBoard = nil
	end
	TimerManager.destroyTimersFor("checkpointBackup")
	RaceMode.instances[self.id] = nil
end


RTF.FlagModel = 2914
RTF.FlagBlip = 19
RTF.flags = {}
RTF.object = nil

RTF.name = 'Reach the flag'
RTF.modeOptions = {
	respawn = 'timelimit',
	respawntime = 5,
	autopimp = false,
	autopimp_map_can_override = false,
	ghostmode = true,
	ghostmode_map_can_override = false,
	duration = (g_MapOptions and (g_MapOptions.duration < 600)) or 10*60*1000,
}