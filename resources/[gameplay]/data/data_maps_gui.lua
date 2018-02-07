GUI_maps = {
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

function clientResourceStart()
	local screenW, screenH = guiGetScreenSize()
	
	GUI_maps.window[1] = guiCreateWindow((screenW - 384) / 2, (screenH - 512) / 2, 384, 512, "Data maps", false)
	guiWindowSetSizable(GUI_maps.window[1], false)
	
	GUI_maps.button[1] = guiCreateButton(160, 480, 64, 24, "Close", false, GUI_maps.window[1])
	addEventHandler("onClientGUIClick",GUI_maps.button[1],buttonTrigger,false)
	
	GUI_maps.tabpanel[1] = guiCreateTabPanel(8, 24, 368, 448, false, GUI_maps.window[1])
	
	GUI_maps.tab[1] = guiCreateTab("Info", GUI_maps.tabpanel[1])
	
	GUI_maps.label[1] = guiCreateLabel(8, 8, 144, 16, "Is the map cycle working:", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[1], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[1], "center")
	
	GUI_maps.label[2] = guiCreateLabel(158, 8, 80, 16, "Unknown", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[2], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[2], "center")
	guiLabelSetColor(GUI_maps.label[2], 255, 128, 0)
	
	GUI_maps.label[3] = guiCreateLabel(8, 40, 64, 16, "Maps:", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[3], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[3], "center")
	
	GUI_maps.label[4] = guiCreateLabel(8, 56, 64, 16, "Target obs:", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[4], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[4], "center")
	
	GUI_maps.label[5] = guiCreateLabel(8, 72, 64, 16, "Obs:", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[5], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[5], "center")
	
	GUI_maps.label[6] = guiCreateLabel(8, 88, 64, 16, "E(Pr(Xi)):", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[6], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[6], "center")
	
	GUI_maps.label[7] = guiCreateLabel(8, 120, 64, 16, "H0: p =", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[7], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[7], "center")
	
	GUI_maps.label[8] = guiCreateLabel(8, 136, 128, 16, "H1: H0 not true", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[8], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[8], "center")
	
	GUI_maps.label[9] = guiCreateLabel(8, 168, 72, 16, "Chi-squared:", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[9], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[9], "center")
	
	GUI_maps.label[10] = guiCreateLabel(8, 184, 64, 16, "Alpha:", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[10], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[10], "center")
	
	GUI_maps.label[11] = guiCreateLabel(8, 200, 64, 16, "Critical:", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[11], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[11], "center")
	
	GUI_maps.label[12] = guiCreateLabel(80, 40, 128, 16, "-", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[12], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[12], "center")
	
	GUI_maps.label[13] = guiCreateLabel(80, 56, 128, 16, "-", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[13], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[13], "center")
	
	GUI_maps.label[14] = guiCreateLabel(80, 72, 128, 16, "-", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[14], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[14], "center")
	
	GUI_maps.label[15] = guiCreateLabel(80, 88, 128, 16, "-", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[15], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[15], "center")
	
	GUI_maps.label[16] = guiCreateLabel(80, 120, 128, 16, "-", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[16], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[16], "center")
	
	GUI_maps.label[17] = guiCreateLabel(80, 168, 128, 16, "-", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[17], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[17], "center")
	
	GUI_maps.label[18] = guiCreateLabel(80, 184, 128, 16, "-", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[18], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[18], "center")
	
	GUI_maps.label[19] = guiCreateLabel(80, 200, 128, 16, "-", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[19], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[19], "center")
	
	GUI_maps.label[20] = guiCreateLabel(8, 232, 128, 16, "Indecisive", false, GUI_maps.tab[1])
	guiLabelSetHorizontalAlign(GUI_maps.label[20], "left", false)
	guiLabelSetVerticalAlign(GUI_maps.label[20], "center")
	
	
	GUI_maps.tab[2] = guiCreateTab("Data", GUI_maps.tabpanel[1])
	
	GUI_maps.gridlist[1] = guiCreateGridList(8, 8, 352, 408, false, GUI_maps.tab[2])
	guiGridListAddColumn(GUI_maps.gridlist[1], "resname", 0.3)
	guiGridListAddColumn(GUI_maps.gridlist[1], "Map Name", 0.3)
	guiGridListAddColumn(GUI_maps.gridlist[1], "Author", 0.3)
	guiGridListAddColumn(GUI_maps.gridlist[1], "Random", 0.1)
	guiGridListAddColumn(GUI_maps.gridlist[1], "Replay", 0.1)
	guiGridListAddColumn(GUI_maps.gridlist[1], "GCShop", 0.1)
	guiGridListAddColumn(GUI_maps.gridlist[1], "Event", 0.1)
	guiGridListSetSortingEnabled(GUI_maps.gridlist[1], true)
	
	guiSetVisible(GUI_maps.window[1],false)
end
addEventHandler('onClientResourceStart', getResourceRootElement(),clientResourceStart)