--------------------------------------------------------
---   Used to keep the different nicknames acceptable
--------------------------------------------------------

illegalNames = {
	"discord."
}

function onPlayerConnect(nick)
	-- if name contains illegal name, refuse connection
	for _, illegalName in ipairs(illegalNames) do
		if string.find(string.lower(nick), illegalName) then
			outputDebugString("VulpyScript: Player tried to connect with illegal nickname: " .. nick, 1)
			if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
				exports.discord:send("admin.log",
				{ log = "Connection refused for player : " .. nick .. " (illegal nickname)"})
			end

			-- refuse connection
			cancelEvent(true, "VulpyScript: Your nickname is invalid. Reconnect with a different nickname")
			return
		end
	end
end
addEventHandler("onPlayerConnect", root, onPlayerConnect, true, "high+4")

function onPlayerChangeNick(oldNick, newNick)
	for _, illegalName in ipairs(illegalNames) do
		if string.find(string.lower(newNick), illegalName) then
			outputDebugString("VulpyScript: Player tried to change nickname to illegal nickname: " .. newNick, 1)
			if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
				exports.discord:send("admin.log",
				{ log = "Nickname change refused for player : " .. oldNick .. " (illegal nickname: " .. newNick .. ")"})
			end

			cancelEvent()
			outputChatBox("VulpyScript: Your new nickname is invalid. Name has not been changed.", source, 255, 0, 0)
			return
		end
	end
end
addEventHandler("onPlayerChangeNick", root, nickChangeHandler, true, "high+4")

function joinPlayer ( )
	local joinedPlayerName = getPlayerName ( source )
	local noColorName = removeColorCoding( getPlayerName ( source ) )
	if (joinedPlayerName == 'Player') or (noColorName:len() == 0) or isNameInUse(joinedPlayerName) or noColorName:gsub ( '#%x%x%x%x%x%x', '' ) ~= noColorName then
		if (joinedPlayerName == 'Player') then
			setTimer(outputChatBox, 3000, 1, 'Please use an other nickname then "Player"', source, 0xFF, 0x00, 0x00 )
		elseif isNameInUse(joinedPlayerName) then
			setTimer(outputChatBox, 3000, 1, 'Your nickname was already in use, changed to random one', source, 0xFF, 0x00, 0x00 )
		elseif noColorName:gsub ( '#%x%x%x%x%x%x', '' ) ~= noColorName then
			setTimer(outputChatBox, 3000, 1, 'Your nickname is using multiple colour codes, which causes bugs. Please change', source, 0xFF, 0x00, 0x00 )
		else
			setTimer(outputChatBox, 3000, 1, 'Please use a nickname longer then 2 characters', source, 0xFF, 0x00, 0x00 )
		end
		setPlayerName ( source , 'Green' .. tostring(math.random(100,999)))
	elseif not (noColorName:len() > 2) then
		setPlayerName ( source , joinedPlayerName:rep(1) .. tostring(math.random(100,999)))
		setTimer(outputChatBox, 3000, 1, 'Please use a nickname longer then 2 characters', source, 0xFF, 0x00, 0x00 )
	end
end
addEventHandler ( "onPlayerJoin", getRootElement(), joinPlayer, true, "low")


function nickChangeHandler(oldNick, newNick)
	local noColorName = removeColorCoding( newNick )
	if (newNick == 'Player') or (noColorName:len() < 3) or (isNameInUse(newNick) and isNameInUse(newNick) ~= source) or isPlayerMuted(source) or chat_is_disabled or noColorName:gsub ( '#%x%x%x%x%x%x', '' ) ~= noColorName then
		if (newNick == 'Player') then
			outputChatBox('Please use an other nickname then "Player"', source, 0xFF, 0x00, 0x00 )
		elseif isNameInUse(newNick) and isNameInUse(newNick) ~= source then
			outputChatBox('This nickname is already in use', source, 0xFF, 0x00, 0x00 )
		elseif isPlayerMuted(source) or chat_is_disabled then
			outputChatBox('You can\'t change your nick while you are muted', source, 0xFF, 0x00, 0x00 )
		elseif noColorName:gsub ( '#%x%x%x%x%x%x', '' ) ~= noColorName then
			outputChatBox('Your nickname is using multiple colour codes, which causes bugs. Please change', source, 0xFF, 0x00, 0x00 )
		else
			outputChatBox('Please use a nickname longer then 2 characters', source, 0xFF, 0x00, 0x00 )
		end
		cancelEvent()
	end
end
addEventHandler("onPlayerChangeNick", getRootElement(), nickChangeHandler)

function isNameInUse ( name )
	players = getElementsByType('player')
	for k,v in ipairs(players) do
		local nick = getPlayerName(v)
		if string.lower(removeColorCoding ( name )) == string.lower(removeColorCoding ( nick )) and name ~= nick then
			return v
		end
	end
	return false
end

function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end
