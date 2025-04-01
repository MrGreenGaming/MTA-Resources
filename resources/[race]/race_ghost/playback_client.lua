GhostPlayback = {}
GhostPlayback.__index = GhostPlayback

addEvent("onClientGhostDataReceive", true)
addEvent("clearMapGhost", true)
addEvent("disableGhostsForThisMap", true)

NO_GHOST                  = false
ghostsCreated             = 0
ghostsAmount              = 12 -- default value

local bestPlaybackEnabled = true
addCommandHandler('bestghost', function()
	bestPlaybackEnabled = not bestPlaybackEnabled
end)

addEvent 'bestghost'
addEventHandler('bestghost', root, function(b)
	bestPlaybackEnabled = not not b
end)

local localPlaybackEnabled = true
addCommandHandler('localghost', function()
	localPlaybackEnabled = not localPlaybackEnabled
end)

addEvent 'localghost'
addEventHandler('localghost', root, function(b)
	localPlaybackEnabled = not not b
end)

local extraPlaybackEnabled = true
addCommandHandler('extraghosts', function()
	extraPlaybackEnabled = not extraPlaybackEnabled
end)

addEvent 'toggleExtraGhosts'
addEventHandler('toggleExtraGhosts', root, function(b)
	extraPlaybackEnabled = not not b
end)


function GhostPlayback:create(recording, ped, vehicle, racer, time, playbackID)
	local result = {
		ped = nil,
		vehicle = nil,
		blip = nil,
		recording = recording,
		racer = racer,
		time = time,
		isPlaying = false,
		startTick = nil,
		disableCollision = true,
		lastData = {},
		playbackID = playbackID
	}

	-- Move this client side so the server doesn't create unused ghost drivers for every player for every player
	result.ped = createPed(ped.p, ped.x, ped.y, ped.z)
	result.vehicle = createVehicle(vehicle.m, vehicle.x, vehicle.y, vehicle.z, vehicle.rx, vehicle.ry, vehicle.rz)
	result.blip = createBlipAttachedTo(result.ped, 0, 1, 150, 150, 150, 50)
	setElementParent(result.blip, result.ped)
	warpPedIntoVehicle(result.ped, result.vehicle)

	setElementData(result.vehicle, "race.isGhostVehicle", true)
	setElementCollisionsEnabled(result.ped, false)
	setElementCollisionsEnabled(result.vehicle, false)
	setElementFrozen(result.vehicle, true)
	setElementAlpha(result.ped, 80)
	setElementAlpha(result.vehicle, 10)
	setHeliBladeCollisionsEnabled(result.vehicle, false)

	ghostsCreated = ghostsCreated + 1
	return setmetatable(result, self)
end

function GhostPlayback:destroy(finished)
	self:stopPlayback(finished)
	if self.checkForCountdownEnd_HANDLER then
		removeEventHandler("onClientRender", root, self.checkForCountdownEnd_HANDLER)
		self.checkForCountdownEnd_HANDLER = nil
	end
	if self.updateGhostState_HANDLER then
		removeEventHandler("onClientRender", root, self.updateGhostState_HANDLER)
		self.updateGhostState_HANDLER = nil
	end
	if isTimer(self.ghostFinishTimer) then
		killTimer(self.ghostFinishTimer)
		self.ghostFinishTimer = nil
	end

	if isElement(self.blip) then destroyElement(self.blip) end
	if isElement(self.ped) then destroyElement(self.ped) end
	if isElement(self.vehicle) then destroyElement(self.vehicle) end

	ghostsCreated = ghostsCreated - 1
end

function GhostPlayback:preparePlayback()
	self.checkForCountdownEnd_HANDLER = function() self:checkForCountdownEnd() end
	addEventHandler("onClientRender", root, self.checkForCountdownEnd_HANDLER)
	self:createNametag()
end

function GhostPlayback:createNametag()
	self.nametagInfo = {
		name = "Ghost " .. self.playbackID .. " (" .. removeColorCoding(self.racer) .. ")",
		time = msToTimeStr(self.time)
	}
	self.drawGhostNametag_HANDLER = function() self:drawGhostNametag(self.nametagInfo) end
	addEventHandler("onClientRender", root, self.drawGhostNametag_HANDLER)
end

function GhostPlayback:destroyNametag()
	if self.drawGhostNametag_HANDLER then
		removeEventHandler("onClientRender", root, self.drawGhostNametag_HANDLER)
		self.drawGhostNametag_HANDLER = nil
	end
end

function GhostPlayback:checkForCountdownEnd()
	if (NO_GHOST == true) then
		NO_GHOST = false
		self:destroy()
	end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
		local frozen = isElementFrozen(vehicle)
		if not frozen then
			-- outputDebug( "Playback started." )
			setElementFrozen(self.vehicle, false)
			if self.checkForCountdownEnd_HANDLER then
				removeEventHandler("onClientRender", root, self.checkForCountdownEnd_HANDLER)
				self.checkForCountdownEnd_HANDLER = nil
			end
			self:startPlayback()
		end
	end
end

function GhostPlayback:startPlayback()
	-- Destroy Ghosts that we don't need
	if ghostsAmount == 0 then -- No ghosts
		-- destroy Top ghost if it exists
		if playbacks["Top"] then
			playbacks["Top"]:destroy()
			playbacks["Top"] = nil
		end

		-- destroy PB ghost if it exists
		if playbacks["PB"] then
			playbacks["PB"]:destroy()
			playbacks["PB"] = nil
		end
	elseif ghostsAmount == 1 then -- only Top
		-- destroy Top ghosts if it exists
		if playbacks["PB"] then
			playbacks["PB"]:destroy()
			playbacks["PB"] = nil
		end
	end

	-- Destroy extra ghosts if they are to much
	-- Check how many extra ghosts exists
	local extraGhostsExist = 0
	for i = 1, 30 do
		if playbacks[i] then extraGhostsExist = extraGhostsExist + 1 end
	end

	-- Destroy extra ghosts
	local extraGhostsAllowed = ghostsAmount - 2
	if extraGhostsAllowed < 0 then extraGhostsAllowed = 0 end

	for i = 1, 30 do
		if playbacks[i] and extraGhostsExist > extraGhostsAllowed then
			playbacks[i]:destroy()
			playbacks[i] = nil
			extraGhostsExist = extraGhostsExist - 1
		end
	end

	if ghostsAmount == 0 then return end

	-- Start Playback
	self.startTick = getTickCount()
	self.isPlaying = true
	self.updateGhostState_HANDLER = function() self:updateGhostState() end
	addEventHandler("onClientRender", root, self.updateGhostState_HANDLER)
end

function GhostPlayback:stopPlayback(finished)
	self:destroyNametag()
	self:resetKeyStates()
	self.isPlaying = false
	if self.updateGhostState_HANDLER then
		removeEventHandler("onClientRender", root, self.updateGhostState_HANDLER)
		self.updateGhostState_HANDLER = nil
	end
	if finished then
		self.ghostFinishTimer = setTimer(
			function()
				local blip = getBlipAttachedTo(self.ped)
				if blip then
					setBlipColor(blip, 0, 0, 0, 0)
				end
				setElementPosition(self.vehicle, 0, 0, 0)
				setElementFrozen(self.vehicle, true)
				setElementAlpha(self.vehicle, 0)
				setElementAlpha(self.ped, 0)
			end, 5000, 1
		)
	end
end

function GhostPlayback:getNextIndexOfType(reqType, start, dir)
	local idx = start
	while (self.recording[idx] and self.recording[idx].ty ~= reqType) do
		idx = idx + dir
	end
	return self.recording[idx] and idx
end

function GhostPlayback:updateGhostState()
	if not self.currentIndex then
		Interpolator.Reset(self.playbackID)
	end
	self.currentIndex = self.currentIndex or 1
	local ticks = getTickCount() - self.startTick
	setElementHealth(self.ped, 100)  -- we don't want the ped to die
	while (self.recording[self.currentIndex] and self.recording[self.currentIndex].t < ticks) do
		local theType = self.recording[self.currentIndex].ty
		-- if theType == "st" then
		--	-- Skip
		if theType == "po" then
			local x, y, z = self.recording[self.currentIndex].x, self.recording[self.currentIndex].y,
					self.recording[self.currentIndex].z
			local rX, rY, rZ = self.recording[self.currentIndex].rX, self.recording[self.currentIndex].rY,
					self.recording[self.currentIndex].rZ
			local vX, vY, vZ = self.recording[self.currentIndex].vX, self.recording[self.currentIndex].vY,
					self.recording[self.currentIndex].vZ
			-- Interpolate with next position depending on current time
			local idx = self:getNextIndexOfType("po", self.currentIndex + 1, 1)
			local period = nil
			if idx then
				local other = self.recording[idx]
				local alpha = math.unlerp(self.recording[self.currentIndex].t, other.t, ticks)
				period = other.t - ticks
				x = math.lerp(x, other.x, alpha)
				y = math.lerp(y, other.y, alpha)
				z = math.lerp(z, other.z, alpha)
				vX = math.lerp(vX, other.vX, alpha)
				vY = math.lerp(vY, other.vY, alpha)
				vZ = math.lerp(vZ, other.vZ, alpha)
				Interpolator.SetPoints(self.playbackID, self.recording[self.currentIndex], other)
			else
				Interpolator.Reset(self.playbackID)
			end
			local lg = self.recording[self.currentIndex].lg
			local health = self.recording[self.currentIndex].h or 1000
			if self.disableCollision then
				health = 1000
				self.lastData.vZ = vZ
				self.lastData.time = getTickCount()
			end
			ErrorCompensator.handleNewPosition(self.playbackID, self.vehicle, x, y, z, period)
			setElementRotation(self.vehicle, rX, rY, rZ)
			setElementVelocity(self.vehicle, vX, vY, vZ)
			setElementHealth(self.vehicle, health)
			if lg then setVehicleLandingGearDown(self.vehicle, lg) end
		elseif theType == "k" then
			local control = self.recording[self.currentIndex].k
			local state = self.recording[self.currentIndex].s
			setPedControlState(self.ped, control, state)
		elseif theType == "pi" then
			local item = self.recording[self.currentIndex].i
			if item == "n" then
				addVehicleUpgrade(self.vehicle, 1010)
			elseif item == "r" then
				fixVehicle(self.vehicle)
			end
		elseif theType == "sp" then
			fixVehicle(self.vehicle)
			-- Respawn clears the control states
			for _, v in ipairs(keyNames) do
				setPedControlState(self.ped, v, false)
			end
		elseif theType == "v" then
			local vehicleType = self.recording[self.currentIndex].m
			setElementModel(self.vehicle, vehicleType)
		end
		self.currentIndex = self.currentIndex + 1

		if not self.recording[self.currentIndex] then
			self:stopPlayback(true)
			self.fadeoutStart = getTickCount()
		end
	end
	ErrorCompensator.updatePosition(self.playbackID, self.vehicle)
	Interpolator.Update(self.playbackID, ticks, self.vehicle)
end

function GhostPlayback:resetKeyStates()
	if isElement(self.ped) then
		for _, v in ipairs(keyNames) do
			setPedControlState(self.ped, v, false)
		end
	end
end

addEventHandler("onClientGhostDataReceive", root,
	function(recording, time, racer, ped, vehicle, playbackID)
		if not playbackID then playbackID = "Top" end

		if not playbacks then playbacks = {} end
		if playbacks[playbackID] then
			playbacks[playbackID]:destroy()
			playbacks[playbackID] = nil
		end

		if (playbackID == "Top") then
			globalInfo.bestTime = time
			-- iprint("[Race Ghost C] Best time is: ", time, racer)
			globalInfo.racer = racer
			if (racer == removeColorCoding(getPlayerName(localPlayer))) then
				globalInfo.personalBest = time
				-- return
			end

			-- Hide best ghost if "Best Playback" is disabled
			if not bestPlaybackEnabled then
				-- hide serverside ped and vehicle
				setElementDimension(ped, 20)
				setElementDimension(vehicle, 20)
				return
			end
		elseif (playbackID == "PB") then
			-- This should no longer occur since PB ghosts are handled differently now (We send the raw XML instead of Ghost Data)
			globalInfo.personalBest = time

			if (globalInfo.racer == removeColorCoding(getPlayerName(localPlayer))) then
				-- This ghost is of ourselves, which we'll already be showing by means of Top. Remove it as duplicate
				return
			end

			-- Hide local ghost (PB) if 'Local playback' is disabled
			if not localPlaybackEnabled then
				-- hide serverside ped and vehicle
				setElementDimension(ped, 20)
				setElementDimension(vehicle, 20)
				return
			end
		else
			if (racer == removeColorCoding(getPlayerName(localPlayer))) then
				-- This ghost is of ourselves, which we'll already be showing by means of PB. Remove it as duplicate
				return
			end

			-- Hide ghosts if "Extra ghosts playback" is disabled
			if not extraPlaybackEnabled then
				-- hide serverside ped and vehicle
				setElementDimension(ped, 20)
				setElementDimension(vehicle, 20)
				return
			end
		end

		--- TODO: Implement this in a smarter way.
		--- The flow seems to be that it first sends the top ghost, then the others at random?
		--- So instead we should maybe add the ghosts to a list before creating them...
		--- Alternatively, only request a certain amount of ghosts from the server and have them be random?
		--- So PB would always be #1, top #2, and then fill up the rest with random ghosts for the map.
		-- if ghostsCreated >= ghostsAmount then
		-- 	return
		-- end

		recording = fromJSON(recording)

		playbacks[playbackID] = GhostPlayback:create(recording, ped, vehicle, racer, time, playbackID)
		playbacks[playbackID]:preparePlayback()
	end
)

addEventHandler("disableGhostsForThisMap", root,
	function()
		NO_GHOST = true
	end
)

addEventHandler("clearMapGhost", root,
	function()
		if playbacks then
			for i, v in pairs(playbacks) do
				v:destroy()
				v = nil
			end
			playbacks = {}
			globalInfo.bestTime = math.huge
			iprint("[Race Ghost C] Best time cleared")
			globalInfo.racer = ""
			globalInfo.personalBest = math.huge

			ghostsCreated = 0
		end
	end
)

addEvent("updateRaceGhostsAmount", true)
addEventHandler("updateRaceGhostsAmount", getRootElement(), function(amount)
	ghostsAmount = amount

	local text = ""
	if ghostsAmount == 0 then
		text = "(disabled)"
	elseif ghostsAmount == 1 then
		text = "(only top ghost)"
	elseif ghostsAmount == 2 then
		text = "(only top and PB ghosts)"
	elseif ghostsAmount > 2 then
		text = "(top, PB and " .. (ghostsAmount - 2) .. " extra ghosts)"
	end

	outputChatBox("Number of race ghosts set to " .. ghostsAmount .. " " .. text)
end)

function getBlipAttachedTo(elem)
	local elements = getAttachedElements(elem)
	for _, element in ipairs(elements) do
		if getElementType(element) == "blip" then
			return element
		end
	end
	return false
end

--------------------------------------------------------------------------
--Interpolator
--------------------------------------------------------------------------
Interpolator = {}
last = {}

function Interpolator.Reset(playbackID)
	if not last[playbackID] then last[playbackID] = {} end
	last[playbackID].from = nil
	last[playbackID].to = nil
end

function Interpolator.SetPoints(playbackID, from, to)
	if not last[playbackID] then last[playbackID] = {} end
	last[playbackID].from = from
	last[playbackID].to = to
end

function Interpolator.Update(playbackID, ticks, vehicle)
	if not last[playbackID] then last[playbackID] = {} end
	if not last[playbackID].from or not last[playbackID].to then return end
	local z, rX, rY, rZ
	local alpha = math.unlerp(last[playbackID].from.t, last[playbackID].to.t, ticks)
	z = math.lerp(last[playbackID].from.z, last[playbackID].to.z, alpha)
	rX = math.lerprot(last[playbackID].from.rX, last[playbackID].to.rX, alpha)
	rY = math.lerprot(last[playbackID].from.rY, last[playbackID].to.rY, alpha)
	rZ = math.lerprot(last[playbackID].from.rZ, last[playbackID].to.rZ, alpha)
	local ox, oy, oz = getElementPosition(vehicle)
	setElementPosition(vehicle, ox, oy, math.max(oz, z))
	setElementRotation(vehicle, rX, rY, rZ)
end

--------------------------------------------------------------------------
-- Error Compensator
--------------------------------------------------------------------------
ErrorCompensator = {}
-- error2 = { timeEnd = 0 }
error2 = {}

function ErrorCompensator.handleNewPosition(playbackID, vehicle, x, y, z, period)
	if not error2[playbackID] then error2[playbackID] = { timeEnd = 0 } end

	local vx, vy, vz = getElementPosition(vehicle)
	-- Check if the distance to interpolate is too far.
	local dist = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
	if dist > 5 or not period then
		-- Just do move if too far to interpolate or period is not valid
		setElementPosition(vehicle, x, y, z)
		error2[playbackID].x = 0
		error2[playbackID].y = 0
		error2[playbackID].z = 0
		error2[playbackID].timeStart = 0
		error2[playbackID].timeEnd = 0
		error2[playbackID].fLastAlpha = 0
	else
		-- Set error correction to apply over the next few frames
		error2[playbackID].x = x - vx
		error2[playbackID].y = y - vy
		error2[playbackID].z = z - vz
		error2[playbackID].timeStart = getTickCount()
		error2[playbackID].timeEnd = error2[playbackID].timeStart + period * 1.0
		error2[playbackID].fLastAlpha = 0
	end
end

-- Apply a portion of the error
function ErrorCompensator.updatePosition(playbackID, vehicle)
	if not error2[playbackID] then error2[playbackID] = { timeEnd = 0 } end

	if error2[playbackID].timeEnd == 0 then return end

	-- Grab the current game position
	local vx, vy, vz = getElementPosition(vehicle)

	-- Get the factor of time spent from the interpolation start to the current time.
	local fAlpha = math.unlerp(error2[playbackID].timeStart, error2[playbackID].timeEnd, getTickCount())

	-- Don't let it overcompensate the error too much
	fAlpha = math.clamp(0.0, fAlpha, 1.5)

	if fAlpha == 1.5 then
		error2[playbackID].timeEnd = 0
		return
	end

	-- Get the current error portion to compensate
	local fCurrentAlpha = fAlpha - error2[playbackID].fLastAlpha
	error2[playbackID].fLastAlpha = fAlpha

	-- Apply
	local nx = vx + error2[playbackID].x * fCurrentAlpha
	local ny = vy + error2[playbackID].y * fCurrentAlpha
	local nz = vz + error2[playbackID].z * fCurrentAlpha
	setElementPosition(vehicle, nx, ny, nz)
end

--------------------------------------------------------------------------
-- Update admin changing options
--------------------------------------------------------------------------
function GhostPlayback:onUpdateOptions()
	if isElement(self.vehicle) and isElement(self.ped) then
		setElementAlpha(self.vehicle, g_GameOptions.alphavalue)
		setElementAlpha(self.ped, g_GameOptions.alphavalue)
	end
end

--------------------------------------------------------------------------
-- Fade out ghost at end of race
--------------------------------------------------------------------------
addEventHandler('onClientPreRender', root,
	function()
		if playback and playback.fadeoutStart and isElement(playback.vehicle) and isElement(playback.ped) then
			playback:updateFadeout()
		end
	end
)

function GhostPlayback:updateFadeout()
	local alpha = math.unlerp(self.fadeoutStart + 2000, self.fadeoutStart + 500, getTickCount())
	if alpha > -1 and alpha < 1 then
		alpha = math.clamp(0, alpha, 1)
		setElementAlpha(self.vehicle, alpha * g_GameOptions.alphavalue)
		setElementAlpha(self.ped, alpha * g_GameOptions.alphavalue)
	end
end

--------------------------------------------------------------------------
-- Counter side effects of having collisions disabled
--------------------------------------------------------------------------
addEventHandler('onClientPreRender', root,
	function()
		if playback and playback.disableCollision and isElement(playback.vehicle) and isElement(playback.ped) then
			playback:disabledCollisionTick()
		end
	end
)


local dampCurve = { { 0, 1 }, { 200, 1 }, { 15000, 0 } }

function GhostPlayback:disabledCollisionTick()
	setVehicleDamageProof(self.vehicle, true)  -- we don't want the vehicle to explode
	setElementCollisionsEnabled(self.ped, false)
	setElementCollisionsEnabled(self.vehicle, false)

	-- Slow down everything when its been more than 200ms since the last position change
	local timeSincePos = getTickCount() - (self.lastData.time or 0)
	local damp = math.evalCurve(dampCurve, timeSincePos)

	-- Stop air floating
	local vx, vy, vz = getElementVelocity(self.vehicle)
	if vz < -0.01 then
		damp = 1 -- Always allow falling
		self.lastData.time = getTickCount()
	end
	vz = self.lastData.vZ or vz
	vx = vx * 0.999 * damp
	vy = vy * 0.999 * damp
	vz = vz * damp
	if vz > 0 then
		vz = vz * 0.999
	end
	if vz > 0 and getDistanceBetweenPoints2D(0, 0, vx, vy) < 0.001 then
		vz = 0
	end
	if self.lastData.vZ then
		self.lastData.vZ = vz
	end
	setElementVelocity(self.vehicle, vx, vy, vz)

	-- Stop crazy spinning
	local vehicle = self.vehicle
	local ax, ay, az = getElementAngularVelocity(self.vehicle)
	local angvel = getDistanceBetweenPoints3D(0, 0, 0, ax, ay, az)
	if angvel > 0.1 then
		ax = ax / 2
		ay = ay / 2
		az = az / 2
		setElementAngularVelocity(self.vehicle, ax, ay, az)
	end
end
