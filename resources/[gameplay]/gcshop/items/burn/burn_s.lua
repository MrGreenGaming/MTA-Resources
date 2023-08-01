-----------------
-- Items stuff --
-----------------

local ID, IDextra, IDextra2 = 6, 7, 8
local g_PlayersBurn = {}
local g_PlayersBurnExtra = {}
local g_PlayersBurnTransfer = {}

function loadGCBurn ( player, bool, settings )
	if bool then
		g_PlayersBurn[player] = true
	else
		g_PlayersBurn[player] = nil
	end
end

function loadGCBurnExtra ( player, bool, settings )
	if bool then
		g_PlayersBurnExtra[player] = true
	else
		g_PlayersBurnExtra[player] = nil
	end
end

function loadGCBurnTransfer ( player, bool, settings )
	if bool then
		g_PlayersBurnTransfer[player] = true
	else
		g_PlayersBurnTransfer[player] = nil
	end
end

addEventHandler('onPlayerQuit', root, function()
	g_PlayersBurn[source] = nil
	g_PlayersBurnExtra[source] = nil
end)


----------------
-- Burn stuff --
----------------

local busy_with_player = {}
local currentRaceState
local extratime = 2500			-- interval of how much time is added
local extra = 2					-- for the extra perk, how many times extratime is added (nonextra = 1 : 7.5secs, extra = 2 : 10secs)

function onRaceStateChanging( newStateName, oldStateName)
	currentRaceState = newStateName
end
addEvent('onRaceStateChanging')
addEventHandler('onRaceStateChanging', root, onRaceStateChanging)

function onVehicleDamage(loss)
	local veh = source
	local player = getVehicleOccupant(veh)
	if not isElement(player) then return end
	local playerState = getElementData(player, 'state', false)
	if busy_with_player[player] or getElementData(player,"race.finished") or not g_PlayersBurn[player]
		or (currentRaceState and currentRaceState ~= "Running" and currentRaceState ~= "SomeoneWon") or playerState ~= "alive" then
		return
	elseif not isPerkAllowedInMode(ID) then
		return
    elseif getResourceState(getResourceFromName("cw_script")) == "running" and exports.cw_script:areTeamsSet() then
        return
	elseif isElement(veh) and getElementHealth(veh) - loss < 250 then
		busy_with_player[player] = true
		if not g_PlayersBurnExtra[player] then
			return setTimer(resetBurnUpTime, 5000 - extratime, 1, player)
		else
			return setTimer(resetBurnUpTime, 5000 - extratime, 1, player, extra)
		end
	end
end
addEventHandler('onVehicleDamage', root, onVehicleDamage)
--addCommandHandler('gcblow', function(p,c,n) setElementHealth(getPedOccupiedVehicle(p), tonumber(n)) end )

function resetBurnUpTime(player, times, marker, marker1)
	if not (isElement(player) and getPedOccupiedVehicle(player) and isElement(getPedOccupiedVehicle(player)) and getElementHealth(getPedOccupiedVehicle(player)) < 250)
		or getElementData(player,"race.finished") or (currentRaceState and currentRaceState ~= "Running" and currentRaceState ~= "SomeoneWon") or getElementData(player, 'state', false) ~= "alive"
		then
		busy_with_player[player] = nil
		if isElement(marker) then destroyElement(marker) end
		if isElement(marker1) then destroyElement(marker1) end
		return
	end

	busy_with_player[player] = true
	local veh = getPedOccupiedVehicle(player)
	setElementHealth(veh, 250)
	setTimer(function(veh) if isElement(veh) then setElementHealth(veh,1)end end, 50, 1, veh)

	if not (marker and marker1 and isElement(marker) and isElement(marker1)) then
		local px, py, pz = getElementPosition(veh)
		marker = createMarker( px, py, pz, 'corona', 2);	setElementParent(marker, veh);	attachElements(marker, veh)
		marker1 = createMarker( px, py, pz, 'corona', 2);	setElementParent(marker1, veh);	attachElements(marker1, veh)
	end

	if type(times) ~= "number" or times <= 1 then
		setTimer ( function(player, marker, marker1)
			busy_with_player[player] = nil
			if isElement(marker) then destroyElement(marker) end
			if isElement(marker1) then destroyElement(marker1) end
		end, 5000, 1, player, marker, marker1 )
	else
		setTimer ( resetBurnUpTime, extratime, 1, player, times - 1, marker, marker1 )
	end

	exports.messages:outputGameMessage('You burned a little longer! ' .. (times or ''), player)
end


-------------------------
-- Fire transfer stuff --
-------------------------

local g_Players = {}
local timers = {}

function onServerRecieveCollisionData(hitCar, usedCar)
	local hitWho = getVehicleController(hitCar)
	if not hitWho then return end  --avoid unexpected error
	g_Players[source] = hitWho
	timers[source] = setTimer(function(player) g_Players[player] = nil end, 1000+getPlayerPing(hitWho), 1, source)    --assume 1 second + other player's ping is the interval in which the parties can collide. If it should take more than 1 second then the collision is one-sided client
	if g_Players[hitWho] == source then   --we have a fully synced collision between 2 players' cars
		triggerEvent('onPlayersVehicleCollide', root, source, usedCar, hitWho, hitCar)
		g_Players[source] = nil
		g_Players[hitWho] = nil
	end
end
addEvent('onServerRecieveCollisionData', true)
addEventHandler('onServerRecieveCollisionData', root, onServerRecieveCollisionData)

local _getPlayerName = getPlayerName
local function getPlayerName(player)
	return string.gsub(_getPlayerName(player),"#%x%x%x%x%x%x","")
end

-- function onPlayersVehicleCollide (player1, car1, player2, car2)
-- 	local saveFireHealth
-- 	if g_PlayersBurnTransfer[player1] and isPerkAllowedInMode(ID) and getElementHealth(car1) <= 245 and getElementHealth(car2) > 245 and not isVehicleBlown(car1) and not isVehicleBlown(car2) then  --isOnFire?
-- 		saveFireHealth = getElementHealth(car1)
-- 		fixVehicle(car1)
-- 		setElementHealth(car1, getElementHealth(car2))
-- 		setElementHealth(car2, saveFireHealth)    --transfer the fire !

-- 		outputChatBox('You have taken ' .. getPlayerName(player2).. '\'s health!', player1, 50, 202, 50)
-- 		exports.messages:outputGameMessage('You have taken ' .. getPlayerName(player2).. '\'s health!', player1, 2, 50, 202, 50, true)

-- 		outputChatBox(getPlayerName(player1).. ' has given you his vehicle fire! (fire transfer gc perk)', player2, 50, 202, 50)
-- 		exports.messages:outputGameMessage(getPlayerName(player1).. ' has given you his vehicle fire! ', player2,2, 50, 202, 50, true)

-- 	elseif g_PlayersBurnTransfer[player2] and isPerkAllowedInMode(ID) and getElementHealth(car2) <= 245 and getElementHealth(car1) > 245 and not isVehicleBlown(car1) and not isVehicleBlown(car2) then   --isOnFire
-- 		saveFireHealth = getElementHealth(car2)
-- 		--fixVehicle(car2)
-- 		--setElementHealth(car2, getElementHealth(car1))
-- 		setElementHealth(car1, saveFireHealth)	 --transfer the fire !

-- 		outputChatBox('You have taken ' .. getPlayerName(player1).. '\'s health!', player2, 50, 202, 50)
-- 		exports.messages:outputGameMessage('You have taken ' .. getPlayerName(player1).. '\'s health!', player2, 2, 50, 202, 50, true)

-- 		outputChatBox(getPlayerName(player2).. ' has given you his vehicle fire! ', player1, 50, 202, 50)
-- 		exports.messages:outputGameMessage(getPlayerName(player2).. ' has given you his vehicle fire! ', player1,2, 50, 202, 50, true)
-- 	end
-- end
function onPlayersVehicleCollide (player1, car1, player2, car2)
	local saveFireHealth
    if getResourceState(getResourceFromName("cw_script")) == "running" and exports.cw_script:areTeamsSet() then return end
	if g_PlayersBurnTransfer[player1] and isPerkAllowedInMode(ID) and getElementHealth(car1) <= 245 and getElementHealth(car2) > 245 and not isVehicleBlown(car1) and not isVehicleBlown(car2) then  --isOnFire?
		saveFireHealth = getElementHealth(car1)
		fixVehicle(car1)
		setElementHealth(car1, getElementHealth(car2))
		setElementHealth(car2, saveFireHealth)    --transfer the fire !

		outputChatBox('You have taken ' .. getPlayerName(player2).. '\'s health!', player1, 50, 202, 50)
		exports.messages:outputGameMessage('You have taken ' .. getPlayerName(player2).. '\'s health!', player1, 2, 50, 202, 50, true)

		outputChatBox(getPlayerName(player1).. ' has given you his vehicle fire! (fire transfer gc perk)', player2, 50, 202, 50)
		exports.messages:outputGameMessage(getPlayerName(player1).. ' has given you his vehicle fire! ', player2,2, 50, 202, 50, true)

	elseif g_PlayersBurnTransfer[player2] and isPerkAllowedInMode(ID) and getElementHealth(car2) <= 245 and getElementHealth(car1) > 245 and not isVehicleBlown(car1) and not isVehicleBlown(car2) then   --isOnFire
		saveFireHealth = getElementHealth(car2)
		fixVehicle(car2)
		setElementHealth(car2, getElementHealth(car1))
		setElementHealth(car1, saveFireHealth)	 --transfer the fire !

		outputChatBox('You have taken ' .. getPlayerName(player1).. '\'s health!', player2, 50, 202, 50)
		exports.messages:outputGameMessage('You have taken ' .. getPlayerName(player1).. '\'s health!', player2, 2, 50, 202, 50, true)

		outputChatBox(getPlayerName(player2).. ' has given you his vehicle fire! ', player1, 50, 202, 50)
		exports.messages:outputGameMessage(getPlayerName(player2).. ' has given you his vehicle fire! ', player1,2, 50, 202, 50, true)
	end
end
addEvent('onPlayersVehicleCollide', true)
addEventHandler('onPlayersVehicleCollide', root,onPlayersVehicleCollide)
