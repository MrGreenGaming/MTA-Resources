function showhideGUI()
	if not guiGetVisible(MainWindow) then
		guiSetVisible(MainWindow, true)
		showCursor(true)
	else
		guiSetVisible(MainWindow, false)
		showCursor(false)
	end
	
end
bindKey("f9","up",showhideGUI)

function buildGUI()

	
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 812, 567
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	MainWindow = guiCreateWindow(left, top, windowWidth, windowHeight, "Welcome!", false)
	guiWindowSetSizable(MainWindow, false)
	
	frame_placeholder = {left = 10, top = 25, width = 791, height = 521, parent = MainWindow}
	
	TabPanel = guiCreateTabPanel(30, 45, 751, 441, false, MainWindow)
	
	AboutTab = guiCreateTab("About", TabPanel)
	
	MotdMemo = guiCreateMemo(20, 20, 361, 371, "Welcome to the Mr. Green MTA servers!", false, AboutTab)
	guiMemoSetReadOnly(MotdMemo,true)
	
	graphicsView_placeholder = {left = 400, top = 30, width = 321, height = 161, parent = AboutTab}
	
	frame3_placeholder = {left = 399, top = 209, width = 321, height = 171, parent = AboutTab}
	
	StaffTitle = guiCreateLabel(484, 200, 151, 20, "   Mr Green Gaming Staff", false, AboutTab)
	guiSetFont(StaffTitle, "default-bold-small")
	guiLabelSetHorizontalAlign(StaffTitle, "left", false)
	guiLabelSetVerticalAlign(StaffTitle, "center")
	guiLabelSetColor(StaffTitle, 0, 255, 0)

	MrGreenLogo = guiCreateStaticImage(391, 49, 350, 137, ":helpmenu/img/logo.png", false, AboutTab)
	
	guiCreateLabel(405, 230, 180, 20, "Ywa - Founder/Owner", false, AboutTab)
	guiCreateLabel(405, 250, 180, 20, "Flipper - Manager", false, AboutTab)
	guiCreateLabel(405, 270, 180, 20, "AleksCore - Developer", false, AboutTab)
	guiCreateLabel(405, 290, 180, 20, "Bob_Taylor - Map Manager", false, AboutTab)
	guiCreateLabel(405, 310, 180, 20, "Cena - Map Manager", false, AboutTab)
	guiCreateLabel(405, 330, 180, 20, "MoshPit - Map Assistant", false, AboutTab)
	-- guiCreateLabel(405, 350, 180, 20, "MoshPit - Map Assistant", false, AboutTab)
	guiCreateLabel(585, 230, 180, 20, "Jack123 - Mother Russia", false, AboutTab)
	guiCreateLabel(585, 250, 180, 20, "Stig - Niu Admin", false, AboutTab)
	guiCreateLabel(585, 270, 180, 20, "F1MADKILLER - Mad Admin", false, AboutTab)
	guiCreateLabel(585, 290, 180, 20, "Hulpje - Dota Admin", false, AboutTab)
	guiCreateLabel(585, 310, 180, 20, "Goldberg - Event Admin", false, AboutTab)
	guiCreateLabel(585, 330, 180, 20, "Besweeet - 4th Admin", false, AboutTab)
	-- guiCreateLabel(585, 350, 180, 20, "neox. - Map Assistant", false, AboutTab)
	
	CommandsBindsTab = guiCreateTab("Commands & Binds", TabPanel)
	
	CommandsBindsMemoText = guiCreateMemo(20, 20, 711, 371, "                           _______________________________ BINDS _________________________________", false, CommandsBindsTab)
	guiMemoSetReadOnly(CommandsBindsMemoText,true)

	local cmdFile = fileOpen('commands.txt', true)
	if cmdFile then
		cmdsText = fileRead(cmdFile, fileGetSize(cmdFile))
		guiSetText(CommandsBindsMemoText, cmdsText)
		fileClose(cmdFile)
	end
	
	LogBindsTab = guiCreateTab("Changelog", TabPanel)
	
	LogBindsMemoText = guiCreateMemo(20, 20, 711, 371, "Changelog currently isn't available for a some reason. Try to reconnect or check this tab a bit later", false, LogBindsTab)
	guiMemoSetReadOnly(LogBindsMemoText, true)

	EventsTab = guiCreateTab("Events", TabPanel)
	
	frame2_placeholder = {left = 320, top = 160, width = 121, height = 61, parent = EventsTab}
	
	EventsMemoText = guiCreateLabel(330, 170, 101, 41, " More info soon", false, EventsTab)
	
	guiSetFont(EventsMemoText, "default-bold-small")
	guiLabelSetHorizontalAlign(EventsMemoText, "left", false)
	guiLabelSetVerticalAlign(EventsMemoText, "center")

	RulesFaqsTab = guiCreateTab("Rules & FAQs", TabPanel)

    RulesMemo = guiCreateMemo(22, 20, 331, 370, "\n\n                         _____ Rules _____\n\n\n  1. Do not cheat, hack or exploit to get any advantage\n\n  2. Do not insult or provoke any players or admins\n\n\n  3. Do not block other players or camp in DD and SH\n\n\n  4. Do not flood or spam the main chat\n\n\n  5. Do not advertise other servers\n\n\n   6. Do not TeamKill in CTF\n\n\n  7. Do not deliberately lock other people's name\n\n\n   8. Do not use tags of clans you are not in\n\n\n    \n        Breaking any of these rules may result in ban.\n\n", false, RulesFaqsTab)
    FaqsMemo = guiCreateMemo(398, 20, 331, 370, "    \n          \n            _____ Frequently Asked Questions _____\n\n\n  Q: What are GreenCoins?\n  \n  A: GreenCoins are our community currency, you can           use them on all of our servers.\n\n  Q: How do win GreenCoins?\n\n  A: You win GreenCoins by simply playing on our servers       you can also donate to get GreenCoins in return.\n\n  Q: What can I buy on this server with GreenCoins?\n\n  A: You can buy Perks, Maps, Custom Horns, Skins             and you can modify your vehicle on our GC Shop - F6\n\n If you have any other questions refer them to our staff", false, RulesFaqsTab)

	
	CloseButton = guiCreateButton(640, 505, 131, 41, "Close", false, MainWindow)
	if on_pushButton_clicked then
		addEventHandler("onClientGUIClick", CloseButton, on_pushButton_clicked, false)
	end
	
	SwitchButton = guiCreateButton(300, 505, 131, 41, "Switch server", false, MainWindow)
	addEventHandler("onClientGUIClick", SwitchButton, function() triggerServerEvent('onRequestRedirect', localPlayer) end, false)
	
	SettingsButton = guiCreateButton(40, 505, 131, 41, "Settings", false, MainWindow)
	if on_pushButton_2_clicked then
		addEventHandler("onClientGUIClick", SettingsButton, on_pushButton_2_clicked, false)
	end
	guiSetVisible(MainWindow, false)
	triggerServerEvent('requestMOTD', resourceRoot)
	triggerServerEvent('requestChangelog', resourceRoot)
	setTimer(triggerServerEvent, 10*60*1000, 0, 'requestChangelog', resourceRoot)
	return gui, windowWidth, windowHeight
end
addEventHandler("onClientResourceStart", resourceRoot, buildGUI)


addEvent('receiveMotd', true)
addEventHandler('receiveMotd', resourceRoot, 
function ( motdText, motdVersion )
	guiSetText(MotdMemo, motdText)
	
	if isNewMotd(motdVersion) then
		showhideGUI()
	end
end
)

addEvent('receiveChangelog', true)
addEventHandler('receiveChangelog', resourceRoot, 
function ( changelog )
	guiSetText(LogBindsMemoText, changelog)
end
)

local settingsFile = '@settings.xml'
function isNewMotd(motdVersion)
	local setting = fileExists(settingsFile) and xmlLoadFile(settingsFile) or xmlCreateFile(settingsFile, 'settings')
	local new = false
	if tonumber(xmlNodeGetAttribute(setting, 'version')) ~= motdVersion then
		xmlNodeSetAttribute(setting, 'version', motdVersion)
		xmlSaveFile(setting)
		new = true
	end
	xmlUnloadFile(setting)
	return new
end

function editmotd()
	guiMemoSetReadOnly(MotdMemo,false)
end
addCommandHandler('editmotd', editmotd)

function savemotd()
	guiMemoSetReadOnly(MotdMemo,true)
	triggerServerEvent('savemotd', resourceRoot, guiGetText(MotdMemo) )
end
addCommandHandler('savemotd', savemotd)

function on_pushButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then return end
	showhideGUI()
end

function on_pushButton_2_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then return end
	executeCommandHandler("settings")	
end

addEvent("sb_showHelp")
addEventHandler("sb_showHelp",root,function()
	if not guiGetVisible(MainWindow) then
		guiSetVisible(MainWindow, true)
		showCursor(true)
		guiSetSelectedTab(TabPanel,RulesFaqsTab)
	else
		guiSetVisible(MainWindow, false)
		showCursor(false)
	end

	
	end)

addEvent("sb_showServerInfo")
addEventHandler("sb_showServerInfo",root,function()
	if not guiGetVisible(MainWindow) then
		guiSetVisible(MainWindow, true)
		showCursor(true)
		guiSetSelectedTab(TabPanel,AboutTab)
	else
		guiSetVisible(MainWindow, false)
		showCursor(false)
	end

	
	end)
