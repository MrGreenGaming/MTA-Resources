--------------------------------------------------------
---   Used to keep the different nicknames acceptable
--------------------------------------------------------


function joinPlayer ( )
	local joinedPlayerName = getPlayerName ( source )
	local noColorName = removeColorCoding( getPlayerName ( source ) )
	if (joinedPlayerName == 'Player') or (noColorName:len() == 0) or isNameInUse(joinedPlayerName) or noColorName:gsub ( '#%x%x%x%x%x%x', '' ) ~= noColorName then
		if (joinedPlayerName == 'Player') then
			setTimer(outputChatBox, 3000, 1, _.For(source, 'Please use an other nickname then "Player"'), source, 0xFF, 0x00, 0x00 )
		elseif isNameInUse(joinedPlayerName) then
			setTimer(outputChatBox, 3000, 1, _.For(source, 'Your nickname was already in use, changed to random one'), source, 0xFF, 0x00, 0x00 )
		elseif noColorName:gsub ( '#%x%x%x%x%x%x', '' ) ~= noColorName then
			setTimer(outputChatBox, 3000, 1, _.For(source, 'Your nickname is using multiple colour codes, which causes bugs. Please change'), source, 0xFF, 0x00, 0x00 )
		else
			setTimer(outputChatBox, 3000, 1, _.For(source, 'Please use a nickname longer then 2 characters'), source, 0xFF, 0x00, 0x00 )
		end
		setPlayerName ( source , 'Green' .. tostring(math.random(100,999)))
	elseif not (noColorName:len() > 2) then
		setPlayerName ( source , joinedPlayerName:rep(1) .. tostring(math.random(100,999)))
		setTimer(outputChatBox, 3000, 1, _.For(source, 'Please use a nickname longer then 2 characters'), source, 0xFF, 0x00, 0x00 )
	end
end
addEventHandler ( "onPlayerJoin", getRootElement(), joinPlayer, true, "low")


function nickChangeHandler(oldNick, newNick)
	local noColorName = removeColorCoding( newNick )
	if (newNick == 'Player') or (noColorName:len() < 3) or (isNameInUse(newNick) and isNameInUse(newNick) ~= source) or isPlayerMuted(source) or chat_is_disabled or noColorName:gsub ( '#%x%x%x%x%x%x', '' ) ~= noColorName then
		if (newNick == 'Player') then
			outputChatBox(_.For(source, 'Please use an other nickname then "Player"'), source, 0xFF, 0x00, 0x00 )
		elseif isNameInUse(newNick) and isNameInUse(newNick) ~= source then
			outputChatBox(_.For(source, 'This nickname is already in use'), source, 0xFF, 0x00, 0x00 )
		elseif isPlayerMuted(source) or chat_is_disabled then
			outputChatBox(_.For(source, "You can't change your nick while you are muted"), source, 0xFF, 0x00, 0x00 )
		elseif noColorName:gsub ( '#%x%x%x%x%x%x', '' ) ~= noColorName then
			outputChatBox(_.For(source, "Your nickname is using multiple colour codes, which causes bugs. Please change"), source, 0xFF, 0x00, 0x00 )
		else
			outputChatBox(_.For(source, 'Please use a nickname longer then 2 characters'), source, 0xFF, 0x00, 0x00 )
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
