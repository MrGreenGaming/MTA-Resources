----------------------------------------------
-- 				Receive.lua					--
-- Respond to requests from other servers	-- 
----------------------------------------------


-----------------
-- F2 redirect --
-----------------

local joiningSerials = {}
function playerRedirect ( serial, playtime, tick, hoursPlayed )
	joiningSerials[serial] = {tick=getTickCount(), playtime=playtime}
	triggerEvent('onPlayerReplaceTime', root, serial, tick, hoursPlayed)
	return {
		serial = serial
	}
end

function onPlayerConnect(nick, ip, username, serial)
	if joiningSerials[serial] then
		if getTickCount() - joiningSerials[serial].tick <= 10 * 1000 then
			local player = getPlayerFromName(nick)
			setElementData(player, 'redirectedFrom', other_server)
		else
			for s, t in pairs(joiningSerials) do
				if getTickCount() - t.tick >= 10 * 1000 then
					joiningSerials[s] = nil
				end
			end
		end
	end
end
addEventHandler('onPlayerConnect', root, onPlayerConnect)

function onPlayerJoin()
	local j = joiningSerials[getPlayerSerial(source)]
	if j then
		setElementData(source, 'playtime', j.playtime)
		joiningSerials[getPlayerSerial(source)] = nil
	end
end
addEventHandler('onPlayerJoin', root, onPlayerJoin)


-------------------------
-- Chat, use the + prefix
-------------------------

function playerChatBoxRemote ( name, message)
	local out = "[" .. other_server:upper() .. "] " .. tostring(name) .. "> " .. tostring(message) .. ""
	outputChatBox(out, root, 0xFF, 0xD7, 0x00)
	outputServerLog(out)
	exports.irc:outputIRC("08[" .. other_server:upper() .. "] " .. tostring(name) .. "> " .. tostring(message) .. "")
	triggerEvent('onInterchatMessage', resourceRoot, other_server:upper(), tostring(name), tostring(message))
	return {
		name = name,
		message = message
	}
end


-------------
-- Players --
-------------

function sendPlayerNames ( player )
	local players = getElementsByType('player')
	local names = {}
	if #players > 0 then
		for k,p in ipairs(players) do
			names[k] = removeColorCoding(getPlayerName(p))
		end
		return player, tostring(#players), tostring(getMaxPlayers()), table.concat(names, ", ")
	else
		return player, '0', ''
	end
end

function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end


------------
-- Admins --
------------

function sendAdminNames ( serial )
	local admins = {}
	local awayString = " (away)"
	for k, v in ipairs (getElementsByType("player")) do
		if hasObjectPermissionTo ( v, "general.adminpanel", false ) then
			local away = ""
        	if exports.anti:isPlayerAFK(v) then
        		away = awayString
        	end
			admins[#admins+1] = getPlayerName(v) : gsub ( '#%x%x%x%x%x%x', '' ) ..away
		end
	end

	local moderators = {}
	for k, v in ipairs (getElementsByType("player")) do
		if hasObjectPermissionTo ( v, "command.k", false ) and not hasObjectPermissionTo ( v, "general.adminpanel", false ) then
			local away = ""
        	if exports.anti:isPlayerAFK(v) then
        		away = awayString
        	end
			moderators[#moderators+1] = getPlayerName(v) : gsub ( '#%x%x%x%x%x%x', '' ) .. away
		end
	end


	return serial, table.concat ( admins, ', ' ), table.concat ( moderators, ', ' )
end


--------------
-- Map info --
--------------

function sendMapInfo ( name, author, gmname, outputMap, returnMapInfo )
	if outputMap then
		outputChatBox("[" .. other_server:upper() .. "] Map started: '" .. name .. "' / Gamemode: "..gmname, root, 0xFF, 0xD7, 0x00)
	end
	
	triggerClientEvent("updateF2GUI", resourceRoot, other_server.." Map", "Map: "..name.."\nAuthor: "..author)

	if returnMapInfo then
		outputDebugString("returnMapInfo", 3)
		if not mapInfo then
			local s = getElementData( getResourceRootElement( getResourceFromName("race") ) , "info")
			if s then
				mapInfo = s.mapInfo 
			else
				mapInfo = {}
			end
		end
		return mapInfo
	end	
end


---------------
-- GC logins --
---------------

function greencoinsLogin ( forumID )
	triggerEvent ( 'onOtherServerGCLogin', resourceRoot, forumID )
end
addEvent('onOtherServerGCLogin')


------------------
-- Mutes & bans --
------------------

function aAddSerialUnmuteTimer ( serial, length )
	exports.admin:aAddSerialUnmuteTimer(serial, tonumber(length))
	return 'ok'
end

function addSyncBan ( ip, serial, reason, seconds )
	addBan ( ip or nil, nil, serial or nil, root, tostring(reason or '') .. ' sync_banned', tonumber(seconds) and tonumber(seconds) > 0 and (tonumber(seconds) - getRealTime().timestamp) or 0)
end


----------------------
-- Unbans --
----------------------

function removeSyncBan ( admin, ip, serial )
	if ip then
		for _, ban in ipairs( getBans() ) do
			if getBanIP(ban) == ip then
				removeBan ( ban, admin )
			end
		end
	elseif serial then
		for _, ban in ipairs( getBans() ) do
			if getBanSerial(ban) == string.upper(serial) then
				removeBan ( ban, admin )
			end
		end
	end
end

-------------
-- Testing --
-------------

function testConnection()
	outputDebugString'Interchat: other server connecting'
	return 'connection ok'
end


-----------------------
-- Online players F2 --
-----------------------

function sendOnlinePlayers()
	local players = #getElementsByType('player')
	return {
		players = players,
		maxPlayers = getMaxPlayers()
	}
end