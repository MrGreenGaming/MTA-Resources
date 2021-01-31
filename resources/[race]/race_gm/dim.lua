-----------------------------
--- Setting up dimensions ---
-----------------------------

-- Divide players in dimensions at the start so that too many players won't drop FPS

local dimensionsEnabled = false
local mapUseGM = false
local g_Players = {}
local g_PlayersRank = {}
local modes = {}
modes['Sprint'] = true
modes['Never the same'] = true

function onMapStarting(mapInfo, mapOptions, gameOptions)
	-- Tell client to stop any previous gm checking and reset vars
	mapHasJustStarted = true
	dimensionsEnabled = false
	for _, player in ipairs(getElementsByType('player')) do 
		g_Players[player] = {}
		g_Players[player].timesPerMap = 0
		if getElementData(player, "kKey") == "spectating" then
			setElementData(player, "kKey", "alive")
		end	
		setElementData(player, "dim", 0)
	end
	--if enough players, start dividing them up
	exports.scoreboard:removeScoreboardColumn("dim", root)
	-- Only use gm in allowed modes
	if (not modes[exports.race:getRaceMode()]) then
		return false;
	end

	if getPlayerCount() > 29 then
		exports.scoreboard:scoreboardAddColumn("dim", root, 30, "Dim", 10)
		if getPlayerCount() > 40 then
			dimensionsEnabled = 3
		else
			dimensionsEnabled = 2
		end

		for theKey, player in ipairs(getElementsByType("player")) do
			-- if the ranks from the previous map are known, use those to divide players
			if g_PlayersRank[player] then
				local i = #getElementsByType('player')/dimensionsEnabled
				if g_PlayersRank[player] <= i then
					setElementData(player, "dim", 0)
				elseif g_PlayersRank[player] <= i*2 or dimensionsEnabled == 2 then
					setElementData(player, "dim", 1)
				else
					setElementData(player, "dim", 2)	
				end
			else
			-- else, just fill up dimensions
				setElementData(player, "dim", theKey % dimensionsEnabled)	
			end	
		end
		mapUseGM = mapOptions['ghostmode']
	end
	triggerClientEvent('onServerMapStarting', root, dimensionsEnabled)
	-- reset ranks for the next map
	g_PlayersRank = {}
end	
addEventHandler("onMapStarting", root, onMapStarting)


-- Remember ranks to group players with similar skills
function onPostFinish()
	for _, player in ipairs(getElementsByType('player')) do 
		local rank = getElementData(player, 'race rank')
		if rank and tonumber(rank) then
			g_PlayersRank[player] = rank
		end	
	end	
end
addEvent('onPostFinish', true)
addEventHandler('onPostFinish', root, onPostFinish)


-- New player: fit him in
function onPlayerJoin()
	g_Players[source] = {}
	g_Players[source].timesPerMap = 0
	if dimensionsEnabled then
		setElementData(source, "dim", 0)
	end
end
addEventHandler('onPlayerJoin', root, onPlayerJoin)

-- Leaving player: reset his vars
function onPlayerQuit()
	g_Players[source] = nil
	g_PlayersRank[source] = nil
end
addEventHandler('onPlayerQuit', root, onPlayerQuit)

-- Stopping resource: disable dimensions
function onResourceStop()
	exports.scoreboard:removeScoreboardColumn("dim", root)
	for _,player in ipairs(getElementsByType('player')) do 
		setElementData(player, "dim", 0)
	end	
end
addEventHandler('onResourceStop', resourceRoot, onResourceStop)

-- Map is running and (again?) reset client timer
function onRaceStateChanging ( state )
	if state == "PostFinish" then
		triggerClientEvent('onServerMapStarting', root, dimensionsEnabled)
	end	
	if state == "Running" then
		mapHasJustStarted = false
	end	
end
addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', root, onRaceStateChanging)

---------------------------
--- Changing dimensions ---
---------------------------

-- On dimension checkpoint: If dimensions are enabled and it's the first time then alert the client to start checking
local dimensionCP = 7
function onPlayerReachCheckpoint( cp )
	if (cp == dimensionCP) and dimensionsEnabled and (getElementData(source, "dim") ~= 0) and (g_Players[source].timesPerMap == 0) then
		triggerClientEvent(source, "checkDimensionOkay", root)
		g_Players[source].timesPerMap = g_Players[source].timesPerMap + 1
	end
end
addEvent('onPlayerReachCheckpoint', true)
addEventHandler('onPlayerReachCheckpoint', root, onPlayerReachCheckpoint)

-- Change the dimension after getting confirmation from the client check
function changeDimension()
	if mapHasJustStarted then return end
	if getElementData(source, "state") == "finished" then return end
	
	exports.messages:outputGameMessage("You will join the First dimension in 3 seconds.", source, 2.5, 255, 0, 0, true)	
	
	setTimer( function(player) 
			if (not mapHasJustStarted) and mapUseGM ~= true and isElement(player) then
				setElementData( player, "overrideCollide.uniqueblah", 0, false )
				setElementData( player, "overrideAlpha.uniqueblah", 180, false )
			end
		end, 2500, 1, source)
	
	setTimer( function(player)
			if (not mapHasJustStarted) and isElement(player) then
				local oldTeam = getElementData(player, "dim")
				setElementData(player, "dim", 0)
				checkTeam ( oldTeam )
				if (mapUseGM ~= true) and changeCheckpoint < tonumber(getElementData(player, 'race.checkpoint') or -1) and not spectating(player) then
					exports.messages:outputGameMessage("Dimension changed! Ghostmode on.", player, 2.5, 255, 0, 0, true)
					setTimer(function(thePlayer)
						triggerClientEvent( thePlayer, 'checkGmCanWorkOk', root)
					end, 5000, 1, player)
				else
					exports.messages:outputGameMessage("Dimension changed!", player, 2.5, 255, 0, 0, true)
				end
			end	
		end, 3000, 1, source)
end
addEvent('changeDimension', true)
addEventHandler('changeDimension', root, changeDimension)


-- Checking dimensions, if they're almost empty change all the players inside
function checkTeam ( team )
	if tonumber(team) and team ~= 0 and #getPlayersInDim ( team ) <= 5 then
		for _, player in ipairs(getPlayersInDim(team, true)) do
			triggerClientEvent(player, "checkDimensionOkay", root)
			g_Players[player].timesPerMap = g_Players[player].timesPerMap + 1
		end
	end
end

function getPlayersInDim ( dimension, includeSpectators )
	local dim_players = {}
	for _, player in ipairs(getElementsByType('player')) do
		if getElementData(player, "dim") == dimension and not(spectating(player) and not includeSpectators) then
			table.insert(dim_players, player)
		end
	end
	return dim_players
end

-- Is the player spectating
function spectating(player)
	return (getElementData(player, "kKey") == "spectating") or (getElementData(player, "player state") ~= "alive")
end

-- Changing the dimension of a player through admin panel
function adminDimensionChange(dimension)
	if not dimensionsEnabled then outputChatBox("Dimensions aren't running", source, 255, 0, 0)  return end
	setElementData(source, "dim", dimension)
	outputChatBox("You've changed teams. Currently team "..dimension, source, 255, 0, 0)
end
addEvent('adminDimensionChange', true)
addEventHandler('adminDimensionChange', root, adminDimensionChange)

--Car Hide--
--Give players their own dimension to improve FPS on potato pc's--local rtfDimensions = {}
local carHideAllowed = false
local allowedModes = {
	['Reach the flag'] = true,
	['Never the same'] = true,
	['Sprint'] = true
	
}

local carHideCooldowns = {}
local carHideCooldownAmount = 7000
function carhideKeyHandler(player,key,keystate)
	if keystate ~= "down" then return end
	if not carHideAllowed then return end
	if not player then return end
	if carHideCooldowns[player] then
		outputChatBox("[CarHide] #FFFFFFPlease wait "..(carHideCooldownAmount/1000).." seconds before changing carhide again!",player,0,255,0,true)
		return
	end
	local playerVeh = getPedOccupiedVehicle(player)
	if not playerVeh then return end

	-- Check for gamemode/spectate
	if exports.race:getRaceMode() ~= 'Reach the flag' and not isGhostModeEnabled(player) or isPlayerSpectating(player) then return end 
	carHideCooldowns[player] = setTimer(function() carHideCooldowns[player] = nil end, carHideCooldownAmount, 1)
	if getElementData(player,"carhide") then -- If player is in a dimension

		removeElementData(player,'carhide')
		outputChatBox("[CarHide] #FFFFFFVehicles visible",player,0,255,0,true)

	else -- if player is in normal dimension
		setElementData(player,"carhide","true")
		outputChatBox("[CarHide] #FFFFFFVehicles hidden",player,0,255,0,true)
	end
end

function carHideState ( state )
	if not allowedModes[exports.race:getRaceMode()] then 
		-- Reset
		carHideAllowed = false
		triggerClientEvent("onCarHideStatusChange",root,false,exports.race:getRaceMode())
		return 
	end
	
	if state == "GridCountdown" then	
		local coreMarkersState = getResourceState( getResourceFromName"coremarkers" )
		if coreMarkersState == "running" then
			carHideAllowed = false
			triggerClientEvent("onCarHideStatusChange",root,false,exports.race:getRaceMode())
			return 
		end
		
		carHideAllowed = true
		for _,p in ipairs(getElementsByType("player")) do
			removeElementData(p,'carhide')
			unbindKey(p,"x","down",carhideKeyHandler)
			bindKey(p,"x","down",carhideKeyHandler)
		end
		triggerClientEvent("onCarHideStatusChange",root,true,exports.race:getRaceMode())

	elseif state == "PostFinish" then
		carHideAllowed = false
		for _,p in ipairs(getElementsByType("player")) do
			removeElementData(p,'carhide')
			unbindKey(p,"x","down",carhideKeyHandler)
		end
		
		triggerClientEvent("onCarHideStatusChange",root,false,exports.race:getRaceMode())

	elseif state == "NoMap" then
		carHideAllowed = false
		
		for _,p in ipairs(getElementsByType("player")) do
			removeElementData(p,'carhide')
			unbindKey(p,"x","down",carhideKeyHandler)
		end
		triggerClientEvent("onCarHideStatusChange",root,false,exports.race:getRaceMode())
	end
end
addEventHandler('onRaceStateChanging', root, carHideState)


function isGhostModeEnabled(player)
	if getElementData( player, "overrideCollide.uniqueblah" ) and getElementData( player, "overrideAlpha.uniqueblah" ) then
		return true
	end
	return false
end

function isPlayerSpectating(player)
	return (getElementData(player, "kKey") == "spectating") or (getElementData(player, "state") ~= "alive")
end

function watchGhostMode(key, old, new)
	-- Watch for ghostmode, and disable carhide when a player loses ghostmode
	if (key == 'overrideCollide.uniqueblah' or key == 'overrideAlpha.uniqueblah') and getElementType(source) == 'player' and carHideAllowed and not isGhostModeEnabled(source) then
		triggerClientEvent(source, "onCarHideStatusChange",root,false, exports.race:getRaceMode())	
		removeElementData(source,'carhide')
	end
end
addEventHandler('onElementDataChange', root, watchGhostMode)

-- SHOOTER DIMENSION EXPLOSION BUG FIX --
addEventHandler('onRaceStateChanging', root, function(state)
	if state == "Running" and exports.race:getRaceMode() == "Shooter" then
			for _,p in ipairs(getElementsByType("player")) do
				setElementData(p,"dim",0)
			end
		end
	end
)
