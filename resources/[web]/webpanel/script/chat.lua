addEvent "onWebChatMessage"

function getAll()
	return _messages
end

function getTime()
	local time = getRealTime()
	if time.hour < 10 then time.hour = "0"..time.hour end
	if time.minute < 10 then time.minute = "0"..time.minute end
	if time.second < 10 then time.second = "0"..time.second end
	
	return time.hour..":"..time.minute..":"..time.second
end

function addMessage(array)
	local trigger = triggerEvent("onWebChatMessage", g_root, array.player, array.msg, array.type)
	if trigger == false then return end
	
	local value = getPlayerFromName(array.player)
	local team_value = ""

	if isElement(value) then
		local team = getPlayerTeam(value)
		
		if isElement(team) then
			local r,g,b = getPlayerNametagColor(value)
			
			team_value = " <span style='color: rgb(".. r ..", ".. g ..", ".. b ..");'>"..getTeamName(team).."</span>"
		end
	end
	
	local output_string = "<tr><td>".. getTime() .."</td><td>".. array.player .."</td><td>".. team_value .."</td><td>".. array.type .."</td><td>".. array.msg .. "</td></tr>"
	
	if #_messages > max_chat then
		table.remove(_messages, 1)
		table.insert(_messages, output_string)
	else
		table.insert(_messages, output_string)
	end
end

function newMessage(gracz, tekst, typ)
	if(gracz and isElement(gracz) and getElementType(gracz) == 'player')and(tekst ~= nil)and(typ ~= nil)then
		local r, g, b = getPlayerNametagColor(gracz)
		addMessage({["player"]=getPlayerName(gracz),["msg"]=tekst,["type"]=typ})
		return true
	end
	return false
end

function sendMessageToAllPlayers(nick, message)
	local wiadomosc = "#FFFF00"..nick.." (web): #FFFFFF"..message
	outputServerLog("CHAT: "..nick.." (web): "..message)
	outputChatBox(wiadomosc, g_root, 255, 255, 255, true)
	addMessage({["player"]=nick.." (web)",["msg"]=message,["type"]="WEB"})
    return wiadomosc
end

function addChatMsg(player, msg, msgtype)
	if(player and msg and msgtype) then
		if type(player) == "userdata" then
			newMessage(player, msg, msgtype)
		else
			addMessage({["player"]=player,["msg"]=msg,["type"]=msgtype})
			return true
		end
	else
		return false
	end
end

function onPlayerChat(msg, msgtype)
	local styp = "" if msgtype == 1 then styp = "ME" elseif msgtype == 2 then styp ="TEAM" else styp = "CHAT" end
	newMessage(source, msg, styp)
end

function onPlayerJoin()
	newMessage(source, "Player ("..getPlayerName(source)..") join server.", "JOIN")
end

function onPlayerQuit(quitType, reason)
	local msg = ""
	if reason then
		msg = ", reason: " .. reason
	end
	newMessage(source, "Player ("..getPlayerName(source)..") quit server ("..quitType.. msg ..").", "QUIT")
end

function onPlayerWasted(ammo, killer, killerWeapon)
	if(killer)and(source)then
		if not (killer == source) and killerWeapon and type(getWeaponNameFromID(killerWeapon)) == "string" then
			newMessage(killer, "Player ("..tostring(getPlayerName(killer))..") kill player ("..tostring(getPlayerName(source))..") using weapon ("..tostring(getWeaponNameFromID(killerWeapon))..").", "KILL")
		end
	else
		newMessage(source, "Player ("..getPlayerName(source)..") die.", "KILL")
	end
end

function onPlayerChangeNick(oldNick, newNick)
	newMessage(source, "Player (".. oldNick ..") change nick. New (".. newNick ..").", "NICK")
end

addEventHandler("onPlayerChat", g_root, onPlayerChat)
addEventHandler("onPlayerJoin", g_root, onPlayerJoin)
addEventHandler("onPlayerQuit", g_root, onPlayerQuit)
addEventHandler("onPlayerWasted", g_root, onPlayerWasted)
addEventHandler("onPlayerChangeNick", g_root, onPlayerChangeNick) 