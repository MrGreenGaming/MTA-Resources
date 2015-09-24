---
-- Main server file that sends player times to the clients.
--
-- @author	driver2
-- @copyright	2009-2010 driver2
--
-- Changes:


local g_times = {}
local g_playersReady = {}

addEventHandler("onGamemodeMapStart",getRootElement(),
	function(startedMap)
		g_times = {}
	end
)

addEventHandler("onPlayerReachCheckpoint",getRootElement(),
	function(checkpoint,time)
		addTime(source,checkpoint,time)
		sendMessageToAllClients("update",{source,checkpoint,time})
	end
)
addEventHandler("onPlayerJoin",getRootElement(),
	function()
		g_playersReady[source] = false
		g_times[source] = {}
	end
)

function addTime(player,checkpoint,time)
	if g_times[player] == nil  then
		g_times[player] = {}
	end
	g_times[player][checkpoint] = time
end

function sendTimesToPlayer(player)
	sendMessageToClient(player,"times",g_times)
end

-------------------
-- Communication --
-------------------

function clientMessage(message,parameter)
	-- outputDebugString("onRaceProgressClientMessage: "..message)
	local player = client
	if message == "loaded" then
		sendTimesToPlayer(player)
		g_playersReady[player] = true
	end
end
addEvent("onRaceProgressClientMessage",true)
addEventHandler("onRaceProgressClientMessage",root,clientMessage)


function sendMessageToAllClients(message,parameter)
	for _,player in pairs(getElementsByType("player")) do
		if g_playersReady[player] then
			sendMessageToClient(player,message,parameter)
		end
	end
end
function sendMessageToClient(client,message,parameter)
	triggerClientEvent(client,"onClientRaceProgressServerMessage",root,message,parameter)
end
