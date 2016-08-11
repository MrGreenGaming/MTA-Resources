-------------------
---  Boat FPS   ---
-------------------
local fps = getFPSLimit()
local boat = false
addEvent('vehicleChange', true)
addEventHandler('vehicleChange', localPlayer, function(v, old)
	if getVehicleType(getPedOccupiedVehicle(localPlayer)) == 'Boat' and not boat then
		fps = getFPSLimit()
		setFPSLimit(getElementData(localPlayer, "fpslimitboats"))
		boat = true
	elseif getVehicleType(getPedOccupiedVehicle(localPlayer)) ~= 'Boat' and boat then
		setFPSLimit(fps)
		boat = false
	end
end)

addEventHandler("onClientElementDataChange", root, 
function(dataName,oldValue)
	if dataName == "state" then
		if getElementData(source, dataName) == "spectating" or getElementData(source, dataName) == "dead" or getElementData(source, dataName) == "finished" then
			setFPSLimit(fps)
		end
	end
end
)

-------------------
---   NFS NOS   ---
-------------------

local nostype = 'hybrid'
function toggleNitro(k, s)
	local v = getPedOccupiedVehicle(localPlayer)
	if v and getVehicleUpgradeOnSlot(v, 8) ~= 0 and not isElementFrozen(v) then
		if nostype == 'hybrid' then
			if s=='down' then
				setVehicleNitroActivated(v, not isVehicleNitroActivated(v))
				setElementData(v, 'nitro', {s==not isVehicleNitroActivated(v), getVehicleNitroLevel(v)})
			end
		elseif nostype == 'nfs' then
			setVehicleNitroActivated(v, s=='down')
			setElementData(v, 'nitro', {s==not isVehicleNitroActivated(v), getVehicleNitroLevel(v)})
		end
	end
end
bindKey("vehicle_fire", 'both', toggleNitro)
bindKey("vehicle_secondary_fire", 'both', toggleNitro)

addEvent'setNitroType'
addEventHandler('setNitroType', root, function(type)
	nostype = type
end)
addCommandHandler('nostype', function(c, type)
	nostype = type
end)

-- This syncs nitro states and levels from other clients
addEventHandler('onClientElementDataChange', root, function(name)
	if name ~= 'nitro' or getVehicleOccupant(source) == localPlayer then return end
	local data = getElementData(source, 'nitro')
	setVehicleNitroActivated(source, data[1])
	setVehicleNitroLevel(source, data[2])
end)


-------------------------------------------
---   Fix for improved vehicle models   ---
-------------------------------------------

local prefix = 'fixedvehicles/'
local mods = {
	-- [445] = { dff = 'admiral.dff' },
	-- [416] = { dff = 'ambulan.dff' },
	-- [435] = { dff = 'artict1.dff' },
	-- [485] = { dff = 'baggage.dff' },
	-- [568] = { dff = 'bandito.dff' },
	-- [511] = { dff = 'beagle.dff' },
	-- [496] = { dff = 'blistac.dff' },
	-- [422] = { dff = 'bobcat.dff' },
	-- [541] = { dff = 'bullet.dff' },
	-- [438] = { dff = 'cabbie.dff' },
	-- [483] = { dff = 'camper.dff' },
	-- [542] = { dff = 'clover.dff' },
	-- [480] = { dff = 'comet.dff' },
	-- [599] = { dff = 'copcarru.dff' },
	-- [598] = { dff = 'copcarvg.dff' },
	[578] = { dff = 'dft30.dff' },
	-- [593] = { dff = 'dodo.dff', txd = 'dodo.txd' },
	[573] = { dff = 'duneride.dff', txd = 'duneride.txd' },
	[562] = { txd = 'elegy.txd' },
	[419] = { dff = 'esperant.dff' },
	-- [544] = { dff = 'firela.dff' },
	-- [565] = { dff = 'flash.dff', txd = 'flash.txd' },
	-- [463] = { dff = 'freeway.dff' },
	-- [492] = { dff = 'greenwoosa.dff' },
	-- [] = { dff = 'greenwoovc.dff' },
	-- [588] = { dff = 'hotdog.dff' },
	-- [434] = { dff = 'hotknife.dff' },
	[579] = { dff = 'huntley.dff' },
	[545] = { dff = 'hustler.dff' },
	[520] = { dff = 'hydra.dff', txd = 'hydra.txd' },
	-- [546] = { dff = 'intruder.dff' },
	-- [559] = { dff = 'jester.txd' },
	-- [508] = { dff = 'journey.dff' },
	-- [571] = { dff = 'kart.dff', txd = 'kart.txd' },
	-- [410] = { dff = 'manana.dff' },
	-- [487] = { dff = 'maverick.dff', txd = 'maverick.txd' },
	-- [556] = { dff = 'monstera.dff' },
	-- [557] = { dff = 'monsterb.dff' },
	-- [418] = { dff = 'moonbeam.dff' },
	-- [572] = { dff = 'mower.dff' },
	[423] = { dff = 'mrwhoop.dff' },
	-- [467] = { dff = 'oceanic.dff' },
	-- [443] = { dff = 'packer.dff' },
	[404] = { dff = 'peren.dff' },
	-- [603] = { dff = 'phoenix.dff' },
	-- [497] = { dff = 'polmav.dff' },
	-- [426] = { dff = 'premier.dff' },
	-- [436] = { dff = 'previon.dff' },
	-- [547] = { dff = 'primo.dff' },
	-- [489] = { dff = 'rancher.dff' },
	-- [479] = { dff = 'regina.dff' },
	-- [505] = { dff = 'rnchlure.dff' },
	-- [442] = { dff = 'romero.dff' },
	-- [440] = { dff = 'rumpo.dff' },
	-- [476] = { dff = 'rustler.dff' },
	-- [543] = { dff = 'sadler.dff' },
	[495] = { dff = 'sandking.dff', txd = 'sandking.txd' },
	-- [567] = { dff = 'savanna.dff' },
	-- [447] = { dff = 'seaspar.dff', txd = 'seaspar.txd' },
	-- [460] = { dff = 'skimmer.dff' },
	-- [458] = { dff = 'solair.dff' },
	[469] = { dff = 'sparrow.dff', txd = 'sparrow.txd' },
	-- [446] = { dff = 'squalo.dff' },
	-- [439] = { dff = 'stallion.dff' },
	-- [561] = { dff = 'stratum.dff' },
	-- [570] = { dff = 'streakc.dff' },
	-- [409] = { dff = 'stretch.dff' },
	-- [513] = { dff = 'stunt.dff' },
	-- [550] = { dff = 'sunrise.dff' },
	-- [506] = { dff = 'supergt.dff' },
	-- [574] = { dff = 'sweeper.dff' },
	-- [576] = { dff = 'tornado.dff' },
	-- [583] = { dff = 'tug.dff' },
	-- [608] = { dff = 'tugstair.dff' },
	[451] = { dff = 'turismo.dff' },
	[558] = { dff = 'uranus.dff', txd = 'uranus.txd' },
	[611] = { dff = 'utiltr1.dff' },
	-- [412] = { dff = 'voodoo.dff' },
	-- [539] = { dff = 'vortex.dff' },
}

local reload, loaded
function init()
	-- outputDebugString( 'Loading')
	loaded = true
	for id, files in pairs(mods) do
		if files.txd then
			local txd = engineLoadTXD ( prefix .. files.txd )
			local res = engineImportTXD ( txd, id )
			-- outputDebugString( id .. ' ' .. files.txd .. ' ' .. tostring(txd) .. ' ' .. tostring(res))
		end
		if files.dff then
			local dff = engineLoadDFF ( prefix .. files.dff )
			local res = engineReplaceModel ( dff, id )
			-- outputDebugString( id .. ' ' .. files.dff .. ' ' .. tostring(dff) .. ' ' .. tostring(res))
		end
	end
end
-- addEventHandler('onClientResourceStart', resourceRoot, init)
addCommandHandler('fixveh', init)

function stop()
	if not loaded or reload then
		reload = nil
		init()
	end
end
addEvent('onGamemodeMapStop', true)
addEventHandler('onGamemodeMapStop', root, stop)

function unload()
	-- outputDebugString( 'Unloading')
	for id, files in pairs(mods) do
		engineRestoreModel ( id )
	end
end
addCommandHandler('unfixveh', unload)

function onClientMapStarting(mapInfo)
	local map = getResourceFromName(mapInfo.resname)
	local mapRoot = getResourceRootElement(map)
	local txds = #getElementsByType('txd', mapRoot)
	local dffs = #getElementsByType('dff', mapRoot)
	if txds > 0 or dffs > 0 then
		-- outputDebugString('Map has mods, reloading fix after map')
		reload = true
	end
	if boat == true then
		boat = false
		setFPSLimit(fps)
	end
end
addEventHandler('onClientMapStarting', root, onClientMapStarting)


--------------------------------------------------------------------
---   No Smoke/Horn Script
---   kills the annoying honkings and smoke at the start of maps
--------------------------------------------------------------------

function smoke()
    toggleControl ( "accelerate", false)
	toggleControl ( "horn", false)
end
addEventHandler ( "onClientMapStarting", getLocalPlayer(), smoke )


---------------------------------
-- Sort the scoreboard on rank --
---------------------------------
function sortRank()
	setTimer ( function() exports.scoreboard:scoreboardSetSortBy("race rank") end, 1000, 1 )
end
sortRank()
addEventHandler("onClientResourceStart", getResourceRootElement(getResourceFromName("scoreboard")), sortRank)

-------------------------------
-- Fix heli blades collision --
-------------------------------

addEventHandler('onClientVehicleEnter', root, function()
	setHeliBladeCollisionsEnabled ( source, false )
end)


--------------------------
-- Disable vehicle clip --
--------------------------

-- setTimer(setCameraClip, 1000, 0, true,false)