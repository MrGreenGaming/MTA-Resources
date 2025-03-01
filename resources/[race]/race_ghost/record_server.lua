newghostForumid, newghostMapname = nil, nil
addCommandHandler('deleteghost', function(client)
	local forumid = exports.gc:getPlayerForumID(client)
	-- if (forumid and playback.forumid == forumid) or hasObjectPermissionTo(client, "function.banPlayer", false) then
	if (forumid and playback.forumid == forumid)  then
		fileDelete( "ghosts/" .. playback.mapName .. ".ghost" )
		outputChatBox('Ghost record for ' .. playback.mapName .. ' deleted!', client, 255,0,0)
	elseif (forumid and newghostForumid == forumid)  then
		fileDelete( "ghosts/" .. newghostMapname .. ".ghost" )
		outputChatBox('Ghost record for ' .. newghostMapname .. ' deleted!', client, 255,0,0)
	else
		outputChatBox('You have no access to this ghost record!', client, 255,0,0)
	end
end)

function isMapTesting()
	return getResourceInfo(exports.mapmanager:getRunningGamemodeMap(), 'newupload') == "true"
end

addEvent( "onGhostDataReceive", true )
addEventHandler( "onGhostDataReceive", g_Root,
	function( recording, bestTime, racer, mapName )
		local forumid = exports.gc:getPlayerForumID(client)
		if isMapTesting() or not forumid then return end
		-- May be inaccurate, if recording is still being sent when map changes
		--[[local currentMap = exports.mapmanager:getRunningGamemodeMap()
		local mapName = getResourceName( currentMap )--]]
		
		-- Create a backup in case of a cheater run
		local ghost = xmlLoadFile( "ghosts/" .. mapName .. ".ghost" )
		if ghost then
			local info = xmlFindChild( ghost, "i", 0 )
			local currentBestTime = math.huge
			if info then
				currentBestTime = tonumber( xmlNodeGetAttribute( info, "t" ) ) or math.huge
			end

			if currentBestTime < bestTime then -- not a new record. Fix for issue #813
				xmlUnloadFile( ghost )
				outputDebugString("Received ghost data from " .. racer .. ". Time: " .. bestTime .. ". Current best time: " .. currentBestTime .. ". Ignoring.")
				return
			end
		
			-- if currentBestTime ~= math.huge and currentBestTime - bestTime >= SUSPECT_CHEATER_LIMIT then -- Cheater?
				outputDebug( "Creating a backup file for " .. mapName .. ".backup" )
				copyFile( "ghosts/" .. mapName .. ".ghost", "ghosts/" .. mapName .. ".backup" )
			-- end
			xmlUnloadFile( ghost )
		end
		
		local ghost = xmlCreateFile( "ghosts/" .. mapName .. ".ghost", "ghost" )
		if ghost then
			local info = xmlCreateChild( ghost, "i" )
			if info then
				xmlNodeSetAttribute( info, "r", tostring( racer ) )
				xmlNodeSetAttribute( info, "t", tostring( bestTime ) )
				xmlNodeSetAttribute( info, "timestamp", tostring( getRealTime().timestamp ) )
				xmlNodeSetAttribute( info, "forumid", tostring( forumid ) )
			end
		
			for _, info in ipairs( recording ) do
				local node = xmlCreateChild( ghost, "n" )
				for k, v in pairs( info ) do
					xmlNodeSetAttribute( node, tostring( k ), tostring( v ) )
				end
			end
			xmlSaveFile( ghost )
			xmlUnloadFile( ghost )
			outputChatBox("Congratulations, you made a new ghost record! Use /deleteghost if you want to remove it", client, 0,255,0)
			newghostForumid = forumid
			newghostMapname = mapName
		else
			outputDebug( "Failed to create a ghost file!" )
		end
	end
)