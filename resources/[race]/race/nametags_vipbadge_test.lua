function setPlayerVIP(psource,command,nickname)
	if ( hasObjectPermissionTo ( psource, "function.kickPlayer", false ) ) then
		local playerToSet = false
		if not nickname then
			playerToSet = psource
		elseif vip_getPlayerFromPartialName(nickname) then
			playerToSet = vip_getPlayerFromPartialName(nickname)
		end

		if isElement( playerToSet ) and getElementType( playerToSet ) == 'player' then
			if command == "setvipname" then
				setElementData( playerToSet, "gcshop.vip", "vip")
				outputChatBox( "You set VIP badge for: "..getPlayerName(playerToSet), psource )
			elseif command == "setvipplusname" then
				setElementData( playerToSet, "gcshop.vip", "vip+")
				outputChatBox( "You set VIP+ badge for: "..getPlayerName(playerToSet), psource )
			elseif command == "removevipname" then
				setElementData(playerToSet,"gcshop.vip",false)
				outputChatBox( "You removed VIP badge for: "..getPlayerName(playerToSet), psource )
			end
		end

	end
end
addCommandHandler( 'setvipname', setPlayerVIP,false,true )
addCommandHandler( 'setvipplusname', setPlayerVIP,false,true )
addCommandHandler( 'removevipname', setPlayerVIP,false,true )




function vip_getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

