tableasd = {2,{{{{anothertable,1}}}}}
-- Created: 27/08/2011 20:13

function makeRadioStayOff()
	cancelEvent()
end

addEventHandler('onClientResourceStart', getResourceRootElement(),
function()
GUIEditor_Window = {}
GUIEditor_Button = {}
GUIEditor_Edit = {}
GUIEditor_Grid = {}
GUIEditor_Image = {}
GUIEditor_Label = {}

GUIEditor_Window[1] = guiCreateWindow(0.331,0.3181,0.3827,0.241,"Radio Station Manager",true)
guiSetVisible(GUIEditor_Window[1], false)
GUIEditor_Grid[1] = guiCreateGridList(0.0171,0.0949,0.3701,0.8696,true,GUIEditor_Window[1])
guiGridListSetSelectionMode(GUIEditor_Grid[1],2)
column = guiGridListAddColumn(GUIEditor_Grid[1],"Radio Stations",0.8)
local xml
xml = xmlLoadFile('playlist.xml')
if not xml then 
	xml = xmlCreateFile('playlist.xml', 'playlist') 
end
local default = xmlFindChild(xml, "default", 0)
if default == false then
	xmlCreateChild(xml, "default")
end	
local children = xmlNodeGetChildren(xml)
for i, child in ipairs(children) do 
	local name = xmlNodeGetAttribute(child, "name")
	local row = guiGridListAddRow(GUIEditor_Grid[1])
	if type(name) == "string" then
		guiGridListSetItemText(GUIEditor_Grid[1], row, column, name, false, false)
	end
end
xmlSaveFile(xml)
xmlUnloadFile(xml)
GUIEditor_Button[1] = guiCreateButton(361,282,5,0,"",false,GUIEditor_Window[1])
GUIEditor_Edit[1] = guiCreateEdit(0.4044,0.1739,0.4961,0.0988,"Input stream URL here",true,GUIEditor_Window[1])
GUIEditor_Button[2] = guiCreateButton(0.9145,0.1739,0.07,0.1028,"Add",true,GUIEditor_Window[1])
GUIEditor_Image[1] = guiCreateStaticImage(0.902,0.8261,0.0669,0.1265,"stop1.png",true,GUIEditor_Window[1])
GUIEditor_Image[2] = guiCreateStaticImage(0.6781,0.83,0.0684,0.1146,"play1.png",true,GUIEditor_Window[1])
GUIEditor_Image[3] = guiCreateStaticImage(0.4339,0.83,0.0669,0.1067,"pause1.png",true,GUIEditor_Window[1])
GUIEditor_Label[1] = guiCreateLabel(0.465,0.4387,0.5179,0.3636,"Add your own URL Radio Streams!\nAdd as many as you want, click one on the left column\nand use the buttons to Play, Stop or Pause\nyour live streams at any time!",true,GUIEditor_Window[1])
GUIEditor_Label[2] = guiCreateLabel(0.423,0.2767,0.8001,0.083,"e.g: http://80.86.106.136:80/",true,GUIEditor_Window[1])
guiSetFont(GUIEditor_Label[1],"default-bold-small")
GUIEditor_Button[3] = guiCreateButton(0.9145,0.336,0.07,0.1107,"Close",true,GUIEditor_Window[1])
addEventHandler('onClientGUIMouseDown', getRootElement(),
function(button)
	if button ~= "left" then return end
	if source == GUIEditor_Image[1] then
		if isElement(stream) then stopSound(stream) end
		destroyElement(GUIEditor_Image[1])
		GUIEditor_Image[1] = guiCreateStaticImage(0.902,0.8261,0.0669,0.1265,"stop2.png",true,GUIEditor_Window[1])
		removeEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
		removeEventHandler("onClientPlayerVehicleEnter",getRootElement(),makeRadioStayOff)
		executeCommandHandler('soundson')
	elseif source == GUIEditor_Image[2] then
		destroyElement(GUIEditor_Image[2])
		GUIEditor_Image[2] = guiCreateStaticImage(0.6781,0.83,0.0684,0.1146,"play2.png",true,GUIEditor_Window[1])
		if isSoundPaused(stream) then
			setRadioChannel(0)
			addEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
			addEventHandler("onClientPlayerVehicleEnter",getRootElement(),makeRadioStayOff)
			executeCommandHandler('soundsoff')
			setSoundPaused(stream, false)
			return
		end
		if isElement(stream) then
			stopSound(stream)
			removeEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
			removeEventHandler("onClientPlayerVehicleEnter",getRootElement(),makeRadioStayOff)
		end
		local row, col = guiGridListGetSelectedItem(GUIEditor_Grid[1])
		if row == false or row == -1 then return end
		local text = guiGridListGetItemText(GUIEditor_Grid[1], row, col)
		stream = playSound(text)
		setRadioChannel(0)
		addEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
		addEventHandler("onClientPlayerVehicleEnter",getRootElement(),makeRadioStayOff)
		executeCommandHandler('soundsoff')
		local xml = xmlLoadFile('playlist.xml')
		local default
		default = xmlFindChild(xml, "default", 0)
		if default == false then
			default = xmlCreateChild(xml, "default")
		end
		xmlNodeSetAttribute(default, "default", text)
		xmlSaveFile(xml)
		xmlUnloadFile(xml)	
	elseif source == GUIEditor_Image[3] then
		if isElement(stream) then setSoundPaused(stream, true) end
		destroyElement(GUIEditor_Image[3])
		GUIEditor_Image[3] = guiCreateStaticImage(0.4339,0.83,0.0669,0.1067,"pause2.png",true,GUIEditor_Window[1])
		removeEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
		removeEventHandler("onClientPlayerVehicleEnter",getRootElement(),makeRadioStayOff)
		executeCommandHandler('soundson')
	end	
end
)
addEventHandler('onClientGUIMouseUp', getRootElement(),
function(button)
	if button ~= "left" then return end
		destroyElement(GUIEditor_Image[1])
		GUIEditor_Image[1] = guiCreateStaticImage(0.902,0.8261,0.0669,0.1265,"stop1.png",true,GUIEditor_Window[1])
		destroyElement(GUIEditor_Image[2])
		GUIEditor_Image[2] = guiCreateStaticImage(0.6781,0.83,0.0684,0.1146,"play1.png",true,GUIEditor_Window[1])
		destroyElement(GUIEditor_Image[3])
		GUIEditor_Image[3] = guiCreateStaticImage(0.4339,0.83,0.0669,0.1067,"pause1.png",true,GUIEditor_Window[1])
end
)
addEventHandler('onClientGUIClick', GUIEditor_Button[2],
function(button, state)
	if button == "left" and state == "up" then
		local text = guiGetText(GUIEditor_Edit[1])
		if text ~= "" and string.find(text, "http", 1, true) and string.find(text, ".", 5, true) then
			--store to XML too
			local xml
			xml = xmlLoadFile('playlist.xml')
			if not xml then 
				xml = xmlCreateFile('playlist.xml', 'playlist') 
			end
			local default
			default = xmlFindChild(xml, "default", 0)
			if default == false then
				default = xmlCreateChild(xml, "default")
			end
			xmlNodeSetAttribute(default, "default", text)	
			local children = xmlNodeGetChildren(xml)
			for i, child in ipairs(children) do 
				local xString = xmlNodeGetAttribute(child, "name")
				if xString == text then
					return
				end	
			end
			local child = xmlCreateChild(xml, "stream")
			xmlNodeSetAttribute(child, "name", text)
			local row = guiGridListAddRow(GUIEditor_Grid[1])
			guiGridListSetItemText(GUIEditor_Grid[1], row, column, text, false, false)
		
			xmlSaveFile(xml)
			xmlUnloadFile(xml)
		end
	end
end, false
)
addEventHandler('onClientGUIClick', GUIEditor_Edit[1],
function(button, state)
	if button == "left" and state == "up" then
		local text = guiGetText(GUIEditor_Edit[1])
		if text == "Input stream URL here" then
			guiSetText(GUIEditor_Edit[1], "")
		end
	end
end, false
)
addEventHandler('onClientGUIClick', GUIEditor_Button[3],
function(button, state)
	guiSetVisible(GUIEditor_Window[1], false)
	showCursor(false)
end, false
)
end
)

addCommandHandler('radio',
function()
	local show = not guiGetVisible(GUIEditor_Window[1])
	guiSetVisible(GUIEditor_Window[1], show)
	showCursor(show)
end
)






