function specialFormat(t) -- Format some stats like playtime and join date
	-- Format Join Date
	local catIndex = categoryMap['General']
	local statIndex = statsMap['General']['Join Date']
	if catIndex and statIndex and t[catIndex].items[statIndex] then
		t[catIndex].items[statIndex].value = getDateFromTimestamp(t[catIndex].items[statIndex].value)
	end
	-- Format play time
	catIndex = categoryMap['General']
	statIndex = statsMap['General']['Playtime']
	if catIndex and statIndex and t[catIndex].items[statIndex] then
		t[catIndex].items[statIndex].value = tostring(math.floor(t[catIndex].items[statIndex].value/3600))..' Hours'
	end
	-- Ratio
	local ratiosToCalculate = {'Destruction Derby', 'Shooter', 'DeadLine'}
	for i, catName in ipairs(ratiosToCalculate) do
		catIndex = categoryMap[catName] 
		statIndex = statsMap[catName]['K/D Ratio']
		local killIndex = statsMap[catName]['Kills']
		local deathIndex = statsMap[catName]['Deaths']
		if catIndex and statIndex and killIndex and deathIndex then
			local kills = t[catIndex].items[killIndex].value and tonumber(t[catIndex].items[killIndex].value) or false
			local deaths = t[catIndex].items[deathIndex].value and tonumber(t[catIndex].items[deathIndex].value) or false
			if kills and deaths then
				local theRatio = calculateRatio(kills, deaths)
				t[catIndex].items[statIndex].value = theRatio and tostring(theRatio) or 0
			end
		end
	end
	return t
end


function calculateRatio(kill, death)
	local kill = tonumber(kill)
	local death = tonumber(death)
	local ratio = 'Perfect'
	if not kill or not death or (death == 0 and kill == 0) then
		return 0
	elseif death ~= 0 then
		return round(kill/death, 1)
	end
	return ratio
end

function round(num, numDecimalPlaces)
	if numDecimalPlaces and numDecimalPlaces>0 then
		local mult = 10^numDecimalPlaces
		return math.floor(num * mult + 0.5) / mult
	end
	return math.floor(num + 0.5)
end

function table.copy (t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = table.copy(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

function canExport(resName)
    return getResourceState(getResourceFromName( resName )) == 'running'
end

function getVipDays(timestamp)
    if type(timestamp) ~= 'number' then return false end
    local diff = timestamp - getRealTime().timestamp
    if not diff then return 0 end
    return math.ceil(diff/86400)
end

function isPlayerAway(p)
    return isElement(p) and getElementData(source, "player state") == "away" or false
end


function getDateFromTimestamp(timestamp)
    local month = { "Jan.", "Feb.", "Mar.", "Apr.", "May", "Jun.", "Jul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec." }
	if not timestamp or type(timestamp) ~= 'number' then return "unknown" end
	local time = getRealTime(timestamp)
	time.year = time.year + 1900
	time.month = time.month + 1
	local month = month[time.month]
	
	return month.." "..time.monthday..", "..time.year
end

function getPlayerID(p)
    return exports.gc:getPlayerGreencoinsID(p)
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