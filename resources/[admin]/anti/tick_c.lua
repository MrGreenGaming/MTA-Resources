pTick = {}

function tickCheck_c(tickCountServer)
	triggerServerEvent("anti_tickCheck_s", getLocalPlayer(), tickCountServer, getTickCount())
end
addEvent("anti_tickCheck_c", true)
addEventHandler("anti_tickCheck_c", root, tickCheck_c)

-- GUI

local timer
GUI = {
    button = {},
	combobox = {},
    edit = {},
    gridlist = {},
	image = {},
    label = {},
	memo = {},
	scrollbar = {},
	scrollpane = {},
    tab = {},
    tabpanel = {},
    window = {}
}

function onClientResourceStart()
	local screenW, screenH = guiGetScreenSize()
	
	GUI.window[1] = guiCreateWindow((screenW - 384) / 2, (screenH - 384) / 2, 384, 384, "Tick checker", false)
	guiWindowSetSizable(GUI.window[1], false)
	
	GUI.gridlist[1] = guiCreateGridList(8, 24, 368, 352, false, GUI.window[1])
	guiGridListAddColumn(GUI.gridlist[1], "Player", 0.2)
	guiGridListAddColumn(GUI.gridlist[1], "Dif joining", 0.2)
	guiGridListAddColumn(GUI.gridlist[1], "%", 0.15)
	guiGridListAddColumn(GUI.gridlist[1], "Dif second", 0.2)
	guiGridListAddColumn(GUI.gridlist[1], "%", 0.15)
	guiGridListSetSortingEnabled(GUI.gridlist[1], false)
	
	guiSetVisible(GUI.window[1],false)
end
addEventHandler("onClientResourceStart",resourceRoot,onClientResourceStart)

function tickWindow_c()
	if guiGetVisible(GUI.window[1]) then
		guiSetVisible(GUI.window[1],false)
		showCursor(false)
		guiSetInputMode("allow_binds")
		if isTimer(timer) then killTimer(timer) end
	else
		guiSetVisible(GUI.window[1],true)
		guiBringToFront(GUI.window[1])
		showCursor(true)
		guiSetInputMode("no_binds_when_editing")
		if isTimer(timer) then killTimer(timer) end
		timer = setTimer(function() triggerServerEvent("anti_tickTable_s", getLocalPlayer()) end, 2000, 0)
	end
	triggerServerEvent("anti_tickTable_s", getLocalPlayer())
end
addEvent("anti_tickWindow_c", true)
addEventHandler("anti_tickWindow_c", root, tickWindow_c)

function tickTable_c(t)
	pTick = t
	guiGridListClear(GUI.gridlist[1])
	
	for a,b in ipairs(pTick) do
		local t_join = (b[6] - b[2])
		local d_join = (b[7] - b[3]) - (b[6] - b[2])
		local p_join = math.floor((d_join / t_join) * 100 * 1000) / 1000
		local t_secc = (b[6] - b[4])
		local d_secc = (b[7] - b[5]) - (b[6] - b[4])
		local p_secc = math.floor((d_secc / t_secc) * 100 * 1000) / 1000
		
		local row = guiGridListAddRow(GUI.gridlist[1])
		guiGridListSetItemText(GUI.gridlist[1],row,1,tostring(pTick[a][1]),true,true,false)
		guiGridListSetItemText(GUI.gridlist[1],row,2,tostring(d_join),false,false,true)
		guiGridListSetItemText(GUI.gridlist[1],row,3,tostring(p_join),false,false,true)
		guiGridListSetItemText(GUI.gridlist[1],row,4,tostring(d_secc),false,false,true)
		guiGridListSetItemText(GUI.gridlist[1],row,5,tostring(p_secc),false,false,true)
		
		if math.abs(d_join) > (b[8] + 1) then
			guiGridListSetItemColor(GUI.gridlist[1],row,2,255,0,0)
			guiGridListSetItemColor(GUI.gridlist[1],row,3,255,0,0)
		end
		if math.abs(d_secc) > (b[8] + 1) then
			guiGridListSetItemColor(GUI.gridlist[1],row,4,255,0,0)
			guiGridListSetItemColor(GUI.gridlist[1],row,5,255,0,0)
		end
	end
end
addEvent("anti_tickTable_c", true)
addEventHandler("anti_tickTable_c", root, tickTable_c)