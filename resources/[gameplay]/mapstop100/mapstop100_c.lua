MapList = {} -- All maps on the server
Map100 = {} -- All nominated maps
MapsList = {} -- All maps on the server, detailed
VoterList = {} -- All voters, detailed

GUIEditor = {
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
	combobox = {},
	image = {}
}

MainPanel = {
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
	combobox = {},
	image = {}
}

TablesInsight = {
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
	combobox = {},
	image = {}
}

function maps100_buildGUI()
	local screenW, screenH = guiGetScreenSize()
	
	---- Nominating Panel ----
	
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
	
	---- Main Panel ----
	
	MainPanel.window[1] = guiCreateWindow((screenW - 512) / 2, (screenH - 472) / 2, 512, 472, "Maps top 100", false)
	guiWindowSetSizable(MainPanel.window[1], false)
	
	MainPanel.image[1] = guiCreateStaticImage(64, 16, 384, 96, "mapstop100_logo.png", false, MainPanel.window[1])
	
	MainPanel.button[1] = guiCreateButton(8, 120, 496, 80, "Nominating panel", false, MainPanel.window[1])
	addEventHandler("onClientGUIClick",MainPanel.button[1],maps100_openCloseGUI,false)
	
	MainPanel.button[2] = guiCreateButton(8, 208, 496, 80, "Voting panel", false, MainPanel.window[1])
	addEventHandler("onClientGUIClick",MainPanel.button[2],maps100_openCloseGUI,false)
	
	MainPanel.button[3] = guiCreateButton(8, 296, 496, 80, "Tables", false, MainPanel.window[1])
	addEventHandler("onClientGUIClick",MainPanel.button[3],maps100_openCloseGUI,false)
	
	MainPanel.button[4] = guiCreateButton(8, 384, 496, 80, "Close", false, MainPanel.window[1])
	addEventHandler("onClientGUIClick",MainPanel.button[4],maps100_openCloseGUI,false)
	
	guiSetVisible(MainPanel.window[1],false)
	
	---- Tables Insight ----
	
	TablesInsight.window[1] = guiCreateWindow((screenW - 768) / 2, (screenH - 640) / 2, 768, 640, "Maps top 100 - Tables", false)
	guiWindowSetSizable(TablesInsight.window[1], false)
	
	TablesInsight.button[1] = guiCreateButton(320, 608, 128, 24, "Close", false, TablesInsight.window[1])
	addEventHandler("onClientGUIClick",TablesInsight.button[1],maps100_openCloseGUI,false)
	
	TablesInsight.tabpanel[1] = guiCreateTabPanel(8, 24, 752, 576, false, TablesInsight.window[1])
	
	TablesInsight.tab[1] = guiCreateTab("Votes", TablesInsight.tabpanel[1])
	
	TablesInsight.combobox[1] = guiCreateComboBox(8, 8, 296, 128, "forumid", false, TablesInsight.tab[1])
	
	TablesInsight.combobox[2] = guiCreateComboBox(312, 8, 296, 128, "options", false, TablesInsight.tab[1])
	guiComboBoxAddItem(TablesInsight.combobox[2], "choice1")
	guiComboBoxAddItem(TablesInsight.combobox[2], "choice2")
	guiComboBoxAddItem(TablesInsight.combobox[2], "choice3")
	guiComboBoxAddItem(TablesInsight.combobox[2], "choice4")
	guiComboBoxAddItem(TablesInsight.combobox[2], "choice5")
	guiComboBoxAddItem(TablesInsight.combobox[2], "all")
	
	TablesInsight.button[2] = guiCreateButton(616, 8, 128, 24, "Remove", false, TablesInsight.tab[1])
	addEventHandler("onClientGUIClick",TablesInsight.button[2],maps100_removeVote,false)
	
	TablesInsight.gridlist[1] = guiCreateGridList(8, 32, 736, 512, false, TablesInsight.tab[1])
	guiGridListAddColumn(TablesInsight.gridlist[1], "id", 0.05)
	guiGridListAddColumn(TablesInsight.gridlist[1], "forumid", 0.1)
	guiGridListAddColumn(TablesInsight.gridlist[1], "choice1", 0.2)
	guiGridListAddColumn(TablesInsight.gridlist[1], "choice2", 0.2)
	guiGridListAddColumn(TablesInsight.gridlist[1], "choice3", 0.2)
	guiGridListAddColumn(TablesInsight.gridlist[1], "choice4", 0.2)
	guiGridListAddColumn(TablesInsight.gridlist[1], "choice5", 0.2)
	
	TablesInsight.tab[2] = guiCreateTab("Nominees", TablesInsight.tabpanel[1])
	
	TablesInsight.button[3] = guiCreateButton(8, 8, 128, 24, "Count votes", false, TablesInsight.tab[2])
	addEventHandler("onClientGUIClick",TablesInsight.button[3],maps100_countVotes,false)
	
	TablesInsight.button[4] = guiCreateButton(8, 40, 128, 24, "Start Event", false, TablesInsight.tab[2])
	addEventHandler("onClientGUIClick",TablesInsight.button[4],maps100_startEvent,false)
	
	TablesInsight.button[5] = guiCreateButton(8, 72, 128, 24, "Stop Event", false, TablesInsight.tab[2])
	addEventHandler("onClientGUIClick",TablesInsight.button[5],maps100_stopEvent,false)
	
	TablesInsight.label[1] = guiCreateLabel(144, 8, 600, 24, "Counts the casted votes for each map and ranks them in descending order.", false, TablesInsight.tab[2])
	guiLabelSetHorizontalAlign(TablesInsight.label[1], "left", false)
	guiLabelSetVerticalAlign(TablesInsight.label[1], "center")
	
	TablesInsight.label[2] = guiCreateLabel(144, 36, 600, 32, "Start the event at the selected rank. E.g. if you select rank 32 it will play 32, 31, 30, 29.. etc. It adds all\nmaps to the queued maps list.", false, TablesInsight.tab[2])
	guiLabelSetHorizontalAlign(TablesInsight.label[2], "left", false)
	guiLabelSetVerticalAlign(TablesInsight.label[2], "center")
	
	TablesInsight.label[3] = guiCreateLabel(144, 72, 600, 24, "Stops the event, removes all remaining added maps from the queued maps list.", false, TablesInsight.tab[2])
	guiLabelSetHorizontalAlign(TablesInsight.label[3], "left", false)
	guiLabelSetVerticalAlign(TablesInsight.label[3], "center")
	
	TablesInsight.gridlist[2] = guiCreateGridList(8, 104, 736, 432, false, TablesInsight.tab[2])
	guiGridListAddColumn(TablesInsight.gridlist[2], "id", 0.05)
	guiGridListAddColumn(TablesInsight.gridlist[2], "mapresourcename", 0.2)
	guiGridListAddColumn(TablesInsight.gridlist[2], "rank", 0.05)
	guiGridListAddColumn(TablesInsight.gridlist[2], "votes", 0.05)
	guiGridListAddColumn(TablesInsight.gridlist[2], "L/D", 0.05)
	guiGridListAddColumn(TablesInsight.gridlist[2], "mapname", 0.2)
	guiGridListAddColumn(TablesInsight.gridlist[2], "author", 0.2)
	guiGridListAddColumn(TablesInsight.gridlist[2], "gamemode", 0.15)
	
	guiSetVisible(TablesInsight.window[1],false)
end
addEventHandler("onClientResourceStart",resourceRoot,maps100_buildGUI)

addEvent("maps100_openCloseGUI",true)
function maps100_openCloseGUI(button, state)
	if button and state then
		if state == "up" and button == "left" then
			if source == MainPanel.button[1] then
				guiSetVisible(MainPanel.window[1],false)
				guiSetVisible(GUIEditor.window[1],true)
			end
			if source == MainPanel.button[2] then
				guiSetVisible(MainPanel.window[1],false)
				guiSetVisible(VotesEditor.window[1],true)
			end
			if source == MainPanel.button[3] then
				guiSetVisible(MainPanel.window[1],false)
				triggerServerEvent("maps100_fetchInsight", resourceRoot, localPlayer)
				guiSetVisible(TablesInsight.window[1],true)
			end
			if source == MainPanel.button[4] then
				guiSetVisible(MainPanel.window[1],false)
				showCursor(false)
				guiSetInputMode("allow_binds")
			end
			if source == GUIEditor.button[1] then
				guiSetVisible(GUIEditor.window[1],false)
				showCursor(false)
				guiSetInputMode("allow_binds")
			end
			if source == TablesInsight.button[1] then
				guiSetVisible(TablesInsight.window[1],false)
				showCursor(false)
				guiSetInputMode("allow_binds")
			end
		end
	else
		if guiGetVisible(MainPanel.window[1]) or guiGetVisible(GUIEditor.window[1]) or guiGetVisible(TablesInsight.window[1]) then
			if guiGetVisible(MainPanel.window[1]) then
				guiSetVisible(MainPanel.window[1],false)
			end
			if guiGetVisible(GUIEditor.window[1]) then
				guiSetVisible(GUIEditor.window[1],false)
			end
			if guiGetVisible(TablesInsight.window[1]) then
				guiSetVisible(TablesInsight.window[1],false)
			end
			showCursor(false)
			guiSetInputMode("allow_binds")
		else
			guiSetVisible(MainPanel.window[1],true)
			showCursor(true)
			guiSetInputMode("no_binds_when_editing")
		end
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

addEvent("maps100_receiveInsight",true)
function receiveInsight(voterList, mapsList)
    VoterList = voterList
	MapsList = mapsList
    maps100_rebuildInsight()
end
addEventHandler("maps100_receiveInsight",root,receiveInsight)

function maps100_rebuildInsight()
	guiGridListClear(TablesInsight.gridlist[1])
	guiGridListSetSortingEnabled(TablesInsight.gridlist[1], false)
	guiComboBoxClear(TablesInsight.combobox[1])
	
	for _,voter in ipairs(VoterList) do
		local id = voter.id
		local forumid = voter.forumid
		local choice1 = voter.choice1
		local choice2 = voter.choice2
		local choice3 = voter.choice3
		local choice4 = voter.choice4
		local choice5 = voter.choice5
		
		local row = guiGridListAddRow(TablesInsight.gridlist[1])
		
		guiGridListSetItemText(TablesInsight.gridlist[1],row,1,tostring(id),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[1],row,2,tostring(forumid),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[1],row,3,tostring(choice1),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[1],row,4,tostring(choice2),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[1],row,5,tostring(choice3),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[1],row,6,tostring(choice4),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[1],row,7,tostring(choice5),false,false)
		
		guiComboBoxAddItem(TablesInsight.combobox[1], forumid)
	end
	
	guiGridListClear(TablesInsight.gridlist[2])
	guiGridListSetSortingEnabled(TablesInsight.gridlist[2], false)
	
	for _,map in ipairs(MapsList) do
		local id = map.id
		local mapresourcename = map.mapresourcename
		local rank = map.rank
		local votes = map.votes
		local balance = map.balance
		local mapname = map.mapname
		local author = map.author
		local gamemode = map.gamemode
        
		local row = guiGridListAddRow(TablesInsight.gridlist[2])
		
		guiGridListSetItemText(TablesInsight.gridlist[2],row,1,tostring(id),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[2],row,2,tostring(mapresourcename),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[2],row,3,tostring(rank),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[2],row,4,tostring(votes),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[2],row,5,tostring(balance),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[2],row,6,tostring(mapname),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[2],row,7,tostring(author),false,false)
		guiGridListSetItemText(TablesInsight.gridlist[2],row,8,tostring(gamemode),false,false)
	end
end

function maps100_removeVote(button, state)
	if state == "up" and button == "left" then
		if source == TablesInsight.button[2] then
			local forumid = guiComboBoxGetItemText(TablesInsight.combobox[1], guiComboBoxGetSelected(TablesInsight.combobox[1]))
			local option = guiComboBoxGetItemText(TablesInsight.combobox[2], guiComboBoxGetSelected(TablesInsight.combobox[2]))
			if forumid and option then
				triggerServerEvent("maps100_removeVote", resourceRoot, localPlayer, forumid, option)
			else
				return false
			end
		end
	end
end

function maps100_countVotes(button, state)
	if state == "up" and button == "left" then
		if source == TablesInsight.button[3] then
			triggerServerEvent("maps100_countVotes", resourceRoot, localPlayer)
		end
	end
end

function maps100_startEvent(button, state)
	if state == "up" and button == "left" then
		if source == TablesInsight.button[4] then
			local rank = guiGridListGetItemText(TablesInsight.gridlist[2], guiGridListGetSelectedItem(TablesInsight.gridlist[2]), 3)
			if tonumber(rank) then
				triggerServerEvent("mapstop100_insertTrigger", resourceRoot, localPlayer, rank)
				outputChatBox("Adding maps to map queue from rank " .. tostring(rank) .. " to rank 1.")
			else
				outputChatBox("No starting point specified, plese select a map.")
			end
		end
	end
end

function maps100_stopEvent(button, state)
	if state == "up" and button == "left" then
		if source == TablesInsight.button[5] then
			triggerServerEvent("mapstop100_removeTrigger", resourceRoot, localPlayer)
		end
	end
end