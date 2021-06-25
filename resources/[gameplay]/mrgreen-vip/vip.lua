currentRaceState = false
vipPlayers = {
	-- [player] = {
	-- 	timestamp: expireTimestamp, 
	-- 	options: {
	-- 		[1] = {options},
	-- 		[2] = (options)
	-- 	}
	-- }
}

vipItems = {
	[1] = { ID = 1, description = 'VIP Badge'},
	[2] = { ID = 2, description = 'Super Nickname'},
	[3] = { ID = 3, description = 'Rainbow Colors'},
	[4] = { ID = 4, description = 'Light Blink'},
	[5] = { ID = 5, description = 'VIP Character Skins'},
	[6] = { ID = 6, description = 'Police Sirens'},
	[7] = { ID = 7, description = 'Dynamic Vehicle Overlay'},
	[8] = { ID = 8, description = 'VIP Join Message'},
	[9] = { ID = 9, description = 'Personal Horn'},
	[10] = { ID = 10, description = 'Free VIP Map'},
	[11] = { ID = 11, description = 'Wheel change'},
}

-- Standard options
vipStandardOptions = {
	[1] = {enabled = false},
	[2] = {supernick = false},
	[3] = {lights = false, paintjob = false, wheels = false},
	[4] = {pattern = 1, speed = 4, enabled = false},
	[5] = {skin = 1},
	[6] = {enabled = false},
	[7] = {style = false, color = "FFFFFF", intensity = 0.5, opacity = 3, speed = 3},
	[8] = {message = ""},
	[9] = {key = "J"},
	[10] = {used = false},
	[11] = {enabled = false}
}

-- Resource init
function initVip()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))

	if not handlerConnect then
		outputDebugString('VIP Database error: could not connect to the mysql db')
		return
	end
end
addEventHandler( 'onResourceStart', resourceRoot, initVip)

-- VIP setter
function setPlayerVIP(player,bool)
	if bool and isElement(player) and getElementType(player) == "player" and not vipPlayers[player] then

		-- setElementData(player, 'gcshop.vipbadge', 'vip')
		
		-- Get options
		local playerOptions = loadVipSettings(player)
		-- Get timestamp
		local playerStamp = exports.gc:getPlayerVip(player)

		if not playerOptions or not playerStamp then return end

		-- Set vip player in table
		vipPlayers[player] = {timestamp = playerStamp, options = playerOptions}
		

		
		-- vip Items should listen to this event
		triggerEvent( 'onPlayerVip', resourceRoot,player, true)
		triggerClientEvent( player, 'onServerSendVip', resourceRoot, vipPlayers[player])

		if vipPlayers[player] then
			local timeLeft = secondsToTimeDesc(playerStamp - getRealTime().timestamp)
			-- vip_outputChatBox("You are set as a VIP.",player)
			vip_outputChatBox("You have "..timeLeft.." of VIP left",player)

		end
	elseif isElement(player) and getElementType(player) == "player" and bool == false then
		vipPlayers[player] = nil
		triggerClientEvent( player, 'onServerRemovedVip', resourceRoot )

		-- vip Items should listen to this event
		triggerEvent( 'onPlayerVip', resourceRoot, player, false)

		

	end
end
addEvent( 'onPlayerVip')
-- addEventHandler( 'onPlayerVip', resourceRoot, function (player, loggedIn)  end )


addEvent( 'onClientRequestsVip' , true )
addEventHandler('onClientRequestsVip',resourceRoot,
	function()
		if isPlayerVIP(client) then
			setPlayerVIP(client,true)
		end
	end
)

-- Settings
function loadVipSettings(player)
	local theID = exports.gc:getPlayerForumID(player)
	if not theID then return false end

	local query = dbQuery(handlerConnect, "SELECT * FROM vip_items WHERE forumid=?", theID)
	local result = dbPoll(query,-1)
	-- local options = fromJSON(result[1].options)
	
	-- Options handling
	local newOptions = table.deepCopy(vipStandardOptions)

	for i, row in ipairs(result) do
		if newOptions[row.item] and row.options then
			local fetchedOptions = fromJSON(row.options)
			for optionName, optionValue in pairs(fetchedOptions) do
				if tostring(newOptions[row.item][optionName]) ~= "nil" then
					newOptions[row.item][optionName] = optionValue
				end
			end
		end
	end

	return newOptions
end

function saveVipSetting(player, itemId, key, value)
	-- ItemId and key must exist

	if not player or getElementType(player) ~= 'player' or not itemId or not key or value == nil then return false end
	local forumId = exports.gc:getPlayerForumID(player)
	if not forumId then return false end
	if not vipPlayers[player] or not vipPlayers[player]['options'][itemId] or vipPlayers[player]['options'][itemId][key] == nil then return false end

	vipPlayers[player]['options'][itemId][key] = value
	local jsonOptions = toJSON( vipPlayers[player]['options'][itemId] )

	outputDebugString(jsonOptions)

	-- Save to db
	local saved = dbExec(handlerConnect, "INSERT INTO vip_items (forumid, item, options) VALUES (?,?,?) ON DUPLICATE KEY UPDATE options=?",forumId,itemId,jsonOptions,jsonOptions)
	
	triggerClientEvent( player, 'onServerChangedPlayerVipOptions', resourceRoot,  vipPlayers[player])

	return true
end

function getVipSetting(player, itemId, key)
	if not player or getElementType(player) ~= 'player' or not vipPlayers[player] or vipPlayers[player]['options'][itemId] == nil or not itemId or key == nil then return nil end
	return vipPlayers[player]['options'][itemId][key]

end
-- VIP Checker
function isVipExpired(timestamp) 
	timestamp = timestamp or 0
	return getRealTime().timestamp > timestamp
end


function checkAllVipExpired()
	for player, val in pairs(vipPlayers) do
		if not player or isVipExpired(val.timestamp) then
			-- player is expired
			setPlayerVIP(player,false)
		end
	end
end
local vipCheckMinutes = 5
setTimer( checkAllVipExpired, vipCheckMinutes * 60000, 0 )


function isPlayerVIP(player)
	if not exports.gc:isPlayerLoggedInGC(player) then return false end	
	local timestamp = exports.gc:getPlayerVip(player)
	if not timestamp or isVipExpired(timestamp) then return false end
	
	return true
end

-- Event listeners
addEvent( 'onGCLogin', true )
addEventHandler('onGCLogin', root, function()
	if isElement(source) and getElementType(source) == "player" and not vipPlayers[source] and isPlayerVIP(source) then
		setPlayerVIP(source,true, "from onGCLogin")
	end

	if isElement(source) and getElementType(source) == "player" and not isPlayerVip(source) then
		-- VIP Has expired. Should clear supernick from database to reset toptimes to default nickname
		local forumId = exports.gc:getPlayerForumID(player)
		if not forumId then return false end

		local jsonOptions = toJSON()
	end
end)
addEvent( 'onGCLogout', true )
addEventHandler('onGCLogout', root, function()
	if isElement(source) and getElementType(source) == "player" and not exports.gc:isPlayerLoggedInGC(source) then
		setPlayerVIP(source,false)
	end
	
end)


function onRaceStateChanging( newStateName, oldStateName)
	currentRaceState = newStateName
	setElementData(resourceRoot, 'racestate', newStateName)
end
addEvent('onRaceStateChanging')
addEventHandler('onRaceStateChanging', root, onRaceStateChanging)

-- function addVIP(player, cmd, target)
-- 	if not hasObjectPermissionTo(player, 'command.addGC') then return end
	
-- 	local targetPlayer = getPlayerFromName(target)
	
-- 	if not targetPlayer then outputChatBox("Player not found!", player, 255, 0, 0) return end
		
-- 	if not exports.gc:isPlayerLoggedInGC(targetPlayer) then outputChatBox("Player is not logged in!", player, 255, 0, 0) return end
	
-- 	local forumid = exports.gc:getPlayerForumID(targetPlayer)
	
-- 	local rootNode = xmlLoadFile('vip.xml')
-- 	if not rootNode then
-- 		rootNode = xmlCreateFile('vip.xml', 'vips')
-- 	end
	
-- 	local child = xmlCreateChild(rootNode, 'vip')
	
-- 	xmlNodeSetValue(child, tostring(forumid))
	
-- 	xmlSaveFile(rootNode)

-- 	setElementData(targetPlayer, 'gcshop.vipbadge', 'vip')
	
-- 	outputChatBox('Success!', player, 100, 255, 100)
-- end
-- addCommandHandler('addvip', addVIP)

-- function removeVIP(player, cmd, forumid)
-- 	if not hasObjectPermissionTo(player, 'command.addGC') then return end
	
-- 	local rootNode = xmlLoadFile('vip.xml')
-- 	if not rootNode then outputChatBox('No VIP file found!', player, 255, 0, 0) return end
	
-- 	local vipNodes = xmlNodeGetChildren(rootNode)
-- 	for i,n in ipairs(vipNodes) do
-- 		if xmlNodeGetValue(n) and tostring(xmlNodeGetValue(n)) == forumid then
-- 			xmlDestroyNode(n)
-- 			xmlSaveFile(rootNode)
			
-- 			for i,p in ipairs(getElementsByType('player')) do
-- 				if exports.gc:isPlayerLoggedInGC(p) and tostring(exports.gc:getPlayerForumID(p)) == forumid then
-- 					setElementData(p, 'gcshop.vipbadge', false)
-- 				end
-- 			end
			
-- 			outputChatBox("Success!", player, 100, 255, 100)
-- 			return
-- 		end
-- 	end
	
-- 	outputChatBox('Given forumid is not VIP!', player, 255, 0, 0)
-- end
-- addCommandHandler('removevip', removeVIP)

-- function vipList(player, cmd)
-- 	if not hasObjectPermissionTo(player, 'command.addGC') then return end
	
-- 	local rootNode = xmlLoadFile('vip.xml')
-- 	if not rootNode then outputChatBox('No VIP file found!', player, 255, 0, 0) return end
	
-- 	local outputString = ''
-- 	local vipNodes = xmlNodeGetChildren(rootNode)
-- 	for i,n in ipairs(vipNodes) do
-- 		outputString = outputString .. xmlNodeGetValue(n) .. ', '
-- 	end
	
-- 	outputString = string.sub(outputString, 0, string.len(outputString) - 2)
	
-- 	outputChatBox('Current VIP players: '..outputString, player, 100, 255, 100)
-- end
-- addCommandHandler('viplist', vipList)

function toggleGUI(player)
	if not isPlayerVIP(player) then return end
	triggerClientEvent(player, 'vip-toggleGUI', player)
end

-- addEventHandler('onResourceStart', resourceRoot, function()
-- 	for i,p in ipairs(getElementsByType('player')) do
-- 		if getResourceState(getResourceFromName('gc')) == "running" then

-- 		end
-- 		bindKey(p, 'F7', 'down', toggleGUI)
-- 	end
-- end)

-- addEventHandler('onPlayerJoin', root, function()
-- 	bindKey(source, 'F7', 'down', toggleGUI)
-- end)

-- addEventHandler('onGCLogin', root, function()
-- 	if isPlayerVIP(source) then
-- 		setElementData(source, 'gcshop.vipbadge', 'vip')
-- 	end
-- end)

-- addEvent('vip-showNametag', true)
-- addEventHandler('vip-showNametag', root, function(enable)
-- 	if enable then
-- 		setElementData(source, 'gcshop.vipbadge', 'vip')
-- 	else 
-- 		setElementData(source, 'gcshop.vipbadge', false)
-- 	end
-- end)

