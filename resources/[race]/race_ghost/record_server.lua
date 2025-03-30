addEvent( "onGhostDataReceive", true )

function isMapTesting()
	return getResourceInfo(exports.mapmanager:getRunningGamemodeMap(), 'newupload') == "true"
end

addEventHandler( "onGhostDataReceive", root,
	function( recording, bestTime, racer, mapName, top, pb )
		if bestTime > g_GameOptions.maxghosttime then
			return
		end

		local forumid = exports.gc:getPlayerForumID(client)
		if isMapTesting() or not forumid then return end

		-- if (top == true) then
		-- 	iprint("[Race Ghost S] Received a new TOP ghost. Data: ", bestTime, racer, mapName, top, pb)
		-- end

		recording = fromJSON(recording)

		if not isBesttimeValidForRecording( recording, bestTime ) then
			outputDebugServer( "Received an invalid ghost recording", mapName, racer, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( recording, bestTime ) .. ")" )
			return
		end

		outputDebugServer( "Saving ghost file", mapName, racer, " (Besttime dif: " .. getRecordingBesttimeError( recording, bestTime ) .. ")" )

		local fileName = "ghosts/" .. mapName .. "_" .. racer:gsub('[%p%c%s]', '') .. "_" .. tostring( bestTime ) .. ".ghost"
		local file = fileCreate(fileName)
		if file then
			local saveJSON = {
				racer = racer,
				bestTime = bestTime,
				recording = recording,
				forumid = forumid,
			}

			fileWrite(file, toJSON(saveJSON, true))
			fileClose(file)
		else
			outputDebug( "Client Local Storage: Failed to create a ghost file!" )
		end
		-- Legacy code to write to XML. Let's not...
		-- ghost = xmlCreateFile( fileName, "ghost" )
		-- if ghost then
		-- 	local info = xmlCreateChild( ghost, "i" )
		-- 	if info then
		-- 		xmlNodeSetAttribute( info, "r", tostring( racer ) )
		-- 		xmlNodeSetAttribute( info, "t", tostring( bestTime ) )
		-- 	end

		-- 	for _, info2 in ipairs( recording ) do
		-- 		local node = xmlCreateChild( ghost, "n" )
		-- 		for k, v in pairs( info2 ) do
		-- 			if type(v) == "number" then
		-- 				xmlNodeSetAttribute( node, tostring( k ), math.floor(v * 10000 + 0.5) / 10000 )
		-- 			else
		-- 				xmlNodeSetAttribute( node, tostring( k ), tostring( v ) )
		-- 			end
		-- 		end
		-- 	end
		-- 	xmlSaveFile( ghost )
		-- 	xmlUnloadFile( ghost )
		-- else
		-- 	outputDebug( "Failed to create a ghost file!" )
		-- end

		if (not top and not pb) then return end

		local toc = xmlLoadFile( "ghosts/" .. mapName .. ".toc", "toc")
		if not toc then
			toc = xmlCreateFile( "ghosts/" .. mapName .. ".toc", "toc")
		end

		if toc then
			if top then
				local topNode = xmlFindChild( toc, "top", 0 )
				if not topNode then
					topNode = xmlCreateChild( toc, "top" )
				end
				if (topNode) then
					xmlNodeSetAttribute( topNode, "f", tostring( fileName ))
				end
			end
			if pb then
				local pbNode = xmlFindChild( toc, "pb_" .. racer:gsub('[%p%c%s]', ''), 0 )
				if not pbNode then
					pbNode = xmlCreateChild( toc, "pb_" .. racer:gsub('[%p%c%s]', '') )
				end
				if (pbNode) then
					xmlNodeSetAttribute( pbNode, "f", tostring( fileName ))
				end
			end
			xmlSaveFile(toc)
			xmlUnloadFile(toc)
		else
			outputDebug( "Failed to create toc file!" )
		end
	end
)
