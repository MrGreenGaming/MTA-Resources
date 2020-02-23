LocalGhostPlayback = {}
LocalGhostPlayback.__index = LocalGhostPlayback

local localPlaybackEnabled = true
addCommandHandler('localghost', function()
	localPlaybackEnabled = not localPlaybackEnabled
end)

addEvent'localghost'
addEventHandler('localghost', root, function(b)
	localPlaybackEnabled = not not b
end)

addEventHandler( "onClientMapStarting", g_Root,
	function ( mapInfo )
		globalInfo.bestLocalTime = math.huge
		if localplayback then
			localplayback:destroy()
		end
		
		-- Check if the map is actually a racing map
		if localPlaybackEnabled and modes[mapInfo.modename] then
			localplayback = LocalGhostPlayback:create( mapInfo.resname )
			if localplayback then
				localplayback:preparePlayback()
			end
		end
	end
)

function LocalGhostPlayback:create( mapName )
	local ped, vehicle, recording = self:loadGhost(mapName)
	if not (ped and vehicle and recording) then return false end
	local result = {
		ped = ped,
		vehicle = vehicle,
		recording = recording,
		isPlaying = false,
		startTick = nil,
	}
	setElementCollisionsEnabled( result.ped, false )
	setElementCollisionsEnabled( result.vehicle, false )
	setElementFrozen( result.vehicle, true )
	setElementAlpha( result.ped, 100 )
	setElementAlpha( result.vehicle, 100 )
	return setmetatable( result, self )
end

function LocalGhostPlayback:loadGhost(mapName)
	-- Load the old ghost if there is one
	local ghost = xmlLoadFile( "ghosts/" .. mapName .. ".ghost" )
	
	if ghost then
		-- Retrieve info about the ghost maker
		local info = xmlFindChild( ghost, "i", 0 )
		if info then
			globalInfo.bestLocalTime = tonumber( xmlNodeGetAttribute( info, "t" ) ) or math.huge
		end
		
		-- Construct a table
		local index = 0
		local node = xmlFindChild( ghost, "n", index )
		local recording = {}
		while (node) do
			if type( node ) ~= "userdata" then
				outputDebugString( "race_ghost - playback_local_client.lua: Invalid node data while loading ghost: " .. type( node ) .. ":" .. tostring( node ), 1 )
				break
			end
			
			local attributes = xmlNodeGetAttributes( node )
			local row = {}
			for k, v in pairs( attributes ) do
				row[k] = convert( v )
			end
			table.insert( recording, row )
			index = index + 1
			node = xmlFindChild( ghost, "n", index )
		end
		xmlUnloadFile( ghost )
			
		-- Create the ped & vehicle
		local ped, vehicle, blip
		for _, v in ipairs( recording ) do
			if v.ty == "st" then
				ped = createPed( v.p, v.x, v.y, v.z )
				vehicle = createVehicle( v.m, v.x, v.y, v.z, v.rX, v.rY, v.rZ )
				setElementData(vehicle, "race.isGhostVehicle", true)
				blip = createBlipAttachedTo( ped, 0, 1, 150, 150, 150, 50 )
				setElementParent( blip, ped )
				warpPedIntoVehicle( ped, vehicle )
				
				outputDebug( "Found a valid local ghost file for " .. mapName )
				-- self.hasGhost = true
				return ped, vehicle, recording
			end
		end
		return false
	end
	return false
end

function LocalGhostPlayback:destroy( finished )
	self:stopPlayback( finished )
	if self.checkForCountdownEnd_HANDLER then removeEventHandler( "onClientRender", g_Root, self.checkForCountdownEnd_HANDLER ) self.checkForCountdownEnd_HANDLER = nil end
	if self.updateGhostState_HANDLER then removeEventHandler( "onClientRender", g_Root, self.updateGhostState_HANDLER ) self.updateGhostState_HANDLER = nil end
	if isTimer( self.ghostFinishTimer ) then
		killTimer( self.ghostFinishTimer )
		self.ghostFinishTimer = nil
	end
	if isElement( self.ped ) then
		destroyElement( self.ped )
		-- outputDebug( "Destroyed ped." )
	end
	if isElement( self.vehicle ) then
		destroyElement( self.vehicle )
		-- outputDebug( "Destroyed vehicle." )
	end
	if isElement( self.blip ) then
		destroyElement( self.blip )
		-- outputDebug( "Destroyed blip." )
	end
	self = nil
end

function LocalGhostPlayback:preparePlayback()
	self.checkForCountdownEnd_HANDLER = function() self:checkForCountdownEnd() end
	addEventHandler( "onClientRender", g_Root, self.checkForCountdownEnd_HANDLER )
	self:createNametag()
end

function LocalGhostPlayback:createNametag()
	self.nametagInfo = {
		name = "My ghost (" .. removeColorCoding(getPlayerName(localPlayer)) .. ")",
		time = msToTimeStr( globalInfo.bestLocalTime )
	}
	self.drawGhostNametag_HANDLER = function() self:drawGhostNametag( self.nametagInfo ) end
	addEventHandler( "onClientRender", g_Root, self.drawGhostNametag_HANDLER )
end

function LocalGhostPlayback:destroyNametag()
	if self.drawGhostNametag_HANDLER then removeEventHandler( "onClientRender", g_Root, self.drawGhostNametag_HANDLER ) self.drawGhostNametag_HANDLER = nil end
end

function LocalGhostPlayback:checkForCountdownEnd()
	local vehicle = getPedOccupiedVehicle( getLocalPlayer() )
	if vehicle then
		local frozen = isElementFrozen( vehicle )
		if not frozen then
			-- outputDebug( "Playback started." )
			setElementFrozen( self.vehicle, false )
			if self.checkForCountdownEnd_HANDLER then removeEventHandler( "onClientRender", g_Root, self.checkForCountdownEnd_HANDLER ) self.checkForCountdownEnd_HANDLER = nil end
			self:startPlayback()
		end
	end
end

function LocalGhostPlayback:startPlayback()
	self.startTick = getTickCount()
	self.isPlaying = true
	self.updateGhostState_HANDLER = function() self:updateGhostState() end
	addEventHandler( "onClientRender", g_Root, self.updateGhostState_HANDLER )
end

function LocalGhostPlayback:stopPlayback( finished )
	self:destroyNametag()
	self:resetKeyStates()
	self.isPlaying = false
	if self.updateGhostState_HANDLER then removeEventHandler( "onClientRender", g_Root, self.updateGhostState_HANDLER ) self.updateGhostState_HANDLER = nil end
	if finished then
		self.ghostFinishTimer = setTimer(
			function()
				local blip = getBlipAttachedTo( self.ped )
				if blip then
					setBlipColor( blip, 0, 0, 0, 0 )
				end
				setElementPosition( self.vehicle, 0, 0, 0 )
				setElementFrozen( self.vehicle, true )
				setElementAlpha( self.vehicle, 0 )
				setElementAlpha( self.ped, 0 )
			end, 5000, 1
		)
	end
end

function LocalGhostPlayback:updateGhostState()
	self.currentIndex = self.currentIndex or 1
	local ticks = getTickCount() - self.startTick
	setElementHealth( self.ped, 100 ) -- we don't want the ped to die
	while (self.recording[self.currentIndex] and self.recording[self.currentIndex].t < ticks) do
		local theType = self.recording[self.currentIndex].ty
		if theType == "st" then
			-- Skip
		elseif theType == "po" then
			local x, y, z = self.recording[self.currentIndex].x, self.recording[self.currentIndex].y, self.recording[self.currentIndex].z
			local rX, rY, rZ = self.recording[self.currentIndex].rX, self.recording[self.currentIndex].rY, self.recording[self.currentIndex].rZ
			local vX, vY, vZ = self.recording[self.currentIndex].vX, self.recording[self.currentIndex].vY, self.recording[self.currentIndex].vZ
			local lg = self.recording[self.currentIndex].lg
			local health = self.recording[self.currentIndex].h or 1000
			setElementPosition( self.vehicle, x, y, z )
			setElementRotation( self.vehicle, rX, rY, rZ )
			setElementVelocity( self.vehicle, vX, vY, vZ )
			setElementHealth( self.vehicle, health )
			if lg then setVehicleLandingGearDown( self.vehicle, lg ) end
		elseif theType == "k" then
			local control = self.recording[self.currentIndex].k
			local state = self.recording[self.currentIndex].s
			setPedControlState( self.ped, control, state )
		elseif theType == "pi" then
			local item = self.recording[self.currentIndex].i
			if item == "n" then
				addVehicleUpgrade( self.vehicle, 1010 )
			elseif item == "r" then
				fixVehicle( self.vehicle )
			end
		elseif theType == "sp" then
			fixVehicle( self.vehicle )
		elseif theType == "v" then
			local vehicleType = self.recording[self.currentIndex].m
			setElementModel( self.vehicle, vehicleType )
		end
		self.currentIndex = self.currentIndex + 1
		
		if not self.recording[self.currentIndex] then
			self:stopPlayback( true )
		end
	end
end

function LocalGhostPlayback:resetKeyStates()
	if isElement( self.ped ) then
		for _, v in ipairs( keyNames ) do
			setPedControlState( self.ped, v, false )
		end
	end
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
