local acceptedChars = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
local nickLimit = 22

addEvent('onClientRequestNickSettings', true)
addEventHandler('onClientRequestNickSettings', root, 
function()
	triggerClientEvent(source, 'sendNickSettings', source, acceptedChars, nickLimit)
end)

addEvent('onClientChangeCustomNickname', true)
addEventHandler('onClientChangeCustomNickname', root,
function(nick)
	local colorlessNick = string.gsub(nick, "#%x%x%x%x%x%x", "")
	local nickLength = string.len(colorlessNick)
	
	if nickLength > nickLimit then
		respondToClient(source, false, "Nick is too long")
		return
	elseif nickLength == 0 then
		respondToClient(source, false, "Nick can't be empty")
		return
	end
	
	setElementData(source, "vip.colorNick", nick)
	respondToClient(source, true, "Nick successfully set!")
end)

addEvent('onClientResetCustomNickname', true)
addEventHandler('onClientResetCustomNickname', root,
function()
	local success = setElementData(source, 'vip.colorNick', false)
	if success then
		respondToClient(source, success, "Your name was successfully reset!")
	else
		respondToClient(source, success, "There was an error while resetting your name!")
	end
end)

function respondToClient(player, success, message)
	--triggerClientEvent(player, 'onServerChangeCustomNicknameResponse', player, success, message)
	if success then
		outputChatBox(message, player, 0, 255, 100)
	else
		outputChatBox(message, player, 255, 100, 0)
	end
end
