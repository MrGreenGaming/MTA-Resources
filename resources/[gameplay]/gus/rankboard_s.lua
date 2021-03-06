playerTable = {}
addEvent('onPlayerFinish', true)
local upModes = { -- Count Up modes
	["Sprint"] = true,
	["Never the same"] = true,
	["Reach the flag"] = true,
}
local downModes = {
	["Shooter"] = true,
	["Deadline"] = true,
	["Destruction derby"] = true,
}


-- Upcount modes finish handler

function upCountModes(rank, time)
	if not upModes[exports.race:getRaceMode()] then return end
	local name = addTeamColor(source)
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
addEvent("onPlayerFinishDeadline")
addEvent("onPlayerWinDeadline")

function downCountModes(rank,time)
	local name = getElementData(source, 'vip.colorNick') or getPlayerName(source)
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
addEventHandler('onPlayerFinishDeadline', getRootElement(),downCountModes)
addEventHandler('onPlayerWinDeadline', getRootElement(),downCountModes)

function longestTimeMode(time)
	-- Insert into table
	local t = {}
	t.name = getElementData(source, 'vip.colorNick') or getPlayerName(source)
	t.time = time
	t.player = source

	local inserted = false
	for i, v in ipairs(playerTable) do
		if v.player == source then
			playerTable[i] = t
			inserted = true
			break
		end
	end
	if not inserted then table.insert(playerTable, 1, t) end

	-- Sort
	table.sort(playerTable, function(a,b) return a.time > b.time end)

	-- Add rank
	for i, v in ipairs(playerTable) do
		playerTable[i].rank = i
	end

	triggerClientEvent("updatePlayerTimes", root, playerTable, "downTime")
end
addEvent("onPlayerFinishManhunt")
addEventHandler('onPlayerFinishManhunt', root, longestTimeMode)

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

function addTeamColor(player)
	local playerTeam = getPlayerTeam ( player )
	if ( playerTeam ) then
		local r,g,b = getTeamColor ( playerTeam )
		local n1 = toHex(r)
		local n2 = toHex(g)
		local n3 = toHex(b)
		if r <= 16 then n1 = "0"..n1 end
		if g <= 16 then n2 = "0"..n2 end
		if b <= 16 then n3 = "0"..n3 end
		return "#"..n1..""..n2..""..n3.."".. (getElementData(player, 'vip.colorNick') or getPlayerNametagText(player))
	else
		return (getElementData(player, 'vip.colorNick') or getPlayerNametagText(player))
	end
end

function toHex ( n )
    local hexnums = {"0","1","2","3","4","5","6","7",
                     "8","9","A","B","C","D","E","F"}
    local str,r = "",n%16
    if n-r == 0 then str = hexnums[r+1]
    else str = toHex((n-r)/16)..hexnums[r+1] end
    return str
end
