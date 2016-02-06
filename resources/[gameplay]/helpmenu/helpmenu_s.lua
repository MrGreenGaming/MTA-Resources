---------------
-- Send Motd --
-- & log to  --
-- client    --
---------------

motdText, svnlog = '', ''
motdVersion = 0
function start()
	local motdNode = fileExists'motd.xml' and xmlLoadFile 'motd.xml' or xmlCreateFile('motd.xml', 'motd')
	motdVersion = tonumber(xmlNodeGetAttribute(motdNode, 'version'))
	motdText = xmlNodeGetValue(motdNode) or ''
	xmlUnloadFile(motdNode)
	
	local svnNode = xmlLoadFile'svn.xml'
	svnlog = xmlNodeGetValue(svnNode) or ''
	xmlUnloadFile(svnNode)
end
addEventHandler('onResourceStart', resourceRoot, start)

function onClientRequestMotdAndLog()
	triggerClientEvent ( client, 'receiveMotdAndLog', resourceRoot, motdText, svnlog, motdVersion )
end
addEvent('requestMOTD&log', true)
addEventHandler('requestMOTD&log', resourceRoot, onClientRequestMotdAndLog)



-------------
-- SVN log --
-------------

local logUrl = "http://api.mrgreengaming.com:8080/svn/mrg-race/log"

function fetchSVNLog()
	fetchRemote ( logUrl, receivedSVNlog )
end

function receivedSVNlog(data, errno)
	if errno ~= 0 then return outputDebugString('receivedSVNlog error: ' .. tostring(errno)) end
	local text = "Server changelog from http://dev.limetric.com/svn/mta.php\r\n"
	text = text .. "Last 10 changes at " .. makeCurrentDatetime() .. '\r\n'
	text = text .. "_________________________________________________________\r\n\r\n"
	data = {fromJSON(data)}
	-- var_dump('-v', data)
	for k,rev in ipairs(data) do
		local l = rev.message .. '\r\n * ' .. rev.author .. ' (' .. rev.revision .. ') on ' .. rev.date
		text = text .. l .. '\r\n\r\n'
	end
	local svnNode = fileExists'svn.xml' and xmlLoadFile'svn.xml' or xmlCreateFile('svn.xml', 'log')
	xmlNodeSetValue(svnNode, text)
	xmlSaveFile(svnNode)
	xmlUnloadFile(svnNode)
	svnlog = text
end
fetchSVNLog()
setTimer(fetchSVNLog, 10*60*1000, 0)



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