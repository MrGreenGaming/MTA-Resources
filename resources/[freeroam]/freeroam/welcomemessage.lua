function greetPlayer ( )
	local joinedPlayerName = getPlayerName ( source )
	local serverName = getServerName( )
	outputChatBox ("Welcome " .. joinedPlayerName .. " to ".. serverName .."!" , source, 13, 255, 215 )
end
addEventHandler ( "onPlayerJoin", getRootElement(), greetPlayer )