function isPlayerVIP(player) --placeholder
	if not exports.gc:isPlayerLoggedInGC(player) then return false end
	
	local rootNode = xmlLoadFile('vip.xml')
	if not rootNode then return false end
	
	local forumid = exports.gc:getPlayerForumID(player)
	
	local vipNodes = xmlNodeGetChildren(rootNode)
	for i,n in ipairs(vipNodes) do
		if xmlNodeGetValue(n) and tostring(xmlNodeGetValue(n)) == tostring(forumid) then return true end
	end
	
	return false
end

function addVIP(player, cmd, target)
	if not hasObjectPermissionTo(player, 'command.addGC') then return end
	
	local targetPlayer = getPlayerFromName(target)
	
	if not targetPlayer then outputChatBox("Player not found!", player, 255, 0, 0) return end
		
	if not exports.gc:isPlayerLoggedInGC(targetPlayer) then outputChatBox("Player is not logged in!", player, 255, 0, 0) return end
	
	local forumid = exports.gc:getPlayerForumID(targetPlayer)
	
	local rootNode = xmlLoadFile('vip.xml')
	if not rootNode then
		rootNode = xmlCreateFile('vip.xml', 'vips')
	end
	
	local child = xmlCreateChild(rootNode, 'vip')
	
	xmlNodeSetValue(child, tostring(forumid))
	
	xmlSaveFile(rootNode)

	outputChatBox('Success!', player, 100, 255, 100)
end
addCommandHandler('addvip', addVIP)

function removeVIP(player, cmd, forumid)
	if not hasObjectPermissionTo(player, 'command.addGC') then return end
	
	local rootNode = xmlLoadFile('vip.xml')
	if not rootNode then outputChatBox('No VIP file found!', player, 255, 0, 0) return end
	
	local vipNodes = xmlNodeGetChildren(rootNode)
	for i,n in ipairs(vipNodes) do
		if xmlNodeGetValue(n) and tostring(xmlNodeGetValue(n)) == forumid then
			xmlDestroyNode(n)
			xmlSaveFile(rootNode)
			outputChatBox("Success!", player, 100, 255, 100)
			return
		end
	end
	
	outputChatBox('Given forumid is not VIP!', player, 255, 0, 0)
end
addCommandHandler('removevip', removeVIP)

function vipList(player, cmd)
	if not hasObjectPermissionTo(player, 'command.addGC') then return end
	
	local rootNode = xmlLoadFile('vip.xml')
	if not rootNode then outputChatBox('No VIP file found!', player, 255, 0, 0) return end
	
	local outputString = ''
	local vipNodes = xmlNodeGetChildren(rootNode)
	for i,n in ipairs(vipNodes) do
		outputString = outputString .. xmlNodeGetValue(n) .. ', '
	end
	
	outputString = string.sub(outputString, 0, string.len(outputString) - 2)
	
	outputChatBox('Current VIP players: '..outputString, player, 100, 255, 100)
end
addCommandHandler('viplist', vipList)

function toggleGUI(player)
	if not isPlayerVIP(player) then return end
	triggerClientEvent(player, 'vip-toggleGUI', player)
end

addEventHandler('onResourceStart', resourceRoot, function()
	for i,p in ipairs(getElementsByType('player')) do
		bindKey(p, 'F7', 'down', toggleGUI)
	end
end)

addEventHandler('onPlayerJoin', root, function()
	bindKey(source, 'F7', 'down', toggleGUI)
end)

--Lights blinking
local mainTimer = false
local blinkTable = {}

addEvent('vip-startBlinking', true)
addEventHandler('vip-startBlinking', root,
function(pattern, speed)
	if not isPlayerVIP(source) then outputChatBox("You are not allowed to use this function. Only VIP members are allowed to use this function!", source, 255, 0, 0) return end
	if pattern == 0 or speed == 0 then 
		if blinkTable[source] then blinkTable[source] = nil end
		local veh = getPedOccupiedVehicle(source)
		if veh then
			setVehicleOverrideLights(veh, 0)
			setVehicleLightState(veh, 0, 0)
			setVehicleLightState(veh, 1, 0)
			setVehicleLightState(veh, 2, 0)
			setVehicleLightState(veh, 3, 0)
		end
		outputChatBox('Light blinking is disabled!', source, 100, 255, 100)
		return
	end
	
	local playerObject = {}
	
	playerObject.pattern = pattern
	playerObject.speed = speed
	playerObject.cyclesLeft = speed
	playerObject.stage = 1
	
	blinkTable[source] = playerObject
	
	if not mainTimer or not isTimer(mainTimer) then mainTimer = setTimer(doBlinking, 250, 0) end
	
	outputChatBox('Light blinking is enabled!', source, 100, 255, 100)
end)

function doBlinking()
	local count = 0
	for k,v in pairs(blinkTable) do
		count = count + 1
		local veh = getPedOccupiedVehicle(k)
		if veh then
			setVehicleOverrideLights(veh, 2)
			
			v.cyclesLeft = v.cyclesLeft - 1
			
			if v.cyclesLeft == 0 then
				v.cyclesLeft = v.speed
				if v.pattern == 1 then
					if v.stage == 1 then
						setVehicleLightState(veh, 0, 0)
						setVehicleLightState(veh, 3, 0)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 1)
						v.stage = v.stage + 1
					elseif v.stage == 2 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 3, 1)
						setVehicleLightState(veh, 1, 0)
						setVehicleLightState(veh, 2, 0)
						v.stage = 1
					end
				elseif v.pattern == 2 then
					if v.stage == 1 then
						setVehicleLightState(veh, 0, 0)
						setVehicleLightState(veh, 3, 1)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 0)
						v.stage = v.stage + 1
					elseif v.stage == 2 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 3, 0)
						setVehicleLightState(veh, 1, 0)
						setVehicleLightState(veh, 2, 1)
						v.stage = 1
					end
				elseif v.pattern == 3 then
					if v.stage == 1 then
						setVehicleLightState(veh, 0, 0)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 1)
						setVehicleLightState(veh, 3, 1)
						v.stage = v.stage + 1
					elseif v.stage == 2 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 1, 0)
						setVehicleLightState(veh, 2, 1)
						setVehicleLightState(veh, 3, 1)
						v.stage = v.stage + 1
					elseif v.stage == 3 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 0)
						setVehicleLightState(veh, 3, 1)
						v.stage = v.stage + 1
					elseif v.stage == 4 then
						setVehicleLightState(veh, 0, 1)
						setVehicleLightState(veh, 1, 1)
						setVehicleLightState(veh, 2, 1)
						setVehicleLightState(veh, 3, 0)
						v.stage = 1
					end
				end
			end
		end
	end
	if count == 0 then killTimer(mainTimer) mainTimer = false end
end

addEventHandler('onPlayerQuit', root, 
function()
	if blinkTable[source] then blinkTable[source] = nil end
end)

addEventHandler('onResourceStop', resourceRoot,
function()
	for i, p in ipairs(getElementsByType('player')) do
		if blinkTable[p] then
			blinkTable[p] = nil
			local veh = getPedOccupiedVehicle(p)
			if veh then
				setVehicleOverrideLights(veh, 0)				
				setVehicleLightState(veh, 0, 0)
				setVehicleLightState(veh, 3, 0)
				setVehicleLightState(veh, 1, 0)
				setVehicleLightState(veh, 2, 0)
			end
		end
	end
end)

