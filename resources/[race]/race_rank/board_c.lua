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
showFlags = false
lightenDarkColors = false

y = 200
w = 190
itemHeight = 20
itemPadding = 2

local flagImage = dxCreateTexture("flags.png")
local flagMap = {}
flagMap["ad"] = {0, 0}
flagMap["ae"] = {60, 0}
flagMap["af"] = {120, 0}
flagMap["ag"] = {180, 0}
flagMap["ai"] = {240, 0}
flagMap["al"] = {300, 0}
flagMap["am"] = {360, 0}
flagMap["ao"] = {420, 0}
flagMap["aq"] = {480, 0}
flagMap["ar"] = {540, 0}
flagMap["as"] = {0, 40}
flagMap["at"] = {60, 40}
flagMap["au"] = {120, 40}
flagMap["aw"] = {180, 40}
flagMap["ax"] = {240, 40}
flagMap["az"] = {300, 40}
flagMap["ba"] = {360, 40}
flagMap["bb"] = {420, 40}
flagMap["bd"] = {480, 40}
flagMap["be"] = {540, 40}
flagMap["bf"] = {0, 80}
flagMap["bg"] = {60, 80}
flagMap["bh"] = {120, 80}
flagMap["bi"] = {180, 80}
flagMap["bj"] = {240, 80}
flagMap["bl"] = {300, 80}
flagMap["bm"] = {360, 80}
flagMap["bn"] = {420, 80}
flagMap["bo"] = {480, 80}
flagMap["bq"] = {540, 80}
flagMap["br"] = {0, 120}
flagMap["bs"] = {60, 120}
flagMap["bt"] = {120, 120}
flagMap["bv"] = {180, 120}
flagMap["bw"] = {240, 120}
flagMap["by"] = {300, 120}
flagMap["bz"] = {360, 120}
flagMap["ca"] = {420, 120}
flagMap["cc"] = {480, 120}
flagMap["cd"] = {540, 120}
flagMap["cf"] = {0, 160}
flagMap["cg"] = {60, 160}
flagMap["ch"] = {120, 160}
flagMap["ci"] = {180, 160}
flagMap["ck"] = {240, 160}
flagMap["cl"] = {300, 160}
flagMap["cm"] = {360, 160}
flagMap["cn"] = {420, 160}
flagMap["co"] = {480, 160}
flagMap["cr"] = {540, 160}
flagMap["cu"] = {0, 200}
flagMap["cv"] = {60, 200}
flagMap["cw"] = {120, 200}
flagMap["cx"] = {180, 200}
flagMap["cy"] = {240, 200}
flagMap["cz"] = {300, 200}
flagMap["de"] = {360, 200}
flagMap["dj"] = {420, 200}
flagMap["dk"] = {480, 200}
flagMap["dm"] = {540, 200}
flagMap["do"] = {0, 240}
flagMap["dz"] = {60, 240}
flagMap["ec"] = {120, 240}
flagMap["ee"] = {180, 240}
flagMap["eg"] = {240, 240}
flagMap["eh"] = {300, 240}
flagMap["er"] = {360, 240}
flagMap["es"] = {420, 240}
flagMap["et"] = {480, 240}
flagMap["fi"] = {540, 240}
flagMap["fj"] = {0, 280}
flagMap["fk"] = {60, 280}
flagMap["fm"] = {120, 280}
flagMap["fo"] = {180, 280}
flagMap["fr"] = {240, 280}
flagMap["ga"] = {300, 280}
flagMap["gb"] = {360, 280}
flagMap["gd"] = {420, 280}
flagMap["ge"] = {480, 280}
flagMap["gf"] = {540, 280}
flagMap["gg"] = {0, 320}
flagMap["gh"] = {60, 320}
flagMap["gi"] = {120, 320}
flagMap["gl"] = {180, 320}
flagMap["gm"] = {240, 320}
flagMap["gn"] = {300, 320}
flagMap["gp"] = {360, 320}
flagMap["gq"] = {420, 320}
flagMap["gr"] = {480, 320}
flagMap["gs"] = {540, 320}
flagMap["gt"] = {0, 360}
flagMap["gu"] = {60, 360}
flagMap["gw"] = {120, 360}
flagMap["gy"] = {180, 360}
flagMap["hk"] = {240, 360}
flagMap["hm"] = {300, 360}
flagMap["hn"] = {360, 360}
flagMap["hr"] = {420, 360}
flagMap["ht"] = {480, 360}
flagMap["hu"] = {540, 360}
flagMap["id"] = {0, 400}
flagMap["ie"] = {60, 400}
flagMap["il"] = {120, 400}
flagMap["im"] = {180, 400}
flagMap["in"] = {240, 400}
flagMap["io"] = {300, 400}
flagMap["iq"] = {360, 400}
flagMap["ir"] = {420, 400}
flagMap["is"] = {480, 400}
flagMap["it"] = {540, 400}
flagMap["je"] = {0, 440}
flagMap["jm"] = {60, 440}
flagMap["jo"] = {120, 440}
flagMap["jp"] = {180, 440}
flagMap["ke"] = {240, 440}
flagMap["kg"] = {300, 440}
flagMap["kh"] = {360, 440}
flagMap["ki"] = {420, 440}
flagMap["km"] = {480, 440}
flagMap["kn"] = {540, 440}
flagMap["kp"] = {0, 480}
flagMap["kr"] = {60, 480}
flagMap["kw"] = {120, 480}
flagMap["ky"] = {180, 480}
flagMap["kz"] = {240, 480}
flagMap["la"] = {300, 480}
flagMap["lb"] = {360, 480}
flagMap["lc"] = {420, 480}
flagMap["li"] = {480, 480}
flagMap["lk"] = {540, 480}
flagMap["lr"] = {0, 520}
flagMap["ls"] = {60, 520}
flagMap["lt"] = {120, 520}
flagMap["lu"] = {180, 520}
flagMap["lv"] = {240, 520}
flagMap["ly"] = {300, 520}
flagMap["ma"] = {360, 520}
flagMap["mc"] = {420, 520}
flagMap["md"] = {480, 520}
flagMap["me"] = {540, 520}
flagMap["mf"] = {0, 560}
flagMap["mg"] = {60, 560}
flagMap["mh"] = {120, 560}
flagMap["mk"] = {180, 560}
flagMap["ml"] = {240, 560}
flagMap["mm"] = {300, 560}
flagMap["mn"] = {360, 560}
flagMap["mo"] = {420, 560}
flagMap["mp"] = {480, 560}
flagMap["mq"] = {540, 560}
flagMap["mr"] = {0, 600}
flagMap["ms"] = {60, 600}
flagMap["mt"] = {120, 600}
flagMap["mu"] = {180, 600}
flagMap["mv"] = {240, 600}
flagMap["mw"] = {300, 600}
flagMap["mx"] = {360, 600}
flagMap["my"] = {420, 600}
flagMap["mz"] = {480, 600}
flagMap["na"] = {540, 600}
flagMap["nc"] = {0, 640}
flagMap["ne"] = {60, 640}
flagMap["nf"] = {120, 640}
flagMap["ng"] = {180, 640}
flagMap["ni"] = {240, 640}
flagMap["nl"] = {300, 640}
flagMap["no"] = {360, 640}
flagMap["np"] = {420, 640}
flagMap["nr"] = {480, 640}
flagMap["nu"] = {540, 640}
flagMap["nz"] = {0, 680}
flagMap["om"] = {60, 680}
flagMap["pa"] = {120, 680}
flagMap["pe"] = {180, 680}
flagMap["pf"] = {240, 680}
flagMap["pg"] = {300, 680}
flagMap["ph"] = {360, 680}
flagMap["pk"] = {420, 680}
flagMap["pl"] = {480, 680}
flagMap["pm"] = {540, 680}
flagMap["pn"] = {0, 720}
flagMap["pr"] = {60, 720}
flagMap["ps"] = {120, 720}
flagMap["pt"] = {180, 720}
flagMap["pw"] = {240, 720}
flagMap["py"] = {300, 720}
flagMap["qa"] = {360, 720}
flagMap["re"] = {420, 720}
flagMap["ro"] = {480, 720}
flagMap["rs"] = {540, 720}
flagMap["ru"] = {0, 760}
flagMap["rw"] = {60, 760}
flagMap["sa"] = {120, 760}
flagMap["sb"] = {180, 760}
flagMap["sc"] = {240, 760}
flagMap["sd"] = {300, 760}
flagMap["se"] = {360, 760}
flagMap["sg"] = {420, 760}
flagMap["sh"] = {480, 760}
flagMap["si"] = {540, 760}
flagMap["sj"] = {0, 800}
flagMap["sk"] = {60, 800}
flagMap["sl"] = {120, 800}
flagMap["sm"] = {180, 800}
flagMap["sn"] = {240, 800}
flagMap["so"] = {300, 800}
flagMap["sr"] = {360, 800}
flagMap["ss"] = {420, 800}
flagMap["st"] = {480, 800}
flagMap["sv"] = {540, 800}
flagMap["sx"] = {0, 840}
flagMap["sy"] = {60, 840}
flagMap["sz"] = {120, 840}
flagMap["tc"] = {180, 840}
flagMap["td"] = {240, 840}
flagMap["tf"] = {300, 840}
flagMap["tg"] = {360, 840}
flagMap["th"] = {420, 840}
flagMap["tj"] = {480, 840}
flagMap["tk"] = {540, 840}
flagMap["tl"] = {0, 880}
flagMap["tm"] = {60, 880}
flagMap["tn"] = {120, 880}
flagMap["to"] = {180, 880}
flagMap["tr"] = {240, 880}
flagMap["tt"] = {300, 880}
flagMap["tv"] = {360, 880}
flagMap["tw"] = {420, 880}
flagMap["tz"] = {480, 880}
flagMap["ua"] = {540, 880}
flagMap["ug"] = {0, 920}
flagMap["um"] = {60, 920}
flagMap["us"] = {120, 920}
flagMap["uy"] = {180, 920}
flagMap["uz"] = {240, 920}
flagMap["va"] = {300, 920}
flagMap["vc"] = {360, 920}
flagMap["ve"] = {420, 920}
flagMap["vg"] = {480, 920}
flagMap["vi"] = {540, 920}
flagMap["vn"] = {0, 960}
flagMap["vu"] = {60, 960}
flagMap["wf"] = {120, 960}
flagMap["ws"] = {180, 960}
flagMap["xk"] = {240, 960}
flagMap["ye"] = {300, 960}
flagMap["yt"] = {360, 960}
flagMap["za"] = {420, 960}
flagMap["zm"] = {480, 960}
flagMap["zw"] = {540, 960}
flagMap["pride"] = {0, 1000}
flagMap["trans"] = {60, 1000}

local isAdminResourceRunning = getResourceFromName("admin")
isAdminResourceRunning = isAdminResourceRunning and getResourceState(isAdminResourceRunning) == "running"

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
RankBoard.timeW = round((dxGetTextWidth(" +00:00:00", 1, RankBoard.fontSmall) + itemPadding*2))
RankBoard.x = screenX - round((w+40) * scale) - (showIntervals and RankBoard.timeW or 0)
RankBoard.y = y
RankBoard.w = round(w * scale);
RankBoard.linePosition = 0
RankBoard.lineY = 0
RankBoard.showIntervals = showIntervals
RankBoard.liveIntervals = liveIntervals
RankBoard.showFlags = showFlags
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
        country = getElementData(player, 'specialCountry') or (getElementData(player, 'flag-country') and getElementData(player, 'flag-country').country) or "",
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
    RankBoard.items[player].country = string.lower(RankBoard.items[player].country)
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
				self.a = 0.5
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
	local bgalpha = 255 * RankBoard.backgroundOpacity * (self.state == "dead" and 1 or alpha)
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

	if RankBoard.showFlags and self.country ~= "" and flagMap[self.country] ~= nil then
		local flag = flagMap[self.country]
		dxDrawImageSection(x + w - p - (h - p*2)/40*60, y + p, (h - p*2)/40*60, h - p*2, tonumber(flag[1]), tonumber(flag[2]), 60, 40, flagImage)
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
	RankBoard.linePosition = 0;
end

function RankBoard.render()
	if #RankBoard.sorted == 0 then return end
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
    -- During Clan Wars focus on the player who's 1st to improve spectator players
    if getResourceFromName("cw_script") and getResourceState(getResourceFromName("cw_script")) == "running" and exports.cw_script:getEventMode() == "CW" then
        g_Rank = 1
    end

	if not isBoardAllowed() or not g_Rank then return end

	local players = getElementsByType('player')
    table.sort(players,
    function(a, b)
        local aRank = tonumber(getElementData(a, 'race rank'))
        local bRank = tonumber(getElementData(b, 'race rank'))
        local aState = getElementData(a, "player state")
        local bState = getElementData(b, "player state")

        if not aRank then
            return false
        elseif not bRank then
            return true
        else
            -- Check if a or b is in the "away" state
            local aIsAway = (aState == "away")
            local bIsAway = (bState == "away")

            if aIsAway and not bIsAway then
                return false -- a is "away," b is not
            elseif not aIsAway and bIsAway then
                return true -- b is "away," a is not
            else
                -- Both are either "away" or not, compare ranks
                return aRank < bRank
            end
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
	if dataName == "player state" and (new ~= "dead" or (new == "dead" and RankBoard.items[source].state ~= "finished")) then
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

addEvent('onClientPlayerSetSpecialCountry', true)
addEventHandler("onClientPlayerSetSpecialCountry", getRootElement(),
    function(country)
    	if not RankBoard.items[source] then return end
    	if country ~= "" then
    		RankBoard.items[source].country = country
    	else
    		country = getElementData(source, 'country') or ""
    		RankBoard.items[source].country = string.lower(country)
    	end
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

function RGBToHSV(red, green, blue)
	local hue, saturation, value;

	local min_value = math.min( red, green, blue );
	local max_value = math.max( red, green, blue );

	value = max_value;

	local value_delta = max_value - min_value;
	if max_value ~= 0 then
		saturation = value_delta / max_value;
	else
		saturation = 0;
		hue = 0;
		return hue, saturation, value;
	end

	if red == max_value then
		hue = ( green - blue ) / value_delta;
	elseif green == max_value then
		hue = 2 + ( blue - red ) / value_delta;
	else
		hue = 4 + ( red - green ) / value_delta;
	end

	hue = hue * 60;
	if hue < 0 then
		hue = hue + 360;
	end

	return hue, saturation, value
end

function HSVToRGB(hue, saturation, value)
	if saturation == 0 then
		return value, value, value
	end

	local hue_sector = math.floor( hue / 60 );
	local hue_sector_offset = ( hue / 60 ) - hue_sector;

	local p = value * ( 1 - saturation )
	local q = value * ( 1 - saturation * hue_sector_offset )
	local t = value * ( 1 - saturation * ( 1 - hue_sector_offset ) )

	if hue_sector == 0 then
		return value, t, p
	elseif hue_sector == 1 then
		return q, value, p
	elseif hue_sector == 2 then
		return p, value, t
	elseif hue_sector == 3 then
		return p, q, value
	elseif hue_sector == 4 then
		return t, p, value
	elseif hue_sector == 5 then
		return value, p, q
	end
end

function toNameColor(red, green, blue, alpha)
	if not lightenDarkColors then
		return tocolor(red, green, blue, alpha)
	else
		local h,s,v = RGBToHSV(red, green, blue)
		if v > 180 then
			return tocolor(red, green, blue, alpha)
		else
			local r, g, b = HSVToRGB(h, s, 180)
			return tocolor(r, g, b, alpha)
		end
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
		if cap == "" and col then color = toNameColor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), 255 * (alpha or 1)) end
		if s ~= 1 or cap ~= "" then
			local w = dxGetTextWidth(cap, scale, font)
			if clip and ax + w > bx then w = w - ( ax + w - bx) end
			dxDrawText(cap, ax, ay, ax + w, by, color, scale, font, nil, nil, clip)
			ax = ax + w
			color = toNameColor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), 255 * (alpha or 1))
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

function setShowFlags(enabled)
	showFlags = enabled and true or false
	RankBoard.showFlags = showFlags
end

function setCustomFlag(flag)
	 triggerServerEvent("onPlayerSetSpecialCountry", localPlayer, flag or "")
end

function setLightenDarkColors(enabled)
	lightenDarkColors = enabled and true or false
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
	RankBoard.timeW = round((dxGetTextWidth(" +00:00:00", 1, RankBoard.fontSmall) + itemPadding*2))
	RankBoard.x = screenX - round((w+40) * scale) - (showIntervals and RankBoard.timeW or 0)
	RankBoard.w = round(w * scale);
end
