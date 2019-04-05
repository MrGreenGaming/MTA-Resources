local mainWindow
local blinkingPattern = 0
local blinkingSpeed = 0
local guiShown = false
addEventHandler("onClientResourceStart", resourceRoot,
    function()
         mainWindow = guiCreateWindow(0.19, 0.31, 0.63, 0.39, "VIP system", true)
        guiWindowSetSizable(mainWindow, false)

        btnNickname = guiCreateButton(0.02, 0.11, 0.18, 0.14, "Set color nickname", true, mainWindow)
        guiSetProperty(btnNickname, "NormalTextColour", "FFAAAAAA")
        lblBlinkingLights = guiCreateLabel(0.25, 0.11, 0.39, 0.13, "Blinking lights:", true, mainWindow)
        btnPattern1 = guiCreateButton(0.25, 0.31, 0.15, 0.15, "Left - Right Pattern", true, mainWindow)
        guiSetProperty(btnPattern1, "NormalTextColour", "FFAAAAAA")
        lblPattern = guiCreateLabel(0.25, 0.20, 0.38, 0.11, "Select pattern:", true, mainWindow)
        lblSpeed = guiCreateLabel(0.25, 0.51, 0.39, 0.13, "Select speed:", true, mainWindow)
        btnSpeed1 = guiCreateButton(0.25, 0.60, 0.06, 0.07, "1", true, mainWindow)
        guiSetProperty(btnSpeed1, "NormalTextColour", "FFAAAAAA")
        btnEnable = guiCreateButton(0.25, 0.72, 0.19, 0.15, "Enable blinking lights", true, mainWindow)
        guiSetProperty(btnEnable, "NormalTextColour", "FFAAAAAA")
        btnSpeed2 = guiCreateButton(0.32, 0.60, 0.06, 0.07, "2", true, mainWindow)
        guiSetProperty(btnSpeed2, "NormalTextColour", "FFAAAAAA")
        btnSpeed3 = guiCreateButton(0.39, 0.60, 0.06, 0.07, "3", true, mainWindow)
        guiSetProperty(btnSpeed3, "NormalTextColour", "FFAAAAAA")
        btnSpeed4 = guiCreateButton(0.46, 0.60, 0.06, 0.07, "4", true, mainWindow)
        guiSetProperty(btnSpeed4, "NormalTextColour", "FFAAAAAA")
        btnRainbow = guiCreateButton(0.02, 0.26, 0.18, 0.14, "Toggle VIP rainbow feature", true, mainWindow)
        guiSetProperty(btnRainbow, "NormalTextColour", "FFAAAAAA")
        btnPattern2 = guiCreateButton(0.42, 0.31, 0.15, 0.15, "Cross Pattern", true, mainWindow)
        guiSetProperty(btnPattern2, "NormalTextColour", "FFAAAAAA")
        btnPattern3 = guiCreateButton(0.59, 0.31, 0.15, 0.15, "Circle Pattern", true, mainWindow)
        guiSetProperty(btnPattern3, "NormalTextColour", "FFAAAAAA")
        btnDisable = guiCreateButton(0.46, 0.72, 0.19, 0.15, "Disable blinking lights", true, mainWindow)
        guiSetProperty(btnDisable, "NormalTextColour", "FFAAAAAA")    
		checkTag = guiCreateCheckBox(0.03, 0.80, 0.21, 0.07, "Show VIP tag over nametag", true, true, mainWindow)
		
		addEventHandler('onClientGUIClick', btnSpeed1, speedClick, false)
		addEventHandler('onClientGUIClick', btnSpeed2, speedClick, false)
		addEventHandler('onClientGUIClick', btnSpeed3, speedClick, false)
		addEventHandler('onClientGUIClick', btnSpeed4, speedClick, false)
		
		addEventHandler('onClientGUIClick', btnPattern1, patternClick, false)
		addEventHandler('onClientGUIClick', btnPattern2, patternClick, false)
		addEventHandler('onClientGUIClick', btnPattern3, patternClick, false)
		
		addEventHandler('onClientGUIClick', btnEnable, enableBlinking, false)
		addEventHandler('onClientGUIClick', btnDisable, disableBlinking, false)
		
		addEventHandler('onClientGUIClick', btnNickname, nickButtonClicked, false)
		addEventHandler('onClientGUIClick', btnRainbow, rainbowButtonClicked, false)
		
		addEventHandler('onClientGUIClick', checkTag, nametagToggle, false)
		
		guiSetVisible(mainWindow, false)
    end
)

function nametagToggle(btn, state)
	if btn~="left" or state~="up" then return end
	
	local showNametag = guiCheckBoxGetSelected(checkTag)
	
	triggerServerEvent('vip-showNametag', localPlayer, showNametag)
end

function nickButtonClicked(btn, state)
	if btn~="left" or state~="up" then return end
	triggerEvent('onPlayerRequestCustomNickWindow', localPlayer)
end

function rainbowButtonClicked(btn, state)
	if btn~="left" or state~="up" then return end
	triggerServerEvent('vip-toggleRainbow', localPlayer)
end

function speedClick(btn, state)
	if btn~="left" or state~="up" then return end
	
	blinkingSpeed = tonumber(guiGetText(source))
	guiSetProperty(btnSpeed1, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnSpeed2, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnSpeed3, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnSpeed4, "NormalTextColour", "FFAAAAAA")
	
	guiSetProperty(source, "NormalTextColour", "FF00FF00")
end

function patternClick(btn, state)
	if btn~="left" or state~="up" then return end
	
	guiSetProperty(btnPattern1, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnPattern2, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnPattern3, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(source, "NormalTextColour", "FF00FF00")
	
	local selectedPattern = guiGetText(source)
	
	if selectedPattern == "Left - Right Pattern" then
		blinkingPattern = 1
	elseif selectedPattern == "Cross Pattern" then
		blinkingPattern = 2
	elseif selectedPattern == "Circle Pattern" then
		blinkingPattern = 3
	end
end

function enableBlinking(btn, state)
	if btn~="left" or state~="up" then return end
	
	if blinkingPattern == 0 or blinkingSpeed == 0 then outputChatBox("You must select a pattern and a speed!", 255, 0, 0) return end
	
	triggerServerEvent('vip-startBlinking', localPlayer, blinkingPattern, blinkingSpeed)
end

function disableBlinking(btn, state)
	if btn~="left" or state~="up" then return end
	
	blinkingPattern = 0
	blinkingSpeed = 0
	
	guiSetProperty(btnPattern1, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnPattern2, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnPattern3, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnSpeed1, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnSpeed2, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnSpeed3, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(btnSpeed4, "NormalTextColour", "FFAAAAAA")
	
	triggerServerEvent('vip-startBlinking', localPlayer, 0, 0)
end

function toggleGUI()
	guiShown = not guiShown
	if guiShown then
		if getElementData(localPlayer, 'gcshop.vipbadge') then
			guiCheckBoxSetSelected(checkTag, true)
		else
			guiCheckBoxSetSelected(checkTag, false)
		end
	end
	guiSetVisible(mainWindow, guiShown)
	showCursor(guiShown)
end
addEvent('vip-toggleGUI', true)
addEventHandler('vip-toggleGUI', root, toggleGUI)
