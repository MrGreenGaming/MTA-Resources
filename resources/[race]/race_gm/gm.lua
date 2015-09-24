local firstCheckpoint = 3
local warnCheckpoint = 4
changeCheckpoint = 5
local useCPGM = false
local newGMCheckpoint
local modes = {}
modes['Sprint'] = true
modes['Never the same'] = true


local DDGhostModeStartTime = 10 -- seconds


function onMapStarting( mapInfo, mapOptions, gameOptions )
	-- Only use gm in allowed modes
	if (not modes[exports.race:getRaceMode()]) then
		return false;
	end
	
	-- Default values, set all players into ghostmode before the start
	firstCheckpoint = 3
	warnCheckpoint = 4
	changeCheckpoint = 5
	for i, plr in ipairs( getElementsByType( "player" ) ) do
		setElementData( plr, "overrideCollide.uniqueblah", 0, false )
		setElementData( plr, "overrideAlpha.uniqueblah", 180, false )
		triggerClientEvent( source, "drawSign", root, false)
	end
	useCPGM = false
	
	-- Check if the map has a new ghostmode checkpoint defined
	local map = exports.mapmanager:getRunningGamemodeMap()
	newGMCheckpoint = tonumber(get(getResourceName(map) .. '.ghostmode_checkpoint'))
	if newGMCheckpoint then
		firstCheckpoint = newGMCheckpoint - 2
		warnCheckpoint = newGMCheckpoint - 1
		changeCheckpoint = newGMCheckpoint
		exports.messages:outputGameMessage("Ghostmode goes off at checkpoint: "..tostring(newGMCheckpoint), root, 2, 255, 0, 0, true)
	end

	-- Will players revert to non-GM
	useCPGM = (#getElementsByType('checkpoint') > (newGMCheckpoint or 5)) and (not mapOptions['ghostmode'])
end
addEvent( "onMapStarting" )
addEventHandler( "onMapStarting", root, onMapStarting)

function onPlayerJoin()
	-- Only use gm in allowed modes
	if (not modes[exports.race:getRaceMode()]) then
		return false;
	end

	-- set player into ghostmode before the start
	setElementData( source, "overrideCollide.uniqueblah", 0, false )
	setElementData( source, "overrideAlpha.uniqueblah", 180, false )
end
addEventHandler( "onPlayerJoin", root, onPlayerJoin)

function onPlayerReachCheckpoint(cp)
	if not useCPGM then
		-- No need to check for changes
		return
	end
	if cp == firstCheckpoint then
		-- Warn the player that gm will be disabled and start drawing the ghostmode sign
		exports.messages:outputGameMessage("Ghostmode will be disabled after 2 checkpoints", source,2, 50, 202, 50, true)
		local checkpoints = getElementsByType("checkpoint")
		local x, y, z
		if checkpoints and checkpoints[changeCheckpoint] then
			x, y, z = getElementPosition(checkpoints[changeCheckpoint])
			if z then
				triggerClientEvent(source, "drawSign", root, true, x, y, z )
			end
		end
		
	elseif cp == warnCheckpoint then
		-- Warn the player again
		exports.messages:outputGameMessage("Ghostmode will be disabled after the next checkpoint when nobody is around you.", source,1.5, 255, 255, 0, true)
	elseif cp == changeCheckpoint then
		-- Trigger the client checking before ghostmode can be disabled and stop drawing the sign
		triggerClientEvent( source, 'checkGmCanWorkOk', root)
		triggerClientEvent( source, "drawSign", root, false)
	end
end	
addEvent( "onPlayerReachCheckpoint", true)
addEventHandler( "onPlayerReachCheckpoint", root, onPlayerReachCheckpoint)	


function onGMoff()
	-- The player is far enough from others, disable GM
	if source then
		exports.messages:outputGameMessage( "Ghostmode has been disabled.", source, 2.5, 255, 0, 0, true )
	end

	if not source then
		for _,u in pairs(getElementsByType("player")) do
			setElementData( u, "overrideCollide.uniqueblah", nil, false )
			setElementData( u, "overrideAlpha.uniqueblah", nil, false )
		end
	else
		setElementData( source, "overrideCollide.uniqueblah", nil, false )
		setElementData( source, "overrideAlpha.uniqueblah", nil, false )
	end
end
addEvent('onGMoff', true)
addEventHandler('onGMoff', root, onGMoff)

function onResourceStop()
	--outputChatBox ( "WARNING: GHOSTMODE REMOVED DURING THIS MAP!", root, 0xFF, 0, 0)
	for _, plr in ipairs(getElementsByType( "player") ) do
		setElementData( plr, "overrideCollide.uniqueblah", nil, false )
		setElementData( plr, "overrideAlpha.uniqueblah", nil, false )
	end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop)	

-- DD ghostmode

addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', root,
function(new, old)
	if exports.race:getRaceMode() == "Destruction derby" then
		if new == "GridCountdown" then
			for _,plr in pairs(getElementsByType('player')) do
				setElementData( plr, "overrideAlpha.uniqueblah", 180, false )
				setElementData( plr, "overrideCollide.uniqueblah", 0, false )
			end
		elseif new == "Running" then

			triggerEvent( 'startddgmTimer', root, true,DDGhostModeStartTime)
			
			setTimer(function()
				triggerClientEvent('onCheckCollisions', root )
				for _,plr in pairs(getElementsByType('player')) do
					onGMoff() -- This overrides the onCheckCollisions check, so only reset alpha
					-- setElementData( plr, "overrideAlpha.uniqueblah", nil,false )
				end end, DDGhostModeStartTime*1000,1)
		end
	elseif exports.race:getRaceMode() == "Capture the flag" then
		if new == "Running" then
			setTimer(function()
				for _,plr in pairs(getElementsByType('player')) do
				-- setElementData( plr, "overrideAlpha.uniqueblah", 250, false )
				setElementData( plr, "overrideCollide.uniqueblah", nil )
				end
			end,100,5)
		end
	end

	-- if old == 'GridCountdown' and not modes[exports.race:getRaceMode()] then
	-- 	for _, plr in ipairs(getElementsByType( "player") ) do
	-- 		setElementData( plr, "overrideCollide.uniqueblah", nil, false )
	-- 		setElementData( plr, "overrideAlpha.uniqueblah", nil, false )
	-- 	end
	-- end

    -- if not (new == "Running" and exports.race:getRaceMode() == "Destruction derby") then return end  --map has started, everyone is now unfrozen and ready to play.

    -- triggerClientEvent('onCheckCollisions', root)  --send a check to each client for him to see if a collision disable is required, that is more than 1 player in 1 spawnpoint.
end)
