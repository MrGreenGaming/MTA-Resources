--- DONT TRY TO COPY LITTLE BITCH

chat = {} -- table to store chat windows in
newmsg = {show=false, tick=getTickCount(), showtime=2500, img=nil, lbl=nil } -- new msg table


local getPlayerName_ = getPlayerName
local function getPlayerName ( player )
	if not isElement or not getElementType(player) == 'player' then return false end
	local name = getPlayerName_(player)
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or false
end

local getPlayerFromName_ = getPlayerFromName
local function getPlayerFromName ( name )
	for _, player in ipairs(getElementsByType'player') do
		if getPlayerName(player) == name then
			return player
		end
	end
	return false
end

function buildPlayerList()
	local gx,gy = guiGetScreenSize()
	local width,height = 222,343
	local x = -1
	local y = 3/4 * gy - height
	newmsg.img = guiCreateStaticImage(681.0000,134.0000, 42.0000,34.0000, "image/chat-icon.png", false) -- mail message icon
	newmsg.lbl = guiCreateLabel(553.0000,175.0000, 350.0000, 50.0000, "", false)
	guiSetVisible(newmsg.img, false)
	guiSetVisible(newmsg.lbl, false)
	guiLabelSetColor(newmsg.lbl,0, 170, 255)
	guiLabelSetHorizontalAlign(newmsg.lbl, "left", true)
	
	wndPlayers = guiCreateWindow(x,y,width,height, "Mr.Green - Chat", false)
	-- fond = guiCreateStaticImage(0.0405,0.0525,1,1,"image/mtalogo.png",true,wndPlayers)

	grdPlayers = guiCreateGridList(0.0491,0.0449+0.025,0.9608,0.8968+0.025, true, wndPlayers)

	colPlayers = guiGridListAddColumn(grdPlayers, "Player list", 0.85)

	local players = getElementsByType("player")
	for k,v in ipairs(players) do
		addPlayerToList(v)
	end
	-- guiSetProperty(fond,"Disabled","true")
	guiWindowSetSizable(wndPlayers, false)
	guiSetProperty(wndPlayers, "RollUpEnabled", "true")
	guiSetProperty(wndPlayers, "Dragable", "true")
	guiSetVisible(wndPlayers, false)
	
		
	bindKey("F3", "down", togglePmGui)	
end
function addPlayerToList(ply)
	--outputDebugString("addPlayerToList:" ..getPlayerName(ply))
	if ply == localPlayer then return end
	local row = guiGridListAddRow(grdPlayers)
	local name = getPlayerName(ply)
	guiGridListSetItemText(grdPlayers,row,colPlayers, name, false, false)
end
function removePlayerFromList(ply)
	--outputDebugString("removePlayerFromList:" ..getPlayerName(ply))
	local name=getPlayerName(ply)
	for row=0,guiGridListGetRowCount(grdPlayers) do
		if guiGridListGetItemText(grdPlayers, row, colPlayers) == name then
			guiGridListRemoveRow(grdPlayers, row)
			-- outputDebugString("remove row" ..tostring(row))
		end
	end
end


function showPmGui(state)
	if state == true then
		for k,v in pairs(chat) do
			guiSetVisible(chat[k].wnd,true)
		end
		showCursor(true)
		guiSetInputMode("no_binds_when_editing")
		guiSetVisible(wndPlayers, true)
	elseif state == false then
		for k,v in pairs(chat) do	
			guiSetVisible(chat[k].wnd,false)
		end
		showCursor(false)
		-- guiSetInputEnabled(false)
		guiSetVisible(wndPlayers, false)
	end
end
function togglePmGui()
	showPmGui( not guiGetVisible(wndPlayers))
end

function buildChatWindow(ply)
	local x,y = guiGetScreenSize()
	local width,height = 300,250
	x = x*.5
	y = y*.5
	
	chat[ply] = {}
	chat[ply].wnd = guiCreateWindow(337 + math.random(0, x - width),277 + math.random(0, y - height),395,252, getPlayerName(ply), false)	
	-- chat[ply].img = guiCreateStaticImage(0.0228,0.0754,0.9544,0.8889,"image/shruk.png",true,chat[ply].wnd)
	chat[ply].memo = guiCreateMemo(0.043,0.1746-0.05,0.9089,0.623+0.05, "", true, chat[ply].wnd)
	chat[ply].edit = guiCreateEdit(0.043,0.8214,0.7089,0.1111, "", true, chat[ply].wnd)
	chat[ply].btnClose = guiCreateButton(0.9315,0.0764,0.6757,0.0794, "X", true, chat[ply].wnd)
	chat[ply].btnSend = guiCreateButton(0.757,0.8335,0.1827,0.0829, "Send", true, chat[ply].wnd)
	-- guiSetProperty(chat[ply].img,"Disabled","true")
	
	guiMemoSetReadOnly(chat[ply].memo, true)
	
	guiWindowSetSizable(chat[ply].wnd, false)
	guiSetProperty(chat[ply].wnd, "RollUpEnabled", "true")
	guiSetProperty(chat[ply].wnd, "Dragable", "true")
	
	if guiGetVisible(wndPlayers) == true then
		guiSetVisible(chat[ply].wnd, true) -- is showing
	else
		guiSetVisible(chat[ply].wnd, false) -- isnt showing
	end	
end
function destroyChatWindow(ply)
	if chat[ply] and isElement(chat[ply].wnd) then
		destroyElement(chat[ply].wnd)
		chat[ply] = nil	
	end
end

function sendChatMessage(ply)
	--outputDebugString("sendChatMessage: " .. tostring(ply))
	if chat[ply] and isElement(chat[ply].wnd) then
		local newText = guiGetText(chat[ply].edit)
		if newText and string.len(newText) > 0 then
			local time = string.format("[%02d:%02d:%02d] ", getRealTime().hour, getRealTime().minute,getRealTime().second)
			local oldText = guiGetText(chat[ply].memo)
			if not oldText then oldText = "" end
			oldText = oldText .. time .. getPlayerName(localPlayer) .. ": " .. newText .. "\n"
			guiSetText(chat[ply].memo, oldText)
			guiSetText(chat[ply].edit, "")
			guiMemoSetCaretIndex(chat[ply].memo, string.len(oldText))

			triggerServerEvent("onGUIPrivateMessage", localPlayer, ply,newText) 
		end	
	end
end
function recieveChatMessage(ply, msg)
	--outputDebugString("recieveChatMessage: " .. msg)
	if exports["mrgreen-settings"]:isPlayerIgnoredPM(ply) then return end

	if getElementData(ply, 'ignored') then return end
	
	if not chat[ply] then
		buildChatWindow(ply)
	end
	
	newmsg.show = true
	newmsg.tick = getTickCount()
	
	guiSetText(newmsg.lbl, "PM from " .. getPlayerName(ply) .. ":\n\"" .. msg .. "\"")
	if guiGetVisible(chat[ply].memo) == false then outputChatBox("#ff0000Press F3 - " .. getPlayerName(ply) .. ": " .. msg,255,255,255,true) end

	guiSetVisible(newmsg.img, true)
	guiSetVisible(newmsg.lbl, true)

	local time = string.format("[%02d:%02d:%02d] ", getRealTime().hour, getRealTime().minute,getRealTime().second)
	local oldText = guiGetText(chat[ply].memo)
	if not oldText then oldText = "" end
	oldText = oldText .. time .. getPlayerName(ply) .. ": " .. msg .. "\n"
	guiSetText(chat[ply].memo, oldText)
	guiMemoSetCaretIndex(chat[ply].memo, string.len(oldText))
end

event_resource_start = function(res)
	buildPlayerList()
	--outputChatBox("#ff0000[BOT]#0096ffPress F3 to open private chat !",255,255,255,true)
end

event_resource_stop = function(res)
	unbindKey("F3", "down", togglePmGui)	
	showPmGui(false)
end

event_player_join = function()
	--outputDebugString("onClientPlayerJoin")
	addPlayerToList(source)
end

event_player_quit = function()
	--outputDebugString("onClientPlayerQuit")
	removePlayerFromList(source)
	if chat[source] then
		local c = math.random()
		chat[c] = {}
		for k,v in pairs(chat[source]) do
			chat[c][k] = v
		end
		chat[source] = nil
		guiSetVisible(chat[c].edit, false)
		guiSetVisible(chat[c].btnSend, false)
		guiSetText(chat[c].wnd, guiGetText(chat[c].wnd) .. ' (Left)')
		setElementData(chat[c].wnd, 'name', c, false)
	end
	--destroyChatWindow(source)
end

event_gui_click = function(button, state, absx, absy)
	if button == "left" and state == "up" then
		if getElementType(source) == "gui-button" then
			local parent = getElementParent(source)
			if parent ~= false then
				local ply = getPlayerFromName(guiGetText(parent)) or getElementData(parent, 'name')
				if chat[ply] then
					if source == chat[ply].btnClose then
						destroyChatWindow(ply)
						-- guiSetInputEnabled(false)
					elseif source == chat[ply].btnSend then
						sendChatMessage(ply)
						-- guiSetInputEnabled(false)
					end
				end
			end
		elseif getElementType(source) == "gui-edit" then
			local parent = getElementParent(source)
			if parent ~= false then
				local ply = getPlayerFromName(guiGetText(parent))
				if source == chat[ply].edit then
					-- guiSetInputEnabled(true)
				end
			end
		else
			-- guiSetInputEnabled(false)
		end
	end
end

event_gui_doubleclick = function(button, state, absx, absy)
	if button == "left" and state == "up" then
		if source == grdPlayers then
			local row, col = guiGridListGetSelectedItem(grdPlayers)
			--outputDebugString("double clicked row: "..tostring(row))
			if row == -1 or col == -1 then return end				
			local name = guiGridListGetItemText(grdPlayers, row, col)
			local ply = getPlayerFromName(name)
			if not chat[ply] then
				buildChatWindow(ply)
			end
			guiBringToFront(chat[ply].wnd)			
		end
	end
end

event_gui_accepted = function(element)
	local parent = getElementParent(source)
	if parent ~= false then
		local ply = getPlayerFromName(guiGetText(parent))
		if ply then
			if element == chat[ply].edit then
				sendChatMessage(ply)
			end
		end
	end
end

event_render = function()
	if newmsg.show == true then
		if getTickCount() > newmsg.tick + newmsg.showtime and guiGetVisible(wndPlayers) then
			guiSetVisible(newmsg.img, false)
			guiSetVisible(newmsg.lbl, false)
			newmsg.show = false
		end
	end
end

addEvent("onPrivateChatSent", true)
addEventHandler("onPrivateChatSent", root, recieveChatMessage)

addEventHandler("onClientResourceStart", resourceRoot, event_resource_start)
addEventHandler("onClientResourceStop", resourceRoot, event_resource_stop)
addEventHandler("onClientGUIDoubleClick", resourceRoot, event_gui_doubleclick)
addEventHandler("onClientGUIClick", resourceRoot, event_gui_click)
addEventHandler("onClientGUIAccepted", resourceRoot, event_gui_accepted)

addEventHandler("onClientPlayerJoin", root, event_player_join)
addEventHandler("onClientPlayerQuit", root, event_player_quit)
addEventHandler("onClientRender", root, event_render)

addEventHandler('onClientPlayerChangeNick', root,
function(old, new)
	-- Remove colour codes
	old = string.gsub ( old, '#%x%x%x%x%x%x', '' )
	new = string.gsub ( new, '#%x%x%x%x%x%x', '' )
	-- Update chat window title if exists
	if chat[source] and isElement(chat[source].wnd) then
		guiSetText(chat[source].wnd, new)
	end
	-- Update old name in grid list
	for row=0,guiGridListGetRowCount(grdPlayers) do
		if guiGridListGetItemText(grdPlayers, row, colPlayers) == old then
			guiGridListSetItemText(grdPlayers,row,colPlayers, new, false, false)
			-- outputDebugString("remove row" ..tostring(row))
		end
	end
end
)

addEvent("sb_showPM")
addEventHandler("sb_showPM",root,function() togglePmGui() end)