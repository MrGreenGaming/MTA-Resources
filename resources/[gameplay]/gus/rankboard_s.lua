playerTable = {}
addEvent('onPlayerFinish', true)
local upModes = { -- Count Up modes
	["Sprint"] = true,
	["Never the same"] = true,
	["Reach the flag"] = true,
}
local downModes = {
	["Shooter"] = true,
	["Destruction derby"] = true,
}


-- Upcount modes finish handler

function upCountModes(rank, time)
	if not upModes[exports.race:getRaceMode()] then return end
	local name = getPlayerName(source)
	playerTable[rank] = {}
	playerTable[rank].name = name
	playerTable[rank].time = time
	playerTable[rank].rank = rank
	triggerClientEvent("updatePlayerTimes", root, playerTable,"up")
end
addEventHandler('onPlayerFinish', getRootElement(),upCountModes)

addEvent("onPlayerFinishDD")
addEvent("onPlayerWinDD")
addEvent("onPlayerFinishShooter")
addEvent("onPlayerWinShooter")

function downCountModes(rank,time)


	local name = getPlayerName(source)
	local t = {}
	t.name = name
	t.rank = rank
	t.time = time
	t.kills = false
	if getElementData(source,"kills") then t.kills = getElementData(source,"kills") else t.kills = nil end

	table.insert(playerTable,1,t)
	triggerClientEvent("updatePlayerTimes",root,playerTable,"down")
end

addEventHandler('onPlayerFinishDD', getRootElement(),downCountModes)
addEventHandler('onPlayerWinDD', getRootElement(),downCountModes)
addEventHandler('onPlayerFinishShooter', getRootElement(),downCountModes)
addEventHandler('onPlayerWinShooter', getRootElement(),downCountModes)



function carGameMode(rankTable)
	triggerClientEvent("updatePlayerTimes",root,rankTable,"cargame")
end
addEvent("onPlayerWinCarGame")
addEventHandler("onPlayerWinCarGame",root,carGameMode)


local bool = false

--[[addEvent('onPostFinish', true)
addEventHandler('onPostFinish', getRootElement(),
function()
		playerTable = {}
		triggerClientEvent("updatePlayerTimes", getRootElement(), false)
		bool = true
end
)]]

addEventHandler('onMapStarting', getRootElement(),
function()
		playerTable = {}
end
)

addEvent("onJoinedPlayerRequireList", true)
addEventHandler("onJoinedPlayerRequireList", getRootElement(),
function()
	if #playerTable > 0 then
		triggerClientEvent(source,"updatePlayerTimes", getRootElement(), playerTable)
	else
	triggerClientEvent(source, "updatePlayerTimes", getRootElement(), false)
	end
end
)