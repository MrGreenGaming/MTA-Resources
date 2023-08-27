local c_window
local screenW, screenH = guiGetScreenSize()

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
