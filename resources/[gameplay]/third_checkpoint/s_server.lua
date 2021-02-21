local modes = {}
modes["Sprint"] = true
modes["Never the same"] = true

local checkpoints

function onMapStart(mapInfo, mapOptions, gameOptions)
	for i, player in ipairs(getElementsByType("player")) do
		triggerClientEvent(player, "clearThirdCheckpoint", root)
	end

	if not modes[exports.race:getRaceMode()] then return false end

	checkpoints = exports.race:getCheckPoints()

	if checkpoints[3] then
		for i, player in ipairs(getElementsByType("player")) do
			triggerClientEvent(player, "setThirdCheckpoint", root, checkpoints[3])
		end
	end

end
addEventHandler("onMapStarting", getRootElement(), onMapStart)

function onPlayerJoin()
	if not modes[exports.race:getRaceMode()] then return false end

	if checkpoints[3] then
		triggerClientEvent(source, "setThirdCheckpoint", root, checkpoints[3])
	end
end
addEventHandler("onPlayerJoin", root, onPlayerJoin)

function onPlayerReachCheckpoint(cp)
	if not modes[exports.race:getRaceMode()] then return false end

	if checkpoints[cp + 3] then
		local facing = checkpoints[cp + 4] and checkpoints[cp + 4].position or nil
		triggerClientEvent(source, "setThirdCheckpoint", root, checkpoints[cp + 3], not checkpoints[cp + 4], facing)
	else
		triggerClientEvent(source, "clearThirdCheckpoint", root)
	end
end
addEventHandler("onPlayerReachCheckpoint", root, onPlayerReachCheckpoint)

function onPlayerSpawn()
	if not modes[exports.race:getRaceMode()] then return false end
	setTimer(function(player)
		local cpId = getElementData(player, "race.checkpoint")

		if not cpId then return false end
		
		if checkpoints[cpId + 2] then
			triggerClientEvent(player, "setThirdCheckpoint", root, checkpoints[cpId + 2], not checkpoints[cpId + 3])
		else
			triggerClientEvent(player, "clearThirdCheckpoint", root)
		end
	end, 100, 1, source)
end
addEventHandler("onPlayerSpawn", root, onPlayerSpawn)
