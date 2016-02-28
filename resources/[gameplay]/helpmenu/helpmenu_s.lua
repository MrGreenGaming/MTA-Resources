-----------------
-- Send Motd ----
-- & changelog --
-- to client ----
-----------------
motdText, changelog = '', "Changelog currently isn't available for a some reason. Try to reconnect or check this tab a bit later"
motdVersion = 0
	
function start()
	local motdNode = fileExists'motd.xml' and xmlLoadFile 'motd.xml' or xmlCreateFile('motd.xml', 'motd')
	motdVersion = tonumber(xmlNodeGetAttribute(motdNode, 'version'))
	motdText = xmlNodeGetValue(motdNode) or ''
	xmlUnloadFile(motdNode)
	
	startChangelogDownload()
	setTimer(startChangelogDownload, 10*60*1000, 0)
end
addEventHandler('onResourceStart', resourceRoot, start)


addEvent('requestMOTD', true)
addEventHandler('requestMOTD', resourceRoot, 
function()
	triggerClientEvent ( client, 'receiveMotd', resourceRoot, motdText, motdVersion )
end
)

addEvent('requestChangelog', true)
addEventHandler('requestChangelog', resourceRoot, 
function()
	triggerClientEvent ( client, 'receiveChangelog', resourceRoot, changelog )
end
)


------------------------
-- Get changelog text --
------------------------
function startChangelogDownload()
	local logUrl = "https://github.com/JarnoVgr/Mr.Green-MTA-Resources/commits/master.atom/"
	fetchRemote ( logUrl, receiveChangelog)
end

function receiveChangelog(responseData, errno)
	if errno == 0 then --If no errors
		--Save changelog to xml file
		outputDebugString("Received changelog data", 3)
		local logFile = fileExists"changelog.xml" and fileOpen"changelog.xml" or fileCreate("changelog.xml")
		fileWrite(logFile, responseData)
		fileClose(logFile)
		
		--And convert from the XML file to a formatted string
		local logNode = xmlLoadFile("changelog.xml")
		
		changelog = "Server changelog from https://github.com/JarnoVgr/Mr.Green-MTA-Resources/commits/master\r\n"
		changelog = changelog .. "Last 20 changes at " .. makeCurrentDatetime() .. '\r\n'
		changelog = changelog .. "_________________________________________________________\r\n\r\n"
	
		for i=0, 19 do
			local entryNode = xmlFindChild(logNode, "entry", i)
		
			local titleNode = xmlFindChild( entryNode, "title", 0 )
			local nameNode = xmlFindChild( xmlFindChild(entryNode, "author", 0) , "name", 0 )
			local date_timeNode = xmlFindChild( entryNode, "updated", 0 )
		
			local title = xmlNodeGetValue(titleNode)
			local name = xmlNodeGetValue(nameNode)
			local date_time = xmlNodeGetValue(date_timeNode)
		
			local title = string.gsub(string.gsub(title, "\n", ""), "  ", "")
			local date_time =  string.gsub(string.gsub(date_time, "T", " "), "+", " UTC +")
			
			if string.find(title, "Merge pull request") == nil then
				changelog = changelog .. "* " .. title .. "\nby " .. name .. " on " .. date_time .. "\r\n\r\n"
			end
		end
		
		xmlUnloadFile(logNode)
	elseif errno == 1 then
		outputDebugString("Can't receive changelog from GitHub. Please update server to version 1.5.2", 3)
	else
		outputDebugString("Can't receive changelog from GitHub. Error #"..errno, 1)
	end
end





-----------------
-- Saving motd --
-----------------

-- player needs access to resource feature resource.*.motd
function savemotd (motdText_)
	if not hasObjectPermissionTo(client,"resource." .. getResourceName(resource) .. ".motd",false) then
		return outputChatBox('You don\t have permission to use this', client, 255,0,0)
	end
	
	local motdNode = xmlLoadFile ( 'motd.xml' )
	motdVersion = (tonumber(xmlNodeGetAttribute(motdNode, 'version')) or 0) + 1
	xmlNodeSetValue(motdNode, motdText_)
	xmlNodeSetAttribute(motdNode, 'version', motdVersion)
	xmlNodeSetAttribute(motdNode, 'lastChanged', makeCurrentDatetime())
	xmlSaveFile ( motdNode )
	xmlUnloadFile(motdNode)
	motdText = motdText_
	outputChatBox('MOTD updated! Will show up once for all new visitors', client, 0, 255, 0)
end
addEvent('savemotd', true)
addEventHandler('savemotd', resourceRoot, savemotd)



------------------
-- Help functions
-- from res. motd
------------------

--[[
-- makeCurrentDatetime
--
-- Creates date and time (realtime, not ingame time) in the YYYY-MM-DD HH:MM:SS format.
-- ]]
function makeCurrentDatetime()
	local time = getRealTime()
	local year = time.year + 1900
	local month = fillDigits(time.month + 1)
	local day = fillDigits(time.monthday)
	local hour = fillDigits(time.hour)
	local minute = fillDigits(time.minute)
	local second = fillDigits(time.second)
	return year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second
end

--[[
-- fillDigits
--
-- Adds leading zeros to a string, until it reaches a certain length.
--
-- @param   string   text: The string
-- @param   number   min: How long the string should at least be
-- ]]
function fillDigits(text,min)
	if min == nil then
		min = 2
	end
	local text = tostring(text)
	return string.rep("0",min - text:len())..text
end

-- modifiers: v - verbose (all subtables), n - normal, s - silent (no output), dx - up to depth x, u - unnamed
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