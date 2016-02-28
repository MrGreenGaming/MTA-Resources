local maps = {
	"duel.map",
}

local function getAlivePlayers()
	local players = {}
	for _, player in ipairs(getElementsByType('player')) do
		if getElementData(player, 'state') == 'alive' then
			table.insert(players, player)
		end
	end
	return players
end

local mapname, maproot

function startDuel(p, c, a)
	local players = getAlivePlayers()
	if exports.race:getRaceMode() ~= "Destruction derby" then return outputChatBox("Not a DD map", p) end
	if #players ~= 2 then return outputChatBox(#players .. " != 2 players for duel", p) end
	
	-- Load in random map
	mapname = maps[math.random(#maps)]
	local node = getResourceConfig ( mapname )
	if not node then return outputChatBox("Couldn't load xml", p) end
	maproot = loadMapData ( node, resourceRoot )
	xmlUnloadFile ( node )
	if not maproot then return outputChatBox("Couldn't load map", p) end
	
	-- Find spawns
	local spawns = getElementsByType('spawnpoint', maproot)
	
	for k, p in ipairs(players) do
		local veh = getPedOccupiedVehicle(p)
		
		local s = spawns[k]
		setElementPosition(veh, getElementPosition(s))
		setElementRotation(veh, 0, 0, getElementData(s, 'rotZ'))
		setElementFrozen(veh, true)
		setTimer(setElementFrozen, 100, 1, veh, false)
	end
	triggerClientEvent('its_time_to_duel.mp3', resourceRoot)
	outputChatBox("[DUEL] " .. getPlayerName(p) .. " #00FF00started a duel!", root, 0,255,0, true)
end
addCommandHandler('duel', startDuel, true)

function stopDuel() 
	if maproot then
		destroyElement(maproot)
		maproot = nil
	end
end
addEvent('stopDuel')
addEventHandler('onPostFinish', root, stopDuel)
