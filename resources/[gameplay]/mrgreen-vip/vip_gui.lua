-- local mainWindow
-- local blinkingPattern = 0
-- local blinkingSpeed = 0
-- local guiShown = false
-- addEventHandler("onClientResourceStart", resourceRoot,
--     function()
--          mainWindow = guiCreateWindow(0.19, 0.31, 0.63, 0.39, "VIP system", true)
--         guiWindowSetSizable(mainWindow, false)

--         btnNickname = guiCreateButton(0.02, 0.11, 0.18, 0.14, "Set color nickname", true, mainWindow)
--         guiSetProperty(btnNickname, "NormalTextColour", "FFAAAAAA")
--         lblBlinkingLights = guiCreateLabel(0.25, 0.11, 0.39, 0.13, "Blinking lights:", true, mainWindow)
--         btnPattern1 = guiCreateButton(0.25, 0.31, 0.15, 0.15, "Left - Right Pattern", true, mainWindow)
--         guiSetProperty(btnPattern1, "NormalTextColour", "FFAAAAAA")
--         lblPattern = guiCreateLabel(0.25, 0.20, 0.38, 0.11, "Select pattern:", true, mainWindow)
--         lblSpeed = guiCreateLabel(0.25, 0.51, 0.39, 0.13, "Select speed:", true, mainWindow)
--         btnSpeed1 = guiCreateButton(0.25, 0.60, 0.06, 0.07, "1", true, mainWindow)
--         guiSetProperty(btnSpeed1, "NormalTextColour", "FFAAAAAA")
--         btnEnable = guiCreateButton(0.25, 0.72, 0.19, 0.15, "Enable blinking lights", true, mainWindow)
--         guiSetProperty(btnEnable, "NormalTextColour", "FFAAAAAA")
--         btnSpeed2 = guiCreateButton(0.32, 0.60, 0.06, 0.07, "2", true, mainWindow)
--         guiSetProperty(btnSpeed2, "NormalTextColour", "FFAAAAAA")
--         btnSpeed3 = guiCreateButton(0.39, 0.60, 0.06, 0.07, "3", true, mainWindow)
--         guiSetProperty(btnSpeed3, "NormalTextColour", "FFAAAAAA")
--         btnSpeed4 = guiCreateButton(0.46, 0.60, 0.06, 0.07, "4", true, mainWindow)
--         guiSetProperty(btnSpeed4, "NormalTextColour", "FFAAAAAA")
--         btnRainbow = guiCreateButton(0.02, 0.26, 0.18, 0.14, "Toggle VIP rainbow feature", true, mainWindow)
--         guiSetProperty(btnRainbow, "NormalTextColour", "FFAAAAAA")
--         btnPattern2 = guiCreateButton(0.42, 0.31, 0.15, 0.15, "Cross Pattern", true, mainWindow)
--         guiSetProperty(btnPattern2, "NormalTextColour", "FFAAAAAA")
--         btnPattern3 = guiCreateButton(0.59, 0.31, 0.15, 0.15, "Circle Pattern", true, mainWindow)
--         guiSetProperty(btnPattern3, "NormalTextColour", "FFAAAAAA")
--         btnDisable = guiCreateButton(0.46, 0.72, 0.19, 0.15, "Disable blinking lights", true, mainWindow)
--         guiSetProperty(btnDisable, "NormalTextColour", "FFAAAAAA")    
-- 		checkTag = guiCreateCheckBox(0.03, 0.80, 0.21, 0.07, "Show VIP tag over nametag", true, true, mainWindow)
		
-- 		addEventHandler('onClientGUIClick', btnSpeed1, speedClick, false)
-- 		addEventHandler('onClientGUIClick', btnSpeed2, speedClick, false)
-- 		addEventHandler('onClientGUIClick', btnSpeed3, speedClick, false)
-- 		addEventHandler('onClientGUIClick', btnSpeed4, speedClick, false)
		
-- 		addEventHandler('onClientGUIClick', btnPattern1, patternClick, false)
-- 		addEventHandler('onClientGUIClick', btnPattern2, patternClick, false)
-- 		addEventHandler('onClientGUIClick', btnPattern3, patternClick, false)
		
-- 		addEventHandler('onClientGUIClick', btnEnable, enableBlinking, false)
-- 		addEventHandler('onClientGUIClick', btnDisable, disableBlinking, false)
		
-- 		addEventHandler('onClientGUIClick', btnNickname, nickButtonClicked, false)
-- 		addEventHandler('onClientGUIClick', btnRainbow, rainbowButtonClicked, false)
		
-- 		addEventHandler('onClientGUIClick', checkTag, nametagToggle, false)
		
-- 		guiSetVisible(mainWindow, false)
--     end
-- )

-- function nametagToggle(btn, state)
-- 	if btn~="left" or state~="up" then return end
	
-- 	local showNametag = guiCheckBoxGetSelected(checkTag)
	
-- 	triggerServerEvent('vip-showNametag', localPlayer, showNametag)
-- end

-- function nickButtonClicked(btn, state)
-- 	if btn~="left" or state~="up" then return end
-- 	triggerEvent('onPlayerRequestCustomNickWindow', localPlayer)
-- end

-- function rainbowButtonClicked(btn, state)
-- 	if btn~="left" or state~="up" then return end
-- 	triggerServerEvent('vip-toggleRainbow', localPlayer)
-- end

-- function speedClick(btn, state)
-- 	if btn~="left" or state~="up" then return end
	
-- 	blinkingSpeed = tonumber(guiGetText(source))
-- 	guiSetProperty(btnSpeed1, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnSpeed2, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnSpeed3, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnSpeed4, "NormalTextColour", "FFAAAAAA")
	
-- 	guiSetProperty(source, "NormalTextColour", "FF00FF00")
-- end

-- function patternClick(btn, state)
-- 	if btn~="left" or state~="up" then return end
	
-- 	guiSetProperty(btnPattern1, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnPattern2, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnPattern3, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(source, "NormalTextColour", "FF00FF00")
	
-- 	local selectedPattern = guiGetText(source)
	
-- 	if selectedPattern == "Left - Right Pattern" then
-- 		blinkingPattern = 1
-- 	elseif selectedPattern == "Cross Pattern" then
-- 		blinkingPattern = 2
-- 	elseif selectedPattern == "Circle Pattern" then
-- 		blinkingPattern = 3
-- 	end
-- end

-- function enableBlinking(btn, state)
-- 	if btn~="left" or state~="up" then return end
	
-- 	if blinkingPattern == 0 or blinkingSpeed == 0 then outputChatBox("You must select a pattern and a speed!", 255, 0, 0) return end
	
-- 	triggerServerEvent('vip-startBlinking', localPlayer, blinkingPattern, blinkingSpeed)
-- end

-- function disableBlinking(btn, state)
-- 	if btn~="left" or state~="up" then return end
	
-- 	blinkingPattern = 0
-- 	blinkingSpeed = 0
	
-- 	guiSetProperty(btnPattern1, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnPattern2, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnPattern3, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnSpeed1, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnSpeed2, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnSpeed3, "NormalTextColour", "FFAAAAAA")
-- 	guiSetProperty(btnSpeed4, "NormalTextColour", "FFAAAAAA")
	
-- 	triggerServerEvent('vip-startBlinking', localPlayer, 0, 0)
-- end

-- function toggleGUI()
-- 	guiShown = not guiShown
-- 	if guiShown then
-- 		if getElementData(localPlayer, 'gcshop.vipbadge') then
-- 			guiCheckBoxSetSelected(checkTag, true)
-- 		else
-- 			guiCheckBoxSetSelected(checkTag, false)
-- 		end
-- 	end
-- 	guiSetVisible(mainWindow, guiShown)
-- 	showCursor(guiShown)
-- end
-- addEvent('vip-toggleGUI', true)
-- addEventHandler('vip-toggleGUI', root, toggleGUI)



function build_mainVipWindow()
	
	gui = {}
	gui._placeHolders = {}
	
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 750, 616
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Mr. Green VIP Panel (F7 to close)", false)
	guiWindowSetSizable(gui["_root"], false)
	guiSetVisible( gui["_root"], false )
	
	gui["vipTabs"] = guiCreateTabPanel(10, 70, 730, 521, false, gui["_root"])
	
	gui["tab_home"] = guiCreateTab("Home", gui["vipTabs"])
	
	gui["scrollAreaHome"] = guiCreateScrollPane(20, 0, 681, 491, false, gui["tab_home"])

	
	gui["labelHome"] = guiCreateLabel(12, 112, 641, 350, "What is VIP?\n--------------------\nVIP is a special status that grants exclusive features and discounts to players.\n\nWhat is included in VIP?\n-------------------------------\n- Forum, ingame and discord VIP tags.\n- Car paintjob and wheels rainbow (Continuously changing colors)\n- +50% GreenCoins for finishing or winning a map.\n- Custom join message (A global chat message when you join the server)\n- 10% off all GC shop items\n- Super Nickname (Your nickname can have 22 characters and unlimited colors)\n- Blinking lights (Have blinking vehicle lights in a pattern)\n- Exclusive VIP character models\n- Exclusive VIP horn (upload your own private horn) - Coming Soon!\n- Police Sirens - Coming Soon!\n- Dynamic Vehicle Overlay (Fancy vehicle overlay that reacts to sound) - Coming Soon!\n- More features coming soon!\n\n", false, gui["scrollAreaHome"])
	guiLabelSetHorizontalAlign(gui["labelHome"], "left", true)
	guiLabelSetVerticalAlign(gui["labelHome"], "top")
	
	gui["tabGetVip"] = guiCreateTabPanel(12, 400, 641, 200, false, gui["scrollAreaHome"])
	
	gui["tab_VipInfo"] = guiCreateTab("Get VIP", gui["tabGetVip"])
	
	gui["labelDonate"] = guiCreateLabel(10, 10, 551, 210, "How do I get VIP?\n-----------------------\nGo to mrgreengaming.com/donate and click on \"VIP\".\n\nOnce your payment has been processed, you will automatically get the days of VIP added to your account!", false, gui["tab_VipInfo"])
	guiSetEnabled(gui["labelDonate"], false)
	guiLabelSetHorizontalAlign(gui["labelDonate"], "left", true)
	guiLabelSetVerticalAlign(gui["labelDonate"], "top")
	guiLabelSetColor(gui["labelDonate"], 120, 120, 120)
	

	gui["mainHeaderImage"] = guiCreateStaticImage( 140, 0, 395, 124, "img/vip_main.png", false, gui["scrollAreaHome"] )

	
	gui["tab_cosmetics"] = guiCreateTab("VIP Cosmetics", gui["vipTabs"])
	guiSetEnabled( gui["tab_cosmetics"], false )

	
	gui["labelLoginInfo"] = guiCreateLabel(200, 280, 361, 101, "", false, gui["tab_cosmetics"])
	guiLabelSetHorizontalAlign(gui["labelLoginInfo"], "left", true)
	guiLabelSetVerticalAlign(gui["labelLoginInfo"], "center")
	
	gui["scrollAreaCosmetics"] = guiCreateScrollPane(20, 0, 681, 491, false, gui["tab_cosmetics"])
	
	gui["cosmeticsImage"] = guiCreateStaticImage( 140, 0, 395, 124, "img/vip_cosmetics.png", false, gui["scrollAreaCosmetics"] )
	
	-- gui._placeHolders["line"] = {left = 2, top = 212, width = 661, height = 20, parent = gui["scrollAreaCosmetics"]}
	gui["line1"] = guiCreateStaticImage( 0, 214, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	
	
	gui["label_2"] = guiCreateLabel(12, 112, 631, 16, "Setting will automatically be saved", false, gui["scrollAreaCosmetics"])
	guiSetFont( gui["label_2"], "default-small")
	guiLabelSetHorizontalAlign(gui["label_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_2"], "center")
	
	gui["label_rainbowcolors"] = guiCreateLabel(22, 232, 161, 21, "Rainbow Colors", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["label_rainbowcolors"], "left", false)
	guiLabelSetVerticalAlign(gui["label_rainbowcolors"], "center")
	guiSetFont( gui["label_rainbowcolors"], "default-bold-small")
	
	gui["Rainbow_Paintjob"] = guiCreateCheckBox(22, 262, 200, 17, "Toggle Rainbow Paintjob", false, false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Rainbow_Paintjob"], onVipRainbowToggle, false)
	gui["Rainbow_Lights"] = guiCreateCheckBox(250, 262, 200, 17, "Toggle Rainbow Headlights", false, false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Rainbow_Lights"], onVipRainbowToggle, false)
	gui["Rainbow_Wheels"] = guiCreateCheckBox(22, 282, 200, 17, "Toggle Rainbow Wheels (Rims)", false, false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Rainbow_Wheels"], onVipRainbowToggle, false)
	
	-- gui._placeHolders["line_2"] = {left = 2, top = 302, width = 661, height = 20, parent = gui["scrollAreaCosmetics"]}
	gui["line2"] = guiCreateStaticImage( 0, 316, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	
	gui["label_3"] = guiCreateLabel(22, 322, 621, 21, "Blinking Lights", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["label_3"], "left", false)
	guiLabelSetVerticalAlign(gui["label_3"], "center")
	guiSetFont( gui["label_3"], "default-bold-small")
	
	gui["label_4"] = guiCreateLabel(22, 352, 111, 16, "Sellect Blink Pattern:", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["label_4"], "left", false)
	guiLabelSetVerticalAlign(gui["label_4"], "center")
	
	gui["Blink_Left_Right_Pattern"] = guiCreateButton(22, 382, 171, 41, "Left-Right Pattern", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Blink_Left_Right_Pattern"], lightblink_patternClick, false)
	
	gui["Blink_Cross_Pattern"] = guiCreateButton(242, 382, 171, 41, "Cross Pattern", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Blink_Cross_Pattern"], lightblink_patternClick, false)
	
	gui["Blink_Circle_Pattern"] = guiCreateButton(462, 382, 171, 41, "Circle Pattern", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Blink_Circle_Pattern"], lightblink_patternClick, false)
	
	
	gui["label_5"] = guiCreateLabel(22, 442, 111, 16, "Select Blink Speed", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["label_5"], "left", false)
	guiLabelSetVerticalAlign(gui["label_5"], "center")
	
	

	gui["Blink_Speed_1"] = guiCreateButton(22, 472, 61, 31, "1", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Blink_Speed_1"], lightblink_speedClick, false)
	
	gui["Blink_Speed_2"] = guiCreateButton(102, 472, 61, 31, "2", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Blink_Speed_2"], lightblink_speedClick, false)

	
	gui["Blink_Speed_3"] = guiCreateButton(182, 472, 61, 31, "3", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Blink_Speed_3"], lightblink_speedClick, false)

	
	gui["Blink_Speed_4"] = guiCreateButton(262, 472, 61, 31, "4", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["Blink_Speed_4"], lightblink_speedClick, false)

	
	gui["checkbox_blink_lights"] = guiCreateCheckBox(22, 522, 631, 17, "Toggle Blinking Lights", false, false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["checkbox_blink_lights"], lightblink_enableBlinking, false)
	-- gui._placeHolders["line_3"] = {left = 2, top = 552, width = 661, height = 20, parent = gui["scrollAreaCosmetics"]}
	gui["line3"] = guiCreateStaticImage( 0, 552, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	
	gui["label_vip_skin"] = guiCreateLabel(22, 572, 161, 21, "VIP Character Skin", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["label_vip_skin"], "left", false)
	guiLabelSetVerticalAlign(gui["label_vip_skin"], "center")
	guiSetFont( gui["label_vip_skin"], "default-bold-small")
	
	gui["vip_skin_current_label"] = guiCreateLabel(22, 602, 181, 16, "Current VIP skin: none", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["vip_skin_current_label"], "left", false)
	guiLabelSetVerticalAlign(gui["vip_skin_current_label"], "center")
	
	gui["vip_skin_grid"] = guiCreateGridList(22, 632, 451, 151, false, gui["scrollAreaCosmetics"])
	guiGridListSetSortingEnabled(gui["vip_skin_grid"], false)
	gui["vip_skin_grid_col0"] = guiGridListAddColumn(gui["vip_skin_grid"], "ID", 0.221729)
	gui["vip_skin_grid_col1"] = guiGridListAddColumn(gui["vip_skin_grid"], "Name", 0.221729)
	
	local vip_skin_grid_row = nil
	
	gui["vip_skin_remove"] = guiCreateButton(492, 722, 151, 61, "Stop using VIP skin", false, gui["scrollAreaCosmetics"])
	if on_vip_skin_remove_clicked then
		addEventHandler("onClientGUIClick", gui["vip_skin_remove"], on_vip_skin_remove_clicked, false)
	end
	
	gui["vip_skin_use"] = guiCreateButton(492, 632, 151, 61, "Use Selected Skin", false, gui["scrollAreaCosmetics"])
	if on_vip_skin_use_clicked then
		addEventHandler("onClientGUIClick", gui["vip_skin_use"], on_vip_skin_use_clicked, false)
	end
	
	-- gui._placeHolders["line_4"] = {left = 2, top = 802, width = 661, height = 20, parent = gui["scrollAreaCosmetics"]}
	gui["line4"] = guiCreateStaticImage( 0, 802, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	
	gui["dvoid_label"] = guiCreateLabel(22, 822, 521, 16, "Dynamic Vehicle Overlay (by ~Shadow~):", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["dvoid_label"], "left", false)
	guiLabelSetVerticalAlign(gui["dvoid_label"], "center")
	guiSetFont( gui["dvoid_label"], "default-bold-small")
	
	-- gui._placeHolders["line_5"] = {left = 2, top = 122, width = 661, height = 20, parent = gui["scrollAreaCosmetics"]}
	-- gui["line5"] = guiCreateStaticImage( 0, 122, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	
	gui["vip_badge_label"] = guiCreateLabel(22, 142, 311, 16, "VIP Badge", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["vip_badge_label"], "left", false)
	guiLabelSetVerticalAlign(gui["vip_badge_label"], "center")
	guiSetFont( gui["vip_badge_label"], "default-bold-small")
	
	gui["vip_badge_toggle"] = guiCreateCheckBox(22, 172, 631, 17, "Toggle VIP Badge", false, false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["vip_badge_toggle"], onVipBadgeToggle, false)


	gui["dvoid_gridlist"] = guiCreateGridList(22, 882, 111, 151, false, gui["scrollAreaCosmetics"])
	guiGridListSetSortingEnabled(gui["dvoid_gridlist"], false)
	gui["dvoid_gridlist_col0"] = guiGridListAddColumn(gui["dvoid_gridlist"], "ID", 0.900901)
	
	local dvoid_gridlist_row = nil
	
	gui["dvoid_use"] = guiCreateButton(142, 882, 151, 61, "Use Selected Overlay", false, gui["scrollAreaCosmetics"])
	-- guiSetEnabled( gui["dvoid_use"], false )
	if on_dvoid_use_clicked then
		addEventHandler("onClientGUIClick", gui["dvoid_use"], on_dvoid_use_clicked, false)
	end
	
	gui["dvoid_using_label"] = guiCreateLabel(22, 852, 271, 16, "Current overlay: none", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["dvoid_using_label"], "left", false)
	guiLabelSetVerticalAlign(gui["dvoid_using_label"], "center")
	
	gui["dvoid_stop_using"] = guiCreateButton(142, 972, 151, 61, "Stop Using Overlay", false, gui["scrollAreaCosmetics"])
	-- guiSetEnabled( gui["dvoid_stop_using"], false )
	if on_dvoid_stop_using_clicked then
		addEventHandler("onClientGUIClick", gui["dvoid_stop_using"], on_dvoid_stop_using_clicked, false)
	end
	
	gui["label_7"] = guiCreateLabel(352, 852, 111, 16, "Current overlay color:", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["label_7"], "left", false)
	guiLabelSetVerticalAlign(gui["label_7"], "center")
	

	gui["dvoid_color"] = guiCreateStaticImage( 352, 882, 111, 50, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	-- SETTING IMAGE COLOR
	guiSetProperty (gui["dvoid_color"], "ImageColours","#FFFFFF")
	
	
	gui["dvoidChangeColor"] = guiCreateButton(472, 882, 151, 61, "Change Color", false, gui["scrollAreaCosmetics"])
	-- guiSetEnabled( gui["dvoidChangeColor"], false )
	if on_dvoidChangeColor_clicked then
		addEventHandler("onClientGUIClick", gui["dvoidChangeColor"], on_dvoidChangeColor_clicked, false)
	end
	
	-- gui._placeHolders["line_6"] = {left = 2, top = 1052, width = 661, height = 20, parent = gui["scrollAreaCosmetics"]}
	gui["line6"] = guiCreateStaticImage( 0, 1052, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	
	gui["label_vip_skin_2"] = guiCreateLabel(22, 1072, 361, 21, "Police Siren Lights (Coming Soon!)", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["label_vip_skin_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_vip_skin_2"], "center")
	guiSetFont( gui["label_vip_skin_2"], "default-bold-small")
	
	gui["police_lights_toggle"] = guiCreateCheckBox(22, 1102, 631, 17, "Toggle Police Siren Lights", false, false, gui["scrollAreaCosmetics"])
	guiSetEnabled( gui["police_lights_toggle"], false )
	
	gui["PoliceSirenLightsComboBox"] = guiCreateComboBox(192, 1102, 171, 180,"", false, gui["scrollAreaCosmetics"])
	
	
	-- gui._placeHolders["line_10"] = {left = 2, top = 1142, width = 661, height = 20, parent = gui["scrollAreaCosmetics"]}
	-- gui["line7"] = guiCreateStaticImage( 0, 1142, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	
	gui["tab_other"] = guiCreateTab("VIP Misc", gui["vipTabs"])
	guiSetEnabled( gui["tab_other"], false )
	
	gui["scrollAreaHome_4"] = guiCreateScrollPane(20, 0, 681, 491, false, gui["tab_other"])
	

	gui["utilImage"] = guiCreateStaticImage( 140, 0, 395, 124, "img/vip_utils.png", false, gui["scrollAreaHome_4"] )
	
	-- gui._placeHolders["line_7"] = {left = 2, top = 212, width = 661, height = 20, parent = gui["scrollAreaHome_4"]}
	gui["line8"] = guiCreateStaticImage( 0, 228, 650, 1, "img/dot.jpg", false,  gui["scrollAreaHome_4"])
	
	gui["label_8"] = guiCreateLabel(12, 112, 631, 16, "Setting will automatically be saved", false, gui["scrollAreaHome_4"])
	guiSetFont( gui["label_8"], "default-small")
	guiLabelSetHorizontalAlign(gui["label_8"], "left", false)
	guiLabelSetVerticalAlign(gui["label_8"], "center")
	
	gui["joinmessage_label"] = guiCreateLabel(22, 232, 161, 21, "VIP Join Message", false, gui["scrollAreaHome_4"])
	guiLabelSetHorizontalAlign(gui["joinmessage_label"], "left", false)
	guiLabelSetVerticalAlign(gui["joinmessage_label"], "center")
	guiSetFont( gui["joinmessage_label"], "default-bold-small")
	
	-- gui._placeHolders["line_8"] = {left = 2, top = 302, width = 661, height = 20, parent = gui["scrollAreaHome_4"]}
	gui["line9"] = guiCreateStaticImage( 0, 317, 650, 1, "img/dot.jpg", false,  gui["scrollAreaHome_4"])
	
	gui["label_9"] = guiCreateLabel(22, 322, 621, 21, "VIP Personal Horn (Coming Soon!)", false, gui["scrollAreaHome_4"])
	guiLabelSetHorizontalAlign(gui["label_9"], "left", false)
	guiLabelSetVerticalAlign(gui["label_9"], "center")
	guiSetFont( gui["label_9"], "default-bold-small")

	
	-- gui._placeHolders["line_9"] = {left = 2, top = 552, width = 661, height = 20, parent = gui["scrollAreaHome_4"]}
	-- gui["line10"] = guiCreateStaticImage( 0, 562, 650, 1, "img/dot.jpg", false,  gui["scrollAreaHome_4"])
	
	-- gui._placeHolders["line_11"] = {left = 2, top = 122, width = 661, height = 20, parent = gui["scrollAreaHome_4"]}
	-- gui["line11"] = guiCreateStaticImage( 0, 122, 650, 1, "img/dot.jpg", false,  gui["scrollAreaHome_4"])
	
	gui["supernick_label"] = guiCreateLabel(22, 142, 311, 16, "Super Nickname", false, gui["scrollAreaHome_4"])
	guiLabelSetHorizontalAlign(gui["supernick_label"], "left", false)
	guiLabelSetVerticalAlign(gui["supernick_label"], "center")
	guiSetFont( gui["supernick_label"], "default-bold-small")
	
	gui["superNickButton"] = guiCreateButton(22, 172, 211, 41, "Set / Edit Super Nickname", false, gui["scrollAreaHome_4"])
	if on_superNickButton_clicked then
		addEventHandler("onClientGUIClick", gui["superNickButton"], on_superNickButton_clicked, false)
	end
	
	gui["vipJoinMessageButton"] = guiCreateButton(22, 262, 211, 41, "Set / Edit VIP join message", false, gui["scrollAreaHome_4"])
	if on_vipJoinMessageButton_clicked then
		addEventHandler("onClientGUIClick", gui["vipJoinMessageButton"], on_vipJoinMessageButton_clicked, false)
	end
	
	gui["label_10"] = guiCreateLabel(22, 342, 601, 21, "To upload your VIP horn, browse to https://mrgreengaming.com/vip/horn and follow the instructions.", false, gui["scrollAreaHome_4"])
	guiLabelSetHorizontalAlign(gui["label_10"], "left", false)
	guiLabelSetVerticalAlign(gui["label_10"], "center")
	
	gui["label_11"] = guiCreateLabel(22, 382, 471, 31, "No VIP horn uploaded.", false, gui["scrollAreaHome_4"])
	guiLabelSetHorizontalAlign(gui["label_11"], "left", false)
	guiLabelSetVerticalAlign(gui["label_11"], "center")
	
	gui["vip_horn_bind"] = guiCreateButton(182, 442, 151, 41, "Bound To KEY", false, gui["scrollAreaHome_4"])
	guiSetEnabled( gui["vip_horn_bind"], false )
	if on_vip_horn_bind_clicked then
		addEventHandler("onClientGUIClick", gui["vip_horn_bind"], on_vip_horn_bind_clicked, false)
	end
	
	gui["label_14"] = guiCreateLabel(22, 452, 151, 16, "Bind horn to key:", false, gui["scrollAreaHome_4"])
	guiLabelSetHorizontalAlign(gui["label_14"], "left", false)
	guiLabelSetVerticalAlign(gui["label_14"], "center")
	
	gui["vipBanner"] = guiCreateLabel(10, 25, 521, 41, "", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["vipBanner"], "center", false)
	guiLabelSetVerticalAlign(gui["vipBanner"], "center")
	
	gui["vipLeftLabel"] = guiCreateLabel(0, 25, windowWidth-25, 41, "You do not have VIP", false, gui["_root"])
	guiLabelSetColor(gui["vipLeftLabel"],255,0,0)
	guiLabelSetHorizontalAlign(gui["vipLeftLabel"], "right", false)
	guiLabelSetVerticalAlign(gui["vipLeftLabel"], "center")

	
	
	gui["label"] = guiCreateLabel(480, 585, 271, 31, "Go to https://mrgreengaming.com/donate to get VIP!", false, gui["_root"])
	guiSetFont( gui["label"], "default-small")
	guiLabelSetHorizontalAlign(gui["label"], "left", false)
	guiLabelSetVerticalAlign(gui["label"], "center")
	-- Something wierd causes this scrollpane scroll position to be on the bottom
	-- Fix :
	guiScrollPaneSetVerticalScrollPosition( gui["scrollAreaHome"], 0 )

	return gui, windowWidth, windowHeight
end

function onVipRainbowToggle (button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	if this == gui["Rainbow_Paintjob"] then
		local isSelected = guiCheckBoxGetSelected( gui["Rainbow_Paintjob"] )
		triggerServerEvent('onClientChangeVipRainbow', localPlayer, "paintjob",isSelected)
	elseif this == gui["Rainbow_Lights"] then
		local isSelected = guiCheckBoxGetSelected( gui["Rainbow_Lights"] )
		triggerServerEvent('onClientChangeVipRainbow', localPlayer, "lights",isSelected)
	elseif this == gui["Rainbow_Wheels"] then
		local isSelected = guiCheckBoxGetSelected( gui["Rainbow_Wheels"] )
		triggerServerEvent('onClientChangeVipRainbow', localPlayer, "wheels",isSelected)
	end

end


function lightblink_speedClick(btn, state)
	if btn~="left" or state~="up" then return end
	
	blinkingSpeed = tonumber(guiGetText(source))
	guiSetProperty(gui["Blink_Speed_1"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["Blink_Speed_2"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["Blink_Speed_3"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["Blink_Speed_4"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(source, "NormalTextColour", "FF00FF00")

	triggerServerEvent('onClientChangeLightblinkSpeed', localPlayer, blinkingSpeed)
end

function lightblink_patternClick(btn, state)
	if btn~="left" or state~="up" then return end	

	local selectedPattern = guiGetText(source)
	guiSetProperty(gui["Blink_Left_Right_Pattern"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["Blink_Cross_Pattern"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["Blink_Circle_Pattern"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(source, "NormalTextColour", "FF00FF00")

	-- Do event for blink pattern saving
	triggerServerEvent('onClientChangeLightblinkPattern', localPlayer, selectedPattern)
end

function lightblink_enableBlinking(button, state)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	
	triggerServerEvent('onClientChangeLightblinkEnabled', localPlayer, guiCheckBoxGetSelected( gui["checkbox_blink_lights"] ))
end

function onVipBadgeToggle (button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local isSelected = guiCheckBoxGetSelected( gui["vip_badge_toggle"] )
	triggerServerEvent('onClientChangeVipBadge', localPlayer, isSelected)
end





function on_vip_skin_remove_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	
	triggerServerEvent('onClientRemoveVipSkin', localPlayer)
	
end

function on_vip_skin_use_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local selectedSkin = guiGridListGetSelectedItem( gui["vip_skin_grid"] )
	if selectedSkin < 0 then
		-- None selected
		vip_outputChatBox("Please select a skin first!",255,0,0)
		return
	end
	selectedSkin = selectedSkin + 1
	triggerServerEvent('onClientUseVipSkin', localPlayer, selectedSkin)
	
end

function on_dvoid_use_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	
	local selectedOverlay = guiGridListGetSelectedItem( gui["dvoid_gridlist"] )
	if selectedOverlay < 0 then
		-- None selected
		vip_outputChatBox("Please select an overlay first!",255,0,0)
		return
	end
	selectedOverlay = selectedOverlay + 1
	triggerServerEvent('onClientSetVipOverlayType', localPlayer, selectedOverlay)
	
end

function on_dvoid_stop_using_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	
	triggerServerEvent('onClientRemoveVipOverlay', localPlayer)
	
end



function on_dvoidChangeColor_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local theColor = playerOptions.options[7].color
	if not theColor then return end
	exports.cpicker:openPicker("dvoidcolor", theColor, "Select Dynamic Overlay Color")
	
end
addEvent("onColorPickerOK",true)
addEventHandler("onColorPickerOK", root, 
function(id, hex)
	if id == "dvoidcolor" then
		sendColor = string.gsub(hex,"#","")
		triggerServerEvent('onClientSetVipOverlayColor', localPlayer, sendColor)
	end
end)


function on_superNickButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	supernick_showGUI(true)
	--TODO: Implement your button click handler here
	
end

function on_vipJoinMessageButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	joinmessage_showGUI(true)	
end

function on_vip_horn_bind_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	
	--TODO: Implement your button click handler here
	
end

function enableVipTabs(bool)
	guiSetEnabled( gui["tab_cosmetics"], bool )
	guiSetEnabled( gui["tab_other"], bool )
end


-- 1 = VIP Badge
-- 2 = Super Nickname
-- 3 = Rainbow Colors
-- 4 = Light Blink
-- 5 = VIP Character Skins
-- 6 = Police Sirens
-- 7 = Dynamic Vehicle Overlay
-- 8 = VIP Join Message
-- 9 = Personal Horn

local overlayGridListBuild = false -- To stop the skipping when an overlay is used

function populateGuiOptions(options)
	-- var_dump("-v",options)
	for optionId, value in pairs(options) do
		if optionId == 1 then
			-- vip badge
			guiCheckBoxSetSelected( gui["vip_badge_toggle"], value.enabled or false )

		elseif optionId == 2 then
			-- super nickname


		elseif optionId == 3 then
			-- Rainbow colors
			guiCheckBoxSetSelected(gui["Rainbow_Paintjob"], value.paintjob or false)
			guiCheckBoxSetSelected(gui["Rainbow_Lights"], value.lights or false)
			guiCheckBoxSetSelected(gui["Rainbow_Wheels"], value.wheels or false)
		
		elseif optionId == 4 then
			-- Light Blink
	
			
			-- Reset buttons first
			guiSetProperty(gui["Blink_Left_Right_Pattern"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["Blink_Cross_Pattern"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["Blink_Circle_Pattern"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["Blink_Speed_1"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["Blink_Speed_2"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["Blink_Speed_3"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["Blink_Speed_4"], "NormalTextColour", "FFAAAAAA")
			guiCheckBoxSetSelected(gui["checkbox_blink_lights"],value.enabled or false)

			-- Handler pattern buttons
			if value.pattern == 1 then
				guiSetProperty(gui["Blink_Left_Right_Pattern"], "NormalTextColour", "FF00FF00")
			elseif value.pattern == 2 then
				guiSetProperty(gui["Blink_Cross_Pattern"], "NormalTextColour", "FF00FF00")
			elseif value.pattern == 3 then
				guiSetProperty(gui["Blink_Circle_Pattern"], "NormalTextColour", "FF00FF00")
			end
			
			-- Handle Speed buttons
			if value.speed == 1 then
				guiSetProperty(gui["Blink_Speed_1"], "NormalTextColour", "FF00FF00")
			elseif value.speed == 2 then
				guiSetProperty(gui["Blink_Speed_2"], "NormalTextColour", "FF00FF00")
			elseif value.speed == 3 then
				guiSetProperty(gui["Blink_Speed_3"], "NormalTextColour", "FF00FF00")
			elseif value.speed == 4 then
				guiSetProperty(gui["Blink_Speed_4"], "NormalTextColour", "FF00FF00")
			end      	


		elseif optionId == 5 then
			-- Vip character skin

			populateVipSkinsGridList()
			-- Handle selected ID
			if value.skin and value.skin > 0 then
				guiGridListSetSelectedItem( gui["vip_skin_grid"], value.skin-1, 1, true )
				guiGridListSetItemColor( gui["vip_skin_grid"], value.skin-1, 2, 0, 255, 0 )
				guiGridListSetItemColor( gui["vip_skin_grid"], value.skin-1, 1, 0, 255, 0 )

			end
			local skinName = getSkinName(value.skin) or "none"
			guiSetText( gui["vip_skin_current_label"], 'Current VIP skin: '..skinName )

		elseif optionId == 6 then
			-- Police Sirens
			-- Coming Soon

		elseif optionId == 7 then
			-- Dynamic Vehicle Overlay
			
			-- Currently 32 types of dvoid
			for i=1, 32 do
				if not overlayGridListBuild then
					guiGridListAddRow( gui["dvoid_gridlist"], i )
				else
					guiGridListSetItemColor( gui["dvoid_gridlist"], i-1, 1, 255, 255, 255 )
				end
				
			end
			overlayGridListBuild = true
			guiSetText( gui["dvoid_using_label"] , "Current overlay: none" )
			if playerOptions.options[7].style then
				guiSetText( gui["dvoid_using_label"] , "Current overlay: "..playerOptions.options[7].style )
				guiGridListSetSelectedItem( gui["dvoid_gridlist"], playerOptions.options[7].style-1, 1 )
				guiGridListSetItemColor( gui["dvoid_gridlist"], playerOptions.options[7].style-1, 1, 0, 255, 0 )
			end

			-- Color
			local hex = "FF"..playerOptions.options[7].color
			local isSet = guiSetProperty (gui["dvoid_color"], "ImageColours", "tl:"..hex.." tr:"..hex.." bl:"..hex.." br:"..hex )


		elseif optionId == 8 then
			-- Vip Join Message
			setVipJoinMessage()
		elseif optionId == 9 then
			-- Personal horn

		end
	end 
end

function handleVipTimeLeftLabel()
	if not guiGetVisible( gui["_root"] ) then return end

	if playerOptions and playerOptions.timestamp and gui and gui["vipLeftLabel"] then
		local timeNow = getRealTime().timestamp
		local vipTime = tonumber(playerOptions.timestamp)
		if timeNow > vipTime then
			guiSetText( gui["vipLeftLabel"], "You do not have VIP" )
			guiLabelSetColor(gui["vipLeftLabel"],255,0,0)
		else
			local diff = vipTime - timeNow
			local timeString = secondsToTimeDesc(diff)
			guiSetText( gui["vipLeftLabel"], "You have "..timeString.." of VIP left" )
			guiLabelSetColor(gui["vipLeftLabel"],0,255,0)
		end
	end
end


addEventHandler("onClientResourceStart",resourceRoot,
	function() 
		
		build_mainVipWindow() 
	end
)


function showMainWindow ()
	guiSetVisible( gui["_root"], not guiGetVisible( gui["_root"] ) )
	showCursor( guiGetVisible( gui["_root"] ) or false )
end
bindKey("F7","down",showMainWindow)









