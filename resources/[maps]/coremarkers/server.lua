addEventHandler("onResourceStart", resourceRoot, 
function()
showText_Create()
showText( 54, 201, 46, "Pick-up power-ups\n @\n Press Fire button", 12000, all)
setTimer(function() textItemSetColor(showText_Text, 54, 201, 46, 255) setTimer(function() textItemSetColor(showText_Text, 255, 255, 255, 255) end, 600, 1) end, 1000, 11)

	for index, object in ipairs(getElementsByType("object")) do
		if getElementModel(object) == 3798 then
			local x, y, z = getElementPosition(object)
			spawnPickup(object, x, y, z)
		end
	end
end
)

function spawnPickup(object, x, y, z)
	if object == nil then
		object = createObject(3798, x, y, z+0.5)
	end
	
	local marker = createMarker(x, y, z-2.5, "cylinder", 3.3, math.random(255), math.random(255), math.random(255), 255)
	local col = createColSphere(x, y, z, 3.7)
	setElementParent(object, col)
	setElementParent(marker, col)
	setObjectScale(object, 0.6)
	setElementCollisionsEnabled(object, false)
	moveObject(object, 5000, x, y, z+0.5, 0, 0, 360)
	setTimer(function () if isElement(object) then moveObject(object, 5000, x, y, z+0.5, 0, 0, 360) end end, 5000, 0)
	setTimer(function () if isElement(marker) then setMarkerColor(marker, math.random(255), math.random(255), math.random(255), 255) end end, 1000, 0)
	
	addEventHandler("onColShapeHit", col, getRandomPower)
end

function getRandomPower(thePlayer)
if getElementType(thePlayer) == "player" then
	if getElementData(thePlayer, "player_have_power") == false then
		setElementData(thePlayer, "player_have_power", true, true)
		triggerClientEvent(thePlayer, "getRandomPower", resourceRoot)
		local x, y, z = getElementPosition(source)
		if get("coremarkers_respawn") ~= false and type(get("coremarkers_respawn")) == "number" and get("coremarkers_respawn") >= 0  then
			setTimer(spawnPickup, get("coremarkers_respawn"), 1, nil, x, y, z)
		else
			setTimer(spawnPickup, 10000, 1, nil, x, y, z)
		end
		removeEventHandler("onColShapeHit", source, getRandomPower)
		destroyElement(source)
	end
end
end

function dropSpikes(theVehicle, x, y, z, rz, minY)
	local spikes = createObject(2892, 0, 0, -200, 0, 0, rz+90)
	setObjectScale(spikes, 0.5)
	setElementPosition(spikes, x, y, z+0.1)
	local spikesCol = createColSphere(x, y, z, 2.6)
	setElementParent(spikes, spikesCol)

	addEventHandler("onColShapeHit", spikesCol,
	function(thePlayer)
		if getElementType(thePlayer) == "player" then
			local _, _, pz = getElementPosition(thePlayer)
			local _, _, sz = getElementPosition(source)
			if pz >= sz then
				setVehicleWheelStates(getPedOccupiedVehicle(thePlayer), 1, 1, 1, 1)
			end
		end
	end
	)
end
addEvent("dropSpikes", true)
addEventHandler("dropSpikes", root, dropSpikes)

function dropHay(theVehicle, x, y, z, rz)
createObject(3374, x, y, z+1.5, 0, 0, rz+90)
end
addEvent("dropHay", true)
addEventHandler("dropHay", root, dropHay)

function dropBarrel(theVehicle, x, y, z, rz)
createObject(1225, x, y, z+0.4)
end
addEvent("dropBarrel", true)
addEventHandler("dropBarrel", root, dropBarrel)

function dropOil(theVehicle, x, y, z, rz, minY)
	local oil = createObject(2717, x, y, z, 90, 0, 0)
	setObjectScale(oil, 2)
	local oilCol = createColSphere(x, y, z, 2)
	setElementParent(oil, oilCol)
	
	addEventHandler("onColShapeHit", oilCol,
	function(thePlayer)
		if getElementType(thePlayer) == "player" then
			if math.random(2) == 1 then
				setVehicleTurnVelocity(getPedOccupiedVehicle(thePlayer),0, 0, 0.07)	
			else
				setVehicleTurnVelocity(getPedOccupiedVehicle(thePlayer),0, 0, -0.07)	
			end
		end
	end
	)
end
addEvent("dropOil", true)
addEventHandler("dropOil", root, dropOil)

function slowDownPlayer(player, killer)
					setElementData(player, "dxShowTextToVictim", tostring("Player '"..getPlayerName(killer).."#006EFF' slowing you down"), true)
					setTimer(setElementData, 8000, 1, player, "dxShowTextToVictim", nil, true)
					triggerClientEvent(player, "slowDownPlayer", resourceRoot, player, killer)
end
addEvent("slowDownPlayer", true)
addEventHandler("slowDownPlayer", root, slowDownPlayer)
