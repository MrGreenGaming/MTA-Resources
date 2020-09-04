GUIEditor = {
    window = {},
    staticimage = {},
    label = {}
}

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
local languageTabs = {}
local _guiSetVisible = guiSetVisible
function guiSetVisible(element, state)
	if element == MainWindow and getResourceState(getResourceFromName('blur_box')) == 'running' then
		if MainWindowBlur then exports.blur_box:destroyBlurBox(MainWindowBlur) end
		if state == true then
			MainWindowBlur = exports.blur_box:createBlurBox( 0, 0,  screenW, screenH, 255, 255, 255, 255, true )
			MainWindowBlurIntensity = exports.blur_box:setBlurIntensity(2.5)
		end
	end
	_guiSetVisible(element, state)
end

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

addEventHandler("onClientResourceStop", resourceRoot, function()
	exports.blur_box:destroyBlurBox(MainWindowBlur)
end)

function buildGUI()
	local screenWidth, screenHeight = guiGetScreenSize()
	MainWindow = guiCreateStaticImage(left, top, windowW, windowH, "img/dot.jpg", false)
	guiSetProperty(MainWindow, "ImageColours", "tl:FF0A0A0A tr:FF0A0A0A bl:FF0A0A0A br:FF0A0A0A")
	GUIEditor.staticimage[2] = guiCreateStaticImage(0, 0, windowW, 10, "img/dot.jpg", false, MainWindow)
	guiSetProperty(GUIEditor.staticimage[2], "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	GUIEditor.staticimage[3] = guiCreateStaticImage(0, 10, windowW, 10, "img/dot.jpg", false, MainWindow)
	guiSetProperty(GUIEditor.staticimage[3], "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	GUIEditor.label[1] = guiCreateLabel(364, 1, 128, 16, "Welcome!", false, MainWindow)
	guiSetFont(GUIEditor.label[1], "default-bold-small")
	guiLabelSetColor(GUIEditor.label[1], 255, 255, 255)
	guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
	guiSetProperty(GUIEditor.label[1], "AlwaysOnTop", "true")

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

	online = guiCreateLabel(adminColumnN2posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, " •   ", false, AboutTab)
	guiLabelSetColor(online, onlineColor.r, onlineColor.g, onlineColor.b)
	online2 = guiCreateLabel(adminColumnN2posX-motdIndent*multiplierX, tabpanelH*multiplierY, adminColumnW, adminColumnH, "online", false, AboutTab)

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

	LogBindsTab = guiCreateTab("Changelog", TabPanel)

	ChangeLogUpdates = guiCreateLabel(268, 48, 20, 20, "*", false, MainWindow)
    guiLabelSetColor(ChangeLogUpdates, 253, 0, 0)
	guiSetProperty(ChangeLogUpdates, "AlwaysOnTop", "True")
	guiSetVisible(ChangeLogUpdates, false)

	addEventHandler("onClientGUIClick", TabPanel, function() guiSetVisible(ChangeLogUpdates, false) end, false)

	LogBindsMemoText = guiCreateMemo(motdIndent, motdIndent, tabpanelW-motdIndent*2, motdH, "", false, LogBindsTab)
	guiMemoSetReadOnly(LogBindsMemoText, true)

    RulesFaqsTab = guiCreateTab("Rules & Frequently Asked Questions", TabPanel)
    RulesMemo = guiCreateMemo(22, 20, 340, motdH, "\n                         _____ Rules _____\n\n\n  1. Do not cheat, hack or exploit to get any advantage\n\n  2. Do not insult or provoke any players or admins\n\n  3. Do not block other players or camp in DD and SH\n\n  4. Do not flood or spam the main chat\n\n  5. Do not advertise other servers\n\n  6. Do not TeamKill in CTF\n\n  7. Do not deliberately lock other people's name\n\n  Breaking any of these rules may result in ban.\n\n", false, RulesFaqsTab)
    FaqsMemo = guiCreateMemo(tabpanelW-340-motdIndent, 20, 340, motdH, "\n          _____ Frequently Asked Questions _____\n\n\n  Q: What are GreenCoins?\n  \n  A: GreenCoins are our community currency, you can         use them on all of our servers.\n\n  Q: How do win GreenCoins?\n\n  A: You win GreenCoins by simply playing on our servers     you can also donate to get GreenCoins in return.\n\n  Q: What can I buy on this server with GreenCoins?\n\n  A: You can buy Perks, Maps, Custom Horns, Skins             and you can modify your vehicle on our GC Shop - F6\n\n If you have any other questions refer them to our staff", false, RulesFaqsTab)
	guiMemoSetReadOnly(RulesMemo, true)
	guiMemoSetReadOnly(FaqsMemo, true)
	languageTabs.EN = RulesFaqsTab

	-- close button

	CloseButton = guiCreateStaticImage(650, 505, 131, 21.5, "img/dot.jpg", false, MainWindow)
	CloseButtonTwo = guiCreateStaticImage(650, 505, 131, 41, "img/dot.jpg", false, MainWindow)
	guiSetProperty(CloseButton, "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	guiSetProperty(CloseButtonTwo, "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	guiSetProperty(CloseButton, "AlwaysOnTop", "true")

	CloseLabel = guiCreateLabel(650, 505, 131, 41, "Close", false, MainWindow)
	guiSetFont(CloseLabel, "default-bold-small")
	guiLabelSetHorizontalAlign(CloseLabel, "center", false)
	guiLabelSetVerticalAlign(CloseLabel, "center")
	guiSetProperty(CloseLabel, "AlwaysOnTop", "true")

	addEventHandler("onClientMouseEnter", CloseLabel, function()
		guiSetAlpha(CloseButton, 1)
		guiSetAlpha(CloseButtonTwo, 1)
	end)

	addEventHandler("onClientMouseLeave", CloseLabel, function()
		guiSetAlpha(CloseButton, 0.5)
		guiSetAlpha(CloseButtonTwo, 0.5)
	end)

	if on_pushButton_clicked then
		addEventHandler("onClientGUIClick", CloseLabel, on_pushButton_clicked, false)
	end

	-- switch button

	SwitchButtonOne = guiCreateStaticImage(350, 505, 131, 21.5, "img/dot.jpg", false, MainWindow)
	SwitchButtonTwo = guiCreateStaticImage(350, 505, 131, 41, "img/dot.jpg", false, MainWindow)
	guiSetProperty(SwitchButtonOne, "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	guiSetProperty(SwitchButtonTwo, "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	guiSetProperty(SwitchButtonOne, "AlwaysOnTop", "true")

	SwitchButton = guiCreateLabel(350, 505, 131, 41, "Switch Server", false, MainWindow)
	guiSetFont(SwitchButton, "default-bold-small")
	guiLabelSetHorizontalAlign(SwitchButton, "center", false)
	guiLabelSetVerticalAlign(SwitchButton, "center")
	guiSetProperty(SwitchButton, "AlwaysOnTop", "true")

	addEventHandler("onClientMouseEnter", SwitchButton, function()
		guiSetAlpha(SwitchButtonOne, 1)
		guiSetAlpha(SwitchButtonTwo, 1)
	end)

	addEventHandler("onClientMouseLeave", SwitchButton, function()
		guiSetAlpha(SwitchButtonOne, 0.5)
		guiSetAlpha(SwitchButtonTwo, 0.5)
	end)
	addEventHandler("onClientGUIClick", SwitchButton, function() triggerServerEvent('onRequestRedirect', localPlayer) end, false)

	-- settingsbutton

	SettingsButtonOne = guiCreateStaticImage(50, 505, 131, 21.5, "img/dot.jpg", false, MainWindow)
	SettingsButtonTwo = guiCreateStaticImage(50, 505, 131, 41, "img/dot.jpg", false, MainWindow)
	guiSetProperty(SettingsButtonOne, "ImageColours", "tl:FF4EC857 tr:FF4EC857 bl:FF4EC857 br:FF4EC857")
	guiSetProperty(SettingsButtonTwo, "ImageColours", "tl:FF0CB418 tr:FF0CB418 bl:FF0CB418 br:FF0CB418")
	guiSetProperty(SettingsButtonOne, "AlwaysOnTop", "true")

	SettingsButton = guiCreateLabel(50, 505, 131, 41, "Settings", false, MainWindow)
	guiSetFont(SettingsButton, "default-bold-small")
	guiLabelSetHorizontalAlign(SettingsButton, "center", false)
	guiLabelSetVerticalAlign(SettingsButton, "center")
	guiSetProperty(SettingsButton, "AlwaysOnTop", "true")

	addEventHandler("onClientMouseEnter", SettingsButton, function()
		guiSetAlpha(SettingsButtonOne, 1)
		guiSetAlpha(SettingsButtonTwo, 1)
	end)

	addEventHandler("onClientMouseLeave", SettingsButton, function()
		guiSetAlpha(SettingsButtonOne, 0.5)
		guiSetAlpha(SettingsButtonTwo, 0.5)
	end)

	if on_pushButton_2_clicked then
		addEventHandler("onClientGUIClick", SettingsButton, on_pushButton_2_clicked, false)
	end


	guiSetVisible(MainWindow, false)
	triggerServerEvent('requestMOTD', resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, buildGUI)

function translateHelpmenu()
    if not MainWindow then return end
    -- guiSetText(,_(""))
    guiSetText(AboutTab,_.context("menu item","About"))
    guiSetText(MotdMemo,_("Welcome to the Mr. Green MTA servers!"))
    guiSetText(StaffTitle,_("Mr Green Gaming Staff"))
    guiSetText(offline2,_.context("player status","offline"))
    guiSetText(online2,_.context("player status","online"))
    guiSetText(CommandsBindsTab,_("Commands & Binds"))
    guiSetText(CommandsBindsMemoText,_("")) -- TODO: Binds localization
    guiSetText(LogBindsTab,_("Changelog"))
    guiSetText(RulesFaqsTab,_("Rules & Frequently Asked Questions"))
    guiSetText(CloseLabel,_.context("action","Close"))
    guiSetText(SwitchButton,_("Switch Server"))
    guiSetText(SettingsButton,_("Settings"))

    -- Rules
    local rulesWrd = _("Rules")
    local rulesStr = "\n                         _____ " .. rulesWrd .. " _____\n\n\n  "
    local spacer = "\n\n  "
    -- rulesStr = rulesStr .. _("") .. spacer
    rulesStr = rulesStr .. "1. " .. _("Do not cheat, hack or exploit to get any advantage") .. spacer
    rulesStr = rulesStr .. "2. " .. _("Do not insult or provoke any players or admins") .. spacer
    rulesStr = rulesStr .. "3. " .. _("Do not block other players or camp in DD and SH") .. spacer
    rulesStr = rulesStr .. "4. " .. _("Do not flood or spam the main chat") .. spacer
    rulesStr = rulesStr .. "5. " .. _("Do not advertise other servers") .. spacer
    rulesStr = rulesStr .. "6. " .. _("Do not TeamKill in CTF") .. spacer
    rulesStr = rulesStr .. "7. " .. _("Do not deliberately lock other people's name") .. spacer
    rulesStr = rulesStr .. _("Breaking any of these rules may result in ban.") .. spacer
    guiSetText(RulesMemo, rulesStr)

    -- FAQ
    local faqWrd = _("Frequently Asked Questions")
    local faqStr = "\n          _____ " .. faqWrd .. " _____\n\n\n  "
    spacer = "\n\n  "
    faqStr = faqStr .. "-- " .. _("What are GreenCoins?") .. spacer
    faqStr = faqStr .. _("GreenCoins are our community currency, you can use them on all of our servers.") .. spacer
    faqStr = faqStr .. "-- " .. _("How do win GreenCoins?") .. spacer
    faqStr = faqStr .. _("You win GreenCoins by simply playing on our servers you can also donate to get GreenCoins in return.") .. spacer
    faqStr = faqStr .. "-- " .. _("What can I buy on this server with GreenCoins?") .. spacer
    faqStr = faqStr .. _("You can buy Perks, Maps, Custom Horns, Skins and you can modify your vehicle in our GreenCoins Shop") .. spacer
    faqStr = faqStr .. spacer .. _("If you have any other questions, refer them to our staff") .. spacer
    guiSetText(FaqsMemo, faqStr)

    -- Commands & Binds
    guiSetText(CommandsBindsMemoText, getLocalizedCommands())
end
addEventHandler("onClientPlayerLocaleChange", root, translateHelpmenu)

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
function ( changelog, changelogLastUpdate, output )
	if not changelog then return end
	guiSetText(LogBindsMemoText, changelog)

	if isNewChangelog(changelogLastUpdate) then
		guiSetVisible(ChangeLogUpdates, true)
        if output then
            outputChatBox("[UPDATE] #FFFFFF" .. _("Something updated, press F9 -> ${changelog} to see what's new") % {changelog = "#00ff00\"" .. _("Changelog") .. "\" #FFFFFF"})		end
	end
end
)


local changelogFile = 'changelog.xml'
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
	setPlayerLanguageTab()
	if not guiGetVisible(MainWindow) then
		guiSetVisible(MainWindow, true)
		showCursor(true)
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

function getLocalizedCommands()
    local keysHeader = "----------------> ".._("Keys").." <----------------\n\n"
    local keysList = {
        {
            command = "F1",
            text = _("Sidebar options.")
        },
        {
            command = "F2",
            text = _("Redirect to the other server.")
        },
        {
            command = "F3",
            text = _("Opens private messaging.")
        },
        {
            command = "F4",
            text = _("Shows your achievements.")
        },
        {
            command = "F5",
            text = _("View current map toptimes/Map info.")
        },
        {
            command = "F6",
            text = _("Opens the GreenCoins Shop.")
        },
        {
            command = "F7",
            text = _("Opens the VIP window.")
        },
        {
            command = "F8",
            text = _("Opens your console.")
        },
        {
            command = "F9",
            text = _("Opens the help menu.")
        },
        {
            command = "F10",
            text = _("Show your statistics.")
        },
        {
            command = "F11",
            text = _("Opens San Andreas map.")
        },
        {
            command = "F12",
            text = _("Take a screen shot / toggle snow.")
        },
        {
            command = "Enter",
            text = _("Commit suicide.")
        },
        {
            command = "LCtrl",
            text = _("Makes your bike jump if held a few seconds and then released.")
        },
        {
            command = "Tab",
            text = _("Displays the scoreboard.")
        },
        {
            command = "T",
            text = _("Write to the chatbox.")
        },
        {
            command = "Y",
            text = _("Write to the team chat.")
        },
        {
            command = "U",
            text = _("Write to global chat.")
        },
        {
            command = "Z",
            text = _("Push to talk for voice chat.")
        },
        {
            command = "L",
            text = _("Toggle vehicle headlights")
        },
        {
            command = "B",
            text = _("Toggle spectator mode.")
        },
        {
            command = "1, 2, 3, 4, 5",
            text = _("Each of these do different animations when your bike is in the air.")
        },

    }

    local commandsHeader = "----------------> ".._("Commands").." <----------------\n\n"
    local commandsList = {
        {
            command = "",
            text = _("")
        },
        {
            command = _("/autologin [".. _("name") .."] [".._("password") .. "]"),
            text = _("Enable or disable auto-login.")
        },
        {
            command = "/admins",
            text = _("Show admins and mods currently on the servers.")
        },
        {
            command = "/assist",
            text = _("Racing assist shows line on road where your ghost was recorded.")
        },
        {
            command = "/assist off",
            text = _("Turn off racing assist.")
        },
        {
            command = "/afk",
            text = _('Set yourself as "Away From Keyboard" state')
        },
        {
            command = "/author",
            text = _("Show current map author.")
        },
        {
            command = _("/bind [".. _("key") .."] [".._("command").."] [".._("arguments").."]"),
            text = _("Binds a command to a key of your choice.")
        },
        {
            command = _("/bind [".. _("key") .."] say [".._("text").."]"),
            text = "Binds text to say in chat."
        },
        {
            command = "/enablenametags",
            text = _("Turn nick over car on or off.")
        },
        {
            command = "/board ",
            text = _("Show ranking board with checkpoint delays.")
        },
        {
            command = "/checkmap [" .. _("map") .. "]",
            text = _("See if a map is on the server.")
        },
        {
            command = _("/country [".. _("player") .."]"),
            text = _("Show the country for a player.")
        },
        {
            command = "/cpdelays",
            text = _("Show or hide the checkpoint splittime indicator.")
        },
        {
            command = "/setdelaypos [x y]",
            text = _("Move the split indicator (range 0 to 1).")
        },
        {
            command = "/currentrecord",
            text = _("Current record of concurrent players on the server.")
        },
        {
            command = "/fpslimit " .. _("number"),
            text = "Change maximum frames per second"
        },
        {
            command = "/freecam",
            text = _("Go into freecam mode (currently for admins only).")
        },
        {
            command = "/gamemodes",
            text = _("List of modes and maps amount on the server (in console = F8).")
        },
        {
            command = "/gc",
            text = _("Toggle GreenCoins counter.")
        },
        {
            command = "/gclogin [" .. _("name") .. "] [" .. _("pass") .. "] ",
            text = "Login to your GreenCoins account."
        },
        {
            command = "/gclogout",
            text = _("Log out of your GreenCoins account.")
        },
        {
            command = "/gcshop",
            text = _("Open greencoins shop.")
        },
        {
            command = "/getvehid",
            text = _("Get current vehicle name and model.")
        },
        {
            command = "/greencoins [" .. _("player") .."] ",
            text = _("Greencoins stats for you or another player displayed in the console.")
        },
        {
            command = "/hidemsg",
            text = _("Hide floating messages.")
        },
        {
            command = "/hidenext",
            text = _("Hide the current/next map window.")
        },
        {
            command = "/ignore [" .. _("player") .. "]",
            text = _("Ignore a disturbing player.")
        },
        {
            command = "/leaderboards",
            text = _("Display the top time earners.")
        },
        {
            command = "/like,/dislike",
            text = _("Like or dislike the current map.")
        },
        {
            command = "/locknick,/unlocknick",
            text = _("Lock or unlock your nickname.")
        },
        {
            command = "/lol",
            text = _("Laugh.")
        },
        {
            command = "/lol [".. _("player") .."]",
            text = _("Laugh at player.")
        },
        {
            command = "/mm",
            text = _("Show map upload window,,")
        },
        {
            command = "/makeowner [" .. _("name") .. "]",
            text = _("Change team owner.")
        },
        {
            command = "/mapinfo [" .. _("map") .. "]",
            text = _("Show map info window.")
        },
        {
            command = "/mapflash",
            text = _("Enable or disable flashing icon on taskbar when next map starts.")
        },
        {
            command = "/maps",
            text = _("List of the maps on the server (in console = F8).")
        },
        {
            command = "/messages",
            text = _("Disable private messages.")
        },
        {
            command = "/mode",
            text = _("Change the mode of the speedo.")
        },
        {
            command = "/motd",
            text = _("Show new changes on the server.")
        },
        {
            command = "/nextmap",
            text = _("Check what the next map is.")
        },
        {
            command = "/nick [" .. _("name") .. "]",
            text = _("Set player name.")
        },
        {
            command = "/oldcam",
            text = _("Switch to a different camera.")
        },
        {
            command = "/players [mix/race]",
            text = _("Show players on other server.")
        },
        {
            command = "/recent",
            text = _("Show recent forum topics.")
        },
        {
            command = "/register [" .. _("name") .. "] [" .. _("password") .. "]",
            text = _("Register an account for mods and admins.")
        },
        {
            command = "/report",
            text = _("Report a problem to admins.")
        },
        {
            command = "/resizeicon [" .. _("size") .."]",
            text = _("Resize typing icon.")
        },
        {
            command = "/round",
            text = _("Show current round being played.")
        },
        {
            command = "/rules",
            text = _("Display the server rules.")
        },
        {
            command = "/s /spec /spectate [".. _("name") .."]",
            text = _("Go into spectator mode or spectate a specific player.")
        },
        {
            command = "/seen [".. _("name") .."]",
            text = _("Displays last seen date and time of a player.")
        },
        {
            command = "/serialnicks [serial]",
            text = _("Show nicknames associated with serial.")
        },
        {
            command = "/seticonvis [".. _("opacity") .."]",
            text = _("Set opacity of typing icons.")
        },
        {
            command = "/settings",
            text = _("Show the settings menu.")
        },
        {
            command = "/showchat",
            text = _("Hide or show chat.")
        },

        {
            command = "/showsensor",
            text = _("Toggle the traffic sensor arrows.")
        },
        {
            command = "/song",
            text = _("Show the local directory the map song.")
        },
        {
            command = "/soundsoff",
            text = _("Mute all sounds.")
        },
        {
            command = "/soundson",
            text = _("Unmute all sounds.")
        },
        {
            command = "/sphud",
            text = _("Switch to a cool HUD.")
        },
        {
            command = "/stats [".. _("player") .."]",
            text = _("Show race/mix stats for player.")
        },
        {
            command = "/time",
            text = _("Display time of the server.")
        },

        {
            command = "/toggleicon",
            text = _("Toggle typing icon.")
        },
        {
            command = "/upload",
            text = _("Show map upload information.")
        },
        {
            command = "/getpackets [".. _("player") .."]",
            text = _("Show a player's packet loss statistics.")
        },

    }

    local moderatorsCommandsHeader = "----------------> ".._("Moderators").." <----------------\n\n"
    local moderatorsCommandsList = {
        {
            command = "/blocker [".. _("name") .."] [".. _("hours") .."]",
            text = _("Marks a player as blocker for set amount of hours. If no hours are supplied, it will default to 1 hour.")
        },
        {
            command = "/blockers",
            text = _("Shows an overview of all players in blocker mode")
        },
        {
            command = "/k [".. _("name") .."] [".. _("reason") .."]",
            text = _("Blow up another player who camps or is bugged in Shooter or DD mode.")
        },
        {
            command = "/mute [".. _("name") .."] [".. _("reason") .."] [".. _("seconds") .."]",
            text = _("Mute a player for x seconds.")
        },
        {
            command = "/unmute [".. _("name") .."]",
            text = _("Unmutes a player.")
        },
        {
            command = "/votekick [".. _("name") .."] [".. _("reason") .."]",
            text = _("Starts a votekick against a player.")
        },
    }

    local str = ""

    -- Add keys
    str = str .. keysHeader
    local spacing = 7
    for _, entry in ipairs(keysList) do
        local addedEntry = entry.command
        -- Insert spacing
        for i=1, spacing - #entry.command do addedEntry = addedEntry .. " " end
        addedEntry = addedEntry .. "- "
        -- Add text
        addedEntry = addedEntry .. entry.text .. "\n"
        -- Add to main string
        str = str .. addedEntry
    end

    -- Add commands
    str = str .. commandsHeader
    spacing = 45
    for _, entry in ipairs(commandsList) do
        local addedEntry = entry.command
        -- Insert spacing
        for i=1, spacing - #entry.command do addedEntry = addedEntry .. " " end
        addedEntry = addedEntry .. "- "
        -- Add text
        addedEntry = addedEntry .. entry.text .. "\n"
        -- Add to main string
        str = str .. addedEntry
    end

    -- Add moderator commands
    str = str .. moderatorsCommandsHeader
    spacing = 45
    for _, entry in ipairs(moderatorsCommandsList) do
        local addedEntry = entry.command
        -- Insert spacing
        for i=1, spacing - #entry.command do addedEntry = addedEntry .. " " end
        addedEntry = addedEntry .. "- "
        -- Add text
        addedEntry = addedEntry .. entry.text .. "\n"
        -- Add to main string
        str = str .. addedEntry
    end

    return str
end
