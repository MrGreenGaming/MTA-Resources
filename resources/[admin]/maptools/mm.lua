local maxuploaded_maps = 3

-------------
-- newMap --
-------------

local uploadedfolder = "[maps]\\[uploadedmaps]"

function newMap(map, forumid, mta_name)
	local mapname = tostring(map) .. '_newupload'
	outputDebugString('newMap ' .. mapname)
	refreshResources()
	setTimer(refreshResources, 2000, 1)
	local mapres = getResourceFromName(map)
	if mapres then
		if getResourceInfo(mapres, "forumid") then
			if getResourceInfo(mapres, "forumid") ~= tostring(forumid) then
				return 'This mapname is already in use on the server, only ' .. getResourceInfo(mapres, "mta_name") .. ' can update ' .. map, ''
			end
		-- else
			-- outputDebugString('new map already exists ' .. map)
			-- outputConsole('new map already exists ' .. map)
			-- return 'This map is already on the server (' .. map .. '), contact a mapmanager if you want to update it', ''
		end
	else
		local mapsInQ = 0
		for k, r in ipairs(getResources()) do
			if getResourceInfo(r, "forumid") == tostring(forumid) and getResourceInfo(r, "newupload") == "true" then
				mapsInQ = mapsInQ + 1
			end
		end
		if mapsInQ >= maxuploaded_maps then
			return 'You already have the max amount of maps (' .. maxuploaded_maps .. ') uploaded, wait untill a mapmanager tests your maps before uploading another one', ''
		end
	end
	local res = getResourceFromName(mapname)
	if not res then
		outputDebugString('loading failed ' .. mapname)
		outputConsole('loading failed ' .. mapname)
		return 'Could not load ' .. tostring(map), ''
	end
	
	local s = getResourceLoadFailureReason(res)
    setResourceInfo(res, "newupload", "true")
    setResourceInfo(res, "forumid", tostring(forumid))
    setResourceInfo(res, "mta_name", mta_name)
    setResourceInfo(res, "uploadtick", tostring(getRealTime().timestamp))
	if s ~= '' then
		if getResourceState(res) == "running" then
			stopResource(res)
		end
		deleteResource(mapname)
		outputDebugString(s..': deleting ' .. mapname)
		outputConsole(s..': deleting ' .. mapname)
	end
	return tostring(s), mapres and getResourceInfo(mapres, "forumid") == tostring(forumid) and "Update" or "New"
end

function handlemap(p, c, resname, ...)
	if not handlerConnect or not resname then return false end
	local mapname = resname .. '_newupload'
	local res = getResourceFromName(mapname)
	if not res then
		return outputChatBox(c..': could not find res ' .. resname, p)
	elseif getResourceInfo(res, "newupload") ~= "true" then
		return outputChatBox(c..': resource is not a new map ' .. resname, p)
	end
	if getResourceState(res) == "running" then
		-- deleteRes = res
		return outputChatBox(c..': can\'t use this while the map is running ' .. resname, p)
	end
	local mta_name = getResourceInfo(res, "mta_name")
	local comment = table.concat({...}, ' ')
	local manager = tostring(getAccountName(getPlayerAccount(p)))
	local status = (c == "acceptmap" and "Accepted" or "Declined")
	if c == "acceptmap" then
		if getResourceFromName(resname) then
			deleteResource(getResourceFromName(resname))
		end
		local newRes = copyResource(res, resname, uploadedfolder)
		setResourceInfo(newRes, "newupload", "false")
	end
	deleteResource(mapname)
	local query = "INSERT INTO uploaded_maps (resname, uploadername, comment, manager, status) VALUES (?,?,?,?,?)"
	local theExec = dbExec ( handlerConnect, query, resname, mta_name, comment, manager, status)
	outputChatBox(c..': done ' .. resname, p)
	fetchMaps(p)
end
addCommandHandler('acceptmap', handlemap, true)
addCommandHandler('declinemap', handlemap, true)

function checkDeleteMap()
    if deleteRes and deleteRes ~= exports.mapmanager:getRunningGamemodeMap() then
		deleteResource(getResourceName(deleteRes))
		deleteRes = nil
    end
end
addEventHandler('onMapStarting', root, checkDeleteMap)


--facilitating map deletion--

deletedMapsPath = "[maps]\\[deletedmaps]"

addEvent('onMapStarting', true)
function connectToDB()
	if handlerConnect then return true end
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname", get("*gcshop.user"), get("*gcshop.pass"))

	if not handlerConnect then
		return outputDebugString('maptools: could not connect to the mysql db')
	end
	moveMapDeletionCache() -- Map deletion entries are stored locally if the mysql database does not work, if it works again move them to mysql
	
end
addEventHandler('onResourceStart', resourceRoot, connectToDB)



function onNewMapStart()

    local map = g_Map
    if map == exports.mapmanager:getRunningGamemodeMap() then   --if map that was deleted gets replayed before deletion, halt deletion for the next map.
        return
    end
    local name = getResourceInfo(map, "name")
    local authr = getResourceInfo(map,"author")
    if not authr then authr = "N/A" end


    -- First copy resource to "[deletedmaps]" folder, then deleteResource(), because the trash folder is unreliable

    local resname = getResourceName(map)

    -- set 
    
    setResourceInfo(map,"gamemodes","race_deleted")
    setResourceInfo(map,"deleted","true")
    setResourceInfo(map,"deleteReason",g_Reason)
    setResourceInfo(map,"deletedBy",g_AccName)
    setResourceInfo(map,"deleteTimeStamp",tostring(getRealTime().timestamp))

    -- Check if copied deleted resource exists, if so then delete first.
    if getResourceFromName( resname.."_deleted" ) then
    	deleteResource( resname.."_deleted" )
    end

    copyResource(map,resname.."_deleted",deletedMapsPath)

    local delete = deleteResource(resname)
    if not delete then
        if isElement(g_P) then outputChatBox("Error: Map cannot be deleted.", g_P) end
        canUseCommand = true
        g_Map = nil
        g_P = nil
        g_Reason = nil
		g_AccName = nil
        removeEventHandler('onMapStarting', root, onNewMapStart)
        return
    end
    if isElement(g_P) then
        outputChatBox("Map deleted: "..name, g_P)
    end
    addMapDeletionRecord(name,authr,g_Reason,g_AccName,resname)

    refreshResources()
    canUseCommand = true
    

    g_Map = nil
    g_P = nil
    g_Reason = nil
	g_AccName = nil
    removeEventHandler('onMapStarting', root, onNewMapStart)
    -- fetchMaps()
end

canUseCommand = true
g_Map = nil
g_P = nil
g_Reason = nil
g_AccName = nil

addCommandHandler('deletemap',
function(p,_,...)
    if not (hasObjectPermissionTo(p, "function.banPlayer", false)) then return end
    if not arg then outputChatBox("Error: Give a reason for map deletion. ( /deletemap full reason )", p) return end
    local fullReason = table.concat(arg," ")
    if not fullReason or #fullReason < 1 then outputChatBox("Error: Give a reason for map deletion. ( /deletemap full reason )", p) return end

    --get current map running, copy it over as a backup and delete it from map list via refresh.
    if not canUseCommand then outputChatBox("Error: Can't use command. An admin has already deleted this map.", p) return end
    local map = exports.mapmanager:getRunningGamemodeMap()
    if not map then outputChatBox("Error: No map.", p) return end
    local adminAccName = getAccountName(getPlayerAccount(p))
    if not adminAccName then outputChatBox("Error: Unable to retrieve account name, contact a developer if this keeps happening.", p) return end

    outputChatBox("Deleting current map at the start of the next map! (reason: "..fullReason..") by "..getPlayerName(p), root, 255, 0, 0)
    g_Map = map
    g_P = p
    g_Reason = fullReason
    g_AccName = adminAccName

    addEventHandler('onMapStarting', root, onNewMapStart)
    canUseCommand = false
end
)

function addMapDeletionRecord(mapname,author,reason,adminName,resname)
	connectToDB() -- Retry db connection
	if handlerConnect then -- if there is db connection, else save in local db file
		moveMapDeletionCache()

		local query = "INSERT INTO uploaded_maps (mapname, uploadername, comment, manager, resname, status) VALUES (?,?,?,?,?,'Deleted')"
		dbExec ( handlerConnect, query,tostring(mapname),tostring(author),tostring(reason),tostring(adminName),tostring(resname)  )
	else -- save to local db
		local theXML = xmlLoadFile("mapdeletioncache.xml")
		if not theXML then
			theXML = xmlCreateFile("mapdeletioncache.xml","entries")
		end

		if not theXML then return false end

		local child = xmlCreateChild(theXML,"map")
		xmlNodeSetAttribute(child,"name",tostring(mapname))
		xmlNodeSetAttribute(child,"author",tostring(author))
		xmlNodeSetAttribute(child,"reason",tostring(reason))
		xmlNodeSetAttribute(child,"admin_name",tostring(adminName))
		xmlNodeSetAttribute(child,"resname",tostring(resname))

		xmlSaveFile(theXML)
		xmlUnloadFile(theXML)



	end
end

function moveMapDeletionCache() -- Moves from cache xml to mysql db
	if not handlerConnect then return false end

	local theXML = xmlLoadFile("mapdeletioncache.xml")
	if not theXML then return end
	local children = xmlNodeGetChildren(theXML)

	if not children or (#children < 1 )then xmlUnloadFile(theXML) return false end

	for i,child in ipairs(children) do
		local mapname = xmlNodeGetAttribute(child,"name")
		local author = xmlNodeGetAttribute(child,"author")
		local reason = xmlNodeGetAttribute(child,"reason")
		local adminName = xmlNodeGetAttribute(child,"admin_name")
		local resname = xmlNodeGetAttribute(child,"resname")

		local query = "INSERT INTO uploaded_maps (mapname, uploadername, comment, manager, resname, status) VALUES (?,?,?,?,?,'Deleted')"
		local theExec = dbExec ( handlerConnect, query,tostring(mapname),tostring(author),tostring(reason),tostring(adminName),tostring(resname)  )

		if theExec then
			xmlDestroyNode(child)
		end
		
		xmlSaveFile(theXML)
		xmlUnloadFile(theXML)
	end
end




--Get Maplist and deletedMap list for client gui
function fetchMaps(player)
    refreshResources()

    local mapList = {}
    local deletedMapList = {}
    local uploadedMapList = {}

    -- Get race and uploaded maps
    local raceMps = exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName("race"))
	local mapRatings = exports.mapratings:getTableOfRatedMaps()
    if not raceMps or not mapRatings then return false end

    for _,map in ipairs(raceMps) do
        local name = getResourceInfo(map,"name")

        local author = getResourceInfo(map,"author")
        local resname = getResourceName(map)

        if not name then name = resname end
        if not author then author = "N/A" end

        local t = {name = name, author = author, resname = resname, likes = "-", dislikes = "-"}
		
		local rating = mapRatings[resname]
		if rating then
			t.likes = rating.likes
			t.dislikes = rating.dislikes
		end
        table.insert(mapList,t)
    end

    -- Deleted and uploaded maps
    local allRes = getResources()

    if not allRes then return false end

    for _,map in ipairs(allRes) do
        if getResourceInfo(map,"gamemodes") == "race_deleted" then
            local name = getResourceInfo(map,"name")
            local author = getResourceInfo(map,"author")
            local deletedBy = getResourceInfo(map,"deletedBy")
            local deleteTimeStamp = getResourceInfo(map,"deleteTimeStamp")
            local deleteReason = getResourceInfo(map,"deleteReason")
            local resname = getResourceName(map)
            local t = {name = name, author = author, resname = resname, deletedBy = deletedBy, deleteTimeStamp = deleteTimeStamp, deleteReason = deleteReason}
            table.insert(deletedMapList,t)
		elseif getResourceInfo(map,"newupload") == "true" then
            local name = getResourceInfo(map,"name")
            local author = getResourceInfo(map,"author")
            local uploadtick = tonumber(getResourceInfo(map,"uploadtick"))
            local resname = getResourceName(map)
			local new = getResourceFromName(string.gsub(resname, "_newupload", "")) and "Update" or "New"
            local t = {name = name, author = author, resname = resname, uploadtick = uploadtick, new = new}
            table.insert(uploadedMapList,t)
        end
    end

    table.sort(uploadedMapList,function(a,b) return tostring(a.uploadtick) > tostring(b.uploadtick) end)
    table.sort(deletedMapList,function(a,b) return tostring(a.deleteTimeStamp) > tostring(b.deleteTimeStamp) end)
    table.sort(mapList,function(a,b) return tostring(a.name) < tostring(b.name) end)

	triggerClientEvent(player,"mm_receiveMapLists",resourceRoot,uploadedMapList,deletedMapList,mapList,hasObjectPermissionTo(player,"command.deletemap",false))
end
addCommandHandler("managemaps",fetchMaps)
addCommandHandler("mm",fetchMaps)
addCommandHandler("deletedmaps",fetchMaps)
addCommandHandler("maps",fetchMaps)


-- Editing resources --
function editmap(player, cmd, mapname)
	local map = mapname and getResourceFromName(mapname) or false
	if not map then return outputChatBox("Map not found ", player) end
	local accName = getAccountName ( getPlayerAccount ( player ) )
	if not exports.mapmanager:isMap(map) and not isObjectInACLGroup ("user."..accName, aclGetGroup ( "ServerManager" )) then
		outputChatBox("This resource does not exist or can not be edited", player)
		return
	end
	local meta = xmlLoadFile(':' .. mapname .. '/meta.xml')
	if not meta then return outputChatBox("Could not open meta " .. mapname, player) end
	local files = {{file="meta.xml",type="meta"}}
	for k, node in ipairs(xmlNodeGetChildren(meta)) do
		if xmlNodeGetAttribute(node, "src") and (xmlNodeGetName(node) == "map" or xmlNodeGetName(node) == "script") then
			table.insert(files, {file=xmlNodeGetAttribute(node, "src"), type=xmlNodeGetName(node)})
		end
	end
	triggerClientEvent(player, "editMapFilesList", resourceRoot, mapname, files)
	xmlUnloadFile(meta)
end
addCommandHandler("editmap", editmap, true)

function editfile(player, cmd, mapname, src)
	local map = mapname and getResourceFromName(mapname) or false
	if not map then return outputChatBox("Map not found ", player) end
	local accName = getAccountName ( getPlayerAccount ( player ) )
	if not exports.mapmanager:isMap(map) and not isObjectInACLGroup ("user."..accName, aclGetGroup ( "ServerManager" )) then
		outputChatBox("This resource does not exist or can not be edited", player)
		return
	end
	local file = fileOpen(':' .. mapname .. '/' .. src)
	if not file then return outputChatBox("Could not open :" .. mapname .. '/' ..src, player) end
	local text = fileRead(file, fileGetSize(file))
	fileClose(file)
	triggerClientEvent(player, "editFileText", resourceRoot, mapname, src, text)
end
addCommandHandler("editfile", editfile, true)

function savefile(mapname, src, text)
	local player = client
	local map = mapname and getResourceFromName(mapname) or false
	if not map then return outputChatBox("Map not found ", player) end
	local accName = getAccountName ( getPlayerAccount ( player ) )
	if not (hasObjectPermissionTo(player, "command.editfile", false)) then
		outputChatBox("You have no access to this", player)
		return
	elseif not exports.mapmanager:isMap(map) and not isObjectInACLGroup ("user."..accName, aclGetGroup ( "ServerManager" )) then
		outputChatBox("This resource does not exist or can not be edited", player)
		return
	end
	-- create a backup
	local backup = fileCopy(':' .. mapname .. '/' .. src, ':' .. mapname .. '/' .. src .. '.' .. getRealTime().timestamp .. '.bak', true)
	if not backup then return outputChatBox("Could not create backup. Changes aren't saved.", player) end
	
	local deletefile = fileDelete(':' .. mapname .. '/' .. src)
	if not deletefile then return outputChatBox("Could not overwrite:" .. mapname .. '/' ..src, player) end
	
	local file = fileCreate(':' .. mapname .. '/' .. src)
	if not file then return outputChatBox("Could not overwrite:" .. mapname .. '/' ..src, player) end
	fileWrite(file, text)
	fileClose(file)
	outputChatBox("Saved file " .. ':' .. mapname .. '/' .. src .. " and made a backup", player)
end
addEvent("savefile", true)
addEventHandler("savefile", resourceRoot, savefile)


-- Clientside events for commands
addEvent("cmm_restoreMap",true)
function restoreMap(map)
    if hasObjectPermissionTo(client,"command.deletemap",false) then
        local theRes = getResourceFromName(map.resname)
        if not theRes then outputChatBox("Error: map can not be restored (can't find map resource)",client,255,0,0) return end

        local properName = string.gsub(map.resname,"_deleted","")
        
        local raceMode = getResourceInfo(theRes,"racemode")
        if not raceMode then raceMode = "[maps]/[dd]" else raceMode = "[maps]/["..raceMode.."]" end

        local theCopy
        local sn = string.lower(getServerName())
        if string.find(sn,"mix") then -- looks if mix or race server
            theCopy = copyResource(theRes,properName,raceMode)
        else
            theCopy = copyResource(theRes,properName,"[maps]")
        end

        if not theCopy then outputChatBox("Can't copy map, resource may already exist",client,255,0,0) return end
        deleteResource(theRes)

        setResourceInfo(theCopy,"gamemodes","race")
        setResourceInfo(theCopy,"deleted","false")
		if handlerConnect then -- if there is db connection, else save in local db file
			local query = "INSERT INTO uploaded_maps (mapname, uploadername, manager, resname, status) VALUES (?,?,?,?,'Restored')"
			dbExec ( handlerConnect, query,getResourceInfo(theCopy, "name") or properName,getResourceInfo(theCopy,"author") or "N/A",tostring(getAccountName(getPlayerAccount(client))),properName)
		end
        outputChatBox("Map '".. getResourceName(theCopy) .."' restored!",client)
        refreshResources()
        fetchMaps(client)
    end

end
addEventHandler("cmm_restoreMap",root,restoreMap)

addEvent("cmm_deleteMap",true)
function deleteMapFromGUI(map,reason) -- Admin deleted map via the gui

    if hasObjectPermissionTo(client,"command.deletemap",false) then
        if map == exports.mapmanager:getRunningGamemodeMap() then
            outputChatBox("The map you are trying to delete is currently playing, use /deletemap instead!",client,255,0,0)
            return
        end

        local theRes = getResourceFromName(map.resname)
        if not theRes then
            outputChatBox("error: Can't find map resource!",client,255,0,0)
        end
        
        local adminAccName = getAccountName(getPlayerAccount(client))
        if not adminAccName then outputChatBox("Error: Unable to retrieve account name, contact a developer if this keeps happening.", client,255,0,0) return end
        

        setResourceInfo(theRes,"gamemodes","race_deleted")
        setResourceInfo(theRes,"deleted","true")
        setResourceInfo(theRes,"deleteReason",reason)
        setResourceInfo(theRes,"deletedBy",adminAccName)
        setResourceInfo(theRes,"deleteTimeStamp",tostring(getRealTime().timestamp))

		-- Check if copied deleted resource exists, if so then delete first.
		if getResourceFromName( map.resname.."_deleted" ) then
			deleteResource( map.resname.."_deleted" )
		end

        copyResource(theRes,map.resname.."_deleted",deletedMapsPath)
        local delete = deleteResource(map.resname)
        if not delete and isElement(client) then
            outputChatBox("Error: Map cannot be deleted.",client,255,0,0)
            return
        end

        if isElement(client) then
            outputChatBox("Map deleted: "..tostring(map.name),client)
        end
        addMapDeletionRecord(map.name,map.author,reason,adminAccName,map.resname)


        
        refreshResources()
        fetchMaps(client)
    end

end
addEventHandler("cmm_deleteMap",root,deleteMapFromGUI)

addEvent("nextmap",true)
function nextMapFromGUI(map) -- Admin next upload map via the gui
    if hasObjectPermissionTo(client,"command.nextmap",false) then
        executeCommandHandler("nextmap", client, map.."_newupload")
    end
end
addEventHandler("nextmap",root,nextMapFromGUI)

addEvent("acceptmap",true)
function acceptMapFromGUI(map, comment) -- Admin accept upload map via the gui
    if hasObjectPermissionTo(client,"command.acceptmap",false) then
        executeCommandHandler("acceptmap", client, map .. ' ' .. (comment or ''))
    end
end
addEventHandler("acceptmap",root,acceptMapFromGUI)

addEvent("declinemap",true)
function declineMapFromGUI(map, comment) -- Admin decline upload map via the gui
    if hasObjectPermissionTo(client,"command.declinemap",false) then
        executeCommandHandler("declinemap", client, map .. ' ' .. (comment or ''))
    end
end
addEventHandler("declinemap",root,declineMapFromGUI)

addEvent("editmap",true)
function editMapFromGUI(map) -- Admin editing map via the gui
    if hasObjectPermissionTo(client,"command.editmap",false) then
        executeCommandHandler("editmap", client, map)
    end
end
addEventHandler("editmap",root,editMapFromGUI)

addEvent("editfile",true)
function editFileFromGUI(map,src) -- Admin editing file via the gui
    if hasObjectPermissionTo(client,"command.editfile",false) then
        executeCommandHandler("editfile", client, map..' '..src)
    end
end
addEventHandler("editfile",root,editFileFromGUI)
