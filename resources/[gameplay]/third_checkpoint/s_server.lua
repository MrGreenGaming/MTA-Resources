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
	if checkpoints[cp + 3] then
		triggerClientEvent(source, "setThirdCheckpoint", root, checkpoints[cp + 3], not checkpoints[cp + 4])
	else
		triggerClientEvent(source, "clearThirdCheckpoint", root)
	end
end
addEventHandler("onPlayerReachCheckpoint", root, onPlayerReachCheckpoint)

function onPlayerWasted()
	-- cpId is the checkpoint number the player is heading to when dying
	-- The player will be thrown 1 cp back (except when cpId is 1)
	-- So the third checkpoint is cpId + 1
	local cpId = getElementData(source, "race.checkpoint")

	if cpId == 1 then return end

	if checkpoints[cpId + 1] then
		triggerClientEvent(source, "setThirdCheckpoint", root, checkpoints[cpId + 1])
	else 
		triggerClientEvent(source, "clearThirdCheckpoint", root)
	end
end
addEventHandler("onPlayerWasted", root, onPlayerWasted)