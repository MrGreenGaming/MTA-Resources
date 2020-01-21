math.randomseed(getTickCount())
local magnetSlowDownTime = 7000
local markersRespawn = 5000
local marker = {}
local markerTimer = {}

------------------------
-- Gamemode Detection --
------------------------
addEvent('onMapStarting')
addEventHandler('onMapStarting', resourceRoot, 
	function(mapInfo, mapOptions, gameOptions)
		currentGameMode = string.upper(mapInfo.modename)
		if currentGameMode == "DESTRUCTION DERBY" then
			powerTypes = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					--{"magnet"},
					{"jump"},
					{"rock"},
					--{"smoke"},
					{"nitro"},
					{"speed"},
					--{"fly"},
					{"kmz"},
					{"minigun"},
			}
		elseif currentGameMode == "FREEROAM" then
			powerTypes = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					{"magnet"},
					{"jump"},
					{"rock"},
					{"smoke"},
					{"nitro"},
					{"speed"},
					{"fly"},
					{"kmz"},
					{"minigun"},
			}
		elseif currentGameMode == "SPRINT" then
			powerTypes = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					{"magnet"},
					{"jump"},
					{"rock"},
					{"smoke"},
					{"nitro"},
					{"speed"},
					{"fly"},
					{"kmz"},
					{"minigun"},
			}
		elseif currentGameMode == "CAPTURE THE FLAG" then
			powerTypes = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					{"magnet"},
					{"jump"},
					{"rock"},
					{"smoke"},
					{"nitro"},
					{"speed"},
					{"fly"},
					{"kmz"},
					{"minigun"},
			}
		elseif currentGameMode == "REACH THE FLAG" then
			powerTypes = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					{"magnet"},
					{"jump"},
					{"rock"},
					{"smoke"},
					{"nitro"},
					{"speed"},
					{"fly"},
					{"kmz"},
					{"minigun"},
			}
		elseif currentGameMode == "NEVER THE SAME" then
			powerTypes = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					{"magnet"},
					{"jump"},
					{"rock"},
					{"smoke"},
					--{"nitro"},
					{"speed"},
					{"fly"},
					{"kmz"},
					{"minigun"},
			}
		elseif currentGameMode == "SHOOTER" then
			powerTypes = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					{"magnet"},
					{"jump"},
					{"rock"},
					{"smoke"},
					{"nitro"},
					{"speed"},
					{"fly"},
					{"kmz"},
					{"minigun"},
			}
		end
		triggerClientEvent(root, "getAllowedPowerTypes", resourceRoot, powerTypes)
	end
)

--------------------
-- Initialization --
--------------------
addEventHandler("onResourceStart", resourceRoot, 
	function()
		outputChatBox( '#ffffff"Core Markers" by #00dd22AleksCore #fffffflaunched.', root, 255, 0, 0, true)
		showText_Create()
		showText( 54, 201, 46, "Pick-up markers (boxes)\n @\nPress LMB or LCTRL button", 12000, all)
		setTimer(
			function() 
				textItemSetColor(showText_Text, 54, 201, 46, 255) 
				setTimer(
					function() 
						textItemSetColor(showText_Text, 255, 255, 255, 255) 
					end
				, 600, 1)
			end
		, 1000, 11)
		
		for index, object in ipairs(getElementsByType("object")) do
			if getElementModel(object) == 3798 then
				local x, y, z = getElementPosition(object)
				spawnPickup(object, x, y, z)
			end
		end
	end
)


---------------------------
-- Spawn Pickups Handler --
---------------------------
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
	addEventHandler("onColShapeHit", col, getRandomPower)
	------------------------
	-- Floating Animation --
	------------------------
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
end


---------------------------------------------
-- Markers/Pickups Handler - onColShapeHit --
---------------------------------------------
function getRandomPower(thePlayer) --onColShapeHit
	if getElementType(thePlayer) == "player" then
		if getElementData(thePlayer, "coremarkers_powerType") == false then
			setElementData(thePlayer, "coremarkers_powerType", true)
			triggerClientEvent(thePlayer, "getRandomPower", resourceRoot)
			if not source then return end --ignore markers respawn if getRandomPower triggered using bind (for tests only)
			---------------------
			-- Markers Respawn --
			---------------------
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
--[[For tests only
for k,v in pairs(getElementsByType("player")) do
	bindKey(v, "mouse5", "down", getRandomPower)
end
]]


-----------------------
-- Drop Spikes Event --
-----------------------
addEvent("dropSpikes", true)
addEventHandler("dropSpikes", root, 
	function (x, y, z, rz)
		local spikes = createObject(2892, 0, 0, -200, 0, 0, rz+90)
		setObjectScale(spikes, 0.5)
		setElementPosition(spikes, x, y, z+0.1)
		local spikesCol = createColSphere(x, y, z, 2.6)
		setElementParent(spikes, spikesCol)
		
		addEventHandler("onColShapeHit", spikesCol,
		function(thePlayer)
			if getElementType(thePlayer) == "player" then
					if not getElementData(thePlayer, "coremarkers_isPlayerRektBySpikes") then
						local _, _, pz = getElementPosition(thePlayer) --player posZ
						local _, _, sz = getElementPosition(source) --spikes posZ
						if pz >= sz then
							setVehicleWheelStates(getPedOccupiedVehicle(thePlayer), 1, 1, 1, 1)
							setElementData(thePlayer, "coremarkers_isPlayerRektBySpikes", true, true)
							triggerClientEvent(thePlayer, "spikesTimerFunction", resourceRoot)
							destroyElement(source)
						end
					end
			end
		end
		)
	end
)

addEvent("onPlayerPickUpRacePickup", true)
addEventHandler("onPlayerPickUpRacePickup", root, 
	function(pickupID, pickupType)
		if pickupType == "repair" then
			setElementData(source, "coremarkers_isPlayerRektBySpikes", false, true)
		end
	end
)

---------------------
--- Drop Hay Event --
---------------------
addEvent("dropHay", true)
addEventHandler("dropHay", root, 
	function (x, y, z, rz)
		createObject(3374, x, y, z+1.5, 0, 0, rz+90)
	end
)


----------------------
--- Drop Rock Event --
----------------------
addEvent("dropRock", true)
addEventHandler("dropRock", root, 
	function (x, y, z, rz)
		createObject(1305, x, y, z+1.5, 0, 0, rz+90)
	end
)


------------------
--- Smoke Event --
------------------
addEvent("doSmoke", true)
addEventHandler("doSmoke", root, 
	function (x, y, z, rz)
		local theVehicle = getPedOccupiedVehicle(client)
		triggerClientEvent(root, "createSmokeEffect", resourceRoot, x, y, z, rz, theVehicle)
	end
)


----------------------
--- Drop Ramp Event --
----------------------
droppedRampTimer = {}
addEvent("dropRamp", true)
addEventHandler("dropRamp", root, 
	function (x, y, z, rz)
		local ramp = createObject(13645, x, y, z+0.4, 4, 0, rz)
		local rampCol = createColSphere(x, y, z+0.4, 4)
		attachElements(rampCol, ramp, 0, 1.5, 0)
		setElementParent(ramp, rampCol)
	
		addEventHandler("onColShapeHit", rampCol,
			function(hitElement)
				if getElementType(hitElement) == "player" then
					if not isTimer(droppedRampTimer[source]) then
						droppedRampTimer[source] = setTimer(
							function(col)
								if isElement(col) then
									destroyElement(col)
								end
							end
						, 30000, 1, source)
					end
				end
			end
		)
	end
)


-------------------------
--- Drop Barrels Event --
-------------------------
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
	end
)


----------------------------
-- Rocket Launcher Events --
----------------------------
local rocketLauncher = {}
addEvent("createRocketLauncher", true)
addEventHandler("createRocketLauncher", root, 
	function(maxY)
		local theVehicle = getPedOccupiedVehicle(client)
		rocketLauncher[client] = createObject(360, 0, 0, -50)
		attachElements(rocketLauncher[client], theVehicle, -0.04, maxY-0.3, -0.14, 0, 0, 270)
	end
)

addEvent("removeRocketLauncher", true)
addEventHandler("removeRocketLauncher", root, 
	function()
		if rocketLauncher and isElement(rocketLauncher[client]) then destroyElement(rocketLauncher[client]) end
	end
)

function vehicleChange(oldModel, newModel)
	if getElementType(source) == "vehicle" then
		local thePlayer = getVehicleOccupant(source)
		if isElement(thePlayer) and getElementData(thePlayer, "coremarkers_powerType") == "rocket" then 
			local _, _, _, _, maxY, _ = getVehicleBoundingBox(newModel)
			attachElements(rocketLauncher[thePlayer], source, -0.04, maxY-0.3, -0.14, 0, 0, 270)
		end
	end
end
addEventHandler("onElementModelChange", root, vehicleChange)


---------------------
--- Drop Oil Event --
---------------------
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


--------------------
-- Kamikaze Event --
--------------------
kamikazeTimer = {}
preKamikazeTimer = {}
addEvent("kamikazeMode", true)
addEventHandler("kamikazeMode", root, 
	function()
		local theVehicle = getPedOccupiedVehicle(client)
		local marker = attachMarker(theVehicle, 6000, 255, 0, 0, 80)
		triggerClientEvent(root, "create3DSound", resourceRoot, theVehicle, "kmz.mp3")
		if isElement(kamikazeTimer[client]) then killTimer(kamikazeTimer[client]) end
		kamikazeTimer[client] = setTimer(
			function(theVehicle, thePlayer)
				if not isElement(theVehicle) then return end
				setElementData(thePlayer, "kamikaze", true, true)
				local x, y, z = getElementPosition(theVehicle)
				createExplosion(x, y, z, 10, thePlayer)
				createExplosion(x+3, y, z, 10, thePlayer)
				createExplosion(x-3, y, z, 10, thePlayer)
				createExplosion(x, y+3, z, 10, thePlayer)
				createExplosion(x, y-3, z, 10, thePlayer)
				blowVehicle(theVehicle, true)
				----
				setTimer(
					function(thePlayer)
						setElementData(thePlayer, "kamikaze", false, true)
					end
				, 5000, 1, thePlayer)
				----
			end
		, kmzItemTime, 1, theVehicle, client)
		if isElement(preKamikazeTimer[client]) then killTimer(preKamikazeTimer[client]) end
		preKamikazeTimer[client] = setTimer(
			function(marker)
				setTimer(
					function(marker)
						if isElement(marker) then
							setMarkerColor(marker, 255, 255, 255, 255)
							local size = getMarkerSize(marker)
							setMarkerSize(marker, size+0.5)
						end
					end
				, 50, 20, marker)
			end
		, 4800, 1, marker)
	end
)


--------------------
-- Speed X2 Event --
--------------------
local speedMarkerColorTimer = {}
addEvent("speedMode", true)
addEventHandler("speedMode", root, 
	function(speedItemTime)
		local theVehicle = getPedOccupiedVehicle(client)
		local marker = attachMarker(theVehicle, speedItemTime+200, 255, 125, 0, 80)
		speedMarkerColorTimer[client] = setTimer(
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


---------------
-- Fly Event --
---------------
addEvent("flyMode", true)
addEventHandler("flyMode", root, 
	function(flyItemTime)
		local theVehicle = getPedOccupiedVehicle(client)
		attachMarker(theVehicle, flyItemTime+200, 125, 0, 125, 80)
	end
)


------------------
-- Magnet Event --
------------------
addEvent("doMagnet", true)
addEventHandler("doMagnet", root, 
	function()
	-----------for tests
		--[[for k, victim in ipairs(getElementsByType("player")) do
						setElementData(victim, "coremarkers_isPlayerSlowedDown", true, true)
						triggerClientEvent(victim, "slowDownPlayer", resourceRoot, magnetSlowDownTime)
						attachMarker(getPedOccupiedVehicle(victim), magnetSlowDownTime, 0, 0, 255, 80)
						sendClientMessage('#FFFFFF'..getPlayerName(client)..'#00DDFF slows down #FFFFFF'..getPlayerName(victim)..'.', root, 255, 255, 255, "bottom")
		end]]
	----------------------------------
		local killer_rank = getElementData(client, "race rank")
		if type(killer_rank) == "number" and killer_rank >= 2 then
			for k, victim in ipairs(getElementsByType("player")) do
				local rank = getElementData(victim, "race rank")
				if type(rank) == "number" then
					if rank == 1 and getElementData(victim, "state") == "alive" then
						setElementData(victim, "coremarkers_isPlayerSlowedDown", true, true)
						triggerClientEvent(victim, "slowDownPlayer", resourceRoot, magnetSlowDownTime)
						attachMarker(getPedOccupiedVehicle(victim), magnetSlowDownTime, 0, 0, 255, 80)
						sendClientMessage('#FFFFFF'..getPlayerName(client)..'#00DDFF slows down #FFFFFF'..getPlayerName(victim)..'.', root, 255, 255, 255, "bottom")
						if speedMarkerColorTimer and isTimer(speedMarkerColorTimer[victim]) then killTimer(speedMarkerColorTimer[victim]) end
						triggerClientEvent(root, "stop3DSound", resourceRoot, getPedOccupiedVehicle(victim))
					end
				end
			end
		elseif killer_rank == 1 then
			sendClientMessage("Magnet slows down only 1st player, you can't use it against yourself", client, 255, 0, 0, "bottom")
		end
	end
)


---------------------------------------
-- Reset Everything On Death/Respawn --
---------------------------------------
function resetAllTheStuff() 
	if getElementType(source) == "player" then
		player = source
	elseif getElementType(source) == "vehicle" then
		player = getVehicleOccupant(source)
	end
	setElementData(player, "coremarkers_isPlayerSlowedDown", false, true)
	setElementData(player, "coremarkers_isPlayerRektBySpikes", false, true)
	triggerClientEvent(player, "removePower", resourceRoot)
	triggerClientEvent(player, "hideSpikesRepairHUD", resourceRoot)
	triggerClientEvent(player, "stopSpeed", resourceRoot)
	triggerClientEvent(player, "stopFly", resourceRoot)
	if isTimer(kamikazeTimer[player]) then killTimer(kamikazeTimer[player]) end
	if isTimer(preKamikazeTimer[player]) then killTimer(preKamikazeTimer[player]) end
	if isElement(marker[player]) then destroyElement(marker[player]) end
	if isTimer(markerTimer[player]) then killTimer(markerTimer[player]) end
	if rocketLauncher and isElement(rocketLauncher[player]) then destroyElement(rocketLauncher[player]) end
	unbindKey(player, "mouse1", "both", preShootMinigun)
	unbindKey(player, "lctrl", "both", preShootMinigun)
end
addEvent("onPlayerRaceWasted", true)
addEventHandler("onPlayerRaceWasted", root, resetAllTheStuff)
addEventHandler ("onVehicleEnter", root, resetAllTheStuff)

addEventHandler("onElementDataChange", root, 
	function(dataName,oldValue)
		if dataName == "state" then
			if getElementData(source, dataName) == "spectating" or getElementData(source, dataName) ~= "alive"then
				resetAllTheStuff(source) 
			end
		end
	end
)


--------------------------
-- Repair Vehicle Event --
--------------------------
addEvent("fixVehicle", true)
addEventHandler("fixVehicle", root, 
	function(fix) 
		local theVehicle = getPedOccupiedVehicle(client)
		if fix then
			fixVehicle(theVehicle)
		end
		setVehicleWheelStates(theVehicle, 0, 0, 0, 0)
		setElementData(client, "coremarkers_isPlayerRektBySpikes", false, true)
		playSoundFrontEnd(client, 46)
	end
)


-----------------
-- Nitro Event --
-----------------
addEvent("giveNitro", true)
addEventHandler("giveNitro", root, 
	function() 
		local theVehicle = getPedOccupiedVehicle(client)
		addVehicleUpgrade(theVehicle, 1010)
		playSoundFrontEnd(client, 46)
	end
)


----------------
-- Jump Event --
----------------
addEvent("doJump", true)
addEventHandler("doJump", root, 
	function()
		local theVehicle = getPedOccupiedVehicle(client)
		local x, y, z = getElementVelocity(theVehicle)
		setElementVelocity(theVehicle, x, y, z+0.3)
	end
)


-----------------------------
-- Function: Attach Marker --
-----------------------------
function attachMarker(theVehicle, timer, r, g, b, a)
	local player = getVehicleOccupant(theVehicle)
	if isElement(marker[player]) then destroyElement(marker[player]) end
	marker[player] = createMarker( 0, 0, -200, 'corona', 2, r, g, b, 80)
	attachElements(marker[player], theVehicle)
	markerTimer[player] = setTimer(function(marker) if isElement(marker) then destroyElement(marker) end end, timer, 1, marker[player])
	return marker[player]
end


-----------------------
-- Kills Information --
-----------------------
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


------------------------------
-- Function: Start Sound 3D --
------------------------------
function startSound3D(sound)
	local theVehicle = getPedOccupiedVehicle(client)
	triggerClientEvent(root, "create3DSound", resourceRoot, theVehicle, sound)
end
addEvent("startSound3D", true)
addEventHandler("startSound3D", root, startSound3D)


-------------
-- Minigun --
-------------
function preShootMinigun(thePlayer, key, keyState)
	if keyState == "down" then
		triggerClientEvent(root, "startShootMinigun", resourceRoot, thePlayer)
	else
		triggerClientEvent(root, "stopShootMinigun", resourceRoot, thePlayer)
	end
end

function preGiveMinigun()
	local theVehicle = getPedOccupiedVehicle(client)
	triggerClientEvent(root, "giveMinigun", resourceRoot, theVehicle)
	bindKey(client, "mouse1", "both", preShootMinigun)
	bindKey(client, "lctrl", "both", preShootMinigun)
end
addEvent("preGiveMinigun", true)
addEventHandler("preGiveMinigun", root, preGiveMinigun)

function removeMinigun()
	unbindKey(client, "mouse1", "both", preShootMinigun)
	unbindKey(client, "lctrl", "both", preShootMinigun)
end
addEvent("removeMinigun", true)
addEventHandler("removeMinigun", root, removeMinigun)