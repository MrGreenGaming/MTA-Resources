--
-- Settings
--
screenFadedOut = false
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
animationsEnabled = true
showIntervals = false
liveIntervals = false

y = 200
w = 190
itemHeight = 20
itemPadding = 2

local screenX, screenY = guiGetScreenSize()

function round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

-- Resolution dependent scale
local scale = round((screenY/800)*10)/10 

--
-- RankBoard class
--
RankBoard = {}
RankBoard.__index = RankBoard
RankBoard.animate = animationsEnabled
RankBoard.scale = scale
RankBoard.itemheight = round(itemHeight * scale)
RankBoard.padding = round(itemPadding * scale)
RankBoard.font = dxCreateFont("fonts/TitilliumWeb-SemiBold.ttf", round(11 * scale)) or "default-bold"
RankBoard.fontSmall = dxCreateFont("fonts/TitilliumWeb-Regular.ttf", round(11 * scale)) or "default"
RankBoard.fontState = dxCreateFont("fonts/StateIcons.ttf", round(9 * scale)) or "default"
RankBoard.timeW = round((dxGetTextWidth("+00:00:00", 1, RankBoard.fontSmall) + itemPadding*2) * scale)
RankBoard.x = screenX - round((w+40) * scale) - (showIntervals and RankBoard.timeW or 0)
RankBoard.y = y
RankBoard.w = round(w * scale);
RankBoard.linePosition = 0
RankBoard.lineY = 0
RankBoard.showIntervals = showIntervals
RankBoard.liveIntervals = liveIntervals
RankBoard.backgroundOpacity = 0.65
RankBoard.animations = {}
RankBoard.sorted = {}
RankBoard.bestCPTimes = {}
RankBoard.leader = nil
RankBoard.items = {}

function RankBoard:create(player, name, color)
    RankBoard.items[player] = setmetatable({
        player = player,
        localPlayer = player == getLocalPlayer(),
        rank = 0,
        name = name or (getElementData(player, 'vip.colorNick') or getPlayerName(player)),
        hidden = true,
        willHide = false,
        willShow = false,
        color = color and tocolor(color[1], color[2], color[3]) or tocolor(100,100,100), 
        colorRGB = color or {100,100,100},
        checkpoint = nil,
        times = {},
        cpTime = 0,
        delay = 0,
        state = getElementData(player, "player state", false) or "alive",
        split = false,
        offset = 0,
        x = 0, 
        y = 0, 
        a = 1,
	rankChange = 0, 
	rankChangeTime = nil, 
	splitValue = "", 
	splitTime = nil,
        animations = {},
    }, self)
    local team = getPlayerTeam(player)
    if team then
    	local r,g,b = getTeamColor(team)
    	RankBoard.items[player].colorRGB = {r,g,b}
    	RankBoard.items[player].color = tocolor(r,g,b)
    	RankBoard.items[player].name = RGBToHex(r,g,b) .. RankBoard.items[player].name
    end
    return RankBoard.items[player]
end

function RankBoard.remove(player)
	if RankBoard.items[player] then setmetatable(RankBoard.items[player], nil) end
	RankBoard.items[player] = nil
end

function RankBoard:update(what)

	for key, value in pairs (what) do
		if key == "rank" then
			
			local newY = ((value - 1) * RankBoard.itemheight) --+ ((value - 1) * RankBoard.padding)
			
			if self.offset > 0 then
				--newY = newY - (self.offset - 1) * (RankBoard.itemheight + RankBoard.padding) + RankBoard.itemheight/2 
				newY = newY - (self.offset - 1) * (RankBoard.itemheight) + RankBoard.padding
			end
		
			if not self.hidden and not self.willHide then
				if RankBoard.animate and not self.willShow then
					if self.animations["y"] ~= nil then destroyAnimation(self.animations["y"]) end
					self.animations["y"] = animate(self.y, newY, "OutQuad", 250, function(y)
			        		self.y = y
			    		end, function()
			    			self.animations["y"] = nil
			    		end)
				else
					self.y = newY
				end
			end
		
			if self.rank > 0 and self.rank ~= value then
				self.rankChange = self.rank - value
				self.rankChangeTime = getTickCount()
			end
			
			self.rank = value
		elseif key == "split" and value ~= "" then
			self.split = value
			--self.splitValue = value
			--self.splitTime = getTickCount()
		elseif key == "state" then
			if value == "dead" then
				self.a = 0.6
			elseif self.state == "dead" then
				self.a = 1
			end
			
			self.state = value
		elseif key == "offset" then
			self.offset = value
		elseif key == "checkpoint" then
			self.times[value.checkpoint] = value
			self.checkpoint = value.checkpoint

			local localItem = RankBoard.items[getLocalPlayer()]
			local localTimes = localItem and localItem.times or false
			local localCP = localItem and localItem.checkpoint or false

			if localCP and (self.localPlayer or self.split) then
				for player,item in pairs(RankBoard.items) do
					local playerTimes = item.times or false
					if player ~= getLocalPlayer() and playerTimes and item.split then
						local playerCP = item.checkpoint or false
						if self.localPlayer and playerTimes[localCP] then  -- when reaching a checkpoint behind someone
							item.splitValue = timeMsToTimeText(playerTimes[localCP].time - localTimes[localCP].time)
							item.splitTime = getTickCount()
						elseif not self.localPlayer and localTimes[playerCP] then  -- when someone reaches a cp behind you
							item.splitValue = timeMsToTimeText(playerTimes[playerCP].time - localTimes[playerCP].time)
							item.splitTime = getTickCount()
						end
					end
				end
			end
			
			if not RankBoard.bestCPTimes[value.checkpoint] then
				RankBoard.bestCPTimes[value.checkpoint] = value.tick
				self.cpTime = 0
				self.delay = 0
			else
				local item = RankBoard.items[RankBoard.leader]
				if item ~= nil and item.times[value.checkpoint] ~= nil then
					self.cpTime = value.time - item.times[value.checkpoint].time
					self.delay = 0
				end
			end
			
		end
	end
end

function RankBoard:hide(hide)
	if hide == self.hidden then return end
	
	self.willShow = self.hidden and not hide
	self.hidden = hide
	self.willHide = hide
	
	if not RankBoard.animate then
		self.a = hide and 0 or 1
		self.willHide = false
		self.willShow = false
		return
	end
	if self.animations["a"] ~= nil then destroyAnimation(self.animations["a"]) end
	self.animations["a"] = animate(self.a, hide and 0 or 1, "Linear", 200, function(a)
		self.a = a
	end, function()
		self.willHide = false
		self.willShow = false
		self.animations["a"] = nil
	end)
end

function RankBoard:draw()
	if self.hidden and not self.willHide then return end
	local x = RankBoard.x
	local y = RankBoard.y + self.y
	local w = RankBoard.w
	local w2 = RankBoard.w2
	local h = RankBoard.itemheight
	local p = RankBoard.padding
	local alpha = self.a
	local stateX = x + w + (RankBoard.showIntervals and RankBoard.timeW or 0)
	
	local rankColor = self.rankChange == 0 and tocolor(255,255,255,220*alpha) or self.rankChange > 0 and tocolor(100,255,100,220*alpha) or tocolor(255,100,100,220*alpha)
	
	local teamColor = (alpha>0 and alpha<1) and tocolor(self.colorRGB[1], self.colorRGB[2], self.colorRGB[3], 255*alpha) or self.color
	
	local bgcolor = nil
	local bgalpha = 255 * RankBoard.backgroundOpacity * alpha
	if self.localPlayer then
		bgcolor = self.state == "finished" and tocolor(20,80,20,bgalpha) or tocolor(40,40,40,bgalpha)
	else
		bgcolor = self.state == "finished" and tocolor(0,60,0,bgalpha) or tocolor(0,0,0,bgalpha)
	end
	
	
	dxDrawRectangle(x, y, w + (RankBoard.showIntervals and RankBoard.timeW or 0) + h + p, h, bgcolor)
	
	dxDrawRectangle(x + p, y + p, h - p*2, h - p*2, rankColor)
	dxDrawRectangle(x + h + p, y + p, p*1.5, h - p*2, teamColor)
	dxDrawText(self.rank, x + p, y + p, x + h - p, y + h - p , tocolor(0,0,0, 255*alpha), 1, RankBoard.font,"center", "center",true)
	if RankBoard.showIntervals then 
		local timeWithDelay = self.cpTime + self.delay
		local time = (self.rank == 1) and "Interval" or (math.floor(timeWithDelay) == 0 and "" or timeMsToTimeText(timeWithDelay))
		dxDrawText(time, x + w + p, y + p, x + w + RankBoard.timeW - p, y + h - p , tocolor(200,200,200, 200*alpha), 1, RankBoard.fontSmall,"right", "center",true) 
	end
	
	dxDrawColorText(self.name, x + h + p*5, y + p, x + w - p*5, y + h - p, tocolor(255,255,255, 255*alpha), 1, RankBoard.font,"left", "center",true, alpha)
	
	local stateText = ""
	
	if self.state == "away" then
		stateText = "a"
	elseif self.state == "dead" then
		stateText = "d"
	elseif self.state == "spectating" then
		stateText = "s"
	elseif self.state == "finished" then
		stateText = "f"
	end
	
	if stateText ~= "" then
		dxDrawText(stateText, stateX + p*2, y + p, stateX + h - p, y + h - p, tocolor(255,255,255, 200*alpha), 1, RankBoard.fontState,"center", "center",true)
	end
	
	
	if self.split and self.splitValue ~= "" then
		local splitColor = self.splitValue:sub(1,1) == "+" and tocolor(68,255,68) or tocolor(255,68,68)
		local w2 = dxGetTextWidth(self.splitValue, 1, RankBoard.fontSmall) + p*2
		dxDrawRectangle(x - w2, y, w2, h, tocolor(0,0,0,160*alpha))
		dxDrawText(self.splitValue, x - w2 + p, y + p, x - p, y + h - p , splitColor, 1, RankBoard.fontSmall,"center", "center",true)
	end
	
	if self.rankChangeTime ~= nil and getTickCount() - self.rankChangeTime > 3000 then
		self.rankChangeTime = nil
		self.rankChange = 0
	end
	
	if self.splitTime ~= nil and getTickCount() - self.splitTime > 5000 then
		self.splitTime = nil
		self.splitValue = ""
		--self.split = false
	end
end

function RankBoard.setLine(position)
	if position == 0 then
		RankBoard.linePosition = 0
		return
	end
	
	if position == RankBoard.linePosition then return end
	
	local newY = RankBoard.y + (position * (RankBoard.itemheight))
	
	if RankBoard.animate and RankBoard.linePosition ~= 0 then
		if RankBoard.animations["line"] ~= nil then destroyAnimation(RankBoard.animations["line"]) end
		RankBoard.animations["line"] = animate(RankBoard.lineY, newY, "OutQuad", 300, function(y)
			RankBoard.lineY = y
			
    		end, function()
    			RankBoard.animations["line"] = nil
    		end)
	else
		RankBoard.lineY = newY
	end
	RankBoard.linePosition = position

end

function RankBoard.drawLine()
	if RankBoard.linePosition == 0 then return end
	dxDrawRectangle(RankBoard.x, RankBoard.lineY, RankBoard.w + (RankBoard.showIntervals and RankBoard.timeW or 0) + RankBoard.itemheight + RankBoard.padding, RankBoard.padding, tocolor(255,0,0,200))
	
end

function RankBoard.getScaled(value, round)
	local x = value * RankBoard.scale
	if not round then return x end
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function RankBoard.reset()
	for p, item in pairs(RankBoard.items) do
		setmetatable(RankBoard.items[p], nil)
		RankBoard.items[p] = nil
	end
	for p, item in pairs(RankBoard.sorted) do
		RankBoard.sorted[p] = nil
	end
	RankBoard.sorted = {}
	RankBoard.leader = nil
	for p, item in pairs(RankBoard.bestCPTimes) do
		RankBoard.bestCPTimes[p] = nil
	end
	RankBoard.bestCPTimes = {}
end

function RankBoard.render() 
	for i, player in pairs (RankBoard.sorted) do
		local item = RankBoard.items[player] or nil
		if item ~= nil then item:draw() end
	end
	RankBoard.drawLine()
end

--
-- For temporary processing
--
g_DrawList = {}
g_Rank = nil
g_Checkpoints = {}
g_Speeds = {}
localPlayer = getLocalPlayer()

--
-- Updates the RankBoard - calculates which items should be hidden or shown based on the settings
--
function updateWhiteList()
	local stime = getTickCount()
	for k,v in pairs(g_DrawList) do
		g_DrawList[k] = nil
	end
	
	for k,v in pairs(RankBoard.sorted) do
		RankBoard.sorted[k] = nil
	end
	
	g_Rank = tonumber(getElementData(localPlayer, 'race rank'))
	--g_Rank =myRank
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
	
	local offsetAfter = 0
	local offsetRank = 0
	
	local leaderNextCP = 0
	local leaderTimeToNextCP = 0
	local leaderDistanceToNextCP = 0
	local leaderSpeed = 0
	RankBoard.leader = players[1]
	
	for rank, player in ipairs (players) do
		table.insert(RankBoard.sorted, 1, player)
		local item = RankBoard.items[player]
		local line = false
		local split = false
		if not item then item = RankBoard:create(player) end
		
		if RankBoard.showIntervals and RankBoard.liveIntervals then
			local delay = 0
			local nextCP = item.checkpoint and item.checkpoint + 1 or 1
			local distance  = distanceFromPlayerToCheckpoint(player, nextCP)
			local vehicle = getPedOccupiedVehicle(player)
			
			local speed = vehicle and getElementSpeed(vehicle, 0) or 0
			if not g_Speeds[player] then g_Speeds[player] = {} end
			table.insert(g_Speeds[player], speed)
			if #g_Speeds[player] == 5 then table.remove(g_Speeds[player], 1) end
			speed = mean(g_Speeds[player])
			
			if distance and nextCP > 1 and nextCP <= #g_Checkpoints and item.state == "alive" then
				local timeToNextCP = (distance / (math.floor(speed) ~= 0 and speed or 1))*1000
				
				if rank == 1 then
					leaderNextCP = nextCP
					leaderTimeToNextCP = timeToNextCP
					leaderDistanceToNextCP = distance
					leaderSpeed = speed
				else
					-- someone already passed the next CP
					if RankBoard.bestCPTimes[nextCP] then
						local cpTime = RankBoard.bestCPTimes[nextCP] - RankBoard.bestCPTimes[item.checkpoint]
						local cpSpeed = g_Checkpoints[nextCP].distance / (cpTime / 1000)
						local cpDelay = (distance / cpSpeed)*1000 - timeToNextCP
						delay = (getTickCount() - RankBoard.bestCPTimes[nextCP] + (timeToNextCP)) + cpDelay - item.cpTime
					-- heading for the same CP as the leader
					elseif leaderTimeToNextCP ~= nil and nextCP == leaderNextCP then
						if timeToNextCP < leaderTimeToNextCP then
							local timeToCatchUp = ((distance - leaderDistanceToNextCP) / (speed - leaderSpeed)) * 1000	
							delay = timeToCatchUp - item.cpTime
						else
							delay = (timeToNextCP - leaderTimeToNextCP) - item.cpTime
						end
						
					end
				end
				
				if item.cpTime and delay < item.cpTime * -1 then delay = item.cpTime * -1 + 1 end
				item.delay = delay
			else
				item.delay = 0
			end
		end
		
		if rank <= ranksTop and rank <= g_Rank -- top ranks
		or ranksBefore <= rank and #g_DrawList < lines -- front and back ranks
		or #players - rank < lines - #g_DrawList then
			g_DrawList[#g_DrawList + 1] = { rank = rank, player = player}
			if g_DrawList[#g_DrawList].rank > 1 and g_DrawList[#g_DrawList].rank - g_DrawList[#g_DrawList - 1].rank ~= 1 then
				g_DrawList[#g_DrawList - 1].line = true
				offsetAfter = #g_DrawList - 1 
				offsetRank = rank - offsetAfter
				line = true
			elseif rank <= splitsTop or (g_Rank - splitsBefore <= rank and rank <= g_Rank + splitsBehind) then
				g_DrawList[#g_DrawList].split = true
				split = true
			end
			item:hide(false)
			item:update({offset = offsetRank, rank = rank, line = line, split = split});
		else 
			item:hide(true)
			item:update({offset = 0, rank = rank, split = false})
			
		end
	end
	RankBoard.setLine(offsetAfter) -- Separator line
	local etime = getTickCount()
end

setTimer(updateWhiteList, 333, 0)

--
-- Events
--
function gameModeHandler(gm)
	if allowedGM[gm] then gamemodeAllowed = true
	else gamemodeAllowed = false
	end
end

addEvent("serverSendGM",true)
addEventHandler("serverSendGM",root,gameModeHandler)


addEventHandler("onClientElementDataChange", root, function(dataName, old, new)
	if getElementType(source) ~= "player" or not RankBoard.items[source] then return end
	if dataName == "player state" and RankBoard.items[source].state ~= "finished" then
		RankBoard.items[source]:update({state = new})
	elseif dataName == "vip.colorNick" then
		local name = new or getPlayerName(source)
		local team = getPlayerTeam(source)
		if team then
			local r,g,b = getTeamColor(team)
			RankBoard.items[source].name = RGBToHex(r,g,b) .. name
		else
			RankBoard.items[source].name = name
		end
	end
	
end)

addEvent("onClientPlayerStateChange", true)
addEventHandler("onClientPlayerStateChange", root, function(state)
	if not RankBoard.items[source] or RankBoard.items[source].state == "finished" then return end
	RankBoard.items[source]:update({state = state})
end)

addEventHandler("onClientPlayerQuit", root, function()
	RankBoard.remove(source)
	g_Speeds[source] = nil
	updateWhiteList()
end)

addEventHandler("onClientScreenFadedOut",getRootElement(),function()
	screenFadedOut = true 
end)
addEventHandler("onClientScreenFadedIn",getRootElement(),function() screenFadedOut = false end)


addEventHandler('onClientRender', getRootElement(), function()
	if not isBoardAllowed() then return end
	RankBoard.render()
end)

addCommandHandler('board', function(cmd, args)
	enableBoard = not enableBoard
	outputChatBox((enableBoard and'Showing' or 'Hiding') .. ' ranking board' )
end)

function isBoardAllowed()
	return not screenFadedOut and enableBoard and gamemodeAllowed
end


addEvent('onClientMapStarting', true)
addEventHandler('onClientMapStarting', getRootElement(), 
	function(mapinfo)
		-- reset the board
		RankBoard.reset()
		for player, speed in pairs(g_Speeds) do
			g_Speeds[player] = nil
		end
		g_Speeds = {}
		if showIntervals then
			setTimer(function()
				g_Checkpoints = getAllCheckPoints()
				RankBoard.showIntervals = #g_Checkpoints and showIntervals or false
			end, 4000, 1)
		end
	end
)

addEvent('onClientPlayerReachCheckpoint', true)
addEventHandler('onClientPlayerReachCheckpoint', getRootElement(), 
	function(checkpoint, time)
		if checkpoint == 0 then checkpoint = #g_Checkpoints end
		if RankBoard.items[source] ~= nil then
			RankBoard.items[source]:update({checkpoint = {checkpoint = checkpoint, time = time, tick = getTickCount()}});
		end
	end
)

addEventHandler ( "onClientPlayerChangeNick", getRootElement(),
    function(old, new)
    	if not RankBoard.items[source] then return end
    	RankBoard.items[source].name = (getElementData(source, 'vip.colorNick') or getPlayerName(source))
    end
)


--
-- Utility functions
--
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

function math.round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function RGBToHex(red, green, blue, alpha)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function dxDrawColorText(str, ax, ay, bx, by, color, scale, font, alignX, alignY, clip, alpha)
 
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
		if cap == "" and col then color = tocolor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), 255 * (alpha or 1)) end
		if s ~= 1 or cap ~= "" then
			local w = dxGetTextWidth(cap, scale, font)
			if clip and ax + w > bx then w = w - ( ax + w - bx) end
			dxDrawText(cap, ax, ay, ax + w, by, color, scale, font, nil, nil, clip)
			ax = ax + w  
			color = tocolor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), 255 * (alpha or 1))
		end
		last = e + 1
		s, e, cap, col = str:find(pat, last)
	end
	if last <= #str then
		cap = str:sub(last)
		local w = dxGetTextWidth(cap, scale, font)
		if clip and ax + w > bx then w = w - ( ax + w - bx) end
		dxDrawText(cap, ax, ay, ax + w, by, color, scale, font, nil, nil, clip)
	end
end

function table.concat(a, b)
	c = {}
	n = 0
	for _,v in ipairs(a) do n=n+1; c[n]=v end
	for _,v in ipairs(b) do n=n+1; c[n]=v end
	return c
end


function getAllCheckPoints()
	local result = {}
	for i,element in ipairs(getElementsByType("checkpoint")) do
		result[i] = {}
		result[i].id = getElementID(element) or i
		result[i].nextid = getElementData(element, "nextid") or 0
		result[i].size = getElementData(element,"size") or 4 
		local position = {
			tonumber(getElementData(element,"posX")),
			tonumber(getElementData(element,"posY")),
			tonumber(getElementData(element,"posZ"))
		}
		result[i].position = position;
	end
	
	local prevPos = nil
	for i,checkpoint in pairs(result) do
		if prevPos then
			checkpoint.distance = getDistanceBetweenPoints3D(unpack(table.concat(prevPos, checkpoint.position)))
		end
		prevPos = checkpoint.position
	end
	return result
end

function distanceFromPlayerToCheckpoint(player, i)
	-- TODO: check if the index exists
	local checkpoint = g_Checkpoints[i]
	if checkpoint == nil then
		return false
	end
	local x, y, z = getElementPosition(player)
	return getDistanceBetweenPoints3D(x, y, z, unpack(checkpoint.position)) - (checkpoint.size or 0)
end

function distanceFromPlayerToPlayer(player, player2)
	local x, y, z = getElementPosition(player)
	local x2, y2, z2 = getElementPosition(player2)
	return getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
end

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function mean(t)
  local sum = 0
  local count = 0

  for k,v in pairs(t) do
    if type(v) == 'number' then
      sum = sum + v
      count = count + 1
    end
  end

  return (sum / count)
end

--
-- Exported function for settings menu, KaliBwoy
--
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

function setAnimationsEnabled(enabled)
	animationsEnabled = enabled and true or false
	RankBoard.animate = animationsEnabled
end

function setShowIntervals(enabled, live)
	showIntervals = enabled and true or false
	liveIntervals = live and true or false
	RankBoard.showIntervals = showIntervals
	RankBoard.liveIntervals = liveIntervals
	RankBoard.x = screenX - round((w+40) * scale) - (showIntervals and RankBoard.timeW or 0)
end

function setNumberOfPositions(positions)
	lines = tonumber(positions) and positions or 8
end

function setBackgroudOpacity(value)
	if not tonumber(value) or value < 0 or value > 1 then return end
	RankBoard.backgroundOpacity = value
end

function setBoardScale(value)
	if not tonumber(value) then return end
	scale = value == 0 and round((screenY/800)*10)/10 or value
	RankBoard.scale = scale
	RankBoard.itemheight = round(itemHeight * scale)
	RankBoard.padding = round(itemPadding * scale)
	RankBoard.font = dxCreateFont("fonts/TitilliumWeb-SemiBold.ttf", round(11 * scale)) or "default-bold"
	RankBoard.fontSmall = dxCreateFont("fonts/TitilliumWeb-Regular.ttf", round(11 * scale)) or "default"
	RankBoard.fontState = dxCreateFont("fonts/StateIcons.ttf", round(9 * scale)) or "default"
	RankBoard.timeW = round((dxGetTextWidth("+00:00:00", 1, RankBoard.fontSmall) + itemPadding*2) * scale)
	RankBoard.x = screenX - round((w+40) * scale) - (showIntervals and RankBoard.timeW or 0)
	RankBoard.w = round(w * scale);
end
