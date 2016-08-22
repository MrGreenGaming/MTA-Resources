local delay = {}
local min_delay = 500
local g_PlayersRefuse = {}


addCommandHandler('messages',
    function(player)
        g_PlayersRefuse[player] = not g_PlayersRefuse[player]
        outputChatBox("Private messaging has been turned "..(g_PlayersRefuse[player] and 'off' or 'on').." for you!", player, 255, 0, 0)
    end)

addEvent("onGUIPrivateMessage", true)
addEventHandler("onGUIPrivateMessage", root, 
	function(toplayer, text)
		local isPlayerAdmin = hasObjectPermissionTo( client, "function.banPlayer" ,false )
		if exports.gus:chatDisabled() or isPlayerMuted(client) and not isPlayerAdmin then
			return outputChatBox('You are muted. Private message wasn\'t delivered. ', client, 255, 0, 0)
		elseif g_PlayersRefuse[client] and not isPlayerAdmin then
			return outputChatBox('Your PM settings are turned off, please enable it via /settings if you wish to PM.',client,255,0,0)
		elseif delay[client] and getTickCount() - delay[client] < min_delay and not isPlayerAdmin then
			return outputChatBox('Do not spam. Private message wasn\'t delivered. ', client, 255, 0, 0)
        elseif g_PlayersRefuse[toplayer] and not isPlayerAdmin then
            return outputChatBox("Message not delivered! "..getPlayerName(toplayer):gsub( '#%x%x%x%x%x%x', '' ).." does not wish to be disturbed right now!", source, 255, 0, 0)
		end
		
		triggerClientEvent(toplayer, "onPrivateChatSent", client, client, text)
		delay[client] = getTickCount()
	end
)

addEventHandler('onPlayerQuit', root,
function()
    delay[source] = nil
	g_PlayersRefuse[source] = nil
end
)


-- Functions for settings menu,  KaliBwoy
addEvent("client_TogglePM", true)
function togglePM(trueornah, loadornah)
	if trueornah == true then
		g_PlayersRefuse[client] = nil
	elseif trueornah == false then
		g_PlayersRefuse[client] = true
	end
	if loadornah ~= true then
		if trueornah == true then
			outputChatBox("Private messaging has been turned on for you!", client, 0, 255, 0)
		else
			outputChatBox("Private messaging has been turned off for you!", client, 255, 0, 0)
		end
	end


end
addEventHandler("client_TogglePM", root, togglePM)

