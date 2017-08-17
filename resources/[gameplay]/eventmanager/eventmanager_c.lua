current = false
event = ""
mapList = {}
eventList = {}
gridPositions = {} -- {[i] = {hor,ver,sel}}

function clientStart()
end
addEventHandler("onClientResourceStart",resourceRoot,clientStart)

---------
-- GUI --
---------

function updateQueueInfo()
	fetchCurrentEvent()
	fetchQueue()
	fetchOverview()
	if guiGetVisible(GUI.window[2]) then
		fetchMaps()
		fetchEvent()
	end
end
addEvent("onMapStarting")
addEventHandler("onMapStarting", resourceRoot, updateQueueInfo)

function updateCurrentEvent(str)
	guiSetText(GUI.label[2], str)
end

function updateQueue(t)
	guiGridListClear(GUI.gridlist[1])

	for a,b in ipairs(t) do
		local row = guiGridListAddRow(GUI.gridlist[1])
		guiGridListSetItemText(GUI.gridlist[1],row,1,tostring(a),false,true)
		guiGridListSetItemText(GUI.gridlist[1],row,2,tostring(t[a][1]),false,false)
		guiGridListSetItemText(GUI.gridlist[1],row,3,tostring(t[a][2]),false,false)
	end
end

function updateOverview(t)
	guiGridListClear(GUI.gridlist[4])

	for a,b in ipairs(t) do
		local row = guiGridListAddRow(GUI.gridlist[4])
		guiGridListSetItemText(GUI.gridlist[4],row,1,tostring(t[a][1]),false,false)
		guiGridListSetItemText(GUI.gridlist[4],row,2,tostring(t[a][2]),false,false)
	end
end

function updateMaps(t)
	guiGridListClear(GUI.gridlist[2])
	
	for a,b in ipairs(t) do
		local row = guiGridListAddRow(GUI.gridlist[2])
		guiGridListSetItemText(GUI.gridlist[2],row,1,tostring(t[a][1]),false,true)
		guiGridListSetItemText(GUI.gridlist[2],row,2,tostring(t[a][2]),false,false)
		guiGridListSetItemText(GUI.gridlist[2],row,3,tostring(t[a][3]),false,false)
	end
end

function updateEvent(t)
	guiGridListClear(GUI.gridlist[3])
	for a,b in ipairs(t) do
		local row = guiGridListAddRow(GUI.gridlist[3])
		guiGridListSetItemText(GUI.gridlist[3],row,1,tostring(a),false,true)
		guiGridListSetItemText(GUI.gridlist[3],row,2,tostring(t[a][1]),false,false)
		guiGridListSetItemText(GUI.gridlist[3],row,3,tostring(t[a][2]),false,false)
		guiGridListSetItemText(GUI.gridlist[3],row,4,tostring(t[a][3]),false,false)
	end
end

function createEvent()
	local name = guiGetText(GUI.edit[2])
	if name == "" then return end
	if name then triggerServerEvent("eventmanager_createEvent_s", resourceRoot, localPlayer, name) end
	updateQueueInfo()
end

function startEvent(button, state)
	if state == "up" and button == "left" then
		if guiGridListGetSelectedItem(GUI.gridlist[4]) == -1 then return end
		local sEvent = guiGridListGetItemText(GUI.gridlist[4], guiGridListGetSelectedItem(GUI.gridlist[4]), 1)
		triggerServerEvent("eventmanager_startEvent_s", resourceRoot, localPlayer, sEvent)
		updateQueueInfo()
	end
end

function deleteEvent(button, state)
	if state == "up" and button == "left" then
		if guiGridListGetSelectedItem(GUI.gridlist[4]) == -1 then return end
		local dEvent = guiGridListGetItemText(GUI.gridlist[4], guiGridListGetSelectedItem(GUI.gridlist[4]), 1)
		triggerServerEvent("eventmanager_deleteEvent_s", resourceRoot, localPlayer, dEvent)
		updateQueueInfo()
	end
end

function eventButtons()
	if source == GUI.gridlist[2] then
		guiSetEnabled(GUI.button[5], true)
		guiSetEnabled(GUI.button[6], false)
		guiSetEnabled(GUI.button[7], false)
		guiSetEnabled(GUI.button[8], false)
		guiSetEnabled(GUI.button[9], false)
		guiSetEnabled(GUI.edit[1], false)
		guiGridListSetSelectedItem(GUI.gridlist[3], 0, 0)
	elseif source == GUI.gridlist[3] then
		guiSetEnabled(GUI.button[5], false)
		guiSetEnabled(GUI.button[6], true)
		guiSetEnabled(GUI.button[7], true)
		guiSetEnabled(GUI.button[8], true)
		guiSetEnabled(GUI.button[9], true)
		guiSetEnabled(GUI.edit[1], true)
		guiGridListSetSelectedItem(GUI.gridlist[2], 0, 0)
	end
end

function eventAdd(button, state)
	if state == "up" and button == "left" then
		local resname = guiGridListGetItemText(GUI.gridlist[2], guiGridListGetSelectedItem(GUI.gridlist[2]), 3)
		if resname then
			triggerServerEvent("eventmanager_eventAdd_s", resourceRoot, localPlayer, resname, current, event)
		end
		updateQueueInfo()
	end
end

function eventRemove(button, state)
	if state == "up" and button == "left" then
		local row = guiGridListGetSelectedItem(GUI.gridlist[3]) + 1
		if row then
			triggerServerEvent("eventmanager_eventRemove_s", resourceRoot, localPlayer, row, current, event)
		end
		updateQueueInfo()
	end
end

function eventMove(button, state)
	if state == "up" and button == "left" then
		local row = guiGridListGetSelectedItem(GUI.gridlist[3]) + 1
		local resname = guiGridListGetItemText(GUI.gridlist[3], guiGridListGetSelectedItem(GUI.gridlist[3]), 4)
		local n = tonumber(guiGetText(GUI.edit[1]))
		local cat = "N/A"
		if source == GUI.button[7] then cat = "up"
		elseif source == GUI.button[8] then cat = "to"
		elseif source == GUI.button[9] then cat = "down" end
		triggerServerEvent("eventmanager_eventMove_s", resourceRoot, localPlayer, current, event, row, resname, n, cat)
		updateQueueInfo()
	end
end

function eventListPositionsGet()
	for a,b in ipairs(GUI.gridlist) do
		gridPositions[a] = {}
		gridPositions[a][1] = guiGridListGetHorizontalScrollPosition(GUI.gridlist[a])
		gridPositions[a][2] = guiGridListGetVerticalScrollPosition(GUI.gridlist[a])
		gridPositions[a][3],gridPositions[a][4] = guiGridListGetSelectedItem(GUI.gridlist[a])
	end
end

function eventListPositionsSet()
	for a,b in ipairs(GUI.gridlist) do
		if gridPositions[a][1] then guiGridListSetHorizontalScrollPosition(GUI.gridlist[a], gridPositions[a][1]) end
		if gridPositions[a][2] then guiGridListSetVerticalScrollPosition(GUI.gridlist[a], gridPositions[a][2]) end
		if gridPositions[a][3] then guiGridListSetSelectedItem(GUI.gridlist[a], gridPositions[a][3], gridPositions[a][4]) end
	end
end

function handleSearches()
	if not mapList then return end
	local searchQuery = guiGetText(GUI.edit[3])
	if #searchQuery == 0 then
		rebuildGridLists()
	else
		local t1 = searchTable(searchQuery,mapList)
		updateMaps(t1)
	end
end

function rebuildGridLists()
	updateMaps(mapList)
end

function searchTable(searchQuery,t)
    searchQuery = string.lower(tostring(searchQuery))
    if #searchQuery == 0 then return t end
	
    local results = {}
    for a,b in ipairs(t) do
        local match = false
        local name = string.find(string.lower( tostring(t[a][1]) ),searchQuery)
        local author = string.find(string.lower( tostring(t[a][2]) ),searchQuery)
        local resname = string.find(string.lower( tostring(t[a][3]) ),searchQuery)

        if type(name) == "number" or type(author) == "number" or type(resname) == "number" then
            match = true
        end
        if match then table.insert(results,b) end
    end
    return results
end

--------------
-- Requests --
--------------

function fetchCurrentEvent()
	triggerServerEvent("eventmanager_fetchCurrentEvent_s", resourceRoot, localPlayer) 
end

function fetchQueue()
	triggerServerEvent("eventmanager_fetchQueue_s", resourceRoot, localPlayer) 
end

function fetchOverview()
	triggerServerEvent("eventmanager_fetchOverview_s", resourceRoot, localPlayer) 
end

function fetchMaps()
	triggerServerEvent("eventmanager_fetchMaps_s", resourceRoot, localPlayer) 
end

function fetchEvent()
	triggerServerEvent("eventmanager_fetchEvent_s", resourceRoot, localPlayer, current, event) 
end

--------------
-- Receives --
--------------

function windowVisibility(button, state)
	if state == "up" and button == "left" then
		if source == GUI.button[1] or source == resourceRoot then
			if guiGetVisible(GUI.window[1]) then
				if guiGetVisible(GUI.window[2]) then guiSetVisible(GUI.window[2],false) end
				guiSetVisible(GUI.window[1],false)
				showCursor(false)
				guiSetInputMode("allow_binds")
			else
				guiSetVisible(GUI.window[1],true)
				guiBringToFront(GUI.window[1])
				showCursor(true)
				guiSetInputMode("no_binds_when_editing")
			end
		elseif source == GUI.button[3] then
			if guiGetVisible(GUI.window[2]) == false then guiSetVisible(GUI.window[2],true) end
			guiBringToFront(GUI.window[2])
			guiSetEnabled(GUI.button[5], false)
			guiSetEnabled(GUI.button[6], false)
			guiSetEnabled(GUI.button[7], false)
			guiSetEnabled(GUI.button[8], false)
			guiSetEnabled(GUI.button[9], false)
			guiSetEnabled(GUI.edit[1], false)
			guiGridListSetSelectedItem(GUI.gridlist[2], 0, 0)
			guiGridListSetSelectedItem(GUI.gridlist[3], 0, 0)
			current = true
			guiSetText(GUI.label[5], "Current event maps:")
		elseif source == GUI.button[4] then
			if guiGetVisible(GUI.window[2]) then guiSetVisible(GUI.window[2],false) end
		elseif source == GUI.button[11] then
			if guiGridListGetSelectedItem(GUI.gridlist[4]) == -1 then return end
			if guiGetVisible(GUI.window[2]) == false then guiSetVisible(GUI.window[2],true) end
			guiBringToFront(GUI.window[2])
			guiSetEnabled(GUI.button[5], false)
			guiSetEnabled(GUI.button[6], false)
			guiSetEnabled(GUI.button[7], false)
			guiSetEnabled(GUI.button[8], false)
			guiSetEnabled(GUI.button[9], false)
			guiSetEnabled(GUI.edit[1], false)
			guiGridListSetSelectedItem(GUI.gridlist[2], 0, 0)
			guiGridListSetSelectedItem(GUI.gridlist[3], 0, 0)
			current = false
			event = guiGridListGetItemText(GUI.gridlist[4], guiGridListGetSelectedItem(GUI.gridlist[4]), 1)
			guiSetText(GUI.label[5], event)
		end
		updateQueueInfo()
	end
end
addEvent("eventmanager_windowVisibility",true)
addEventHandler("eventmanager_windowVisibility",root,windowVisibility)

function receiveCurrentEvent(str)
	updateCurrentEvent(str)
end
addEvent("eventmanager_fetchCurrentEvent_c",true)
addEventHandler("eventmanager_fetchCurrentEvent_c",root,receiveCurrentEvent)

function receiveQueue(t)
	updateQueue(t)
end
addEvent("eventmanager_fetchQueue_c",true)
addEventHandler("eventmanager_fetchQueue_c",root,receiveQueue)

function receiveOverview(t)
	updateOverview(t)
end
addEvent("eventmanager_fetchOverview_c",true)
addEventHandler("eventmanager_fetchOverview_c",root,receiveOverview)

function receiveMaps(t)
	mapList = t
	updateMaps(t)
	handleSearches()
end
addEvent("eventmanager_fetchMaps_c",true)
addEventHandler("eventmanager_fetchMaps_c",root,receiveMaps)

function receiveEvent(t)
	eventList = t
	updateEvent(t)
	handleSearches()
end
addEvent("eventmanager_fetchEvent_c",true)
addEventHandler("eventmanager_fetchEvent_c",root,receiveEvent)