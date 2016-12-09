welcomeText = "Welcome to the Mr.Green Maps top 100! Choose maps from the list on the left you want to vote for and add\nthem with the 'Add' button. If you made a mistake simply remove the vote with the 'remove' button. When\nyou carefully selected the maps press the 'Cast vote' button. You may vote up to a maximum of 5 maps."

VotesList = {}
CastList = {}

VotesEditor = {
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
	image = {}
}

function votes100_buildGUI()
	local screenW, screenH = guiGetScreenSize()
	VotesEditor.window[1] = guiCreateWindow((screenW - 768) / 2, (screenH - 640) / 2, 768, 640, "Maps top 100", false)
	guiWindowSetSizable(VotesEditor.window[1], false)
	
	VotesEditor.button[1] = guiCreateButton(320, 608, 128, 24, "Close", false, VotesEditor.window[1])
	addEventHandler("onClientGUIClick",VotesEditor.button[1],votes100_openCloseGUI,false)
	
	VotesEditor.image[1] = guiCreateStaticImage(192, 16, 384, 96, "mapstop100_logo.png", false, VotesEditor.window[1])
	
	VotesEditor.gridlist[1] = guiCreateGridList(8, 208, 328, 344, false, VotesEditor.window[1])
	guiGridListAddColumn(VotesEditor.gridlist[1], "Name", 0.7)
	guiGridListAddColumn(VotesEditor.gridlist[1], "Author", 0.4)
	guiGridListAddColumn(VotesEditor.gridlist[1], "Gamemode", 0.5)
	guiGridListAddColumn(VotesEditor.gridlist[1], "resname", 0.5)
	
	VotesEditor.gridlist[2] = guiCreateGridList(432, 208, 328, 256, false, VotesEditor.window[1])
	guiGridListAddColumn(VotesEditor.gridlist[2], "Name", 0.7)
	guiGridListAddColumn(VotesEditor.gridlist[2], "Author", 0.4)
	guiGridListAddColumn(VotesEditor.gridlist[2], "Gamemode", 0.5)
	guiGridListAddColumn(VotesEditor.gridlist[2], "resname", 0.5)
	
	VotesEditor.label[1] = guiCreateLabel(8, 184, 328, 16, "Maps to choose from:", false, VotesEditor.window[1])
	guiLabelSetHorizontalAlign(VotesEditor.label[1], "center", false)
	guiLabelSetVerticalAlign(VotesEditor.label[1], "center")
	
	VotesEditor.label[2] = guiCreateLabel(432, 184, 328, 16, "Maps you vote for:", false, VotesEditor.window[1])
	guiLabelSetHorizontalAlign(VotesEditor.label[2], "center", false)
	guiLabelSetVerticalAlign(VotesEditor.label[2], "center")
	
	VotesEditor.label[3] = guiCreateLabel(8, 112, 752, 48, welcomeText, false, VotesEditor.window[1])
	guiLabelSetHorizontalAlign(VotesEditor.label[3], "center", false)
	guiLabelSetVerticalAlign(VotesEditor.label[3], "center")
	
	VotesEditor.button[2] = guiCreateButton(352, 272, 64, 24, "Add", false, VotesEditor.window[1])
	addEventHandler("onClientGUIClick",VotesEditor.button[2],votes100_voteMap,false)
	
	VotesEditor.button[3] = guiCreateButton(352, 304, 64, 24, "Remove", false, VotesEditor.window[1])
	addEventHandler("onClientGUIClick",VotesEditor.button[3],votes100_removeMap,false)
	
	VotesEditor.button[4] = guiCreateButton(532, 480, 128, 24, "Cast vote!", false, VotesEditor.window[1])
	addEventHandler("onClientGUIClick",VotesEditor.button[4],votes100_castVote,false)
	
	VotesEditor.edit[1] = guiCreateEdit(24, 568, 192, 24, "", false, VotesEditor.window[1])
	VotesEditor.button[5] = guiCreateButton(224, 568, 96, 24, "Clear search", false, VotesEditor.window[1])
	addEventHandler("onClientGUIClick",VotesEditor.button[5],votes100_clearSearch,false)
	
	guiSetVisible(VotesEditor.window[1],false)
end
addEventHandler("onClientResourceStart",resourceRoot,votes100_buildGUI)

function votes100_openCloseGUI()
	if guiGetVisible(VotesEditor.window[1]) then
		guiSetVisible(VotesEditor.window[1],false)
		showCursor(false)
		guiSetInputMode("allow_binds")
	else
		guiSetVisible(VotesEditor.window[1],true)
		showCursor(true)
		guiSetInputMode("no_binds_when_editing")
	end
end
addCommandHandler("votes100",votes100_openCloseGUI)

addEvent("votes100_receiveMap100",true)
function votes100_receiveMapList(votesList, castList)
    VotesList = votesList
	CastList = castList
    votes100_rebuildGridLists()
end
addEventHandler("votes100_receiveMap100",root,votes100_receiveMapList)

function votes100_rebuildGridLists()
	guiGridListClear(VotesEditor.gridlist[1])
	guiGridListSetSortingEnabled(VotesEditor.gridlist[1], false)
	
	for _,map in ipairs(VotesList) do
		local author = map.author or "N/A"
		local name = map.name
		local resname = map.resname
		local gamemode = map.gamemode
	
		local row = guiGridListAddRow(VotesEditor.gridlist[1])
	
		guiGridListSetItemText(VotesEditor.gridlist[1],row,1,tostring(name),false,false)
		guiGridListSetItemText(VotesEditor.gridlist[1],row,2,tostring(author),false,false)
		guiGridListSetItemText(VotesEditor.gridlist[1],row,3,tostring(gamemode),false,false)
		guiGridListSetItemText(VotesEditor.gridlist[1],row,4,tostring(resname),false,false)
	end
	
	guiGridListClear(VotesEditor.gridlist[2])
	guiGridListSetSortingEnabled(VotesEditor.gridlist[2], false)
	
	for _,map in ipairs(CastList) do
		local author = map.author or "N/A"
		local name = map.name
		local resname = map.resname
		local gamemode = map.gamemode
	
		local row = guiGridListAddRow(VotesEditor.gridlist[2])
	
		guiGridListSetItemText(VotesEditor.gridlist[2],row,1,tostring(name),false,false)
		guiGridListSetItemText(VotesEditor.gridlist[2],row,2,tostring(author),false,false)
		guiGridListSetItemText(VotesEditor.gridlist[2],row,3,tostring(gamemode),false,false)
		guiGridListSetItemText(VotesEditor.gridlist[2],row,4,tostring(resname),false,false)
	end
end

function votes100_voteMap(button, state)
	if state == "up" and button == "left" then
		if source == VotesEditor.button[2] then
			local resname = guiGridListGetItemText(VotesEditor.gridlist[1], guiGridListGetSelectedItem(VotesEditor.gridlist[1]), 4)
			if resname then
				triggerServerEvent("votes100_voteMap", resourceRoot, localPlayer, resname)
			else
				return false
			end
		end
	end
end

function votes100_removeMap(button, state)
	if state == "up" and button == "left" then
		if source == VotesEditor.button[3] then
			local resname = guiGridListGetItemText(VotesEditor.gridlist[2], guiGridListGetSelectedItem(VotesEditor.gridlist[2]), 4)
			if resname then
				triggerServerEvent("votes100_removeMap", resourceRoot, localPlayer, resname)
			else
				return false
			end
		end
	end
end

function votes100_castVote(button, state)
	if state == "up" and button == "left" then
		if source == VotesEditor.button[4] then
		end
	end
end

function votes100_clearSearch(button, state)
	if state == "up" and button == "left" then
		if source == VotesEditor.button[5] then
            guiSetText(VotesEditor.edit[1],"")
		end
	end
end

function votes100_handleSearches()
    if source == VotesEditor.edit[1] then
        if not VotesList or #VotesList == 0 then return end
        local searchQuery = guiGetText(VotesEditor.edit[1])
        if #searchQuery == 0 then
            votes100_rebuildGridLists()
        else
            local resultsTable = votes100_searchTable(searchQuery,VotesList)
            votes100_populateSearchResults(resultsTable,VotesEditor.gridlist[1])
        end
    end
end
addEventHandler("onClientGUIChanged",root,votes100_handleSearches)

function votes100_searchTable(searchQuery,t)
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

function votes100_populateSearchResults(resultsTable,gridlist)
    if gridlist == VotesEditor.gridlist[1] then -- maplist
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
end