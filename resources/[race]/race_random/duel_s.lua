local maps = {
	"duel.map",
}

local function getAlivePlayers()
	local players = {}
	for _, player in ipairs(getElementsByType('player')) do
		if getElementData(player, 'player state') == 'alive' then
			table.insert(players, player)
		end
	end
	return players
end

local maproot, initiator

function startDuel(p, c, a)
	if maproot then return end
	local players = getAlivePlayers()
	if exports.race:getRaceMode() ~= "Destruction derby" then return outputChatBox("Not a DD map", p) end
	if #players ~= 2 then return outputChatBox(#players .. " != 2 players for duel", p) end
	
	if getElementData(p, 'player state') ~= 'alive' then return outputChatBox("Only the last two players can start duels", p, 255,0,0) end
	if not initiator then
		outputChatBox(getPlayerStrippedName(p) .. " has requested to duel! /duel to accept", root, 0, 255, 0)
		initiator = p
		return
	elseif p == initiator then
		return
	end
	
	-- Load in random map
	local node = getResourceConfig ( maps[math.random(#maps)] )
	if not node then return outputChatBox("Couldn't load xml", p) end
	maproot = loadMapData ( node, resourceRoot )
	xmlUnloadFile ( node )
	if not maproot then return outputChatBox("Couldn't load map", p) end
	
	-- Find spawns
	local spawns = getElementsByType('spawnpoint', maproot)
	
	for k, p in ipairs(players) do
		local veh = getPedOccupiedVehicle(p)
		
		local s = spawns[k]
		local x, y, z = getElementPosition(s)
		setElementPosition(veh, x, y, z+1)
		setElementRotation(veh, 0, 0, getElementData(s, 'rotZ'))
		setElementFrozen(veh, true)
		setTimer(setElementFrozen, 100, 1, veh, false)
	end
	triggerClientEvent('its_time_to_duel.mp3', resourceRoot)
	outputChatBox("[DUEL] " .. getPlayerName(p) .. " #00FF00accepted a duel!", root, 0,255,0, true)
end
addCommandHandler('duel', startDuel)

function stopDuel() 
	if maproot then
		destroyElement(maproot)
	end
	maproot = nil
	initiator = nil
end
addEvent('stopDuel')
addEventHandler('onPostFinish', root, stopDuel)

function removeHEXFromString(str)
	return str:gsub("#%x%x%x%x%x%x", "")
end

function getPlayerStrippedName(player)
	if not isElement(player) then error('getPlayerStrippedName error', 2) end
	return removeHEXFromString(getPlayerName(player))
end
