
-----------------
-- Items stuff --
-----------------

local ID = 4
local g_CustomPlayers = {}
local PJ_API_URL = "https://mrgreengaming.com/api/custompaintjobs/"


local loadGCCustomPaintjobQueue = {}

function loadGCCustomPaintjob(player, bool, settings)
    local function executeLoadGCCustomPaintjob()
        if bool then
            if not isElement(player) then return end
            g_CustomPlayers[player] = player
            sendPaintjobs({player}, player)
            checkAPIOutdatedPaintjobs(player)
        else
            g_CustomPlayers[player] = nil
        end
    end
    table.insert(loadGCCustomPaintjobQueue, executeLoadGCCustomPaintjob)
end

function executeAllLoadPaintjobFunctionsInQueue()
    for _, func in ipairs(loadGCCustomPaintjobQueue) do
        func()
    end
    -- Clear the queue after executing all functions.
    loadGCCustomPaintjobQueue = {}
end

------------------------------------
---   Drawing custom paintjobs   ---
------------------------------------
local usethePJ = true
addCommandHandler("usePJ",
	function(player,command,bool)

		if bool == nil then outputChatBox("Wrong syntax used: /usePJ [true/false]",player) return end
		if hasObjectPermissionTo(player,"function.banPlayer",false) then
			outputDebugString("Custom Paintjobs set to "..tostring(bool).." by: "..getPlayerName(player))
			if bool == "false" then
				usethePJ = false
			elseif bool == "true" then
				usethePJ = true
			end
		end
	end )


function applyCustomPaintJob( player, pid )
	if usethePJ == false then return end
	local forumID = exports.gc:getPlayerForumID ( player )
	--outputDebugString("s add custom paintjob " .. pid)
	setElementData(player, 'gcshop.custompaintjob', forumID .. '-' .. pid)
end

function removeCustomPaintJob (player)
	--outputDebugString("s rem custom paintjob")
	setElementData(player, 'gcshop.custompaintjob', nil)
end

function onResourceStart()
	for k, p in ipairs(getElementsByType('player')) do
		setElementData(p, 'gcshop.custompaintjob', nil)
	end
end
addEventHandler('onResourceStart', resourceRoot, onResourceStart)

------------------------------------
---   Sending custom paintjobs   ---
------------------------------------

local server_path = 'items/paintjob/'
function sendPaintjobs ( from, to, pid )
	-- outputChatBox('Sending to')
	-- outputChatBox(tostring(getElementType(to)))
	getPerkSettings(from, ID,
	function(res)
		local md5list = {}
		if type(res) == 'table' then
			for player, opt in pairs(res) do
				local player_md5_list = {}
				local paintjobs = fromJSON(opt)
				local forumID = exports.gc:getPlayerForumID ( player )
				if not tonumber(pid) then
					for pid=1,paintjobs.amount do
						if fileExists(server_path .. tostring(forumID) .. '-' .. pid .. '.bmp') then
							player_md5_list[pid] = getMD5 ( server_path .. tostring(forumID) .. '-' .. pid .. '.bmp' )
						end
					end
				else
					if fileExists(server_path .. tostring(forumID) .. '-' .. pid .. '.bmp') then
						player_md5_list[pid] = getMD5 ( server_path .. tostring(forumID) .. '-' .. pid .. '.bmp' )
					end
				end
				md5list[forumID] = player_md5_list
			end
		end

		-- Send a list that links players do forum id's to client
		local idToPlayerList = getIdToPlayerList()

		if to == root then
			triggerClientEvent('serverPaintjobsMD5', resourceRoot, md5list, idToPlayerList)
		elseif type(to) == 'table' then
			for _, player in pairs(to) do
				triggerClientEvent(player, 'serverPaintjobsMD5', resourceRoot, md5list, idToPlayerList)
			end
		elseif isElement(to) then
			triggerClientEvent(to, 'serverPaintjobsMD5', resourceRoot, md5list, idToPlayerList)
		end
	end)
end

function clientSendPaintjobs()
	sendPaintjobs(getCustomPlayersArray(), client)
end
addEvent('clientSendPaintjobs', true)
addEventHandler('clientSendPaintjobs', root, clientSendPaintjobs)

function clientRequestsPaintjobs ( requests )
	local files = {}
	for _, filename in ipairs(requests) do
		local file = fileOpen(server_path .. filename, true)
		local image = fileRead(file, fileGetSize(file))
		fileClose(file)
		files[filename] = image
	end
	triggerLatentClientEvent(client, 'serverSendsPaintjobs', 1000000, resourceRoot, files)
end
addEvent('clientRequestsPaintjobs', true)
addEventHandler('clientRequestsPaintjobs', root, clientRequestsPaintjobs)

addEventHandler('onPlayerQuit', root, function()
	g_CustomPlayers[source] = nil


end)

----------------------------------------
---   Downloading custom paintjobs   ---
---          from clients            ---
----------------------------------------

function setUpCustomPaintJob( player, filename, pid )
	local forumID = exports.gc:getPlayerForumID ( player )
	if not fileExists(server_path .. tostring(forumID) .. '-' .. pid .. '.bmp') then
		-- No paintjob retrieved yet, request the first one
		--outputDebugString('s: No paintjob retrieved yet, request the first one ' .. forumID .. ' '  .. pid .. ' ' .. getPlayerName(player))
		triggerClientEvent(player, 'gcshopRequestPaintjob', resourceRoot, false, forumID, filename, pid)
	else
		-- A paintjob exists, check if the client has a new one using md5
		local imageMD5 = getMD5(server_path .. tostring(forumID) .. '-' .. pid .. '.bmp')
		--outputDebugString('s: A paintjob exists, check if the client has a new one using md5 ' .. forumID .. ' '  .. pid .. ' ' .. getPlayerName(player) .. ' ' .. tostring(imageMD5))
		triggerClientEvent(player, 'gcshopRequestPaintjob', resourceRoot, imageMD5, forumID, filename, pid)
	end
end
addCommandHandler('setUpCustomPaintJob', function(p, c, pid, f) setUpCustomPaintJob( p, f, pid ) end)
addEvent('setUpCustomPaintJob', true);
addEventHandler('setUpCustomPaintJob', resourceRoot, setUpCustomPaintJob);

function receiveImage ( image, pid )
	local player = source
	local forumID = exports.gc:getPlayerForumID ( player )
	if image == false then
		-- sendOldPaintjob to clients
		--outputDebugString('s: No new paintjob uploaded, keeping old one')
		sendPaintjobs ( {player}, player, pid )
	else
		-- send new paintjob to clients
		--outputDebugString('s: New paintjob arrived, saving')
		local dummy = fileCreate(server_path .. forumID .. '-' .. pid .. 'dummy.bmp')
		fileWrite(dummy, image)

		local maxFileSize = 0.5 -- In MB
		if fileGetSize(dummy) > (maxFileSize*1048576) then -- If file is bigger then x MB
			outputChatBox("Custom paintjob image too big, please use a smaller image. (Max: "..tostring(maxFileSize).."MB)",player,255,0,0)
			fileClose(dummy)
			fileDelete(server_path .. forumID .. '-' .. pid .. 'dummy.bmp')
			sendPaintjobs ( {player}, player, pid )
		else -- If file is under the size limit
			fileClose(dummy)
			fileDelete(server_path .. forumID .. '-' .. pid .. 'dummy.bmp')
			local file = fileCreate(server_path .. forumID .. '-' .. pid .. '.bmp')
			fileWrite(file, image)
			fileClose(file)
			sendPaintjobs ( {player}, player, pid )
			sendAPICustomPaintjob(player, forumID .. '-' .. pid, base64Encode(image))
		end



	end
end
addEvent('receiveImage', true)
addEventHandler('receiveImage', root, receiveImage)

function getMD5 ( filename )
	local file = fileOpen(filename, true)
	local image = fileRead(file, fileGetSize(file))
	fileClose(file)
	return md5(image)
end
----------------------------------------
---    Send/Save custom paintjob     ---
---             with API             ---
----------------------------------------
function checkAPIOutdatedPaintjobs(player)
	local forumID = exports.gc:getPlayerForumID(player)
	if not isElement(player) or getElementType(player) ~= 'player' or not forumID then return end
	getPerkSettings(player, ID,
	function(res)
		if type(res) == 'table' and type(res.amount) == 'number' then
			local userPjs = {}
			for i = 1, res.amount do
				table.insert(userPjs, forumID..'-'..i)
			end
			getAPICustomPaintjobMD5(userPjs)
		end
	end)
end

function getAPICustomPaintjobMD5(paintjobID)
	local ids = {}
	if type(paintjobID) == 'table' then
		ids = paintjobID
	elseif type(paintjobID) == 'string' then
		ids = {paintjobID}
	else
		outputDebugString('getAPICustomPaintjobMD5: Empty paintjobID', 1)
		return
	end

	local fetchOptions = {
        queueName = "API-Paintjob",
        connectionAttempts = 3,
        connectTimeout = 4000,
        method = "POST",
        postData = toJSON({
            paintjobs = ids,
            appId = get("gc.appId"),
            appSecret = get("gc.appSecretPass")
		}, true),
		headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }
	}
	fetchRemote(PJ_API_URL .. "getmd5", fetchOptions, receiveAPICustomPaintjobMD5)
end

function receiveAPICustomPaintjobMD5(res, info)
	if not info.success or not res then
		if not res then
			res = "EMPTY"
		end
		outputDebugString("receiveAPICustomPaintjobMD5: invalid response (status " .. info.statusCode .. "). Res: " .. res, 1)
		return
	end

	local result = fromJSON(res)
	if not result or result.error then
		return
	end

	-- Check for changes
	for name, hash in pairs(result) do
		if type(hash) == 'string' and type(name) == 'string' then
			local serverMD5 = string.upper(hash)
			local filePath = server_path .. name .. '.bmp'
			local exists = fileExists(filePath)
			if exists then
				local imageMD5 = getMD5(filePath)
				if imageMD5 ~= serverMD5 then
					-- Server has a different bmp image, so download the correct one
					getAPICustomPaintjob(name)
				end
			else
				getAPICustomPaintjob(name)
			end
		end
	end
end

function getAPICustomPaintjob(paintjobID)
	if type(paintjobID) ~= 'string' then return end
	outputDebugString('gcshop: Downloading paintjob from API: '..paintjobID)
	local fetchOptions = {
        queueName = "API-Paintjob",
        connectionAttempts = 3,
        connectTimeout = 4000,
        method = "POST",
        postData = toJSON({
            id = paintjobID,
            appId = get("gc.appId"),
            appSecret = get("gc.appSecretPass")
		}, true),
		headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }
	}
	fetchRemote(PJ_API_URL .. "getpaintjob", fetchOptions, receiveAPICustomPaintjob, {paintjobID})
end

function receiveAPICustomPaintjob(res, info, id)
	if type(info) == 'table' and info.success and type(id) == 'string' then
		-- Save new custom PJ
		local file = fileCreate("items/paintjob/" .. id ..'.bmp')
		fileWrite( file, res )
		fileClose( file )
		outputDebugString('gcshop: Saved new paintjob '..id)
	end
end

function sendAPICustomPaintjob(player, paintjobID, imageData)
	if not player or type(paintjobID) ~= 'string' or type(imageData) ~= 'string' then return end
	local fetchOptions = {
        queueName = "API-Paintjob",
        connectionAttempts = 3,
        connectTimeout = 4000,
        method = "POST",
        postData = toJSON({
			id = paintjobID,
            data = splitPaintjobImageString(imageData),
            appId = get("gc.appId"),
            appSecret = get("gc.appSecretPass")
		}, true),
		headers = {
			["Content-Type"] = "application/json",
			["Accept"] = "application/json"
        }
	}
	fetchRemote(PJ_API_URL .. "savepaintjob", fetchOptions, function(res, status)
		if type(status) == 'table' and status.success then
			outputChatBox('GCShop: Successfully uploaded new paintjob!', player, 0, 255, 0)
		else
			if not status.success or not res then
				if not res then
					res = "EMPTY"
				end
				outputDebugString("sendAPICustomPaintjob: invalid response (status " .. status.statusCode .. "). Res: " .. res, 1)
			end
			outputChatBox('GCShop: Could not upload paintjob, please try again', player, 255, 0 , 0)
		end
	end)
end
----------------------------------------
---         Hosting PJ upload        ---
----------------------------------------
function receiveHostingURL(url,id)
	local player = source
	fetchRemote(url,receiveHostingFetch,"",false,player,id)
end
addEvent("serverReceiveHostingURL",true)
addEventHandler("serverReceiveHostingURL",root,receiveHostingURL)

function receiveHostingFetch(responseData,errno,player,id)
	if not player or not responseData then return end
	if errno == 0 then
		triggerEvent("receiveImage",player,responseData,id)
	else
		outputChatBox("Downloading paintjob failed, please check the URL or contact an admin (ERROR CODE: "..tostring(errno).." )",player,255,0,0)
	end
end

-- Send info to clients for (re)making textures
addEvent('onRaceStateChanging', true)
function serverRefreshClientPJTable(state)
	if state == "LoadingMap" then
        executeAllLoadPaintjobFunctionsInQueue()
		sendPaintjobs(getCustomPlayersArray(), root)
		-- triggerClientEvent("clientRefreshShaderTable",resourceRoot,root)
	end
end
addEventHandler("onRaceStateChanging", root, serverRefreshClientPJTable)

-- util
function getIdToPlayerList()
	local l = {}
	for i, p in ipairs(getElementsByType('player')) do
		local theId = exports.gc:getPlayerForumID(p)
		if theId then
			l[theId] = p
		end
	end
	return l
end

function getCustomPlayersArray()
	local g_CustomPlayersArray = {}
	for p, _ in pairs(g_CustomPlayers) do
		table.insert(g_CustomPlayersArray, p)
	end
	return g_CustomPlayersArray
end

function splitPaintjobImageString(imageString)
    local s = {}
    for i=1, #imageString, 60000 do
        s[#s+1] = imageString:sub(i,i+60000 - 1)
    end
    return s
end
