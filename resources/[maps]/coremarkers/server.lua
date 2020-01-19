local magnetSlowDownTime = 7000
local markersRespawn = 5000
math.randomseed(getTickCount())
local marker = {}
local markerTimer = {}

addEventHandler("onResourceStart", resourceRoot, 
function()
	outputChatBox( '#ffffff"Core Markers" by #00dd22AleksCore #fffffflaunched.', root, 255, 0, 0, true)
	showText_Create()
	showText( 54, 201, 46, "Pick-up markers (boxes)\n @\nPress LMB or LCTRL button", 12000, all)
	setTimer(function() textItemSetColor(showText_Text, 54, 201, 46, 255) setTimer(function() textItemSetColor(showText_Text, 255, 255, 255, 255) end, 600, 1) end, 1000, 11)
	
	for index, object in ipairs(getElementsByType("object")) do
		if getElementModel(object) == 3798 then
			local x, y, z = getElementPosition(object)
			spawnPickup(object, x, y, z)
		end
	end
end
)

function spawnPickup(object, x, y, z, isRespawn)
	if not z then return end --for tests
	if object == nil then
		object = createObject(3798, x, y, z+0.3)
	end
	
	local marker = createMarker(x, y, z-2.75, "cylinder", 3.3, 0, 255, 0, 255)
	local col = createColSphere(x, y, z, 3.7)
	setElementParent(object, col)
	setElementParent(marker, col)
	setObjectScale(object, 0.6)
	setElementCollisionsEnabled(object, false)
	-------------------------------------------------------------------------------------------------------
	local animationSpeed = 1 --the more the slower
	local box_posZ = 0.3
	local amplitude = 0.1
	local easing = "InOutQuad"
	moveObject(object, animationSpeed*1000, x, y, z+box_posZ+amplitude, 0, 0, 0, easing)
	setTimer(
		function()
			if isElement(object) then 
				moveObject(object, animationSpeed*1000, x, y, z+box_posZ-amplitude, 0, 0, 0, easing)
			end
		end
	, animationSpeed*1000, 1)
	setTimer(
		function() 
			if isElement(object) then 
				moveObject(object, animationSpeed*1000, x, y, z+box_posZ+amplitude, 0, 0, 0, easing) 
				setTimer(
					function()
						if isElement(object) then
							moveObject(object, animationSpeed*1000, x, y, z+box_posZ-amplitude, 0, 0, 0, easing)
						end
				end, animationSpeed*1000, 1)
			end 
		end
	, animationSpeed*2000, 0)
	---------------------------------------------------------------------------------------------------------
	--[[setTimer(
		function() 
			if isElement(marker) then 
				setMarkerColor(marker, math.random(255), math.random(255), math.random(255), 255) 
			end 
		end, 123, 0)]]
	addEventHandler("onColShapeHit", col, getRandomPower)
end

function getRandomPower(thePlayer) --onPlayerPickUpMarker
	if getElementType(thePlayer) == "player" then
		if getElementData(thePlayer, "coremarkers_powerType") == false then
			setElementData(thePlayer, "coremarkers_powerType", true)
			triggerClientEvent(thePlayer, "getRandomPower", resourceRoot)
			if not source then return end --for tests
			local x, y, z = getElementPosition(source)
			if get("coremarkers_respawn") ~= false and type(get("coremarkers_respawn")) == "number" and get("coremarkers_respawn") >= 0  then
				setTimer(spawnPickup, get("coremarkers_respawn"), 1, false, x, y, z, true)
			else
				setTimer(spawnPickup, markersRespawn, 1, nil, x, y, z, true)
			end
			removeEventHandler("onColShapeHit", source, getRandomPower)
			destroyElement(source)
		end
	end
end
--For tests
--[[for k,v in pairs(getElementsByType("player")) do
	bindKey(v, "mouse5", "down", getRandomPower)
end]]

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

addEvent("dropRock", true)
addEventHandler("dropRock", root, 
function (x, y, z, rz)
	createObject(1305, x, y, z+1.5, 0, 0, rz+90)
end
)

addEvent("doSmoke", true)
addEventHandler("doSmoke", root, 
function (x, y, z, rz, theVehicle)
	triggerClientEvent(root, "createSmokeEffect", root, x, y, z, rz, theVehicle)
end
)

addEvent("dropRamp", true)
addEventHandler("dropRamp", root, 
function (x, y, z, rz)
	local ramp = createObject(13645, x, y, z+0.4, 4, 0, rz)
	local rampCol = createColSphere(x, y, z+0.4, 4)
	attachElements(rampCol, ramp, 0, 1.5, 0)
	setElementParent(ramp, rampCol)

	addEventHandler("onColShapeHit", rampCol,
	function(thePlayer)
		if getElementType(thePlayer) == "player" then
			if not isTimer(destroyTimer) then
				destroyTimer = setTimer(destroyElement, 30000, 1, source)
			end
		end
	end
	)
end
)

barrelCreator = {}
addEvent("dropBarrels", true)
addEventHandler("dropBarrels", root, 
function (x, y, z, rz)
	local barrels = {}
	barrels[1] = createObject(1225, x, y, z+0.4)
	barrels[2] = createObject(1225, x+0.5, y+0.5, z+0.4)
	barrels[3] = createObject(1225, x-0.5, y-0.5, z+0.4)
	barrels[4] = createObject(1225, x+0.5, y-0.5, z+0.4)
	barrels[5] = createObject(1225, x-0.5, y+0.5, z+0.4)
	
	for _, barrel in ipairs(barrels) do
		barrelCreator[barrel] = client
	end
	--old "fake" gay barrels which was damaging only single player
	--[[local barrelsCol = createColSphere(x, y, z+0.6, 2.35)
		
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
			setElementHealth(getPedOccupiedVehicle(thePlayer), health-800)
			destroyElement(source)
		end
	end
	)]]	
end
)


addEvent("dropOil", true)
addEventHandler("dropOil", root, 
function (x, y, z, rz)
	local oil = createObject(2717, x, y, z, 90, 0, 0)
	setObjectScale(oil, 2)
	local oilCol = createColSphere(x, y, z+0.4, 2)
	setElementParent(oil, oilCol)
	setElementData(oilCol, "creator", client) --temporary protection for creator from oil
	setTimer( --remove protection after 2s
		function() 
			if isElement(oilCol) then 
				setElementData(oilCol, "creator", nil)
			end
		end
	, 2000, 1)
	
	addEventHandler("onColShapeHit", oilCol,
	function(thePlayer)
		if getElementType(thePlayer) == "player" then
			if getElementData(source, "creator") == thePlayer then return end
			if math.random(2) == 1 then
				setElementAngularVelocity(getPedOccupiedVehicle(thePlayer),0, 0, 0.146)
			else
				setElementAngularVelocity(getPedOccupiedVehicle(thePlayer),0, 0, -0.146)	
			end
			
			destroyElement(source)
		end
	end
	)
end
)

kamikazeTimer = {}
addEvent("kamikazeMode", true)
addEventHandler("kamikazeMode", root, 
function()
	local theVehicle = (getPedOccupiedVehicle(client))
	attachMarker(theVehicle, 6000, 255, 0, 0, 80)
	triggerClientEvent(root, "create3DSound", root, theVehicle, "kmz.mp3")
	if isElement(kamikazeTimer[client]) then killTimer(kamikazeTimer[client]) end
	kamikazeTimer[client] = setTimer(
		function(theVehicle, thePlayer)
			if not isElement(theVehicle) then return end
			setElementData(thePlayer, "kamikaze", true, true)
			local x, y, z = getElementPosition(theVehicle)
			createExplosion(x, y, z, 10, thePlayer)
			blowVehicle(theVehicle, true)
			----
			setTimer(
				function(thePlayer)
					setElementData(thePlayer, "kamikaze", false, true)
				end
			, 5000, 1, thePlayer)
			----
		end
	, 5800, 1, theVehicle, client)
end
)

addEvent("speedMode", true)
addEventHandler("speedMode", root, 
function(theVehicle, speedItemTime)
	local marker = attachMarker(theVehicle, speedItemTime+200, 255, 125, 0, 80)
	speedMarkerColorTimer = setTimer(
		function(marker) 
			if isElement(marker) then
				local r, g, b = getMarkerColor(marker)
				if  g == 125 then
					setMarkerColor(marker, 255, 0, 255, 80)
				else
					setMarkerColor(marker, 255, 125, 0, 80)
				end
			end
		end
	, 200, (speedItemTime/200)+1, marker)
end
)

addEvent("doMagnet", true)
addEventHandler("doMagnet", root, 
function (killer)
-----------for tests
	--[[for k, victim in ipairs(getElementsByType("player")) do
					setElementData(victim, "coremarkers_isPlayerSlowedDown", true, true)
					triggerClientEvent(victim, "slowDownPlayer", resourceRoot, magnetSlowDownTime)
					attachMarker(getPedOccupiedVehicle(victim), magnetSlowDownTime, 0, 0, 255, 80)
					sendClientMessage('#FFFFFF'..getPlayerName(killer)..'#00DDFF slows down #FFFFFF'..getPlayerName(victim)..'.', root, 255, 255, 255, "bottom")
	end]]
----------------------------------
	local killer_rank = getElementData(killer, "race rank")
	if killer_rank >= 2 then
		for k, victim in ipairs(getElementsByType("player")) do
			local rank = getElementData(victim, "race rank")
			if type(rank) == "number" then
				if rank == 1 and getElementData(victim, "state") == "alive" then
					setElementData(victim, "coremarkers_isPlayerSlowedDown", true, true)
					triggerClientEvent(victim, "slowDownPlayer", resourceRoot, magnetSlowDownTime)
					attachMarker(getPedOccupiedVehicle(victim), magnetSlowDownTime, 0, 0, 255, 80)
					sendClientMessage('#FFFFFF'..getPlayerName(killer)..'#00DDFF slows down #FFFFFF'..getPlayerName(victim)..'.', root, 255, 255, 255, "bottom")
				end
			end
		end
	elseif killer_rank == 1 then
		sendClientMessage("Magnet slows down only 1st player, you can't use it against yourself", killer, 255, 0, 0, "bottom")
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
	triggerClientEvent(player, "stopSpeed", resourceRoot)
	triggerClientEvent(player, "stopFly", resourceRoot)
	if isTimer(kamikazeTimer[player]) then killTimer(kamikazeTimer[player]) end
	if isElement(marker[player]) then destroyElement(marker[player]) end
	if isTimer(markerTimer[player]) then killTimer(markerTimer[player]) end
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

addEvent("doJump", true)
addEventHandler("doJump", root, 
function(theVehicle)
	local x, y, z = getElementVelocity(theVehicle)
	setElementVelocity(theVehicle, x, y, z+0.3)
end
)

function attachMarker(theVehicle, timer, r, g, b, a)
	local player = getVehicleOccupant(theVehicle)
	marker[player] = createMarker( 0, 0, -200, 'corona', 2, r, g, b, 80)
	attachElements(marker[player], theVehicle)
	markerTimer[player] = setTimer(destroyElement, timer, 1, marker[player])
	return marker[player]
end
addEvent("attachMarker", true)
addEventHandler("attachMarker", root, attachMarker)


addEvent("Kill", true)
addEventHandler("Kill", root,
function (killer)
	if getElementType(killer) == "vehicle" then killer = getVehicleOccupant(killer) end
	if getElementType(killer) == "object" then 
		if barrelCreator[killer] then
			killer = barrelCreator[killer]
		else
			return
		end
	end
	local victim = client
	local a = string.gsub (getElementData(victim, 'vip.colorNick') or getPlayerName(victim), '#%x%x%x%x%x%x', '' )
	local b = string.gsub (getElementData(killer, 'vip.colorNick') or getPlayerName(killer), '#%x%x%x%x%x%x', '' )
	sendClientMessage(a .. " was killed by " .. b, root, 255, 255, 255, "bottom")
end
)

addEvent("onPlayerPickUpRacePickup", true)
addEventHandler("onPlayerPickUpRacePickup", root, function(pickupID, pickupType)
	if pickupType == "repair" then
		setElementData(source, "coremarkers_isPlayerRektBySpikes", false, true)
	end
end
)

function startSound3D(theVehicle, sound)
	triggerClientEvent(root, "create3DSound", root, theVehicle, sound)
end
addEvent("startSound3D", true)
addEventHandler("startSound3D", root, startSound3D)

local minigunTimer = {}
function giveMinigun()
	giveWeapon(client, 38, 60, true)
	setPedWeaponSlot(client, 7)
	setPedDoingGangDriveby(client, true)
	if isTimer(minigunTimer[client]) then killTimer(minigunTimer[client]) end
	minigunTimer[client] = setTimer(setPedDoingGangDriveby, 10000, 1, client, false)
end
addEvent("giveMinigun", true)
addEventHandler("giveMinigun", root, giveMinigun)

function startSound3D(theVehicle, sound)
	triggerClientEvent(root, "create3DSound", root, theVehicle, sound)
end
addEvent("startSound3D", true)
addEventHandler("startSound3D", root, startSound3D)