-----------------
---   Items   ---
-----------------

local currentRaceState = ''
local busy_with_player = {}
local items = {
	Flip = {
		key = '1';
		cmd = 'gcflipv2';
		func = 'callFlip';
		priceLabel = 'labelFlipPrice';
		price = 35;
		allowedWhen = {
			raceState = {
				Running = true;
				SomeoneWon = true;
			};
			raceMode = {
				['Sprint'] = true,
				['Destruction derby'] = false,
				['Never the same'] = true,
				['Manhunt'] = true,
				['Capture the flag'] = true,
				['Reach the flag'] = true,
			};
			playerState = {
				alive = true;
			};
		};
	};
	Spawn = {
		key = '3';
		cmd = 'gcspawn';
		func = 'callSpawn';
		priceLabel = 'labelSpawnPrice';
		price = 7;
		allowedWhen = {
			raceState = {
				PreGridCountdown = true;
				GridCountdown = true;
			};
			raceMode = {
				['Sprint'] = true,
				['Destruction derby'] = false,
				['Never the same'] = true,
				['Manhunt'] = false,
				['Capture the flag'] = false,
				['Reach the flag'] = true,
				['Deadline'] = true,
			};
			playerState = {
				alive = true;
				['not ready'] = true;
			};
		};
	};
}

function shopLogIn ( forumID, amount )
	for name,Item in pairs(items) do
		bindKey( source, Item.key, 'down', _G[Item.func] )
	end
end
addEventHandler("onGCShopLogin", root, shopLogIn)

function shopLogOut( forumID )
	busy_with_player[source] = nil
	for name,Item in pairs(items) do
		unbindKey( source, Item.key, 'down', _G[Item.func] )
	end
end
addEventHandler("onGCShopLogout", root, shopLogOut )

function onRaceStateChanging( newStateName, oldStateName)
	currentRaceState = newStateName
	--[=[
		-- (/random) NoMap -> LoadingMap
		-- LoadingMap -> PreGridCountdown
		-- PreGridCountdown -> GridCountdown
		-- GridCountdown -> Running
		-- Running -> [[(/new)MidMapVote
		-- MidMapVote]] -> Running
		-- Running -> [[SomeoneWon
		-- SomeoneWon -> TimesUp
		-- TimesUp] -> [EveryoneFinished
		-- EveryoneFinished]] -> PostFinish
		-- PostFinish -> [[NextMapSelect
		-- NextMapSelect -> NextMapVote
		-- NextMapVote]] -> NoMap
	--]=]
end
addEvent('onRaceStateChanging')
addEventHandler('onRaceStateChanging', root, onRaceStateChanging)


---------------------
-- Permanent items --
---------------------

local perks = {
--  [id]= { ID,     price,         description,               , loading function,     				, expire length in days,		allowed modes filter},
	[1] = { ID = 1, price =  3000, description = 'Bike trials', func = 'loadGCTrials'},
	[2] = { ID = 2, price =  3250, description = 'Faster respawn for 60 days', func = 'loadGCRespawn', exp = 60},
	[3] = { ID = 3, price =  2250, description = 'HP Regen for 30 days', func = 'loadGCRegenHP', exp = 30},
	[4] = { ID = 4, price = 15000, description = 'Custom paintjob', func = 'loadGCCustomPaintjob', defaultAmount = 1, extraPrice = 15000, modes = {'Sprint', 'Never the same', 'Manhunt'}},
	[5] = { ID = 5, price =  1500, description = 'Voice', func = 'loadGCVoice'},
	[6] = { ID = 6, price =  2250, description = 'Longer burnup time', func = 'loadGCBurn', modes = {'Sprint', 'Never the same', 'Shooter', 'Deadline', 'Reach the flag', 'Capture the flag', 'Destruction derby'}},
	[7] = { ID = 7, price =  3250, description = 'Extra long burnup time', func = 'loadGCBurnExtra', requires = {6}, exp = 30, modes = {'Sprint', 'Never the same', 'Shooter', 'Deadline', 'Reach the flag', 'Capture the flag', 'Destruction derby'}},
	[8] = { ID = 8, price =  3000, description = 'Health transfer', func = 'loadGCBurnTransfer', requires = {6}, exp = 30, disabled = true},
	[9] = { ID = 9, price =  3000, description = 'Double sided objects', func = 'loadDoubleSided'},
	[10] = { ID = 10, price =  500, description = 'Colored Projectiles for 30 days', func = 'loadProjectileColor', exp = 30},
	[11] = { ID = 11, price =  1500, description = 'NTS/DD Vehicle reroll for 30 days', func = 'loadVehicleReroll', exp = 30},
	[12] = { ID = 12, price =  500, description = 'Deadline color change', func = 'loadDeadlineColorChange', exp = 30},

}

--discount = false
--function perkdiscount()
--	local d = 2
--	if not discount then d = 0.5 end
--	discount = not discount
--	for a,b in ipairs(perks) do
--		local p = b.price
--		b.price = math.ceil(p * d)
--	end
--	
--	local players = getElementsByType("player")
--	for a,b in ipairs(players) do
--		local forumID = tonumber(exports.gc:getPlayerForumID(b))
--		if forumID then triggerClientEvent( b, 'itemLogin', b, perks, getPerks(forumID) ) end
--	end
--end
--addCommandHandler("perkdiscount", perkdiscount, true, true)

function onGCShopLogin (forumID)
	local theSource = source
	getPerks(forumID, 
	function(prks)
		local perkIdTable = {}
		for _, p in pairs(prks) do
			table.insert(perkIdTable, p.ID)
		end
		getPerkExpire(forumID, perkIdTable, 
		function(expired)
			for _, perk in pairs(prks) do
				if tonumber(perk.exp) and (not expired[perk.ID] or expired[perk.ID] < getTimestamp()) then
					outputChatBox ( 'GC: ' .. perk.description .. ' has expired!', theSource, 255, 0, 0)
					removePerkFromDatabase(forumID, perk.ID)
				else
					loadPerk(theSource, perk.ID)
				end
			end
			getPerks(forumID, 
			function(newPerks)
				triggerClientEvent( theSource, 'itemLogin', theSource, perks, newPerks )
				-- Trigger the event once more with a delay
				setTimer(triggerClientEvent, 5000, 1, theSource, 'itemLogin', theSource, perks, newPerks)
				
			end)
		end)
	end)
end
addEventHandler("onGCShopLogin", root, onGCShopLogin)

function onGCShopLogout (forumID)
	local src = source
	getPerks(forumID, 
	function(perks) 
		for _, perk in pairs(perks) do
			unloadPerk(src, perk.ID)
		end
	end)
end
addEventHandler("onGCShopLogout", root, onGCShopLogout)

function buyPerk ( player, cmd, ID )
	if client and client ~= player then return end
	
	ID = tonumber(ID)
	local i = perks[ID]
	
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	
	if (not forumID) then
		outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
		return
	elseif not ID or type(i) ~= 'table' then
		outputChatBox('Not a valid perk (use the correct name or ID)', player, 255, 0, 0 )
		return
	elseif i.disabled then
		outputChatBox('Perk purchase has been disabled', player, 255, 0, 0 )
		return
	end
	
	-- Check if perk is already bought, and check for required perks
	local idsToCheck = {ID}
	if i.requires then
		for i, perk in ipairs(i.requires) do
			table.insert(idsToCheck, perk)
		end
	end

	checkPerk(forumID, idsToCheck, 
	function(res)
		if res and res[ID] then
			outputChatBox('You already bought this perk: '..i.description, player, 255, 165, 0 )
			return
		elseif i.requires and res then
			for _, perk in ipairs(i.requires) do
				if not res[perk] then
					outputChatBox('This perk requires another perk: '..perks[perk].description, player, 255, 0, 0 )
					return			
				end
			end
		end

		local result, error = gcshopBuyItem ( player, i.price, 'Perk: ' .. i.description )
		if result == true then
			local added = addPerkToDatabase( forumID, ID, i.exp )
			if type(i.defaultAmount) == 'number' then
				setPerkSetting(player, ID, 'amount', i.defaultAmount, nil, function() end)
			end
			addToLog ( '"' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought perk=' .. tostring(ID) .. ' ' .. tostring(i.description) ..  ' ' .. tostring(i.defaultAmount) ..  ' ' .. tostring(added))
			outputChatBox ('Perk \"' .. i.description  .. '\" bought.', player, 0, 255, 0)
			loadPerk( player, ID )
			getPerks(forumID, 
			function(thePerks)
				triggerClientEvent( player, 'itemLogin', player, perks, thePerks ) 
			end)
			return
		end
		if error then
			outputChatBox( 'An error occured, try reconnecting and notify an admin if you lost GC!', player, 255, 0, 0 )
			addToLog ( 'Error: "' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought perk=' .. tostring(ID) .. ' Result=' .. tostring(result) .. ' Error=' .. tostring(error))
		end
	end)
end
addCommandHandler('gcbuyperk', buyPerk)
addEvent('gcbuyperk', true)
addEventHandler('gcbuyperk', root, buyPerk)

function buyPerkExtra ( player, cmd, ID, total )
	if client and client ~= player then return end
	
	ID = tonumber(ID)
	total = math.floor(total)
	local i = perks[ID]
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	
	if (not forumID) then
		outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
		return
	elseif not ID or type(i) ~= 'table' or not tonumber(i.defaultAmount) then
		outputChatBox('Not a valid perk (use the correct name or ID)', player, 255, 0, 0 )
		return
	elseif i.disabled then
		outputChatBox('Perk purchase has been disabled', player, 255, 0, 0 )
		return
	elseif not total then
		outputChatBox('Not a valid amount (use a number)', player, 255, 0, 0 )
		return
	end

	local result, error = gcshopBuyItem ( player, i.price * total, 'Perk extra: ' .. i.description .. ' x' .. total )
	
	if result == true then
		local theSource = source
		getPerkSettings(player, ID, 
		function(perkSetting)
			setPerkSetting(player, ID, 'amount', perkSetting.amount + total, false, 
			function(added) 
				addToLog ( '"' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought extra perk=' .. tostring(ID) .. ' ' .. tostring(i.description) ..  ' ' .. tostring(i.defaultAmount) ..  ' ' .. tostring(total) ..  ' ' .. tostring(added))
				outputChatBox ('Extra \"' .. i.description  .. '\" bought.', player, 0, 255, 0)
				--loadPerk( player, ID )
				
				getPerks(forumID, 
				function(res) 
					triggerClientEvent( theSource, 'itemLogin', theSource, perks, res )
				end)
			end)
		end)
		return
	end
	if error then
		outputChatBox( 'An error occured, try reconnecting and notify an admin if you lost GC!', player, 255, 0, 0 )
		addToLog ( 'Error: "' .. getPlayerName(player) .. '" (' .. tostring(forumID) .. ') bought extra perk=' .. tostring(ID) .. ' Result=' .. tostring(result) .. ' Error=' .. tostring(error))
	end
end
addCommandHandler('gcbuyperkextra', buyPerkExtra)
addEvent('gcbuyperkextra', true)
addEventHandler('gcbuyperkextra', root, buyPerkExtra)

function addPerkToDatabase( forumID, ID, duration )
	if not perks[ID] or not handlerConnect then return false end
	if not duration then
		return dbExec(handlerConnect, "INSERT INTO gc_items (forumid,itembought) VALUES (?,?)", forumID, ID)
	else
		duration = duration * 24 * 3600 + getTimestamp()
		if not duration then return false end
		return dbExec(handlerConnect, "INSERT INTO gc_items (forumid,itembought,expires) VALUES (?,?,?)", forumID, ID, duration)
	end
end

function removePerkFromDatabase( forumID, ID )
	if not perks[ID] or not handlerConnect then return false end
	return dbExec(handlerConnect, "DELETE FROM gc_items WHERE forumid=? AND itembought=?", forumID, ID)
end

function isPerkAllowedInMode(perkID, mode)
	if getResourceFromName('race') and getResourceState(getResourceFromName('race')) == 'running' then mode = exports.race:getRaceMode() end
	outputDebugString(mode)
	local p = perks[perkID]
	if (not p.modes) then return true end
	if type(p.modes) ~= 'table' then error('expected table ' .. perkID, 2) end
	for _, m in ipairs(p.modes) do
		if m == mode then
			return true
		end
	end
	return false
end

function getPerks(forumID, callback)
	if type(callback) ~= 'function' then
		outputDebugString( 'getPerks: No callback specified at argument #2', 1 )
		return
	end

	dbQuery(
		function(query) 
			local result = dbPoll(query,0)
			local perkIdTable = {}
			for _, prk in ipairs(result) do
				table.insert(perkIdTable, prk.itembought)
			end
			getPerkExpire(forumID, perkIdTable, 
			function(expired)
				local return_perks = {}
				for _, row in ipairs(result) do
					if perks[row.itembought] then
						--table.insert(return_perks, perks[row.itembought])
						return_perks[ tonumber(row.itembought) ] = perks[tonumber(row.itembought)]
						return_perks[ tonumber(row.itembought) ].expires = expired[row.itembought] or nil
						return_perks[ tonumber(row.itembought) ].options = fromJSON(row.options)
					end
				end
				callback(return_perks)
			end)
		end, 
	handlerConnect, "SELECT * FROM gc_items WHERE forumid=?", forumID)
end

function checkPerk ( forumID, ID, callback )
	-- ID can be a table too
	if type(callback) ~= 'function' then
		outputDebugString( 'checkPerk: No callback specified at argument #3', 1 )
		return
	end
	if type(id) == 'table' then
		-- Check for multiple ID's
		local idsToCheck = {}
		for i, theID in ipairs(ID) do
			idsToCheck[tostring(theID)] = true
		end

		dbQuery(
			function(query) 
				local result = dbPoll(query,0)
				if #result == 0 then
					callback({})
					return
				end
				local returnVal = {}
				for i, row in ipairs(result) do
					if idsToCheck[tostring(row.itembought)] then
						returnVal[tonumber(row.itembought)] = true
					end
				end
				callback(returnVal)
			end, 
		handlerConnect, "SELECT * FROM gc_items WHERE forumid=?", forumID)
	else
		dbQuery(
			function(query) 
				local result = dbPoll(query,0)
				callback(result and #result >= 1)
			end, 
		handlerConnect, "SELECT * FROM gc_items WHERE forumid=? AND itembought=?", forumID, ID)
	end
end

function getPerkExpire ( forumID, ID, callback )
	-- ID can be a table too
	if type(callback) ~= 'function' then
		outputDebugString( 'getPerkExpire: No callback specified at argument #3', 1 )
		return
	elseif not forumID then 
		callback(false)
		-- outputDebugString('getPerkExpire: No forumID argument', 1)
		return
	end

	if type(ID) == 'table' then
		local queryString = dbPrepareString(handlerConnect, 'SELECT * FROM gc_items WHERE forumid = ?', forumID)
		for ind, prk in ipairs(ID) do
			if ind == 1 then
				queryString = queryString .. ' AND ('
			end
			
			if prk and tonumber(prk) then
				local addedQuery = dbPrepareString(handlerConnect, 'itembought = ?', prk)
				if addedQuery then
					queryString = queryString .. addedQuery
				end

				if ID[ind+1] then
					queryString = queryString .. ' OR '
				else
					queryString = queryString .. ')'
				end
			end
		end
		dbQuery(
			function(query) 
				local result = dbPoll(query,0)
				if result == false then
					outputDebugString('Invalid query: '..queryString)
				end
				if type(result) == 'table' then
					local returnVal = {}
					for _, row in ipairs(result) do
						returnVal[row.itembought] = row.expires or nil
					end
					callback(returnVal)
				else
					callback(false)
				end
			end,
		handlerConnect, queryString)
	else
		dbQuery(
			function(query) 
				local result = dbPoll(query,0)
				callback(result and result[1].expires or nil)
			end,
		handlerConnect, "SELECT * FROM gc_items WHERE forumid=? AND itembought=?", forumID, ID)
	end
end

function loadPerk(player, ID)
	if not isElement(player) or not perks[ID] then return end
	getPerkSettings(player, ID,
	function(perkSettings)
		_G[perks[ID].func](player, true, perkSettings)
		outputDebugString('Perk loaded: ' .. getPlayerName(player) .. ' ' .. ID .. ' ' .. perks[ID].description .. (tonumber(perkSettings.amount) and ' (' .. perkSettings.amount .. ')' or ''))		
	end)
end

function unloadPerk(player, ID)
	if not isElement(player) or not perks[ID] then return end
	outputDebugString('Perk unloading: ' .. getPlayerName(player) .. ' ' .. ID .. ' ' .. perks[ID].description)
	_G[perks[ID].func](player, false)
end

function getPerkSettings(player, ID, callback)
	
	ID = tonumber(ID)
	local i = perks[ID]
	if type(callback) ~= 'function' then
		outputDebugString( 'getPerkSettings: No callback specified at argument #3', 1 )
		return
	end

	if type(player) == 'table' then
		if #player < 1 then
			-- outputDebugString( 'getPerkSettings: No entries in player table', 1 )
			-- outputDebugString( debug.traceback() )
			-- outputConsole( debug.traceback() )
			callback(false)
			return
		end
		local playerToForumId = {}
		local queryString = dbPrepareString(handlerConnect, 'SELECT forumid, options FROM gc_items WHERE itembought=? AND (', ID)
		for ind, p in ipairs(player) do
			local forumID = tonumber(exports.gc:getPlayerForumID ( p )) or 0
			playerToForumId[forumID] = p
			-- table.insert(queryTable, 'SELECT options FROM gc_items WHERE forumid='..forumID..' AND itembought='..ID..';')
			queryString = queryString .. dbPrepareString(handlerConnect, '(forumid=?) ', forumID)
			if player[ind+1] then
				queryString = queryString .. 'OR '
			else
				queryString = queryString .. ')'
			end
		end
		-- outputDebugString(queryString)
		dbQuery(
			function(qh)
				local result = dbPoll(qh, 0)
				local returnVal = {}
				for i, row in ipairs(result) do
					local option = fromJSON(row.options)
					if type(option) ~= 'table' then
						outputDebugString('GC Perks: wrong options format [' .. tostring(row.forumid))
					elseif not row.forumid or not tonumber(row.forumid) or not playerToForumId[tonumber(row.forumid)] then
						outputDebugString('GC Perks: wrong options format [' .. tostring(row.forumid))
					else
						returnVal[playerToForumId[tonumber(row.forumid)]] = row.options
					end
				end
				callback(returnVal)
			end, handlerConnect, queryString)
	else
		local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
		if (not forumID) or (not ID or type(i) ~= 'table') then
			callback(false)
			return
		end
		dbQuery(
			function(query) 
				local result = dbPoll(query,0)
				local options = {}
				if result[1] and result[1].options then
					options = fromJSON(result[1].options)
				end
				if type(options) ~= 'table' then 
					outputDebugString('GC Perks: wrong options format [' .. forumID, 1)
					callback(false)
					return  
				end
				callback(options)
			end, 
		handlerConnect, "SELECT options FROM gc_items WHERE forumid=? AND itembought=?", forumID, ID)
		
	end
end

function setPerkSetting(player, ID, key, value, text, callback)
	if type(callback) ~= 'function' then
		outputDebugString( 'setPerkSetting: No callback specified at argument #6', 1 )
		return
	end

	ID = tonumber(ID)
	local i = perks[ID]
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	checkPerk ( forumID, ID, 
	function(bool)
		if not bool then
			callback(false)
			return
		end

		if (not forumID) or (not ID or type(i) ~= 'table') then
			callback(false)
			return
		end
		
		dbQuery(
			function(query) 
				local result = dbPoll(query,0)
				local options = fromJSON(result[1].options)
				if type(options) ~= 'table' then return outputDebugString('GC Perks: wrong options format [' .. forumID, 1) and false end
				
				options[key] = value
				options = toJSON(options)
				if type(options) ~= 'string' then return outputDebugString('GC Perks: error adding option [' .. forumID, 1) and false end
				local result = dbExec(handlerConnect, "UPDATE gc_items SET options=? WHERE forumID=? AND itembought=?", options, forumID, ID)
				
				if type(text) == 'string' then
					outputChatBox(tostring(text), player, 0, 255, 0)
				end
				
				callback(result)
			end, 
		handlerConnect, "SELECT options FROM gc_items WHERE forumid=? AND itembought=?", forumID, ID)
	end)
end


----------------
---   Flip   ---
----------------

local newHealth = 500
function callFlip(player)
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	if not forumID then
		outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
		return false
	end
	local veh = getPedOccupiedVehicle(player)
	local currentPlayerState = getElementData(player, 'state', false)
	if busy_with_player[player] or getElementData(player,"race.finished") or not items.Flip.allowedWhen.raceState[currentRaceState] or not items.Flip.allowedWhen.raceMode[exports.race:getRaceMode()] or not items.Flip.allowedWhen.playerState[currentPlayerState] then
		-- outputChatBox('1. Not allowed at the moment', player, 255, 0, 0 )
	elseif veh then
		local vehHealth = getElementHealth(veh)
		local rx, ry, rz = getElementRotation(veh)
		local vx, vy, vz = getElementVelocity(veh)
		local v = math.sqrt(vx^2 + vy^2 + vz^2)
		if (((160<rx and rx<200) and not (160<ry and ry<200)) or ((160<ry and ry<200) and not (160<rx and rx<200))) and v < 0.05 then
			flipPlayer(player)
		end
	else
		outputChatBox('No vehicle .. shouldnt happen', player, 255, 165, 0 )
	end
end
addCommandHandler('gcflipv2', callFlip, false, false)
-- addCommandHandler('flip', function(p) outputChatBox('p') setElementRotation(getPedOccupiedVehicle(p), 180,0,0) end )

function flipPlayer(player)	
	local veh = getPedOccupiedVehicle(player)

	busy_with_player[player] = true

	local px, py, pz = getElementPosition(veh)
	local rx, ry, rz = getElementRotation(veh)
	local vx, vy, vz = getElementVelocity(veh)
	local newHealth = (getElementHealth(veh) < newHealth and newHealth) or getElementHealth(veh)
	if gcshopBuyItem ( player, items.Flip.price, 'Flip' ) then
		setElementHealth(veh, newHealth)
		setTimer(
			function()
				setElementVelocity(veh,0,0,0)
				setVehicleTurnVelocity(veh,0,0,0)
				setElementRotation(veh, rx, ry + 180, rz)
				setElementHealth(veh, newHealth)
				busy_with_player[player] = false
			end,
			250, 1 )
		local marker = createMarker( px, py, pz, 'corona', 2)
		attachElements(marker, veh)
		setTimer ( destroyElement, 2000, 1, marker )
		local marker1 = createMarker( px+.1, py, pz, 'corona', 2)
		attachElements(marker1, veh)
		setTimer ( destroyElement, 2000, 1, marker1 )
		outputChatBox ( 'You got flipped!', player, 0x00, 0xFF )
	end
end


-----------------
---   Spawn   ---
-----------------

local spawnIndex = {}
local allSpawnpoints = {}
function mapRestart ( mapInfo, mapOptions, gameOptions )
	-- reset previousSpawn
	previousSpawn = {}
	spawnIndex = {}
	lshift, rshift = {}, {}
	allSpawnpoints = getElementsByType('spawnpoint', getResourceRootElement(exports.mapmanager:getRunningGamemodeMap ()))
	if #getElementsByType('checkpoint') > 0 then
		table.sort(allSpawnpoints, function (spawnA, spawnB)
			local a_x, a_y, a_z, a_id = getSpawnpointPosition ( spawnA )
			local b_x, b_y, b_z, b_id = getSpawnpointPosition ( spawnB )
			local c_x, c_y, c_z = getElementPosition(getElementsByType('checkpoint')[1])
			return getDistanceBetweenPoints3D( a_x, a_y, a_z, c_x, c_y, c_z) < getDistanceBetweenPoints3D( b_x, b_y, b_z, c_x, c_y, c_z)
		end)
	end
	if #allSpawnpoints == 0 then
		--Some maps aren't converted to MTA 1.0 format so they do not return checkpoints.
		return false
	end	
	-- local c_x, c_y, c_z = getElementPosition(getElementsByType('checkpoint')[1])
	-- for k,spawn in ipairs(allSpawnpoints) do
		-- local a_x, a_y, a_z, id, vehID, rot = getSpawnpointPosition ( spawn )
		-- local dis = getDistanceBetweenPoints3D( a_x, a_y, a_z, c_x, c_y, c_z)
		-- outputDebugString(k..': '.. id .. '( ' .. math.floor(dis*100)/100 .. ')')
	-- end
end
addEventHandler ( "onMapStarting", root, mapRestart )

function callSpawn ( player )
	if #allSpawnpoints == 0 then
		return false
	end	
	local currentPlayerState = getElementData(player, 'state', false)
	local forumID = tonumber(exports.gc:getPlayerForumID ( player ))
	local elementID
	if not items.Spawn.allowedWhen.raceState[currentRaceState] or not items.Spawn.allowedWhen.raceMode[exports.race:getRaceMode()] or not items.Spawn.allowedWhen.playerState[currentPlayerState] then
		-- return outputChatBox('3. Not allowed at the moment', player, 255, 0, 0 )
	elseif not forumID then
		return outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
	elseif not spawnIndex[player] then
		if gcshopBuyItem ( player, items.Spawn.price, 'Spawn' ) then
			elementID, distance, index = changeSpawn(player)
			outputChatBox('[GC] Use shift+3 to go back to a previous spawnpoint', player, 0,255,0)
		end
	elseif getPedOccupiedVehicle(player) then
		elementID, distance, index = changeSpawn(player)
	end
	if elementID then
		return outputConsole("Changed to spawnpoint "..index..". Distance: "..distance.."m", player) -- less info
		-- return outputChatBox('[GC] Changed to spawnpoint \"' .. tostring(elementID) .. '\" .. ('..index..'/'..distance..'m)', player, 0,255,0)
	end
end
	
function changeSpawn (player)
	local x, y, z, id, vehID, rot
	local newSpawnpoint, currentSP
	local x2, y2, z2
	local distance
	
	local veh = getPedOccupiedVehicle(player)
	if not veh then return end

	-- create a new spawnpoint entry
	if not spawnIndex[player] then
		spawnIndex[player] = 1
	else
		-- try to skip spawns at the same position
		for i=1,25 do 
			-- go to next/previous spawn 
			currentSP = spawnIndex[player] -- current sp
			spawnIndex[player] = spawnIndex[player] + (getShiftState(player) and -1 or 1) -- next sp
			-- check bounds
			if spawnIndex[player] > #allSpawnpoints then spawnIndex[player] = 1 
			elseif spawnIndex[player] < 1 then spawnIndex[player] = #allSpawnpoints
			end			
			-- check distance between spawn i and i+1
			x2, y2, z2, _, _, _ = getSpawnpointPosition( allSpawnpoints[currentSP] )
			x, y, z, _, _, _ = getSpawnpointPosition( allSpawnpoints[spawnIndex[player]] )
			distance = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			-- outputChatBox("sp "..currentSP.." -> "..spawnIndex[player]..", dist: ".. distance) -- debug
			
			-- next sp is far enough, stop searching, example:
			-- spawn 1 -> 2, dist: 0		bad
			-- spawn 2 -> 3, dist: 0		bad
			-- spawn 3 -> 4, dist: 1.5		ok
			if distance > 0.5 then
				break
			end
			
		end -- for
	end
	
	newSpawnpoint = allSpawnpoints[spawnIndex[player]]
	x, y, z, id, vehID, rot = getSpawnpointPosition(newSpawnpoint)
	
	setElementPosition(veh, x,y,z)
	setElementRotation(veh, 0,0,rot)
	setElementModel(veh, vehID)
	setElementHealth(veh, 1000)
		
	modShopCheckVehicleAgain(player)
	distance = getElementsByType('checkpoint')[1] and math.floor(100*getDistanceBetweenPoints3D(x,y,z,getElementPosition(getElementsByType('checkpoint')[1])))/100 or 0
	return id, distance, spawnIndex[player]
end
addCommandHandler('gcspawn', callSpawn, false, false)

function getSpawnpointPosition ( element )
	-- returns: posX, posY, posZ, element_id, vehicle_id, vehicle_rotation
	local x = tonumber(getElementData(element, 'posX'))
	local y = tonumber(getElementData(element, 'posY'))
	local z = tonumber(getElementData(element, 'posZ'))
	local id = getElementID(element)
	local vehID = tonumber(getElementData(element, 'vehicle'))
	local rot = tonumber(getElementData(element, 'rotation') or getElementData(element, 'rotZ'))
	return x, y, z, id, vehID, rot
end


---------------------------
---   Shift detection   ---
---------------------------

local lshift, rshift = {}, {}

function shift ( player, key, state )
	if key == 'lshift' then
		lshift[player] = state == 'down' and true or nil
	elseif key == 'rshift' then
		rshift[player] = state == 'down' and true or nil
	end
end
for k,v in ipairs(getElementsByType('player')) do
	bindKey( v, 'lshift', 'both', shift)
	bindKey( v, 'rshift', 'both', shift)
end

addEventHandler('onPlayerJoin', root, function()
	bindKey( source, 'lshift', 'both', shift)
	bindKey( source, 'rshift', 'both', shift)
end)
addEventHandler('onPlayerQuit', root, function()
	lshift[source] = nil
	rshift[source] = nil
end)

function getShiftState ( player )
	return lshift[player] or rshift[player]
end

--------------------------
---   Rocket Colors   ---
--------------------------
function setPlayerRocketColor(player,color)
	local fID = exports.gc:getPlayerForumID ( player )
	if not color or #color ~= 7 then outputChatBox("Something went wrong, please try again!",player) return false end
	if not fID then outputChatBox("You are not logged in to a gc account!",player) return false end

	local exec = dbExec(handlerConnect, "UPDATE gc_rocketcolor SET color=? WHERE forumid=?", color:gsub("#",""), fID)

	
	if exec then setElementData(player,"gc_projectilecolor","#"..color) return true end

	return false

end

addEvent("serverRocketColorChange",true)
function rockerColorChange(hex)
	local thePlayer = client
	if not thePlayer or not isElement(thePlayer) or getElementType(thePlayer) ~= "player" then return end
	local setColor = setPlayerRocketColor(thePlayer,hex)
	
	triggerClientEvent(thePlayer,"clientRocketColorChangeConfirm",resourceRoot,setColor or false)

end
addEventHandler("serverRocketColorChange",root,rockerColorChange)

function getPlayerRocketColor(player, callback)
	if type(callback) ~= 'function' then
		outputDebugString( 'getPlayerRocketColor: No callback specified at argument #2', 1 )
		return
	end

	local forumID = exports.gc:getPlayerForumID ( player )
	if not forumID then 
		callback(false)
		return
	end

	dbQuery(
		function(query) 
			local result = dbPoll(query,0)

			if result[1] and result[1]["color"] then
				callback(result[1]["color"])
				return
			end
			callback(false)
		end, 
	handlerConnect, "SELECT color FROM gc_rocketcolor WHERE forumid=?", forumID)
end

function insertPlayerRocketColorToDB(player)
	local forumID = exports.gc:getPlayerForumID ( player )
	if not forumID then return false end

	return dbExec(handlerConnect, "INSERT INTO gc_rocketcolor (forumid,color) VALUES (?,?)", forumID,"00FF00" )
end


--------------------------
---   DeadLine Colors  ---
--------------------------
function loadDeadlineColorChange ( player, bool )
	if bool then
		getPlayerDeadLineColor(player, 
		function(color) 
			if not color then
				outputDebugString("Could not find Color for "..getPlayerName(player))
				insertDeadLineColorToDB(player)
				color = "00FF00"
			end
			setElementData(player,"gcshop_deadlinecolor","#"..color:gsub("#","")) 
		end)
	else
		removeElementData( player, 'gcshop_deadlinecolor' )
	end
end

addEvent("serverDeadLineColorChange",true)
function deadlineColorChange(hex)
	local thePlayer = client
	if not thePlayer or not isElement(thePlayer) or getElementType(thePlayer) ~= "player" then return end
	local setColor = setPlayerDeadLineColor(thePlayer,hex)
	
	triggerClientEvent(thePlayer,"clientDeadLineColorChangeConfirm",resourceRoot,setColor or false)

end
addEventHandler("serverDeadLineColorChange",root,deadlineColorChange)

function setPlayerDeadLineColor(player,color)
	local fID = exports.gc:getPlayerForumID ( player )
	if not color or #color ~= 7 then outputChatBox("Something went wrong, please try again!",player) return false end
	if not fID then outputChatBox("You are not logged in to a gc account!",player) return false end

	local exec = dbExec(handlerConnect, "UPDATE gc_deadlinecolor SET color=? WHERE forumid=?", color:gsub("#",""), fID)

	
	if exec then setElementData(player,"gcshop_deadlinecolor","#"..color:gsub("#","")) return true end

	return false

end

function getPlayerDeadLineColor(player, callback)
	if type(callback) ~= 'function' then
		outputDebugString( 'getPlayerDeadLineColor: No callback specified at argument #2', 1 )
		return
	end

	local forumID = exports.gc:getPlayerForumID ( player )
	if not forumID then 
		callback(false)
		return false 
	end

	dbQuery(
		function(query) 
			local result = dbPoll(query,0)

			if result[1] and result[1]["color"] then
				callback(result[1]["color"])
				return 
			end

			callback(false)
		end, 
	handlerConnect, "SELECT color FROM gc_deadlinecolor WHERE forumid=?", forumID)
end

function insertDeadLineColorToDB(player)
	local forumID = exports.gc:getPlayerForumID ( player )
	if not forumID then return false end

	return dbExec(handlerConnect, "INSERT INTO gc_deadlinecolor (forumid,color) VALUES (?,?)", forumID,"00FF00" )
end

--------------------------
---   Tool functions   ---
--------------------------

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
 
    -- calculate timestamp
    for i=1970, year-1 do
		timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000)
	end
    for i=1, month-1 do
		timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i])
	end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
 
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
 
    return timestamp
end

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function doesTableExist ( name )
	if type(name) ~= "string" then
		outputDebugString("doesTableExist: #1 not a string", 1)
		return false
	end
	name = safeString (name)
	local cmd = "SELECT tbl_name FROM sqlite_master WHERE tbl_name = '" .. name .. "'"
	local results = executeSQLQuery( cmd )
	return results and (#results > 0)
end

function safeString(s)
    s = string.gsub(s, '&', '&amp;')
    s = string.gsub(s, '"', '&quot;')
    s = string.gsub(s, '<', '&lt;')
    s = string.gsub(s, '>', '&gt;')
    return s
end
