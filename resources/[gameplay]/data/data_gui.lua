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

function clientResourceStart()
	local screenW, screenH = guiGetScreenSize()
	GUI.window[1] = guiCreateWindow((screenW - 384) / 2, (screenH - 384) / 2, 384, 384, "Event Manager", false)
	GUI.button[1] = guiCreateButton(160, 352, 64, 24, "Close", false, GUI.window[1])
	guiSetVisible(GUI.window[1],false)
end
addEventHandler('onClientResourceStart', getResourceRootElement(),clientResourceStart)