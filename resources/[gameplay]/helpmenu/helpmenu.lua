--Settings
local screenW, screenH = guiGetScreenSize()
local windowW, windowH = 840, 570
local left = screenW/2 - windowW/2
local top = screenH/2 - windowH/2
local tabpanelW, tabpanelH = windowW-50, windowH-130
local motdIndent = 20
local motdW, motdH = 0.45*(tabpanelW-motdIndent), tabpanelH-(motdIndent*3.3)
local logoW, logoH = 350, 137
local adminColumnN1posX = motdIndent*2.5+motdW
local adminColumnN2posX = adminColumnN1posX+0.5*(tabpanelW-(motdIndent*4+motdW))
local adminColumnW, adminColumnH = adminColumnN2posX-adminColumnN1posX, 20
local offlineColor = { r = 100, g = 100, b = 100 }
local onlineColor = { r = 0, g = 255, b = 0 }
	
	
function showhideGUI()
	if not guiGetVisible(MainWindow) then
		triggerServerEvent('requestChangelog', resourceRoot)
		triggerServerEvent('requestAdmins', resourceRoot)
		guiSetVisible(MainWindow, true)
		showCursor(true)
	else
		guiSetVisible(MainWindow, false)
		showCursor(false)
	end
end
bindKey("F9", "up", showhideGUI)

function buildGUI()	
	MainWindow = guiCreateWindow(left, top, windowW, windowH, "Welcome!", false)
	guiWindowSetSizable(MainWindow, false)
	
	TabPanel = guiCreateTabPanel( 0.5*(windowW-tabpanelW), 0.08*windowH, tabpanelW, tabpanelH, false, MainWindow)
	
	AboutTab = guiCreateTab("About", TabPanel)
	
	MotdMemo = guiCreateMemo(motdIndent, motdIndent, motdW, motdH, "Welcome to the Mr. Green MTA servers!", false, AboutTab)
	guiMemoSetReadOnly(MotdMemo,true)
	
	MrGreenLogo = guiCreateStaticImage( (motdIndent+motdW)+0.5*(tabpanelW-(motdIndent+motdW)-logoW), tabpanelH*0.08, 350, 137, ":helpmenu/img/logo.png", false, AboutTab)
	
	StaffTitle = guiCreateLabel(motdW, tabpanelH*0.45, tabpanelW-(motdIndent+motdW), 20, "Mr Green Gaming Staff", false, AboutTab)
	guiSetFont(StaffTitle, "default-bold-small")
	guiLabelSetHorizontalAlign(StaffTitle, "center", false)
	guiLabelSetColor(StaffTitle, 0, 255, 0)
	
	local multiplierX = 1.0
	local multiplierY = 0.88
	offline = guiCreateLabel(adminColumnN1posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, "•          ", false, AboutTab)
	guiLabelSetColor(offline, offlineColor.r, offlineColor.g, offlineColor.b)
	guiLabelSetHorizontalAlign(offline, "right", false)
	offline2 = guiCreateLabel(adminColumnN1posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, "offline ", false, AboutTab)
	guiLabelSetHorizontalAlign(offline2, "right", false)
	
	online = guiCreateLabel(adminColumnN2posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, " •", false, AboutTab)
	guiLabelSetColor(online, onlineColor.r, onlineColor.g, onlineColor.b)
	guiCreateLabel(adminColumnN2posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, "   online", false, AboutTab)

	local m = 0
	for i=1, math.ceil(#admins/2) do --column #1
		m = m + 20
		guiCreateLabel(adminColumnN1posX, tabpanelH*0.45+m, adminColumnW, adminColumnH, admins[i].name.." - "..admins[i].title, false, AboutTab)
		admins[i].label = guiCreateLabel(adminColumnN1posX-10, tabpanelH*0.45+m, adminColumnW, adminColumnH, "•", false, AboutTab)
		guiLabelSetColor(admins[i].label, offlineColor.r, offlineColor.g, offlineColor.b)
	end
	
	local m = 0
	for i=math.ceil(#admins/2)+1, #admins do --column #2
		m = m + 20
		guiCreateLabel(adminColumnN2posX, tabpanelH*0.45+m, adminColumnW, adminColumnH, admins[i].name.." - "..admins[i].title, false, AboutTab)
		admins[i].label = guiCreateLabel(adminColumnN2posX-10, tabpanelH*0.45+m, adminColumnW, adminColumnH, "•", false, AboutTab)
		guiLabelSetColor(admins[i].label, offlineColor.r, offlineColor.g, offlineColor.b)
	end
	
	CommandsBindsTab = guiCreateTab("Commands & Binds", TabPanel)
	
	CommandsBindsMemoText = guiCreateMemo(motdIndent, motdIndent, tabpanelW-motdIndent*2, motdH, "                           _______________________________ BINDS _________________________________", false, CommandsBindsTab)
	guiMemoSetReadOnly(CommandsBindsMemoText,true)

	local cmdFile = fileOpen('commands.txt', true)
	if cmdFile then
		cmdsText = fileRead(cmdFile, fileGetSize(cmdFile))
		guiSetText(CommandsBindsMemoText, cmdsText)
		fileClose(cmdFile)
	end
	
	LogBindsTab = guiCreateTab("Changelog", TabPanel)
	
	ChangeLogUpdates = guiCreateLabel(268, 48, 20, 20, "*", false, MainWindow)
    guiLabelSetColor(ChangeLogUpdates, 253, 0, 0)
	guiSetProperty(ChangeLogUpdates, "AlwaysOnTop", "True")
	guiSetVisible(ChangeLogUpdates, false)
	
	addEventHandler("onClientGUIClick", TabPanel, function() guiSetVisible(ChangeLogUpdates, false) end, false)
	
	LogBindsMemoText = guiCreateMemo(motdIndent, motdIndent, tabpanelW-motdIndent*2, motdH, "Changelog currently isn't available for a some reason. Try to reconnect or check this tab a bit later", false, LogBindsTab)
	guiMemoSetReadOnly(LogBindsMemoText, true)

	RulesFaqsTab = guiCreateTab("Rules & FAQs", TabPanel)

    RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                         _____ Rules _____\n\n\n  1. Do not cheat, hack or exploit to get any advantage\n\n  2. Do not insult or provoke any players or admins\n\n  3. Do not block other players or camp in DD and SH\n\n  4. Do not flood or spam the main chat\n\n  5. Do not advertise other servers\n\n  6. Do not TeamKill in CTF\n\n  7. Do not deliberately lock other people's name\n\n  Breaking any of these rules may result in ban.\n\n", false, RulesFaqsTab)
    FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n          _____ Frequently Asked Questions _____\n\n\n  Q: What are GreenCoins?\n  \n  A: GreenCoins are our community currency, you can         use them on all of our servers.\n\n  Q: How do win GreenCoins?\n\n  A: You win GreenCoins by simply playing on our servers     you can also donate to get GreenCoins in return.\n\n  Q: What can I buy on this server with GreenCoins?\n\n  A: You can buy Perks, Maps, Custom Horns, Skins             and you can modify your vehicle on our GC Shop - F6\n\n If you have any other questions refer them to our staff", false, RulesFaqsTab)
	guiMemoSetReadOnly(RulesMemo, true)
	guiMemoSetReadOnly(FaqsMemo, true)
	
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
end
addEventHandler("onClientResourceStart", resourceRoot, buildGUI)


addEvent('receiveAdmins', true)
addEventHandler('receiveAdmins', resourceRoot, 
function ( onlineAdmins )
	for k, v in pairs(onlineAdmins) do
		if onlineAdmins[k] == true then
			guiLabelSetColor(admins[k].label, onlineColor.r, onlineColor.g, onlineColor.b)
		else
			guiLabelSetColor(admins[k].label, offlineColor.r, offlineColor.g, offlineColor.b)
		end
	end
end
)

addEvent('receiveChangelog', true)
addEventHandler('receiveChangelog', resourceRoot, 
function ( changelog, changelogLastUpdate )
	if not changelog then return end
	
	guiSetText(LogBindsMemoText, changelog)
	
	if isNewChangelog(changelogLastUpdate) then
		guiSetVisible(ChangeLogUpdates, true)
		outputChatBox("Changelog updated, press F9 to see what's new", 0, 255, 0)
	end
end
)

local changelogFile = '@changelog.xml'
function isNewChangelog(changelogLastUpdate)
	local setting = fileExists(changelogFile) and xmlLoadFile(changelogFile) or xmlCreateFile(changelogFile, 'settings')
	local new = false
	if xmlNodeGetAttribute(setting, 'changelogLastUpdate') ~= changelogLastUpdate then
		xmlNodeSetAttribute(setting, 'changelogLastUpdate', changelogLastUpdate)
		xmlSaveFile(setting)
		new = true
	end
	xmlUnloadFile(setting)
	return new
end



addEvent('receiveMotd', true)
addEventHandler('receiveMotd', resourceRoot, 
function ( motdText, motdVersion )
	guiSetText(MotdMemo, motdText)
	
	if isNewMotd(motdVersion) then
		showhideGUI()
	end
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
end
)