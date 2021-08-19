GUIEditor = {
    window = {},
    staticimage = {},
    label = {}
}

function build_mainVipWindow()
	
	gui = {}
	gui._placeHolders = {}
	
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 750, 616
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2

	gui["_root"] = guiCreateStaticImage(left, top, windowWidth, windowHeight, "img/dot.jpg", false)
	guiSetProperty(gui["_root"], "ImageColours", "tl:FF0A0A0A tr:FF0A0A0A bl:FF0A0A0A br:FF0A0A0A") 
	GUIEditor.staticimage[2] = guiCreateStaticImage(0, 0, 854, 10, "img/dot.jpg", false, gui["_root"])
	guiSetProperty(GUIEditor.staticimage[2], "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	GUIEditor.staticimage[3] = guiCreateStaticImage(0, 10, 854, 10, "img/dot.jpg", false, gui["_root"])
	guiSetProperty(GUIEditor.staticimage[3], "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	GUIEditor.label[1] = guiCreateLabel(310, 1, 128, 16, "Mr. Green VIP Panel", false, gui["_root"])
	guiSetFont(GUIEditor.label[1], "default-bold-small")
	guiSetProperty(GUIEditor.label[1], "AlwaysOnTop", "true")
	guiLabelSetColor(GUIEditor.label[1], 255, 255, 255)
	guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[1], "center") 
	guiSetVisible( gui["_root"], false )
	
	gui["vipTabs"] = guiCreateTabPanel(10, 70, 730, 521, false, gui["_root"])
	
	gui["tab_home"] = guiCreateTab("Home", gui["vipTabs"])
	
	gui["scrollAreaHome"] = guiCreateScrollPane(20, 0, 681, 491, false, gui["tab_home"])

	
	gui["labelHome"] = guiCreateLabel(12, 112, 641, 350, "What is VIP?\n--------------------\nVIP is a special status that grants exclusive features and discounts to players.\n\nWhat is included in VIP?\n-------------------------------\n- Forum, ingame and discord VIP tags.\n- Car paintjob and wheels rainbow (Continuously changing colors)\n- +50% GreenCoins for finishing or winning a map.\n- Custom join message (A global chat message when you join the server)\n- 10% off all GC shop items\n- Super Nickname (Your nickname can have 22 characters and unlimited colors)\n- Blinking lights (Have blinking vehicle lights in a pattern)\n- Exclusive VIP character models\n- Exclusive VIP horn (upload your own private horn)\n- Police Sirens\n- Dynamic Vehicle Overlay (Fancy vehicle overlay that reacts to sound)\n- More features coming soon!\n\n", false, gui["scrollAreaHome"])
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
	gui["vip_skin_grid_col0"] = guiGridListAddColumn(gui["vip_skin_grid"], "ID", 0.2)
	gui["vip_skin_grid_col1"] = guiGridListAddColumn(gui["vip_skin_grid"], "Name", 0.5)
	
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


	gui["dvoid_gridlist"] = guiCreateGridList(22, 882, 111, 185, false, gui["scrollAreaCosmetics"])
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
	
	gui["dvoid_stop_using"] = guiCreateButton(142, 1006, 151, 61, "Stop Using Overlay", false, gui["scrollAreaCosmetics"])
	-- guiSetEnabled( gui["dvoid_stop_using"], false )
	if on_dvoid_stop_using_clicked then
		addEventHandler("onClientGUIClick", gui["dvoid_stop_using"], on_dvoid_stop_using_clicked, false)
	end

	gui["dvoid_intensity_low"] = guiCreateButton(302, 972, 80, 30, "Low\n Intensity", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_intensity_low"], on_dvoid_intensity, false)
	gui["dvoid_intensity_medium"] = guiCreateButton(392, 972, 80, 30, "Medium\n Intensity", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_intensity_medium"], on_dvoid_intensity, false)
	gui["dvoid_intensity_high"] = guiCreateButton(482, 972, 80, 30, "High\n Intensity", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_intensity_high"], on_dvoid_intensity, false)
	gui["dvoid_intensity_max"] = guiCreateButton(572, 972, 80, 30, "Max\n Intensity", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_intensity_max"], on_dvoid_intensity, false)

	gui["dvoid_opacity_low"] = guiCreateButton(302, 1005, 80, 30, "Low\n Opacity", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_opacity_low"], on_dvoid_opacity, false)
	gui["dvoid_opacity_medium"] = guiCreateButton(392, 1005, 80, 30, "Medium\n Opacity", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_opacity_medium"], on_dvoid_opacity, false)
	gui["dvoid_opacity_high"] = guiCreateButton(482, 1005, 80, 30, "High\n Opacity", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_opacity_high"], on_dvoid_opacity, false)
	gui["dvoid_opacity_max"] = guiCreateButton(572, 1005, 80, 30, "Max\n Opacity", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_opacity_max"], on_dvoid_opacity, false)
	
	gui["dvoid_speed_low"] = guiCreateButton(302, 1038, 80, 30, "Low\n Speed", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_speed_low"], on_dvoid_speed, false)
	gui["dvoid_speed_medium"] = guiCreateButton(392, 1038, 80, 30, "Medium\n Speed", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_speed_medium"], on_dvoid_speed, false)
	gui["dvoid_speed_high"] = guiCreateButton(482, 1038, 80, 30, "High\n Speed", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_speed_high"], on_dvoid_speed, false)
	gui["dvoid_speed_max"] = guiCreateButton(572, 1038, 80, 30, "Max\n Speed", false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["dvoid_speed_max"], on_dvoid_speed, false)
	
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
	gui["line6"] = guiCreateStaticImage( 0, 1086, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	
	gui["wheelchange_label"] = guiCreateLabel(22, 1106, 361, 21, "Wheel changing", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["wheelchange_label"], "left", false)
	guiLabelSetVerticalAlign(gui["wheelchange_label"], "center")
	guiSetFont( gui["wheelchange_label"], "default-bold-small")
	
	gui["wheelchange_toggle"] = guiCreateCheckBox(22, 1136, 631, 17, "Toggle wheel changing", false, false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["wheelchange_toggle"], onWheelChangingToggle, false)
	
	gui["line7"] = guiCreateStaticImage( 0, 1186, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"])
	
	gui["label_vip_skin_2"] = guiCreateLabel(22, 1206, 361, 21, "Police Siren Lights", false, gui["scrollAreaCosmetics"])
	guiLabelSetHorizontalAlign(gui["label_vip_skin_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_vip_skin_2"], "center")
	guiSetFont( gui["label_vip_skin_2"], "default-bold-small")
	
	gui["police_lights_toggle"] = guiCreateCheckBox(22, 1236, 631, 17, "Toggle Police Siren Lights", false, false, gui["scrollAreaCosmetics"])
	addEventHandler("onClientGUIClick", gui["police_lights_toggle"], onPoliceSirenToggle, false)
	
	guiCreateStaticImage( 0, 1350, 650, 1, "img/dot.jpg", false,  gui["scrollAreaCosmetics"]) -- Line used for margin
	
	
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
	
	gui["label_9"] = guiCreateLabel(22, 322, 621, 21, "VIP Personal Horn", false, gui["scrollAreaHome_4"])
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
	
	gui["label_10"] = guiCreateLabel(22, 342, 601, 21, "To upload/delete your VIP horn(s), browse to https://mrgreengaming.com/viphorns and follow the instructions.", false, gui["scrollAreaHome_4"])
	guiLabelSetHorizontalAlign(gui["label_10"], "left", false)
	guiLabelSetVerticalAlign(gui["label_10"], "center")
	
	gui['vipHornDoubleClickLabel'] = guiCreateLabel(22, 368, 600, 20, 'Double click to preview the horn', false, gui["scrollAreaHome_4"])
	guiSetFont( gui['vipHornDoubleClickLabel'], 'default-small' )
	
	gui['vipHornGridList'] = guiCreateGridList( 22, 385, 300, 200,false ,gui["scrollAreaHome_4"] )
	guiGridListAddColumn( gui['vipHornGridList'], 'Horn', 0.75 )
	guiGridListAddColumn( gui['vipHornGridList'], 'Key', 0.16 )
	guiGridListSetSortingEnabled ( gui['vipHornGridList'], false )
	addEventHandler( "onClientGUIDoubleClick", gui['vipHornGridList'], previewVipHorn, false )

	
	gui["vip_horn_bind"] = guiCreateButton(355, 384, 175, 60, "Bind selected horn to key", false, gui["scrollAreaHome_4"])
	if on_vip_horn_bind_clicked then
		addEventHandler("onClientGUIClick", gui["vip_horn_bind"], on_vip_horn_bind_clicked, false)
	end


	gui["line11"] = guiCreateStaticImage( 0, 800, 650, 1, "img/dot.jpg", false,  gui["scrollAreaHome_4"])
	
	gui["vipBanner"] = guiCreateLabel(10, 25, 521, 41, "", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["vipBanner"], "center", false)
	guiLabelSetVerticalAlign(gui["vipBanner"], "center")
	
	gui["vipLeftLabel"] = guiCreateLabel(0, 25, windowWidth-25, 41, "You do not have VIP", false, gui["_root"])
	guiLabelSetColor(gui["vipLeftLabel"],255,0,0)
	guiLabelSetHorizontalAlign(gui["vipLeftLabel"], "right", false)
	guiLabelSetVerticalAlign(gui["vipLeftLabel"], "center")
	guiSetFont(gui["vipLeftLabel"], "default-bold-small")
	
	
	gui["label"] = guiCreateLabel(480, 585, 271, 31, "Go to https://mrgreengaming.com/donate to get VIP!", false, gui["_root"])
	guiSetFont( gui["label"], "default-small")
	guiLabelSetHorizontalAlign(gui["label"], "left", false)
	guiLabelSetVerticalAlign(gui["label"], "center")
	-- Something wierd causes this scrollpane scroll position to be on the bottom
	-- Fix :
	guiScrollPaneSetVerticalScrollPosition( gui["scrollAreaHome"], 0 )

	return gui, windowWidth, windowHeight
end

-- moving the window

local isWindowClicked = false
local windowOffsetPos = false
addEventHandler( "onClientGUIMouseDown", getRootElement( ),
    function ( btn, x, y )
        if btn == "left" and (source == GUIEditor.staticimage[2] or source == GUIEditor.staticimage[3]) then
            isWindowClicked = true
            local elementPos = { guiGetPosition( gui["_root"], false ) }
            windowOffsetPos = { x - elementPos[ 1 ], y - elementPos[ 2 ] }; -- get the offset position
        end
    end
)

addEventHandler( "onClientGUIMouseUp", getRootElement( ),
    function ( btn, x, y )
        if btn == "left" then
            isWindowClicked = false
        end
    end
)

addEventHandler( "onClientCursorMove", getRootElement( ),
    function ( _, _, x, y )
        if isWindowClicked and windowOffsetPos then
            guiSetPosition( gui["_root"], x - windowOffsetPos[ 1 ], y - windowOffsetPos[ 2 ], false )
        end
    end
)

---

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

function onWheelChangingToggle(button, state)
	if button ~= "left" or state ~= "up" then return end

	local selected = guiCheckBoxGetSelected(gui["wheelchange_toggle"])
	triggerServerEvent('onClientToggleWheelChange', localPlayer, selected)
end

function onPoliceSirenToggle(button, state)
	if button ~= "left" or state ~= "up" then return end

	local selected = guiCheckBoxGetSelected(gui["police_lights_toggle"])
	triggerServerEvent('onClientTogglePoliceSiren', localPlayer, selected)
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

function on_dvoid_intensity(btn, state)
	if btn~="left" or state~="up" then return end	
	guiSetProperty(gui["dvoid_intensity_low"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["dvoid_intensity_medium"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["dvoid_intensity_high"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["dvoid_intensity_max"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(source, "NormalTextColour", "FF00FF00")
	local chosen = false
	if source == gui["dvoid_intensity_low"] then
		chosen = 1
	elseif source == gui["dvoid_intensity_medium"] then
		chosen = 2
	elseif source == gui["dvoid_intensity_high"] then
		chosen = 3
	elseif source == gui["dvoid_intensity_max"] then
		chosen = 4
	end
	-- Do event for saving intensity
	triggerServerEvent('onClientSetVipOverlayIntensity', localPlayer, chosen)
end

function on_dvoid_opacity(btn, state)
	if btn~="left" or state~="up" then return end	
	guiSetProperty(gui["dvoid_opacity_low"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["dvoid_opacity_medium"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["dvoid_opacity_high"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["dvoid_opacity_max"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(source, "NormalTextColour", "FF00FF00")
	local chosen = false
	if source == gui["dvoid_opacity_low"] then
		chosen = 1
	elseif source == gui["dvoid_opacity_medium"] then
		chosen = 2
	elseif source == gui["dvoid_opacity_high"] then
		chosen = 3
	elseif source == gui["dvoid_opacity_max"] then
		chosen = 4
	end
	-- Do event for saving intensity
	triggerServerEvent('onClientSetVipOverlayOpacity', localPlayer, chosen)
end

function on_dvoid_speed(btn, state)
	if btn~="left" or state~="up" then return end	
	guiSetProperty(gui["dvoid_speed_low"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["dvoid_speed_medium"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["dvoid_speed_high"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(gui["dvoid_speed_max"], "NormalTextColour", "FFAAAAAA")
	guiSetProperty(source, "NormalTextColour", "FF00FF00")
	local chosen = false
	if source == gui["dvoid_speed_low"] then
		chosen = 1
	elseif source == gui["dvoid_speed_medium"] then
		chosen = 2
	elseif source == gui["dvoid_speed_high"] then
		chosen = 3
	elseif source == gui["dvoid_speed_max"] then
		chosen = 4
	end
	-- Do event for saving intensity
	triggerServerEvent('onClientSetVipOverlaySpeed', localPlayer, chosen)
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
	local selected = guiGridListGetSelectedItem( gui['vipHornGridList'] )
	if not selected or selected == -1 then
		outputChatBox('Select a custom horn first!',255,0,0)
		return
	end
	
	bindVipHorn(selected)
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
			guiCheckBoxSetSelected( gui["police_lights_toggle"], value.enabled or false )
		elseif optionId == 7 then
			-- Dynamic Vehicle Overlay
			
			-- Currently 32 types of dvoid
			for i=1, 51 do
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

			-- Intensity
			
			guiSetProperty(gui["dvoid_intensity_low"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["dvoid_intensity_medium"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["dvoid_intensity_high"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["dvoid_intensity_max"], "NormalTextColour", "FFAAAAAA")
			local intensity = playerOptions.options[7].intensity
			if not intensity then intensity = 2 end
			
			if intensity == 1 then
				guiSetProperty(gui["dvoid_intensity_low"], "NormalTextColour", "FF00FF00")
			elseif intensity == 2 then
				guiSetProperty(gui["dvoid_intensity_medium"], "NormalTextColour", "FF00FF00")
			elseif intensity == 3 then
				guiSetProperty(gui["dvoid_intensity_high"], "NormalTextColour", "FF00FF00")
			elseif intensity == 4 then
				guiSetProperty(gui["dvoid_intensity_max"], "NormalTextColour", "FF00FF00")
			end

			-- Opacity
			
			guiSetProperty(gui["dvoid_opacity_low"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["dvoid_opacity_medium"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["dvoid_opacity_high"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["dvoid_opacity_max"], "NormalTextColour", "FFAAAAAA")
			local opacity = playerOptions.options[7].opacity
			if not opacity then opacity = 2 end
			
			if opacity == 1 then
				guiSetProperty(gui["dvoid_opacity_low"], "NormalTextColour", "FF00FF00")
			elseif opacity == 2 then
				guiSetProperty(gui["dvoid_opacity_medium"], "NormalTextColour", "FF00FF00")
			elseif opacity == 3 then
				guiSetProperty(gui["dvoid_opacity_high"], "NormalTextColour", "FF00FF00")
			elseif opacity == 4 then
				guiSetProperty(gui["dvoid_opacity_max"], "NormalTextColour", "FF00FF00")
			end

			-- Speed
			
			guiSetProperty(gui["dvoid_speed_low"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["dvoid_speed_medium"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["dvoid_speed_high"], "NormalTextColour", "FFAAAAAA")
			guiSetProperty(gui["dvoid_speed_max"], "NormalTextColour", "FFAAAAAA")
			local speed = playerOptions.options[7].speed
			if not speed then speed = 2 end
			
			if speed == 1 then
				guiSetProperty(gui["dvoid_speed_low"], "NormalTextColour", "FF00FF00")
			elseif speed == 2 then
				guiSetProperty(gui["dvoid_speed_medium"], "NormalTextColour", "FF00FF00")
			elseif speed == 3 then
				guiSetProperty(gui["dvoid_speed_high"], "NormalTextColour", "FF00FF00")
			elseif speed == 4 then
				guiSetProperty(gui["dvoid_speed_max"], "NormalTextColour", "FF00FF00")
			end

		elseif optionId == 8 then
			-- Vip Join Message
			setVipJoinMessage()
		elseif optionId == 9 then
			-- Personal horn
		elseif optionId == 11 then
			guiCheckBoxSetSelected( gui["wheelchange_toggle"], value.enabled or false )
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


function showvip ()
	guiSetVisible( gui["_root"], not guiGetVisible( gui["_root"] ) )
	showCursor( guiGetVisible( gui["_root"] ) or false )
end
bindKey("F7","down",showvip)







