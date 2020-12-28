local eventQueue = {} -- { i = { [1] = mapResName, [2] = eventname, [3] = triggerEvent, args ... } }

--------------------
-- Resource start --
--------------------

function serverStart()
	--for i=1,2 do
	--	table.insert(eventQueue, {"race-neverthesame", "Bierbuikje Event"})
	--end
	
	local xml
	xml = xmlLoadFile("eventManager.xml")
	if not xml then
		xml = xmlCreateFile("eventManager.xml", "events")
		xmlSaveFile(xml)
	end
	xmlUnloadFile(xml)
	
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))
end
addEventHandler('onResourceStart', getResourceRootElement(),serverStart)

--------------
-- Commands --
--------------

function windowVisibility(p)
	triggerClientEvent(p,"eventmanager_windowVisibility",resourceRoot,"left","up")
end
addCommandHandler("event", windowVisibility, true, true)

-----------
-- Calls --
-----------

function isAnyMapQueued()
    if #eventQueue > 0 then
        return true
    end
	return false
end

function getCurrentMapQueued(noRemove)
    if #eventQueue == 0 then
        return false
    end
    if not getResourceFromName(eventQueue[1][1]) then
        outputChatBox("[Event Manager] Error: Queued map may have been deleted.", root, 255, 0, 0)
		table.remove(eventQueue, 1)
        return false
    end
    local choice = eventQueue[1]
    if not noRemove then
        table.remove(eventQueue, 1)
        if #eventQueue > 0 then
            triggerEvent('onNextmapSettingChange', root, getResourceFromName(eventQueue[1][1]))
        end
		if choice[1] then
			triggerEvent(choice[1], root, choice)
		end
    end
    return choice
end

function getCurrentQueue()
	return eventQueue
end

function fetchCurrentEvent(p)
	local str = currentEvent()
	triggerClientEvent(p,"eventmanager_fetchCurrentEvent_c",resourceRoot,str)
end
addEvent("eventmanager_fetchCurrentEvent_s",true)
addEventHandler("eventmanager_fetchCurrentEvent_s",root,fetchCurrentEvent)

function currentEvent()
	local str = "N/A"
	if #eventQueue > 0 then
		str = eventQueue[1][2]
	end
	
	return str
end

function fetchQueue(p)
	t = mapQueue()
	
	triggerClientEvent(p,"eventmanager_fetchQueue_c",resourceRoot,t)
end
addEvent("eventmanager_fetchQueue_s",true)
addEventHandler("eventmanager_fetchQueue_s",root,fetchQueue)

function mapQueue()
	local t = {}
	for a,b in ipairs(eventQueue) do
		local map = eventQueue[a][1]
		if not map then break end
		
		local name = getResourceInfo(getResourceFromName(map), "name")
		local author = getResourceInfo(getResourceFromName(map), "author")
		if not author then author = "N/A" end
		
		t[a] = {name, author, map}
	end
	
	return t
end

function fetchOverview(p)
	local xml = xmlLoadFile("eventManager.xml")
	if not xml then return end
	local events = xmlNodeGetChildren(xml)
	local t = {}
	for a,b in ipairs(events) do
		local name =  xmlNodeGetAttribute(b, "name")
		local amount = #xmlNodeGetChildren(b)
		t[a] = {name, amount}
	end
	xmlUnloadFile(xml)
	triggerClientEvent(p,"eventmanager_fetchOverview_c",resourceRoot,t)
end
addEvent("eventmanager_fetchOverview_s",true)
addEventHandler("eventmanager_fetchOverview_s",root,fetchOverview)

function fetchMaps(p)
	local raceMaps = exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName("race"))
	if not raceMaps then return false end
	
	local t = {}
    for a,b in ipairs(raceMaps) do
        local name = getResourceInfo(b,"name")
        local author = getResourceInfo(b,"author")
        local resname = getResourceName(b)

        if not name then name = resname end
        if not author then author = "N/A" end
		
        local r = {name, author, resname}
		
        table.insert(t,r)
    end

	table.sort(t,function(a,b) return tostring(a[1]) < tostring(b[1]) end)
	
	triggerClientEvent(p,"eventmanager_fetchMaps_c",resourceRoot,t)
end
addEvent("eventmanager_fetchMaps_s",true)
addEventHandler("eventmanager_fetchMaps_s",root,fetchMaps)

function fetchEvent(p, current, event)
	local t = {}
	if current then
		t = mapQueue()
	elseif current == false and event ~= "" then
			local xml = xmlLoadFile("eventManager.xml")
			if not xml then return end
			local events = xmlNodeGetChildren(xml)
			for a,b in ipairs(events) do
				if xmlNodeGetAttribute(b, "name") == event then
					local maps = xmlNodeGetChildren(b)
					for c,d in ipairs(maps) do
						local map = xmlNodeGetValue(d)
						if not map then break end
						
						local name = getResourceInfo(getResourceFromName(map), "name")
						local author = getResourceInfo(getResourceFromName(map), "author")
						if not author then author = "N/A" end
						
						t[c] = {name, author, map}
					end
					break
				end
			end
			xmlUnloadFile(xml)
	end
	triggerClientEvent(p,"eventmanager_fetchEvent_c",resourceRoot,t)
end
addEvent("eventmanager_fetchEvent_s",true)
addEventHandler("eventmanager_fetchEvent_s",root,fetchEvent)

function eventCreate(p, name)
	if hasObjectPermissionTo(p, "command.event", false) then
		if name and name ~= "" then
			local xml = xmlLoadFile("eventManager.xml")
			if not xml then return end
			
			local bool = false
			local events = xmlNodeGetChildren(xml)
			for a,b in ipairs(events) do
				if xmlNodeGetAttribute(b, "name") == name then
					bool = true
					break
				end
			end
			
			if bool then
				outputDebugString("Event already exists for " .. getPlayerName(p), 0)
			else
				local eventChild = xmlCreateChild(xml, "event")
				xmlNodeSetAttribute(eventChild, "name", name)
				outputDebugString("Event " .. name .. " succesfully created for " .. getPlayerName(p), 0)
			end
			
			xmlSaveFile(xml)
			xmlUnloadFile(xml)
		else
		end
	else
		outputDebugString("No permission to create event for " .. getPlayerName(p), 0)
	end
end
addEvent("eventmanager_createEvent_s",true)
addEventHandler("eventmanager_createEvent_s",root,eventCreate)

function startEvent(p, sEvent)
	if hasObjectPermissionTo(p, "command.event", false) then
		if sEvent and name ~= "" then
			local xml = xmlLoadFile("eventManager.xml")
			if not xml then return end
			
			local events = xmlNodeGetChildren(xml)
			for a,b in ipairs(events) do
				if xmlNodeGetAttribute(b, "name") == sEvent then
					local maps = xmlNodeGetChildren(b)
					for c,d in ipairs(maps) do
						local map = xmlNodeGetValue(d)
						if not map then break end
						
						local name = getResourceInfo(getResourceFromName(map), "name")
						local author = getResourceInfo(getResourceFromName(map), "author")
						if not author then author = "N/A" end
						
						eventQueue[#eventQueue + 1 ] = {map, sEvent}
					end
					break
				end
			end
			
			xmlUnloadFile(xml)
		else
		end
	else
		outputDebugString("No permission to start event for " .. getPlayerName(p), 0)
	end
end
addEvent("eventmanager_startEvent_s",true)
addEventHandler("eventmanager_startEvent_s",root,startEvent)

function deleteEvent(p, dEvent)
	if hasObjectPermissionTo(p, "command.event", false) then
		if dEvent and name ~= "" then
			local xml = xmlLoadFile("eventManager.xml")
			if not xml then return end
			
			local events = xmlNodeGetChildren(xml)
			for a,b in ipairs(events) do
				if xmlNodeGetAttribute(b, "name") == dEvent then
					xmlDestroyNode(b)
					break
				end
			end
			
			xmlSaveFile(xml)
			xmlUnloadFile(xml)
		else
		end
	else
		outputDebugString("No permission to delete event for " .. getPlayerName(p), 0)
	end
end
addEvent("eventmanager_deleteEvent_s",true)
addEventHandler("eventmanager_deleteEvent_s",root,deleteEvent)

function eventAdd(p, resname, current, event)
	if hasObjectPermissionTo(p, "command.event", false) then
		if current then
			local str = currentEvent()
			local r = 1
			for a,b in ipairs(eventQueue) do
				if eventQueue[a][2] == str then r = a end
			end
			table.insert(eventQueue,r+1,{resname,str})
		elseif current == false and event ~= "" then
			local xml = xmlLoadFile("eventManager.xml")
			if not xml then return end
			
			local events = xmlNodeGetChildren(xml)
			for a,b in ipairs(events) do
				if xmlNodeGetAttribute(b, "name") == event then
					local newMap = xmlCreateChild(b, "map")
					xmlNodeSetValue(newMap, resname)
					break
				end
			end
			
			xmlSaveFile(xml)
			xmlUnloadFile(xml)
		end
	else
		outputDebugString("No permission to add map for " .. getPlayerName(p), 0)
	end
end
addEvent("eventmanager_eventAdd_s",true)
addEventHandler("eventmanager_eventAdd_s",root,eventAdd)

function eventRemove(p, row, current, event)
	if hasObjectPermissionTo(p, "command.event", false) then
		if current then
			table.remove(eventQueue,row)
		elseif current == false and event ~= "" then
			local xml = xmlLoadFile("eventManager.xml")
			if not xml then return end
			
			local events = xmlNodeGetChildren(xml)
			for a,b in ipairs(events) do
				if xmlNodeGetAttribute(b, "name") == event then
					local map = xmlFindChild(b, "map", row - 1)
					if not map then xmlUnloadFile(xml) return end
					xmlDestroyNode(map)
					break
				end
			end
			
			xmlSaveFile(xml)
			xmlUnloadFile(xml)
		end
	else
		outputDebugString("No permission to remove map for " .. getPlayerName(p), 0)
	end
end
addEvent("eventmanager_eventRemove_s",true)
addEventHandler("eventmanager_eventRemove_s",root,eventRemove)

function eventMove(p, current, event, row, resname, n, cat)
	if hasObjectPermissionTo(p, "command.event", false) then
		if current then
			local str = currentEvent()
			local r = 1
			table.remove(eventQueue,row)
			if cat == "up" then
				r = row-1
			elseif cat == "to" then
				if type(n) == "number" then
					r = n
				else
					r = row
				end
			elseif cat == "down" then
				r = row+1
			end
			if r < 1 or r > #eventQueue then r = row end
			table.insert(eventQueue,r,{resname,str})
		elseif current == false and event ~= "" then
			local t = {}
			local xml = xmlLoadFile("eventManager.xml")
			if not xml then return end
			
			local events = xmlNodeGetChildren(xml)
			for a,b in ipairs(events) do
				if xmlNodeGetAttribute(b, "name") == event then
					local maps = xmlNodeGetChildren(b)
					for c,d in ipairs(maps) do
						local map = xmlNodeGetValue(d)
						if not map then break end
						t[c] = map
					end
					break
				end
			end
			
			for a,b in ipairs(events) do
				if xmlNodeGetAttribute(b, "name") == event then
					local maps = xmlNodeGetChildren(b)
					for c,d in ipairs(maps) do
						xmlDestroyNode(d)
					end
				end
			end
			
			local r = 1
			table.remove(t,row)
			if cat == "up" then
				r = row-1
			elseif cat == "to" then
				if type(n) == "number" then
					r = n
				else
					r = row
				end
			elseif cat == "down" then
				r = row+1
			end
			if r < 1 or r > #t then r = row end
			table.insert(t,r,resname)
			
			for a,b in ipairs(events) do
				if xmlNodeGetAttribute(b, "name") == event then
					for c,d in ipairs(t) do
						local newMap = xmlCreateChild(b, "map")
						xmlNodeSetValue(newMap, t[c])
					end
				end
			end
			
			xmlSaveFile(xml)
			xmlUnloadFile(xml)
		end
	else
		outputDebugString("No permission to move map for " .. getPlayerName(p), 0)
	end
end
addEvent("eventmanager_eventMove_s",true)
addEventHandler("eventmanager_eventMove_s",root,eventMove)

function eventInject(t)
	for a,b in ipairs(t) do
		eventQueue[#eventQueue + 1 ] = b
	end
end
addEvent("eventmanager_eventInject",true)
addEventHandler("eventmanager_eventInject",root,eventInject)
