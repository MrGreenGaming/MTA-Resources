-- add to collisionless
local collisionlessTable = {}
punishedForMap = {}

function getPlayerCollisionless(player)
	return collisionlessTable[player] or false
end

function setPlayerCollisionless(player)

	if getElementType(player) ~= "player" then return end

	
	if not collisionlessTable[player] then 
		-- outputDebugString("[anti] "..getPlayerName(player).." is now set to collisionless mode")
		collisionlessTable[player] = true
		triggerClientEvent("onClientReceiveCollisionlessTable",resourceRoot,collisionlessTable)
	end
end

raceState = false
addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', root,
function(state)
	raceState = state
	if state == "LoadingMap" then
		-- Reset collisionless
		
		collisionlessTable = {}
		punishedForMap = {}
		triggerClientEvent("onClientReceiveCollisionlessTable",resourceRoot,collisionlessTable)
	end

end
)

addEvent("onClientRequestCollisionlessTable",true)
addEventHandler("onClientRequestCollisionlessTable",resourceRoot,function() triggerClientEvent("onClientReceiveCollisionlessTable",resourceRoot,collisionlessTable) end)
addEventHandler("onPlayerQuit",root,function() if collisionlessTable[source] then collisionlessTable[source] = nil triggerClientEvent("onClientReceiveCollisionlessTable",resourceRoot,collisionlessTable) end end)
-- Player vehicles
-- function checkVehicleIDChange(old,new)
-- 	if getElementType(source) == "vehicle" then
-- 		local occupant = getVehicleOccupant(source)
-- 		if occupant and isElement(occupant) and getElementType(occupant) == "player" then
-- 			triggerClientEvent("onPlayerVehicleIDChange",root,occupant)
-- 		end
-- 	end
-- end
-- addEventHandler("onElementModelChange",root,checkVehicleIDChange)
-- addEventHandler("onVehicleEnter",root,checkVehicleIDChange)


-- function gmChecker(name)
-- 	if getElementType(source) == "player" and string.find(name,"overrideCollide") then -- If it's an gm override
-- 		triggerClientEvent("onPlayerVehicleIDChange",root,source)
-- 	end
-- end
-- addEventHandler("onElementDataChange",root,gmChecker)


-- addEvent("onPlayerSpectateCollisionReset")
-- function unSpectateCollision()
-- 	if getElementType(source) == "player" then
-- 		triggerClientEvent("onPlayerVehicleIDChange",root,source)
-- 	end
-- end
-- addEventHandler("onPlayerSpectateCollisionReset",root,unSpectateCollision)
