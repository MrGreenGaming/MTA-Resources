objectStartTick = getTickCount()
playersWithBounty = { -- Object
	-- [player] = Object
}





addEvent("clientReceiveBounty", true)
function receiveBounties(player,amount)
	if localPlayer ~= player then
		local bountyObject = createObject(1313,0,0,-1000)
		setElementAlpha( bountyObject, 190 )
		setElementCollisionsEnabled( bountyObject, false )
		local pveh = getPedOccupiedVehicle( player )
		attachElements( bountyObject, pveh,0,0,1.5 )
		playersWithBounty[player] = bountyObject

	else exports.messages:outputGameMessage("Someone put a bounty on your head, stay alive to get the bounty reward ("..tostring(amount).."GC)!",2.5, 255, 0, 0) end

end
addEventHandler("clientReceiveBounty", resourceRoot, receiveBounties)

addEvent("onClientMapStopping", true)
function removeBountyObjects()
	for f,u in pairs(playersWithBounty) do
		if isElement(u) then
			destroyElement( u )
		end
	end
	playersWithBounty = {}
end
addEventHandler('onClientMapStopping', root, removeBountyObjects)

addEvent("onClientMapStarting", true)
addEventHandler("onClientMapStarting",root, function() objectStartTick = getTickCount() end)

function rotateBountyObject()
	local angle = math.fmod((getTickCount() - objectStartTick) * 360 / 2000, 360)
	for p, obj in pairs(playersWithBounty) do
		if isElement(obj) then
			if isElementStreamedIn(obj) and isElement(p) then
				if isPedDead( p ) then
					destroyElement( obj )
					playersWithBounty[p] = nil
				end
				
				local veh = getPedOccupiedVehicle( p )
				if veh then
					if isElementStreamedIn(veh) then
						local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(veh)
						attachElements( obj, veh, 0, 0, maxz+0.5, 0, 0, angle )
					end
				end
			end
		else playersWithBounty[p] = nil
		end
	end
end
addEventHandler("onClientPreRender", root, rotateBountyObject)