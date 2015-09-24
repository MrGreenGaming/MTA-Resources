addEvent('onNextmapSettingChange', true)
addEventHandler('onNextmapSettingChange', root,
function(nmap)
	local mapName = getResourceInfo(nmap, "name") or getResourceName(nmap)
	local rating = getMapRating(getResourceName(nmap))
	local likes = rating.likes or '0'
	local dislikes = rating.hates or '0'
	local stringSet = 'Next map: \''.. mapName.. '\' Likes '.. likes.. ' / Dislikes '.. dislikes
	nextmap = stringSet
	map = exports.mapmanager:getRunningGamemodeMap()
	if map then
		local mapName = getResourceInfo(map, "name") or getResourceName(map)
		local rating = getMapRating(getResourceName(map))
		local likes = rating.likes or '0'
		local dislikes = rating.hates or '0'
		stringSet = 'Current map: \''.. mapName.. '\' Likes '.. likes.. ' / Dislikes '.. dislikes .. '\n' .. stringSet
	end
	setElementData(resourceRoot, 'gamemode.nextmap', stringSet)	
end
)



local mapName

addEvent('onMapStarting')
addEventHandler('onMapStarting', root,
	function(mapInfo)
        mapName = mapInfo.resname
		mapName = mapName:gsub("'", "\'")
		rating = getMapRating(mapName)
		triggerEvent("onSendMapRating", root, rating or "unrated")
		if rating then 
			maplikes = rating.likes 
			maphates = rating.hates
			-- outputChatBox("-Map- Likes: "..maplikes.." / Dislikes: "..maphates,root, 255, 0 , 0)
			if getResourceFromName('irc') and getResourceState(getResourceFromName('irc')) == "running" and exports.irc  then
				exports.irc:outputIRC("11* Likes: "..tostring(maplikes).." / Dislikes: "..tostring(maphates))
			end
		end
	end
)
--addEvent('onRaceStateChanging', true)


function safeString(s)
    s = string.gsub(s, '&', '&amp;')
    s = string.gsub(s, '"', '&quot;')
    s = string.gsub(s, '<', '&lt;')
    s = string.gsub(s, '>', '&gt;')
    return s:gsub( "(['])", "''" )
end

addEvent('requestMapInfo', true)
addEventHandler('requestMapInfo', root,
function(pMap)
	local map
	local res
	if pMap == nil then
		map = getMapName()
		res = exports.mapmanager:getRunningGamemodeMap()
	else 
		map, res = searchMap(pMap)
		if map == false then 
			map = getMapName() 
			res = exports.mapmanager:getRunningGamemodeMap()
		end
	end
	if not map or not res then return end
	res = getResourceName(res)
	local rating = getMapRating(res)
	local likes = rating.likes
	local dislikes = rating.hates
	local mapSQL = executeSQLQuery("SELECT infoName, playedCount, resName, lastTimePlayedText FROM race_mapmanager_maps WHERE lower(resName) = '"..safeString(string.lower(res)).."'")
	if #mapSQL < 1 then triggerClientEvent(source, "onMapGather", root, map,likes,dislikes,0, '-not set-', '-not set-', 'First time. Testing purposes. No Greencoins.', '-not set-') return end
	local timesPlayed = mapSQL[1].playedCount
	local mapRes = mapSQL[1].resName
	local lastTimePlayed = mapSQL[1].lastTimePlayedText
	local author = getResourceInfo(getResourceFromName(mapRes), "author")
	if not author then author = "-not set-" end
	local description = getResourceInfo(getResourceFromName(mapRes), "description")
	if not description then description = "-not set-" end
	local player = getPlayerName(source)
	player = string.gsub (player, '#%x%x%x%x%x%x', '' )
	map = string.gsub(map,"?","'") -- FIX FOR MAPS WITH ? IN NAME
	local mapTable = (tableprefix[exports.race:getRaceMode()] or ("race maptimes " .. exports.race:getRaceMode())) .. ' ' .. map
	local sql = executeSQLQuery("SELECT playerName, timeText FROM ? WHERE playerName=?", mapTable,player) 
	local playerTime
	if #sql > 0 and type(sql) == "table" then 
		playerTime = sql[1].timeText 
		if score[exports.race:getRaceMode()] then
			playerTime = playerTime .. ' kills'
		end
	else
		playerTime = "-not set-"
	end
	triggerClientEvent(source, "onMapGather", root, map,likes,dislikes,timesPlayed, author, description, lastTimePlayed, playerTime, nextmap)
end
)

tableprefix = {}
tableprefix['Reach the flag'] = 'race maptimes Freeroam'
tableprefix['Never the same'] = 'race maptimes Sprint'
tableprefix['Manhunt'] = 'manhunt maptimes Freeroam'
tableprefix['Destruction derby'] = 'manhunt maptimes Destruction derby'

reversed = {}
reversed['Manhunt'] = true
reversed['Destruction derby'] = true
reversed['Shooter'] = true

score = {}
score['Destruction derby'] = true
score['Shooter'] = true


function searchMap(map)
	local maps = exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName('race'))
	for i,v in ipairs (maps) do
			theMap = getResourceInfo(v, "name") or getResourceName(v)
			if (string.find(string.gsub ( string.lower(theMap), '#%x%x%x%x%x%x', '' ),string.lower(map))) then
				return theMap, v
			end
	end
	return false
end


function var_dump(...)
	-- default options
	local verbose = false
	local firstLevel = true
	local outputDirectly = true
	local noNames = false
	local indentation = "\t\t\t\t\t\t"
	local depth = nil
 
	local name = nil
	local output = {}
	for k,v in ipairs(arg) do
		-- check for modifiers
		if type(v) == "string" and k < #arg and v:sub(1,1) == "-" then
			local modifiers = v:sub(2)
			if modifiers:find("v") ~= nil then
				verbose = true
			end
			if modifiers:find("s") ~= nil then
				outputDirectly = false
			end
			if modifiers:find("n") ~= nil then
				verbose = false
			end
			if modifiers:find("u") ~= nil then
				noNames = true
			end
			local s,e = modifiers:find("d%d+")
			if s ~= nil then
				depth = tonumber(string.sub(modifiers,s+1,e))
			end
		-- set name if appropriate
		elseif type(v) == "string" and k < #arg and name == nil and not noNames then
			name = v
		else
			if name ~= nil then
				name = ""..name..": "
			else
				name = ""
			end
 
			local o = ""
			if type(v) == "string" then
				table.insert(output,name..type(v).."("..v:len()..") \""..v.."\"")
			elseif type(v) == "userdata" then
				local elementType = "no valid MTA element"
				if isElement(v) then
					elementType = getElementType(v)
				end
				table.insert(output,name..type(v).."("..elementType..") \""..tostring(v).."\"")
			elseif type(v) == "table" then
				local count = 0
				for key,value in pairs(v) do
					count = count + 1
				end
				table.insert(output,name..type(v).."("..count..") \""..tostring(v).."\"")
				if verbose and count > 0 and (depth == nil or depth > 0) then
					table.insert(output,"\t{")
					for key,value in pairs(v) do
						-- calls itself, so be careful when you change anything
						local newModifiers = "-s"
						if depth == nil then
							newModifiers = "-sv"
						elseif  depth > 1 then
							local newDepth = depth - 1
							newModifiers = "-svd"..newDepth
						end
						local keyString, keyTable = var_dump(newModifiers,key)
						local valueString, valueTable = var_dump(newModifiers,value)
 
						if #keyTable == 1 and #valueTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>\t"..valueString)
						elseif #keyTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>")
							for k,v in ipairs(valueTable) do
								table.insert(output,indentation..v)
							end
						elseif #valueTable == 1 then
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							table.insert(output,indentation.."\t=>\t"..valueString)
						else
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							for k,v in ipairs(valueTable) do
								if k == 1 then
									table.insert(output,indentation.." => "..v)
								else
									table.insert(output,indentation..v)
								end
							end
						end
					end
					table.insert(output,"\t}")
				end
			else
				table.insert(output,name..type(v).." \""..tostring(v).."\"")
			end
			name = nil
		end
	end
	local string = ""
	for k,v in ipairs(output) do
		if outputDirectly then
			outputConsole(v)
		end
		string = string..v
	end
	return string, output
end