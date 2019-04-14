local joinMessageGui = {}
local screenWidth, screenHeight = guiGetScreenSize()
local joinMessage_maxLength = 150
local messageIsValid = true
local newMessage


function joinmessage_spawnGUI()

	joinMessageGui.windowMessage = guiCreateWindow(0.36, 0.39, 0.32, 0.14, "VIP Join Message", true)
	guiWindowSetSizable(joinMessageGui.windowMessage, false)

	joinMessageGui.lblText = guiCreateLabel(0.02, 0.21, 0.58, 0.15, "Enter your VIP join message (Keep it nice!):", true, joinMessageGui.windowMessage)
	joinMessageGui.warningLabel = guiCreateLabel(0, 0.21, 0.98, 0.15, "Too long!", true, joinMessageGui.windowMessage)
	guiSetVisible( joinMessageGui.warningLabel, false )
	guiLabelSetHorizontalAlign(joinMessageGui.warningLabel, "right", true)
	guiLabelSetColor( joinMessageGui.warningLabel, 255, 0, 0 )

	joinMessageGui.editMessage = guiCreateEdit(0.02, 0.41, 0.96, 0.22, "", true, joinMessageGui.windowMessage)

	
	addEventHandler('onClientGUIChanged', joinMessageGui.editMessage, joinmessage_editChanged)
	
	joinMessageGui.btnDone = guiCreateButton(0.74, 0.71, 0.24, 0.19, "Done", true, joinMessageGui.windowMessage)
	guiSetProperty(joinMessageGui.btnDone, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", joinMessageGui.btnDone, joinmessage_btnDoneClick, false)
	
	
	joinMessageGui.btnCancel = guiCreateButton(0.02, 0.71, 0.24, 0.19, "Cancel", true, joinMessageGui.windowMessage)
	guiSetProperty(joinMessageGui.btnCancel, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", joinMessageGui.btnCancel, joinmessage_btnCancelClick, false)
	
	
	joinMessageGui.btnPreview = guiCreateButton(0.3, 0.71, 0.4, 0.19, "Preview", true, joinMessageGui.windowMessage)
	guiSetProperty(joinMessageGui.btnPreview, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", joinMessageGui.btnPreview, joinmessage_btnPreviewClick, false)
		
	guiSetInputMode("no_binds_when_editing")
	
	guiSetVisible(joinMessageGui.windowMessage, false)
end
addEventHandler('onClientResourceStart', resourceRoot, joinmessage_spawnGUI)


function joinmessage_btnDoneClick(btn, state)
	if btn ~= "left" or state ~= "up" then return end

	joinmessage_showGUI(false)

	if messageIsValid == true and string.len(newMessage) < joinMessage_maxLength then
		triggerServerEvent('onClientChangeCustomJoinMessage', localPlayer, newMessage)
	else
		vip_outputChatBox("Join message is not valid!", 255, 0, 0)
	end
end

function joinmessage_btnPreviewClick(btn, state)
	if btn ~= "left" or state ~= "up" then return end
	local theMessage = guiGetText( joinMessageGui.editMessage )
	if string.len(theMessage) > 0 then
		local playerName = getPlayerName( localPlayer )
		if not playerName then playerName = getPlayerName( localPlayer ) end

		outputChatBox("[VIP Joined] "..playerName..": #FFFFFF"..theMessage,255,255,0,true)

	end
	
end

function joinmessage_editChanged(element)
	local tempMessage = guiGetText(element)
	if string.len(tempMessage) > joinMessage_maxLength then
		joinmessage_restrictSaving(true)
	else
		joinmessage_restrictSaving(false)
		newMessage = tempMessage
	end
end

function joinmessage_restrictSaving(bool)
	guiSetVisible( joinMessageGui.warningLabel, bool )
	guiSetEnabled(joinMessageGui.btnDone, not bool)
	guiSetEnabled(joinMessageGui.btnPreview, not bool)
	messageIsValid = not bool

end

function joinmessage_btnCancelClick(btn, state)
	if btn ~= "left" or state ~= "up" then return end
	joinmessage_showGUI(false)
end

function joinmessage_showGUI(state)

	guiBringToFront(joinMessageGui.windowMessage,true)
	local currentMessage = playerOptions.options[8].message
	if not currentMessage then currentMessage = "" end
	if state then
		guiSetText(joinMessageGui.editMessage, currentMessage)
	end
	

	guiSetVisible(joinMessageGui.windowMessage, state)
	showCursor(state, state)
end


function setVipJoinMessage()
	local currentMessage = playerOptions.options[8].message
	if not currentMessage then currentMessage = "" end
	guiSetText(joinMessageGui.editMessage, currentMessage)
end