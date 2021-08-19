local wheelsTable = {1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 1096, 1097, 1098}
local stateTable = {}
local mainTimer = false

function toggleChange(state)

	local player = source
	
	if not isPlayerVIP(player) then outputChatBox('You must be VIP to use this function!', player, 255, 0, 0) return false end
	
	if state then
		stateTable[player] = 1
		local saved = saveVipSetting(source, 11, "enabled", state)
		if saved then
			outputChatBox('Wheel changing enabled', player, 0, 255, 0)
		else
			outputChatBox('Wheel changing enabled with a DB error!', player, 255, 119, 0)
		end
	else
		stateTable[player] = false
		
		local vehicle = getPedOccupiedVehicle(player)
		
		if vehicle then
			local wheels = exports.gcshop:getPlayerSavedWheelsForVehicle(player, getElementModel(vehicle))
			
			if wheels then
				addVehicleUpgrade(vehicle, wheels)
			else 
				local upg = getVehicleUpgradeOnSlot(vehicle, 12)
				removeVehicleUpgrade(vehicle, upg)
			end
		end
		
		local saved = saveVipSetting(source, 11, "enabled", state)
		
		if saved then
			outputChatBox('Wheel changing disabled', player, 255, 0, 0)
		else
			outputChatBox('Wheel changing disabled with a DB error!', player, 255, 119, 0)
		end
	end
end
addCommandHandler('wheelchange', toggleChange)
addEvent('onClientToggleWheelChange', true)
addEventHandler('onClientToggleWheelChange', root, toggleChange)

function timer()
	local vehicle = false
	for i,p in ipairs(getElementsByType('player')) do
		if stateTable[p] and not stateTable[p] == false then
		
			vehicle = getPedOccupiedVehicle(p)
			
			if vehicle then
				stateTable[p] = stateTable[p] + 1
				if stateTable[p] > #wheelsTable then stateTable[p] = 1 end
				addVehicleUpgrade(vehicle, wheelsTable[stateTable[p]])
			end
		end
	end
end

addEventHandler('onResourceStart', resourceRoot,
function ()
	mainTimer = setTimer(timer, 1000, 0)
end)

addEventHandler('onResourceStop', resourceRoot,
function ()
	killTimer(mainTimer)
end)

addEventHandler('onPlayerQuit', root,
function ()
	if stateTable[source] then
		stateTable[source] = false
	end
end)

addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
			if loggedIn and getVipSetting(player,11,'enabled') then
				stateTable[player] = 1			
			end
		end
	end
)

