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

    -- <spawnpoint id="spawnpoint (NRG-500) (1)" vehicle="522" team="none" posX="-932.79999" posY="-328" posZ="2.2" rotX="0" rotY="0" rotZ="270"></spawnpoint>
    -- <spawnpoint id="spawnpoint (NRG-500) (2)" vehicle="522" team="none" posX="-315" posY="-328" posZ="2.2" rotX="0" rotY="0" rotZ="90"></spawnpoint>
    local spawnInfo = {
    {vehicle="522", team="none", posX=-932.79999, posY=-328, posZ=2.2, rotX=0, rotY=0, rotZ=270},
    {vehicle="522", team="none", posX=-315, posY=-328, posZ=2.2, rotX=0, rotY=0, rotZ=90}
}
function createDuelSpawns()
	for i=1,2 do
		local spawnpoint = createElement( "duelspawn", "duelspawn"..i )
		setElementParent( spawnpoint, resourceRoot )
		for name,val in pairs(spawnInfo[i]) do
			setElementData( spawnpoint, name, val )
		end
		setElementPosition( spawnpoint, spawnInfo[i].posX, spawnInfo[i].posY, spawnInfo[i].posZ )
		setElementRotation( spawnpoint, spawnInfo[i].rotX, spawnInfo[i].rotY, spawnInfo[i].rotZ )
	end
end
addEventHandler("onResourceStart",resourceRoot,createDuelSpawns)


function duel(p, c, a)
	local players = getAlivePlayers()
	if #players ~= 2 or exports.race:getRaceMode() ~= "Destruction derby" then return end
	
	-- local map = getResourceMapRootElement(resource, "duel.map")
	local spawns = getElementsByType('duelspawn', resourceRoot)
	
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
end
addCommandHandler('duel', duel, true)

function stopDuel() 
	local map = getResourceMapRootElement(resource, "duel.map")
	setElementDimension(getResourceMapRootElement(resource, "duel.map"), 9001)
end
addEvent('stopDuel')
addEventHandler('onPostFinish', root, stopDuel)
