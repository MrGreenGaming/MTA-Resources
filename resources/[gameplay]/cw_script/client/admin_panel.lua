local a_window
local screenW, screenH = guiGetScreenSize()

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

        start_button = guiCreateButton(10, 188, 112, 29, "Start CW", false, tab_general)
		guiSetProperty(start_button, "NormalTextColour", "FF30FE00")
		addEventHandler("onClientGUIClick", start_button, startWar, false)
		stop_button = guiCreateButton(132, 188, 114, 29, "Stop CW", false, tab_general)
		guiSetProperty(stop_button, "NormalTextColour", "FFFE0000")
		addEventHandler("onClientGUIClick", stop_button, function() serverCall('destroyTeams', localPlayer) end, false)
		fun_button = guiCreateButton(257, 188, 114, 29, "Fun Round", false, tab_general)
		guiSetProperty(fun_button, "NormalTextColour", "FFFD7D00")
		addEventHandler("onClientGUIClick", fun_button, function() serverCall('funRound', localPlayer) end, false)

        -- tab teams
        tab_teams = guiCreateTab('Teams', tab_panel)

		local t1 = guiCreateLabel(59, 5, 68, 28, "Team Name", false, tab_teams)
		guiLabelSetHorizontalAlign(t1, "center", false)
		local t2 = guiCreateLabel(260, 5, 68, 28, "Team Name", false, tab_teams)
		guiLabelSetHorizontalAlign(t2, "center", false)
		local t1t = guiCreateLabel(59, 45, 68, 28, "Team Tag", false, tab_teams)
		guiLabelSetHorizontalAlign(t1t, "center", false)
		local t2t = guiCreateLabel(260, 45, 68, 28, "Team Tag", false, tab_teams)
		guiLabelSetHorizontalAlign(t2t, "center", false)
		local t1c = guiCreateLabel(39, 85, 100, 28, "Team Color [hex]", false, tab_teams)
		guiLabelSetHorizontalAlign(t1c, "center", false)
		local t2c = guiCreateLabel(240, 85, 100, 28, "Team Color [hex]", false, tab_teams)
		guiLabelSetHorizontalAlign(t2c, "center", false)
		--guiCreateLabel(10, 20, 150, 20, "Team name:", false, tab_general)
		--guiCreateLabel(10, 25, 150, 20, "________________", false, tab_general)
        --guiCreateLabel(128, 20, 150, 20, "Tag:", false, tab_general)
        --guiCreateLabel(128, 25, 150, 20, "_______", false, tab_general)

		if isElement(teams[1]) then
			t1name = getTeamName(teams[1])
		else
			t1name = 'Home'
		end
		t1_field = guiCreateEdit(15, 23, 154, 22, t1name, false, tab_teams)
		if isElement(teams[2]) then
			t2name = getTeamName(teams[1])
		else
			t2name = 'Guest'
		end
		t2_field = guiCreateEdit(217, 23, 154, 22, t2name, false, tab_teams)
        if(isElement(tags[1])) then
            t1tag = tags[1]
        else
            t1tag = 'H'
        end
        t1t_field = guiCreateEdit(15, 63, 154, 22, t1tag, false, tab_teams)
        if(isElement(tags[2])) then
            t2tag = tags[2]
        else
            t2tag = 'G'
        end
        t2t_field = guiCreateEdit(217, 63, 154, 22, t2tag, false, tab_teams)

		--guiCreateLabel(180, 20, 100, 20, "Color [RGB]:", false, tab_general)
		--guiCreateLabel(180, 25, 100, 20, "__________________________", false, tab_general)
		if isElement(teams[1]) then
			t1r, t1g, t1b = getTeamColor(teams[1])
			t1color = rgb2hex(t1r,t1g,t1b)
		else
			t1color = '#ff0000'
		end
		t1c_field = guiCreateEdit(15, 103, 154, 22, t1color, false, tab_teams)
		if isElement(teams[2]) then
			t2r, t2g, t2b = getTeamColor(teams[2])
			t2color = rgb2hex(t2r,t2g,t2b)
		else
			t2color = '#00ff00'
		end
		t2c_field = guiCreateEdit(217, 103, 154, 22, t2color, false, tab_teams)
		zadat_button = guiCreateButton(257, 143, 114, 29, "Apply", false, tab_teams)
		guiSetProperty(zadat_button, "NormalTextColour", "FFFFFEFE")
		addEventHandler("onClientGUIClick", zadat_button, zadatTeams, false)

        -- tab Free-for-all
        tab_ffa = guiCreateTab('Free-for-All', tab_panel)
        ffa_field = guiCreateCheckBox(59, 5, 300, 20, "Enable Free-for-All (will ignore team settings)", ffa_mode == "FFA", false, tab_ffa)

        ffa_keep_gcshop_teams_field = guiCreateCheckBox(59, 25, 240, 20, "Keep GcShop teams", false, false, tab_ffa)

        ffa_keep_modshop_field = guiCreateCheckBox(59, 45, 350, 20, "Keep ModShop modifications (except wheels)", false, false, tab_ffa)

        ffa_warn_label = guiCreateLabel(0, 170, 500, 20, "WARNING: The settings on this page can't change once event started!", false, tab_ffa)

        zadat_button_ffa = guiCreateButton(128, 190, 100, 27, 'Apply not needed', false, tab_ffa)
		guiSetProperty(zadat_button_ffa, "NormalTextColour", "FFFFFEFE")
        guiSetEnabled(zadat_button_ffa, false)

		-- tab scoring
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
    local keepTeams = guiCheckBoxGetSelected(ffa_keep_gcshop_teams_field) == true
    local keepModShop = guiCheckBoxGetSelected(ffa_keep_modshop_field) == true

	serverCall('startWar', t1name, t2name, t1tag, t2tag, r1, g1, b1, r2, g2, b2, ffa, keepTeams, keepModShop)
	outputInfoClient('Press #9b9bff0 #ffffffto switch display mode')

    if ffa == "CW" then
        outputInfoClient('Press #9b9bff8 #ffffffto select team')
    end
end

function onResStart()
	serverCall('isClientAdmin', localPlayer)
	createAdminGUI()
end

bindKey('9', 'down', toogleAdminGUI)
createAdminGUI()
addEventHandler('onClientResourceStart', getResourceRootElement(), onResStart)
