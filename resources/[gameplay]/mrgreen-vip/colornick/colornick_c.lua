local guiItems = {}
local name
local screenWidth, screenHeight = guiGetScreenSize()
local acceptedChars
local nickLimit
local nickValid = false

addEvent('sendNickSettings', true)
addEventHandler('sendNickSettings', root,
function(chars, limit)
	acceptedChars = chars
	nickLimit = limit
end)

function spawnGUI()
	triggerServerEvent('onClientRequestNickSettings', localPlayer)

	guiItems.windowNick = guiCreateWindow(0.36, 0.39, 0.32, 0.14, "Longer nicknames", true)
	guiWindowSetSizable(guiItems.windowNick, false)

	guiItems.lblText = guiCreateLabel(0.02, 0.21, 0.58, 0.15, "Enter your new name:", true, guiItems.windowNick)
	
	guiItems.editName = guiCreateEdit(0.02, 0.41, 0.96, 0.22, "", true, guiItems.windowNick)
	name = ''
	
	addEventHandler('onClientGUIChanged', guiItems.editName, editChanged)
	
	guiItems.btnDone = guiCreateButton(0.74, 0.71, 0.24, 0.19, "Done", true, guiItems.windowNick)
	guiSetProperty(guiItems.btnDone, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", guiItems.btnDone, btnDoneClick, false)
	
	
	guiItems.btnCancel = guiCreateButton(0.02, 0.71, 0.24, 0.19, "Cancel", true, guiItems.windowNick)
	guiSetProperty(guiItems.btnCancel, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", guiItems.btnCancel, btnCancelClick, false)
	
	
	guiItems.btnReset = guiCreateButton(0.3, 0.71, 0.4, 0.19, "Remove custom nick", true, guiItems.windowNick)
	guiSetProperty(guiItems.btnReset, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", guiItems.btnReset, btnResetClick, false)
		
	guiSetInputMode("no_binds_when_editing")
	
	guiSetVisible(guiItems.windowNick, false)
end
addEventHandler('onClientResourceStart', resourceRoot, spawnGUI)

function drawPreview()
	local posX, posY = guiGetPosition(guiItems.windowNick, false)
	local width, height = guiGetSize(guiItems.windowNick, false)
	dxDrawText(name, posX + (width * 0.61), posY + (height * 0.21), posX + (width * 0.61) + (width * 0.37), posY + (height * 0.21) + (height * 0.15), 0xFFFFFFFF, 1.0, 1.0, "default", "right", "top", false, false, true, true)
end

function btnDoneClick(btn, state)
	if btn ~= "left" or state ~= "up" then return end
	--outputChatBox(guiGetText(guiItems.editName))
	local nick = name
	local valid = nickValid
	showGUI(false)
	if valid == true then
		triggerServerEvent('onClientChangeCustomNickname', localPlayer, nick)
	else
		outputChatBox("Nickname is not valid!", 255, 0, 0)
	end
end

function btnResetClick(btn, state)
	if btn ~= "left" or state ~= "up" then return end
	showGUI(false)
	triggerServerEvent('onClientResetCustomNickname', localPlayer)
end

function editChanged(element)
	local tempName = guiGetText(element)
	for i=1,string.len(tempName) do
		local char = string.sub(tempName, i, i)
		if not string.find(acceptedChars, char) then
			name = "#FF0000Name contains illegal characters!"
			nickValid = false
			return
		end
	end
	
	local colorlessName = string.gsub(tempName, "#%x%x%x%x%x%x", "")
	
	if string.len(colorlessName) == 0 then
		nickValid = false
		name = "#FF0000Name can't be empty!"
		return
	elseif string.len(colorlessName) > nickLimit then
		nickValid = false
		name = "#FF0000Name is too long!"
		return
	end
	
	nickValid = true
	name = guiGetText(element)
end

function btnCancelClick(btn, state)
	if btn ~= "left" or state ~= "up" then return end
	showGUI(false)
end

function showGUI(state)
	guiSetVisible(guiItems.windowNick, state)
	showCursor(state, state)
	
	if state == true then
		addEventHandler('onClientRender', root, drawPreview)
		if not getElementData(localPlayer, 'vip.colorNick') then
			guiSetText(guiItems.editName, getPlayerName(localPlayer))
			guiSetEnabled(guiItems.btnReset, false)
		else
			guiSetText(guiItems.editName, getElementData(localPlayer, 'vip.colorNick'))
			guiSetEnabled(guiItems.btnReset, true)
		end
	else
		guiSetText(guiItems.editName, '')
		removeEventHandler('onClientRender', root, drawPreview)
		name = ''
		triggerEvent('vip-toggleGUI', localPlayer)
	end
	
end

function showWindow()
	triggerEvent('vip-toggleGUI', localPlayer)
	showGUI(true)
end
addEvent('onPlayerRequestCustomNickWindow', true)
addEventHandler('onPlayerRequestCustomNickWindow', root, showWindow)
