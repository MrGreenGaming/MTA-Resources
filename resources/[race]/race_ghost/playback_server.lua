
addEvent"onMapStarting"

GhostPlayback = {}
GhostPlayback.__index = GhostPlayback

GhostFileNames = {}
GhostFileNamesCount = 0
UsedGhosts = {}
TopPlayback = nil

function GhostPlayback:create( map )
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

function GhostPlayback:destroy()
	if self.hasGhost then
		triggerClientEvent( "clearMapGhost", root )
	end
	self.ped = nil
	self.vehicle = nil
end

function GhostPlayback:deleteGhost()
	local mapName = getResourceName( self.map )
	-- if fileExists( "ghosts/" .. mapName .. ".ghost" ) then
	-- 	fileDelete( "ghosts/" .. mapName .. ".ghost" )
	-- 	self:destroy()
	-- 	playback = nil
	-- 	return true
	-- end
	return false
end

function getGhostsForMap(map)
	local runs = {}
	local mapName = getResourceName( map )
	local toc = xmlLoadFile("ghosts/" .. mapName .. ".toc")
	-- Look for a table of contents. If it doesn't exist, make it
	if not toc then 
		-- Look for old file (backwards compatibility)
		local fileName = "ghosts/" .. mapName .. ".ghost"
		local old = xmlLoadFile( fileName )
		if not old then
			-- Look for .backup instead
			fileName = "ghosts/" .. mapName .. ".backup"
			local old = xmlLoadFile( fileName )
		end
		if old then
			-- Found old file, write it to a new table of contents
			xmlUnloadFile( old )

			toc = xmlCreateFile( "ghosts/" .. mapName .. ".toc", "toc")
			if toc then
				local top = xmlCreateChild( toc, "top" )
				if (top) then
					xmlNodeSetAttribute( top, "f", fileName)
				end	
				xmlSaveFile( toc )
			end
			runs["top"] = fileName
			xmlUnloadFile( toc )
		end
		return runs
	end
	-- toc exists. Read it
	local nodes = xmlNodeGetChildren(toc)
	for i,v in ipairs(nodes) do
		runs[xmlNodeGetName(v)] = xmlNodeGetAttribute(v, "f")
	end
	xmlUnloadFile( toc )
	return runs
end

function GhostPlayback:loadGhost(ghostResourceName, mapName)
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
			json = legacyConvert(ghostFile)

			-- Save legacy after converting
			saveGhostFile(ghostResourceName, json)
		else
			json = fromJSON(ghostFile)
		end

		self.racer = json.racer
		self.bestTime = tonumber(json.bestTime) or math.huge
		self.recording = json.recording

		-- Validate
		local bValidForMap = isBesttimeValidForMap( self.map, self.bestTime )
		local bValidForRecording = isBesttimeValidForRecording( self.recording, self.bestTime )
		if not bValidForMap or not bValidForRecording then

			-- TODO: Erase the time from the toc

			-- -- Use backup file if it exists
			-- local backup = xmlLoadFile( "ghosts/" .. mapName .. ".backup" )
			-- if backup then
			-- 	xmlUnloadFile( backup )
			-- 	copyFile( "ghosts/" .. mapName .. ".ghost", "ghosts/" .. mapName .. ".invalid" )
			-- 	copyFile( "ghosts/" .. mapName .. ".backup", "ghosts/" .. mapName .. ".ghost" )
			-- 	fileDelete( "ghosts/" .. mapName .. ".backup" )
			-- 	outputDebugServer( "Trying backup as found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
			-- 	self.recording = {}
			-- 	return self:loadGhost()
			-- end
			if not bValidForMap then
				outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for map. Error: " .. getMapBesttimeError( self.map, self.bestTime ) .. ")" )
			end
			if not bValidForRecording then
				outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
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
					-- if bestDist > 5 then
					-- 	for _,spawnpoint in ipairs(getElementsByType("spawnpoint_onfoot")) do
					-- 		bestDist = math.min( bestDist, getDistanceBetweenPoints3D( v.x, v.y, v.z, getElementPosition(spawnpoint) ) )
					-- 	end
					-- end
					if bestDist > 5 then
						outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Spawn point too far away - " .. bestDist .. ")" )
						return false
					end
				end
				self.ped = { p = v.p, x = v.x, y = v.y, z = v.z }
				self.vehicle = { m = v.m, x = v.x, y = v.y, z = v.z, rx = v.rX, ry = v.rY, rz = v.rZ }
				outputDebugServer( "Found a valid ghost", self.racer, nil, " (Besttime dif: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
				self.hasGhost = true
				return true
			end
		end
	end

	outputDebugServer( "No ghost file", mapName, nil )
	return false
end

function GhostPlayback:loadGhost_Legacy(ghostResourceName, mapName)
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
				outputDebugString( "race_ghost - playback_server.lua: Invalid node data while loading ghost: " .. type( node ) .. ":" .. tostring( node ), 1 )
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

			-- TODO: Erase the time from the toc

			-- -- Use backup file if it exists
			-- local backup = xmlLoadFile( "ghosts/" .. mapName .. ".backup" )
			-- if backup then
			-- 	xmlUnloadFile( backup )
			-- 	copyFile( "ghosts/" .. mapName .. ".ghost", "ghosts/" .. mapName .. ".invalid" )
			-- 	copyFile( "ghosts/" .. mapName .. ".backup", "ghosts/" .. mapName .. ".ghost" )
			-- 	fileDelete( "ghosts/" .. mapName .. ".backup" )
			-- 	outputDebugServer( "Trying backup as found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
			-- 	self.recording = {}
			-- 	return self:loadGhost()
			-- end
			if not bValidForMap then
				outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for map. Error: " .. getMapBesttimeError( self.map, self.bestTime ) .. ")" )
			end
			if not bValidForRecording then
				outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
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
					-- if bestDist > 5 then
					-- 	for _,spawnpoint in ipairs(getElementsByType("spawnpoint_onfoot")) do
					-- 		bestDist = math.min( bestDist, getDistanceBetweenPoints3D( v.x, v.y, v.z, getElementPosition(spawnpoint) ) )
					-- 	end
					-- end
					if bestDist > 5 then
						outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Spawn point too far away - " .. bestDist .. ")" )
						return false
					end
				end
				self.ped = { p = v.p, x = v.x, y = v.y, z = v.z }
				self.vehicle = { m = v.m, x = v.x, y = v.y, z = v.z, rx = v.rX, ry = v.rY, rz = v.rZ }
				outputDebugServer( "Found a valid ghost", self.racer, nil, " (Besttime dif: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
				self.hasGhost = true
				return true
			end
		end
	end
	outputDebugServer( "No ghost file", mapName, nil )
	return false
end

function GhostPlayback:sendGhostData( target, playbackID )
	if self.hasGhost then
		triggerClientEvent( target or root, "onClientGhostDataReceive", root, toJSON(self.recording, true), self.bestTime, self.racer, self.ped, self.vehicle, playbackID )
	end
end

addEventHandler( "onMapStarting", root,
	function()
		GhostPlayers = 0
		ReportedPlayers = 0
		TotalPlayers = #getElementsByType("player")

		if TopPlayback then
			TopPlayback:destroy()
		end
		if (personalPlaybacks) then
			for _, v in pairs(personalPlaybacks) do
				v:destroy()
			end
		end
		if (extraPlaybacks) then
			for _, v in pairs (extraPlaybacks) do
				v:destroy()
			end
		end

		local mapName = exports.mapmanager:getRunningGamemodeMap()

		if (get("*" .. getResourceName( mapName ) .. ".disableraceghosts")) then
			triggerClientEvent( "disableGhostsForThisMap", root )
			return
		end

		GhostFileNames = getGhostsForMap(mapName)
		GhostFileNamesCount = 0
		for _,_ in pairs(GhostFileNames) do
			GhostFileNamesCount = GhostFileNamesCount + 1
		end
		UsedGhosts = {}

		tickCount = getTickCount()
		tickCount2 = tickCount
		tickCountDiff = 0

		local topFileName = GhostFileNames["top"]
		local topGhost = nil

		-- The original WR ghost
		TopPlayback = GhostPlayback:create( mapName )
		topFileName = GhostFileNames["top"]
		topGhost = TopPlayback:loadGhost(topFileName, getResourceName(mapName))
		for i, v in pairs(GhostFileNames) do
			-- Remove duplicate entries (PBs)
			if i ~= "top" and v == GhostFileNames["top"] then
				UsedGhosts[i] = v
				GhostFileNames[i] = nil
				GhostFileNamesCount = GhostFileNamesCount - 1
			end
		end
		GhostFileNames["top"] = nil
		GhostFileNamesCount = GhostFileNamesCount - 1

		tickCount2 = getTickCount()
		tickCountDiff = tickCount2 - tickCount
		-- iprint(tickCountDiff .. " ms | Top ghost loaded")
		tickCount = tickCount2
		
		local extraPlaybacks = {}
		local extraPlaybackCount = g_GameOptions.fillplayerslots - #getElementsByType("player")
		while (extraPlaybackCount > 0 and GhostFileNamesCount > 0) do
			local xRandom = math.random(1, GhostFileNamesCount)
			local xCount = 0
			for i, v in pairs(GhostFileNames) do
				xCount = xCount + 1
				if (xCount == xRandom) then
					local xGhost = GhostPlayback:create( mapName )
					xGhost:loadGhost(v)
					table.insert(extraPlaybacks, xGhost)
					extraPlaybackCount = extraPlaybackCount - 1
					UsedGhosts[i] = v
					GhostFileNames[i] = nil
					GhostFileNamesCount = GhostFileNamesCount - 1
					break
				end
			end
		end

		tickCount2 = getTickCount()
		tickCountDiff = tickCount2 - tickCount
		-- iprint(tickCountDiff .. " ms | " .. #extraPlaybacks .. " Extra ghosts loaded")
		tickCount = tickCount2

		-- Send all ghosts to all players
		for i, v in pairs(getElementsByType("player")) do
			TopPlayback:sendGhostData(v, "Top")
			local ghostNumber = 1
			for j, w in pairs (extraPlaybacks) do
				w:sendGhostData(v, ghostNumber)
				ghostNumber = ghostNumber + 1
			end
		end

		tickCount2 = getTickCount()
		tickCountDiff = tickCount2 - tickCount
		-- iprint(tickCountDiff .. " ms | Ghosts sent to clients")
		tickCount = tickCount2
	end
)

addEvent("onClientRequestPBGhost", true)
addEventHandler( "onClientRequestPBGhost", root, 
	function(mapName)
		local pName = removeColorCoding(getPlayerName(source))
		local pIndex = "pb_" .. pName:gsub('[%p%c%s]', '')
		local pFile = GhostFileNames[pIndex] or UsedGhosts[pIndex]
		if (not pFile) then return end
		local ghostFile = fileOpen(pFile)
		local ghostXml = fileRead(ghostFile, fileGetSize(ghostFile))
		triggerClientEvent(source, "onServerSentPBGhost", resourceRoot, ghostXml, mapName)
		fileClose(ghostFile)

		tickCount2 = getTickCount()
		tickCountDiff = tickCount2 - tickCount
		-- iprint(tickCountDiff .. " ms | PB ghost loaded and sent to " .. pName)
		tickCount = tickCount2
	end
)

-- 	-- Find PB ghosts for each player
-- 	local ghostsFound = {}
-- 	for i, v in pairs(getElementsByType("player")) do
-- 		local vName = removeColorCoding((getPlayerName(v)))
-- 		local vGhost = GhostPlayback:create( mapName )
-- 		local vFile = "pb_" .. vName:gsub('[%p%c%s]', '')
-- 		if (ghostFileNames[vFile]) then
-- 			-- vGhost:loadGhost(ghostFileNames[vFile])
-- 			ghostsFound[v] = vFile
-- 			-- ghostsCount = ghostsCount + 1
-- 			-- ghostFileNames[vFile] = nil
-- 		end
-- 	end
-- 	return ghostsFound

addEventHandler( "onPlayerJoin", root,
	function()
		triggerClientEvent( source, "race_ghost.updateOptions", resourceRoot, g_GameOptions ); -- We need to send server settings first or it's going to throw errors
		if TopPlayback then
			TopPlayback:sendGhostData( source )
		end
		if personalPlayback then
			vName = removeColorCoding((getPlayerName(source)))
			personalPlayback:loadGhost("pb_" .. vName:gsub('[%p%c%s]', ''))
			personalPlayback:sendGhostData(source, "pb")   
		end
	end
)

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
