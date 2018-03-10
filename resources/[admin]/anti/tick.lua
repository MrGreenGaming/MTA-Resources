local pTick = {} -- pTick[i] = { player element, first server tick, first client tick, previous server tick, previous client tick, last server tick, last client tick, delta, serial}
local tickRemove
local tickTimer

function onResourceStart()
	tickTimer = setTimer(tickCheck_s, 1000, 0)
	tickRemove = setTimer(tickRemove, 1000 * 60 * 10, 0)
end
addEventHandler('onResourceStart', getResourceRootElement(),onResourceStart)

function tickCheck_s()
	local players = getElementsByType("player")
	for a,b in ipairs(players) do
		triggerClientEvent(b, "anti_tickCheck_c", resourceRoot, getTickCount())
	end
end

function tickCheck(tick_s, tick_c)
	local delta = getTickCount() - tick_s -- Difference between request and receive
	local serial = getPlayerSerial(source)
	
	local bool = false
	local players = getElementsByType("player")
	for a,b in ipairs(pTick) do
		if b[9] == serial then
			bool = true
			b[4] = b[6]
			b[5] = b[7]
			b[6] = tick_s
			b[7] = tick_c
			b[8] = delta
		end
	end
	
	if not bool then
		local i = #pTick + 1
		pTick[i] = {}
		pTick[i][1] = getPlayerNametagText(source)
		pTick[i][2] = tick_s
		pTick[i][3] = tick_c
		pTick[i][4] = tick_s
		pTick[i][5] = tick_c
		pTick[i][6] = tick_s
		pTick[i][7] = tick_c
		pTick[i][8] = delta
		pTick[i][9] = serial
	end
end
addEvent("anti_tickCheck_s", true)
addEventHandler("anti_tickCheck_s", root, tickCheck)

function tickRemove()
	local i = #pTick
	while i > 0 do
		if (not getPlayerFromName(pTick[i][1])) and (pTick[i][6] > (getTickCount() - 1000 * 60 * 30)) then
			table.remove(pTick,i)
		end
		i = i - 1
	end
end

-- GUI

function tickTable_s()
	triggerClientEvent(source, "anti_tickTable_c", resourceRoot, pTick)
end
addEvent("anti_tickTable_s", true)
addEventHandler("anti_tickTable_s", root, tickTable_s)

function tickWindow(p)
	triggerClientEvent(p,"anti_tickWindow_c",resourceRoot)
end
addCommandHandler("tick", tickWindow, true, true)