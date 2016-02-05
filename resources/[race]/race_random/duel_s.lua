local function getAlivePlayers()
	local players = {}
	for _, player in ipairs(getElementsByType('player')) do
		if getElementData(player, 'state') == 'alive' then
			table.insert(players, player)
		end
	end

	table.sort(players,sortFunction)
	return players
end

function duel(p, c, a)
	local players = getAlivePlayers()
	if #players ~= 2 or exports.race:getRaceMode() ~= "Destruction derby" then return end
	
	local map = getResourceMapRootElement(resource, "duel.map")
	local spawns = getElementsByType('spawnpoint', map)
	
	for k, p in ipairs(players) do
		local veh = getPedOccupiedVehicle(p)
		
		local s = spawns[k]
		setElementPosition(veh, getElementPosition(s))
		setElementRotation(veh, 0, 0, getElementData(s, 'rotZ'))
		setElementFrozen(veh, true)
		setTimer(setElementFrozen, 100, 1, veh, false)
		setElementDimension(map, 0)
	end
	triggerClientEvent('its_time_to_duel.mp3', resourceRoot)
	outputChatBox("[DUEL] " .. getPlayerName(p) .. " #00FF00started a duel!", root, 0,255,0, true)
end
addCommandHandler('duel', duel, true)

function stopDuel() 
	local map = getResourceMapRootElement(resource, "duel.map")
	setElementDimension(getResourceMapRootElement(resource, "duel.map"), 9001)
end
addEvent('stopDuel')
addEventHandler('onPostFinish', root, stopDuel)
