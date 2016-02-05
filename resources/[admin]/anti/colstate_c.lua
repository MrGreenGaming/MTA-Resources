local theCollisionlessTable = {}
addEventHandler("onClientResourceStart",resourceRoot,function() triggerServerEvent("onClientRequestCollisionlessTable",resourceRoot) end)


addEvent("onClientReceiveCollisionlessTable",true)
addEventHandler("onClientReceiveCollisionlessTable",root,function(t)
	theCollisionlessTable = t
	for _, p in ipairs(getElementsByType'player') do
		setElementData(p, 'markedlagger', t[p] or nil, false)
	end
	setCollision("refresh")
end)



-- addEvent("onPlayerVehicleIDChange",true)
function setCollision()
	local mode = getResourceFromName'race' and getResourceState(getResourceFromName'race')=='running' and exports.race:getRaceMode()
	if not mode or mode == "Shooter" then return end
	
	for p,_ in pairs(theCollisionlessTable) do

		if p ~= localPlayer then
			local vehMe = getPedOccupiedVehicle(localPlayer)
			local vehCollLess = getPedOccupiedVehicle(p)
			if vehMe and vehCollLess then
				setElementCollidableWith(vehMe, vehCollLess, false)
				setElementAlpha(vehCollLess, 140)
			end
		end
	end
end
setTimer(setCollision,50,0)
-- addEventHandler("onPlayerVehicleIDChange",root,setCollision)

addEventHandler("onClientExplosion",root,function() if theCollisionlessTable[source] then cancelEvent() end end)