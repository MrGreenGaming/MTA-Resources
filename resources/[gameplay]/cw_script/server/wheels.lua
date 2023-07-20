-- When the resource is started - set all players' wheels to the offroad ones
function onResourceStart()
    outputInfo("To change your wheels use: /wheels offroad|default")
	for i, player in ipairs(getElementsByType("player")) do
		if isPedInVehicle(player) then
			local veh = getPedOccupiedVehicle(player)
			local wwWheels = getElementData(player, "wheels")
			if (getVehicleType(veh) == "Automobile") or (getVehicleType(veh) == "Monster Truck") or (getVehicleType(veh) == "Quad") then
				if wwWheels == false then addVehicleUpgrade(veh, 1025) else removeVehicleUpgrade ( veh, 1025 ) end

			end
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)

-- When a player spawns - set their wheels to the offroad ones
function onPlayerSpawn()
	setTimer(function(player)
		if isPedInVehicle(player) then
			local veh = getPedOccupiedVehicle(player)
			local wwWheels = getElementData(player, "wheels")
			if (getVehicleType(veh) == "Automobile") or (getVehicleType(veh) == "Monster Truck") or (getVehicleType(veh) == "Quad") then
				if wwWheels == false then addVehicleUpgrade(veh, 1025) else removeVehicleUpgrade ( veh, 1025 ) end
			end
		end
	end, 1000, 1, source)
end
addEventHandler("onPlayerSpawn", root, onPlayerSpawn)

-- When a player hits a vehicle change pickup - set their wheels to the offroad ones
addEvent("onPlayerPickUpRacePickup", true)
function onPlayerPickUpRacePickup(pickupID, pickupType, vehicleModel)
	if pickupType == "vehiclechange" then
		if isPedInVehicle(source) then
			local veh = getPedOccupiedVehicle(source)
			local wwWheels = getElementData(source, "wheels")
			if (getVehicleType(veh) == "Automobile") or (getVehicleType(veh) == "Monster Truck") or (getVehicleType(veh) == "Quad") then
				if wwWheels == false then addVehicleUpgrade(veh, 1025) else removeVehicleUpgrade ( veh, 1025 ) end
			end
		end
	end
end
addEventHandler("onPlayerPickUpRacePickup", root, onPlayerPickUpRacePickup)


-- When a player hits the last checkpoint aka finishes the race - set their wheels to the offroad ones
-- This is done so that if there is a vehicle change checkpoint as the last one, the offroad wheels would get set to the new vehicle
addEvent("onPlayerFinish", true)
function onPlayerFinish()
	if isPedInVehicle(source) then
		local veh = getPedOccupiedVehicle(source)
		local wwWheels = getElementData(source, "wheels")
		if (getVehicleType(veh) == "Automobile") or (getVehicleType(veh) == "Monster Truck") or (getVehicleType(veh) == "Quad") then
			  if wwWheels == false then addVehicleUpgrade(veh, 1025) else removeVehicleUpgrade ( veh, 1025 ) end
		end
	end
end
addEventHandler("onPlayerFinish", root, onPlayerFinish)


function ChooseWheels(source, commandName, WheelsType)
	if WheelsType == "default" then

		outputChatBox("You switched to default wheels.", source, 255, 255, 255, true)
		setElementData(source, "wheels", true)

		if isPedInVehicle(source) then
			local veh = getPedOccupiedVehicle(source)
			local wwWheels = getElementData(source, "wheels")
			if (getVehicleType(veh) == "Automobile") or (getVehicleType(veh) == "Monster Truck") or (getVehicleType(veh) == "Quad") then
				removeVehicleUpgrade ( veh, 1025 )
			end
		end

	elseif WheelsType == "offroad" then

		outputChatBox("You switched to offroad wheels.", source, 255, 255, 255, true)
		setElementData(source, "wheels", false)

		if isPedInVehicle(source) then
			local veh = getPedOccupiedVehicle(source)
			local wwWheels = getElementData(source, "wheels")
			if (getVehicleType(veh) == "Automobile") or (getVehicleType(veh) == "Monster Truck") or (getVehicleType(veh) == "Quad") then
				addVehicleUpgrade(veh, 1025)
			end
		end
	else
		outputChatBox("Use: /wheels offroad|default", source, 255, 255, 255, true)
	end

end
addCommandHandler("wheels", ChooseWheels)

addEvent("onPlayerConnect", true)
function onPlayerConnect()
	setElementData(source, "wheels", true)
end
addEventHandler("onPlayerConnect", root, onPlayerConnect)



