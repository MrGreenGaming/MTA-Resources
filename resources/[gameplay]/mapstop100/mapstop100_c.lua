MapList = {}
Map100 = {}

GUIEditor = {
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
	image = {}
}

function maps100_buildGUI()
	local screenW, screenH = guiGetScreenSize()
	GUIEditor.window[1] = guiCreateWindow((screenW - 768) / 2, (screenH - 640) / 2, 768, 684, "Maps top 100 - Nominations", false)
	guiWindowSetSizable(GUIEditor.window[1], false)
	
	GUIEditor.button[1] = guiCreateButton(320, 608, 128, 24, "Close", false, GUIEditor.window[1])
	addEventHandler("onClientGUIClick",GUIEditor.button[1],maps100_openCloseGUI,false)
	
	GUIEditor.image[1] = guiCreateStaticImage(192, 16, 384, 96, "mapstop100_logo.png", false, GUIEditor.window[1])
	
	GUIEditor.gridlist[1] = guiCreateGridList(8, 208, 328, 344, false, GUIEditor.window[1])
	guiGridListAddColumn(GUIEditor.gridlist[1], "Name", 0.4)
	guiGridListAddColumn(GUIEditor.gridlist[1], "Author", 0.3)
	guiGridListAddColumn(GUIEditor.gridlist[1], "Gamemode", 0.5)
	guiGridListAddColumn(GUIEditor.gridlist[1], "resname", 0.5)
	
	GUIEditor.gridlist[2] = guiCreateGridList(432, 208, 328, 344, false, GUIEditor.window[1])
	guiGridListAddColumn(GUIEditor.gridlist[2], "Name", 0.4)
	guiGridListAddColumn(GUIEditor.gridlist[2], "Author", 0.3)
	guiGridListAddColumn(GUIEditor.gridlist[2], "Gamemode", 0.5)
	guiGridListAddColumn(GUIEditor.gridlist[2], "resname", 0.5)
	
	GUIEditor.label[1] = guiCreateLabel(8, 184, 328, 16, "Maps to choose from:", false, GUIEditor.window[1])
	guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
	
	GUIEditor.label[2] = guiCreateLabel(432, 184, 328, 16, "Nominated maps:", false, GUIEditor.window[1])
	guiLabelSetHorizontalAlign(GUIEditor.label[2], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
	
	GUIEditor.label[3] = guiCreateLabel(8, 112, 752, 48, "Nominate maps panel", false, GUIEditor.window[1])
	guiLabelSetHorizontalAlign(GUIEditor.label[3], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[3], "center")
	
	GUIEditor.button[2] = guiCreateButton(352, 272, 64, 24, "Add", false, GUIEditor.window[1])
	addEventHandler("onClientGUIClick",GUIEditor.button[2],maps100_nominateMap,false)
	
	GUIEditor.button[3] = guiCreateButton(352, 304, 64, 24, "Remove", false, GUIEditor.window[1])
	addEventHandler("onClientGUIClick",GUIEditor.button[3],maps100_removeMap,false)
	
	GUIEditor.edit[1] = guiCreateEdit(24, 568, 192, 24, "", false, GUIEditor.window[1])
	GUIEditor.button[4] = guiCreateButton(224, 568, 96, 24, "Clear search", false, GUIEditor.window[1])
	addEventHandler("onClientGUIClick",GUIEditor.button[4],maps100_clearSearch,false)
	
	
	guiSetVisible(GUIEditor.window[1],false)
end
addEventHandler("onClientResourceStart",resourceRoot,maps100_buildGUI)

addEvent("maps100_openCloseGUI",true)
function maps100_openCloseGUI()
	if guiGetVisible(GUIEditor.window[1]) then
		guiSetVisible(GUIEditor.window[1],false)
		showCursor(false)
		guiSetInputMode("allow_binds")
	else
		guiSetVisible(GUIEditor.window[1],true)
		showCursor(true)
		guiSetInputMode("no_binds_when_editing")
	end
end
addEventHandler("maps100_openCloseGUI",root,maps100_openCloseGUI)

addEvent("maps100_receiveMapLists",true)
function receiveMapList(mapList,map100)
    MapList = mapList
	Map100 = map100
    maps100_rebuildGridLists()
end
addEventHandler("maps100_receiveMapLists",root,receiveMapList)

function maps100_rebuildGridLists()
    if #guiGetText(GUIEditor.edit[1]) == 0 then
        
        guiGridListClear(GUIEditor.gridlist[1])
		guiGridListSetSortingEnabled(GUIEditor.gridlist[1], false)

        for _,map in ipairs(MapList) do
            local author = map.author or "N/A"
            local name = map.name
            local resname = map.resname
            local gamemode = map.gamemode

            local row = guiGridListAddRow(GUIEditor.gridlist[1])

            guiGridListSetItemText(GUIEditor.gridlist[1],row,1,tostring(name),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,2,tostring(author),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,3,tostring(gamemode),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,4,tostring(resname),false,false)
        end
		
		guiGridListClear(GUIEditor.gridlist[2])
		guiGridListSetSortingEnabled(GUIEditor.gridlist[2], false)
		
		for _,map in ipairs(Map100) do
			local author = map.author or "N/A"
			local name = map.name
			local resname = map.resname
			local gamemode = map.gamemode
		
			local row = guiGridListAddRow(GUIEditor.gridlist[2])
		
			guiGridListSetItemText(GUIEditor.gridlist[2],row,1,tostring(name),false,false)
			guiGridListSetItemText(GUIEditor.gridlist[2],row,2,tostring(author),false,false)
			guiGridListSetItemText(GUIEditor.gridlist[2],row,3,tostring(gamemode),false,false)
			guiGridListSetItemText(GUIEditor.gridlist[2],row,4,tostring(resname),false,false)
		end
    end
end

function maps100_clearSearch(button,state)
    if state == "up" and button == "left" then
        if source == GUIEditor.button[2] then
            guiSetText(GUIEditor.edit[1],"")
        elseif source == GUIEditor.button[5] then
            guiSetText(GUIEditor.edit[2],"")
        end
    end
end

function maps100_handleSearches()
    if source == GUIEditor.edit[1] then
        if not MapList or #MapList == 0 or not Map100 then return end
        local searchQuery = guiGetText(GUIEditor.edit[1])
        if #searchQuery == 0 then
            maps100_rebuildGridLists()
        else
            local resultsTable_1 = maps100_searchTable(searchQuery,MapList)
			local resultsTable_2 = maps100_searchTable(searchQuery,Map100)
            maps100_populateSearchResults(resultsTable_1,GUIEditor.gridlist[1])
            maps100_populateSearchResults(resultsTable_2,GUIEditor.gridlist[2])
        end
    end
end
addEventHandler("onClientGUIChanged",root,maps100_handleSearches)

function maps100_searchTable(searchQuery,t)
    searchQuery = string.lower(tostring(searchQuery))
    if #searchQuery == 0 then return t end
	
    local results = {}
    for _,map in ipairs(t) do
        local match = false
        local name = string.find(string.lower( tostring(map.name) ),searchQuery)
        local author = string.find(string.lower( tostring(map.author) ),searchQuery)
        local resname = string.find(string.lower( tostring(map.resname) ),searchQuery)

        if type(name) == "number" or type(author) == "number" or type(resname) == "number" then
            match = true
        end
        if match then table.insert(results,map) end
    end
    return results
end

function maps100_populateSearchResults(resultsTable,gridlist)
    guiGridListClear(gridlist)
    for _,map in ipairs(resultsTable) do
        local author = map.author or "N/A"
        local name = map.name
        local resname = map.resname
        local gamemode = map.gamemode

        local row = guiGridListAddRow(gridlist)

        guiGridListSetItemText(gridlist,row,1,tostring(name),false,false)
        guiGridListSetItemText(gridlist,row,2,tostring(author),false,false)
        guiGridListSetItemText(gridlist,row,3,tostring(gamemode),false,false)
        guiGridListSetItemText(gridlist,row,4,tostring(resname),false,false)
    end
end

function maps100_nominateMap(button, state)
	if state == "up" and button == "left" then
		if source == GUIEditor.button[2] then
			local name = guiGridListGetItemText(GUIEditor.gridlist[1], guiGridListGetSelectedItem(GUIEditor.gridlist[1]), 1)
			local author = guiGridListGetItemText(GUIEditor.gridlist[1], guiGridListGetSelectedItem(GUIEditor.gridlist[1]), 2)
			local gamemode = guiGridListGetItemText(GUIEditor.gridlist[1], guiGridListGetSelectedItem(GUIEditor.gridlist[1]), 3)
			local resname = guiGridListGetItemText(GUIEditor.gridlist[1], guiGridListGetSelectedItem(GUIEditor.gridlist[1]), 4)
			if name and author and gamemode and resname then
				triggerServerEvent("maps100_addMap", resourceRoot, localPlayer, name, author, gamemode, resname)
			else
				return false
			end
		end
	end
end

function maps100_removeMap(button, state)
	if state == "up" and button == "left" then
		if source == GUIEditor.button[3] then
			local name = guiGridListGetItemText(GUIEditor.gridlist[2], guiGridListGetSelectedItem(GUIEditor.gridlist[2]), 1)
			local author = guiGridListGetItemText(GUIEditor.gridlist[2], guiGridListGetSelectedItem(GUIEditor.gridlist[2]), 2)
			local gamemode = guiGridListGetItemText(GUIEditor.gridlist[2], guiGridListGetSelectedItem(GUIEditor.gridlist[2]), 3)
			local resname = guiGridListGetItemText(GUIEditor.gridlist[2], guiGridListGetSelectedItem(GUIEditor.gridlist[2]), 4)
			if name and author and gamemode and resname then
				triggerServerEvent("maps100_delMap", resourceRoot, localPlayer, name, author, gamemode, resname)
			else
				return false
			end
		end
	end
end