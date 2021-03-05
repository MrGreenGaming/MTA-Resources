

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
	for k, v in ipairs(getElementsByType("player")) do
		if v ~= source then
			local state = getElementData(v, "player state")
			if state ~= "alive" then
				local player = false
				local target = getCameraTarget(v)
				if target and getElementType(target) == "vehicle" then
					player = getVehicleOccupant(target)
				elseif target and getElementType(target) == "player" then
					player = target
				end
				if player and player == source then
					for i, checkpoint in ipairs(checkpoints) do
						triggerClientEvent(v, "hideSign", root, i)
					end
					local x, y, z = getElementPosition(player)
					triggerClientEvent(v, "updateIconsPosition", root, z)
					triggerClientEvent(v, "showSign", root, cp + 1)
				end
			end
		end
	end
end
addEventHandler("onPlayerReachCheckpoint", root, onPlayerReachCheckpoint)

addEvent("onPlayerFinish", true)
function onPlayerFinish()
	for i, checkpoint in ipairs(checkpoints) do
		triggerClientEvent(source, "hideSign", root, i)
	end
	setTimer(function(player)
		triggerClientEvent(player, "showVehChangeIcon", root)
	end, 5000, 1, source)
end
addEventHandler("onPlayerFinish", root, onPlayerFinish)

addEvent("removeIconsOnTimeUp", true)
function onTimeIsUp()
	for k, v in ipairs(getElementsByType("player")) do
		for i, checkpoint in ipairs(checkpoints) do
			triggerClientEvent(v, "hideSign", root, i)
		end
	end
end
addEventHandler("removeIconsOnTimeUp", root, onTimeIsUp)

function onPlayerSpawn()
    setTimer(function(player)
        local cp = getElementData(player, "race.checkpoint")
        if cp then
            for i, checkpoint in ipairs(checkpoints) do
                triggerClientEvent(player, "hideSign", root, i)
            end
            triggerClientEvent(player, "showSign", root, cp)
        end
    end, 100, 1, source)
end
addEventHandler("onPlayerSpawn", root, onPlayerSpawn)
