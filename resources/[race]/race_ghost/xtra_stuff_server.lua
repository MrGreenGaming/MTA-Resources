
---------------------------------------------------------------------------
--
-- Commands and binds
--
--
--
---------------------------------------------------------------------------

addCommandHandler( "deleteghost",
	function( player )
		if isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			if playback then
				local mapName = getResourceName( playback.map )
				if playback:deleteGhost() then
					outputChatBox( "Ghost racer for map '" .. tostring(mapName) .. "' deleted by " .. getPlayerName(player) )
					outputServerLog( "GhostRacer: "
						.. tostring(getPlayerName(player)) .. " deleted ghost"
						.. " from map '" .. tostring(mapName) .. "'"
						)
				end
			end
		end
	end
)


function isPlayerInACLGroup(player, groupName)
	local account = getPlayerAccount(player)
	if not account then
		return false
	end
	local accountName = getAccountName(account)
	for _,name in ipairs(split(groupName,string.byte(','))) do
		local group = aclGetGroup(name)
		if group then
			for i,obj in ipairs(aclGroupListObjects(group)) do
				if obj == 'user.' .. accountName or obj == 'user.*' then
					return true
				end
			end
		end
	end
	return false
end


---------------------------------------------------------------------------
--
-- Settings
--
--
--
---------------------------------------------------------------------------

addEventHandler('onResourceStart', resourceRoot,
	function()
		cacheGameOptions()
		triggerClientEvent( root, "race_ghost.updateOptions", resourceRoot, g_GameOptions );
	end
)

-- Called from the admin panel when a setting is changed there
addEvent ( "onSettingChange" )
addEventHandler('onSettingChange', resourceRoot,
	function(name, oldvalue, value, player)
		outputDebugString( 'Setting changed: ' .. tostring(name) .. '  value:' .. tostring(value) .. '  value:' .. tostring(oldvalue).. '  by:' .. tostring(player and getPlayerName(player) or 'n/a') )
		cacheGameOptions()
		triggerClientEvent( root, "race_ghost.updateOptions", resourceRoot, g_GameOptions );
	end
)

function cacheGameOptions()
	g_GameOptions = {}
	g_GameOptions.verboselog			= getBool('race_ghost.verboselog',false)
	g_GameOptions.alphavalue			= getNumber('race_ghost.alphavalue',120)
	g_GameOptions.admingroup			= getString('race_ghost.admingroup','Admin')
	g_GameOptions.recordpersonalbests	= getBool('race_ghost.recordpersonalbests',false)
	g_GameOptions.validatespawn			= getBool('race_ghost.validatespawn',false)
	g_GameOptions.validatetime			= getBool('race_ghost.validatetime',false)
	g_GameOptions.hideatstart			= getBool('race_ghost.hideatstart',false)
	g_GameOptions.fillplayerslots		= getNumber('race_ghost.fillplayerslots',0)
	g_GameOptions.maxghosttime			= getNumber('race_ghost.maxghosttime',10) * 60 * 1000
end

function setGhostsAmount(source, command, amount)
	-- Fail checks
	if command ~= "ghosts" then return end
	if isGuestAccount(getPlayerAccount(source)) then return end
	if not amount then return outputChatBox("Usage: /ghosts [amount]. Maximum is 12 ghosts.", source) end
	if tonumber(amount) == nil then return end
	
	-- Check for valid value
	amount = tonumber(amount)
	if amount > 12 then amount = 12
	elseif amount < 0 then amount = 0 end
	
	-- Save settings
	setAccountData(getPlayerAccount(source), "race_ghost.amount", amount)
	triggerClientEvent(source, "updateRaceGhostsAmount", source, amount)
end
addCommandHandler("ghosts", setGhostsAmount)

addEventHandler("onPlayerLogin", root, function()
	local ghostsAmount = tonumber(getAccountData(getPlayerAccount(source), "race_ghost.amount"))
	if ghostsAmount == nil then ghostsAmount = 12 end -- set default value
	
	triggerClientEvent(source, "updateRaceGhostsAmount", source, ghostsAmount)
end )

---------------------------------------------------------------------------
--
-- gets
--
---------------------------------------------------------------------------

-- get string or default
function getString(var,default)
    local result = get(var)
    if not result then
        return default
    end
    return tostring(result)
end

-- get number or default
function getNumber(var,default)
    local result = get(var)
    if not result then
        return default
    end
    return tonumber(result)
end

-- get true or false or default
function getBool(var,default)
    local result = get(var)
    if not result then
        return default
    end
    return result == 'true'
end


---------------------------------------------------------------------------
--
-- Spam
--
--
--
---------------------------------------------------------------------------

function outputDebugServer( msg, mapname, player, extra )
	if g_GameOptions.verboselog == false and _DEGUG == false then
		return
	end

	local status = "race_ghost: "
	if msg then
		status = status ..tostring(msg)
	end
	if mapname then
		status = status .. " for " .. tostring(mapname)
	end
	if player then
		if type(player) ~= "string" then
			player = tostring(getPlayerName(player))
		end
		status = status .. " by " .. tostring(player)
	end
	if extra then
		status = status .. " " .. extra
	end
	outputDebugString( status )
end


addEvent( "onDebug", true )
addEventHandler( "onDebug", resourceRoot,
	function( msg, mapname, extra )
		outputDebugServer( "[CLIENT " .. tostring(getPlayerName(client)) .. "] " .. tostring( msg ), mapname, nil, extra )
	end,
	false
)
