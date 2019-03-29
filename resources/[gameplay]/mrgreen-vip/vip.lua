--Lights blinking
local blinkTable = {}
function cmdLightBlink(player, cmd, time)
	if not hasObjectPermissionTo ( player, "command.ban" ) then return end  -- change it to vip only
	
	local playerObject
	
	if not time then 
		if blinkTable[player] then
			killTimer(blinkTable[player]["timer"])
			blinkTable[player] = false
			local vehicle = getPedOccupiedVehicle(player)
			if vehicle then
				setVehicleOverrideLights(vehicle, 2)
				setVehicleLightState(vehicle, 0, 0)
				setVehicleLightState(vehicle, 1, 0)
				setVehicleLightState(vehicle, 2, 0)
				setVehicleLightState(vehicle, 3, 0)
			end
			outputChatBox("Stopped blinking", player, 50, 255, 50)
		else
			outputChatBox("Usage: /"..cmd.." [time in milliseconds]", player, 255, 0, 0)
		end
		return
	end
	
	if not tonumber(time) then
		outputChatBox("Time in milliseconds must be a number!", player, 255, 0, 0)
		return
	end
	
	if tonumber(time) < 250 or tonumber(time) > 1000 then
		outputChatBox("Time must be between 250 and 1000 milliseconds!", player, 255, 0, 0)
		return
	end
	
	if blinkTable[player] then
		playerObject = blinkTable[player]
	else
		playerObject = {}
	end
	
	if playerObject.blinking then
		killTimer(blinkTable[player]["timer"])
		blinkTable[player]["timer"] = setTimer(blink, tonumber(time), 0, player)
		outputChatBox("Updated blinking time to "..time.." milliseconds", player, 50, 255, 50)
	else
		playerObject.blinking = true
		playerObject.left = true
		playerObject.timer = setTimer(blink, tonumber(time), 0, player)
		blinkTable[player] = playerObject
		outputChatBox("Started blinking every "..time.." milliseconds", player, 50, 255, 50)
		outputChatBox("To stop the blinking, type /"..cmd, player, 50, 255, 50)
	end
end
addCommandHandler('lightblink', cmdLightBlink)

function blink(player)
	if not blinkTable[player] then return end
	
	local playerObject = blinkTable[player]
	if not playerObject.blinking then return end
	
	local vehicle = getPedOccupiedVehicle(player)
	if not vehicle then return end
	
	setVehicleOverrideLights(vehicle, 2)
	
	local leftValue
	local rightValue
	
	if playerObject.left then
		leftValue = 0
		rightValue = 1
	else
		leftValue = 1
		rightValue = 0
	end
	
	setVehicleLightState(vehicle, 0, leftValue)
	setVehicleLightState(vehicle, 3, leftValue)
	setVehicleLightState(vehicle, 1, rightValue)
	setVehicleLightState(vehicle, 2, rightValue)
	
	playerObject.left = not playerObject.left
	
	blinkTable[player] = playerObject
end
