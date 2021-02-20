

local modes = {}
modes['Sprint'] = true

local checkpoints

function onMapStart(mapInfo, mapOptions, gameOptions)

	for i, player in ipairs(getElementsByType("player")) do
		triggerClientEvent(player, "deleteSigns" ,root)
	end

	if not modes[exports.race:getRaceMode()] then return false end

	checkpoints = exports.race:getCheckPoints()

	for i, checkpoint in ipairs(checkpoints) do
		-- This checkpoint has a vehicle change
		if checkpoint.vehicle then
			for j, player in ipairs(getElementsByType("player")) do
				triggerClientEvent(player, "setSign",root, i , checkpoint.position, getVehicleType(checkpoint.vehicle), getVehicleNameFromModel(checkpoint.vehicle), checkpoint.type)
			end

		end
	end

end
addEventHandler("onMapStarting", getRootElement(), onMapStart)

function onPlayerJoin()
	if not modes[exports.race:getRaceMode()] then return false end
	
	for i, checkpoint in ipairs(checkpoints) do
		if checkpoint.vehicle then
			triggerClientEvent(source, "setSign", root, i, checkpoint.position, getVehicleType(checkpoint.vehicle), getVehicleNameFromModel(checkpoint.vehicle), checkpoint.type)
		end
	end
end
addEventHandler("onPlayerJoin", root, onPlayerJoin)

function onPlayerReachCheckpoint(cp)

	triggerClientEvent(source, "hideSign", root, cp)
	triggerClientEvent(source, "showSign", root, cp + 1)

end
addEventHandler("onPlayerReachCheckpoint", root, onPlayerReachCheckpoint)
