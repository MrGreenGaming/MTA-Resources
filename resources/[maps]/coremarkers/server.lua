local magnetSlowDownTime = 7000

math.randomseed(getTickCount())

addEventHandler("onResourceStart", resourceRoot, 
function()
	outputChatBox( '#ffffff"Core Markers" by #00dd22AleksCore #fffffflaunched.', root, 255, 0, 0, true)
	showText_Create()
	showText( 54, 201, 46, "Pick-up power-ups\n @\n Press LMB or LCTRL button", 12000, all)
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
	setTimer(function () if isElement(marker) then setMarkerColor(marker, math.random(255), math.random(255), math.random(255), 255) end end, 500, 0)
	
	addEventHandler("onColShapeHit", col, getRandomPower)
end

function getRandomPower(thePlayer) --onPlayerPickUpMarker
	if getElementType(thePlayer) == "player" then
		if getElementData(thePlayer, "coremarkers_powerType") == false then
			setElementData(thePlayer, "coremarkers_powerType", true)
			triggerClientEvent(thePlayer, "getRandomPower", resourceRoot)
			local x, y, z = getElementPosition(source)
			if get("coremarkers_respawn") ~= false and type(get("coremarkers_respawn")) == "number" and get("coremarkers_respawn") >= 0  then
				setTimer(spawnPickup, get("coremarkers_respawn"), 1, false, x, y, z)
			else
				setTimer(spawnPickup, 10000, 1, nil, x, y, z)
			end
			removeEventHandler("onColShapeHit", source, getRandomPower)
			destroyElement(source)
		end
	end
end


addEvent("dropSpikes", true)
addEventHandler("dropSpikes", root, 
function (creator, x, y, z, rz)
	local spikes = createObject(2892, 0, 0, -200, 0, 0, rz+90)
	setObjectScale(spikes, 0.5)
	setElementPosition(spikes, x, y, z+0.1)
	local spikesCol = createColSphere(x, y, z, 2.6)
	setElementParent(spikes, spikesCol)
	
	addEventHandler("onColShapeHit", spikesCol,
	function(thePlayer)
		if getElementType(thePlayer) == "player" then
				if not getElementData(thePlayer, "coremarkers_isPlayerRektBySpikes") then
					local _, _, pz = getElementPosition(thePlayer)
					local _, _, sz = getElementPosition(source)
					if pz >= sz then
						setVehicleWheelStates(getPedOccupiedVehicle(thePlayer), 1, 1, 1, 1)
						setElementData(thePlayer, "coremarkers_isPlayerRektBySpikes", true, true)
						triggerClientEvent(thePlayer, "spikesTimerFunction", root)
						destroyElement(source)
					end
				end
		end
	end
	)
end
)


addEvent("dropHay", true)
addEventHandler("dropHay", root, 
function (x, y, z, rz)
	createObject(3374, x, y, z+1.5, 0, 0, rz+90)
end
)


addEvent("dropRamp", true)
addEventHandler("dropRamp", root, 
function (x, y, z, rz)
	local ramp = createObject(13645, x, y, z+0.4, 4, 0, rz)
	local rampCol = createColSphere(x, y, z+0.4, 4)
	setElementParent(ramp, rampCol)

	addEventHandler("onColShapeHit", rampCol,
	function(thePlayer)
		if getElementType(thePlayer) == "player" then
			if not isTimer(destroyTimer) then
				destroyTimer = setTimer(destroyElement, 5000, 1, source)
			end
		end
	end
	)
end
)


addEvent("dropBarrels", true)
addEventHandler("dropBarrels", root, 
function (model, x, y, z, rz)
	local model = tonumber(model)
	local barrels = {}
	barrels[1] = createObject(model, x, y, z+0.4)
	barrels[2] = createObject(model, x+0.5, y+0.5, z+0.4)
	barrels[3] = createObject(model, x-0.5, y-0.5, z+0.4)
	barrels[4] = createObject(model, x+0.5, y-0.5, z+0.4)
	barrels[5] = createObject(model, x-0.5, y+0.5, z+0.4)

	local barrelsCol = createColSphere(x, y, z+0.6, 2.35)
		
	for k, barrel in ipairs(barrels) do
		setElementCollisionsEnabled(barrel, false)
		setElementParent(barrel, barrelsCol)
	end
		
	addEventHandler("onColShapeHit", barrelsCol,
	function(thePlayer)
		if getElementType(thePlayer) == "player" then
			local barrel = getElementChildren(source)
			local x, y, z = getElementPosition(barrel[1])
			triggerClientEvent(root, "createExplosionEffect", root, x, y, z)
			local health = getElementHealth(getPedOccupiedVehicle(thePlayer))
			setElementHealth(getPedOccupiedVehicle(thePlayer), health-math.random(200, 400))
			destroyElement(source)
		end
	end
	)
end
)


addEvent("dropOil", true)
addEventHandler("dropOil", root, 
function (x, y, z, rz)
	local oil = createObject(2717, x, y, z, 90, 0, 0)
	setObjectScale(oil, 2)
	local oilCol = createColSphere(x, y, z+0.4, 2)
	setElementParent(oil, oilCol)
	
	addEventHandler("onColShapeHit", oilCol,
	function(thePlayer)
		if getElementType(thePlayer) == "player" then
			if math.random(2) == 1 then
				setVehicleTurnVelocity(getPedOccupiedVehicle(thePlayer),0, 0, 0.055)
			else
				setVehicleTurnVelocity(getPedOccupiedVehicle(thePlayer),0, 0, -0.055)	
			end
			
			destroyElement(source)
		end
	end
	)
end
)


addEvent("doMagnet", true)
addEventHandler("doMagnet", root, 
function (killer)
	local killer_rank = getElementData(killer, "race rank")
	if killer_rank >= 2 then
		local victim_rank = killer_rank-1
		gotAlivePlayer = false
		for k, victim in ipairs(getElementsByType("player")) do
			local rank = getElementData(victim, "race rank")
			if type(rank) == "number" then
				if rank <= victim_rank and rank >= 1 and getElementData(victim, "state") == "alive" and not gotAlivePlayer and not getElementData(victim, "coremarkers_isPlayerSlowedDown") then
					gotAlivePlayer = true
					setElementData(victim, "coremarkers_isPlayerSlowedDown", true, true)
					triggerClientEvent(victim, "slowDownPlayer", resourceRoot, magnetSlowDownTime)
					attachMarker(getPedOccupiedVehicle(victim), magnetSlowDownTime, 255, 0, 0)
					sendClientMessage('#FFFFFF'..getPlayerName(killer)..'#00DDFF slows down #FFFFFF'..getPlayerName(victim)..'.', root, 255, 255, 255, "bottom")
				end
			end
		end
	elseif killer_rank == 1 then
		sendClientMessage("Magnet won't affect anyone if you're 1st.", killer, 255, 0, 0, "bottom")
	end
end
)


function resetAllTheStuff() 
	if getElementType(source) == "player" then
		player = source
	elseif getElementType(source) == "vehicle" then
		player = getVehicleOccupant(source)
	end
	setElementData(player, "coremarkers_powerType", false)
	setElementData(player, "coremarkers_isPlayerSlowedDown", false, true)
	setElementData(player, "coremarkers_isPlayerRektBySpikes", false, true)
	triggerClientEvent(player, "removePower", resourceRoot)
	triggerClientEvent(player, "hideSpikesRepairHUD", resourceRoot)
end
addEvent("onPlayerRaceWasted", true)
addEventHandler("onPlayerRaceWasted", root, resetAllTheStuff)
addEventHandler ("onVehicleEnter", root, resetAllTheStuff)


addEventHandler("onElementDataChange", root, 
function(dataName,oldValue)
	if dataName == "state" then
		if getElementData(source, dataName) == "spectating" then
			resetAllTheStuff(source) 
		end
	end
end
)

addEvent("fixVehicle", true)
addEventHandler("fixVehicle", root, 
function(thePlayer, theVehicle, fix) 
	if fix then
		fixVehicle(theVehicle)
	end
	setVehicleWheelStates(theVehicle, 0, 0, 0, 0)
	setElementData(thePlayer, "coremarkers_isPlayerRektBySpikes", false, true)
end
)

function attachMarker(theVehicle, timer, r, g, b)
	local marker = createMarker( 0, 0, -200, 'corona', 2, r, g, b)
	attachElements(marker, theVehicle)
	setTimer ( destroyElement, timer, 1, marker )
end
addEvent("attachMarker", true)
addEventHandler("attachMarker", root, attachMarker)


addEvent("outputChatBoxForAll", true)
addEventHandler("outputChatBoxForAll", root,
function (thePlayer, text)
	sendClientMessage(text, root, 255, 255, 255, "bottom")
end
)

addEvent("onPlayerPickUpRacePickup", true)
addEventHandler("onPlayerPickUpRacePickup", root, function(pickupID, pickupType)
	if pickupType == "repair" then
		setElementData(source, "coremarkers_isPlayerRektBySpikes", false, true)
	end
end
)