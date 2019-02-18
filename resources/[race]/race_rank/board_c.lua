g_SplitTimes = {}
g_DrawList = {}
g_Rank = nil
--[[
g_DrawList ={
{rank = 1, name = "#FF0000SDK1"},
{rank = 2, name = "8888888888888888888888"},
{rank = 3, name = "SD#FFF000K3", line = true},
{rank = 8, name = "SDK8"},
{rank = 9, name = "SDK9"},
{rank = 10, name = "SDK10", player = getLocalPlayer()},
{rank = 11, name = "SDK#66666111"},
{rank = 12, name = "SDK12"}
}--]]
localPlayer = getLocalPlayer()

screenFadedOut = false
raceState = ""
enableBoard = false
gamemodeAllowed = false
allowedGM = {
	["Never the same"] = true,
	["Sprint"] = true,
	["Reach the flag"] = true,
}

lines = 8
ranksBefore = 2
ranksBehind = 2
splitsTop = 1
splitsBefore = 1
splitsBehind = 1


function gameModeHandler(gm)
	if allowedGM[gm] then gamemodeAllowed = true
	else gamemodeAllowed = false
	end
end
addEvent("serverSendGM",true)
addEventHandler("serverSendGM",root,gameModeHandler)

function updateWhiteList()
	for k,v in pairs(g_DrawList) do
		g_DrawList[k] = nil
	end
	
	g_Rank = tonumber(getElementData(localPlayer, 'race rank'))
	if not isBoardAllowed() or not g_Rank then return end
	
	local players = getElementsByType('player')
	table.sort ( players, 
		function ( a, b )
			a = tonumber(getElementData(a, 'race rank'))
			b = tonumber(getElementData(b, 'race rank'))
			if not a then
				return false
			elseif not b then 
				return true
			else
				return a < b
			end
		end
	)
	
	local ranksTop = math.clamp ( 1, lines - (1 + ranksBefore + ranksBehind), #players)
	local ranksBefore  = math.clamp ( 1, g_Rank - math.abs( ranksBefore ), g_Rank)
	local ranksBehind  = math.clamp ( g_Rank, g_Rank + math.abs( ranksBehind ), #players)
	
	for rank, player in ipairs (players) do
		if rank <= ranksTop and rank <= g_Rank --top ranks
		or ranksBefore <= rank and #g_DrawList < lines --front and back ranks
		or #players - rank < lines - #g_DrawList then
			g_DrawList[#g_DrawList + 1] = { rank = rank, player = player, name = (getElementData(player, 'vip.colorNick') or getPlayerName(player)) }
			if g_DrawList[#g_DrawList].rank > 1 and g_DrawList[#g_DrawList].rank - g_DrawList[#g_DrawList - 1].rank ~= 1 then
				g_DrawList[#g_DrawList - 1].line = true
			elseif rank <= splitsTop or (g_Rank - splitsBefore <= rank and rank <= g_Rank + splitsBehind) then
				g_DrawList[#g_DrawList].split = true
			end
		end
	end
end
setTimer(updateWhiteList, 450, 0)
addEventHandler("onClientPlayerQuit", root, updateWhiteList)
local screenx,screeny = guiGetScreenSize()
x = screenx - 210
y = 200
w = 200
lineheight = 15
rank_w = 27
space_w = 10
margin = 5
font = "default"
timewidth = 65
drawSplitTimeTime = 5000
addEventHandler("onClientScreenFadedOut",getRootElement(),function() screenFadedOut = true end)
addEventHandler("onClientScreenFadedIn",getRootElement(),function() screenFadedOut = false end)

addCommandHandler('board', function(cmd, args)
	enableBoard = not enableBoard
	outputChatBox((enableBoard and'Showing' or 'Hiding') .. ' ranking board' )
end)

addEventHandler('onClientRender', getRootElement(), function()
	if not isBoardAllowed() then return end
	
	drawBackground(x,y,w,lines * lineheight)
	drawRank()
	drawSplits()
end)

function isBoardAllowed()
	return not screenFadedOut and enableBoard and gamemodeAllowed
end

function drawBackground (x,y,w,d)
	dxDrawRectangle(x-1,y-1,rank_w+2,d+2,tocolor(255,255,255))
	dxDrawRectangle(x,y,rank_w,d,tocolor(0,0,0))
	dxDrawRectangle(x-1+rank_w+space_w,y-1,w+2-rank_w-space_w,d+2,tocolor(255,255,255))
	dxDrawRectangle(x+rank_w+space_w,y,w-rank_w-space_w,d,tocolor(0,0,0))
	-- for i=1,lines-1 do
		-- dxDrawLine(x,y + i* lineheight, x+w, y + i * lineheight, tocolor(255,255,255))
	-- end
end

function drawRank()
	for k,r in ipairs(g_DrawList) do
		if r.line == true then
			local text = "-"
			local width = dxGetTextWidth(text,1,font)
			text = string.rep ( text, math.ceil(w-(rank_w+space_w) / width) + 1 )
			dxDrawText(text, x,y+(k-1)*lineheight, x+rank_w, y+k*lineheight,tocolor(255,0,0),1,font,"center", "center",true)
			dxDrawText(text, x+rank_w+space_w,y+(k-1)*lineheight, x+w, y+k*lineheight,tocolor(255,0,0),1,font,"center", "center",true)
		else
			if r.player == localPlayer then
				dxDrawRectangle(x,y+(k-1)*lineheight, rank_w, lineheight,tocolor(100, 100, 100))
				dxDrawRectangle(x+rank_w+space_w,y+(k-1)*lineheight, w-(rank_w+space_w), lineheight,tocolor(100, 100, 100))
			end
			-- dxDrawBorderedText(1,tocolor(255,255,255),r.rank .. ".",x,y+(k-1)*lineheight, x+rank_w, y+k*lineheight,tocolor(255,255,255),1,font,"center", "center",true)
			-- dxDrawBorderedText(1,tocolor(255,255,255),r.name ,x+rank_w+space_w + margin,y+(k-1)*lineheight, x+w-margin, y+k*lineheight,tocolor(255,255,255),1,font,"left", "center",true)
			dxDrawColorText(r.rank .. ".",x+margin,y+(k-1)*lineheight, x+rank_w, y+k*lineheight,tocolor(255,255,255),1,font,"left", "center",true)
			dxDrawColorText(r.name ,x+rank_w+space_w + margin,y+(k-1)*lineheight, x+w-margin, y+k*lineheight,tocolor(255,255,255),1,font,"left", "center",true)
			local state = isElement(r.player) and getElementType(r.player) == "player" and getElementData(r.player, 'state', false)
			if state and getElementData(r.player, 'race.finished', false) then
				dxDrawRectangle(x,y+(k-1)*lineheight, rank_w, lineheight,tocolor(0, 255, 0,60))
				dxDrawRectangle(x+rank_w+space_w,y+(k-1)*lineheight, w-(rank_w+space_w), lineheight,tocolor(0, 255, 0,60))
			elseif state == "dead" then
				local text = "-"
				local width = dxGetTextWidth(text,1,font)
				text = string.rep ( text, math.ceil(w-(rank_w+space_w) / width) + 1 )
				dxDrawText(text, x,y+(k-1)*lineheight, x+rank_w, y+k*lineheight,tocolor(255,255,255),1,font,"center", "center",true)
				dxDrawText(text, x+rank_w+space_w,y+(k-1)*lineheight, x+w, y+k*lineheight,tocolor(255,255,255),1,font,"center", "center",true)
			end
		end
	end
end

function drawSplits()
	local localTimes = g_SplitTimes[localPlayer]
	local localCP = localTimes and localTimes.current and localTimes.current.checkpoint
	if not tonumber(localCP) then return end
	for line, data in ipairs ( g_DrawList ) do
		local player, playerRank, playerShowSplitTime, playerTimes = data.player, data.rank, data.split, g_SplitTimes[data.player]
		if player ~= localPlayer and isElement(player) and playerTimes and playerShowSplitTime then
			local playerCP = playerTimes.current and playerTimes.current.checkpoint or false
			if playerTimes[localCP] then		-- when reaching a checkpoint behind someone
				if getTickCount() - localTimes[localCP].tick <= drawSplitTimeTime and playerRank < g_Rank then
					drawSplitTime(line, localTimes.current.time - playerTimes[localCP].time)
				end
			elseif localTimes[playerCP] then	-- when someone reaches a cp behind you
				if getTickCount() - playerTimes[playerCP].tick <= drawSplitTimeTime and playerRank > g_Rank then
					drawSplitTime(line, localTimes[playerCP].time - playerTimes[playerCP].time)
				end
			end
		end
	end
end

function drawSplitTime(line,splittime)
	local x = x - margin - timewidth
	local y = y + (line-1) * lineheight + 1
	local w = timewidth
	local h = lineheight -2
	local color = splittime<0 and tocolor(255,0,0) or tocolor(0,255,0)
	dxDrawRectangle(x,y,w,h,color)
	dxDrawRectangle(x+1,y+1,w-2,h-2,tocolor(0, 0, 0))
	dxDrawText(timeMsToTimeText(splittime), x+margin/2,y,x+w-margin/2,y+h,color,1,font, "right", "center", true)
end

--[[ addEventHandler("onClientRender", root, function()
	-- drawSplitTime(5,-1500)
	-- drawSplitTime(6,-1565489)
	-- drawSplitTime(7,1500)
	-- drawSplitTime(8,59880+60000*88)
 end)
--]]

addEvent('onClientMapStarting', true)
addEventHandler('onClientMapStarting', getRootElement(), 
	function(mapinfo)
		g_SplitTimes = {}
	end
)

addEvent('onClientPlayerReachCheckpoint', true)
addEventHandler('onClientPlayerReachCheckpoint', getRootElement(), 
	function(checkpoint, time)
		if not g_SplitTimes[source] then
			g_SplitTimes[source] = {}
		end
		g_SplitTimes[source].current = { checkpoint = checkpoint, time = time, tick = getTickCount() }
		g_SplitTimes[source][checkpoint] = { time = time, tick = getTickCount() }
		-- for i,v in ipairs ( g_SplitTimes[source] ) do
			-- if g_SplitTimes[source].current.checkpoint < i  then
				-- g_SplitTimes[source][i] = nil
			-- end
		-- end
	end
)

function showsplits(c, a)
	local t = g_SplitTimes[getPlayerFromName(a)]
	-- outputDebugString('Current: ' .. t.current.checkpoint .. ' ' .. t.current.time .. ' ' .. t.current.tick .. ' ')
	for k,v in pairs(t) do 
		outputDebugString(k .. ': ' .. v.time .. ' ' .. v.tick .. ' ')
	end
end
-- addCommandHandler('showsplits',showsplits)

function timeMsToTimeText( timeMs )

	local pre = (timeMs > 0 and '+') or '-'
	timeMs = math.abs ( timeMs )
	local minutes	= math.floor( timeMs / 60000 )
	timeMs			= timeMs - minutes * 60000;

	-- local seconds	= math.floor( timeMs / 1000 )
	local seconds	=  timeMs / 1000 
	-- local ms		= timeMs - seconds * 1000;
	
	return string.format( '%s%d:%05.2f', pre, minutes, seconds )
end

function timeMsToTimeText2( timeMs )

	local pre = (timeMs > 0 and '+') or '-'
	timeMs = math.abs ( timeMs )
	local minutes	= math.floor( timeMs / 60000 )
	timeMs			= timeMs - minutes * 60000;

	local seconds	= math.floor( timeMs / 1000 )
	local ms		= timeMs - seconds * 1000;
	
	
	return pre .. string.format( '%01d:%02d:%03d', minutes, seconds, ms );
end

function math.clamp(lowClamp, val, highClamp)
	return math.max(math.min(val, highClamp), lowClamp)
end

function dxDrawColorText(str, ax, ay, bx, by, color, scale, font, alignX, alignY)
 
	if alignX then
		if alignX == "center" then
			local w = dxGetTextWidth(str:gsub("#%x%x%x%x%x%x",""), scale, font)
			ax = ax + (bx-ax)/2 - w/2
		elseif alignX == "right" then
			local w = dxGetTextWidth(str:gsub("#%x%x%x%x%x%x",""), scale, font)
			ax = bx - w
		end
	end

	if alignY then
		if alignY == "center" then
			local h = dxGetFontHeight(scale, font)
			ay = ay + (by-ay)/2 - h/2
		elseif alignY == "bottom" then
			local h = dxGetFontHeight(scale, font)
			ay = by - h
		end
	end

	local pat = "(.-)#(%x%x%x%x%x%x)"
	local s, e, cap, col = str:find(pat, 1)
	local last = 1
	while s do
		if cap == "" and col then color = tocolor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), 255) end
		if s ~= 1 or cap ~= "" then
			local w = dxGetTextWidth(cap, scale, font)
			dxDrawText(cap, ax, ay, ax + w, by, color, scale, font)
			ax = ax + w
			color = tocolor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), 255)
		end
		last = e + 1
		s, e, cap, col = str:find(pat, last)
	end
	if last <= #str then
		cap = str:sub(last)
		local w = dxGetTextWidth(cap, scale, font)
		dxDrawText(cap, ax, ay, ax + w, by, color, scale, font)
	end
end

function dxDrawBorderedText(outlineSize, outlineColor, text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI)
	if not outlineSize or not outlineColor or not text or not left or not top then return end
	if not right then right = left end
	if not bottom then bottom = top end
	if not color then color = 0xFFFFFFFF end
	if not scale then scale = 1 end
	if not font then font = font end
	if not alignX then alignX = "left" end
	if not alignY then alignY = "right" end
	if clip == nil then clip = false end
	if wordBreak == nil then wordBreak = false end
	if postGUI == nil then postGUI = false end
    
	for oX = -1*outlineSize, outlineSize do
        for oY = -1*outlineSize, outlineSize do
                dxDrawText(text, left + oX, top + oY, right + oX, bottom + oY, outlineColor, scale, font, alignX, alignY, clip, wordBreak, postGUI)
        end
    end
    dxDrawText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI)
end

-- Exported function for settings menu, KaliBwoy

function showBoard()
	enableBoard = true
	local xml = xmlLoadFile("board_settings.xml")
	if not xml then
		xml = xmlCreateFile("board_settings.xml", "main")
	end
	local child = xmlFindChild(xml, "option", 0)
	if not child then
		child = xmlCreateChild(xml, "option")
	end
	xmlNodeSetValue(child, tostring(true))
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end

function hideBoard()
	enableBoard = false
	local xml = xmlLoadFile("board_settings.xml")
	if not xml then
		xml = xmlCreateFile("board_settings.xml", "main")
	end
	local child = xmlFindChild(xml, "option", 0)
	if not child then
		child = xmlCreateChild(xml, "option")
	end
	xmlNodeSetValue(child, tostring(false))
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end