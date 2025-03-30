GhostPlaybackC = {}
GhostPlaybackC.__index = GhostPlaybackC

function GhostPlaybackC:create( map )
	local result = {
		map = map,
		bestTime = math.huge,
		racer = "",
		recording = {},
		hasGhost = false,
		ped = nil,
		vehicle = nil
		-- blip = nil
	}
	return setmetatable( result, self )
end

function GhostPlaybackC:getVar ( var )
	if (var == "map") then return self.map end
	if (var == "bestTime") then return self.bestTime end
	if (var == "racer") then return self.racer end
	if (var == "recording") then return self.recording end
	if (var == "hasGhost") then return self.hasGhost end
	if (var == "ped") then return self.ped end
	if (var == "vehicle") then return self.vehicle end
	return nil
end

function GhostPlaybackC:sendGhostData( playbackID )
	if self.hasGhost then
		triggerEvent( "onClientGhostDataReceive", root, toJSON(self.recording, true), self.bestTime, self.racer, self.ped, self.vehicle, playbackID )
	end	
end

function GhostPlaybackC:loadGhost(ghostResourceName, mapName)
	if not ghostResourceName then
		return
	end

	if fileExists(ghostResourceName) then
		local ghostFile = readGhostFile(ghostResourceName)

		if not ghostFile then
			outputDebug( "Invalid ghost file", mapName, nil )
			return false
		end

		local json
		if isLegacyGhost(ghostFile) then
			outputDebugString("Converting legacy ghost for map \"" .. mapName .. "\" ...")
			json = legacyConvert(ghostFile)

			-- Save legacy after converting
			saveLocalPBGhost(json.recording, json.bestTime, json.racer, mapName, false, true)
			outputDebugString("Legacy ghost converted and saved to new format!")
		else
			json = fromJSON(ghostFile)
		end

		if not json then
			-- Something went wrong loading the ghost file
			return
		end

		self.racer = json.racer
		self.bestTime = tonumber(json.bestTime) or math.huge
		self.recording = json.recording

		-- Validate
		local bValidForMap = isBesttimeValidForMap( self.map, self.bestTime )
		local bValidForRecording = isBesttimeValidForRecording( self.recording, self.bestTime )
		if not bValidForMap or not bValidForRecording then
			if not bValidForMap then
				outputDebug( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for map. Error: " .. getMapBesttimeError( self.map, self.bestTime ) .. ")" )
			end
			if not bValidForRecording then
				outputDebug( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
			end
			return false
		end

		-- Create the ped & vehicle
		for _, v in ipairs( self.recording ) do
			if v.ty == "st" then
				if g_GameOptions.validatespawn then				
					-- Check start is near a spawnpoint
					local bestDist = math.huge
					for _,spawnpoint in ipairs(getElementsByType("spawnpoint")) do
						bestDist = math.min( bestDist, getDistanceBetweenPoints3D( v.x, v.y, v.z, getElementPosition(spawnpoint) ) )
					end
					if bestDist > 5 then
						outputDebug( "Found an invalid ghost file", mapName, nil, " (Spawn point too far away - " .. bestDist .. ")" )
						return false
					end
				end
				self.ped = { p = v.p, x = v.x, y = v.y, z = v.z }
				self.vehicle = { m = v.m, x = v.x, y = v.y, z = v.z, rx = v.rX, ry = v.rY, rz = v.rZ }
				outputDebug( "Found a valid ghost", self.racer, nil, " (Besttime dif: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
				self.hasGhost = true
				return true
			end
		end
	else
		outputDebug( "No ghost file", mapName, nil )
		return false
	end
end

function GhostPlaybackC:loadGhost_Legacy(ghostResourceName, mapName)
	if not ghostResourceName then
		return
	end

	local ghost = xmlLoadFile( ghostResourceName )

	if ghost then
		-- Retrieve info about the ghost maker
		local info = xmlFindChild( ghost, "i", 0 )
		if info then
			self.racer = xmlNodeGetAttribute( info, "r" ) or "unknown"
			self.bestTime = tonumber( xmlNodeGetAttribute( info, "t" ) ) or math.huge
		end
		-- Construct a table
		local index = 0
		local node = xmlFindChild( ghost, "n", index )
		self.recording = {}
		while (node) do
			if type( node ) ~= "userdata" then
				outputDebug( "race_ghost - playback_server.lua: Invalid node data while loading ghost: " .. type( node ) .. ":" .. tostring( node ), 1 )
				break
			end

			local attributes = xmlNodeGetAttributes( node )
			local row = {}
			for k, v in pairs( attributes ) do
				row[k] = convert( v )
			end
			table.insert( self.recording, row )
			index = index + 1
			node = xmlFindChild( ghost, "n", index )
		end
		xmlUnloadFile( ghost )

		-- Validate
		local bValidForMap = isBesttimeValidForMap( self.map, self.bestTime )
		local bValidForRecording = isBesttimeValidForRecording( self.recording, self.bestTime )
		if not bValidForMap or not bValidForRecording then
			if not bValidForMap then
				outputDebug( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for map. Error: " .. getMapBesttimeError( self.map, self.bestTime ) .. ")" )
			end
			if not bValidForRecording then
				outputDebug( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
			end
			return false
		end

		-- Create the ped & vehicle
		for _, v in ipairs( self.recording ) do
			if v.ty == "st" then
				if g_GameOptions.validatespawn then				
					-- Check start is near a spawnpoint
					local bestDist = math.huge
					for _,spawnpoint in ipairs(getElementsByType("spawnpoint")) do
						bestDist = math.min( bestDist, getDistanceBetweenPoints3D( v.x, v.y, v.z, getElementPosition(spawnpoint) ) )
					end
					if bestDist > 5 then
						outputDebug( "Found an invalid ghost file", mapName, nil, " (Spawn point too far away - " .. bestDist .. ")" )
						return false
					end
				end
				self.ped = { p = v.p, x = v.x, y = v.y, z = v.z }
				self.vehicle = { m = v.m, x = v.x, y = v.y, z = v.z, rx = v.rX, ry = v.rY, rz = v.rZ }
				outputDebug( "Found a valid ghost", self.racer, nil, " (Besttime dif: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
				self.hasGhost = true
				return true
			end
		end
	end
	outputDebug( "No ghost file", mapName, nil )
	return false
end

---Get the ghost file path for a map name
---@param mapName string The map name as a string
---@param private? boolean Load from private folder (true by default)
---@return string
function getGhostFilePath(mapName, private)
    -- Ensure private defaults to true if omitted or invalid
    if private == nil or type(private) ~= "boolean" then
        private = true
    end

	local filePath = "ghosts/" .. mapName .. "_" .. removeColorCoding( getPlayerName(localPlayer)):gsub('[%p%c%s]', '') .. "_PB.ghost"
	if private then
		filePath = "@" .. filePath
	end

	return filePath
end

function loadLocalPBGhost(mapInfo)
	if (NO_GHOST) then
		NO_GHOST = false
		return
	end

	local mapName = mapInfo.resname
	pbPlayback = GhostPlaybackC:create( mapName )

	-- outputDebugString("Trying to load ghost from private storage...")
	local pbGhost = pbPlayback:loadGhost(getGhostFilePath(mapName), mapName)
	if not pbGhost then
		-- Try to load and convert a legacy ghost
		-- outputDebugString("Trying to load ghost from public storage...")
		pbGhost = pbPlayback:loadGhost(getGhostFilePath(mapName, false), mapName)

		if not pbGhost then
			-- No legacy ghost either? Request it from the server.
			-- outputDebugString("Requesting ghost from server...")
			triggerServerEvent("onClientRequestPBGhost", localPlayer, mapName)
			return
		else
			-- Do another save in case the ghost was loaded but was already in JSON format
			saveLocalPBGhost(pbPlayback.recording, pbPlayback.bestTime, pbPlayback.racer, mapName, false, true)
		end
	end

	if (globalInfo.personalBest > pbPlayback.bestTime) then
		globalInfo.personalBest = pbPlayback.bestTime
		pbPlayback:sendGhostData("PB")
	end
end

addEvent("onServerSentPBGhost",true)
addEventHandler( "onServerSentPBGhost", root, 
	function(receivedXml, mapName)
		-- 
		local filePath = getGhostFilePath(mapName)
		local file = fileCreate(filePath)
		if (file) then
			fileWrite(file, receivedXml)
			fileClose(file)
			pbPlayback = GhostPlaybackC:create( mapName )
			local pbGhost = pbPlayback:loadGhost(filePath)
			if (pbGhost) then
				globalInfo.personalBest = pbPlayback.bestTime
				if (globalInfo.personalBest ~= globalInfo.bestTime) then
					pbPlayback:sendGhostData("PB")
				end
			end
		end
	end
)

---------------------------------------------------------------------------
--
-- Save
--
--
--
---------------------------------------------------------------------------

function saveLocalPBGhost ( recording, bestTime, racer, mapName, top, pb )
	if (not pb) then return end
	
	if not isBesttimeValidForRecording( recording, bestTime ) then
		-- outputDebugServer( "Client Local Storage: Invalid ghost recording", mapName, racer, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( recording, bestTime ) .. ")" )
		return
	end

	-- outputDebugServer( "Client Local Storage: Saving ghost file", mapName, racer, " (Besttime dif: " .. getRecordingBesttimeError( recording, bestTime ) .. ")" )

	local filePath = getGhostFilePath(mapName)
	-- local fileName = "@ghosts/" .. mapName .. "_" .. racer:gsub('[%p%c%s]', '') .. "_PB.ghost"

	local saveJSON = {
		racer = racer,
		bestTime = bestTime,
		recording = recording
	}

	if not saveGhostFile(filePath, saveJSON) then
		outputDebug( "Client Local Storage: Failed to create a ghost file!" )
	end
end

function saveLocalPBGhost_Legacy ( recording, bestTime, racer, mapName, top, pb )
	-- Early return
	if true then
		outputDebugString("Called deprecated method \"saveLocalPBGhost_Legacy\"")
		return
	end

	if (not pb) then return end
	
	if not isBesttimeValidForRecording( recording, bestTime ) then
		-- outputDebugServer( "Client Local Storage: Invalid ghost recording", mapName, racer, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( recording, bestTime ) .. ")" )
		return
	end

	-- outputDebugServer( "Client Local Storage: Saving ghost file", mapName, racer, " (Besttime dif: " .. getRecordingBesttimeError( recording, bestTime ) .. ")" )

	local fileName = "ghosts/" .. mapName .. "_" .. racer:gsub('[%p%c%s]', '') .. "_PB.ghost"
	ghost = xmlCreateFile( fileName, "ghost" )
	if ghost then
		local info = xmlCreateChild( ghost, "i" )
		if info then
			xmlNodeSetAttribute( info, "r", tostring( racer ) )
			xmlNodeSetAttribute( info, "t", tostring( bestTime ) )
		end

		for _, info2 in ipairs( recording ) do
			local node = xmlCreateChild( ghost, "n" )
			for k, v in pairs( info2 ) do
				if type(v) == "number" then
					xmlNodeSetAttribute( node, tostring( k ), math.floor(v * 10000 + 0.5) / 10000 )
				else
					xmlNodeSetAttribute( node, tostring( k ), tostring( v ) )
				end
			end
		end
		xmlSaveFile( ghost )
		xmlUnloadFile( ghost )
	else
		outputDebug( "Client Local Storage: Failed to create a ghost file!" )
	end

end



---------------------------------------------------------------------------
--
-- Recording validation
--
--
--
---------------------------------------------------------------------------

-- Check the best time is after the last recorded item time, but not too far afterwards
function isBesttimeValidForRecording( recording, bestTime )
	if not g_GameOptions.validatetime then return true end
	local terror = getRecordingBesttimeError( recording, bestTime )
	return terror >= -2000 and terror < 2000
end

function getRecordingBesttimeError( recording, bestTime )
	-- get time of last item
	local t
	for idx = #recording,1,-1 do
		local v = recording[idx]
		t = tonumber(v.t)
		if t then
			break
		end
	end
	-- Calc error
	if t then
		return bestTime - t
	end
	return math.huge
end


-- Check the best time is not (much) less than the map toptime
function isBesttimeValidForMap( map, bestTime )
	if not g_GameOptions.validatetime then return true end
	local terror = getMapBesttimeError( map, bestTime )
	outputDebug ( "isBesttimeValidForMap dif:" .. tostring(terror) )
	return terror >= -1000
end

function getMapBesttimeError( map, bestTime )
	-- -- get time of map top time
	-- local t
	-- local mapName = getResourceInfo(map, "name") or getResourceName(map)
	-- local tableName = 'race maptimes Sprint ' .. mapName
	-- local res = executeSQLQuery( "SELECT * from ? WHERE rowid=1", tableName )
	-- if res and #res >= 1 then
	-- 	t = tonumber(res[1]["timeMs"])
	-- end

	-- -- Calc error
	-- if t then
	-- 	return bestTime - t
	-- end
	-- outputDebugString ( "ghost_racer: getMapBesttimeError - Can't find toptime for " .. tostring(mapName) )
	return 0
end

function convert( value )
	if tonumber( value ) ~= nil then
		return tonumber( value )
	else
		if tostring( value ) == "true" then
			return true
		elseif tostring( value ) == "false" then
			return false
		else
			return tostring( value )
		end
	end
end


----------------------------------------------------------------------------
---------------- Deletion and Renomination ---------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------

function ClientRenameGhost(old, new)
	if (fileExists(old)) then
		iprint("[Race Ghost C] Renaming locally stored ghost "..old.." to "..new)
		outputConsole("[Race Ghost C] Renaming locally stored ghost "..old.." to "..new)
		fileRename(old, new)
	end
end

addEvent("OnRequestClientRenameLocalGhost")
addEvent("OnRequestClientDeleteLocalGhost")
addEventHandler( "OnRequestClientRenameLocalGhost", root, 
	function(ghostToRename, newName)
		ClientRenameGhost(ghostToRename, newName)
	end
)
addEventHandler( "OnRequestClientDeleteLocalGhost", root, 
	function(ghostToDelete)
		ClientRenameGhost(ghostToDelete, ghostToDelete..".old")
	end
)

