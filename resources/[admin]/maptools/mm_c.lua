-- GUI
UploadedMaps = {}
DeletedMaps = {}
MapList = {}
isMapManager = false


    deleteMapPrompt = {
    button = {},
    window = {},
    edit = {},
    label = {}
}

undoGUI = {
    button = {},
    window = {},
    label = {}
}

GUIEditor = {
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {}
}
editfileslist = {
    button = {},
    window = {},
    gridlist = {}
}
fileditor = {
    button = {},
    window = {},
    memo = {}
}
function buildGUI()
    
    local screenW, screenH = guiGetScreenSize()
    GUIEditor.window[1] = guiCreateWindow((screenW - 621) / 2, (screenH - 519) / 2, 621, 519, "Manage Maps", false)
    guiWindowSetSizable(GUIEditor.window[1], false)

    GUIEditor.button[1] = guiCreateButton(222, 482, 147, 27, "Close", false, GUIEditor.window[1])
    addEventHandler("onClientGUIClick",GUIEditor.button[1],openCloseGUI,false)
    GUIEditor.tabpanel[1] = guiCreateTabPanel(9, 24, 602, 448, false, GUIEditor.window[1])

    GUIEditor.tab[1] = guiCreateTab("Maps", GUIEditor.tabpanel[1])

    GUIEditor.gridlist[1] = guiCreateGridList(10, 46, 582, 313, false, GUIEditor.tab[1])
    guiGridListAddColumn(GUIEditor.gridlist[1], "Name", 0.4)
    guiGridListAddColumn(GUIEditor.gridlist[1], "Likes", 0.1)
    guiGridListAddColumn(GUIEditor.gridlist[1], "Dislikes", 0.1)
    guiGridListAddColumn(GUIEditor.gridlist[1], "L-D", 0.1)
    guiGridListAddColumn(GUIEditor.gridlist[1], "Author", 0.3)
    guiGridListAddColumn(GUIEditor.gridlist[1], "resname", 0.5)
    GUIEditor.label[1] = guiCreateLabel(23, 13, 75, 23, "Search:", false, GUIEditor.tab[1])
    guiLabelSetHorizontalAlign(GUIEditor.label[1], "right", false)
    guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
    GUIEditor.edit[1] = guiCreateEdit(108, 13, 235, 23, "", false, GUIEditor.tab[1])
    GUIEditor.button[2] = guiCreateButton(356, 15, 80, 21, "Clear Search", false, GUIEditor.tab[1])
    totalMapsLabel = guiCreateLabel(440, 13, 300, 23, "", false, GUIEditor.tab[1])
    addEventHandler("onClientGUIClick",GUIEditor.button[2],clearSearch)
    GUIEditor.button[3] = guiCreateButton(214, 371, 144, 32, "Delete Selected Map", false, GUIEditor.tab[1])
	guiSetVisible(GUIEditor.button[3],false)
    addEventHandler("onClientGUIClick",GUIEditor.button[3],deleteMap,false)
    GUIEditor.button[13] = guiCreateButton(214+160, 371, 144, 32, "Edit Map", false, GUIEditor.tab[1])
	guiSetVisible(GUIEditor.button[13],false)
    addEventHandler("onClientGUIClick",GUIEditor.button[13],editmap,false)

    GUIEditor.tab[2] = guiCreateTab("Deleted Maps", GUIEditor.tabpanel[1])

    GUIEditor.gridlist[2] = guiCreateGridList(4, 55, 593, 317, false, GUIEditor.tab[2])
    guiGridListAddColumn(GUIEditor.gridlist[2], "Name", 0.4)
    guiGridListAddColumn(GUIEditor.gridlist[2], "Reason", 0.4)
    guiGridListAddColumn(GUIEditor.gridlist[2], "Deleted By", 0.2)
    guiGridListAddColumn(GUIEditor.gridlist[2], "Map Author", 0.3)
    guiGridListAddColumn(GUIEditor.gridlist[2], "resname", 0.2)
    GUIEditor.button[4] = guiCreateButton(208, 378, 156, 29, "Undo Deletion", false, GUIEditor.tab[2])
    addEventHandler("onClientGUIClick",GUIEditor.button[4],undoDeleteMap,false)

    GUIEditor.label[2] = guiCreateLabel(-25, 21, 95, 20, "Search:", false, GUIEditor.tab[2])
    guiLabelSetHorizontalAlign(GUIEditor.label[2], "right", false)
    guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
    GUIEditor.edit[2] = guiCreateEdit(76, 21, 254, 24, "", false, GUIEditor.tab[2])
    GUIEditor.button[5] = guiCreateButton(335, 25, 68, 20, "Clear search", false, GUIEditor.tab[2])
    addEventHandler("onClientGUIClick",GUIEditor.button[5],clearSearch)


    GUIEditor.label[3] = guiCreateLabel(335, 24, 276, 43, "", false, GUIEditor.window[1])   
    guiSetVisible(GUIEditor.window[1],false) 

    guiGridListSetSortingEnabled(GUIEditor.gridlist[1],false)
    guiGridListSetSortingEnabled(GUIEditor.gridlist[2],false)
    
	-- Uploaded maps
    GUIEditor.tab[3] = guiCreateTab("Uploaded Maps", GUIEditor.tabpanel[1])

    GUIEditor.gridlist[3] = guiCreateGridList(10, 10, 582, 313, false, GUIEditor.tab[3])
    guiGridListAddColumn(GUIEditor.gridlist[3], "Name", 0.48)
    guiGridListAddColumn(GUIEditor.gridlist[3], "Author", 0.2)
    guiGridListAddColumn(GUIEditor.gridlist[3], "Date", 0.2)
    guiGridListAddColumn(GUIEditor.gridlist[3], "Status", 0.1)
    guiGridListAddColumn(GUIEditor.gridlist[3], "resname", 0.3)
    GUIEditor.label[3] = guiCreateLabel(25, 333, 125, 23, "Comment on map:", false, GUIEditor.tab[3])
    guiLabelSetHorizontalAlign(GUIEditor.label[3], "right", false)
    guiLabelSetVerticalAlign(GUIEditor.label[3], "center")
    GUIEditor.edit[3] = guiCreateEdit(158, 333, 235, 23, "", false, GUIEditor.tab[3])
    GUIEditor.button[6] = guiCreateButton(214-160, 371, 144, 32, "Test map next", false, GUIEditor.tab[3])
    addEventHandler("onClientGUIClick",GUIEditor.button[6],nextmap,false)
    GUIEditor.button[7] = guiCreateButton(214, 371, 144, 32, "Accept Map", false, GUIEditor.tab[3])
    addEventHandler("onClientGUIClick",GUIEditor.button[7],acceptmap,false)
    GUIEditor.button[8] = guiCreateButton(214+160, 371, 144, 32, "Decline Map", false, GUIEditor.tab[3])
    addEventHandler("onClientGUIClick",GUIEditor.button[8],declinemap,false)


    -- Undo deletion prompt

    undoGUI.window[1] = guiCreateWindow((screenW - 344) / 2, (screenH - 132) / 2, 344, 132, "Are you sure?", false)
    guiWindowSetSizable(undoGUI.window[1], false)

    undoGUI.label[1] = guiCreateLabel(12, 23, 315, 41, "Are you sure you want to restore \"\" ?", false, undoGUI.window[1])
    undoGUI.button[1] = guiCreateButton(12, 84, 93, 38, "Yes", false, undoGUI.window[1])
    addEventHandler("onClientGUIClick",undoGUI.button[1],undoDeleteConfirmation,false)
    undoGUI.button[2] = guiCreateButton(234, 84, 93, 38, "No", false, undoGUI.window[1]) 
    addEventHandler("onClientGUIClick",undoGUI.button[2],undoDeleteConfirmation,false)
    guiSetVisible(undoGUI.window[1],false) 



    -- Delete map prompt
    deleteMapPrompt.window[1] = guiCreateWindow((screenW - 432) / 2, (screenH - 179) / 2, 432, 179, "Are you sure?", false)
    guiWindowSetSizable(deleteMapPrompt.window[1], false)

    deleteMapPrompt.edit[1] = guiCreateEdit(96, 69, 318, 35, "", false, deleteMapPrompt.window[1])
    deleteMapPrompt.label[1] = guiCreateLabel(14, 67, 76, 37, "Reason:", false, deleteMapPrompt.window[1])
    guiLabelSetHorizontalAlign(deleteMapPrompt.label[1], "right", false)
    guiLabelSetVerticalAlign(deleteMapPrompt.label[1], "center")
    deleteMapPrompt.label[2] = guiCreateLabel(33, 28, 381, 39, "Are you sure you want to delete '' ?", false, deleteMapPrompt.window[1])
    guiLabelSetHorizontalAlign(deleteMapPrompt.label[2], "left", true)
    deleteMapPrompt.button[1] = guiCreateButton(26, 124, 118, 45, "Yes", false, deleteMapPrompt.window[1])
    addEventHandler("onClientGUIClick",deleteMapPrompt.button[1],deleteMapConfirmation,false)
    deleteMapPrompt.button[2] = guiCreateButton(296, 124, 118, 45, "No", false, deleteMapPrompt.window[1])
    addEventHandler("onClientGUIClick",deleteMapPrompt.button[2],deleteMapConfirmation,false)

    guiSetVisible(deleteMapPrompt.window[1],false)
	
	
    -- Edit files list prompt
    editfileslist.window[1] = guiCreateWindow((screenW - 432) / 2, (screenH - 400) / 2, 432, 400, "Choose file to edit", false)
    guiWindowSetSizable(editfileslist.window[1], false)

    editfileslist.gridlist[1] = guiCreateGridList(10, 30, 432, 325, false, editfileslist.window[1])
    guiGridListAddColumn(editfileslist.gridlist[1], "Source", 0.7)
    guiGridListAddColumn(editfileslist.gridlist[1], "Type", 0.2)
    editfileslist.button[1] = guiCreateButton(20, 360, 180, 30, "Edit file", false, editfileslist.window[1])
    editfileslist.button[2] = guiCreateButton(220, 360, 180, 30, "Cancel", false, editfileslist.window[1])
    addEventHandler("onClientGUIClick",editfileslist.button[1],editfile,false)
    addEventHandler("onClientGUIClick",editfileslist.button[2],function()showCursor(false);guiSetVisible(editfileslist.window[1],false)end,false)

    guiSetVisible(editfileslist.window[1],false)
	
    -- File editor
    fileditor.window[1] = guiCreateWindow((screenW - 621) / 2, (screenH - 519) / 2, 621, 519, "Edit file", false)
    guiWindowSetSizable(fileditor.window[1], false)

    fileditor.memo[1] = guiCreateMemo(10, 30, 600, 425, "", false, fileditor.window[1])
    fileditor.button[1] = guiCreateButton(50, 475, 200, 30, "Save file", false, fileditor.window[1])
    fileditor.button[2] = guiCreateButton(350, 475, 200, 30, "Close", false, fileditor.window[1])
    addEventHandler("onClientGUIClick",fileditor.button[1],savefile,false)
    addEventHandler("onClientGUIClick",fileditor.button[2],function()showCursor(false);guiSetVisible(fileditor.window[1],false);guiSetInputMode("allow_binds")end,false)

    guiSetVisible(fileditor.window[1],false)
end
addEventHandler("onClientResourceStart",resourceRoot,buildGUI)

function rebuildGridLists()
    -- rebuild maplist if no search query

    if #guiGetText(GUIEditor.edit[1]) == 0 then
        
        guiGridListClear(GUIEditor.gridlist[1])
		guiGridListSetSortingEnabled(GUIEditor.gridlist[1], true)
        if type(#MapList) == "number" then
            guiSetText( totalMapsLabel, "Total maps: "..tostring(#MapList) )
        end

        for _,map in ipairs(MapList) do
            local author = map.author or "N/A"
            local name = map.name
            local resname = map.resname
            local likes = map.likes
            local dislikes = map.dislikes
			local lminusd = dislikes and dislikes ~= "-" and likes - dislikes or ""

            local row = guiGridListAddRow(GUIEditor.gridlist[1])

            guiGridListSetItemText(GUIEditor.gridlist[1],row,1,tostring(name),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,2,tostring(likes),false,true)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,3,tostring(dislikes),false,true)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,4,tostring(lminusd),false,true)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,5,tostring(author),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,6,tostring(resname),false,false)
        end
    end

    -- rebuild deleted maplist if no search query
    if #guiGetText(GUIEditor.edit[2]) == 0 then
        guiGridListClear(GUIEditor.gridlist[2])
        for _,map in ipairs(DeletedMaps) do
            local author = map.author or "N/A"
            local name = map.name
            local resname = map.resname
            local deletedBy = map.deletedBy
            local deleteReason = map.deleteReason

            local row = guiGridListAddRow(GUIEditor.gridlist[2])
     
            guiGridListSetItemText(GUIEditor.gridlist[2],row,1,tostring(name),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[2],row,2,tostring(deleteReason),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[2],row,3,tostring(deletedBy),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[2],row,4,tostring(author),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[2],row,5,tostring(resname),false,false)
        end
    end
	
	-- rebuild uploaded maplist
	guiGridListClear(GUIEditor.gridlist[3])
	for _,map in ipairs(UploadedMaps) do
		local row = guiGridListAddRow(GUIEditor.gridlist[3])
		guiGridListSetItemText(GUIEditor.gridlist[3],row,1,tostring(map.name or "N/A"),false,false)
		guiGridListSetItemText(GUIEditor.gridlist[3],row,2,tostring(map.author or "N/A"),false,false)
		guiGridListSetItemText(GUIEditor.gridlist[3],row,3,FormatDate(map.uploadtick),false,false)
		guiGridListSetItemText(GUIEditor.gridlist[3],row,4,tostring(map.new),false,false)
		guiGridListSetItemText(GUIEditor.gridlist[3],row,5,string.gsub(map.resname, "_newupload", ""),false,false)
	end
end
function FormatDate(timestamp)
	local t =  getRealTime(timestamp)
	-- return string.format("%02d/%02d/'%02d %02d:%02d:%02d", t.monthday, t.month+1, t.year - 100, t.hour, t.minute, t.second)
	return string.format("%02d/%02d/%d", t.monthday, t.month+1, t.year)
end

addEvent("mm_receiveMapLists",true)
function receiveMapList(uplMapList,delMapList,mapList, manager)
    UploadedMaps = uplMapList
    DeletedMaps = delMapList
    MapList = mapList
	guiSetVisible(GUIEditor.button[4],manager)
	guiSetVisible(GUIEditor.button[3],manager)
	guiSetVisible(GUIEditor.button[13],manager)
	guiSetVisible(GUIEditor.button[6],manager)
	guiSetVisible(GUIEditor.button[7],manager)
	guiSetVisible(GUIEditor.button[8],manager)
	guiSetVisible(GUIEditor.edit[3],manager)
	guiSetVisible(GUIEditor.label[3],manager)
    rebuildGridLists()
end
addEventHandler("mm_receiveMapLists",root,receiveMapList)

function openCloseGUI()
	if guiGetVisible(GUIEditor.window[1]) then
		guiSetVisible(GUIEditor.window[1],false)
		showCursor(false)
		guiSetInputMode("allow_binds")
	else
		guiSetVisible(GUIEditor.window[1],true)
		showCursor(true)
		guiSetInputMode("no_binds_when_editing")
		guiSetVisible(fileditor.window[1],false)
		guiSetVisible(editfileslist.window[1],false)
	end
end
addCommandHandler("managemaps",openCloseGUI)
addCommandHandler("mm",openCloseGUI)
addCommandHandler("deletedmaps",openCloseGUI)
addCommandHandler("maps",openCloseGUI)


function clearSearch(button,state)


    if state == "up" and button == "left" then
        if source == GUIEditor.button[2] then
            guiSetText(GUIEditor.edit[1],"")
        elseif source == GUIEditor.button[5] then
            guiSetText(GUIEditor.edit[2],"")
        end
    end
end


function handleSearches()
     

    if source == GUIEditor.edit[1] then
        if not MapList or #MapList == 0 then return end
        local searchQuery = guiGetText(GUIEditor.edit[1])
        if #searchQuery == 0 then
            rebuildGridLists()
        else
            local resultsTable = searchTable(searchQuery,MapList)
            populateSearchResults(resultsTable,GUIEditor.gridlist[1])
        end


    elseif source == GUIEditor.edit[2] then

        if not DeletedMaps or #DeletedMaps == 0 then return end

        local searchQuery = guiGetText(GUIEditor.edit[2])
        if #searchQuery == 0 then
            rebuildGridLists()
        else
            local resultsTable = searchTable(searchQuery,DeletedMaps)
            populateSearchResults(resultsTable,GUIEditor.gridlist[2])
        end
    end
end
addEventHandler("onClientGUIChanged",root,handleSearches)

function populateSearchResults(table,gridlist)
    if gridlist == GUIEditor.gridlist[1] then -- maplist
        guiGridListClear(gridlist)
        for _,map in ipairs(table) do
            local author = map.author or "N/A"
            local name = map.name
            local resname = map.resname
            local likes = map.likes
            local dislikes = map.dislikes
			local lminusd = dislikes and dislikes ~= "-" and likes - dislikes or ""

            local row = guiGridListAddRow(GUIEditor.gridlist[1])

            guiGridListSetItemText(GUIEditor.gridlist[1],row,1,tostring(name),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,2,tostring(likes),false,true)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,3,tostring(dislikes),false,true)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,4,tostring(lminusd),false,true)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,5,tostring(author),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[1],row,6,tostring(resname),false,false)
        end

    elseif gridlist == GUIEditor.gridlist[2] then -- deleted maplist
        guiGridListClear(gridlist)
        for _,map in ipairs(table) do
            local author = map.author or "N/A"
            local name = map.name
            local resname = map.resname
            local deletedBy = map.deletedBy
            local deleteReason = map.deleteReason

            local row = guiGridListAddRow(GUIEditor.gridlist[2])
     
            guiGridListSetItemText(GUIEditor.gridlist[2],row,1,tostring(name),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[2],row,2,tostring(deleteReason),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[2],row,3,tostring(deletedBy),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[2],row,4,tostring(author),false,false)
            guiGridListSetItemText(GUIEditor.gridlist[2],row,5,tostring(resname),false,false)
     
        end
    end
end
function searchTable(searchQuery,t)
    searchQuery = string.lower(tostring(searchQuery))
    if #searchQuery == 0 then return t end
    local mode = 1 -- 1 = map list, 2 = deleted map list
    if t[1]["deletedBy"] then mode = 2 end


    local results = {}
    for _,map in ipairs(t) do
        local match = false
        if mode == 1 then
            local name = string.find(string.lower( tostring(map.name) ),searchQuery)
            local author = string.find(string.lower( tostring(map.author) ),searchQuery)
            local resname = string.find(string.lower( tostring(map.resname) ),searchQuery)

            if type(name) == "number" or type(author) == "number" or type(resname) == "number" then
                match = true
            end

        elseif mode == 2 then
            local name = string.find(string.lower( tostring(map.name) ),searchQuery)
            local author = string.find(string.lower( tostring(map.author) ),searchQuery)
            local resname = string.find(string.lower( tostring(map.resname) ),searchQuery)
            local deletedBy = string.find(string.lower( tostring(map.deletedBy) ),searchQuery)
            local reason = string.find(string.lower( tostring(map.reason) ),searchQuery)

            if type(name) == "number" or type(author) == "number" or type(resname) == "number" or type(deletedBy) == "number" or type(reason) == "number" then
                match = true
            end

        end
        if match then table.insert(results,map) end
    end
    return results
end

undoSelected = {}
function undoDeleteMap()
    local gridlist = GUIEditor.gridlist[2]
    local selected = guiGridListGetSelectedItem(gridlist)
    if not selected or selected == -1 then outputChatBox("You must select a map from the list first.",255,0,0) return end


    local name = guiGridListGetItemText(gridlist,selected,1)
    local reason = guiGridListGetItemText(gridlist,selected,2)
    local deletedBy = guiGridListGetItemText(gridlist,selected,3)
    local author = guiGridListGetItemText(gridlist,selected,4)
    local resname = guiGridListGetItemText(gridlist,selected,5)
    local t = {name = name, reason = reason, deletedBy = deletedBy, resname = resname, author = author}
    undoSelected = t

    guiSetText(undoGUI.label[1],"Are you sure you want to restore '"..undoSelected.name .."' ?")
    guiSetVisible(undoGUI.window[1],true)
    guiBringToFront(undoGUI.window[1])

end
function undoDeleteConfirmation(button,state)
    if state == "up" and button == "left" then
        if not undoSelected.name then guiSetVisible(undoGUI.window[1],false) return end
        if source == undoGUI.button[1] then -- if yes
            triggerServerEvent("cmm_restoreMap",resourceRoot,undoSelected)
            undoSelected = {}
            guiSetVisible(undoGUI.window[1],false) 
        elseif source == undoGUI.button[2] then-- if no
            undoSelected = {}
            guiSetText(undoGUI.label[1],"")
            guiSetVisible(undoGUI.window[1],false)
        end
    end
end

-- Editing resources --
addEvent("editMapFilesList", true)
function editMapFilesList(mapname, files)
	guiSetVisible(fileditor.window[1],false)
	guiGridListClear(editfileslist.gridlist[1])
	editfileslist.mapname = mapname
	for k,v in ipairs(files) do
		local row = guiGridListAddRow(editfileslist.gridlist[1])
		guiGridListSetItemText(editfileslist.gridlist[1],row,1,tostring(v.file),false,false)
		guiGridListSetItemText(editfileslist.gridlist[1],row,2,tostring(v.type),false,false)
	end
	guiSetVisible(editfileslist.window[1],true)
	showCursor(true)
end
addEventHandler("editMapFilesList", resourceRoot, editMapFilesList)

addEvent("editFileText", true)
function editFileText(mapname, src, text)
	guiSetVisible(editfileslist.window[1],false)
	fileditor.mapname = mapname
	fileditor.src = src
	guiSetText(fileditor.memo[1], text)
	guiSetText(fileditor.window[1], "Editing :" .. mapname .. '/' .. src)
	guiSetVisible(fileditor.window[1],true)
	showCursor(true)
	guiSetInputMode("no_binds_when_editing")
end
addEventHandler("editFileText", resourceRoot, editFileText)

-- Button handlers --

deleteMapSelection = {}
function deleteMap()
    local gridlist = GUIEditor.gridlist[1]
    local selected = guiGridListGetSelectedItem(gridlist)
    if not selected or selected == -1 then outputChatBox("You must select a map from the list first.",255,0,0) return end


    local name = guiGridListGetItemText(gridlist,selected,1)
    local author = guiGridListGetItemText(gridlist,selected,5)
    local resname = guiGridListGetItemText(gridlist,selected,6)

    local t = {name = name, resname = resname, author = author}
    deleteMapSelection = t

    guiSetText(deleteMapPrompt.label[2],"Are you sure you want to delete '"..deleteMapSelection.name .."' ?")
    guiSetText(deleteMapPrompt.edit[1],"")
    guiSetVisible(deleteMapPrompt.window[1],true)
    guiBringToFront(deleteMapPrompt.window[1])
end

function deleteMapConfirmation(button,state)
    if state == "up" and button == "left" then
        if not deleteMapSelection.name then guiSetVisible(deleteMapPrompt.window[1],false) return end
        if source == deleteMapPrompt.button[1] then -- if yes
            
            if not guiGetText(deleteMapPrompt.edit[1]) or #guiGetText(deleteMapPrompt.edit[1]) < 1 then outputChatBox("Please give a reason for map deletion") return end
            local reason = guiGetText(deleteMapPrompt.edit[1])

            

            triggerServerEvent("cmm_deleteMap",resourceRoot,deleteMapSelection,reason)
            deleteMapSelection = {}
            guiSetVisible(deleteMapPrompt.window[1],false) 
        elseif source == deleteMapPrompt.button[2] then-- if no
            deleteMapSelection = {}
            guiSetText(deleteMapPrompt.label[1],"")
            guiSetVisible(deleteMapPrompt.window[1],false)
        end
    end
end

function nextmap()
    local gridlist = GUIEditor.gridlist[3]
    local selected = guiGridListGetSelectedItem(gridlist)
    if not selected or selected == -1 then outputChatBox("You must select a map from the list first.",255,0,0) return end

    local resname = guiGridListGetItemText(gridlist,selected,5)
    triggerServerEvent("nextmap",resourceRoot,resname)
end

function acceptmap()
    local gridlist = GUIEditor.gridlist[3]
    local selected = guiGridListGetSelectedItem(gridlist)
    if not selected or selected == -1 then outputChatBox("You must select a map from the list first.",255,0,0) return end

    local resname = guiGridListGetItemText(gridlist,selected,5)
	local comment = guiGetText(GUIEditor.edit[3])
    triggerServerEvent("acceptmap",resourceRoot,resname,comment)
end

function declinemap()
    local gridlist = GUIEditor.gridlist[3]
    local selected = guiGridListGetSelectedItem(gridlist)
    if not selected or selected == -1 then outputChatBox("You must select a map from the list first.",255,0,0) return end

    local resname = guiGridListGetItemText(gridlist,selected,5)
	local comment = guiGetText(GUIEditor.edit[3])
    triggerServerEvent("declinemap",resourceRoot,resname,comment)
end

function editmap()
    local gridlist = GUIEditor.gridlist[1]
    local selected = guiGridListGetSelectedItem(gridlist)
    if not selected or selected == -1 then outputChatBox("You must select a map from the list first.",255,0,0) return end

    local resname = guiGridListGetItemText(gridlist,selected,6)
    triggerServerEvent("editmap",resourceRoot,resname)
	openCloseGUI()
end

function editfile()
    local gridlist = editfileslist.gridlist[1]
    local selected = guiGridListGetSelectedItem(gridlist)
    if not selected or selected == -1 then outputChatBox("You must select a file from the list first.",255,0,0) return end

    local filename = guiGridListGetItemText(gridlist,selected,1)
    triggerServerEvent("editfile",resourceRoot,editfileslist.mapname,filename)
	guiSetVisible(editfileslist.window[1],false)
	showCursor(false)
end

function savefile()
	triggerServerEvent("savefile", resourceRoot, fileditor.mapname, fileditor.src, guiGetText(fileditor.memo[1]))
end