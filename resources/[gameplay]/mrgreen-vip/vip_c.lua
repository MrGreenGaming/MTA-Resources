local mainWindow
local blinkingPattern = 0
local blinkingSpeed = 0
local guiShown = false
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        mainWindow = guiCreateWindow(0.30, 0.31, 0.42, 0.28, "VIP system (F7 to close)", true)
        guiWindowSetSizable(mainWindow, false)

        btnNickname = guiCreateButton(0.05, 0.20, 0.21, 0.07, "Set color nickname", true, mainWindow)
        guiSetProperty(btnNickname, "NormalTextColour", "FFAAAAAA")
        lblBlinkingLights = guiCreateLabel(0.33, 0.17, 0.32, 0.10, "Blinking lights:", true, mainWindow)
        btnPattern1 = guiCreateButton(0.33, 0.38, 0.17, 0.07, "Left - Right Pattern", true, mainWindow)
        guiSetProperty(btnPattern1, "NormalTextColour", "FFAAAAAA")
		btnPattern2 = guiCreateButton(0.51, 0.38, 0.17, 0.07, "Cross Pattern", true, mainWindow)
        guiSetProperty(btnPattern2, "NormalTextColour", "FFAAAAAA")
        btnPattern3 = guiCreateButton(0.69, 0.38, 0.17, 0.07, "Circle Pattern", true, mainWindow)
        guiSetProperty(btnPattern3, "NormalTextColour", "FFAAAAAA")
        lblPattern = guiCreateLabel(0.33, 0.30, 0.32, 0.10, "Select pattern:", true, mainWindow)
        lblSpeed = guiCreateLabel(0.33, 0.47, 0.32, 0.10, "Select speed:", true, mainWindow)
        btnSpeed1 = guiCreateButton(0.33, 0.54, 0.05, 0.07, "1", true, mainWindow)
        guiSetProperty(btnSpeed1, "NormalTextColour", "FFAAAAAA")
        btnSpeed2 = guiCreateButton(0.39, 0.54, 0.05, 0.07, "2", true, mainWindow)
        guiSetProperty(btnSpeed2, "NormalTextColour", "FFAAAAAA")
        btnSpeed3 = guiCreateButton(0.45, 0.54, 0.05, 0.07, "3", true, mainWindow)
        guiSetProperty(btnSpeed3, "NormalTextColour", "FFAAAAAA")
        btnSpeed4 = guiCreateButton(0.51, 0.54, 0.05, 0.07, "4", true, mainWindow)
        guiSetProperty(btnSpeed4, "NormalTextColour", "FFAAAAAA")
        btnEnable = guiCreateButton(0.33, 0.71, 0.17, 0.07, "Enable blinking lights", true, mainWindow)
        guiSetProperty(btnEnable, "NormalTextColour", "FFAAAAAA")
        btnDisable = guiCreateButton(0.51, 0.71, 0.17, 0.07, "Disable blinking lights", true, mainWindow)
        guiSetProperty(btnDisable, "NormalTextColour", "FFAAAAAA")
        btnRainbow = guiCreateButton(0.05, 0.30, 0.21, 0.07, "Toggle VIP rainbow effect", true, mainWindow)
        guiSetProperty(btnRainbow, "NormalTextColour", "FFAAAAAA")    
		
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
		
		guiSetVisible(mainWindow, false)
    end
)

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
	guiSetVisible(mainWindow, guiShown)
	showCursor(guiShown)
end
addEvent('vip-toggleGUI', true)
addEventHandler('vip-toggleGUI', root, toggleGUI)
