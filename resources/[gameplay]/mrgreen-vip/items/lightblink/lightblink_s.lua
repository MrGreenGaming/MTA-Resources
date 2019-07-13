--Lights blinking
local blinkMainTimer = false
local blinkTable = {}

-- addEvent('vip-startBlinking', true)
-- addEventHandler('vip-startBlinking', root,
-- function(pattern, speed)
-- 	if not isPlayerVIP(source) then outputChatBox("You are not allowed to use this function. Only VIP members are allowed to use this function!", source, 255, 0, 0) return end
-- 	if pattern == 0 or speed == 0 then 
-- 		if blinkTable[source] then blinkTable[source] = nil end
-- 		local veh = getPedOccupiedVehicle(source)
-- 		if veh then
-- 			setVehicleOverrideLights(veh, 0)
-- 			setVehicleLightState(veh, 0, 0)
-- 			setVehicleLightState(veh, 1, 0)
-- 			setVehicleLightState(veh, 2, 0)
-- 			setVehicleLightState(veh, 3, 0)
-- 		end
-- 		outputChatBox('Light blinking is disabled!', source, 100, 255, 100)
-- 		return
-- 	end
	
-- 	local playerObject = {}
	
-- 	playerObject.pattern = pattern
-- 	playerObject.speed = speed
-- 	playerObject.cyclesLeft = speed
-- 	playerObject.stage = 1
	
-- 	blinkTable[source] = playerObject
	
-- 	if not blinkMainTimer or not isTimer(blinkMainTimer) then blinkMainTimer = setTimer(doBlinking, 250, 0) end
	
-- 	outputChatBox('Light blinking is enabled!', source, 100, 255, 100)
-- end)

function setLightBlink(player)
	local playerEnabled = getVipSetting(player,4,'enabled')
	if not playerEnabled then
		-- Remove lightblink
		if blinkTable[player] then blinkTable[player] = nil end
		local veh = getPedOccupiedVehicle(player)
		if veh then
			setVehicleOverrideLights(veh, 0)
			setVehicleLightState(veh, 0, 0)
			setVehicleLightState(veh, 1, 0)
			setVehicleLightState(veh, 2, 0)
			setVehicleLightState(veh, 3, 0)
		end

		return 
	end

	local playerSpeed = getVipSetting(player,4,'speed')
	local playerPattern = getVipSetting(player,4,'pattern')

	if not playerSpeed or not playerPattern then return false end


	local playerObject = {}
	playerObject.pattern = playerPattern
	playerObject.speed = playerSpeed
	playerObject.cyclesLeft = playerSpeed
	playerObject.stage = 1


	blinkTable[player] = playerObject
	if not blinkMainTimer or not isTimer(blinkMainTimer) then blinkMainTimer = setTimer(doBlinking, 250, 0) end

	return true
end

function doBlinking()
	local count = 0

	for k,v in pairs(blinkTable) do
		count = count + 1
		local veh = getPedOccupiedVehicle(k)
		if veh then
			setVehicleOverrideLights(veh, 2)
			v.cyclesLeft = v.cyclesLeft - 1
			
			if v.cyclesLeft == 0 then
				v.cyclesLeft = v.speed
				if v.pattern == 1 then
					if v.stage == 1 then
						setVehicleLightState(veh, 0, 0)
						setVehicleLightState(veh, 3, 0)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 1)
						v.stage = v.stage + 1
					elseif v.stage == 2 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 3, 1)
						setVehicleLightState(veh, 1, 0)
						setVehicleLightState(veh, 2, 0)
						v.stage = 1
					end
				elseif v.pattern == 2 then
					if v.stage == 1 then
						setVehicleLightState(veh, 0, 0)
						setVehicleLightState(veh, 3, 1)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 0)
						v.stage = v.stage + 1
					elseif v.stage == 2 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 3, 0)
						setVehicleLightState(veh, 1, 0)
						setVehicleLightState(veh, 2, 1)
						v.stage = 1
					end
				elseif v.pattern == 3 then
					if v.stage == 1 then
						setVehicleLightState(veh, 0, 0)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 1)
						setVehicleLightState(veh, 3, 1)
						v.stage = v.stage + 1
					elseif v.stage == 2 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 1, 0)
						setVehicleLightState(veh, 2, 1)
						setVehicleLightState(veh, 3, 1)
						v.stage = v.stage + 1
					elseif v.stage == 3 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 0)
						setVehicleLightState(veh, 3, 1)
						v.stage = v.stage + 1
					elseif v.stage == 4 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 1)
						setVehicleLightState(veh, 3, 0)
						v.stage = 1
					end
				end
			end
		end
	end
	if count == 0 then killTimer(blinkMainTimer) blinkMainTimer = false end
end



addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
			if loggedIn and getVipSetting(player,4,'enabled') then
				setLightBlink(player)				
			end
		end
	end
)

-- [4] = {pattern = 1, speed = 4, enabled = false},

addEvent('onClientChangeLightblinkSpeed',true)
addEvent('onClientChangeLightblinkPattern',true)
addEvent('onClientChangeLightblinkEnabled',true)

	
addEventHandler('onClientChangeLightblinkSpeed', root,
function(speed)
	if not isPlayerVIP(source) or not vipPlayers[source] then return end
	if not speed or not tonumber(speed) then
		vip_outputChatBox("Invalid speed set.", source, 255, 50, 0)
	end	

	local saved = saveVipSetting(source,4,"speed",tonumber(speed))
	if saved then
		setLightBlink(source)
		vip_outputChatBox("Lightblink speed successfully set!", source, 0, 255, 100)
	else
		vip_outputChatBox("Problem saving lightblink speed.", source, 255, 50, 0)
	end
	
end)

addEventHandler('onClientChangeLightblinkPattern', root,
function(pattern)
	if not isPlayerVIP(source) or not vipPlayers[source] then return end
	local patternToNumber = {
		["Left-Right Pattern"] = 1,
		["Cross Pattern"] = 2,
		["Circle Pattern"] = 3
	}

	if not pattern or not patternToNumber[pattern] then
		vip_outputChatBox("Invalid pattern set.", source, 255, 50, 0)
	end	

	local saved = saveVipSetting(source,4,"pattern",patternToNumber[pattern])
	if saved then
		setLightBlink(source)
		vip_outputChatBox("Lightblink speed successfully set!", source, 0, 255, 100)
	else
		vip_outputChatBox("Problem saving lightblink speed.", source, 255, 50, 0)
	end
	
end)

addEventHandler('onClientChangeLightblinkEnabled', root,
function(bool)
	if not isPlayerVIP(source) or not vipPlayers[source] then return end

	if bool == true or bool == false then
		local saved = saveVipSetting(source,4,"enabled",bool)
		if saved then
			if bool then
				vip_outputChatBox("Lightblink successfully activated!", source, 0, 255, 100)
			else
				vip_outputChatBox("Lightblink successfully deactivated!", source, 0, 255, 100)
			end
			
			setLightBlink(source)
		else
			vip_outputChatBox("Problem saving lightblink.", source, 255, 50, 0)
		end

	else
		vip_outputChatBox("Invalid argument.", source, 255, 50, 0)
	end

	
	
end)

addEventHandler('onPlayerQuit', root, 
function()
	if blinkTable[source] then blinkTable[source] = nil end
end)

addEventHandler('onResourceStop', resourceRoot,
function()
	for i, p in ipairs(getElementsByType('player')) do
		if blinkTable[p] then
			blinkTable[p] = nil
			local veh = getPedOccupiedVehicle(p)
			if veh then
				setVehicleOverrideLights(veh, 0)				
				setVehicleLightState(veh, 0, 0)
				setVehicleLightState(veh, 3, 0)
				setVehicleLightState(veh, 1, 0)
				setVehicleLightState(veh, 2, 0)
			end
		end
	end
end)
