---------
-- GUI --
---------

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

function clientStart()
	local screenW, screenH = guiGetScreenSize()
	
	-----------------
	-- Now Playing --
	-----------------
	
	GUI.window[1] = guiCreateWindow((screenW - 384) / 2, (screenH - 384) / 2, 384, 384, "Event Manager", false)
	guiWindowSetSizable(GUI.window[1], false)
	
	GUI.button[1] = guiCreateButton(160, 352, 64, 24, "Close", false, GUI.window[1])
	addEventHandler("onClientGUIClick",GUI.button[1],windowVisibility,false)
	
	GUI.tabpanel[1] = guiCreateTabPanel(8, 24, 368, 320, false, GUI.window[1])
	
	GUI.tab[1] = guiCreateTab("Now playing", GUI.tabpanel[1])
	
	GUI.label[1] = guiCreateLabel(8, 8, 80, 16, "Current event:", false, GUI.tab[1])
	guiLabelSetHorizontalAlign(GUI.label[1], "left", false)
	guiLabelSetVerticalAlign(GUI.label[1], "center")
	
	GUI.label[2] = guiCreateLabel(96, 8, 264, 16, "", false, GUI.tab[1])
	guiLabelSetHorizontalAlign(GUI.label[2], "left", false)
	guiLabelSetVerticalAlign(GUI.label[2], "center")
	
	GUI.label[3] = guiCreateLabel(8, 32, 96, 16, "Upcoming maps:", false, GUI.tab[1])
	guiLabelSetHorizontalAlign(GUI.label[3], "left", false)
	guiLabelSetVerticalAlign(GUI.label[3], "center")
	
	GUI.gridlist[1] = guiCreateGridList(8, 56, 352, 196, false, GUI.tab[1])
	guiGridListAddColumn(GUI.gridlist[1], "#", 0.1)
	guiGridListAddColumn(GUI.gridlist[1], "Map name", 0.5)
	guiGridListAddColumn(GUI.gridlist[1], "Author", 0.3)
	guiGridListSetSortingEnabled(GUI.gridlist[1], false)
	
	GUI.button[2] = guiCreateButton(296, 32, 64, 16, "Refresh", false, GUI.tab[1])
	addEventHandler("onClientGUIClick",GUI.button[2],updateQueueInfo,false)
	
	GUI.button[3] = guiCreateButton(120, 260, 128, 24, "Tweak current event", false, GUI.tab[1])
	addEventHandler("onClientGUIClick",GUI.button[3],windowVisibility,false)
	
	guiSetVisible(GUI.window[1],false)
	
	--------------
	-- Overview --
	--------------
	
	GUI.tab[2] = guiCreateTab("Overview", GUI.tabpanel[1])
	
	GUI.gridlist[4] = guiCreateGridList(8, 8, 352, 244, false, GUI.tab[2])
	guiGridListAddColumn(GUI.gridlist[4], "Event name", 0.5)
	guiGridListAddColumn(GUI.gridlist[4], "Maps", 0.4)
	guiGridListSetSortingEnabled(GUI.gridlist[4], true)
	
	GUI.button[13] = guiCreateButton(8, 260, 112, 24, "Start event", false, GUI.tab[2])
	addEventHandler("onClientGUIClick",GUI.button[13],startEvent,false)
	
	GUI.button[11] = guiCreateButton(128, 260, 112, 24, "Edit event", false, GUI.tab[2])
	addEventHandler("onClientGUIClick",GUI.button[11],windowVisibility,false)
	
	GUI.button[12] = guiCreateButton(248, 260, 112, 24, "Delete event", false, GUI.tab[2])
	addEventHandler("onClientGUIClick",GUI.button[12],deleteEvent,false)
	
	------------
	-- Create --
	------------
	
	GUI.tab[3] = guiCreateTab("Create", GUI.tabpanel[1])
	
	GUI.label[6] = guiCreateLabel(8, 8, 96, 16, "Event name:", false, GUI.tab[3])
	guiLabelSetHorizontalAlign(GUI.label[6], "left", false)
	guiLabelSetVerticalAlign(GUI.label[6], "center")
	
	GUI.edit[2] = guiCreateEdit(8, 32, 352, 24, "", false, GUI.tab[3])
	guiSetEnabled(GUI.edit[2], true)
	
	GUI.button[10] = guiCreateButton(120, 260, 128, 24, "Create event", false, GUI.tab[3])
	addEventHandler("onClientGUIClick",GUI.button[10],createEvent,false)
	
	-------------------------
	-- Window event editor --
	-------------------------
	
	GUI.window[2] = guiCreateWindow((screenW - 800) / 2, (screenH - 640) / 2, 800, 640, "Event editor", false)
	guiWindowSetSizable(GUI.window[2], false)
	
	GUI.gridlist[2] = guiCreateGridList(32, 128, 320, 384, false, GUI.window[2])
	guiGridListAddColumn(GUI.gridlist[2], "Map name", 0.5)
	guiGridListAddColumn(GUI.gridlist[2], "Author", 0.4)
	guiGridListAddColumn(GUI.gridlist[2], "resname", 0.4)
	guiGridListSetSortingEnabled(GUI.gridlist[2], false)
	addEventHandler("onClientGUIClick",GUI.gridlist[2],eventButtons,false)
	
	GUI.gridlist[3] = guiCreateGridList(448, 128, 320, 384, false, GUI.window[2])
	guiGridListAddColumn(GUI.gridlist[3], "#", 0.1)
	guiGridListAddColumn(GUI.gridlist[3], "Map name", 0.5)
	guiGridListAddColumn(GUI.gridlist[3], "Author", 0.3)
	guiGridListAddColumn(GUI.gridlist[3], "resname", 0.4)
	guiGridListSetSortingEnabled(GUI.gridlist[3], false)
	addEventHandler("onClientGUIClick",GUI.gridlist[3],eventButtons,false)
	
	GUI.label[4] = guiCreateLabel(144, 104, 96, 16, "Server maps list:", false, GUI.window[2])
	guiLabelSetHorizontalAlign(GUI.label[4], "left", false)
	guiLabelSetVerticalAlign(GUI.label[4], "center")
	
	GUI.label[5] = guiCreateLabel(448, 104, 320, 16, "Current event maps:", false, GUI.window[2])
	guiLabelSetHorizontalAlign(GUI.label[5], "center", false)
	guiLabelSetVerticalAlign(GUI.label[5], "center")
	
	GUI.button[5] = guiCreateButton(368, 288, 64, 24, "Add", false, GUI.window[2])
	addEventHandler("onClientGUIClick",GUI.button[5],eventAdd,false)
	guiSetEnabled(GUI.button[5], false)
	
	GUI.button[6] = guiCreateButton(368, 328, 64, 24, "Remove", false, GUI.window[2])
	addEventHandler("onClientGUIClick",GUI.button[6],eventRemove,false)
	guiSetEnabled(GUI.button[6], false)
	
	GUI.button[7] = guiCreateButton(576, 528, 64, 24, "Move up", false, GUI.window[2])
	addEventHandler("onClientGUIClick",GUI.button[7],eventMove,false)
	guiSetEnabled(GUI.button[7], false)
	
	GUI.button[8] = guiCreateButton(540, 560, 64, 24, "Move to", false, GUI.window[2])
	addEventHandler("onClientGUIClick",GUI.button[8],eventMove,false)
	guiSetEnabled(GUI.button[8], false)
	
	GUI.edit[1] = guiCreateEdit(612, 560, 64, 24, "", false, GUI.window[2])
	guiSetEnabled(GUI.edit[1], false)
	
	GUI.label[7] = guiCreateLabel(40, 528, 40, 24, "Search:", false, GUI.window[2])
	guiLabelSetHorizontalAlign(GUI.label[7], "left", false)
	guiLabelSetVerticalAlign(GUI.label[7], "center")
	
	GUI.edit[3] = guiCreateEdit(88, 528, 256, 24, "", false, GUI.window[2])
	guiSetEnabled(GUI.edit[3], true)
	addEventHandler("onClientGUIChanged",GUI.edit[3],handleSearches)
	
	GUI.button[9] = guiCreateButton(576, 592, 64, 24, "Move down", false, GUI.window[2])
	addEventHandler("onClientGUIClick",GUI.button[9],eventMove,false)
	guiSetEnabled(GUI.button[9], false)
	
	GUI.button[4] = guiCreateButton(368, 608, 64, 24, "Close", false, GUI.window[2])
	addEventHandler("onClientGUIClick",GUI.button[4],windowVisibility,false)
	
	guiSetVisible(GUI.window[2],false)
end
addEventHandler("onClientResourceStart",resourceRoot,clientStart)