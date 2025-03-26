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
	totalCheckpoints = (#(exports.race:getCheckPoints() or {}) or 1) 
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
end)

addEventHandler('onClientMapTimeLeft', root, function( duration)
	g_Duration = duration
end)

addEventHandler('onClientMapStopping', root, function()
	g_MapRunning = false
end)

addEventHandler('onClientScreenFadedIn', root, function()
	g_FadedIn = true
	totalCheckpoints = (#(exports.race:getCheckPoints() or {}) or 1)
end)

addEventHandler('onClientScreenFadedOut', root, function()
	g_FadedIn = false
end)

addEventHandler('onClientResourceStop', resourceRoot, hideRaceHUD)
addEventHandler('onClientResourceStop', resourceRoot, function() showRadar() end)


-- drawing it onto the screen and handling data from ingame
function drawNewHUD()
	if not(getResourceFromName'race' and getResourceState(getResourceFromName'race') == 'running') then
		return
	end

	if g_Duration and g_StartTick and getTickCount() > (g_StartTick + g_Duration - 60 * 1000) then
		triggerEvent('onClientCall_race', getResourceRootElement( getResourceFromName('race')), 'showGUIComponents', 'timeleftbg', 'timeleft')
		g_Duration = nil
	end

	local target = exports.race:getWatchedPlayer() or localPlayer
	local g_Veh = getPedOccupiedVehicle(target)

	if not ( isVehicle(g_Veh)) or not g_FadedIn then return end
	local rank = getElementData(target,'race rank')
	local players = #getElementsByType('player') or 1
	local currentCheckpoint = (getElementData(target, 'race.checkpoint') or 1) - ((getElementData(target, 'race.finished') and 0) or 1)
    local currentLap = (getElementData(target, 'race.lap') or nil)
    local totalLaps = (getElementData(target, "race.totalLaps") or nil)
	local health = math.ceil((getElementHealth(g_Veh) - 250) / 7.50)
	if g_hud ~= 1 then
		if not ( isVehicle(g_Veh) and isElementOnScreen(g_Veh) ) then return end
		local g_VehType = getVehicleType(g_Veh)

		local minX,minY,minZ,maxX,maxY,maxZ = getElementBoundingBox(g_Veh)
		if not minX then return end

		local z0 = getElementDistanceFromCentreOfMassToBaseOfModel(g_Veh) or 0
		local x,y,z
		if g_VehType == 'Helicopter' or g_VehType == 'Plane' then
			x,y,z = getPositionRelativeToElement(g_Veh, 0, 0, -z0)
		else
			x,y,z = getPositionRelativeToElement(g_Veh, 0, minY * 2/3, -z0 * 2/3)
		--												+E/-W, +N/-S, +U/-D
		end
		local a, b = getScreenFromWorldPosition(x, y, z, 100, true)

		if a and b then
			a,b = math.floor(a), math.floor(b)
			local rank = getElementData(target,'race rank')
			local players = #getElementsByType('player') or 1
			local currentCheckpoint = (getElementData(target, 'race.checkpoint') or 1) - ((getElementData(target, 'race.finished') and 0) or 1)
			local health = math.ceil((getElementHealth(g_Veh) - 250) / 7.50)
			local speedMode = 1

			return drawStuff ( a, b, g_Veh, rank, players, currentCheckpoint, totalCheckpoints, health, speedMode)
		end
	else
		return drawIVHud (target, g_Veh, rank, players, currentCheckpoint, totalCheckpoints, g_StartTick, currentLap, totalLaps)
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

function drawIVHud2 (player, g_Veh, rank, players, currentCheckpoint, totalCheckpoints, g_StartTick)
	local x = 0.98
	local w = math.max(0.12, width)
	local h = 0.04
	local xb = 0.01
	local scaleTxt = 0.6 *2
	local scaleData = 0.8 *2
	local scaleData2nd = 0.65 *2
	rank = tonumber(rank)

	if type(totalCheckpoints) == 'number' and totalCheckpoints > 0 then
		local ckp = {x = x, w = w, y = .8, h = h, xb = xb }
		dxDrawRectangle ( (ckp.x - ckp.xb - ckp.w) * sx, ckp.y * sy, (ckp.w + ckp.xb * 2) * sx , ckp.h * sy, tocolor ( 0 ,0,0,150))
		local sPosition = currentCheckpoint
		local sCPS = ' / ' .. tonumber(totalCheckpoints)
		dxDrawTextWithBorder ( 'CHECKPOINT', (ckp.x - ckp.w) * sx, ckp.y * sy, ckp.x * sx, (ckp.y + ckp.h) * sy, tocolor(255,255,255), scaleTxt, 'arial', "left", "center", true, false, false, 1, tocolor(0,0,0) )
		dxDrawTextWithBorder ( sPosition   , (ckp.x - ckp.w) * sx, ckp.y * sy, ckp.x * sx - dxGetTextWidth ( sCPS, scaleData2nd, 'arial' ), (ckp.y + ckp.h) * sy, tocolor(255,255,255), scaleData, 'arial', "right", "center", true, false, false, 1, tocolor(0,0,0) )
		dxDrawTextWithBorder ( sCPS   , (ckp.x - ckp.w) * sx, ckp.y * sy, ckp.x * sx, (ckp.y + ckp.h) * sy, tocolor(200,200,200), scaleData2nd, 'arial', "right", "center", true, false, false, 1, tocolor(0,0,0) )

		if player == localPlayer and currentCheckpoint ~= g_CheckpointFade.prevCP then
			if g_CheckpointFade.prevCP and currentCheckpoint > g_CheckpointFade.prevCP then
				g_CheckpointFade.mode = true
				g_CheckpointFade.startTick = getTickCount()
			end
			g_CheckpointFade.prevCP = currentCheckpoint
		end

		if g_CheckpointFade.mode then
			local scale = scaleData
			local progress = ( getTickCount() - g_CheckpointFade.startTick ) / g_CheckpointFade.time

			local posWidth = dxGetTextWidth ( sPosition , scale, 'arial' )
			local posHeigth = dxGetFontHeight ( scale, 'arial' )
			local fadeWidth = dxGetTextWidth ( sPosition, scale * g_CheckpointFade.scale, 'arial' )
			local fadeHeigth = dxGetFontHeight ( scale * g_CheckpointFade.scale, 'arial' )

			local fade_l = ( (ckp.x - ckp.w) * sx + posWidth / 2 ) - fadeWidth / 2
			local fade_t = ( ckp.y * sy + posHeigth / 2 ) - fadeHeigth / 2
			local fade_r = ( (ckp.x) * sx - dxGetTextWidth ( sCPS, scaleData2nd, 'arial' ) - posWidth / 2 ) + fadeWidth / 2
			local fade_r = (ckp.x) * sx - dxGetTextWidth ( sCPS, scaleData2nd, 'arial' )
			local fade_b = ( (ckp.y + ckp.h) * sy - posHeigth / 2 ) + fadeHeigth / 2

			local fade_color = {255,255,255,255}
				fade_color[4] = 255
			if progress >= 0.5 then
				fade_color[4] = math.clamp(0, fade_color[4] - 255 * ( (progress - 0.5) * 2 ), 255)

			end
			local fade_scale = scale + progress * (g_CheckpointFade.scale * scale - scale)

			-- dxDrawText ( sPosition, fade_l, fade_t, fade_r, fade_b, tcft(fade_color), fade_scale, 'arial', 'right', 'center', true, false, false )
			dxDrawTextWithBorder ( sPosition, fade_l, fade_t, fade_r, fade_b, tcft(fade_color), fade_scale, 'arial', 'right', 'center', true, false, false, 1, tocolor(0,0,0), true )
			-- dxDrawRectangleFrame ( fade_l, fade_t, fade_r, fade_b, tcft(fade_color), 2 )

			if progress >= 1 then
				g_CheckpointFade.mode = false
			end
		end
	end

	if rank then
		local pos = {x = x, w = w, y = .85, h = h, xb = xb }
		dxDrawRectangle ( (pos.x - pos.xb - pos.w) * sx, pos.y * sy, (pos.w + pos.xb * 2) * sx , pos.h * sy, tocolor ( 0 ,0,0,150))
		local sRank = rank .. ((rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th' )
		local sTotal = ' / ' .. tonumber(players)
		dxDrawTextWithBorder ( 'POSITION', (pos.x - pos.w) * sx, pos.y * sy, (pos.x) * sx, (pos.y + pos.h) * sy, tocolor(255,255,255), scaleTxt, 'arial', "left", "center", true, false, false, 1, tocolor(0,0,0), true )
		dxDrawTextWithBorder ( sRank , (pos.x - pos.w) * sx, pos.y * sy, (pos.x) * sx - dxGetTextWidth ( sTotal, scaleData2nd, 'arial' ), (pos.y + pos.h) * sy, tocolor(255,255,255), scaleData, 'arial', "right", "center", true, false, false, 1, tocolor(0,0,0), true )
		-- dxDrawRectangleFrame ( (pos.x - pos.w) * sx, pos.y * sy, (pos.x) * sx - dxGetTextWidth ( sTotal, scaleData2nd, 'arial' ), (pos.y + pos.h) * sy, tocolor(255,255,255), scaleData)
		dxDrawTextWithBorder ( sTotal, (pos.x - pos.w) * sx, pos.y * sy, (pos.x) * sx, (pos.y + pos.h) * sy, tocolor(200,200,200), scaleData2nd, 'arial', "right", "center", true, false, false, 1, tocolor(0,0,0), true )

		if player == localPlayer and rank ~= g_RankFade.prevRank then
			if g_RankFade.prevRank and rank < g_RankFade.prevRank then
				g_RankFade.mode = true
				g_RankFade.startTick = getTickCount()
			end
			g_RankFade.prevRank = rank
		end

		if g_RankFade.mode then
			local scale = scaleData
			local progress = ( getTickCount() - g_RankFade.startTick ) / g_RankFade.time

			local rankWidth = dxGetTextWidth ( sRank , scale, 'arial' )
			local rankHeigth = dxGetFontHeight ( scale, 'arial' )
			local fadeWidth = dxGetTextWidth ( sRank, scale * g_RankFade.scale, 'arial' )
			local fadeHeigth = dxGetFontHeight ( scale * g_RankFade.scale, 'arial' )

			local fade_l = ( (pos.x - pos.w) * sx + rankWidth / 2 ) - fadeWidth / 2
			local fade_t = ( pos.y * sy + rankHeigth / 2 ) - fadeHeigth / 2
			local fade_r = ( (pos.x) * sx - dxGetTextWidth ( sTotal, scaleData2nd, 'arial' ) - rankWidth / 2 ) + fadeWidth / 2
			local fade_r = (pos.x) * sx - dxGetTextWidth ( sTotal, scaleData2nd, 'arial' )
			local fade_b = ( (pos.y + pos.h) * sy - rankHeigth / 2 ) + fadeHeigth / 2

			local fade_color = {255,255,255,255}
				fade_color[4] = 255
			if progress >= 0.5 then
				fade_color[4] = math.clamp(0, fade_color[4] - 255 * ( (progress - 0.5) * 2 ), 255)

			end
			local fade_scale = scale + progress * (g_RankFade.scale * scale - scale)

			-- dxDrawText ( sRank, fade_l, fade_t, fade_r, fade_b, tcft(fade_color), fade_scale, 'arial', 'right', 'center', true, false, false )
			dxDrawTextWithBorder ( sRank, fade_l, fade_t, fade_r, fade_b, tcft(fade_color), fade_scale, 'arial', 'right', 'center', true, false, false, 1, tocolor(0,0,0), true )
			-- dxDrawRectangleFrame ( fade_l, fade_t, fade_r, fade_b, tcft(fade_color), 2 )

			if progress >= 1 then
				g_RankFade.mode = false
			end
		end
	end



	-- if g_StartTick then
		local time = {x = x, w = w, y = .9, h = h, xb = xb }
		dxDrawRectangle ( (time.x - time.xb - time.w) * sx, time.y * sy, (time.w + time.xb * 2) * sx , time.h * sy, tocolor ( 0 ,0,0,150))
		local minutes, seconds, milliseconds = msToTime(g_StartTick and (getTickCount() - g_StartTick) or 0)
		dxDrawTextWithBorder ( 'TIME', (time.x - time.w) * sx, time.y * sy, (time.x) * sx, (time.y + time.h) * sy, tocolor(255,255,255), scaleTxt, 'arial', "left", "center", true, false, false, 1, tocolor(0,0,0), true )
		dxDrawTextWithBorder ( minutes .. ':' .. seconds, (time.x - time.w) * sx, time.y * sy, (time.x) * sx - dxGetTextWidth ( ".00", scaleData2nd, 'arial' ), (time.y + time.h) * sy, tocolor(255,255,255), scaleData, 'arial', "right", "center", true, false, false, 1, tocolor(0,0,0), true )
		dxDrawTextWithBorder ( milliseconds, (time.x - time.w) * sx, time.y * sy, (time.x) * sx, (time.y + time.h) * sy, tocolor(200,200,200), scaleData2nd, 'arial', "right", "center", true, false, false, 1, tocolor(0,0,0), true )
	-- end
end

local coolvetica = dxCreateFont ( 'files/coolvetica_rg.ttf', 50 )
function drawIVHud (player, g_Veh, rank, players, currentCheckpoint, totalCheckpoints, g_StartTick, currentLap, totalLaps)
	local x, y = 0.99, 0.95								-- origin point: bottom right
	local dy = 0.005									-- y distance between elements
	-- local dataScale = 3.0								-- text scale of the variables
	local dataScale = 1.0								-- text scale of the variables

	local labelScaleRatio = 0.7							-- text scale of the labels in relation to dataScale
	local labelWidth = 0.150							-- width of label
	local labelOffsetX = 0.015							-- distance between label and data

	local textColor = tocolor(225, 225, 225, 240)		-- variable color
	local backAlpha = 150
	local backDropColor = tocolor(0, 0, 0, backAlpha)	-- background color
	local rightBorder = 0.01							-- extra bacground size on the right
	-- local font = 'sans'									-- font
	local font = 'bankgothic'									-- font
	local team = player and getPlayerTeam(player) and {getTeamColor(getPlayerTeam(player))} or {}
	local color = tocolor(team[1] or 0, team[2] or 0, team[3] or 0, backAlpha)

	local dataWidth = 	dxGetTextWidth ( '88:88:88', dataScale, font) / sx
	local fontHeight = dxGetFontHeight ( dataScale, font ) / sy -- * .74
	local labelScale = labelScaleRatio * dataScale

	local l, m, r = sx * (x - labelWidth - dataWidth - labelOffsetX), sx * ( x - dataWidth - labelOffsetX ), sx * x
	local wl, w, h = sx * labelWidth, sx * (dataWidth + labelOffsetX), sy * fontHeight
	rank = tonumber(rank)
	totalCheckpoints = tonumber(totalCheckpoints)

	if not isPlayerFinished(player) then
		msPassed = g_StartTick and (getTickCount() - g_StartTick) or 0
	end

	local minutes, seconds, milliseconds = msToTime(msPassed)
	local text = minutes .. ':' .. seconds .. '.' .. milliseconds
	local t, b = sy * ( y - fontHeight ), sy * y

	dxDrawRectangle ( math.floor(m) + 1, t, w + rightBorder * sx, h, color)
	-- dxDrawRectangleFrame (math.floor(m) + 1, t, math.floor(m) + 1 + w + rightBorder * sx, t + h)
	dxDrawText ( text, m, t, r, b, textColor, dataScale, font, "right", "bottom", false, false, false, false, true)

	for i = math.floor(l), math.floor(m) do
		local a = backAlpha * (i-l) / (m-l)
		dxDrawRectangle ( i, t, 1, h, tocolor(team[1] or 0, team[2] or 0, team[3] or 0,a) )
	end

	dxDrawText ( "TIME", l, t, m, b, textColor, labelScale, font, "right", "center", false, false, false, false, true)

	if rank then
		local t, b = sy * ( y - fontHeight * 2 - dy), sy * (y - fontHeight - dy)
		local sRank = rank .. ' / ' .. tonumber(players)

		dxDrawRectangle ( math.floor(m) + 1, t, w + rightBorder * sx, h, color)
		dxDrawText ( sRank, m, t, r, b, textColor, dataScale, font, "right", "bottom", false, false, false, false, true)
	-- dxDrawRectangleFrame (m, t, r, b)

		for i = math.floor(l), math.floor(m) do
			local a = backAlpha * (i-l) / (m-l)
			dxDrawRectangle ( i, t, 1, h, tocolor(team[1] or 0, team[2] or 0, team[3] or 0,a) )
		end

		dxDrawText ( "POSITION", l, t, m, b, textColor, labelScale, font, "right", "center", false, false, false, false, true)
	elseif exports.race:getRaceMode() == 'Capture the flag' then
		local t, b = sy * ( y - fontHeight * 2 - dy), sy * (y - fontHeight - dy)
		local sFlags = (getElementData(getTeamFromName('Blue team'), 'ctf.points') or 0) .. ' / 3'

		dxDrawRectangle ( math.floor(m) + 1, t, w + rightBorder * sx, h, tocolor(0, 0, 255, backAlpha))
		dxDrawText ( sFlags, m, t, r, b, textColor, dataScale, font, "right", "bottom", false, false, false, false, true)

		for i = math.floor(l), math.floor(m) do
			local a = backAlpha * (i-l) / (m-l)
			dxDrawRectangle ( i, t, 1, h, tocolor(0, 0, 255,a) )
		end

		dxDrawText ( "BLUE FLAGS", l, t, m, b, textColor, labelScale, font, "right", "center", false, false, false, false, true)
	else return
	end

	if totalCheckpoints and totalCheckpoints > 0 and not totalLaps then
 		local t, b = sy * ( y - fontHeight * 3 - dy * 2), sy * (y - fontHeight * 2 - dy * 2)
		local sCheckpoint = currentCheckpoint .. ' / ' .. totalCheckpoints

		dxDrawRectangle ( math.floor(m) + 1, t, w + rightBorder * sx, h, color)
		dxDrawText ( sCheckpoint, m, t, r, b, textColor, dataScale, font, "right", "bottom", false, false, false, false, true)

		for i = math.floor(l), math.floor(m) do
			local a = backAlpha * (i-l) / (m-l)
			dxDrawRectangle ( i, t, 1, h, tocolor(team[1] or 0, team[2] or 0, team[3] or 0,a) )
		end

		if sx >= 800 and sy >= 600 then
			dxDrawText ( "CHECKPOINT", l, t, m, b, textColor, labelScale, font, "right", "center", false, false, false, false, true)
		else
			dxDrawText ( "CHECKPOINT", l, t, m, b, textColor, labelScale, 0.5, "right", "center", false, false, false, false, true)
			-- Don't really know if this will help, it makes the font more tiny, won't change entire code cuz a letter is outside, this should kind of fix it, don't so important to add
		end
    elseif totalCheckpoints and totalCheckpoints > 0 and totalLaps then
        if totalLaps then
            local t, b = sy * ( y - fontHeight * 3 - dy * 2), sy * (y - fontHeight * 2 - dy * 2)
            local sLaps = (currentLap or 1) .. " / " .. totalLaps

            dxDrawRectangle ( math.floor(m) + 1, t, w + rightBorder * sx, h, color)
            dxDrawText ( sLaps, m, t, r, b, textColor, dataScale, font, "right", "bottom", false, false, false, false, true)

            for i = math.floor(l), math.floor(m) do
                local a = backAlpha * (i-l) / (m-l)
                dxDrawRectangle ( i, t, 1, h, tocolor(team[1] or 0, team[2] or 0, team[3] or 0,a) )
            end

            dxDrawText("LAP", l, t, m, b, textColor, labelScale, font, "right", "center", false, false, false, false, true )

            local t, b= sy * ( y - fontHeight * 4 - dy * 3), sy * (y - fontHeight * 3 - dy * 3)
            dxDrawRectangle ( math.floor(m) + 1, t, w + rightBorder * sx, h, color)

            local minutes, seconds, milliseconds = msToTime(getElementData(player, "race.bestlap") or 0)
            local text = minutes .. ':' .. seconds .. '.' .. milliseconds

            dxDrawText(text, m, t, r, b, textColor, dataScale, font, "right", "bottom", false, false, false, false, true)

            for i = math.floor(l), math.floor(m) do
                local a = backAlpha * (i-l) / (m-l)
                dxDrawRectangle ( i, t, 1, h, tocolor(team[1] or 0, team[2] or 0, team[3] or 0,a) )
            end

            dxDrawText("BEST LAP", l, t, m, b, textColor, labelScale, font, "right", "center", false, false, false, false, true )
        end
	elseif exports.race:getRaceMode() == 'Shooter' or exports.race:getRaceMode() == 'Destruction derby' or exports.race:getRaceMode() == 'Deadline' then
		local t, b = sy * ( y - fontHeight * 3 - dy * 2), sy * (y - fontHeight * 2 - dy * 2)
		local sKills = getElementData(player, 'kills') or 0

		dxDrawRectangle ( math.floor(m) + 1, t, w + rightBorder * sx, h, color)
		dxDrawText ( sKills, m, t, r, b, textColor, dataScale, font, "right", "bottom", false, false, false, false, true)

		for i = math.floor(l), math.floor(m) do
			local a = backAlpha * (i-l) / (m-l)
			dxDrawRectangle ( i, t, 1, h, tocolor(team[1] or 0, team[2] or 0, team[3] or 0,a) )
		end

		dxDrawText ( "KILLS", l, t, m, b, textColor, labelScale, font, "right", "center", false, false, false, false, true)
	elseif exports.race:getRaceMode() == 'Capture the flag' then
		local t, b = sy * ( y - fontHeight * 3 - dy * 2), sy * (y - fontHeight * 2 - dy * 2)
		local sFlags = (getElementData(getTeamFromName('Red team'), 'ctf.points') or 0) .. ' / 3'

		dxDrawRectangle ( math.floor(m) + 1, t, w + rightBorder * sx, h, tocolor(255, 0, 0, backAlpha))
		dxDrawText ( sFlags, m, t, r, b, textColor, dataScale, font, "right", "bottom", false, false, false, false, true)

		for i = math.floor(l), math.floor(m) do
			local a = backAlpha * (i-l) / (m-l)
			dxDrawRectangle ( i, t, 1, h, tocolor(255, 0, 0,a) )
		end

		dxDrawText ( "RED FLAGS", l, t, m, b, textColor, labelScale, font, "right", "center", false, false, false, false, true)
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
	if not fireTick then
		text = math.clamp ( 0, health, 100 ) .. '%'
		dxDrawTextWithBorder ( text, l, t, r, b, tcft(inlineColor), scale, font, 'center', 'center', true, false, false, outlineSize, tcft(outlineColor) )
	else
		local time = 5 - math.floor((getTickCount() - fireTick)/1000)
		-- local x = 3
		local x = math.floor( (r-l) / (dxGetTextWidth('.', scale, font)) )
		local rep = math.floor((getTickCount() - fireTick)%1000*(x+1)/1000)
		if time < 1 then rep = 0 end
		local dots = string.rep('.', rep)
		text = time .. ' ' .. dots
		dxDrawTextWithBorder ( text, l, t, r, b, tcft(inlineColor), scale, font, 'left', 'center', true, false, false, outlineSize, tcft(outlineColor2) )
	end
end

---[[ Checking for vehicle on fire

vehicle, model, health, fireTick = nil

setTimer(
function()
	if not getPedOccupiedVehicle(g_Me) or not isElement(getPedOccupiedVehicle(g_Me)) or getElementData(g_Me, "state")  ~= "alive" or getElementData(g_Me, "kKey")  == "spectating" then
		vehicle, model, health, fireTick = nil, nil, nil, nil
		return false
	elseif (not vehicle) or vehicle ~= getPedOccupiedVehicle(g_Me) then
		vehicle = getPedOccupiedVehicle(g_Me)
		health, fireTick = nil, nil
		model = getElementModel(vehicle)
	end
	local newHealth = getElementHealth(vehicle) or 1000
	if not health then
		health = newHealth
	elseif health ~= newHealth then
		local dif = newHealth - health
		--outputChatBox(''.. newHealth .. ' (' .. (dif > 0 and '+' or '') .. dif ..')', dif < 0 and 255 or 0, dif > 0 and 255 or 0, 0)
		health = newHealth
	elseif model ~= getElementModel(vehicle) then
		--outputChatBox('Reset')
		model = getElementModel(vehicle)
		if newHealth < 249.99 then
			fireTick = getTickCount()
		end
	end
	if fireTick and ((fireTick - getTickCount() > 5000)) then
		fireTick = nil
		--outputChatBox("Fire stopped (time's up) ..." .. tostring(fireTick) )
	elseif fireTick and ((newHealth < 0.0001)) then
		fireTick = nil
		--outputChatBox("Fire stopped (boom!) ..." .. tostring(fireTick) )
	end
	if 0.0001 < newHealth and newHealth < 249.99 and not fireTick then
		fireTick = getTickCount()
		--outputChatBox("Fire started!" .. tostring(fireTick) )
	elseif newHealth > 249.99 and fireTick then
		fireTick = nil
		--outputChatBox("Fire stopped (healed) ..." .. tostring(fireTick) )
	end
end,
50, 0)
--]]


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
