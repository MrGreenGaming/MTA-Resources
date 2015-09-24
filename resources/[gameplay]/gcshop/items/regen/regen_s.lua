-----------------
-- Items stuff --
-----------------

local ID = 3
local g_PlayersRegen = {}
local addition = 2.5
local interval = 500

function loadGCRegenHP ( player, bool, settings )
	if bool then
		g_PlayersRegen[player] = true
	else
		g_PlayersRegen[player] = nil
	end
end


-----------------
-- Regen stuff --
-----------------

function addCarHealth(car, player)
	if not isElement(car) then return end
	-- local x = getElementHealth(car)
	-- setElementHealth(car, math.min(addition + x, 1000))  --105/100 = 5% addition
	-- Do health addition clientside, so we avoid desync mistakes
	triggerClientEvent(player, "addCarHealth", car, addition)
	
end

setTimer(function()
	if not isPerkAllowedInMode(ID) then return end
	for player, _ in pairs(g_PlayersRegen) do 
		if isElement(player) and getElementData(player, 'state') == 'alive' 
			and getPedOccupiedVehicle(player) 
			and not isVehicleDamageProof(getPedOccupiedVehicle(player)) 
			and not isVehicleBlown(getPedOccupiedVehicle(player))
			and getElementHealth(getPedOccupiedVehicle(player)) > 250
			and getElementHealth(getPedOccupiedVehicle(player)) < 1000 then
			addCarHealth(getPedOccupiedVehicle(player), player)
		end
	end
end, interval, 0)

addEventHandler('onPlayerQuit', root, function()
	g_PlayersRegen[source] = nil
end)
