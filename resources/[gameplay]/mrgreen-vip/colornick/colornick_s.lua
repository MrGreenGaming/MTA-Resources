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
	if not hasObjectPermissionTo(source, "command.ban", false) then 
		respondToClient(source, false, "Admin only feature!")
		return 
	end
	
	local colorlessNick = string.gsub(nick, "#%x%x%x%x%x%x", "")
	local nickLength = string.len(colorlessNick)
	
	if nickLength > nickLimit then
		respondToClient(source, false, "Nick is too long")
		return
	elseif nickLength == 0 then
		respondToClient(source, false, "Nick can't be empty")
		return
	end
	
	for i, p in ipairs(getElementsByType("player")) do
		if p ~= source and string.lower(getPlayerName(p):gsub("#%x%x%x%x%x%x", "")) == string.lower(colorlessNick) then
			respondToClient(source, false, "Nick already in use!")
			return
		end
	end
	
	setPlayerName(source, string.gsub(nick, '#%x%x%x%x%x%x', ''))
	
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

addEventHandler('onPlayerChangeNick', root,
function()
	if getElementData(source, 'vip.colorNick') then
		setElementData(source, 'vip.colorNick', false)
	end
end)

function respondToClient(player, success, message)
	if success then
		outputChatBox(message, player, 0, 255, 100)
	else
		outputChatBox(message, player, 255, 50, 0)
	end
end

addCommandHandler('nickwindow', 
function(player)
	if not hasObjectPermissionTo(player, "command.ban", false) then return end
	triggerClientEvent(player, 'onPlayerRequestCustomNickWindow', player)
end)
