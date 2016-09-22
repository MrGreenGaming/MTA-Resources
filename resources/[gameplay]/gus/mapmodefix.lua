-- Rewrite meta.xml of maps to follow the new gamemode="race" racemode="xxx" syntax

local gamemodes = {}
gamemodes['nts'] = true
gamemodes['manhunt'] = true
gamemodes['ctf'] = true
gamemodes['rtf'] = true
gamemodes['shooter'] = true

function checkNoGamemodeMaps()
	local incompatibleMaps = getMapsCompatibleWithNoGamemode()
	
	if incompatibleMaps and #incompatibleMaps > 0 then
		if debugMode then
			outputDebugString('need to convert ' .. #incompatibleMaps .. ' map(s)')
		end
		for i, map in ipairs(incompatibleMaps) do
			if map.gm then
				setResourceInfo(map.resource , 'gamemodes', 'race')
				setResourceInfo(map.resource , 'racemode', map.gm)
			elseif map.rm then
				setResourceInfo(map.resource , 'racemode', map.rm)
			end
		end
	end

	local incompatibleMaps = getMapsCompatibleOldFormat()
	
	if not(incompatibleMaps and #incompatibleMaps > 0) then
		return
	end
	
	if debugMode then
		outputDebugString('need to convert ' .. #incompatibleMaps .. ' map(s) to new format 2')
	end
	for i, map in ipairs(incompatibleMaps) do
		updateMapToNewFormat(map.resource)
	end
	
end
setTimer(function() setTimer(checkNoGamemodeMaps, 2000, 0) end, 20000,1)
addCommandHandler('checkNoGamemodeMaps', checkNoGamemodeMaps)

function getMapsCompatibleWithNoGamemode()
	local incompatibleMaps = {}
	for i,theResource in ipairs(getResources()) do
		local gm = getResourceInfo(theResource, "gamemodes")
		if gm and gamemodes[gm:lower()] then
			table.insert(incompatibleMaps, {resource = theResource, gm = gm:lower()})
		end
		local rm = get(getResourceName(theResource) .. '.racemode')
		if not getResourceInfo(theResource, "racemode") and rm and gamemodes[rm:lower()] then
			table.insert(incompatibleMaps, {resource = theResource, rm = rm:lower()})
		end
	end

	return incompatibleMaps
end

function getMapsCompatibleOldFormat()
	local incompatibleMaps = {}
	for i,theResource in ipairs(getResources()) do
		local racemode = getResourceInfo(theResource, "racemode")
		local version = getResourceInfo(theResource, "mrgreen")
		if racemode and version ~= "2" then
			table.insert(incompatibleMaps, {resource = theResource})
		end
	end

	return incompatibleMaps
end

function updateMapToNewFormat ( resource )
	-- outputDebugString'updateMapToNewFormat'
	
	local name = getResourceName(resource)
	local maproot = getResourceRootElement(resource)
	local mode = getResourceInfo(resource, "racemode")
	local version = getResourceInfo(resource, "mrgreen")
	if not mode or version == "2" then return end
	outputDebugString(getResourceName(resource))
	
	-- read out all .map files from meta.xml
	local meta = xmlLoadFile(':' .. name .. '/meta.xml')
	local mapfiles={}
	for _, node in ipairs(xmlNodeGetChildren(meta)) do
		if xmlNodeGetName(node) == 'map' then
			table.insert(mapfiles, xmlNodeGetAttribute(node,'src'))
		end
	end
	xmlUnloadFile(meta)
	
	if mode == "shooter" then
		setResourceInfo(resource, "mrgreen", '2')
	elseif mode == "rtf" then
		for _, file in ipairs(mapfiles) do
			-- outputDebugString(file)
			local map = xmlLoadFile(':' .. name .. '/' .. file)
			local edit = false
			-- outputDebugString('updating rtf')
			for _, node in ipairs(xmlNodeGetChildren(map)) do
				if xmlNodeGetName(node) == 'object' and xmlNodeGetAttribute(node, 'model') == '2914' then
					-- outputDebugString'2914'
					xmlNodeSetName(node, 'rtf')
					edit = true
				end
			end
			if edit then xmlSaveFile(map) end
			xmlUnloadFile(map)
		end
		setResourceInfo(resource, "mrgreen", '2')
	elseif mode == "ctf" then
		for _, file in ipairs(mapfiles) do
			-- outputDebugString(file)
			local map = xmlLoadFile(':' .. name .. '/' .. file)
			local edit = false
			local spawn = 1
			-- outputDebugString('updating ctf')
			for _, node in ipairs(xmlNodeGetChildren(map)) do
				if xmlNodeGetName(node) == 'object' and xmlNodeGetAttribute(node, 'model') == '2914' then
					-- outputDebugString'2914'
					xmlNodeSetName(node, 'ctfred')
					edit = true
				elseif xmlNodeGetName(node) == 'object' and xmlNodeGetAttribute(node, 'model') == '2048' then
					-- outputDebugString'2048'
					xmlNodeSetName(node, 'ctfblue')
					edit = true
				elseif xmlNodeGetName(node) == 'spawnpoint' and xmlNodeGetAttribute(node, 'team') ~= 'red'  and xmlNodeGetAttribute(node, 'team') ~= 'blue' then
					-- outputDebugString( spawn .. ' ' .. (spawn%2 == 1 and 'red' or 'blue') )
					xmlNodeSetAttribute(node, 'team', (spawn%2 == 1 and 'red' or 'blue'))
					edit = true
					spawn = spawn + 1
				end
			end
			if edit then xmlSaveFile(map) end
			xmlUnloadFile(map)
		end
		setResourceInfo(resource, "mrgreen", '2')
	elseif mode == "nts" then
		for _, file in ipairs(mapfiles) do
			-- outputDebugString(file)
			local map = xmlLoadFile(':' .. name .. '/' .. file)
			local edit = false
			-- outputDebugString('updating nts')
			for _, node in ipairs(xmlNodeGetChildren(map)) do
				if xmlNodeGetName(node) == 'checkpoint' and not xmlNodeGetAttribute(node, 'nts') then
					local r, g, b = getColorFromString(xmlNodeGetAttribute(node, 'color'))
					if b == 255 then
						-- outputDebugString'vehicle'
						xmlNodeSetAttribute(node, 'nts', 'vehicle')
						edit = true
					elseif g == 255 then
						-- outputDebugString'boat'
						xmlNodeSetAttribute(node, 'nts', 'boat')
						edit = true
					elseif r == 255 then
						-- outputDebugString'boat'
						xmlNodeSetAttribute(node, 'nts', 'air')
						edit = true
					end
				end
			end
			if edit then xmlSaveFile(map) end
			xmlUnloadFile(map)
		end
		setResourceInfo(resource, "mrgreen", '2')
	end
end
