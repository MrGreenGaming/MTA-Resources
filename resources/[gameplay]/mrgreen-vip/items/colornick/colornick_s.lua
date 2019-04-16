-- Super Nicknames are saved in gc_nickcache.colorname

local acceptedChars = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
local nickLimit = 22
local originalName = {
	-- [player] = name
}

function setSuperNick(player,bool)
	-- originalName[source] = getPlayerName( source )
	local playerSuperNick = getVipSetting(player, 2, 'supernick')
	if bool == true and playerSuperNick and playerSuperNick ~= "" and isPlayerVIP(player) then
		local colorlessNick = string.gsub(playerSuperNick, "#%x%x%x%x%x%x", "")
		setElementData(player, "vip.colorNick", playerSuperNick)
		setPlayerName(player, colorlessNick)
		if getPlayerName( player ) ~= colorlessNick then
			-- If name change is not succes, try again
			setTimer( setPlayerName, 3000, 1, colorlessNick )
		end
		return true
	elseif bool == false and player and isElement(player) and getElementType(player) == "player" then
		removeElementData( player, "vip.colorNick" )
		if originalName[player] then
			setPlayerName(player, originalName[player])
		end
	end 
end


addEvent('onClientRequestNickSettings', true)
addEventHandler('onClientRequestNickSettings', root, 
function()
	triggerClientEvent(source, 'sendNickSettings', source, acceptedChars, nickLimit)
end)

addEvent('onClientChangeCustomNickname', true)
addEventHandler('onClientChangeCustomNickname', root,
function(nick)
	if not isPlayerVIP(source) or not vipPlayers[source] then return end
	
	local colorlessNick = string.gsub(nick, "#%x%x%x%x%x%x", "")
	local nickLength = string.len(colorlessNick)
	
	if nickLength > nickLimit then
		vip_outputChatBox("Nick is too long", source, 255, 50, 0)
		return
	elseif nickLength == 0 then
		vip_outputChatBox("Nick can't be empty", source, 255, 50, 0)
		return
	end
	
	for i, p in ipairs(getElementsByType("player")) do
		if p ~= source and string.lower(getPlayerName(p):gsub("#%x%x%x%x%x%x", "")) == string.lower(colorlessNick) then
			vip_outputChatBox("Nick already in use", source, 255, 50, 0)
			return
		end
	end
	
	saveVipSetting(source,2,"supernick",nick)
	setSuperNick(source)
	
	vip_outputChatBox("Super Nick Successfully set!", source, 0, 255, 100)
end)

addEvent('onClientResetCustomNickname', true)
addEventHandler('onClientResetCustomNickname', root,
function()
	if not isPlayerVIP(source) or not vipPlayers[source] then return end
	
	local forumid = exports.gc:getPlayerForumID(source)

	-- success = success and dbExec(handlerConnect, "UPDATE gc_nickcache SET colorname=null WHERE forumid=?", forumid)
	local success = saveVipSetting(source,2,"supernick",false)
	if success then

		removeElementData( source, 'vip.colorNick' )
		if originalName[source] then
			setPlayerName( source, originalName[source])
			originalName[source] = nil
		end
		vip_outputChatBox("Your super nick was succesfully cleared!",source,0,255,100)
	else
		vip_outputChatBox("There was an error while clearing your name!",source,255,0,0)
	end
end)

addEventHandler('onPlayerChangeNick', root,
function(old,new,byPlayer)
	if getElementData(source, "vip.colorNick" ) and isPlayerVIP(source) and vipPlayers[source] and byPlayer then
		-- removeElementData( source, 'vip.colorNick' )
		vip_outputChatBox("Please remove VIP SuperNick before changing your name!",source,255,0,0)
		cancelEvent( true, "Please remove VIP SuperNick first!" )
	end
end)





addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
			if loggedIn then
				
				local playerSuperNick = vipPlayers[player].options[2].supernick
				if playerSuperNick and playerSuperNick ~= "" then
					originalName[player] = getPlayerName(player)
					setSuperNick(player,true)
					-- vip_outputChatBox("Your nickname has been set to your VIP nickname.", player, 0, 255, 100)
				end
			else
				-- Handle logout
				setSuperNick(source,false)
			end
		end
	end
)

addEventHandler('onResourceStop', resourceRoot,
function()
	for i, p in ipairs(getElementsByType('player')) do
		if originalName[p] then
			setPlayerName( p, originalName[p] )
		end
		removeElementData( p, 'vip.colorNick' )
	end
end)