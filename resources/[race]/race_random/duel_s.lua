local maps = {
	"duel.map",
}

--Categories was taken from map editor
local tDuelCars = {
					--"2-Door"	
401, 410, 436, 474, 491, 496, 517, 526, 527, 533, 545, 549, 439, 475, 542,
					--"4-Door"
405, 409, 420, 421, 426, 438, 445, 466, 467, 492, 507, 516, 529, 540, 546, 547, 550, 551, 566, 580, 585, 
					--"Lowriders"
412, 419, 518, 534, 535, 536, 567, 575, 576, 
					--"Sports Cars"
402, 411, 415, 429, 451, 477, 480, 506, 541, 555, 558, 559, 560, 562, 565, 587, 602, 603					
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

local maproot, initiator, duelType

function startDuel(p, c, t)
	if maproot then return end
	local players = getAlivePlayers()
	if exports.race:getRaceMode() ~= "Destruction derby" then return outputChatBox("Not a DD map", p) end
	if #players ~= 2 then return outputChatBox(#players .. " != 2 players for duel", p) end
	
	if getElementData(p, 'player state') ~= 'alive' then return outputChatBox("Only the last two players can start duels", p, 255,0,0) end
	if not initiator then
		if t == 2 then 
			outputChatBox(getPlayerStrippedName(p) .. " has requested to duel on #ffffffequal #00ff00cars! /duel to accept", root, 0, 255, 0, true) 
		else 
			outputChatBox(getPlayerStrippedName(p) .. " has requested to duel on #ffffffrandom #00ff00cars! /duel to accept", root, 0, 255, 0, true) 
		end
		initiator = p
		duelType = t
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
	
	exports.race:disableNTSModeForDD()
	exports.gcshop:disableReRoll()
	
	-- Reset water level
	resetWaterLevel ()
	
	-- Find spawns
	local spawns = getElementsByType('spawnpoint', maproot)
	
	local vehicle = tDuelCars[math.random(#tDuelCars)]
	local function returnVehicleModel() 
			if duelType == 2 then 
				return vehicle 
			else 
				return tDuelCars[math.random(#tDuelCars)] 
			end
		end

	for k, p in ipairs(players) do
		local veh = getPedOccupiedVehicle(p)
		setElementModel(veh, returnVehicleModel())
		
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
	duelType = nil
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
