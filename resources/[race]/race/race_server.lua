g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
allowRPC('setElementPosition')
g_MotorBikeIDs = table.create({ 448, 461, 462, 463, 468, 471, 521, 522, 523, 581, 586 }, true)
g_ArmedVehicleIDs = table.create({ 425, 447, 520, 430, 464, 432 }, true)
g_AircraftIDs = table.create({ 592, 577, 511, 548, 512, 593, 425, 520, 417, 487, 553, 488, 497, 563, 476, 447, 519, 460, 469, 513 }, true)
g_RCVehicleIDs = table.create({ 441, 464, 465, 501, 564, 594 }, true)
g_VehicleClothes = {
	[{ 490, 523, 598, 596, 597, 599}] = { [16] = false, [17] = 4 }
}

g_CurrentRaceMode = nil

g_Spawnpoints = {}			-- { i = { position={x, y, z}, rotation=rotation, vehicle=vehicleID, paintjob=paintjob, upgrades={...} } }
g_Checkpoints = {}			-- { i = { position={x, y, z}, size=size, color={r, g, b}, type=type, vehicle=vehicleID, paintjob=paintjob, upgrades={...} } }
g_Objects = {}				-- { i = { position={x, y, z}, rotation={x, y, z}, model=modelID } }
g_Pickups = {}				-- { i = { position={x, y, z}, type=type, vehicle=vehicleID, paintjob=paintjob, upgrades={...} }

g_Players = {}				-- { i = player }
g_Vehicles = {}				-- { player = vehicle }

local unloadedPickups = {}


addEventHandler('onPlayerJoin', g_Root,
	function()
		outputConsole ( 'Race version ' .. getBuildString(), source, 255, 127, 0 )
		for _,line in ipairs(Addons.report) do
			outputConsole ( 'Race addon: ' .. line, source )
		end
	end
)


addEventHandler('onGamemodeMapStart', g_Root,
	function(mapres)
		-- outputDebugString('onGamemodeMapStart(' .. getResourceName(mapres) .. ')')
		if getTotalPlayerCount() == 0 then
			outputDebugString('Stopping map')
			triggerEvent('onGamemodeMapStop', g_Root)
            return
		end
        gotoState('LoadingMap')
        -- set up all players as not ready
        for i,player in ipairs(getElementsByType('player')) do
            setPlayerNotReady(player)
        end
        -- tell clients new map is loading
        clientCall(g_Root, 'notifyLoadingMap', getResourceInfo(mapres, "name") or getResourceName(mapres), g_GameOptions.showauthorname and getResourceInfo( mapres , "author"), getResourceName(mapres) )

		if g_CurrentRaceMode then
			outputDebugString('Unloading previous map')
			unloadAll()
		end
		TimerManager.createTimerFor("raceresource","loadmap"):setTimer( doLoadMap, 50, 1 ,mapres )
	end
)
-- continue loading map after onGamemodeMapStart has completed
function doLoadMap(mapres)
	if not loadMap(mapres) then
        -- Select another map on load error
        problemChangingMap()
		return
	end
	g_CurrentRaceMode = RaceMode.getApplicableMode():create()
	if not g_CurrentRaceMode:isMapValid() then
        -- Select another map on load error
        problemChangingMap()
		return
	end
	g_CurrentRaceMode:start()
	g_MapInfo.modename  = g_CurrentRaceMode:getName()
	-- Edit #1, removed useless string
	outputDebugString('Loaded race mode ' .. g_MapInfo.modename .. ' ' .. getResourceName(mapres))
	startRace()
end

-- Called from the admin panel when a setting is changed there
addEvent ( "onSettingChange" )
addEventHandler('onSettingChange', g_ResRoot,
	function(name, oldvalue, value, player)
		outputDebug( 'MISC', 'Setting changed: ' .. tostring(name) .. '  value:' .. tostring(value) .. '  value:' .. tostring(oldvalue).. '  by:' .. tostring(player and getPlayerName(player) or 'n/a') )
		cacheGameOptions()
		if g_SavedMapSettings then
			cacheMapOptions(g_SavedMapSettings)
			clientCall(g_Root,'updateOptions', g_GameOptions, g_MapOptions)
			updateGhostmode()
		end
	end
)

function cacheGameOptions()
	g_GameOptions = {}
	g_GameOptions.timeafterfirstfinish  = getNumber('race.timeafterfirstfinish',30) * 1000
	g_GameOptions.hurrytime				= getNumber('race.hurrytime',15) * 1000
	g_GameOptions.defaultrespawnmode	= getString('race.respawnmode','none')
	g_GameOptions.defaultrespawntime	= getNumber('race.respawntime',5) * 1000
	g_GameOptions.defaultduration		= getNumber('race.duration',6000) * 1000
	g_GameOptions.ghostmode				= getBool('race.ghostmode',false)
	g_GameOptions.ghostalpha			= getBool('race.ghostalpha',false)
	g_GameOptions.randommaps			= getBool('race.randommaps',false)
	g_GameOptions.statskey				= getString('race.statskey','name')
	g_GameOptions.vehiclecolors			= getString('race.vehiclecolors','file')
	g_GameOptions.skins					= getString('race.skins','cj')
	g_GameOptions.autopimp				= getBool('race.autopimp',true)
	g_GameOptions.vehicleweapons		= getBool('race.vehicleweapons',true)
	g_GameOptions.firewater				= getBool('race.firewater',false)
	g_GameOptions.classicchangez		= getBool('race.classicchangez',false)
	g_GameOptions.admingroup			= getString('race.admingroup','Admin')
	g_GameOptions.blurlevel				= getNumber('race.blur',36)
	g_GameOptions.cloudsenable			= getBool('race.clouds',true)
	g_GameOptions.joinspectating		= getBool('race.joinspectating',true)
	g_GameOptions.stealthspectate		= getBool('race.stealthspectate',true)
	g_GameOptions.countdowneffect		= getBool('race.countdowneffect',true)
	g_GameOptions.showmapname			= getBool('race.showmapname',true)
	g_GameOptions.hunterminigun			= getBool('race.hunterminigun',true)
	g_GameOptions.securitylevel			= getNumber('race.securitylevel',2)
	g_GameOptions.anyonecanspec			= getBool('race.anyonecanspec',true)
	g_GameOptions.norsadminspectate		= getBool('race.norsadminspectate',false)
	g_GameOptions.racerespawn			= getBool('race.racerespawn',true)
	g_GameOptions.joinrandomvote		= getBool('race.joinrandomvote',true)
	g_GameOptions.asyncloading			= getBool('race.asyncloading',true)
	g_GameOptions.showauthorname		= getBool('race.showauthorname',true)
	g_GameOptions.ghostmode_map_can_override		= getBool('race.ghostmode_map_can_override',true)
	g_GameOptions.skins_map_can_override			= getBool('race.skins_map_can_override',true)
	g_GameOptions.vehicleweapons_map_can_override   = getBool('race.vehicleweapons_map_can_override',true)
	g_GameOptions.autopimp_map_can_override			= getBool('race.autopimp_map_can_override',true)
	g_GameOptions.firewater_map_can_override		= getBool('race.firewater_map_can_override',true)
	g_GameOptions.classicchangez_map_can_override	= getBool('race.classicchangez_map_can_override',true)
	g_GameOptions.ghostmode_warning_if_map_override			= getBool('race.ghostmode_warning_if_map_override',true)
	g_GameOptions.vehicleweapons_warning_if_map_override	= getBool('race.vehicleweapons_warning_if_map_override',true)
	g_GameOptions.hunterminigun_map_can_override	= getBool('race.hunterminigun_map_can_override',true)
	if g_GameOptions.statskey ~= 'name' and g_GameOptions.statskey ~= 'serial' then
		outputWarning( "statskey is not set to 'name' or 'serial'" )
		g_GameOptions.statskey = 'name'
	end
end


function cacheMapOptions(map, bDontUseMode)
	local mode = (not bDontUseMode) and RaceMode.getApplicableMode() and RaceMode.getApplicableMode().modeOptions or {}
	g_MapOptions = {}
	g_MapOptions.duration = map.duration and tonumber(map.duration) > 0 and map.duration*1000 or g_GameOptions.defaultduration
	if mode.duration and g_MapOptions.duration > mode.duration then
		g_MapOptions.duration = mode.duration
	elseif g_MapOptions.duration > 20*60*1000 then
		g_MapOptions.duration = 20*60*1000
	end
	g_MapOptions.respawn = map.respawn or g_GameOptions.defaultrespawnmode
	g_MapOptions.respawn = mode.respawn ~= nil and mode.respawn or g_MapOptions.respawn
	if g_MapOptions.respawn ~= 'timelimit' and g_MapOptions.respawn ~= 'none' then
		g_MapOptions.respawn = 'timelimit'
	end
	g_MapOptions.respawntime	= g_MapOptions.respawn == 'timelimit' and (map.respawntime and map.respawntime*1000 or g_GameOptions.defaultrespawntime)
	g_MapOptions.respawntime 	= mode.respawntime ~= nil and mode.respawntime*1000 or g_MapOptions.respawntime
	g_MapOptions.time			= map.time or '12:00'
	g_MapOptions.weather		= map.weather or 0

	g_MapOptions.skins			= map.skins or 'cj'
	g_MapOptions.vehicleweapons = map.vehicleweapons == 'true'
	g_MapOptions.ghostmode		= map.ghostmode == 'true'
	g_MapOptions.autopimp		= map.autopimp == 'true'
	g_MapOptions.firewater		= map.firewater == 'true'
	g_MapOptions.classicchangez	= map.classicchangez == 'true'
	g_MapOptions.hunterminigun	= map.hunterminigun == 'true'

	outputDebug("MISC", "duration = "..g_MapOptions.duration.."  respawn = "..g_MapOptions.respawn.."  respawntime = "..tostring(g_MapOptions.respawntime).."  time = "..g_MapOptions.time.."  weather = "..g_MapOptions.weather)
	
	if g_MapOptions.time then
		setTime(g_MapOptions.time:match('(%d+):(%d+)'))
	end
	if g_MapOptions.weather then
		setWeather(g_MapOptions.weather)
	end
	
	-- Set ghostmode from g_GameOptions if not defined in the map, or map override not allowed
	if not map.ghostmode or not g_GameOptions.ghostmode_map_can_override then
		g_MapOptions.ghostmode = g_GameOptions.ghostmode
		if mode.ghostmode ~= nil then
			g_MapOptions.ghostmode = mode.ghostmode
		end
	end
	if mode.ghostmode ~= nil and mode.ghostmode_map_can_override == true then
		g_MapOptions.ghostmode = mode.ghostmode
	end
	if not bDontUseMode and map.ghostmode and g_GameOptions.ghostmode_warning_if_map_override and g_MapOptions.ghostmode ~= (mode.ghostmode ~= nil and mode.ghostmode or g_GameOptions.ghostmode) then
		if g_MapOptions.ghostmode then
			outputChatBox( 'Notice: Ghostmode is turned ON for this map' )
		else
			outputChatBox( 'Notice: Ghostmode is turned OFF for this map' )
		end
	end

	-- Set skins from g_GameOptions if not defined in the map, or map override not allowed
	if not map.skins or not g_GameOptions.skins_map_can_override then
		g_MapOptions.skins = g_GameOptions.skins
		if mode.skins ~= nil then
			g_MapOptions.skins = mode.skins
		end
	end
	if mode.skins ~= nil and not mode.skins_map_can_override == true then
		g_MapOptions.skins = mode.skins
	end

	-- Set vehicleweapons from g_GameOptions if not defined in the map, or map override not allowed
	if not map.vehicleweapons or not g_GameOptions.vehicleweapons_map_can_override then
		g_MapOptions.vehicleweapons = g_GameOptions.vehicleweapons
		if mode.vehicleweapons ~= nil then
			g_MapOptions.vehicleweapons = mode.vehicleweapons
		end
	end
	if mode.vehicleweapons ~= nil and not mode.vehicleweapons_map_can_override == true then
		g_MapOptions.vehicleweapons = mode.vehicleweapons
	end
	if not bDontUseMode and map.vehicleweapons and g_GameOptions.vehicleweapons_warning_if_map_override and g_MapOptions.vehicleweapons ~= (mode.vehicleweapons ~= nil and mode.vehicleweapons or g_GameOptions.vehicleweapons) then
		if g_MapOptions.vehicleweapons then
			outputChatBox( 'Notice: Vehicle weapons are turned ON for this map' )
		else
			outputChatBox( 'Notice: Vehicle weapons are turned OFF for this map' )
		end
	end

	-- Set autopimp from g_GameOptions if not defined in the map, or map override not allowed
	if not map.autopimp or not g_GameOptions.autopimp_map_can_override then
		g_MapOptions.autopimp = g_GameOptions.autopimp
		if mode.autopimp ~= nil then
			g_MapOptions.autopimp = mode.autopimp
		end
	end
	if mode.autopimp ~= nil and not mode.autopimp_map_can_override == true then
		g_MapOptions.autopimp = mode.autopimp
	end

	-- Set firewater from g_GameOptions if not defined in the map, or map override not allowed
	if not map.firewater or not g_GameOptions.firewater_map_can_override then
		g_MapOptions.firewater = g_GameOptions.firewater
		if mode.firewater ~= nil then
			g_MapOptions.firewater = mode.firewater
		end
	end
	if mode.firewater ~= nil and not mode.firewater_map_can_override == true then
		g_MapOptions.firewater = mode.firewater
	end

	-- Set classicchangez from g_GameOptions if not defined in the map, or map override not allowed
	if not map.classicchangez or not g_GameOptions.classicchangez_map_can_override then
		g_MapOptions.classicchangez = g_GameOptions.classicchangez
		if mode.classicchangez ~= nil then
			g_MapOptions.classicchangez = mode.classicchangez
		end
	end
	if mode.classicchangez ~= nil and not mode.classicchangez_map_can_override == true then
		g_MapOptions.classicchangez = mode.classicchangez
	end

	-- Set hunterminigun from g_GameOptions if not defined in the map, or map override not allowed
	if not map.hunterminigun or not g_GameOptions.hunterminigun_map_can_override then
		g_MapOptions.hunterminigun = g_GameOptions.hunterminigun
		if mode.hunterminigun ~= nil then
			g_MapOptions.hunterminigun = mode.hunterminigun
		end
	end
	if mode.hunterminigun ~= nil and not mode.hunterminigun_map_can_override == true then
		g_MapOptions.hunterminigun = mode.hunterminigun
	end
end



-- Called from:
--      onGamemodeMapStart
function loadMap(res)
	local map = RaceMap.load(res)
	if not map then
		outputDebugString( 'Error loading map ' .. tostring(getResourceName(res)) )
        outputChatBox( 'Error loading map ' .. tostring(getResourceName(res)) )
		return false
	end

	-- set options
	-- Edit #1a
	g_MapInfo = {}
    g_MapInfo.name      = getResourceInfo(res, 'name') or 'unnamed'
	g_MapInfo.author    = getResourceInfo(res, 'author') or ''
	g_MapInfo.metamode  = getResourceInfo(res, 'racemode') or ''
    g_MapInfo.resname   = getResourceName(res)
	-- Edit #1a
	
	g_SavedMapSettings = {}
	g_SavedMapSettings.duration			= map.duration
	g_SavedMapSettings.respawn			= map.respawn
	g_SavedMapSettings.respawntime		= map.respawntime
	g_SavedMapSettings.time				= map.time
	g_SavedMapSettings.weather			= map.weather
	g_SavedMapSettings.skins			= map.skins
	g_SavedMapSettings.vehicleweapons	= map.vehicleweapons
	g_SavedMapSettings.ghostmode		= map.ghostmode
	g_SavedMapSettings.autopimp			= map.autopimp
	g_SavedMapSettings.firewater		= map.firewater
	g_SavedMapSettings.classicchangez	= map.classicchangez
	g_SavedMapSettings.firewater		= map.firewater
	g_SavedMapSettings.hunterminigun	= map.hunterminigun

	cacheMapOptions(g_SavedMapSettings, true)

	-- If no checkpoints and ghostmode no defined in the map, turn ghostmode off for this map
	if #map:getAll('checkpoint') == 0 and not map.ghostmode and g_MapOptions.ghostmode then
		g_MapOptions.ghostmode = false
		if g_GameOptions.ghostmode_warning_if_map_override then
			outputChatBox( 'Notice: Collisions are turned on for this map' )
		end
	end

	-- Check race can start ok
	-- if g_IgnoreSpawnCountProblems ~= res and not g_MapOptions.ghostmode then
		-- local numSpawnPoints = #map:getAll('spawnpoint')
		-- if getTotalPlayerCount() > numSpawnPoints then
			-- -- unload map xml
			-- map:unload()
			-- outputRace( (numSpawnPoints).." or less players are required to start '"..tostring(getResourceName(res)).."' if not using ghostmode" )
			-- return false
		-- end
	-- end
	
	-- read spawnpoints
	g_Spawnpoints = map:getAll('spawnpoint')
	
	-- read checkpoints
	g_Checkpoints = map:getAll('checkpoint')
	
	-- if map isn't made in the new editor or map is an old race map multiplicate the checkpointsize with 4
	local madeInNewEditor = map.def and map.def:find("editor_main")
	if not madeInNewEditor or map:isRaceFormat() then
		for i,checkpoint in ipairs(g_Checkpoints) do
			checkpoint.size = checkpoint.size and checkpoint.size*4 or 4
		end
	end
	
	if map:isDMFormat() then
		-- sort checkpoints
		local chains = {}		-- a chain is a list of checkpoints that immediately follow each other
		local prevchainnum, chainnum, nextchainnum
		for i,checkpoint in ipairs(g_Checkpoints) do
		
			--check size
			checkpoint.size = checkpoint.size or 4
			
			-- any chain we can place this checkpoint after?
			chainnum = table.find(chains, '[last]', 'nextid', checkpoint.id)
			if chainnum then
				table.insert(chains[chainnum], checkpoint)
				if checkpoint.nextid then
					nextchainnum = table.find(chains, 1, 'id', checkpoint.nextid)
					if nextchainnum then
						table.merge(chains[chainnum], chains[nextchainnum])
						table.remove(chains, nextchainnum)
					end
				end
			elseif checkpoint.nextid then
				-- any chain we can place it before?
				chainnum = table.find(chains, 1, 'id', checkpoint.nextid)
				if chainnum then
					table.insert(chains[chainnum], 1, checkpoint)
					prevchainnum = table.find(chains, '[last]', 'nextid', checkpoint.id)
					if prevchainnum then
						table.merge(chains[prevchainnum], chains[chainnum])
						table.remove(chains, chainnum)
					end
				else
					-- new chain
					table.insert(chains, { checkpoint })
				end
			else
				table.insert(chains, { checkpoint })
			end
		end
		g_Checkpoints = chains[1] or {}
	end
	
	-- read objects
	g_Objects = map:getAll('object')
	
	-- read pickups
	g_Pickups = map:getAll('pickup')
	
	cacheMapOptions(g_SavedMapSettings)
	
	-- unload map xml
	map:unload()
	return true
end

-- Called from:
--      onGamemodeMapStart
function startRace()
    gotoState('PreGridCountdown')
    triggerClientEvent( "resetCustomCountdown", root )
	setElementData( g_ResRoot, "info", {mapInfo = g_MapInfo, mapOptions = g_MapOptions, gameOptions = g_GameOptions}, false )
	AddonOverride.removeAll()
    triggerEvent('onMapStarting', g_Root, g_MapInfo, g_MapOptions, g_GameOptions )
	g_Players = {}
	client_loaded_map = {}
	TimerManager.createTimerFor("map","spawn"):setTimer(joinHandlerByTimer, 200, 0)
	if g_CurrentRaceMode:isRanked() then
		TimerManager.createTimerFor("map","rank"):setTimer(updateRank, 1000, 0)
	end
end


-- Called from:
--      g_RaceStartCountdown
function launchRace()
	for i,player in pairs(g_Players) do
		unfreezePlayerWhenReady(player)
	end
	clientCall(g_Root, 'launchRace', g_MapOptions.duration, g_MapOptions.vehicleweapons)
	if g_MapOptions.duration then
		TimerManager.createTimerFor("map","raceend"):setTimer(raceTimeout, g_MapOptions.duration, 1)
	end
	g_CurrentRaceMode:launch()
	g_CurrentRaceMode.running = true
    gotoState('Running')
end


-- OLD COUNTDOWN
-- g_RaceStartCountdown = Countdown.create(6, launchRace)
-- g_RaceStartCountdown:useImages('img/countdown_%d.png', 474, 204)
-- g_RaceStartCountdown:enableFade(true)
-- g_RaceStartCountdown:addClientHook(3, 'playSoundFrontEnd', 44)
-- g_RaceStartCountdown:addClientHook(2, 'playSoundFrontEnd', 44)
-- g_RaceStartCountdown:addClientHook(1, 'playSoundFrontEnd', 44)
-- g_RaceStartCountdown:addClientHook(0, 'playSoundFrontEnd', 45) 



-- Called from:
--      event onPlayerJoin
--      g_SpawnTimer = setTimer(joinHandler, 500, 0) in startRace
-- Interesting calls to:
--      g_RaceStartCountdown:start()
--
-- note: player is always nil on entry

function joinHandlerByEvent()
    setPlayerNotReady(source)
    joinHandlerBoth()
end

function joinHandlerByTimer()
    joinHandlerBoth()
end

local client_loaded_map = {}
addEvent('client_loaded_map', true)
addEventHandler('client_loaded_map', resourceRoot, function() client_loaded_map[client] = true end)

function joinHandlerBoth(player)
	if #g_Spawnpoints == 0 then
 		-- start vote if no map is loaded
		if not TimerManager.hasTimerFor("watchdog") then
            TimerManager.createTimerFor("map","watchdog"):setTimer(
                function()
                    if #g_Spawnpoints == 0 then
                        outputDebugString('No map loaded; showing votemanager')
						TimerManager.destroyTimersFor("spawn")
                        RaceMode:endMap()
                    end
                end,
                1000, 1 )
        end
        return
    else
		TimerManager.destroyTimersFor("watchdog")
    end
	if TimerManager.hasTimerFor("spawn") then
		for i,p in ipairs(getElementsByType('player')) do
			if not table.find(g_Players, p) and getElementData(p, 'player state') ~= 'away' and client_loaded_map[p] then
				player = p
				break
			end
		end
		if not player then
			for i,p in ipairs(getElementsByType('player')) do
				if not table.find(g_Players, p) and client_loaded_map[p] then
					player = p
					break
				end
			end
		end
		if not player then
			-- Is everyone ready?
			if howManyPlayersNotReady() == 0 then
				TimerManager.destroyTimersFor("spawn")
				if stateAllowsGridCountdown() then
					gotoState('GridCountdown')
					-- g_RaceStartCountdown:start() -- OLD COUNTDOWN
					startCustomCountdown()
				end
			end
			return
		end
	end
	local bPlayerJoined = not player
	if bPlayerJoined then
		player = source
		setPlayerStatus( player, "joined", "" )
	else
        setPlayerStatus( player, "not ready", "" )
    end
    if not player then
        outputDebug( 'MISC', 'joinHandler: player==nil' )
        return
    end

	table.insert(g_Players, player)
    local vehicle
	if true then
        local spawnpoint = g_CurrentRaceMode:pickFreeSpawnpoint(player)
        
        local x, y, z = unpack(spawnpoint.position)
        -- Set random seed dependant on map name, so everyone gets the same models
        setRandomSeedForMap('clothes')

        if g_MapOptions.skins == 'cj' then
            spawnPlayer(player, x + 4, y, z, 0, 0)
            
            local clothes = { [16] = math.random(12, 13), [17] = 7 }    -- 16=Hats(12:helmet 13:moto) 17=Extra(7:garageleg)
            for vehicles,vehicleclothes in pairs(g_VehicleClothes) do
                if table.find(vehicles, spawnpoint.vehicle) then
                    for type,index in pairs(vehicleclothes) do
                        clothes[type] = index or nil
                    end
                end
            end
            local texture, model
            for type,index in pairs(clothes) do
                texture, model = getClothesByTypeIndex(type, index)
                addPedClothes(player, texture, model, type)
            end
        elseif g_MapOptions.skins == 'random' then
            repeat until spawnPlayer(player, x + 4, y, z, 0, math.random(9, 288))
        else
            local ok
            for i=1,20 do
                ok = spawnPlayer(player, x + 4, y, z, 0, getRandomFromRangeList(g_MapOptions.skins))
                if ok then break end
            end
            if not ok then
                spawnPlayer(player, x + 4, y, z, 0, 264)
            end
        end

		setPlayerSpectating(player, false)
        setPlayerNotReady( player )
        setPedStat(player, 160, 1000)
        setPedStat(player, 229, 1000)
        setPedStat(player, 230, 1000)
        
        if spawnpoint.vehicle then
            setRandomSeedForMap('vehiclecolors')
			-- Replace groups of unprintable characters with a space, and then remove any leading space
			local plate = getPlayerName(player):gsub( '[^%a%d]+', ' ' ):gsub( '^ ', '' )
			-- Edit #2 
			if not spawnpoint.rotation then  --Binslayer: wtf, fixing some weirdass bug with maps that dont have rotation and make createVehicle fail thus integrity check fail
				spawnpoint.rotation = 0 
			end
			vehicle = createVehicle(spawnpoint.vehicle, x, y, z, 0, 0, spawnpoint.rotation, plate:sub(1, 8))
			if setElementSyncer then
				setElementSyncer( vehicle, false )
			end
            g_Vehicles[player] = vehicle
			Override.setAlpha( "ForRCVehicles", player, g_RCVehicleIDs[spawnpoint.vehicle] and 0 or nil )
            g_CurrentRaceMode:playerFreeze(player)
            outputDebug( 'MISC', 'joinHandlerBoth: setElementFrozen true for ' .. tostring(getPlayerName(player)) .. '  vehicle:' .. tostring(vehicle) )
            if bPlayerJoined and g_CurrentRaceMode.running then
                unfreezePlayerWhenReady(player)
            end

			if g_MapOptions.respawn == 'none' and not stateAllowsSpawnInNoRespawnMap() then
                g_CurrentRaceMode.setPlayerIsFinished(player)
                setElementPosition(vehicle, 0, 0, 0)
            end
            
            if spawnpoint.paintjob or spawnpoint.upgrades then
                setVehiclePaintjobAndUpgrades(vehicle, spawnpoint.paintjob, spawnpoint.upgrades)
            else
                if g_MapOptions.autopimp then
                    pimpVehicleRandom(vehicle)
                end
                if g_GameOptions.vehiclecolors == 'random' then
                    setRandomSeedForMap('vehiclecolors')
                    local vehicleColorFixed = false
                    for vehicleID,color in pairs(g_FixedColorVehicles) do
                        if vehicleID == tonumber(spawnpoint.vehicle) then
                            if color then
                                setVehicleColor(vehicle, color[1], color[2], color[3], color[4])
                            end
                            vehicleColorFixed = true
                            break
                        end
                    end
                    if not vehicleColorFixed then
                        setVehicleColor(vehicle, math.random(0, 126), math.random(0, 126), 0, 0)
                    end
                end
            end
            warpPedIntoVehicle(player, vehicle)	
        end
        
		destroyBlipsAttachedTo(player)
        createBlipAttachedTo(player, 0, 1, 200, 200, 200)
        g_CurrentRaceMode:onPlayerJoin(player, spawnpoint)
    end

    -- Send client all info
    local playerInfo = {}
    playerInfo.admin    = isPlayerInACLGroup(player, g_GameOptions.admingroup)
    playerInfo.testing  = _TESTING
    playerInfo.joined   = bPlayerJoined
	local duration = bPlayerJoined and (g_MapOptions.duration and (g_MapOptions.duration - g_CurrentRaceMode:getTimePassed()) or true)
	clientCall(player, 'initRace', vehicle, g_Checkpoints, g_Objects, g_Pickups, g_MapOptions, g_CurrentRaceMode:isRanked(), duration, g_GameOptions, g_MapInfo, playerInfo )
	
	if bPlayerJoined and getPlayerCount() == 2 and stateAllowsRandomMapVote() and g_GameOptions.joinrandomvote then
		-- Start random map vote if someone joined a lone player mid-race
		TimerManager.createTimerFor("map"):setTimer(startMidMapVoteForRandomMap,7000,1)
	end

	-- Handle spectating when joined
	if g_CurrentRaceMode.isPlayerFinished(player) then
		-- Joining 'finished'
		clientCall(player, "Spectate.start", 'auto' )
		setPlayerStatus( player, nil, "waiting" )
	else
		if bPlayerJoined and g_CurrentRaceMode.running then
			-- Joining after start
			addActivePlayer(player)
			if g_GameOptions.joinspectating then
				clientCall(player, "Spectate.start", 'manual' )
				setPlayerStatus( player, nil, "spectating")
				Override.setCollideOthers( "ForSpectating", g_CurrentRaceMode.getPlayerVehicle( player ), 0 )
			end
		end
	end
end
addEventHandler('onPlayerJoin', g_Root, joinHandlerByEvent)



-- Called from:
--      joinHandler
--      unfreezePlayerWhenReady
--      launchRace
function unfreezePlayerWhenReady(player)
	if not isValidPlayer(player) then
        outputDebug( 'MISC', 'unfreezePlayerWhenReady: not isValidPlayer(player)' )
		return
	end
    if isPlayerNotReady(player) then
        outputDebug( 'MISC', 'unfreezePlayerWhenReady: isPlayerNotReady(player) for ' .. tostring(getPlayerName(player)) )
        TimerManager.createTimerFor("map",player):setTimer( unfreezePlayerWhenReady, 500, 1, player )
    else
        g_CurrentRaceMode:playerUnfreeze(player)
        outputDebug( 'MISC', 'unfreezePlayerWhenReady: setElementFrozen false for ' .. tostring(getPlayerName(player)) )
    end
end



-- Called from:
--      g_RankTimer = setTimer(updateRank, 1000, 0) in startRace
function updateRank()
	if g_CurrentRaceMode then
		g_CurrentRaceMode:updateRanks()
	end
end


-- Set random seed dependent on map name
--
-- Note: Some clients will experience severe stutter and stalls if any
-- players have different skin/clothes.
-- For smooth gameplay, ensure everyone has the same skin setup including crash helmet etc.
function setRandomSeedForMap( type )
    local seed = 0
    if type == 'clothes' then
        seed = 100                  -- All players get the same driver skin/clothes
    elseif type == 'upgrades' then
        seed = 0                    -- All players get the same set of vehicle upgrades
    elseif type == 'vehiclecolors' then
        seed = getTickCount()       -- Allow vehicle colors to vary between players
    else
        outputWarning( 'Unknown setRandomSeedForMap type ' .. type )
    end
    for i,char in ipairs( { string.byte(g_MapInfo.name,1,g_MapInfo.name:len()) } ) do
        seed = math.mod( seed * 11 + char, 216943)
    end
    math.randomseed(seed)    
end


addEvent('onPlayerReachCheckpoint')
addEvent('onPlayerFinish')
addEvent('onPlayerReachCheckpointInternal', true)
addEventHandler('onPlayerReachCheckpointInternal', g_Root,
	function(checkpointNum, nitroLevel, nitroActive)
		if checkClient( false, source, 'onPlayerReachCheckpointInternal' ) then return end
        if not stateAllowsCheckpoint() then
            return
        end
		local vehicle = g_Vehicles[source]
		local checkpoint = g_CurrentRaceMode:getCheckpoint(checkpointNum)
		if checkpoint.vehicle then
			if getElementModel(vehicle) ~= tonumber(checkpoint.vehicle) then
				if checkpointNum < #g_Checkpoints then
					clientCall(source, 'alignVehicleWithUp')
				end
				setVehicleID(vehicle, checkpoint.vehicle)
				if nitroLevel then
					addVehicleUpgrade(vehicle, 1010)
					clientCall(root, 'setVehicleNitroLevel', vehicle, nitroLevel)
					clientCall(root, 'setVehicleNitroActivated', vehicle, nitroActive)
				end
				clientCall(source, 'vehicleChanging', g_MapOptions.classicchangez, tonumber(checkpoint.vehicle))
				if checkpoint.paintjob or checkpoint.upgrades then
					setVehiclePaintjobAndUpgrades(vehicle, checkpoint.paintjob, checkpoint.upgrades)
				else
					if g_MapOptions.autopimp then
						pimpVehicleRandom(vehicle)
					end
				end
			end
		end
		
		local rank, time = g_CurrentRaceMode:onPlayerReachCheckpoint(source, checkpointNum, nitroLevel, nitroActive)
		if checkpointNum < #g_Checkpoints then
			triggerEvent('onPlayerReachCheckpoint', source, checkpointNum, time)
		else
			triggerEvent('onPlayerFinish', source, rank, time)
		end
	end
)

addEvent('onPlayerPickUpRacePickup')
addEvent('onPlayerPickUpRacePickupInternal', true)
addEventHandler('onPlayerPickUpRacePickupInternal', g_Root,
	function(pickupID, respawntime, nitroLevel, nitroActive)
		if checkClient( false, source, 'onPlayerPickUpRacePickupInternal' ) then return end
		local pickup = g_Pickups[table.find(g_Pickups, 'id', pickupID)]
		local vehicle = g_Vehicles[source]
		if not pickup or not vehicle then return end
		if respawntime and tonumber(respawntime) >= 50 then
			table.insert(unloadedPickups, pickupID)
			clientCall(g_Root, 'unloadPickup', pickupID)
			TimerManager.createTimerFor("map"):setTimer(ServerLoadPickup, tonumber(respawntime), 1, pickupID)
		end
		if pickup.type == 'repair' then
			fixVehicle(vehicle)
		elseif pickup.type == 'nitro' then
			if getVehicleUpgradeOnSlot(vehicle, 8) == 0 then
				addVehicleUpgrade(vehicle, 1010)
			else
				clientCall(root, 'setVehicleNitroLevel', vehicle, 1)
			end
		elseif pickup.type == 'vehiclechange' then
			if getElementModel(vehicle) ~= tonumber(pickup.vehicle) then
				-- clientCall(source, 'removeVehicleNitro')
				setVehicleID(vehicle, pickup.vehicle)
				if pickup.paintjob or pickup.upgrades then
					setVehiclePaintjobAndUpgrades(vehicle, pickup.paintjob, pickup.upgrades)
				end
				if nitroLevel then
					addVehicleUpgrade(vehicle, 1010)
					clientCall(root, 'setVehicleNitroLevel', vehicle, nitroLevel)
					clientCall(root, 'setVehicleNitroActivated', vehicle, nitroActive)
				end
			end
		end
		g_CurrentRaceMode:onPlayerPickUpRacePickup(source, pickup)
		triggerEvent('onPlayerPickUpRacePickup', source, pickupID, pickup.type, pickup.vehicle)
	end
)

function ServerLoadPickup(pickupID)
	table.removevalue(unloadedPickups, pickupID)
	clientCall(g_Root, 'loadPickup', pickupID)
end

addEventHandler('onPlayerWasted', g_Root,
	function()
		if g_CurrentRaceMode then
			if not g_CurrentRaceMode.startTick then
				local x, y, z = getElementPosition(source)
				spawnPlayer(source, x, y, z, 0, getElementModel(source))
				if g_Vehicles[source] then
					warpPedIntoVehicle(source, g_Vehicles[source])	
				end
			else
				setPlayerStatus( source, "dead", "" )
				local player = source
				g_CurrentRaceMode:onPlayerWasted(source)
				triggerEvent( 'onPlayerRaceWasted', player, g_CurrentRaceMode.getPlayerVehicle( player ) )
			end
		end
	end
)


-- Called from:
--		g_RaceEndTimer = setTimer(raceTimeout, g_MapOptions.duration, 1)
function raceTimeout()
	if stateAllowsTimesUp() then
		gotoState('TimesUp')
		for i,player in pairs(g_Players) do
			if not isPlayerFinished(player) then
				showMessage('Time\'s up!')
			end
		end
		clientCall(g_Root, 'raceTimeout')
		TimerManager.destroyTimersFor("raceend")
		g_CurrentRaceMode:timeout()
		g_CurrentRaceMode:endMap()
	end
end

-- Called from:
--      onGamemodeMapStart
--      onGamemodeMapStop
--      onResourceStop
function unloadAll()
	if getPlayerCount() > 0 then
		clientCall(g_Root, 'unloadAll')
	end
	TimerManager.destroyTimersFor("map")

	Countdown.destroyAll()
	triggerEvent("StopCountDown",resourceRoot)

	for i,player in pairs(g_Players) do
		setPlayerFinished(player, false)
		destroyMessage(player)
	end
	destroyMessage(g_Root)
	
	table.each(g_Vehicles, destroyElement)
	g_Vehicles = {}
	g_Spawnpoints = {}
	g_Checkpoints = {}
	g_Objects = {}
	g_Pickups = {}
	unloadedPickups = {}
	if g_CurrentRaceMode then
		g_CurrentRaceMode:destroy()
	end
	g_CurrentRaceMode = nil
	Override.resetAll()
end

addEventHandler('onGamemodeMapStop', g_Root,
	function(mapres)
		--Clear the scoreboard
		for i,player in ipairs(getElementsByType"player") do
			setElementData ( player, "race rank", "" )
			setElementData ( player, "checkpoint", "" )
		end
        fadeCamera ( g_RootPlayers, false, 0.0, 0,0, 0 )
        gotoState('NoMap')
		unloadAll()
	end
)

-- Called from:
--      nowhere
addEventHandler('onPollDraw', g_Root,
	function()
		outputDebugString('Poll ended in a draw')
	end
)


-- Recharge scoreboard columns if required
addEventHandler('onResourceStart', g_Root,
	function(res)
		local resourceName = getResourceName(res)
		if resourceName == 'scoreboard' then
			TimerManager.createTimerFor("raceresource"):setTimer( addRaceScoreboardColumns, 1000, 1 )
		end
	end
)


addEventHandler('onResourceStart', g_ResRoot,
	function()
		outputDebugString('Race resource starting')
		startAddons()
	end
)

addEventHandler('onGamemodeStart', g_ResRoot,
	function()
		outputDebugString('Race onGamemodeStart')
		addRaceScoreboardColumns()
		if not g_GameOptions then
			cacheGameOptions()
		end
	end
)

function addRaceScoreboardColumns()
	exports.scoreboard:addScoreboardColumn('race rank')
	exports.scoreboard:addScoreboardColumn('checkpoint')
	exports.scoreboard:scoreboardAddColumn('player state',root,50,"state")
end

addEventHandler('onResourceStop', g_ResRoot,
	function()
        gotoState( 'Race resource stopping' )
        fadeCamera ( g_Root, false, 0.0, 0,0, 0 )
		outputDebugString('Resource stopping')
		unloadAll()
		exports.scoreboard:removeScoreboardColumn('race rank')
		exports.scoreboard:removeScoreboardColumn('checkpoint')
		exports.scoreboard:removeScoreboardColumn('player state')
	end
)

addEventHandler('onPlayerQuit', g_Root,
	function()
		destroyBlipsAttachedTo(source)
		table.removevalue(g_Players, source)
		if g_Vehicles[source] then
			if isElement(g_Vehicles[source]) then
				destroyElement(g_Vehicles[source])
			end
			g_Vehicles[source] = nil
		end
		if g_CurrentRaceMode then
			g_CurrentRaceMode:onPlayerQuit(source)
		end
		
		for i,player in pairs(g_Players) do
			if not isPlayerFinished(player) then
				return
			end
		end
        
		if getTotalPlayerCount() < 2 then
			outputDebugString('Stopping map')
			triggerEvent('onGamemodeMapStop', g_Root)
		else
			-- Edit #3 warning fix
			if stateAllowsPostFinish() and g_CurrentRaceMode and g_CurrentRaceMode.running then
				gotoState('EveryoneFinished')
				g_CurrentRaceMode:endMap()
			end
		end
	end
)

addEventHandler('onVehicleStartExit', g_Root, function() cancelEvent() end)

function getPlayerCurrentCheckpoint(player)
	return getElementData(player, 'race.checkpoint') or 1
end

function setPlayerCurrentCheckpoint(player, i)
	clientCall(player, 'setCurrentCheckpoint', i)
end

function setPlayerFinished(player, toggle)
	setElementData(player, 'race.finished', toggle)
end

function isPlayerFinished(player)
	return getElementData(player, 'race.finished') or false
end

function distanceFromPlayerToCheckpoint(player, i)
	local checkpoint = g_Checkpoints[i]
	local x, y, z = getElementPosition(player)
	-- Edit #4 bugfix
	if not checkpoint then  --workaround
		local cp = getPlayerCurrentCheckpoint(player)
		local cps = getElementsByType('checkpoint')
		checkpoint = cps[cp]
		local rx, ry, rz = getElementData(checkpoint, 'posX'), getElementData(checkpoint, 'posY'), getElementData(checkpoint, 'posZ')
		return getDistanceBetweenPoints3D(x, y, z, rx, ry, rz)
	else
		return getDistanceBetweenPoints3D(x, y, z, unpack(checkpoint.position))
	end
end

addEvent('onRequestKillPlayer', true)
addEventHandler('onRequestKillPlayer', g_Root,
    function(reason)
		if checkClient( false, source, 'onRequestKillPlayer' ) then return end
        local player = source
        if stateAllowsKillPlayer() then
        	if reason ~= "water" then
        		triggerEvent("onRacePlayerSuicide",source)
        	end
        	
            setElementHealth(player, 0)
            toggleAllControls(player,false, true, false)
        end
    end
)

function toggleServerGhostmode(player)
	if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
		return
	end
	g_MapOptions.ghostmode = not g_MapOptions.ghostmode
	g_GameOptions.ghostmode = not g_GameOptions.ghostmode
	set('*ghostmode', g_GameOptions.ghostmode and 'true' or 'false' )
	updateGhostmode()
	if g_MapOptions.ghostmode then
		outputChatBox('Ghostmode enabled by ' .. getPlayerName(player), g_Root, 0, 240, 0)
	else
		outputChatBox('Ghostmode disabled by ' .. getPlayerName(player), g_Root, 240, 0, 0)
	end
end
-- Edit #5 removed commands
--addCommandHandler('gm', toggleServerGhostmode)
--addCommandHandler('ghostmode', toggleServerGhostmode)

function updateGhostmode()
	for i,player in ipairs(g_Players) do
		local vehicle = g_CurrentRaceMode.getPlayerVehicle(player)
		if vehicle then
			Override.setCollideOthers( "ForGhostCollisions", vehicle, g_MapOptions.ghostmode and 0 or nil )
			Override.setAlpha( "ForGhostAlpha", {player, vehicle}, g_MapOptions.ghostmode and g_GameOptions.ghostalpha and 180 or nil )
		end
	end
end

g_SavedVelocity = {}

-- Handle client request for manual spectate
addEvent('onClientRequestSpectate', true)
addEventHandler('onClientRequestSpectate', g_Root,
	function(enable)
		if checkClient( false, source, 'onClientRequestSpectate' ) then return end
		-- Checks if switching on
		local player = source
		if enable then
			if not stateAllowsManualSpectate() then return end
			if not _TESTING then
				if isPlayerInACLGroup(player, g_GameOptions.admingroup) then
					if not g_CurrentRaceMode:isMapRespawn() and g_GameOptions.norsadminspectate then
						return false
					end
				else
					if not g_CurrentRaceMode:isMapRespawn() or not g_GameOptions.anyonecanspec then
						return false
					end
				end
			end
		end
		if isPlayerSpectating(player) ~= enable then
			if enable then	-- Go to spectator request
				-- Edit #6 Extra spectator features
				if isPlayerInACLGroup(player, g_GameOptions.admingroup) then
					clientCall(player, "Spectate.start", 'manual' )
				else
					if g_CurrentRaceMode:getTimeRemaining() - g_CurrentRaceMode.getMapOption('respawntime') > 1000 then
						Countdown.create(g_CurrentRaceMode.getMapOption('respawntime')/1000, clientCall, 'You will be able to respawn in:', 255, 255, 255, 0.25, 2.5, true, player, "Spectate.allowUnspectate"):start(player)
					end
					clientCall(player, "Spectate.start", 'manual', true )
				end	
				if not g_GameOptions.stealthspectate or not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
					setPlayerStatus( player, nil, "spectating")
				end
				if isPlayerInACLGroup(player, g_GameOptions.admingroup) then
					setElementData(player, "kKey", "spectating")
				end	
				Override.setCollideOthers( "ForSpectating", g_CurrentRaceMode.getPlayerVehicle( player ), 0 )
				g_SavedVelocity[player] = {}
				g_SavedVelocity[player].velocity = {getElementVelocity(g_Vehicles[player])}
				g_SavedVelocity[player].turnvelocity = {getVehicleTurnVelocity(g_Vehicles[player])}
				g_CurrentRaceMode:playerSpectating(player)
			elseif g_CurrentRaceMode:getTimeRemaining() > 500 then
				clientCall(player, "Spectate.stop", 'manual' )
				setPlayerStatus( player, nil, "")
				if isPlayerInACLGroup(player, g_GameOptions.admingroup) then
					setElementData(player, "kKey", "alive")
				end
				Override.setCollideOthers( "ForSpectating", g_CurrentRaceMode.getPlayerVehicle( player ), nil )
				if g_GameOptions.racerespawn and (g_CurrentRaceMode.getNumberOfCheckpoints() > 0 or g_CurrentRaceMode:forceRespawnRestore()) and not (isPlayerInACLGroup(player, g_GameOptions.admingroup) and g_GameOptions.norsadminspectate) then
			-- Edit #6
					-- Do respawn style restore
					g_CurrentRaceMode:restorePlayer( g_CurrentRaceMode.id, player, true, true )
				else
					-- Do 'freeze/collision off' stuff when stopping spectate
					g_CurrentRaceMode:playerFreeze(player, true, true)
					TimerManager.createTimerFor("map",player):setTimer(afterSpectatePlayerUnfreeze, 2000, 1, player, true)
				end
			end
		end
	end
)

function afterSpectatePlayerUnfreeze(player, bDontFix)
	g_CurrentRaceMode:playerUnfreeze(player, bDontFix)
	if g_SavedVelocity[player] then
		setElementVelocity(g_Vehicles[player], unpack(g_SavedVelocity[player].velocity))
		setVehicleTurnVelocity(g_Vehicles[player], unpack(g_SavedVelocity[player].turnvelocity))
		g_SavedVelocity[player] = nil
	end
end

-- Handle client going to/from spectating
addEvent('onClientNotifySpectate', true)
addEventHandler('onClientNotifySpectate', g_Root,
	function(enable)
		if checkClient( false, source, 'onClientNotifySpectate' ) then return end
		setPlayerSpectating(source, enable)
	end
)

function setPlayerSpectating(player, toggle)
	showBlipsAttachedTo ( player, not toggle )		-- Hide blips if spectating
	setElementData(player, 'race.spectating', toggle)
end

function isPlayerSpectating(player)
	return getElementData(player, 'race.spectating') or false
end


addEvent('onNotifyPlayerReady', true)
addEventHandler('onNotifyPlayerReady', g_Root,
	function()
		if checkClient( false, source, 'onNotifyPlayerReady' ) then return end
		setPlayerReady( source )
		for i, pickupID in ipairs(unloadedPickups) do
			-- outputDebugString(getPlayerName(source).." unload "..tostring(pickupID))
			clientCall(source, "unloadPickup", pickupID )
		end
	end
)

------------------------
-- Players not ready stuff
g_NotReady = {}             -- { player = bool }
g_NotReadyDisplay = nil
g_NotReadyTextItems = {}
g_NotReadyDisplayOnTime = 0
g_JoinerExtraWait = nil
g_NotReadyTimeout = nil
g_NotReadyMaxWait = nil

-- Remove ref if player quits
addEventHandler('onPlayerQuit', g_Root,
	function()
        g_NotReady[source] = nil
		g_SavedVelocity[source] = nil
	end
)

-- Give 10 seconds for joining players to become not ready
addEventHandler('onPlayerJoining', g_Root,
	function()
        g_JoinerExtraWait = getTickCount() + 10000
	end
)

-- Give 5 seconds for first player to start joining
addEventHandler('onGamemodeMapStart', g_Root,
	function(mapres)
        g_JoinerExtraWait = getTickCount() + 5000
		g_NotReadyMaxWait = false
	end
)

-- Give 30 seconds for not ready players to become ready
function setPlayerNotReady( player )
    g_NotReady[player] = true
    g_NotReadyTimeout = getTickCount() + 20000 + 10000
    if _DEBUG_TIMING then g_NotReadyTimeout = g_NotReadyTimeout - 15000 end
    activateNotReadyText()
end

-- Alter not ready timeout 
function setPlayerReady( player )
	setPlayerStatus( player, "alive", nil )
    g_NotReady[player] = false
    g_NotReadyTimeout = getTickCount() + 20000
    if _DEBUG_TIMING then g_NotReadyTimeout = g_NotReadyTimeout - 10000 end
	-- Set max timeout to 30 seconds after first person is ready
	if not g_NotReadyMaxWait then
		g_NotReadyMaxWait = getTickCount() + 30000
	end
	-- If more than 10 players, and only one player not ready, limit max wait time to 5 seconds
	if #g_Players > 10 and howManyPlayersNotReady() == 1 then
		g_NotReadyMaxWait = math.min( g_NotReadyMaxWait, getTickCount() + 5000 )
	end
end

function isPlayerNotReady( player )
    return g_NotReady[player] and getElementData(player, 'player state') ~= 'away' and not client_loaded_map[player]
end


function howManyPlayersNotReady()
    local count = 0
	local names = ''
    for i,player in ipairs(g_Players) do
        if isPlayerNotReady(player) then
            count = count + 1
			names = names .. (count > 1 and ', ' or '') .. getPlayerName(player)
        end
    end
    if g_JoinerExtraWait and g_JoinerExtraWait > getTickCount() then
        count = count + 1 -- If the JoinerExtraWait is set, pretend someone is not ready
    end
    if g_NotReadyTimeout and g_NotReadyTimeout < getTickCount() then
        count = 0       -- If the NotReadyTimeout has passed, pretend everyone is ready
    end
    if g_NotReadyMaxWait and g_NotReadyMaxWait < getTickCount() then
        count = 0       -- If the NotReadyMaxWait has passed, pretend everyone is ready
    end
    return count, names
end


function activateNotReadyText()
    if stateAllowsNotReadyMessage() then
        if not g_NotReadyDisplay then
			TimerManager.createTimerFor("raceresource","notready"):setTimer( updateNotReadyText, 100, 0 )
	        g_NotReadyDisplay = textCreateDisplay()
	        g_NotReadyTextItems[1] = textCreateTextItem('', 0.5, 0.7, 'medium', 255, 235, 215, 255, 1.5, 'center', 'center')
	        textDisplayAddText(g_NotReadyDisplay, g_NotReadyTextItems[1])
        end
    end
end

function updateNotReadyText()
	local count, names = howManyPlayersNotReady()
    if count == 0 then
        deactiveNotReadyText()
    end
	if g_NotReadyDisplay then
        -- Make sure all ready players are observers
        for i,player in ipairs(g_Players) do
            if isPlayerNotReady(player) then
                textDisplayRemoveObserver(g_NotReadyDisplay, player)
            else
                if not textDisplayIsObserver(g_NotReadyDisplay, player) then
                    textDisplayAddObserver(g_NotReadyDisplay, player)
                    g_NotReadyDisplayOnTime = getTickCount()
                end
            end
        end
		-- Only show 'Waiting for other players...' if there actually are any other players
		if getTotalPlayerCount() > 1 then
			textItemSetText(g_NotReadyTextItems[1], 'Waiting for ' .. count .. ' player(s):\n' .. names)
		end
	end
end

function deactiveNotReadyText()
    if g_NotReadyDisplay then
		TimerManager.destroyTimersFor("notready")
        -- Ensure message is displayed for at least 2 seconds
        local hideDisplayDelay  = math.max(50,math.min(2000,2000+g_NotReadyDisplayOnTime - getTickCount()))
        local display           = g_NotReadyDisplay;
        local textItems         = { g_NotReadyTextItems[1] };
		TimerManager.createTimerFor("raceresource"):setTimer(
            function()
		        textDestroyDisplay(display)
		        textDestroyTextItem(textItems[1])
            end,
            hideDisplayDelay, 1 )
		g_NotReadyDisplay = nil
		g_NotReadyTextItems[1] = nil
    end
end


------------------------
-- addon management
Addons = {}
Addons.report = {}
Addons.reportShort = ''

-- Start addon resources listed in the setting 'race.addons'
function startAddons()
	Addons.report = {}
	Addons.reportShort = ''

	-- Check permissions
	local bCanStartResource = hasObjectPermissionTo ( getThisResource(), "function.startResource", false )
	local bCanStopResource = hasObjectPermissionTo ( getThisResource(), "function.stopResource", false )
	if not bCanStartResource or not bCanStopResource then
		local line1 = 'WARNING: Race does not have permission to start/stop resources'
		local line2 = 'WARNING: Addons may not function correctly'
		outputDebugString( line1 )
		outputDebugString( line2 )
		table.insert(Addons.report,line1)
		table.insert(Addons.report,line2)
	end

	for idx,name in ipairs(string.split(getString('race.addons'),',')) do
		if name ~= '' then
			local resource = getResourceFromName(name)
			if not resource then
				outputWarning( "Can't use addon '" .. name .. "', as it is not the name of a resource" )
			else
				if getResourceInfo ( resource, 'addon' ) ~= 'race' then
					outputWarning( "Can't use addon " .. name .. ', as it does not have addon="race" in the info section' )
				else
					-- Start or restart resource
					if getResourceState(resource) == 'running' then
						-- stopResource(resource)
						-- TimerManager.createTimerFor("raceresource"):setTimer( function() startResource(resource) end, 200, 1 )
					else
						startResource(resource, true)
					end
					-- Update Addons.report
					local tag = getResourceInfo ( resource, 'name' ) or getResourceName(resource)
					local build = getResourceInfo ( resource, 'build' ) or ''
					local version = getResourceInfo ( resource, 'version' ) or ''
					local author = getResourceInfo ( resource, 'author' ) or ''
					local description = getResourceInfo ( resource, 'description' ) or ''
					local line = tag .. ' - ' .. description .. ' - by ' .. author .. ' - version [' .. version .. '] [' .. build .. ']'
					table.insert(Addons.report,line)
					-- Update Addons.reportShort
					if  Addons.reportShort ~= '' then
						Addons.reportShort = Addons.reportShort .. ', '
					end
					Addons.reportShort = Addons.reportShort .. tag
				end
			end
		end
	end
end


------------------------
-- Server side move away
MoveAway = {}
MoveAway.list = {}

addEvent( "onRequestMoveAwayBegin", true )
addEventHandler( "onRequestMoveAwayBegin", g_Root,
	function()
		if checkClient( false, source, 'onRequestMoveAwayBegin' ) then return end
		MoveAway.list [ source ] = true
		if not TimerManager.hasTimerFor("moveaway") then
			TimerManager.createTimerFor("map","moveaway"):setTimer( MoveAway.update, 1000, 0 )
		end
	end
)

addEventHandler( "onPlayerQuit", g_Root,
	function()
		MoveAway.list [ source ] = nil
	end
)


addEvent( "onRequestMoveAwayEnd", true )
addEventHandler( "onRequestMoveAwayEnd", g_Root,
	function()
		if checkClient( false, source, 'onRequestMoveAwayEnd' ) then return end
		MoveAway.list [ source ] = nil
	end
)

function MoveAway.update ()
	for player,_ in pairs(MoveAway.list) do
		if not isElement(player) then
			MoveAway.list [ player ] = nil
		end
	end
	for player,_ in pairs(MoveAway.list) do
		if isPedDead(player) or getElementHealth(player) == 0 then
			local vehicle = g_Vehicles[player]
			if isElement(vehicle) then 
				setElementVelocity(vehicle,0,0,0)
				setVehicleTurnVelocity(vehicle,0,0,0)
				Override.setCollideOthers( "ForMoveAway", vehicle, 0 )
				Override.setAlpha( "ForMoveAway", {player, vehicle}, 0 )
			end
		end
	end
end


function setPlayerStatus( player, status1, status2 )
	if status1 then
		setElementData ( player, "status1", status1 )
	end
	if status2 then
		setElementData ( player, "status2", status2 )
	end
	local status = getElementData ( player, "status2" )
	if not status or status=="" then
		status = getElementData ( player, "status1" )
	end
	if status then
		setElementData ( player, "state", status )
	end
end

------------------------
-- Keep players in vehicles
g_checkPedIndex = 0

TimerManager.createTimerFor("raceresource","warppeds"):setTimer(
	function ()
		-- Make sure all players are in a vehicle
		local maxCheck = 6		-- Max number to check per call
		local maxWarp = 3		-- Max number to warp per call

		local warped = 0
		for checked = 0, #g_Players - 1 do
			if checked >= maxCheck or warped >= maxWarp then
				break
			end
			g_checkPedIndex = g_checkPedIndex + 1
			if g_checkPedIndex > #g_Players then
				g_checkPedIndex = 1
			end
			local player = g_Players[g_checkPedIndex]
			if not getPedOccupiedVehicle(player) then
				local vehicle = g_Vehicles[player]
				if vehicle and isElement(vehicle) and not isPlayerRaceDead(player) then
					-- Edit #7 Removed spam
					-- outputDebugString( "Warping player into vehicle for " .. tostring(getPlayerName(player)) )
					warpPedIntoVehicle( player, vehicle )
					warped = warped + 1
				end
			end
		end
	end,
	50,0
)

function isPlayerRaceDead(player)
	return not getElementHealth(player) or getElementHealth(player) < 1e-45 or isPedDead(player)
end

------------------------
-- Script integrity test

g_IntegrityFailCount = 0
TimerManager.createTimerFor("raceresource","integrity"):setTimer(
	function ()
		local fail = false
		-- Make sure all vehicles are valid - Invalid vehicles really mess up the race script
		for player,vehicle in pairs(g_Vehicles) do
			if not isElement(vehicle) then
				fail = true
				outputRace( "Race integrity test fail: Invalid vehicle for player " .. tostring(getPlayerName(player)) )
				kickPlayer( player, nil, "Connection terminated to protect the core" )
			end
		end

		-- Increment or reset fail counter
		g_IntegrityFailCount = fail and g_IntegrityFailCount + 1 or 0

		-- Two fails in a row triggers a script restart
		if g_IntegrityFailCount > 1 then
			outputRace( "Race script integrity compromised - Restarting" )
			exports.mapmanager:changeGamemode( getThisResource() )
		end	
	end,
	1000,0
)

------------------------
-- Testing commands

addCommandHandler('restartracemode',
	function(player)
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
		outputChatBox('Race restarted by ' .. getPlayerName(player), g_Root, 0, 240, 0)
		exports.mapmanager:changeGamemode( getThisResource() )
	end
)


addCommandHandler('pipedebug',
	function(player, command, arg)
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
        if g_PipeDebugTo then
            clientCall(g_PipeDebugTo, 'setPipeDebug', false)
        end
        g_PipeDebugTo = (arg == "1") and player
        if g_PipeDebugTo then
            clientCall(g_PipeDebugTo, 'setPipeDebug', true)
        end
	end
)


------------------------
-- Exported functions

function getPlayerRank(player)
	if not g_CurrentRaceMode or not g_CurrentRaceMode:isRanked() then
		return false
	end
	return g_CurrentRaceMode:getPlayerRank(player)
end

function getTimePassed()
	if not g_CurrentRaceMode then
		return false
	end
	return g_CurrentRaceMode:getTimePassed()
end

function getPlayerVehicle( player )
	return g_CurrentRaceMode.getPlayerVehicle( player )
end

function getRaceMode()
	return g_CurrentRaceMode and g_MapInfo.modename or false
end

function getCheckPoints()
	return g_Checkpoints
end

function export_setPlayerVehicle(player,vehicleID) -- Used in gc perk: reroll vehicle
	if isElement(player) and getElementType(player) == "player" and type(vehicleID) == "number" then
		local vehicle = g_CurrentRaceMode.getPlayerVehicle(player)
		if not vehicle then return false end

		local nitrous = getElementData(vehicle, 'nitro')
		if type(nitrous) ~= "table" or type(nitrous[1]) ~= "boolean" or type(nitrous[2]) ~= "number" then
			nitrous = false
		end


		local isset = setVehicleID(vehicle, vehicleID)
		local notifyClient = clientCall(player, 'vehicleChanging', g_MapOptions.classicchangez, vehicleID)

		if nitrous and nitrous[2] then
			addVehicleUpgrade(vehicle, 1010)
			clientCall(root, 'setVehicleNitroLevel', vehicle, nitrous[2])

			if nitrous[1] then
				clientCall(root, 'setVehicleNitroActivated', vehicle, true)
			end
		end

		return not not isset
	end
end

------------------------
-- Checks

addEventHandler('onElementDataChange', root,
	function(dataName, oldValue )
		if getElementType(source)=='player' and checkClient( false, source, 'onElementDataChange', dataName ) then
			setElementData( source, dataName, oldValue )
			return
		end
	end
)

-- returns true if there is trouble
function checkClient(checkAccess,player,...)
	if client and client ~= player and g_GameOptions.securitylevel >= 2 then
		local desc = table.concat({...}," ")
		local ipAddress = getPlayerIP(client)
		outputDebugString( "Race security - Client/player mismatch from " .. tostring(ipAddress) .. " (" .. tostring(desc) .. ")", 1 )
		cancelEvent()
		if g_GameOptions.clientcheckban then
			local reason = "race checkClient (" .. tostring(desc) .. ")"
			addBan ( ipAddress, nil, nil, getRootElement(), reason )
		end
		return true
	end
	if checkAccess and g_GameOptions.securitylevel >= 1 then
		if not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			local desc = table.concat({...}," ")
			local ipAddress = getPlayerIP(client or player)
			outputDebugString( "Race security - Client without required rights trigged a race event. " .. tostring(ipAddress) .. " (" .. tostring(desc) .. ")", 2 )
			return true
		end
	end
	return false
end
