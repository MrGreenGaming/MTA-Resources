local gPlayerTickCount = { }
local gPlayerSpams = { }
local gPlayerMessage = { }
local gPlayerMsgNum = { }
local gPlayerMutedTimers = { }
local gSettings = { }
local gPlayerMutes = {}
local mutesLimit = 3

addEvent('playerMessage')
addEventHandler('playerMessage', root, 
	function( message, fullMessage, logMessage, teamChat )
		local sendMsg = true
		if not gPlayerSpams[ source ] then
			setElementData(source, "spam", 0)
			gPlayerSpams[ source ] = true
			gPlayerTickCount[ source ] = getTickCount( )
			gPlayerMessage[ source ] = message
			gPlayerMutes[source] = 0
		else
			if isPlayerMuted(source) then return end

			-- AntiSpam won't be checked in team chat. Meaning in team chat players can talk as much as they want.
			if teamChat then
				triggerEvent("antiResp", source, fullMessage, logMessage, teamChat)
				return
			end

			if getTickCount( ) - gPlayerTickCount[ source ] > gSettings.delay then
				setElementData(source, "spam", 0)
				gPlayerMsgNum[ source ] = 0
				gPlayerTickCount[ source ] = getTickCount( )
				triggerEvent("antiResp", source, fullMessage, logMessage, teamChat)
				return
			else
				if gPlayerMsgNum[source] > (gSettings.msgNum)*2 then
					gPlayerMutes[source] = gPlayerMutes[source] + 1
					if gPlayerMutes[source] ~= mutesLimit then
						gPlayerTickCount[ source ] = getTickCount( )
						--cancelEvent( )
						sendMsg = false
						setPlayerMuted(source, true)
						setElementData(source, "spam", 1)
						outputChatBox(getPlayerName(source).."#FF0000 has been muted for flooding. (1 min)", root, 255, 0, 0, true)
						gPlayerMutedTimers[source] = setTimer(function(player) setPlayerMuted(player, false) outputChatBox(getPlayerName(player).."#FF0000 has been unmuted by the Console.", root, 255, 0, 0, true) setElementData(player, "spam", 0) end, 60000, 1, source)
					else kickPlayer(source, "Kicked for excessive spam.")	
					end
					return
				end	
				if gPlayerMsgNum[ source ] >= gSettings.msgNum then
					setElementData(source, "spam", 1)
					gPlayerTickCount[ source ] = getTickCount( )
					--cancelEvent( )
					sendMsg = false
					outputChatBox( "Don't flood the chat! (Quick spam)", source, 255, 0, 0 )
				elseif message == gPlayerMessage[ source ] then
					setElementData(source, "spam", 1)
					gPlayerTickCount[ source ] = getTickCount( )
					--cancelEvent( )
					sendMsg = false
					outputChatBox( "Don't flood the chat! (Same message)", source, 255, 0, 0 )
				elseif tonumber(message) and tonumber(gPlayerMessage[ source ]) then
					setElementData(source, "spam", 1)
					gPlayerTickCount[ source ] = getTickCount( )
					--cancelEvent( )
					sendMsg = false
					outputChatBox( "Don't flood the chat! (Number spam)", source, 255, 0, 0 )
				end
				gPlayerMsgNum[ source ] = gPlayerMsgNum[ source ] + 1
			end
		end
		gPlayerMessage[ source ] = message
		
		if sendMsg then
			triggerEvent("antiResp", source, fullMessage, logMessage, teamChat)
		end
	end
)

addEventHandler( "onPlayerJoin", root,
	function( )
		gPlayerMsgNum[ source ] = 0
		setElementData(source, "spam", 0)
	end
)

-- ANTI FLOOD FOR COMMANDS. IMPLEMENTED SINCE 1.1.x
local commandSpam = {}
local cmdSpamTimer = {}


--exceptions required because the event onPlayerCommand fires up when a bunch of binds(attached to commands) are called for example scoreboard, gcshop etc
local exceptions = {
 "Toggle",
 "say", 
 "showsensor",
 "showtimes", 
 "gcshop",
 "Open",
 "scoreboard",
 "mapinfo",
 "gchorn",
 "admin",
 "Commit",
 "modsay",
 "adsay"
}
--
 
function preventCommandSpam(command)
	-- if hasObjectPermissionTo(source, "function.banPlayer", false) then return end
	for i, com in ipairs(exceptions) do 
		if com == command then return end
	end
	if (not commandSpam[source]) then
		commandSpam[source] = 1
		--resetSpamTimer
		if isTimer(cmdSpamTimer[source]) then killTimer(cmdSpamTimer[source]) end
		cmdSpamTimer[source] = setTimer(function(player) commandSpam[player] = false end, tonumber(gSettings.delay), 1, source)
	elseif (commandSpam[source] >= 4) then
		cancelEvent()
		outputChatBox("Please refrain from command/bind spamming! Wait at least 4 seconds.", source, 255, 0, 0)
		if isTimer(cmdSpamTimer[source]) then killTimer(cmdSpamTimer[source]) end
		cmdSpamTimer[source] = setTimer(function(player) commandSpam[player] = false end, tonumber(gSettings.delay), 1, source)
	else
		commandSpam[source] = commandSpam[source] + 1
		if isTimer(cmdSpamTimer[source]) then killTimer(cmdSpamTimer[source]) end
		cmdSpamTimer[source] = setTimer(function(player) commandSpam[player] = false end, tonumber(gSettings.delay), 1, source)
	end
end

addEventHandler( "onResourceStart", resourceRoot,
    function( )
        gSettings.delay = get( "@differenceBetweenMessages_ms" )
		gSettings.msgNum = get( "@messagesNumber" )
		for _, plr in pairs( getElementsByType( "player" ) ) do
			gPlayerMsgNum[ plr ] = 0
			setElementData(plr, "spam", 0)
		end
		addEventHandler("onPlayerCommand", root, preventCommandSpam)
    end
)

---------------VOTE SPAM HANDLER--------------

function disableVoteSpam(message)
	if hasObjectPermissionTo(source, "function.banPlayer", false) then
		return 
	elseif string.find(message, '1') or string.find(message, '2') then
		cancelEvent()
		outputChatBox('Chat has disabled use of numbers during voting.', source, 50, 205, 50)
	end	
end

local chatDisabled = false
addEvent('onPollStarting', true)
addEventHandler('onPollStarting', root,
function(poll)
	if poll[1][1] == 'Random' then    --All we want is Race's very own Random/Play again to handle
		addEventHandler('onPlayerChat', root, disableVoteSpam)
		chatDisabled = true
	end	
end
)

addEvent('onMapStarting', true)   
addEventHandler('onMapStarting', root,
function()
	if chatDisabled then
		removeEventHandler('onPlayerChat', root, disableVoteSpam)
		chatDisabled = false
	end	
end
)

addEvent('onPollEnd', true)
addEventHandler('onPollEnd', root,
function()
	if chatDisabled then
		removeEventHandler('onPlayerChat', root, disableVoteSpam)
		chatDisabled = false
	end	
end
)


-- Blocking /say /me commands that have been binded using /bind
local saybinds = {}
local saybindstimer = {}
addEvent('saybinds', true)
addEventHandler('saybinds', resourceRoot, function(binds)
	saybinds[client] = binds
end)

function onChatMessageHandler(theMessage)
	local binds = saybinds[source]
	local tick = getTickCount()
	if not binds then return end
	for k, msg in ipairs (binds) do
		if msg == theMessage then
			if saybindstimer[source] and tick - saybindstimer[source] < 20 * 1000 then
				outputChatBox('Binds disabled', source, 255, 0, 0)
				return cancelEvent()
			else
				saybindstimer[source] = tick
			end
		end
	end
end
addEventHandler("onPlayerChat", root, onChatMessageHandler)

-- Cleaning up on quit
addEventHandler('onPlayerQuit', root, function()
	saybinds[source] = nil
	saybindstimer[source] = nil
	gPlayerTickCount[source] = nil
	gPlayerSpams[source] = nil
	gPlayerMsgNum[source] = nil
	gPlayerMutedTimers[source] = nil
	gPlayerMutes[source] = nil
end)



--[[
-- command to retreive a player's binds
addCommandHandler('testsay', function(p, c, n)
	local player = getPlayerFromName(n) or p
	local binds = saybinds[player]
	
	if not binds then
		return outputDebugString('No binds for ' .. getPlayerName(player))
	end
	
	outputDebugString(#binds .. ' binds for ' .. getPlayerName(player))
	
	for k, v in ipairs(binds) do
		outputDebugString(k .. ':' .. v)
	end
end)
--]]
