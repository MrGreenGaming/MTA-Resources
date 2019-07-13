local supernick_guiItems = {}
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

function supernick_spawnGUI()
	triggerServerEvent('onClientRequestNickSettings', localPlayer)

	supernick_guiItems.windowNick = guiCreateWindow(0.36, 0.39, 0.32, 0.14, "Super Nickname", true)
	guiWindowSetSizable(supernick_guiItems.windowNick, false)

	supernick_guiItems.lblText = guiCreateLabel(0.02, 0.21, 0.58, 0.15, "Enter your new name:", true, supernick_guiItems.windowNick)
	
	supernick_guiItems.editName = guiCreateEdit(0.02, 0.41, 0.96, 0.22, "", true, supernick_guiItems.windowNick)
	name = ''
	
	addEventHandler('onClientGUIChanged', supernick_guiItems.editName, supernick_editChanged)
	
	supernick_guiItems.btnDone = guiCreateButton(0.74, 0.71, 0.24, 0.19, "Done", true, supernick_guiItems.windowNick)
	guiSetProperty(supernick_guiItems.btnDone, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", supernick_guiItems.btnDone, supernick_btnDoneClick, false)
	
	
	supernick_guiItems.btnCancel = guiCreateButton(0.02, 0.71, 0.24, 0.19, "Cancel", true, supernick_guiItems.windowNick)
	guiSetProperty(supernick_guiItems.btnCancel, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", supernick_guiItems.btnCancel, supernick_btnCancelClick, false)
	
	
	supernick_guiItems.btnReset = guiCreateButton(0.3, 0.71, 0.4, 0.19, "Remove super nick", true, supernick_guiItems.windowNick)
	guiSetProperty(supernick_guiItems.btnReset, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", supernick_guiItems.btnReset, supernick_btnResetClick, false)
		
	guiSetInputMode("no_binds_when_editing")
	
	guiSetVisible(supernick_guiItems.windowNick, false)
end
addEventHandler('onClientResourceStart', resourceRoot, supernick_spawnGUI)

function supernick_drawPreview()
	local posX, posY = guiGetPosition(supernick_guiItems.windowNick, false)
	local width, height = guiGetSize(supernick_guiItems.windowNick, false)
	dxDrawText(name, posX + (width * 0.61), posY + (height * 0.21), posX + (width * 0.61) + (width * 0.37), posY + (height * 0.21) + (height * 0.15), 0xFFFFFFFF, 1.0, 1.0, "default", "right", "top", false, false, true, true)
end

function supernick_btnDoneClick(btn, state)
	if btn ~= "left" or state ~= "up" then return end
	--outputChatBox(guiGetText(supernick_guiItems.editName))
	local nick = name
	local valid = nickValid
	supernick_showGUI(false)
	if valid == true then
		triggerServerEvent('onClientChangeCustomNickname', localPlayer, nick)
	else
		vip_outputChatBox("Nickname is not valid!", 255, 0, 0)
	end
end

function supernick_btnResetClick(btn, state)
	if btn ~= "left" or state ~= "up" then return end
	supernick_showGUI(false)
	triggerServerEvent('onClientResetCustomNickname', localPlayer)
end

function supernick_editChanged(element)
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

function supernick_btnCancelClick(btn, state)
	if btn ~= "left" or state ~= "up" then return end
	supernick_showGUI(false)
end

function supernick_showGUI(state)
	guiSetVisible(supernick_guiItems.windowNick, state)
	guiBringToFront(supernick_guiItems.windowNick,true)


	
	if state == true then
		addEventHandler('onClientRender', root, supernick_drawPreview)
		if not getElementData(localPlayer, 'vip.colorNick') then
			guiSetText(supernick_guiItems.editName, getPlayerName(localPlayer))
			guiSetEnabled(supernick_guiItems.btnReset, false)
		else
			guiSetText(supernick_guiItems.editName, getElementData(localPlayer, 'vip.colorNick'))
			guiSetEnabled(supernick_guiItems.btnReset, true)
		end
	else
		guiSetText(supernick_guiItems.editName, '')
		removeEventHandler('onClientRender', root, supernick_drawPreview)
		name = ''
		triggerEvent('vip-toggleGUI', localPlayer)
	end
end


