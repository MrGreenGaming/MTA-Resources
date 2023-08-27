-- TESTING LAGG SPIKES
-- local timeoutTime = -1
-- addCommandHandler("gcdbtimeout",
-- 	function(player,command,ms)
-- 		local ms = tonumber(ms)
-- 		if not ms then outputChatBox("Wrong syntax used: /gcdbtimeout [ms]",player) return end
-- 		if hasObjectPermissionTo(player,"function.banPlayer",false) then
-- 			outputChatBox("GCshop vehicle mod fetching timeout set to: "..tostring(ms),player)
-- 			outputDebugString("GCshop vehicle mod fetching timeout set to: "..tostring(ms).." by "..getPlayerName(player))
-- 			timeoutTime = ms
-- 		end
-- 	end


-- 	)

gcMods = {}

local vehicle_price = 550
local extras_price = 550
local prev_vehid = {}
local neons = {
    green =     { "modshop/drug_green.dff",     2055},
    orange =    { "modshop/drug_orange.dff",    2056},
    red =       { "modshop/drug_red.dff",       2057},
    aqua =      { "modshop/drug_aqua.dff",      2058},
    yellow =    { "modshop/drug_yellow.dff",    2059},
}

local permissions = {
	colour = {								-- the rules for custom colours are the same for paintjobs, since they both change colours
		['Sprint'] = true,
		['Destruction derby'] = true,
		['Never the same'] = true,
		['Reach the flag'] = true,
		['Shooter'] = true,
		['Deadline'] = true,
		['Manhunt'] = true,
	},
	preview = {								-- the rules for custom colours are the same for paintjobs, since they both change colours
		['Sprint'] = true,
		['Never the same'] = true,
		-- ['Reach the flag'] = true,
	},
}

local neon_elements = {};
-----------------------------------------
---   Buying and upgrading commands   ---
-----------------------------------------

function buyVehicle ( player, cmd, vehicleID )
	if client and client ~= player then return end

	local vehicleID = getVehicleModelFromString(vehicleID)
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))

	if (not forumID) then
		outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
		return
	elseif not vehicleID then
		outputChatBox('Not a valid vehicle (use the correct name or ID)', player, 255, 0, 0 )
		return
	elseif isVehInDatabase ( forumID, vehicleID ) then
		outputChatBox('You already bought this vehicle: '.. getVehicleNameFromModel(vehicleID)  .. ' (' .. tostring(vehicleID) .. ')', player, 255, 165, 0 )
		return
	end

	local result, error = gcshopBuyItem ( player, vehicle_price, 'Vehicle: ' .. getVehicleNameFromModel(vehicleID)  .. ' (' .. tostring(vehicleID) .. ')' )

	if result == true then
		local added = addVehToDatabase( forumID, vehicleID )
		addToLog ( '"' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought vehicle=' .. tostring(vehicleID) .. ' ' .. tostring(added))
		outputChatBox ('Vehicle \"' .. getVehicleNameFromModel(vehicleID)  .. '\" (' .. tostring(vehicleID) .. ') bought.', player, 0, 255, 0)
		-- getModsFromDB(forumID, )
		getModsFromDB(forumID, true,
		function(data)
			triggerClientEvent( player, 'modshopLogin', player, vehicle_price, data or false )
		end)
		return
	end
	if error then
		outputChatBox( 'An error occured, try reconnecting and notify an admin if you lost GC!', player, 255, 0, 0 )
		addToLog ( 'Error: "' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought vehicle=' .. tostring(vehicleID) .. ' Result=' .. tostring(result) .. ' Error=' .. tostring(error))
	end
end
addCommandHandler('gcbuyveh', buyVehicle, false, false)
addEvent('gcbuyveh', true)
addEventHandler('gcbuyveh', resourceRoot, buyVehicle)

function buyExtras ( player, cmd )
	if client and client ~= player then return end

	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	local vehID = 0
	if true and (not forumID) then
		outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
		return
	elseif doesHaveExtraMods ( forumID ) then
		outputChatBox('You already enabled the extra mods', player, 255, 165, 0 )
		return
	end

	local result, error = gcshopBuyItem ( player, extras_price, 'Modshop: enable extra mods' )

	if result == true then
		local addedVeh = addVehToDatabase( forumID, vehID )
        local addedSlot = addUpgToSlotDatabase (forumID, vehID, 'slot0', 1 )
		addToLog ( '"' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought extra mods= ' .. tostring(addedVeh) ..' '.. tostring(addedSlot))
		outputChatBox ('Modshop: enable extra mods bought.', player, 0, 255, 0)
		getModsFromDB(forumID, true,
		function(data)
			triggerClientEvent( player, 'modshopLogin', player, vehicle_price, data or false )
		end)
		return
	end
	if error then
		outputChatBox( 'An error occured, try reconnecting and notify an admin if you lost GC!', player, 255, 0, 0 )
		addToLog ( 'Error: "' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought extra mods, Result=' .. tostring(result) .. ' Error=' .. tostring(error))
	end
end
addCommandHandler('gcbuyextras', buyExtras, false, false)
addEvent('gcbuyextras', true)
addEventHandler('gcbuyextras', resourceRoot, buyExtras)

function setMod ( player, cmd, vehicleID, upgradeType, ... )
	if client and client ~= player then return end
	-- vehicle = id
	-- slot0-16 = modupgrades
	-- slot17 = paintjob
	-- slot18-21 = vehcolors
	-- slot22-24 = headlightcolors
	-- 25 = horn?
	-- slot25-30 = extra

	vehicleID = getVehicleModelFromString(vehicleID)
	forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	local upgrades = {
		["upgrade"] = addShopUpgrade,
		["remupgrade"] = remShopUpgrade,
		["paintjob"] = addShopPaintJob,
		["vcolor"] = addShopVColor,
		["vcolor2"] = addShopVColorRGB,
		["lcolor"] = addShopLColor,
        ["neon"] = addShopNeon
	}
	upgradeType = upgrades[upgradeType]

	if (not forumID) then
		outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
		return
	elseif not vehicleID then
		outputChatBox('Not a valid vehicle (use the correct name or ID)', player, 255, 0, 0 )
		return
	elseif vehicleID ~= '*' and not isVehInDatabase ( forumID, vehicleID ) then
		outputChatBox('You don\'t own this vehicle: '.. getVehicleNameFromModel(vehicleID)  .. ' (' .. tostring(vehicleID) .. ')', player, 255, 0, 0 )
		return
	elseif not upgradeType then
		outputChatBox('Not a valid upgrade type', player, 255, 0, 0 )
		return
	end

	upgradeType ( player, forumID, vehicleID, ... )
	getModsFromDB(forumID, true,
	function(data)
		triggerClientEvent( player, 'modshopLogin', player, vehicle_price, data or false )
	end)
	return
end
addCommandHandler('gcsetmod', setMod, false, false )
addEvent('gcsetmod', true)
addEventHandler('gcsetmod', resourceRoot, setMod)

function addShopUpgrade ( player, forumID, vehicleID, upgradeID)
	upgradeID = upgradeSlotID(tonumber(upgradeID)) and tonumber(upgradeID)
	if (not upgradeID) then
		outputChatBox ( 'Not a valid upgrade ID (use numbers)', player, 255, 0, 0 )
	elseif upgradeID == 1008 or upgradeID == 1009 or upgradeID == 1010 or upgradeID == 1087 then
		outputChatBox ( 'Nitro or hydraulics are not allowed', player, 255, 0, 0 )
	elseif vehicleID == '*' then
		getModsFromDB(forumID,true,
			function(vehTable)
				for i = 1, #vehTable do
					if vehTable[i].vehicle then
						if not isUpgradeCompatible ( vehTable[i].vehicle, upgradeID ) then
						elseif isUpgInDatabase ( forumID, vehTable[i].vehicle, upgradeID ) then
						else
							local added = addUpgToDatabase (forumID, vehTable[i].vehicle, upgradeID )
							local veh = getPedOccupiedVehicle(player)
							if veh and vehTable[i].vehicle == getElementModel(veh) then
					if veh and vehTable[i].vehicle == getElementModel(veh) then
							if veh and vehTable[i].vehicle == getElementModel(veh) then
								addVehicleUpgrade(veh, upgradeID)
							end
						end
					end
			end
					end
				end
				outputChatBox ('Upgrade added to all your compatible vehicles' , player, 0, 255, 0 )
			end
		)
	elseif not isUpgradeCompatible ( vehicleID, upgradeID ) then
		outputChatBox ( 'Upgrade ' .. tostring(upgradeID) .. ' isn\'t compatible with a(n) ' .. tostring(getVehicleNameFromModel(vehicleID)), player, 255, 0, 0 )
	elseif isUpgInDatabase ( forumID, vehicleID, upgradeID ) then
		outputChatBox ( 'This upgrade is already added: '.. tostring(getVehicleNameFromModel(vehicleID)) .. ' + ' .. tostring(upgradeID), player, 255, 165, 0 )
	else
		local added = addUpgToDatabase (forumID, vehicleID, upgradeID )
		outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\": new upgrade '.. tostring(upgradeID) .. ((added and '') or ' FAILED'), player, 0, 255, 0 )
		local veh = getPedOccupiedVehicle(player)
		if veh and vehicleID == getElementModel(veh) then
			addVehicleUpgrade(veh, upgradeID)
		end
	end
end


function remShopUpgrade ( player, forumID, vehicleID, upgradeID)
	upgradeID = upgradeSlotID(tonumber(upgradeID)) and tonumber(upgradeID)
	if (not upgradeID) then
		outputChatBox ( 'Not a valid upgrade ID (use numbers)', player, 255, 0, 0 )
	elseif vehicleID == '*' then
		getModsFromDB(forumID,true,
			function(vehTable)
				for i = 1, #vehTable do
					if vehTable[i].vehicle then
						if isUpgInDatabase ( forumID, vehTable[i].vehicle, upgradeID ) then
							local removed = remUpgFromDatabase (forumID, vehTable[i].vehicle, upgradeID )
							local veh = getPedOccupiedVehicle(player)
							if veh and vehicleID == getElementModel(veh) then
					if veh and vehicleID == getElementModel(veh) then
							if veh and vehicleID == getElementModel(veh) then
								removeVehicleUpgrade(veh, upgradeID)
							end
						end
					end
			end
					end
				end
				outputChatBox ('Removed upgrade of all your vehicles' , player, 0, 255, 0 )
			end
		)
	elseif not isUpgInDatabase ( forumID, vehicleID, upgradeID ) then
		outputChatBox ( 'This upgrade is not added: '.. tostring(getVehicleNameFromModel(vehicleID)) .. ' + ' .. tostring(upgradeID), player, 255, 165, 0 )
	else
		local removed = remUpgFromDatabase (forumID, vehicleID, upgradeID )
		outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\": removed upgrade '.. tostring(upgradeID) .. ((removed and '') or ' FAILED'), player, 0, 255, 0 )
		local veh = getPedOccupiedVehicle(player)
		if veh and vehicleID == getElementModel(veh) then
			removeVehicleUpgrade(veh, upgradeID)
		end
	end
end

function addShopPaintJob ( player, forumID, vehicleID, paintjob)
	checkPerk(forumID, 4,
	function(bool)
		getPerkSettings(player, 4,
		function(perkSetting)
			if bool and not math.range(paintjob, 0, 3 + (perkSetting.amount or 0)) then
				outputChatBox ( 'Wrong input, need a paintjob between 1 and 3 (0 = no paintjob) or ' .. 3 + perkSetting.amount .. 'for custom paintjobs!', player, 255, 0, 0 )
			elseif not bool and not math.range(paintjob, 0, 3)  then
				outputChatBox ( 'Wrong input, need a paintjob between 1 and 3 (0 = no paintjob)', player, 255, 0, 0 )
			else
				paintjob = math.range(paintjob, 0, 3 + (perkSetting and perkSetting.amount or 0))
				local realPJ = (paintjob ~= 0 and paintjob - 1) or 3
				if vehicleID ~= '*' then
					if paintjob > 3  then
						addUpgToSlotDatabase (forumID, vehicleID, 'slot17', paintjob )
						outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\": new custom paintjob #' .. paintjob, player, 0, 255, 0 )
					elseif paintjob ~= 0 then
						addUpgToSlotDatabase (forumID, vehicleID, 'slot17', paintjob - 1 )
						outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\": new paintjob #' .. paintjob, player, 0, 255, 0 )
					else
						remUpgFromSlotDatabase (forumID, vehicleID, 'slot17' )
						outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\": paintjob removed' , player, 0, 255, 0 )
					end
				else
					if paintjob > 3  then
						addUpgToSlotDatabase (forumID, vehicleID, 'slot17', paintjob )
						outputChatBox ('All your vehicles have a new custom paintjob #' .. paintjob, player, 0, 255, 0 )
					elseif paintjob ~= 0 then
						addUpgToSlotDatabase (forumID, vehicleID, 'slot17', paintjob - 1 )
						outputChatBox ('All your vehicles have a new paintjob #' .. paintjob, player, 0, 255, 0 )
					else
						remUpgFromSlotDatabase (forumID, vehicleID, 'slot17' )
						outputChatBox ('Paintjob removed from all your vehicles' , player, 0, 255, 0 )
					end
				end
				local veh = getPedOccupiedVehicle(player)
				if veh and vehicleID == getElementModel(veh) then
					local col1, col2, col3, col4 = getVehicleColor ( veh )
					if paintjob < 4 then
						setVehiclePaintjob(veh, realPJ)
						removeCustomPaintJob (player)
					else
						setVehiclePaintjob(veh, 3)
						applyCustomPaintJob( player, paintjob - 3 )
					end
					if isVehColorAllowed() then
						setVehicleColor(veh, col1, col2, col3, col4)
					end
				end
			end
		end)
	end)

end

function addShopVColor ( player, forumID, vehicleID, arg1, arg2, arg3, arg4 )
	if arg1 and not tonumber(arg1) then
		outputChatBox ( 'Wrong input, up to four colors between 0-255 are accepted', player, 255, 0, 0 )
		return
	end
	arg1 = math.range(arg1, 0, 255)
	arg2 = arg1 and math.range(arg2, 0, 255)
	arg3 = arg2 and math.range(arg3, 0, 255)
	arg4 = arg3 and math.range(arg4, 0, 255)
	remUpgFromSlotDatabase (forumID, vehicleID, 'slot18' )
	remUpgFromSlotDatabase (forumID, vehicleID, 'slot19' )
	remUpgFromSlotDatabase (forumID, vehicleID, 'slot20' )
	remUpgFromSlotDatabase (forumID, vehicleID, 'slot21' )
	if not (arg1) then
		outputChatBox ( 'Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\" : colors removed', player, 0, 255, 0 )
	else
		addUpgToSlotDatabase (forumID, vehicleID, 'slot18', arg1 )
		if not arg2 then
			outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\" has a new color: ' .. arg1, player, 0, 255, 0 )
		else
			addUpgToSlotDatabase (forumID, vehicleID, 'slot19', arg2 )
			if not arg3 then
				outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\" has a new color scheme: ' .. arg1 .. " " .. arg2, player, 0, 255, 0 )
			else
				addUpgToSlotDatabase (forumID, vehicleID, 'slot20', arg3 )
				if not arg4 then
					outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\" has a new color scheme: ' .. arg1 .. " " .. arg2 .. " " .. arg3, player, 0, 255, 0 )
				else
					addUpgToSlotDatabase (forumID, vehicleID, 'slot21', arg4 )
					outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\" has a new color scheme: ' .. arg1 .. " " .. arg2 .. " " .. arg3 .. " " .. arg4, player, 0, 255, 0 )
				end
			end
		end
		local veh = getPedOccupiedVehicle(player)
		if veh and vehicleID == getElementModel(veh) then
			local col1, col2, col3, col4 = getVehicleColor ( veh )
			if isVehColorAllowed() then
				setVehicleColor(veh, arg1 or col1, arg2 or col2, arg3 or col3, arg4 or col4)
			end
		end
	end
end

function addShopVColorRGB ( player, forumID, vehicleID, ... )
	local arg = {...}		-- should be (r1, g1, b1, [r2, g2, b2, [r3, g3, b3, [r4, g4, b4]]])
	local colors = {}		-- [1] = {r,g,b}, [2] = {..}, [3]={..}, [4]={..}
	for i=0,3 do
		local t = {}
		t[1] = math.range(arg[1+i*3], 0, 255)	--red
		t[2] = math.range(arg[2+i*3], 0, 255)	--green
		t[3] = math.range(arg[3+i*3], 0, 255)	--blue
		if not (t[1] and t[2] and t[3]) then
			if i == 0 and arg[1] then
				outputChatBox ( 'Wrong input, up to four rgb colors are accepted', player, 255, 0, 0 )
				return
			else
				t[1], t[2], t[3] = nil, nil, nil
			end
		end
		colors[i] = t
	end
	if vehicleID ~= '*' then
		remUpgFromSlotDatabase (forumID, vehicleID, 'slot18' )
		remUpgFromSlotDatabase (forumID, vehicleID, 'slot19' )
		remUpgFromSlotDatabase (forumID, vehicleID, 'slot20' )
		remUpgFromSlotDatabase (forumID, vehicleID, 'slot21' )
	end
	if not (colors[0][1]) then
		if vehicleID ~= '*' then
			outputChatBox ( 'Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\": colors removed', player, 0, 255, 0 )
		end
	else
		local text = ''
		for i=0,3 do
			if not colors[i] then break end
			local s = table.concat(colors[i], ",")
			addUpgToSlotDatabase (forumID, vehicleID, 'slot' .. 18 + i, s )
			text = text ..' '.. s
		end
		if vehicleID ~= '*' then
			outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\" has a new color scheme: ' .. text, player, 0, 255, 0 )
		else
			outputChatBox ('All your vehicles have a new color scheme: ' .. text, player, 0, 255, 0 )
		end
		local veh = getPedOccupiedVehicle(player)
		if veh and ( vehicleID == getElementModel(veh) or isVehInDatabase ( forumID, getElementModel(veh) ) ) then
			if isVehColorAllowed() then
				setVehicleColor(veh,	colors[0][1], colors[0][2], colors[0][3],
										colors[1][1], colors[1][2], colors[1][3],
										colors[2][1], colors[2][2], colors[2][3],
										colors[3][1], colors[3][2], colors[3][3]
										)
			end
		end
	end
end

function addShopLColor ( player, forumID, vehicleID, red, green, blue )
	if not (red or green or blue) then
		if vehicleID ~= '*' then
			remUpgFromSlotDatabase (forumID, vehicleID, 'slot22' )
			remUpgFromSlotDatabase (forumID, vehicleID, 'slot23' )
			remUpgFromSlotDatabase (forumID, vehicleID, 'slot24' )
			local veh = getPedOccupiedVehicle(player)
			setVehicleHeadLightColor(veh, 255, 255, 255)
			outputChatBox ( 'Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\" : headlight colors removed', player, 0, 255, 0 )
		end
	else
		red = math.range(red, 0, 255)
		green = math.range(green, 0, 255)
		blue = math.range(blue, 0, 255)
		if not (red and green and blue) then
			outputChatBox ( 'Wrong input, need a rgb color (ex. "155 155 0")', player, 255, 0, 0 )
		else
			addUpgToSlotDatabase (forumID, vehicleID, 'slot22', red )
			addUpgToSlotDatabase (forumID, vehicleID, 'slot23', green )
			addUpgToSlotDatabase (forumID, vehicleID, 'slot24', blue )
			if vehicleID ~= '*' then
				outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\" has new headlights : ' .. red .. " " .. green .. " " .. blue, player, 0, 255, 0 )
			else
				outputChatBox ('All your vehicles have new headlights : ' .. red .. " " .. green .. " " .. blue, player, 0, 255, 0 )
			end
			local veh = getPedOccupiedVehicle(player)
			if veh and ( vehicleID == getElementModel(veh) or isVehInDatabase ( forumID, getElementModel(veh) ) ) then
				setVehicleHeadLightColor(veh, red, green, blue)
			end
		end
	end
end

function addShopNeon ( player, forumID, vehicleID, color)
    if not getModelNeonData ( vehicleID ) then
		outputChatBox ( 'This vehicle doesn\' support neon lights', player, 255, 0, 0 )
	elseif color and not neons[color] then
		outputChatBox ( 'Wrong input, need a valid color (green, red, yellow, aqua, orange)', player, 255, 0, 0 )
	else
        if not (color) then
            remUpgFromSlotDatabase (forumID, vehicleID, 'slot26' )
            outputChatBox ( 'Removed neon lights from ' .. tostring(getVehicleNameFromModel(vehicleID)), player, 0, 255, 0 )
        else
            addUpgToSlotDatabase (forumID, vehicleID, 'slot26', color )
            outputChatBox ('Vehicle \"' .. tostring(getVehicleNameFromModel(vehicleID)) .. '\" has new neon lights: ' .. color, player, 0, 255, 0 )
        end
        local veh = getPedOccupiedVehicle(player)
        if veh and vehicleID == getElementModel(veh) then
            for k, element in ipairs ( getAttachedElements(veh) ) do
                if getElementData(element, "neon", false) == true then
                    destroyElement( element )
                end
            end
            if color then
                updateNeon ( player, color )
            end
        end
    end
end


----------------------------
---   Aplying upgrades   ---
----------------------------

local map_allows_shop = true
local dataID = "gcshop.modshop"

function mapRestart ( mapInfo, mapOptions, gameOptions )
	-- reset prev_vehid
	prev_vehid = {}
	-- check for map upgrades
	map_allows_shop = true
	for k,s in pairs(getElementsByType('spawnpoint')) do
		if getElementData(s,'upgrades') or getElementData(s,'paintjob') then
			map_allows_shop = false
		end
	end
	for k,s in pairs(getElementsByType('checkpoint')) do
		if getElementData(s,'upgrades') or getElementData(s,'paintjob') then
			map_allows_shop = false
		end
	end
	for k,s in pairs(getElementsByType('pickup')) do
		if getElementData(s,'upgrades') or getElementData(s,'paintjob') then
			map_allows_shop = false
		end
	end
	if not map_allows_shop then
		setTimer(outputChatBox, 1500, 1, 'This map has it\'s own custom upgrades, modshop upgrades are disabled')
	end
end
addEventHandler ( "onMapStarting", root, mapRestart )

function shopLogIn(forumID, amount)
	local player = source
	getModsFromDB(forumID, true,
		function(playerMods)
			local veh = getPedOccupiedVehicle(player)
			if veh then
				prev_vehid[player] = getElementModel(veh)
			end
			addUpgradeHandlers(player)
			setTimer(vehicleChecker2, 2000, 1, player)
			local accName = getAccountName ( getPlayerAccount ( player ) ) -- get his account name
			-- setTimer(triggerClientEvent,5000,1, player, 'modshopLogin', player, vehicle_price, gcMods[forumID] or false )
			triggerClientEvent( player, 'modshopLogin', player, vehicle_price, playerMods or false )
		end
	)
end
addEventHandler("onGCShopLogin", root, shopLogIn)

function shopLogOut( forumID )
	if gcMods[forumID] then
		prev_vehid[source] = nil
		removeUpgradeHandlers ( source )
		gcMods[forumID] = nil
	end
	triggerClientEvent( source, 'modshopLogout', source )
end
addEventHandler("onGCShopLogout", root, shopLogOut )

addEvent('onPlayerReachCheckpoint', true)
addEvent('onPlayerPickUpRacePickup', true)
addEvent('onClientModMapIsStarting', true)

function addUpgradeHandlers(player)
	local function isEventHandlerAdded(sEventName, pElementAttachedTo, func)
		if type(sEventName) == 'string' and
				isElement(pElementAttachedTo) and
				type(func) == 'function' then
			local aAttachedFunctions = getEventHandlers(sEventName, pElementAttachedTo)
			if type(aAttachedFunctions) == 'table' and #aAttachedFunctions > 0 then
				for i, v in ipairs(aAttachedFunctions) do
					if v == func then
						return true
					end
				end
			end
		end

		return false
	end

	if not isEventHandlerAdded('onPlayerVehicleEnter', player, vehicleChecker) then
		addEventHandler('onPlayerVehicleEnter', player, vehicleChecker)
	end
	if not isEventHandlerAdded('onClientModMapIsStarting', player, vehicleChecker) then
		addEventHandler('onClientModMapIsStarting', player, vehicleChecker)
	end
	if not isEventHandlerAdded('onPlayerQuit', player, removeUpgradeHandlers) then
		addEventHandler('onPlayerQuit', player, removeUpgradeHandlers)
	end
end

function removeUpgradeHandlers(player)
	player = source or player
	removeEventHandler('onPlayerVehicleEnter', player, vehicleChecker)
	removeEventHandler('onClientModMapIsStarting', player, vehicleChecker)
	removeEventHandler('onPlayerQuit', player, removeUpgradeHandlers)
end

addEventHandler('onElementModelChange', root, function()
	if getElementType(source) == 'vehicle' then
		local player = getVehicleOccupant(source)
		if not player then return end
		if not exports.gc:isPlayerLoggedInGC(player) then return end
		if not gcMods[exports.gc:getPlayerForumID(player)] then return end
		setTimer(vehicleChecker2, 50, 1, player)
	end
end)

function vehicleChecker2(player)
	player = source or player
	if isElement(player) and getPedOccupiedVehicle(player) and map_allows_shop then
        if getResourceState(getResourceFromName("cw_script")) == "running" and not exports.cw_script:areModShopModificationsAllowed() then return false end
		local previd = prev_vehid[player]
		local id = getElementModel(getPedOccupiedVehicle(player))
		if not previd or previd ~= id then
			prev_vehid[player] = id
			local veh = getPedOccupiedVehicle(player)
			cleanVehicle(veh, player)
		end
		local forumID = tonumber(exports.gc:getPlayerForumID(player))
		return upgradeVehicle(player, forumID)
	end
end

function vehicleChecker(player)
	player = source or player
	setTimer(vehicleChecker2, 50, 1, player)
end

modShopCheckVehicleAgain = vehicleChecker

function upgradeVehicle(player, forumID)
	local veh = getPedOccupiedVehicle(player)
	if not veh then
		outputDebugString('upgradeVehicle: no vehicle', 2)
		return
	end

	local vehID = getElementModel(veh)
	--local upgrades = getUpgInDatabase (forumID, vehID )
	--outputDebugString('Instead of outputting error @ indexing say why: ForumID '.. tostring(forumID))
	if not gcMods[forumID] or not gcMods[forumID]["ID-" .. vehID] then return end
	local upgrades = gcMods[forumID]["ID-" .. vehID]
	if not upgrades or not upgrades['vehicle'] then return end

	local addUpg = {}
	for i = 0, 24 do
        if i == 12 then -- wheels
            if getResourceState(getResourceFromName("cw_script")) == "running" and exports.cw_script:areTeamsSet() then do break end;
        end

		if #split(tostring(upgrades['slot' .. i]), ",") <= 1 then
			addUpg[i] = tonumber(upgrades['slot' .. i])
		else
			addUpg[i] = {}
			for k, v in ipairs(split(tostring(upgrades['slot' .. i]), ",")) do
				addUpg[i][k] = tonumber(v)
			end
		end
		if i <= 16 and addUpg[i] and (i ~= 8 and i ~= 9) then
			addVehicleUpgrade(veh, addUpg[i])
		elseif i == 17 and addUpg[i] then
			if permissions.colour[exports.race:getRaceMode()] then
				local col1, col2, col3, col4 = getVehicleColor(veh)
				if addUpg[17] < 4 then
					--outputDebugString("s 1")
					setVehiclePaintjob(veh, addUpg[17])
					removeCustomPaintJob(player)
				else
					--outputDebugString("s 2")
					setVehiclePaintjob(veh, 3)
					applyCustomPaintJob(player, addUpg[17] - 3)
				end
				if isVehColorAllowed() then
					setVehicleColor(veh, col1, col2, col3, col4)
				end
			end
		elseif i == 21 and addUpg[18] then
			if permissions.colour[exports.race:getRaceMode()] then
				if type(addUpg[18]) == 'number' then
					local col1, col2, col3, col4 = getVehicleColor(veh)
					if isVehColorAllowed() then
						setVehicleColor(veh, math.range(addUpg[18], 0, 255) or col1, math.range(addUpg[19], 0, 255) or col2, math.range(addUpg[20], 0, 255) or col3, math.range(addUpg[21], 0, 255) or col4)
					end
				else
					addUpg[19] = type(addUpg[19]) == 'table' and addUpg[19] or {}
					addUpg[20] = type(addUpg[20]) == 'table' and addUpg[20] or {}
					addUpg[21] = type(addUpg[21]) == 'table' and addUpg[21] or {}
					if isVehColorAllowed() then
						setVehicleColor(veh, addUpg[18][1], addUpg[18][2], addUpg[18][3],
							addUpg[19][1], addUpg[19][2], addUpg[19][3],
							addUpg[20][1], addUpg[20][2], addUpg[20][3],
							addUpg[21][1], addUpg[21][2], addUpg[21][3])
					end
				end
			end
		elseif i == 24 and addUpg[i - 2] then
			setVehicleHeadLightColor(veh, math.range(addUpg[22], 0, 255) or 255, math.range(addUpg[23], 0, 255) or 255, math.range(addUpg[24], 0, 255) or 255)
		end
	end
	--if doesHaveExtraMods ( forumID ) then
	if neons[upgrades['slot26']] then
		updateNeon(player, upgrades['slot26'])
	end
	--  end
end

function cleanVehicle(veh, player)
	for k, v in ipairs(getVehicleUpgrades(veh)) do
		if (v ~= 1008 and v ~= 1009 and v ~= 1010) then
			removeVehicleUpgrade(veh, v)
		end
	end
	setVehiclePaintjob(veh, 3)
	removeCustomPaintJob(player)
	setVehicleHeadLightColor(veh, 255, 255, 255)
	for k, element in ipairs(getElementChildren(veh)) do
		if getElementData(element, "neon", false) then
			destroyElement(element)
		end
	end
	return true
end

function updateNeon(player, color)
	local veh = getPedOccupiedVehicle(player)
	if not veh then return end
	local pos_data = getModelNeonData(getElementModel(veh))
	-- { 1=1+2/math.abs(left+right), 2=1+2/z, 3=1+2/scale, 4=3/front, 5=3/z, 6=3/scale, 7=4/back, 8=4/z, 9=4/scale)
	if not pos_data then return end
	local object = neons[color][2]
	local dim = getElementDimension(veh) or 0;

	local obj1 = createObject(object, 0, 0, 0)
	local obj2 = createObject(object, 0, 0, 0)
	local obj3 = createObject(object, 0, 0, 0)
	local obj4 = createObject(object, 0, 0, 0)

	setElementDimension(obj1, dim);
	setElementDimension(obj2, dim);
	setElementDimension(obj3, dim);
	setElementDimension(obj4, dim);

	setObjectScale(obj1, pos_data[3])
	setObjectScale(obj2, pos_data[3])
	setObjectScale(obj3, pos_data[6])
	setObjectScale(obj4, pos_data[9])

	setElementData(obj1, "neon", true)
	setElementData(obj2, "neon", true)
	setElementData(obj3, "neon", true)
	setElementData(obj4, "neon", true)

	local b = attachElements(obj1, veh, pos_data[1], 0, pos_data[2], 0, 0, 0)
	attachElements(obj2, veh, -pos_data[1], 0, pos_data[2], 0, 0, 0)
	attachElements(obj3, veh, 0, pos_data[4], pos_data[5], 0, 0, 90)
	attachElements(obj4, veh, 0, pos_data[7], pos_data[8], 0, 0, 90)

	setElementParent(obj1, veh)
	setElementParent(obj2, veh)
	setElementParent(obj3, veh)
	setElementParent(obj4, veh)

	setElementCollisionsEnabled(obj1, false) --not sure if needed but players seem to crash in neons at times
	setElementCollisionsEnabled(obj2, false)
	setElementCollisionsEnabled(obj3, false)
	setElementCollisionsEnabled(obj4, false)
end

addEvent('onShopInit', true)
addEventHandler('onShopInit', root,
	function()
		triggerClientEvent(client, "installNeon", client, neons)
	end)


-------------------------------
---   View/Testing ground   ---
-------------------------------
--1475,1765,11.8

local currentRaceState
local dimensions = {}

local function onRaceStateChanging( newStateName, oldStateName)
	currentRaceState = newStateName
end
addEvent('onRaceStateChanging')
addEventHandler('onRaceStateChanging', root, onRaceStateChanging)

local function modshopTestVehicle(player, c , vehicleID)
	local playerState = getElementData(player, 'state', false)
	local vehicleID = getVehicleModelFromString(vehicleID)
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	local veh = getPedOccupiedVehicle(player)

	if (not forumID) then
		outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
		return
	elseif not vehicleID then
		outputChatBox('Not a valid vehicle (use the correct name or ID)', player, 255, 0, 0 )
		return
	elseif not isVehInDatabase ( forumID, vehicleID ) then
		outputChatBox('You don\'t own this vehicle: '.. getVehicleNameFromModel(vehicleID)  .. ' (' .. tostring(vehicleID) .. ')', player, 255, 0, 0 )
		return
	elseif not permissions.preview[exports.race:getRaceMode()] or getElementData(player,"race.finished")
		or (currentRaceState and currentRaceState ~= "Running" and currentRaceState ~= "SomeoneWon") or playerState ~= "alive" or isElementFrozen(veh)
		or not( isElement(player)and getElementData(player, 'state') == 'alive' and veh and isElement(veh) and not isVehicleBlown(veh) and getElementHealth(veh) > 0) then
		return outputChatBox('Not allowed to preview vehicles now!', player, 255,0,0)
	end

	local random = dimensions[player];
	if not random then
		repeat
			random = math.random(4,60000);
		until not dimensions[random]
	end
	dimensions[random] = player;
	dimensions[player] = random;

	setElementDimension(veh, random);
	setElementDimension(player,random);
	setElementData(player,'gcmodshop.testing', true);
	setCameraMatrix(player, 1475,1765,11.8, 1475, 1776, 15);
	setTimer(function()
	setElementPosition(veh,1475,1765,11.8);
	setElementRotation(veh,0,0,180);
	setElementModel(veh, vehicleID);
	setTimer(vehicleChecker2,100,1,player);
	setElementFrozen(veh, true);
	setElementAlpha(veh,255);
	fixVehicle(veh);
	setVehicleDamageProof(veh, true);
	setCameraTarget(player);
	for i = 0,5 do
		setVehicleDoorState(veh, i, 0);
	end
	setTimer(setElementFrozen,50,1,veh, false);
	outputChatBox('Modding ' .. getVehicleNameFromModel(vehicleID)  .. ' (' .. tostring(vehicleID) .. ')', player, 0, 255, 0);
	outputChatBox('Press enter to go back to racing!', player, 0, 255, 0);
	end, 150, 1)
end
addCommandHandler('gctestveh', modshopTestVehicle);
addEvent('gctestveh', true);
addEventHandler('gctestveh', root, modshopTestVehicle);

local function wasted()
	if getElementData(source,'gcmodshop.testing') or dimensions[source] then
		if dimensions[source] then
			dimensions[dimensions[source]] = nil;
			dimensions[source] = nil;
		end
		setElementDimension(exports.race:getPlayerVehicle(source), 0);
		setElementDimension(source, 0);
		setElementData(source,'gcmodshop.testing', nil);
	end
end
addEventHandler('onPlayerWasted', root, wasted)
----------------------------
---   Common functions   ---
----------------------------

function getcolor(r,g,b,a)
	r,g,b,a = tonumber(r), tonumber(g), tonumber(b), tonumber(a) or 255
	if not (r and g and b) or not (0<=r and r<=255 and 0<=g and g<=255 and 0<=b and b<=255 and 0<=a and a<=255) then return false end
	return string.format('#%02X%02X%02X%02X', r, g, b, a)
end

function getVehicleModelFromString ( vehicle )
	if type(vehicle) ~= 'string' then
		return false
	end
	if vehicle == '*' then
		return '*'
	end
	if getVehicleModelFromName (vehicle) or '' ~= getVehicleNameFromModel(tonumber(vehicle) or 0)
	then
		return getVehicleModelFromName (vehicle) or tonumber(vehicle)
	end
	return false
end

function getVehModel ( vehref )
	if type(vehref) == 'string' then
		if tonumber(vehref) then
			vehref = tonumber(vehref)
		else
			return getVehicleModelFromName ( vehref )
		end
	end
	if type(vehref) == 'number' then
		return getVehicleNameFromModel ( vehref ) ~= '' and vehref
	end
	return false
end
-- addCommandHandler('getVehModel', function(p, c, f, v) outputChatBox(tostring(getVehModel(tonumber(f) or f)),p) end, true, true )

function isUpgradeCompatible ( vehicle, upgrade )
	if isElement(tempveh) then destroyElement(tempveh) end
	if timer then killTimer(timer) end
	local timer = nil
	local tempveh = nil
	if not (isElement(vehicle) and getElementType(vehicle) == 'vehicle') then
		if type(vehicle) == 'number' and getVehicleNameFromModel(vehicle) ~= '' then
			tempveh = createVehicle(vehicle, 0,0,-50)
			vehicle = tempveh
			timer = setTimer(function() if isElement(tempveh) then destroyElement(tempveh) end end, 500, 1)
		else
			return false
		end
	end
	upgrade = tonumber(upgrade)
	if upgrade then
		local compUpgrades = getVehicleCompatibleUpgrades(vehicle)
		for k, v in ipairs(compUpgrades) do
			if v == upgrade then
				if isElement(tempveh) then destroyElement(tempveh) end
				return true
			end
		end
	end
	return false
end

function upgradeSlotID (upgradeID)
	local slotName = getVehicleUpgradeSlotName ((type(upgradeID) == 'number' and upgradeID) or 0)
	return slotIDOnName (slotName)
end

function slotIDOnName (slotName)
	local slotOnName = {}
	slotOnName['Hood'] = 0
	slotOnName['Vent'] = 1
	slotOnName['Spoiler'] = 2
	slotOnName['Sideskirt'] = 3
	slotOnName['Front Bullbars'] = 4
	slotOnName['Rear Bullbars'] = 5
	slotOnName['Headlights'] = 6
	slotOnName['Roof'] = 7
	slotOnName['Nitro'] = 8
	slotOnName['Hydraulics'] = 9
	slotOnName['Stereo'] = 10
	slotOnName['Unknown'] = 11
	slotOnName['Wheels'] = 12
	slotOnName['Exhaust'] = 13
	slotOnName['Front Bumper'] = 14
	slotOnName['Rear Bumper'] = 15
	slotOnName['Misc'] = 16
	return slotOnName[slotName] or false
end

function getModelNeonData ( id )
    for k,v in ipairs( getElementsByType('modshop_vehicle', getElementByID("modshop_vehicles")) ) do
        if tonumber(getElementData(v, "vehicle_id", false)) == id then
            local data = false
            local neon_data = getElementData(v, "neon_data", false)
            if neon_data and type(neon_data) == "string" and #neon_data > 0 then
                neon_data = split(neon_data, ",")
                for i = 1,#neon_data do
                    neon_data[i] = tonumber(neon_data[i])
                end
                if #neon_data == 9 then
                    data = neon_data
                end
            end
            return data
        end
    end
    return false
end

function doesHaveExtraMods ( forumID )
    local vehID = 0
    local slot = "slot0"
    local key = 1
    return getUpgInDatabase (forumID, vehID ) and tonumber(getUpgInDatabase (forumID, vehID )[slot]) == key
end

function math.range(val, lowClamp, highClamp)
	if tonumber(val) and tonumber(lowClamp) and tonumber(highClamp) then
		if tonumber(lowClamp) <= tonumber(val) and tonumber(val) <= tonumber(highClamp) then
			return math.min(math.max(tonumber(val), tonumber(lowClamp)), tonumber(highClamp))
		end
	end
	return false
end

function math.clamp(val, lowClamp, highClamp)
	if tonumber(val) and tonumber(lowClamp) and tonumber(highClamp) then
		return math.min(math.max(tonumber(val), tonumber(lowClamp)), tonumber(highClamp))
	end
	return false
end


--------------------
---   Database   ---
--------------------

local tableName = 'gcshop_mod_upgrades'
local tabelDef = 'forumID INT, vehicle INT, slot0 INT, slot1 INT, slot2 INT, slot3 INT, slot4 INT, slot5 INT, slot6 INT, slot7 INT, slot8 INT, slot9 INT, slot10 INT, slot11 INT, slot12 INT, slot13 INT, slot14 INT, slot15 INT, slot16 INT, slot17 INT, slot18 INT, slot19 INT, slot20 INT, slot21 INT, slot22 INT, slot23 INT, slot24 INT, slot25 INT, slot26 INT, slot27 INT, slot28 INT, slot29 INT, slot30 INT'
-- vehicle = id, (if this is zero, and slot0 is one, extra mods are enabled)
-- slot0-16 = modupgrades
-- slot17 = paintjob
-- slot18-21 = vehcolors
-- slot22-24 = headlightcolors
-- slot25 = horn
-- slot26 = neon
-- slot27 = benox
-- slot28-30 = nothing yet, spare columns

function hasPlayerSQLModshop ( forumID )
	forumID = tonumber(forumID)
	if type(forumID) ~= 'number' then return false end

	return gcMods[forumID] and #gcMods[forumID] > 0
end

function isVehInDatabase ( forumID, vehID )
	forumID = tonumber(forumID)
	vehID = tonumber(vehID)
	if type(vehID) == 'number' then
		-- local query = dbQuery(handlerConnect, "SELECT * FROM ?? WHERE forumID=? AND vehicle=?", tableName, tostring(forumID), tostring(vehID))
		-- local result = dbPoll(query,timeoutTime)
		return gcMods[forumID]["ID-"..vehID]
	end
	return false
end

function addVehToDatabase( forumID, vehID )
	forumID = tonumber(forumID)
	vehID = tonumber(vehID)
	if isVehInDatabase (forumID, vehID) then
		return nil
	elseif type(vehID) == 'number' then
		local result = dbExec(handlerConnect, "INSERT INTO ?? (forumID,vehicle) VALUES (?,?)", tableName, tostring(forumID), tostring(vehID))
		getModsFromDB(forumID)
		return result
	end
	return false
end

function isUpgInDatabase ( forumID, vehID, upgradeID )
	forumID = tonumber(forumID)
	vehID = tonumber(vehID)
	upgradeID = tonumber(upgradeID)
	local slot = upgradeSlotID(upgradeID)

	return tonumber(gcMods[forumID]["ID-"..vehID]["slot"..slot]) == upgradeID



end




addCommandHandler("showcache", function(p, c, f)
	for k, v in pairs(cacheUpgrades[tonumber(f)]) do
		outputDebugString('Vehicle: ' .. k)
		for i, j in pairs(v) do
			outputDebugString(i .. ': ' .. j)
		end
	end
end)

function getUpgInDatabase (forumID, vehID )
	forumID = tonumber(forumID)
	if vehID ~= nil then
		vehID = tonumber(vehID)
		if not isVehInDatabase (forumID, vehID) then return false end

		return gcMods[forumID]["ID-"..vehID] or false
		-- table[vehicle=id, slot0=upgrade, ... slot17 = paintjob, ... slot30=extra]
	else

		return gcMods[forumID] or false
	end
end

function addUpgToDatabase (forumID, vehID, upgradeID )
	forumID = tonumber(forumID)
	vehID = tonumber(vehID)
	upgradeID = tonumber(upgradeID)
	local slot = upgradeSlotID(upgradeID)
	if not isVehInDatabase (forumID, vehID) then
		return false
	elseif isUpgInDatabase (forumID, vehID, upgradeID ) then
		return nil
	elseif slot then
		local result = dbExec(handlerConnect, "UPDATE ?? SET slot" .. slot .. "=? WHERE forumID=? AND vehicle=?", tableName, tostring(upgradeID), tostring(forumID), tostring(vehID))
		getModsFromDB(forumID)
		return result
	end
	return false
end

function addUpgToSlotDatabase (forumID, vehID, slot, upgradeID )
	forumID = tonumber(forumID)
	-- vehID = tonumber(vehID)
	-- upgradeID = tonumber(upgradeID)
	if vehID ~= '*' and not isVehInDatabase (forumID, vehID) then
		return false
	elseif (not upgradeID) then
		return nil
	elseif type(slot) == 'string' then
		local conditions = ' AND vehicle=' .. tostring(vehID)
		if vehID == '*' then
			conditions = ''
		end
		local result = dbExec(handlerConnect, "UPDATE ?? SET " .. slot .. "=? WHERE forumID=?" .. conditions, tableName, tostring(upgradeID), tostring(forumID)) -- vehID is inside conditions

		getModsFromDB(forumID)
		return result
	end
	return false
end

function remUpgFromDatabase (forumID, vehID, upgradeID )
	forumID = tonumber(forumID)
	vehID = tonumber(vehID)
	local slot = upgradeSlotID(tonumber(upgradeID))
	if not isVehInDatabase (forumID, vehID) then
		outputDebugString('remUpgToDatabase no data forum/veh id')
		return false
	elseif slot then
		local set = 'slot'.. tostring(slot)
		local value = ''
		local result = dbExec(handlerConnect, "UPDATE ?? SET ?? = ? WHERE forumID=? AND vehicle=?", tableName, set, value, tostring(forumID), tostring(vehID) )

		getModsFromDB(forumID)
		return not not result
	end
	return false
end

function remUpgFromSlotDatabase (forumID, vehID, slot )
	forumID = tonumber(forumID)
	if vehID ~= '*' then vehID = tonumber(vehID) end

	if vehID == '*' and type(slot) == 'string' then
		local result = dbExec(handlerConnect, "UPDATE ?? SET ?? = ? WHERE forumID=?", tableName, slot, '', tostring(forumID))

		getModsFromDB(forumID)
		return not not result
	elseif not isVehInDatabase (forumID, vehID) then
		outputDebugString('remUpgToDatabase no data forum/veh id')
		return false
	elseif type(slot) == 'string' then
		local set = tostring(slot)
		local value = ''
		local result = dbExec(handlerConnect, "UPDATE ?? SET ?? = ? WHERE forumID=? AND vehicle=?", tableName, set, value, tostring(forumID), tostring(vehID) )

		getModsFromDB(forumID)
		return not not result
	end
	return false
end




function getModsFromDB(forumID, raw, callback, ...)
	if not forumID then return end
	if not type(forumID) == "number" then return end
	local args = {...}
	dbQuery(
		function(query)
			local theMods = dbPoll(query,0) -- Takes 14MS on local wamp server for fully bought and modded gc account --

			gcMods[forumID] = {}
			if #theMods > 0 then
				gcMods[forumID] = theMods -- For some reason, this is necessary or else it will not insert sorted by vehID, strange bug or i'm retarded

				for i = 1, #theMods do
					if theMods[i].vehicle then
						local vehID = tostring("ID-"..theMods[i].vehicle)

						-- gcMods[forumID][i] = nil

						gcMods[forumID][vehID] = theMods[i]
						gcMods[forumID][vehID] = theMods[i]
						gcMods[forumID][vehID] = theMods[i]
					end
				end

				for i,v in pairs(gcMods[forumID]) do -- Resort
					if tonumber(i) then
						v = nil
					end
				end

				if not callback or type(callback) ~= 'function' then return end
				if raw then
					 callback(theMods, unpack(args))
				else
					callback(vehTable, unpack(args))
				end
			end
		end,
	handlerConnect,"SELECT * FROM gcshop_mod_upgrades WHERE forumID=?",forumID)
end


function isVehColorAllowed()
	return exports.race:getRaceMode() ~= "Capture the flag"
end

-- idk if this already exists but im gonna make it anyways, lemme know if it already exists ~ Mihoje
function doesPlayerOwnVehicle(player, vehicleid)
	if not player or getElementType(player) ~= 'player' then return false end

	local forumid = exports.gc:getPlayerForumID(player)

	if not forumid then return false end

	local query = dbQuery(handlerConnect, "SELECT vehicle FROM ?? WHERE forumID=? AND vehicle=?", tableName, forumid, vehicleid)

	local result = dbPoll(query, -1)

	if #result > 0 then return true else return false end
end

--same comment as the function above ~ Mihoje
function getPlayerSavedWheelsForVehicle(player, vehicleid)
	if not player or getElementType(player) ~= 'player' then return false end

	local forumid = exports.gc:getPlayerForumID(player)

	if not forumid then return false end

	local query = dbQuery(handlerConnect, "SELECT slot12 FROM ?? WHERE forumid=? AND vehicle=? AND slot12<>'' AND slot12 IS NOT NULL", tableName, forumid, vehicleid)

	local result = dbPoll(query, -1)

	if #result == 0 then return false end

	for i,r in ipairs(result) do
		return r[0] or r['slot12']
	end
end

