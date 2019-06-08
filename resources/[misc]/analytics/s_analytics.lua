local isSandBox = false -- Set true for sandbox, dont forget to change keys to sandbox too (TODO, make it an option)
local canSendEvents = false -- If the init POST doesnt fail, set this to true
local API_KEY = isSandBox and '5c6bcb5402204249437fb5a7a80a4959' or get('*analytics_API_KEY')
local API_SECRET = isSandBox and '16813a12f718bc5c620f56944e1abc3ea13ccbac' or get('*analytics_API_SECRET')
local API_ENDPOINT = isSandBox and 'sandbox-api.gameanalytics.com/v2/' .. tostring(API_KEY) .. '/' or 'api.gameanalytics.com/v2/' .. tostring(API_KEY) .. '/'
local sessionNum = 0
local pInfo = {}


function init()
    -- Initialize connection to gameanalytics' rest api
	if not API_KEY or not API_SECRET or API_KEY == '' or API_SECRET == '' then
		outputDebugString('Analytics: No API key and secret added!')
		return
	end
    -- Use internal database here, since we need a local database solution
    local database = executeSQLQuery("CREATE TABLE IF NOT EXISTS analytics (key TEXT, value TEXT)")
	local database2 = executeSQLQuery("CREATE TABLE IF NOT EXISTS analytics_sessions (session_start_ts TEXT, session_id TEXT, eventObject TEXT, userIP TEXT)")
    if not database or not database2 then
        outputDebugString('Analytics: Could not create table in registry.db')
        return
    end
    -- Set session ID
    local returnedSessionId = executeSQLQuery("SELECT value FROM analytics WHERE key=?", 'session_num' )
    if #returnedSessionId == 0 then
        executeSQLQuery("INSERT INTO analytics (key, value) VALUES(?,?)", 'session_num', 1)
        sessionNum = 1
    else
        sessionNum = returnedSessionId[1].value
    end

    local fetchOptions = {
        queueName = 'serverAnalytics',
        connectionAttempts = 3,
        connectionTimeout = 5000,
        method = 'POST',
        postData = {},
        headers = {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = false
        }
    }
    local theData = toJSON({
        ['platform'] = 'Windows',
        ['os_version'] = '10',
        ['sdk_version'] = 'rest api v2'
    })
    fetchOptions.postData = theData
    fetchOptions.headers.Authorization = getAuthorization(theData)

    fetchRemote(API_ENDPOINT .. 'init', fetchOptions, function(res, info)
        if res then res = fromJSON(res) end
        if not info.success or not res or not res.enabled then
            var_dump_admins('-v',info)
            var_dump_admins('-v',res)
            outputDebugString('Could not init analytics, please check if the game key and api secret are correct.')
            return
		else
			canSendEvents = true
			checkOutstandingSessionEndings()
			handleCurrentPlayers()
        end
    end)
end
addEventHandler('onResourceStart', resourceRoot, init)

function getAuthorization(body)
    return sha2.bin2base64(sha2.hex2bin(sha2.hmac(sha2.sha256, API_SECRET, body)))
end

function sendEvent(data, endpoint)
	local now = getRealTime().timestamp
    local options = {
        queueName = 'serverAnalytics',
        connectionAttempts = 3,
        connectionTimeout = 5000,
        method = 'POST',
		postData = {
			 -- Default annotations
			    ['v'] = 2,
                ['user_id'] = 'default user id',
                ['client_ts'] = now,
                ['sdk_version'] = 'rest api v2',
                ['os_version'] = 'windows 10',
                ['manufacturer'] = 'n/a',
                ['platform'] = 'windows',
                ['session_id'] = 'default session id',
                ['session_num'] = 0,
                ['device'] = 'unknown'	
				-- Event data
			
        },
        headers = {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = false,
            
        }
    }
	
	-- Set data to postData
	for key, val in pairs(data) do -- Overwrite default annotations and set event data
		if key ~= 'userIP' and key ~= 'joinStamp' then -- userIP is used for outstanding session endings - joinStamp used to insert into DB
			options.postData[key] = val
		elseif key == 'userIP' then
			options.headers['X-Forwarded-For'] = val
		end
	end

	-- JSONify and set authorization	
    options.postData = toJSON(options.postData,true)
	options.headers.Authorization = getAuthorization(options.postData)

	
	-- Save/remove depending on session_end
	if not isSandBox then
		if data.category ==  'session_end' then
			-- Remove from sqlite
			executeSQLQuery('DELETE FROM analytics_sessions WHERE session_id=?', data.session_id)
		elseif data.category == 'user' then
			-- Insert sqlite
			executeSQLQuery('INSERT INTO analytics_sessions (session_start_ts, session_id, eventObject, userIP) VALUES(?,?,?,?)', data.joinStamp or getRealTime().timestamp, data.session_id, options.postData, data.userIP)
		else
			-- Update sqlite
			executeSQLQuery('UPDATE analytics_sessions SET eventObject=? WHERE session_id=?', options.postData, data.session_id)
		end
	end
	-- Do sendy stuff
	fetchRemote(API_ENDPOINT .. endpoint, options, function(res, info)
        if res then res = fromJSON(res) end
        if not info.success or not res then
            var_dump_admins('-v',info)
			var_dump_admins('-v',res)
            outputDebugString('Analytics: Something went wrong with posting the data, please check f8.')
            return
        end
    end)
end


function getNewSessionNum()
    local s = sessionNum + 1
    executeSQLQuery("UPDATE analytics SET value=? WHERE key=?  ", s, 'session_num')
    return s
end

function getSessionId()
    return getUuid()
end

function getUuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        math.randomseed(getTickCount()+getPlayerCount()+math.random(1,999))
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end
--------------------------------------
-----------------Events---------------
--------------------------------------


function sessionStart(p)
	if not p or not isElement(p) and getElementType(source) == 'player' then
		p = source
	end
	-- Check if session is already started for player
	if pInfo[p] then return end

	-- set user info
	local userInfo = {
		['user_id'] = getPlayerSerial(p),
        ['session_id'] = getSessionId(),
		['session_num'] = getNewSessionNum(),
		['userIP'] = getPlayerIP(p),
		['joinStamp'] = getRealTime().timestamp
	}
    pInfo[p] = userInfo

    -- set data
    local data = {
		['user_id'] = userInfo['user_id'],
        ['session_id'] = userInfo['session_id'],
		['session_num'] = userInfo['session_num'],
		['userIP'] = userInfo['userIP'],
		['category'] = 'user',
		['joinStamp'] = userInfo['joinStamp']
	}

    sendEvent(data, 'events')
end
addEventHandler('onPlayerJoin', root, sessionStart)

function sessionEnd(p)
	if not p or not isElement(p) and getElementType(source) == 'player' then
		p = source
	end
	
	if pInfo[p] and getElementData(p, 'analytics.joinStamp') then
		-- Calculate session time
		local playTime = getRealTime().timestamp - getElementData(p, 'analytics.joinStamp')
		local data = {
			['category'] = 'session_end',
			['length'] = playTime,
			['user_id'] = pInfo[p]['user_id'],
        	['session_id'] = pInfo[p]['session_id'],
			['session_num'] = pInfo[p]['session_num'],
			['userIP'] = pInfo[p].userIP or nil
		}
		sendEvent(data, 'events')
		pInfo[p] = nil
	end
end
addEventHandler('onPlayerQuit', root, sessionEnd)


function checkOutstandingSessionEndings()
	local outstanding = executeSQLQuery("SELECT * FROM analytics_sessions")
	if #outstanding == 0 then return end
	for i, row in ipairs(outstanding) do
		local lastEvent = fromJSON(row.eventObject)
		if lastEvent and lastEvent[1] then
			local playLenght = 1
			if lastEvent[1].client_ts and row.session_start_ts then
				playLenght = lastEvent[1].client_ts - row.session_start_ts
			end

			local data = {
				['category'] = 'session_end',
				['length'] = playLenght,
				['user_id'] = lastEvent[1].user_id,
				['session_id'] = lastEvent[1].seession_id,
				['session_num'] = lastEvent[1].session_num,
				['userIP'] = row.userIP or 0
			}
			sendEvent(data, 'events')
		end
	end
end

function handleCurrentPlayers()
	for _, p in ipairs(getElementsByType('player')) do
		sessionStart(p)
	end
end


-- modifiers: v - verbose (all subtables), n - normal, s - silent (no output), dx - up to depth x, u - unnamed
function var_dump_admins(...)
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
						local keyString, keyTable = var_dump_admins(newModifiers,key)
						local valueString, valueTable = var_dump_admins(newModifiers,value)
						
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
	for _, p in ipairs(getElementsByType('player')) do
		if hasObjectPermissionTo( p, 'function.banPlayer', false ) then
			string = ""
			for k,v in ipairs(output) do
				if outputDirectly then
					outputConsole(v,p)
				end
				string = string..v
			end
		end
	end
	return string, output
end