local sendJoinMessages = {
	-- [id] = stamp
}
local joinMessageTimeBetween = 30 -- in seconds

addEvent('onClientChangeCustomJoinMessage', true)
addEventHandler('onClientChangeCustomJoinMessage', root,
function(message)
	if not isPlayerVIP(client) or not vipPlayers[client] then return end
	if string.len(message) > 150 then
		-- Save message to false when it's an empty string
		if message == "" then message = false end
		vip_outputChatBox("Join message too long!", client, 255, 50, 0)
		return
	end

	local saved = saveVipSetting(client,8,"message",message)
	if saved then
		vip_outputChatBox("Join message successfully set!", client, 0, 255, 100)
	else
		vip_outputChatBox("Could not save join message.", client, 255, 50, 0)
	end
end)


-- Handle vip join
addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
				outputVipJoinMessage(player)
		end
	end
)

function outputVipJoinMessage(player)
	if not player or not vipPlayers[player] then return end
	local theId = exports.gc:getPlayerForumID(player)
	local theMessage = vipPlayers[player].options[8].message
	local playerName = getPlayerName( player )
	if not theId or not theMessage or not playerName then return end

	-- Check if player just joined (30 seconds from join)
	if getElementData(player, 'jointick') < (getRealTime().timestamp - 30) then return end
	-- Check time between
	if sendJoinMessages[theId] and sendJoinMessages[theId] > (getRealTime().timestamp - joinMessageTimeBetween) then return end

	sendJoinMessages[theId] = getRealTime().timestamp
	outputChatBox("[VIP Joined] "..playerName..": #FFFFFF"..theMessage,getRootElement(),255,255,0,true)
end