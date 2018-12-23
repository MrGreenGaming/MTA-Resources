function buildGUI()
	windowTransfer = guiCreateWindow(0.56, 0.03, 0.34, 0.58, "Greencoin Transfer", true)
	guiWindowSetSizable(windowTransfer, false)

	gridPlayers = guiCreateGridList(0.03, 0.14, 0.56, 0.84, true, windowTransfer)
	guiGridListAddColumn(gridPlayers, "Name", 0.9)
	
	txtAmount = guiCreateEdit(0.67, 0.14, 0.31, 0.05, "", true, windowTransfer)
	guiEditSetMaxLength(txtAmount, 5)

	local lblAmount = guiCreateLabel(0.67, 0.09, 0.14, 0.05, "Amount:", true, windowTransfer)
	local lblSelectPlayer = guiCreateLabel(0.03, 0.09, 0.26, 0.05, "Select a player:", true, windowTransfer)
	local btnSend = guiCreateButton(0.67, 0.20, 0.31, 0.04, "Send", true, windowTransfer)
	guiSetProperty(btnSend, "NormalTextColour", "FFAAAAAA")
	local btnClose = guiCreateButton(0.67, 0.25, 0.31, 0.04, "Close", true, windowTransfer)
	guiSetProperty(btnClose, "NormalTextColour", "FFAAAAAA")   

	addEventHandler("onClientGUIClick", btnSend, sendTransferRequest, false)
    addEventHandler("onClientGUIClick", btnClose, hideGUI, false)
	guiSetInputMode("no_binds_when_editing")
	guiSetVisible(windowTransfer, false)		
end

-- Button functions

function sendTransferRequest(btn, state)
	if btn == "left" and state == "up" then
		local strAmount = guiGetText(txtAmount)
		guiSetText(txtAmount, "")
		local row, col = guiGridListGetSelectedItem(gridPlayers)
		if row == -1 or row == false then
			outputChatBox("[GC Transfer] Select a player first!", 255, 0, 0)
			return
		end
		
		local pName = guiGridListGetItemText(gridPlayers, row, col)
		
		local amount = tonumber(strAmount)
		if not amount then
			outputChatBox("[GC Transfer] You need to enter a number as the amount!", 255, 0, 0)
			return
		end
		
		triggerServerEvent("GCTransfer.SendTransferRequest", localPlayer, pName, amount)
	end
end

function hideGUI(btn, state)
	if btn == "left" and state == "up" then
		guiSetVisible(windowTransfer, false)
		showCursor(false)
	end
end



-- Events

addEventHandler("onClientResourceStart", root, 
function()
	buildGUI()
end)

addEvent("sb_transferGC", false)
addEventHandler("sb_transferGC", root,
function(playersTable)
	guiSetVisible(windowTransfer, true)
	showCursor(true)
	triggerServerEvent("GCTransfer.RequestPlayerData", localPlayer)
end)

addEvent("GCTransfer.TransferResponse", true)
addEventHandler("GCTransfer.TransferResponse", root, 
function(success, response)
	if success then
		outputChatBox(response, 0, 255, 0, true)
		guiSetVisible(windowTransfer, false)
		showCursor(false)
	else 
		outputChatBox(response, 255, 0, 0, true)
	end
end)
addEvent("GCTransfer.PlayerDataResponse", true)
addEventHandler("GCTransfer.PlayerDataResponse", root,
function(players)
	if not players then return end
	guiGridListClear(gridPlayers)
	
	for i, p in ipairs(players) do
		local row = guiGridListAddRow(gridPlayers)
		guiGridListSetItemText(gridPlayers, row, 1, p[1], false, false)
		if p[2] then
			guiGridListSetItemColor(gridPlayers, row, 1, 0, 255, 0, 255)
		else
			guiGridListSetItemColor(gridPlayers, row, 1, 255, 0, 0, 255)
		end
	end
end)