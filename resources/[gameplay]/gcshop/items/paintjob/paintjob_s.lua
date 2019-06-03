
-----------------
-- Items stuff --
-----------------

local ID = 4
local g_CustomPlayers = {}

function loadGCCustomPaintjob ( player, bool, settings )
	if bool then
		g_CustomPlayers[player] = player
		sendPaintjobs ( {player}, player )
	else
		g_CustomPlayers[player] = nil
	end
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
	local md5list = {}
	for _, player in pairs(from) do
		local player_md5_list = {}
		local paintjobs = getPerkSettings(player, ID)
		local forumID = exports.gc:getPlayerForumID ( player )
		if not tonumber(pid) then
			for pid=1,paintjobs.amount do
				if fileExists(server_path .. tostring(forumID) .. '-' .. pid .. '.bmp') then
					player_md5_list[pid] = getMD5 ( server_path .. tostring(forumID) .. '-' .. pid .. '.bmp' )
				--else
					--player_md5_list[pid] = false
				end
			end
		else
			if fileExists(server_path .. tostring(forumID) .. '-' .. pid .. '.bmp') then
				player_md5_list[pid] = getMD5 ( server_path .. tostring(forumID) .. '-' .. pid .. '.bmp' )
			--else
				--player_md5_list[pid] = false
			end
		end
		md5list[forumID] = player_md5_list
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
end

function clientSendPaintjobs()
	sendPaintjobs(g_CustomPlayers, client)
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

		local maxFileSize = 1.5 -- In MB
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
			outputChatBox("Custom Paintjob Uploaded!",player,255,255,255)
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
---         Hosting PJ upload         ---
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

-- Send custom PJ info to client on vehicle switch
-- function PjInfoToClient(name,old)
-- 	if name == "gcshop.custompaintjob" then
-- 		local newPJ = getElementData(source,name)

-- 		outputChatBox("NEW: "..tostring(getElementData(source,name)).." OLD: "..tostring(old))
-- 		if not old and not newPJ then
-- 			-- REMOVE PJ
-- 		elseif newPJ then
-- 			-- NEW PJ
-- 		end
-- 	end
-- end
-- addEventHandler("onElementDataChange",root,PjInfoToClient)


-- Send info to clients for (re)making textures
addEvent('onRaceStateChanging', true)
function serverRefreshClientPJTable(state)
	if state == "NoMap" then
		sendPaintjobs(g_CustomPlayers, root)
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
