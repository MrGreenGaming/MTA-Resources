local currentMap = nil

function resourceStart()
	local xml
	xml = xmlLoadFile("data_maps.xml")
	if not xml then
		outputDebugString("XML file not found, creating a new one.",0)
		xml = xmlCreateFile("data_maps.xml", "maps")
		
		local raceMaps = exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName("race"))
		if not raceMaps then return false end
		
		local t = {}
		for a,b in ipairs(raceMaps) do
			local name = getResourceInfo(b,"name")
			local author = getResourceInfo(b,"author")
			local resname = getResourceName(b)
	
			if not name then name = resname end
			if not author then author = "N/A" end
			
			local r = {resname, name, author}
			table.insert(t,r)
		end
		table.sort(t,function(a,b) return tostring(a[1]) < tostring(b[1]) end)
		
		for a,b in ipairs(t) do
			local child = xmlCreateChild(xml, "map")
			xmlNodeSetAttribute(child, "resname", b[1])
			xmlNodeSetAttribute(child, "name", b[2])
			xmlNodeSetAttribute(child, "author", b[3])
			local ran = xmlCreateChild(child, "random")
			local replay = xmlCreateChild(child, "replay")
			local gcshop = xmlCreateChild(child, "gcshop")
			local event = xmlCreateChild(child, "event")
			xmlNodeSetValue(ran, 0)
			xmlNodeSetValue(replay, 0)
			xmlNodeSetValue(gcshop, 0)
			xmlNodeSetValue(event, 0)
		end
		
		xmlSaveFile(xml)
		t = nil
		raceMaps = nil
	end
	xmlUnloadFile(xml)
end
addEventHandler('onResourceStart', getResourceRootElement(),resourceStart)

function gamemodeMapStart(res)
	if res == currentMap then
		updateStats(res, 0, 1, 0, 0)
	else
		updateStats(res, 1, 0, 0, 0)
		currentMap = res
	end
	--outputDebugString("gamemodeMapStart",0)
end
addEvent('onGamemodeMapStart')
addEventHandler('onGamemodeMapStart', root, gamemodeMapStart)

function gcshopMapStart(res)
	if res == currentMap then
		updateStats(res, 0, -1, 1, 0)
	else
		updateStats(res, -1, 0, 1, 0)
	end
	--outputDebugString("gcshopMapStart",0)
end
addEvent('data_onGCShopMapStart')
addEventHandler('data_onGCShopMapStart', root, gcshopMapStart)

function eventMapStart(res)
	if res == currentMap then
		updateStats(res, 0, -1, 0, 1)
	else
		updateStats(res, -1, 0, 0, 1)
	end
	--outputDebugString("eventMapStart",0)
end
addEvent('data_onEventMapStart')
addEventHandler('data_onEventMapStart', root, eventMapStart)

function updateStats(res, ran, replay, gcshop, event)
	xml = xmlLoadFile("data_maps.xml")
	if not xml then
		outputDebugString("XML file not found or loading failed.",0)
		return
	end
	
	local resname = getResourceName(res)
	local maps = xmlNodeGetChildren(xml)
	local bool = false
	for a,b in ipairs(maps) do
		if xmlNodeGetAttribute(b, "resname") == resname then
			local stats = xmlNodeGetChildren(b)
			for c,d in ipairs(stats) do
				if xmlNodeGetName(d) == "random" then
					old_var = xmlNodeGetValue(d)
					local new_var = tonumber(old_var) + ran
					xmlNodeSetValue(d, new_var)
				end
				if xmlNodeGetName(d) == "replay" then
					old_var = xmlNodeGetValue(d)
					local new_var = tonumber(old_var) + replay
					xmlNodeSetValue(d, new_var)
				end
				if xmlNodeGetName(d) == "gcshop" then
					old_var = xmlNodeGetValue(d)
					local new_var = tonumber(old_var) + gcshop
					xmlNodeSetValue(d, new_var)
				end
				if xmlNodeGetName(d) == "event" then
					old_var = xmlNodeGetValue(d)
					local new_var = tonumber(old_var) + event
					xmlNodeSetValue(d, new_var)
				end
			end
			bool = true
		end
	end
	
	if not bool then
		outputDebugString("Map is being added to statistics XML.",0)
		local child = xmlCreateChild(xml, "map")
		xmlNodeSetAttribute(child, "resname", getResourceName(res))
		xmlNodeSetAttribute(child, "name", getResourceInfo(res,"name"))
		xmlNodeSetAttribute(child, "author", getResourceInfo(res,"author"))
		local c1 = xmlCreateChild(child, "random")
		local c2 = xmlCreateChild(child, "replay")
		local c3 = xmlCreateChild(child, "gcshop")
		local c4 = xmlCreateChild(child, "event")
		xmlNodeSetValue(c1, ran)
		xmlNodeSetValue(c2, replay)
		xmlNodeSetValue(c3, gcshop)
		xmlNodeSetValue(c4, event)
	end
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end

function buttonTrigger(p)
	triggerClientEvent(p,"data_maps_buttonTrigger",resourceRoot,"left","up")
end
addCommandHandler("data_maps", buttonTrigger, true, true)

function fetchData_s(p)
	xml = xmlLoadFile("data_maps.xml")
	if not xml then
		outputDebugString("XML file not found or loading failed.",0)
		return
	end
	
	local t = {}
	local maps = xmlNodeGetChildren(xml)
	for a,b in ipairs(maps) do
		local resname = xmlNodeGetAttribute(b, "resname")
		local mapname = xmlNodeGetAttribute(b, "name")
		local author = xmlNodeGetAttribute(b, "author")
		local stats = xmlNodeGetChildren(b)
		local ran
		local replay
		local gcshop
		local event
		for c,d in ipairs(stats) do
			if xmlNodeGetName(d) == "random" then ran = xmlNodeGetValue(d) end
			if xmlNodeGetName(d) == "replay" then replay = xmlNodeGetValue(d) end
			if xmlNodeGetName(d) == "gcshop" then gcshop = xmlNodeGetValue(d) end
			if xmlNodeGetName(d) == "event" then event = xmlNodeGetValue(d) end
		end
		t[a] = {resname, mapname, author, ran, replay, gcshop, event}
	end
	
	xmlUnloadFile(xml)
	
	triggerClientEvent(p,"data_maps_fetchData_c",resourceRoot,t)
end
addEvent("data_maps_fetchData_s",true)
addEventHandler("data_maps_fetchData_s",root,fetchData_s)