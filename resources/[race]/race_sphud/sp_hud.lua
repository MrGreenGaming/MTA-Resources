local g_Me = getLocalPlayer()
local g_NewHudEnabled = false
local g_MapRunning = true
local g_Spectating = false
local g_hud = false
local g_radar = false

local g_StartTick = nil
local g_Duration = nil
g_FadedIn = true
local sx,sy = guiGetScreenSize()

local totalCheckpoints = 0

-- toggling the hud --
function showHud (hud)
	hud = tonumber(hud)
	if hud and hud > 0 then
		if not g_NewHudEnabled then
			addEventHandler('onClientRender',root,drawNewHUD)
		end
		g_NewHudEnabled = true
		hideRaceHUD(true)
		if getResourceFromName'gc' and getResourceState(getResourceFromName'gc' ) == 'running' then
			exports.gc:toggleGCInfo(false)
		end
		-- executeCommandHandler('mode','none')
		if getResourceFromName'fps' and getResourceState(getResourceFromName'fps' ) == 'running' then
			exports.fps:enableFPS(false)
		end
		g_hud = hud
		if getResourceFromName('race') and getResourceState(getResourceFromName'race' ) == 'running' then
			g_StartTick = exports.race:getStartTick()
		end
	else
		g_NewHudEnabled = false
		g_hud = false
		removeEventHandler('onClientRender',root,drawNewHUD)
		hideRaceHUD(false)
		if getResourceFromName'gc' and getResourceState(getResourceFromName'gc' ) == 'running' then
			exports.gc:toggleGCInfo(true)
		end
		if getResourceFromName'fps' and getResourceState(getResourceFromName'fps' ) == 'running' then
			exports.fps:enableFPS(true)
		end
	end
	-- outputChatBox('New hud ' .. (g_NewHudEnabled and 'enabled' or 'disabled') .. '!')
end

addCommandHandler('sphud', function(cmd, b)
	showHud(b == '0' and 0 or 2)
	if cmd then
		outputChatBox( (g_NewHudEnabled and 'Showing' or 'Hiding') .. ' split second hud')
		local g_conf = xmlLoadFile ( 'hud.conf' )
		local hudnode = xmlFindChild ( g_conf, 'hud', 0)
		xmlNodeSetAttribute ( hudnode, 'type', b == '0' and 0 or 2 )
		xmlSaveFile(g_conf)
		xmlUnloadFile(g_conf)
	end
end)

addCommandHandler('hud', function(cmd, b)
	showHud(b == '0' and 0 or 1)
	if cmd then
		outputChatBox( (g_NewHudEnabled and 'Showing' or 'Hiding') .. ' new hud')
		local g_conf = xmlLoadFile ( 'hud.conf' )
		local hudnode = xmlFindChild ( g_conf, 'hud', 0)
		xmlNodeSetAttribute ( hudnode, 'type', b == '0' and 0 or 1 )
		xmlSaveFile(g_conf)
		xmlUnloadFile(g_conf)
	end
end)

function showRadar(cmd, show)
	if tonumber(show) == 1 then
		setPlayerHudComponentVisible('radar', false)
		g_radar = true
	else
		g_radar = false
		setPlayerHudComponentVisible('radar', true)
	end
	if cmd then
		outputChatBox( (g_radar and 'Showing' or 'Hiding') .. ' radar')
		local g_conf = xmlLoadFile ( 'hud.conf' )
		local radarnode = xmlFindChild ( g_conf, 'radar', 0)
		xmlNodeSetAttribute ( radarnode, 'enabled', g_radar and 1 or 0 )
		xmlSaveFile(g_conf)
		xmlUnloadFile(g_conf)
	end
end
addCommandHandler('sradar', showRadar, true)

function onStart()
	local g_conf
	if not fileExists('hud.conf') then
		local def = xmlLoadFile ( 'def.conf' )
		g_conf = xmlCopyFile(def, 'hud.conf')
		xmlSaveFile(g_conf)
	else
		g_conf = xmlLoadFile ( 'hud.conf' )
	end
	local radarnode = xmlFindChild ( g_conf, 'radar', 0)
	local radar = tonumber(xmlNodeGetAttribute ( radarnode, 'enabled' ))
	local hudnode = xmlFindChild ( g_conf, 'hud', 0)
	local hud = tonumber(xmlNodeGetAttribute ( hudnode, 'type' ))
	totalCheckpoints = #exports.race:getCheckPoints() or 1;
	xmlUnloadFile(g_conf)
	showHud(hud)
	showRadar(nil, radar)
end
addEventHandler('onClientResourceStart', resourceRoot, onStart)


-- hide race hud (without changing the race mode, it needs to be send to serverside first)
function hideRaceHUD(hide)
	if not (getResourceFromName('race') and getResourceState(getResourceFromName'race' ) == 'running') then return end
	if hide == true then
		triggerEvent('onClientCall_race', getResourceRootElement( getResourceFromName('race')), 'hideGUIComponents', 'timepassed', 'healthbar', 'speedbar', 'ranknum', 'ranksuffix', 'checkpoint', 'timeleftbg', 'timeleft')
	else
		triggerEvent('onClientCall_race', getResourceRootElement( getResourceFromName('race')), 'showGUIComponents', 'timepassed', 'healthbar', 'speedbar', 'ranknum', 'ranksuffix', 'checkpoint', 'timeleftbg', 'timeleft')
	end
end

addEvent('onClientMapStarting'); addEvent('onClientMapStopping'); addEvent('onClientMapLaunched'); addEvent('onClientMapTimeLeft');
addEvent('onClientCall_race', true);
addEvent('onClientMapTimeLeft');
addEventHandler('onClientMapStarting', root, function(mapinfo, mapoptions)
	g_MapRunning = true
	g_StartTick = nil
	g_Duration = nil
	totalCheckpoints = #exports.race:getCheckPoints() or 1;
	if g_NewHudEnabled then
		-- outputChatBox('hiding default hud')
		setTimer(hideRaceHUD, 50, 1, true)
	end
	if g_radar then
		setPlayerHudComponentVisible('radar', false)
	end
end)

addEventHandler('onClientMapLaunched', root, function(start, duration)
	g_StartTick = start
	g_Duration = duration
	if g_NewHudEnabled == true and g_Duration > 60 * 1000 then
		triggerEvent('onClientCall_race', getResourceRootElement( getResourceFromName('race')), 'hideGUIComponents', 'timeleftbg', 'timeleft')
	end
	totalCheckpoints = #exports.race:getCheckPoints() or 1;
end)

addEventHandler('onClientMapTimeLeft', root, function( duration)
	g_Duration = duration
end)

addEventHandler('onClientMapStopping', root, function()
	g_MapRunning = false
end)

addEventHandler('onClientScreenFadedIn', root, function()
	g_FadedIn = true
	totalCheckpoints = #exports.race:getCheckPoints() or 1;
end)

addEventHandler('onClientScreenFadedOut', root, function()
	g_FadedIn = false
end)

addEventHandler('onClientResourceStop', resourceRoot, hideRaceHUD)
addEventHandler('onClientResourceStop', resourceRoot, function() showRadar() end)


-- drawing it onto the screen and handling data from ingame
-- Throttle/cache setup
local lastPlayerCountUpdate = 0
local cachedPlayerCount = 1

local lastDataUpdate = 0
local cachedData = {}

function drawNewHUD()
	if not (getResourceFromName('race') and getResourceState(getResourceFromName('race')) == 'running') then
		return
	end

	-- Time left HUD
	if g_Duration and g_StartTick and getTickCount() > (g_StartTick + g_Duration - 60000) then
		triggerEvent('onClientCall_race', getResourceRootElement(getResourceFromName('race')), 'showGUIComponents', 'timeleftbg', 'timeleft')
		g_Duration = nil
	end

	local target = exports.race:getWatchedPlayer() or localPlayer
	local g_Veh = getPedOccupiedVehicle(target)

	if not isVehicle(g_Veh) or not g_FadedIn then return end

	local tick = getTickCount()

	-- Throttle player count update (every 1 second)
	if tick - lastPlayerCountUpdate > 1000 then
		cachedPlayerCount = #getElementsByType('player') or 1
		lastPlayerCountUpdate = tick
	end

	-- Throttle heavy data updates (every 200ms)
	if tick - lastDataUpdate > 200 then
		cachedData.rank = getElementData(target, 'race rank')
		cachedData.currentCheckpoint = (getElementData(target, 'race.checkpoint') or 1) - (getElementData(target, 'race.finished') and 0 or 1)
		cachedData.currentLap = getElementData(target, 'race.lap')
		cachedData.totalLaps = getElementData(target, 'race.totalLaps')
		cachedData.health = math.ceil((getElementHealth(g_Veh) - 250) / 7.5)
		lastDataUpdate = tick
	end

	-- Select HUD mode
	if g_hud ~= 1 then
		if not isElementOnScreen(g_Veh) then return end

		local g_VehType = getVehicleType(g_Veh)
		local minX, minY, _, _, _, _ = getElementBoundingBox(g_Veh)
		if not minX then return end

		local z0 = getElementDistanceFromCentreOfMassToBaseOfModel(g_Veh) or 0
		local x, y, z

		if g_VehType == 'Helicopter' or g_VehType == 'Plane' then
			x, y, z = getPositionRelativeToElement(g_Veh, 0, 0, -z0)
		else
			x, y, z = getPositionRelativeToElement(g_Veh, 0, minY * 2/3, -z0 * 2/3)
		end

		local a, b = getScreenFromWorldPosition(x, y, z, 100, true)
		if a and b then
			a, b = math.floor(a), math.floor(b)
			return drawStuff(a, b, g_Veh, cachedData.rank, cachedPlayerCount, cachedData.currentCheckpoint, totalCheckpoints, cachedData.health, 1)
		end
	else
		return drawIVHud(target, g_Veh, cachedData.rank, cachedPlayerCount, cachedData.currentCheckpoint, totalCheckpoints, g_StartTick, cachedData.currentLap, cachedData.totalLaps)
	end
end


local width = dxGetTextWidth ( "CHECKPOINT 999/999", 0.6, 'bankgothic' ) / sx

function isRadarActivated()
	return g_FadedIn and g_radar and true or false
end

local g_RankFade = {
	prevRank = false,
	mode = false,
	time = 1000,
	scale = 2.0,
	startTick

}

local g_CheckpointFade = {
	prevCP = false,
	mode = false,
	time = 1000,
	scale = 2.0,
	startTick

}

local coolvetica = dxCreateFont ( 'files/coolvetica_rg.ttf', 50 )
local lastUpdateTick = 0
local cachedTeamColor = {}
local cachedDataWidth = nil
local cachedFontHeight = nil
local cachedLabelScale = nil
local cachedLayout = {}

function drawIVHud(player, g_Veh, rank, players, currentCheckpoint, totalCheckpoints, g_StartTick, currentLap, totalLaps)
	local now = getTickCount()
	if now - lastUpdateTick > 500 then
		lastUpdateTick = now

		local font = 'bankgothic'
		local dataScale = 1.0
		local labelScaleRatio = 0.7
		local labelWidth = 0.150
		local labelOffsetX = 0.015

		cachedDataWidth = dxGetTextWidth('88:88:88', dataScale, font) / sx
		cachedFontHeight = dxGetFontHeight(dataScale, font) / sy
		cachedLabelScale = labelScaleRatio * dataScale

		local x = 0.99
		local l = sx * (x - labelWidth - cachedDataWidth - labelOffsetX)
		local m = sx * (x - cachedDataWidth - labelOffsetX)
		local r = sx * x
		local w = sx * (cachedDataWidth + labelOffsetX)
		local wl = sx * labelWidth
		local h = sy * cachedFontHeight
		local rightBorder = 0.01 * sx

		cachedLayout = { l = l, m = m, r = r, w = w, wl = wl, h = h, rightBorder = rightBorder }

		local team = getPlayerTeam(player)
		if team then
			local r, g, b = getTeamColor(team)
			cachedTeamColor = { r, g, b }
		else
			cachedTeamColor = { 0, 0, 0 }
		end
	end

	local x, y = 0.99, 0.95
	local dy = 0.005
	local dataScale = 1.0
	local font = 'bankgothic'
	local textColor = tocolor(225, 225, 225, 240)
	local backAlpha = 150
	local backColor = tocolor(cachedTeamColor[1], cachedTeamColor[2], cachedTeamColor[3], backAlpha)
	local l, m, r = cachedLayout.l, cachedLayout.m, cachedLayout.r
	local w, h, rightBorder = cachedLayout.w, cachedLayout.h, cachedLayout.rightBorder
	local fontHeight = cachedFontHeight
	local labelScale = cachedLabelScale

	local function drawBar(yOffset, label, valueText, bgColor)
		local t = sy * (y - fontHeight * yOffset - dy * (yOffset - 1))
		local b = t + h
		dxDrawRectangle(m + 1, t, w + rightBorder, h, bgColor or backColor)
		dxDrawText(valueText, m, t, r, b, textColor, dataScale, font, "right", "bottom", false, false, false, false, true)
		for i = math.floor(l), math.floor(m) do
			local a = backAlpha * (i - l) / (m - l)
			dxDrawRectangle(i, t, 1, h, tocolor(cachedTeamColor[1], cachedTeamColor[2], cachedTeamColor[3], a))
		end
		dxDrawText(label, l, t, m, b, textColor, labelScale, font, "right", "center", false, false, false, false, true)
	end

	-- TIME
	local msPassed = g_StartTick and (getTickCount() - g_StartTick) or 0
	local min, sec, ms = msToTime(msPassed)
	drawBar(1, "TIME", string.format("%02d:%02d.%02d", min, sec, ms))

	-- POSITION
	if tonumber(rank) then
		drawBar(2, "POSITION", string.format("%d / %d", rank, players))
	elseif exports.race:getRaceMode() == 'Capture the flag' then
		local sFlags = (getElementData(getTeamFromName('Blue team'), 'ctf.points') or 0) .. ' / 3'
		drawBar(2, "BLUE FLAGS", sFlags, tocolor(0, 0, 255, backAlpha))
	end

	-- Checkpoint, Laps, or Kills
	if totalCheckpoints and totalCheckpoints > 0 and not totalLaps then
		drawBar(3, "CHECKPOINT", string.format("%d / %d", currentCheckpoint, totalCheckpoints))
	elseif totalLaps then
		drawBar(3, "LAP", string.format("%d / %d", currentLap or 1, totalLaps))

		local bestLap = getElementData(player, "race.bestlap") or 0
		local bmin, bsec, bms = msToTime(bestLap)
		drawBar(4, "BEST LAP", string.format("%02d:%02d.%03d", bmin, bsec, bms))
	elseif exports.race:getRaceMode() == 'Shooter' or exports.race:getRaceMode() == 'Destruction derby' or exports.race:getRaceMode() == 'Deadline' then
		local sKills = getElementData(player, 'kills') or 0
		drawBar(3, "KILLS", tostring(sKills))
	elseif exports.race:getRaceMode() == 'Capture the flag' then
		local sFlags = (getElementData(getTeamFromName('Red team'), 'ctf.points') or 0) .. ' / 3'
		drawBar(3, "RED FLAGS", sFlags, tocolor(255, 0, 0, backAlpha))
	end
end


function drawStuff ( x, y, g_Veh, rank, players, currentCheckpoint, totalCheckpoints, health, speedMode )
	local scale = 1.25
	local font = 'bankgothic'
	local clip = true
	local wordBreak = false
	local postGUI = false
	local inlineColor = { 255, 255, 255, 255 }
	local outlineSize = 2
	local outlineColor = { 19, 241, 255, 100 }
	local outlineColor2 = { 255, 000, 000, 100 }

	local midx, midy = x, y
	local width = 400
	local heigth = dxGetFontHeight(scale, font)
	local left = midx - math.floor(width/2)
	local top = midy - heigth
	local right = midx + math.floor(width/2)
	local bottom = midy + heigth

	drawRank ( rank, players, left, top , right, midy, scale, font, 'left', 'center', inlineColor, outlineSize, outlineColor, outlineColor2 )

	drawCheckpoint ( currentCheckpoint, totalCheckpoints, left, top , right, midy, scale, font, 'right', 'center', inlineColor, outlineSize, outlineColor, outlineColor2 )

	drawSpeed ( g_Veh, speedMode, left, midy , midx, bottom, scale * 0.8, font, 'center', 'center', inlineColor, outlineSize, outlineColor, outlineColor2 )

	drawHealth ( health, midx, midy , right, bottom, scale * 0.8, font, 'center', 'center', inlineColor, outlineSize, outlineColor, outlineColor2 )

end

function drawRank ( rank, players, l, t, r, b, scale, font, alignX, alignY, inlineColor, outlineSize, outlineColor, outlineColor2 )

	if type(rank) ~= 'number' then return end
	local rankText, rankScale = tostring(rank)		, 1.1
		local suffix = ((rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th')
	local suffText, suffScale = tostring(suffix)	, 0.8
	local playText, playScale = ' / ' .. players	, 0.8

	local rankWidth = 		  0 + dxGetTextWidth( rankText, scale * rankScale, font ) + 2 * outlineSize
	local suffWidth = rankWidth + dxGetTextWidth( suffText, scale * suffScale, font ) + 2 * outlineSize
	local playWidth = suffWidth + dxGetTextWidth( playText, scale * playScale, font ) + 2 * outlineSize

	dxDrawTextWithBorder ( rankText, l + 0, 		t, l + rankWidth, b, tcft(inlineColor), scale * rankScale, font, 'left',   'top', true, false, false, outlineSize, tcft(outlineColor2) )
	dxDrawTextWithBorder ( suffText, l + rankWidth, t, l + suffWidth, b, tcft(inlineColor), scale * suffScale, font, 'center', 'top', true, false, false, outlineSize, tcft(outlineColor) )
	-- dxDrawTextWithBorder ( playText, l + suffWidth, t, l + playWidth, b, inlineColor, scale * playScale, font, 'center', 'top', true, false, false, outlineSize, outlineColor )


	if rank ~= g_RankFade.prevRank then
		if g_RankFade.prevRank then
			g_RankFade.mode = true
			g_RankFade.startTick = getTickCount()
		end
		g_RankFade.prevRank = rank
	end

	if g_RankFade.mode then
		local progress = ( getTickCount() - g_RankFade.startTick ) / g_RankFade.time

		local fadeWidth = dxGetTextWidth ( rankText, scale * rankScale * g_RankFade.scale, font )
		local fadeHeigth = dxGetFontHeight ( scale * rankScale * g_RankFade.scale, font )
		local fade_l = ( l + rankWidth / 2 ) - fadeWidth / 2
		local fade_t = ( t + (b-t) / 2 ) - fadeHeigth / 2
		local fade_r = ( l + rankWidth / 2 ) + fadeWidth / 2
		local fade_b = ( t + (b-t) / 2 ) + fadeHeigth / 2

		local fade_color = table.deepcopy(outlineColor2)
			fade_color[4] = 255
		if progress >= 0.5 then
			fade_color[4] = math.clamp(0, fade_color[4] - 255 * ( (progress - 0.5) * 2 ), 255)

		end
		local fade_scale = scale + progress * (g_RankFade.scale * scale - scale)

		dxDrawText ( rankText, fade_l, fade_t, fade_r, fade_b, tcft(fade_color), fade_scale, font, 'center', 'center', true, false, false )
		-- dxDrawRectangleFrame ( fade_l, fade_t, fade_r, fade_b, tcft(fade_color), 2 )
		if progress >= 1 then
			g_RankFade.mode = false
		end
	end

	-- local text = '|' .. rank .. suffix .. ' / ' .. players .. '|'
	-- local w = dxGetTextWidth( text, scale, font )
	-- dxDrawRectangleFrame ( l, t, l + w, b, outlineColor, 2 )

end

function drawCheckpoint ( currentCheckpoint, totalCheckpoints, l, t, r, b, scale, font, alignX, alignY, inlineColor, outlineSize, outlineColor, outlineColor2 )
	local text = currentCheckpoint .. ' / ' .. totalCheckpoints
	dxDrawTextWithBorder ( text, l, t, r, b, tcft(inlineColor), scale, font, 'right', 'center', true, false, false, outlineSize, tcft(outlineColor) )
end

function drawSpeed ( veh, speedMode, l, t, r, b, scale, font, alignX, alignY, inlineColor, outlineSize, outlineColor, outlineColor2 )
	--speedMode: 1-KMh 2-MPh 3-Knots
	speedMode = ((speedMode == 2) and 2) or 1

	local vehtype = getVehicleType(veh)
	if (vehtype == 'Boat') or (vehtype == 'Helicopter') or (vehtype == 'Plane') then
		speedMode = 3
	end
	local speed = (getDistanceBetweenPoints3D(0,0,0,getElementVelocity(veh)) or 0 )
	speed = speed * 100 * (speedMode == 1 and 1.61 or 1) * (speedMode == 3 and 1/1.15 or 1)
	speed = math.floor(speed)

	local text = speed .. ' ' .. (speedMode == 1 and 'KMh' or '') .. (speedMode == 2 and 'MPh' or '') .. (speedMode == 3 and 'Knots' or '')
	dxDrawTextWithBorder ( text, l, t, r, b, tcft(inlineColor), scale, font, 'center', 'center', true, false, false, outlineSize, tcft(outlineColor) )
end

function drawHealth ( health, l, t, r, b, scale, font, alignX, alignY, inlineColor, outlineSize, outlineColor, outlineColor2 )
	local text
		text = math.clamp ( 0, health, 100 ) .. '%'
		dxDrawTextWithBorder ( text, l, t, r, b, tcft(inlineColor), scale, font, 'center', 'center', true, false, false, outlineSize, tcft(outlineColor) )
end


--[[
	Utils
--]]

function isVehicle(element)
	return isElement(element) and (getElementType(element) == 'vehicle')
end

function getSpeedString(car, mode)
	local modeData = {
		[1] = {
			-- kmh
			multiplier = 161,
			suffix = 'KMh'
		},
		[2] = {
			-- mph
			multiplier = 100,
			suffix = 'MPh'
		},
		[3] = {
			-- knots
			multiplier = 100/1.15,
			suffix = 'Knots'
		}
	}
	mode = ((mode == 2) and 2) or 1
	if car then
		local vehtype = getVehicleType(car)
		if (vehtype == 'Plane') or (vehtype == 'Boat') or (vehtype == 'Helicopter') then
			mode = 3
		end
		local speed = (getDistanceBetweenPoints3D(0,0,0,getElementVelocity(car)) or 0 ) * (tonumber(modeData[mode].multiplier) or 100)
		speed = math.floor(speed)
		return speed .. ' ' .. tostring(modeData[mode].suffix)
	end
end

function getPositionRelativeToElement(element, rx, ry, rz)
	-- Some magic
    local matrix = getElementMatrix (element)
    local offX = rx * matrix[1][1] + ry * matrix[2][1] + rz * matrix[3][1] + matrix[4][1]
    local offY = rx * matrix[1][2] + ry * matrix[2][2] + rz * matrix[3][2] + matrix[4][2]
    local offZ = rx * matrix[1][3] + ry * matrix[2][3] + rz * matrix[3][3] + matrix[4][3]
    return offX, offY, offZ
end

function math.clamp ( lowClamp, val, highClamp )
	return math.min(math.max(val, lowClamp), highClamp)
end

function table.deepcopy(t)
	local known = {}
	local function _deepcopy(t)
		local result = {}
		for k,v in pairs(t) do
			if type(v) == 'table' then
				if not known[v] then
					known[v] = _deepcopy(v)
				end
				result[k] = known[v]
			else
				result[k] = v
			end
		end
		return result
	end
	return _deepcopy(t)
end

function tcft ( table )
	--to color from table
	return tocolor(unpack(table))
end

function dxDrawTextWithBorder ( text, l, t, r, b, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, outlineSize, outlineColor, subPixelPositioning )
	if type(outlineSize) == 'number' and outlineSize > 0 then
		for offsetX=-outlineSize,outlineSize,outlineSize do
			for offsetY=-outlineSize,outlineSize,outlineSize do
				if not (offsetX == 0 and offsetY == 0) then
					dxDrawText(text, l + offsetX, t + offsetY, r + offsetX, b + offsetY, outlineColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, subPixelPositioning )
				end
			end
		end
	end
	dxDrawText ( text, l, t, r, b, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, subPixelPositioning )
end

function dxDrawRectangleFrame ( l, t, r, b, color, width, postGUI )
	dxDrawLine(l, t, r, t, color, width, postGUI )
	dxDrawLine(l, b, r, b, color, width, postGUI )
	dxDrawLine(l, t, l, b, color, width, postGUI )
	dxDrawLine(r, t, r, b, color, width, postGUI )
end

function msToTime(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	if #minutes == 1 then
		minutes = '0' .. minutes
	end
	return minutes, seconds, centiseconds
end

function isPlayerFinished(player)
	return getElementData(player, 'race.finished')
end

-- executeCommandHandler('sphud', '2')

-- Exported functions for settings menu , KaliBwoy


function e_showSPhud()
	showHud(2)

	local g_conf = xmlLoadFile ( 'hud.conf' )
	local hudnode = xmlFindChild ( g_conf, 'hud', 0)
	xmlNodeSetAttribute ( hudnode, 'type', 2 )
	xmlSaveFile(g_conf)
	xmlUnloadFile(g_conf)

end

function e_showNewhud()
	showHud(1)
	local g_conf = xmlLoadFile ( 'hud.conf' )
	local hudnode = xmlFindChild ( g_conf, 'hud', 0)
	xmlNodeSetAttribute ( hudnode, 1 )
	xmlSaveFile(g_conf)
	xmlUnloadFile(g_conf)

end


function e_showOldhud()
	showHud(0)
	local g_conf = xmlLoadFile ( 'hud.conf' )
	local hudnode = xmlFindChild ( g_conf, 'hud', 0)
	xmlNodeSetAttribute ( hudnode, 0 )
	xmlSaveFile(g_conf)
	xmlUnloadFile(g_conf)

end


function e_showRadar()

		setPlayerHudComponentVisible('radar', false)
		g_radar = true



		local g_conf = xmlLoadFile ( 'hud.conf' )
		local radarnode = xmlFindChild ( g_conf, 'radar', 0)
		xmlNodeSetAttribute ( radarnode, 'enabled', 1 )
		xmlSaveFile(g_conf)
		xmlUnloadFile(g_conf)

end


function e_hideRadar()
		g_radar = false
		setPlayerHudComponentVisible('radar', true)
		local g_conf = xmlLoadFile ( 'hud.conf' )
		local radarnode = xmlFindChild ( g_conf, 'radar', 0)
		xmlNodeSetAttribute ( radarnode, 'enabled', 0 )
		xmlSaveFile(g_conf)
		xmlUnloadFile(g_conf)

end
