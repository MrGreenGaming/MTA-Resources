local screenW, screenH = guiGetScreenSize()
local text_offset = 20
local teams = {}
local tags = {}
local ffa_mode = "CW" -- CW or FFA
local scoring = "15,13,11,9,7,5,4,3,2,1"
local c_round = 0
local m_round = 10
local f_round = false
local team_choosen = false
local isAdmin = false
local compact = false
local mode = "main"
local margin = math.floor(10 * (screenW / 1920))


local rowCount = 15
local rowHeight = math.floor(25 * (screenH / 1080))
local windowSizeX, windowSizeY = math.floor(250 * (screenW / 1920)), math.floor(rowHeight) * rowCount
local wX, wY = screenW - windowSizeX - 20, (screenH - windowSizeY) / 2

local fSize = screenH/1080
local fBold = dxCreateFont("fonts/Roboto-Bold.ttf", 9 * fSize, true,"cleartype") or "default"
local fReg = dxCreateFont("fonts/Roboto-Medium.ttf", 9 * fSize, false, "cleartype") or "default"

local nickWidth = 160 * (screenW/1920)
local rankWidth = 40 * (screenW/1920)
local ptsWidth = 50 * (screenW/1920)

function outputInfoClient(info)
    outputChatBox('[Event] #ffffff' ..info, 155, 155, 255, true)
end

-----------------
-- Call functions
-----------------

function serverCall(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    triggerServerEvent("onClientCallsServerFunction", resourceRoot , funcname, unpack(arg))
end

function clientCall(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do arg[key] = tonumber(value) or value end
    end
    loadstring("return "..funcname)()(unpack(arg))
end
addEvent("onServerCallsClientFunction", true)
addEventHandler("onServerCallsClientFunction", resourceRoot, clientCall)

------------------------
-- DISPLAY
------------------------

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

function dxDrawBottomRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y, radius, height-(radius), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y, radius, height-(radius), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

function updateDisplay()
	if isElement(teams[1]) and isElement(teams[2]) then
		local state = ""
		local sColor = "#ffffff"
		local r1, g1, b1 = getTeamColor(teams[1])
        local r2, g2, b2 = getTeamColor(teams[2])
		local t1c = rgb2hex(r1, g1, b1)
		local t2c = rgb2hex(r2, g2, b2)
        local t1tag = tags[1]
        local t2tag = tags[2]
		local t1 = getTeamName(teams[1])
		local t2 = getTeamName(teams[2])
		local t1t = getTeamFromName(t1)
		local t2t = getTeamFromName(t2)
		local t1Players = getPlayersInTeam(t1t)
		local t2Players = getPlayersInTeam(t2t)

		windowSizeX, windowSizeY = math.floor(250 * (screenW / 1920)), math.floor(rowHeight) * rowCount

		table.sort(t1Players, function(a, b) return getElementData(a, 'Score') > getElementData(b, 'Score') end)
		table.sort(t2Players, function(a, b) return getElementData(a, 'Score') > getElementData(b, 'Score') end)

		if not f_round then
			sColor = "#00ff00"
			state = "Event Active"
		else
			sColor = "#FFA500"
			state = "Free Round"
		end

		if #t1Players > 8 and #t2Players > 8 then
			rowCount = 8 + 8 + 5
		elseif #t1Players > 8 and #t2Players < 8 then
			rowCount = 8 + #t2Players + 5
		elseif #t1Players < 8 and #t2Players > 8 then
			rowCount = 8 + #t1Players + 5
		else
			rowCount = #t1Players + #t2Players + 5
		end

		if mode == "main" then
			local count = 0
			if #t1Players > 8 then
				count = 8
			else
				count = #t1Players
			end
			dxDrawRoundedRectangle(wX, wY, windowSizeX, windowSizeY, 10, tocolor(0, 0, 0, 160), false, false) -- background
			dxDrawRectangle(wX, wY + (rowHeight*2), windowSizeX, rowHeight, tocolor(r1, g1, b1, 30), false, false) -- t1 bg
            if ffa_mode == "CW" then
                dxDrawRectangle(wX, wY + (rowHeight*(2+(count+1))), windowSizeX, rowHeight, tocolor(r2, g2, b2, 30), false, false) -- t2 bg
            end
			dxDrawBottomRoundedRectangle(wX, wY + (rowHeight * (rowCount-1)), windowSizeX, rowHeight, 10, tocolor(0, 0, 0, 160), false, false) -- mode bg
			dxDrawText("Press #bababa0 #ffffffto change mode", wX, wY + (rowHeight * (rowCount-1)), wX+windowSizeX, wY + (rowHeight * (rowCount)), tocolor(255, 255, 255, 200), 1, fBold, "center", "center", false, false, true, true, false)

			dxDrawText(sColor..state, wX, wY, wX+windowSizeX, wY+rowHeight, tocolor(255, 255, 255, 255), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText("Round "..c_round.."/"..m_round, wX, wY+rowHeight, wX+windowSizeX, wY+(rowHeight*2), tocolor(255, 255, 255, 255), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText(getTeamName(teams[1]), wX + margin, wY + (rowHeight*2), wX+windowSizeX-margin, wY+(rowHeight*3), tocolor(r1, g1, b1, 255), 1, fBold, "left", "center", false, false, false, true, false)
			dxDrawText(getElementData(teams[1], 'Score'), wX + rankWidth + nickWidth, wY + (rowHeight*2), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*3), tocolor(r1, g1, b1, 255), 1, fBold, "center", "center", false, false, false, true, false)
			for playerKey, player in ipairs(t1Players) do
				local rank = tonumber(getElementData(player, 'race rank')) or 1
				local playerName = getElementData( player, "vip.colorNick" ) or getPlayerName( player )
				local pts = getElementData(player, 'Score')
				if playerKey < 9 then
					dxDrawText(rank .. getPrefix(rank), wX + margin, wY + (rowHeight*(2+playerKey)), wX+rankWidth, wY+(rowHeight*(3+playerKey)), tocolor(255,255,255, 255), 1, fReg, "left", "center", false, false, false, true, false)
					dxDrawText(playerName, wX + rankWidth, wY + (rowHeight*(2+playerKey)), wX+nickWidth, wY+(rowHeight*(3+playerKey)), tocolor(r1, g1, b1, 255), 1.0, fBold, "left", "center", false, false, false, true, false)
					dxDrawText(pts .. ' pts', wX + rankWidth + nickWidth, wY + (rowHeight*(2+playerKey)), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*(3+playerKey)), tocolor(255, 255, 255, 255), 1.0, fReg, "center", "center", false, false, false, true, false)
				end
			end

            if (ffa_mode == "CW") then
                dxDrawText(getTeamName(teams[2]), wX + margin, wY + (rowHeight*(3+count)), wX+windowSizeX-margin, wY+(rowHeight*(4+count)), tocolor(r2, g2, b2, 255), 1, fBold, "left", "center", false, false, false, true, false)
                dxDrawText(getElementData(teams[2], 'Score'), wX + rankWidth + nickWidth, wY + (rowHeight*(3+count)), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*(4+count)), tocolor(r2, g2, b2, 255), 1, fBold, "center", "center", false, false, false, true, false)

                local t2start = 0
                if #t1Players > 8 then
                    t2start = 3+8
                else
                    t2start = 3+#t1Players
                end
                for playerKey, player in ipairs(t2Players) do
                    local rank = tonumber(getElementData(player, 'race rank')) or 1
                    local playerName = getElementData( player, "vip.colorNick" ) or getPlayerName( player )
                    local pts = getElementData(player, 'Score')
                    if playerKey < 9 then
                        dxDrawText(rank .. getPrefix(rank), wX + margin, wY + (rowHeight*(t2start+playerKey)), wX+rankWidth, wY+(rowHeight*(t2start+playerKey+1)), tocolor(255,255,255, 255), 1, fReg, "left", "center", false, false, false, true, false)
                        dxDrawText(playerName, wX + rankWidth, wY + (rowHeight*(t2start+playerKey)), wX+nickWidth, wY+(rowHeight*(t2start+playerKey+1)), tocolor(r2, g2, b2, 255), 1.0, fBold, "left", "center", false, false, false, true, false)
                        dxDrawText(pts .. ' pts', wX + rankWidth + nickWidth, wY + (rowHeight*(t2start+playerKey)), wX+(nickWidth + rankWidth + ptsWidth), wY+(rowHeight*(t2start+playerKey+1)), tocolor(255, 255, 255, 255), 1.0, fReg, "center", "center", false, false, false, true, false)
                    end
                end
            end
            elseif mode == "compact" then
                rowCount = 4
			windowSizeX, windowSizeY = math.floor(250 * (screenW / 1920)), math.floor(rowHeight) * rowCount
			dxDrawRoundedRectangle(wX, wY, windowSizeX, windowSizeY, 10, tocolor(0, 0, 0, 160), false, false) -- background
			dxDrawRectangle(wX, wY + (rowHeight*2), windowSizeX, rowHeight, tocolor(r1, g1, b1, 20), false, false) -- t1 bg
			dxDrawBottomRoundedRectangle(wX, wY + (rowHeight * (rowCount-1)), windowSizeX, rowHeight, 10, tocolor(0, 0, 0, 160), false, false) -- mode bg
			dxDrawText("Press #bababa0 #ffffffto change mode", wX, wY + (rowHeight * (rowCount-1)), wX+windowSizeX, wY + (rowHeight * (rowCount)), tocolor(255, 255, 255, 200), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText(sColor..state, wX, wY, wX+windowSizeX, wY+rowHeight, tocolor(255, 255, 255, 255), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText("Round "..c_round.."/"..m_round, wX, wY+rowHeight, wX+windowSizeX, wY+(rowHeight*2), tocolor(255, 255, 255, 255), 1, fBold, "center", "center", false, false, true, true, false)
			dxDrawText(t1c..t1tag.."   "..getElementData(teams[1], 'Score').."  #ffffff-  "..t2c..getElementData(teams[2], 'Score').."   "..t2tag, wX + margin, wY + (rowHeight*2), wX+windowSizeX-(margin*2), wY+(rowHeight*3), tocolor(r1, g1, b1, 255), 1, fBold, "center", "center", false, false, false, true, false)
		else
			dxDrawRoundedRectangle(1,1,1,1, 0, tocolor(0, 0, 0, 0), false, false)
		end
	end
end

------------------------
--GUI
------------------------
local c_window

function createGUI(team1, team2) -- choose GUI
	if isElement(c_window) then
		destroyElement(c_window)
	end
	c_window = guiCreateWindow(screenW/2-150, screenH/2-75, 300, 140, "Select Team", false)
	guiWindowSetMovable(c_window, false)
	guiWindowSetSizable(c_window, false)
	local t1_button = guiCreateButton(40, 35, 100, 30, team1, false, c_window)
	addEventHandler("onClientGUIClick", t1_button, team1Choosen, false)
	local t2_button = guiCreateButton(160, 35, 100, 30, team2, false, c_window)
	addEventHandler("onClientGUIClick", t2_button, team2Choosen, false)
	local t3_button = guiCreateButton(40, 85, 220, 30, 'Spectators', false, c_window)
	addEventHandler("onClientGUIClick", t3_button, team3Choosen, false)
	showCursor(true)
end

function rgb2hex(r,g,b)
	return string.format("#%02X%02X%02X", r,g,b)
end

--admin GUI
local a_window

function createAdminGUI()
	if isElement(a_window) then
		destroyElement(a_window)
	end
	a_window = guiCreateWindow(screenW/2-150, screenH/2-75, 405, 320, 'Clan War Management', false)
	guiWindowSetSizable(a_window, false)
	close_button = guiCreateButton(9, 285, 381, 25, 'C L O S E', false, a_window)
	addEventHandler("onClientGUIClick", close_button, function() guiSetVisible(a_window, false) showCursor(false) end, false)
	tab_panel = guiCreateTabPanel(0.02, 0.08, 0.94, 0.78, true, a_window)
	guiSetInputMode('no_binds_when_editing')
		-- tab 1
		tab_general = guiCreateTab('General', tab_panel)

		local t1 = guiCreateLabel(59, 5, 68, 28, "Team Name", false, tab_general)
		guiLabelSetHorizontalAlign(t1, "center", false)
		local t2 = guiCreateLabel(260, 5, 68, 28, "Team Name", false, tab_general)
		guiLabelSetHorizontalAlign(t2, "center", false)
		local t1t = guiCreateLabel(59, 45, 68, 28, "Team Tag", false, tab_general)
		guiLabelSetHorizontalAlign(t1t, "center", false)
		local t2t = guiCreateLabel(260, 45, 68, 28, "Team Tag", false, tab_general)
		guiLabelSetHorizontalAlign(t2t, "center", false)
		local t1c = guiCreateLabel(39, 85, 100, 28, "Team Color [hex]", false, tab_general)
		guiLabelSetHorizontalAlign(t1c, "center", false)
		local t2c = guiCreateLabel(240, 85, 100, 28, "Team Color [hex]", false, tab_general)
		guiLabelSetHorizontalAlign(t2c, "center", false)
		--guiCreateLabel(10, 20, 150, 20, "Team name:", false, tab_general)
		--guiCreateLabel(10, 25, 150, 20, "________________", false, tab_general)
        --guiCreateLabel(128, 20, 150, 20, "Tag:", false, tab_general)
        --guiCreateLabel(128, 25, 150, 20, "_______", false, tab_general)

        ffa_field = guiCreateCheckBox(15, 143, 240, 20, "Free-for-All (ignores team settings)", ffa_mode == "FFA", false, tab_general)
        guiCreateLabel(15, 163, 240, 20, "Cannot be changed once war has started!", false, tab_general)

		if isElement(teams[1]) then
			t1name = getTeamName(teams[1])
		else
			t1name = 'Home'
		end
		t1_field = guiCreateEdit(15, 23, 154, 22, t1name, false, tab_general)
		if isElement(teams[2]) then
			t2name = getTeamName(teams[1])
		else
			t2name = 'Guest'
		end
		t2_field = guiCreateEdit(217, 23, 154, 22, t2name, false, tab_general)
        if(isElement(tags[1])) then
            t1tag = tags[1]
        else
            t1tag = 'H'
        end
        t1t_field = guiCreateEdit(15, 63, 154, 22, t1tag, false, tab_general)
        if(isElement(tags[2])) then
            t2tag = tags[2]
        else
            t2tag = 'G'
        end
        t2t_field = guiCreateEdit(217, 63, 154, 22, t2tag, false, tab_general)

		--guiCreateLabel(180, 20, 100, 20, "Color [RGB]:", false, tab_general)
		--guiCreateLabel(180, 25, 100, 20, "__________________________", false, tab_general)
		if isElement(teams[1]) then
			t1r, t1g, t1b = getTeamColor(teams[1])
			t1color = rgb2hex(t1r,t1g,t1b)
		else
			t1color = '#ff0000'
		end
		t1c_field = guiCreateEdit(15, 103, 154, 22, t1color, false, tab_general)
		if isElement(teams[2]) then
			t2r, t2g, t2b = getTeamColor(teams[2])
			t2color = rgb2hex(t2r,t2g,t2b)
		else
			t2color = '#00ff00'
		end
		t2c_field = guiCreateEdit(217, 103, 154, 22, t2color, false, tab_general)
		zadat_button = guiCreateButton(257, 143, 114, 29, "Apply", false, tab_general)
		guiSetProperty(zadat_button, "NormalTextColour", "FFFFFEFE")
		addEventHandler("onClientGUIClick", zadat_button, zadatTeams, false)
		start_button = guiCreateButton(10, 188, 112, 29, "Start CW", false, tab_general)
		guiSetProperty(start_button, "NormalTextColour", "FF30FE00")
		addEventHandler("onClientGUIClick", start_button, startWar, false)
		stop_button = guiCreateButton(132, 188, 114, 29, "Stop CW", false, tab_general)
		guiSetProperty(stop_button, "NormalTextColour", "FFFE0000")
		addEventHandler("onClientGUIClick", stop_button, function() serverCall('destroyTeams', localPlayer) end, false)
		fun_button = guiCreateButton(257, 188, 114, 29, "Fun Round", false, tab_general)
		guiSetProperty(fun_button, "NormalTextColour", "FFFD7D00")
		addEventHandler("onClientGUIClick", fun_button, function() serverCall('funRound', localPlayer) end, false)
		-- tab 2
		tab_rounds = guiCreateTab('Rounds & Score', tab_panel)

        scoring_name = guiCreateLabel(29, 127, 289, 20, "Scoring (split by ,)", false, tab_rounds)
        scoring_field = guiCreateEdit(29, 150, 289, 27, scoring, false, tab_rounds)


		tt1_name = guiCreateLabel(29, 13, 120, 20, "Team 1 Score", false, tab_rounds)
		tt2_name = guiCreateLabel(29, 70, 120, 20, "Team 2 Score", false, tab_rounds)
		local t1_score
		local t2_score
		if isElement(teams[1]) then t1_score = getElementData(teams[1], 'Score') else t1_score = '0' end
		if isElement(teams[2]) then t2_score = getElementData(teams[2], 'Score') else t2_score = '0' end
		t1cur_field = guiCreateEdit(29, 33, 120, 27, tostring(t1_score), false, tab_rounds)
		t2cur_field = guiCreateEdit(29, 90, 120, 27, tostring(t2_score), false, tab_rounds)
		guiCreateLabel(238, 13, 80, 20, "Current Round", false, tab_rounds)
		guiCreateLabel(238, 70, 80, 20, "Total Rounds", false, tab_rounds)
		cr_field = guiCreateEdit(238, 33, 80, 27, tostring(c_round), false, tab_rounds)
		ct_field = guiCreateEdit(238, 90, 80, 27, tostring(m_round), false, tab_rounds)
		zadat_button2 = guiCreateButton(128, 190, 100, 27, 'Apply', false, tab_rounds)
		guiSetProperty(zadat_button2, "NormalTextColour", "FFFFFEFE")
		addEventHandler("onClientGUIClick", zadat_button2, zadatScoreRounds, false)
	--	re_button = guiCreateButton(20, 120, 340, 25, 'Закончить текущий раунд', false, tab_rounds)
	--	addEventHandler('onClientGUIClick', re_button, function() triggerServerEvent('onPostFinish', getRootElement()) end, false)
	guiSetVisible(a_window, false)
end

function hex2rgb(hex)
	hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function toogleGUI() -- choose GUI
	if isElement(c_window) then
		if guiGetVisible(c_window) then
			guiSetVisible(c_window, false)
			if not guiGetVisible(a_window) then
				showCursor(false)
			end
		elseif not guiGetVisible(c_window) then
			guiSetVisible(c_window, true)
			showCursor(true)
		end
	end
end

function toogleAdminGUI()
	if isAdmin then
		if isElement(a_window) then
			if guiGetVisible(a_window) then
				guiSetVisible(a_window, false)
				if isElement(c_window) then
					if not guiGetVisible(c_window) then
						showCursor(false)
					end
				else
					showCursor(false)
				end
			elseif not guiGetVisible(a_window) then
				updateAdminPanelText()
				guiSetVisible(a_window, true)
				guiSetInputMode('no_binds_when_editing')
				showCursor(true)
			end
		end
	end
end

function toggleMode()
	if mode == "main" and ffa_mode == "CW" then
		mode = "compact"
		outputInfoClient('Compact mode')

    elseif mode == "main" and ffa_mode == "FFA" then
        mode = "hidden"
        outputInfoClient('Hidden mode')
	elseif mode == "compact" then
		mode = "hidden"
		outputInfoClient('Hidden mode')
	else
		mode = "main"
		outputInfoClient('Full mode')
	end
end

function updateAdminPanelText()
	if isElement(teams[1]) then
		local team1name = getTeamName(teams[1])
		local team2name = getTeamName(teams[2])
		guiSetText(t1_field, team1name)
		guiSetText(t2_field, team2name)
		local r1, g1, b1 = getTeamColor(teams[1])
		local r2, g2, b2 = getTeamColor(teams[2])
		local t1c = rgb2hex(r1,g1,b1)
		local t2c = rgb2hex(r2,g2,b2)
		guiSetText(t1c_field, tostring(t1c))
		guiSetText(t2c_field, tostring(t2c))
        local team1tag = tags[1]
        local team2tag = tags[2]
        guiSetText(t1t_field, team1tag)
        guiSetText(t2t_field, team2tag)
		local t1score = getElementData(teams[1], 'Score')
		local t2score = getElementData(teams[2], 'Score')
		guiSetText(tt1_name, team1name.. ':')
		guiSetText(tt2_name, team2name.. ':')
		guiSetText(t1cur_field, t1score)
		guiSetText(t2cur_field, t2score)
		guiSetText(cr_field, c_round)
		guiSetText(ct_field, m_round)

        guiSetText(scoring_field, scoring)
        guiCheckBoxSetSelected(ffa_field, ffa_mode == "FFA")
	end
end

function team1Choosen()
	serverCall('setPlayerTeam', localPlayer, teams[1])
    triggerServerEvent('onPlayerChangeTeam', localPlayer, getTeamName(teams[1]))
	if not guiGetVisible(a_window) then
		showCursor(false)
	end
	guiSetVisible(c_window, false)
	--outputChatBox('Press F3 to select team again', 155, 155, 255, true)
end

function team2Choosen()
	serverCall('setPlayerTeam', localPlayer, teams[2])
    triggerServerEvent('onPlayerChangeTeam', localPlayer, getTeamName(teams[2]))
	if not guiGetVisible(a_window) then
		showCursor(false)
	end
	guiSetVisible(c_window, false)
	--outputChatBox('Press F3 to select team again', 155, 155, 255, true)
end

function team3Choosen()
	serverCall('setPlayerTeam', localPlayer, teams[3])
    triggerServerEvent('onPlayerChangeTeam', localPlayer, getTeamName(teams[3]))
	if not guiGetVisible(a_window) then
		showCursor(false)
	end
	guiSetVisible(c_window, false)
	--outputChatBox('[CW] #ffffffPress #9b9bffF3 #ffffffto select team again', 155, 155, 255, true)
end

function zadatScoreRounds()
	local t1score = guiGetText(t1cur_field)
	local t2score = guiGetText(t2cur_field)
	local cur_round = guiGetText(cr_field)
	local ma_round = guiGetText(ct_field)
    local scoring_value = guiGetText(scoring_field)
	if isElement(teams[1]) and isElement(teams[2]) then
		setElementData(teams[1], 'Score', t1score)
		setElementData(teams[2], 'Score', t2score)
	end
	serverCall('updateRounds', cur_round, ma_round)

    local parsedScoring = stringToTable(scoring_value)
    if #parsedScoring ~= 0 then
        outputInfoClient('Scoring set to: ' .. table.concat(parsedScoring, ","))
        serverCall('updateScoring', scoring_value)
    else
        outputInfoClient('#FF0000INVALID SCORING, not applying scoring', 155, 155, 255, true)
    end

end

function zadatTeams()
    local ffa = guiCheckBoxGetSelected(ffa_field) == true and "FFA" or "CW"

    outputDebugString("FFA mode is: " .. tostring(ffa))

	local t1name = guiGetText(t1_field)
	local t2name = guiGetText(t2_field)
	local t1color = guiGetText(t1c_field)
	local t2color = guiGetText(t2c_field)
	if isElement(teams[1]) and isElement(teams[2]) then
		local r1,g1,b1 = hex2rgb(t1color)
		local r2,g2,b2 = hex2rgb(t2color)
		serverCall('setTeamName', teams[1], t1name)
		serverCall('setTeamColor', teams[1], r1, g1, b1)
		serverCall('setTeamName', teams[2], t2name)
		serverCall('setTeamColor', teams[2], r2, g2, b2)
        serverCall('setFFAMode', ffa_mode, ffa)
		serverCall('sincAP')
	end
end

function startWar()
	local t1name = guiGetText(t1_field)
	local t2name = guiGetText(t2_field)
    local t1tag = guiGetText(t1t_field)
    local t2tag = guiGetText(t2t_field)
	local t1color = guiGetText(t1c_field)
	local t2color = guiGetText(t2c_field)
	local r1,g1,b1 = hex2rgb(t1color)
	local r2,g2,b2 = hex2rgb(t2color)
    local ffa = guiCheckBoxGetSelected(ffa_field) == true and "FFA" or "CW"

	serverCall('startWar', t1name, t2name, t1tag, t2tag, r1, g1, b1, r2, g2, b2, ffa)
	outputInfoClient('Press #9b9bff0 #ffffffto switch display mode')

    if ffa == "CW" then
        outputInfoClient('Press #9b9bff8 #ffffffto select team')
    end
end

----------------------------
-- OTHER FUNCTIONS
----------------------------
function updateTeamData(team1, team2, team3)
	teams[1] = team1
	teams[2] = team2
	teams[3] = team3
	updateAdminPanelText()
end

function updateTagData(tag1, tag2)
	tags[1] = tag1
	tags[2] = tag2
	updateAdminPanelText()
end

function updateModeData(mode)
    ffa_mode = mode
    updateAdminPanelText()
end

function updateScoringData(newScoring)
    scoring = newScoring
    updateAdminPanelText()
end

function updateRoundData(c_r, max_r, f_r)
	if c_r == 0 then
		f_round = true
	else
		f_round = f_r
	end
	c_round = c_r
	m_round = max_r
	updateAdminPanelText()
end

function updateAdminInfo(obj)
	isAdmin = obj
	if isAdmin then
		createAdminGUI()
		outputInfoClient('Press #9b9bff9 #ffffffto open management panel')
	end
end

function onResStart()
	serverCall('isClientAdmin', localPlayer)
	createAdminGUI()
end

function stringToNumber(colorsString)
	local r = gettok(colorsString, 1, string.byte(','))
	local g = gettok(colorsString, 2, string.byte(','))
	local b = gettok(colorsString, 3, string.byte(','))
	if r == false or g == false or b == false then
		outputInfoClient('use - [0-255], [0-255], [0-255]')
		return 0, 255, 0
	else
		return r, g, b
	end
end
----------------------------
-- BINDS
----------------------------
createAdminGUI()
setTimer(function()
    if isElement(teams[1]) and ffa_mode == "CW" then
        createGUI(getTeamName(teams[1]), getTeamName(teams[2]))
    end
end, 2500, 1)
bindKey('8', 'down', toogleGUI)
bindKey('9', 'down', toogleAdminGUI)
bindKey('0', 'down', toggleMode)
serverCall('playerJoin', localPlayer)

----------------------------
-- EVENT HANDLERS
----------------------------
addEventHandler('onClientRender', getRootElement(), updateDisplay)
addEventHandler('onClientResourceStart', getResourceRootElement(), onResStart)
--guiCreateLabel(30, 3, 200, 200, '*Race League script by [CsB]Vally', false)
