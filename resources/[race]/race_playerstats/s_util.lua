
g_ResName = getResourceName(resource)

local c_MaxStatValue = 1000

Stat = {
	-- Vehicles
	DIST_CAR = 4,
	DIST_BIKE = 5,
	DIST_BOAT = 6, 
	DIST_AIRCRAFT = 8,
	DIST_CYCLE = 27,
	CARS_DESTROYED = 122,
	BIKES_DESTROYED = 1125,
	BOATS_DESTROYED = 123,
	AIRCRAFT_DESTROYED = 124,
	DAMAGE_TAKEN = 1090,
	
	--Player
	TIMES_DIED = 135,
	DRIVING_SKILL = 160,
	FLYING_SKILL = 223,
	BIKE_SKILL = 229, 
	CYCLE_SKILL = 230,
	PLAYING_TIME = 1001,
	FAT = 21,
	STAMINA = 22,
	BODY_MUSCLE = 23,
	MAX_HEALTH = 24,	
	
	-- Cash
	CASH_EARNINGS = 1011,
	TOTAL_SHOPPING_BUDGET = 62,
	CURRENT_CASH_BALANCE = 1012,
	
	-- Races
	CHECKPOINTS_COLLECTED = 1024,
	TOTAL_RACES = 148,
	RACES_FINISHED = 1025,
	RACES_WON = 1026,
	TOPTIMES_SET = 1027,
	MAX_STREAKS = 1028
}

DefaultStats = {
	[21] = 999
}


function getDestroyedVehicleStatKey(modelId)
	if not modelId then return nil end
	if ModelID.MotorBikes[modelId] then return Stat.BIKES_DESTROYED end
	if ModelID.Boats[modelId] then return Stat.BOATS_DESTROYED end
	if ModelID.Aircraft[modelId] then return Stat.AIRCRAFT_DESTROYED end
	if (not ModelID.Bikes[modelId]) and (not ModelID.Exempt[modelId]) then return Stat.CARS_DESTROYED end
	return nil
end





addEvent("onPlayerStatsUpdate", true)


--
-- PLAYER STATS DATA
--

--[[
The PlayerData structure holds a in-memory copy of 
each players stats table.
It is synchronized when a map ends.

PlayerData = {
	"PlayerName" = {
		JoinTime = 0,
		Stats = {
			[4] = 0,
			[160] = 0.3242
		}
	}
}
]]

PlayerData = {}


function InitializePlayerData(playerName)
	if not PlayerData then 
		PlayerData = {}
	end

	PlayerData[playerName] = {}
	PlayerData[playerName].JoinTime = getTickCount()
	PlayerData[playerName].Stats = {}
end


---
--- EXPORTS
---


-- exported function; do extra checking
function IncrementPlayerStat(playerOrName, statKey, amount)
	if not playerOrName then
		outputDebugString("Missing first parameter: playerOrName [userdata or string]")
		return false
	end
	
	if not statKey then
		outputDebugString("Missing second parameter: statKey [integer]")
		return false
	end
	
	if not amount then
		outputDebugString("Missing third parameter: amount [float]");
		return false
	end

	if amount == 0 then
		return true
	end
	
	return IncrementPlayerStatInternal(playerOrName, statKey, amount)
end


function GetPlayerStatsTable(playerOrName)
	if not playerOrName then
		outputDebugString("Missing first parameter: playerOrName [userdata or string]")
		return false
	end
	
	return GetPlayerStatsTableInternal(playerOrName)
end

-- exported function; do extra checking
function GetPlayerStatValue(playerOrName, statKey)
	if not playerOrName then
		outputDebugString("Missing first parameter: playerOrName [userdata or string]")
		return false
	end
	
	if not statKey then
		outputDebugString("Missing second parameter: statKey [integer]")
		return false
	end
	
	return GetPlayerStatValueInternal(playerOrName, statKey)
end


-- exported function; do extra checking
function SetPlayerStatValue(playerOrName, statKey, value)
	if not playerOrName then
		outputDebugString("Missing first parameter: playerOrName [userdata or string]")
		return false
	end
	
	if not statKey then
		outputDebugString("Missing second parameter: statKey [integer]")
		return false
	end
	
	if not value then
		outputDebugString("Missing third parameter: value [float]");
		return false
	end
	
	return SetPlayerStatValueInternal(playerOrName, statKey, value)
end


-- exported function; do extra checking
function ClearPlayerStats(playerOrName, statKey)
	if not playerOrName then
		outputDebugString("Missing first parameter: playerOrName [userdata or string]")
		return false
	end
	
	if type(playerOrName) == "userdata" and getElementType(playerOrName) == "player" then
		playerOrName = getPlayerName(playerOrName)
	else
		playerOrName = tostring(playerOrName)
	end
	
	if not tonumber(statKey) then
		InitializePlayerData(playerOrName)
	else
		PlayerData[playerName].Stats[tonumber(statKey)] = nil
	end
	return true
end


--
-- INTERNALS
--

function IncrementPlayerStatInternal(playerOrName, key, amount)
	if (amount or 0) == 0 then return end
	
	local originalValue = GetPlayerStatValueInternal(playerOrName, key) or 0
	local value = originalValue + amount
	
	return SetPlayerStatValueInternal(playerOrName, key, value)
end


function GetPlayerStatsTableInternal(playerOrName)
	local player, playerName = getPlayerAndName(playerOrName)
	if PlayerData[playerName] then
		return PlayerData[playerName].Stats
	else
		return LoadPlayerStats(player)
	end
	return nil
end


function GetPlayerStatValueInternal(playerOrName, key)
	local player, playerName = getPlayerAndName(playerOrName)
	if player and (not PlayerData[playerName] or not PlayerData[playerName].Stats[key]) then
			return getElementData(player, "stats."..key, false)
	else
		if PlayerData[playerName] and PlayerData[playerName].Stats then
			return PlayerData[playerName].Stats[key]
		end
	end
	return nil
end


function SetPlayerStatValueInternal(playerOrName, key, value)
	local player, playerName = getPlayerAndName(playerOrName)
	
	if not PlayerData[playerName] then
		PlayerData[playerName] = {}
	end
	
	if not PlayerData[playerName].Stats then
		PlayerData[playerName].Stats = {}
	end
	
	local originalValue = value or 0
	if player then 
		if key < 1000 then
			-- check for overflow
			if value > c_MaxStatValue then
				value = c_MaxStatValue
			end
			setPedStat(player, key, value)
		end
		setElementData(player, "stats."..key, originalValue, false)
	end
	local previousValue = PlayerData[playerName].Stats[key] or 0
	PlayerData[playerName].Stats[key] = originalValue
	
	--outputDebugString("Key:"..tostring(key).." Value:"..tostring(originalValue).." OldValue:"..tostring(previousValue))
	
	triggerEvent("onPlayerStatsUpdate", player or root, playerName, key, value, previousValue)
	return true
end


function BatchApplyPedStats(player, statTable)
	local playerName = getPlayerName(player)
	
	if not PlayerData[playerName] then
		PlayerData[playerName] = {}
	end
	
	if not PlayerData[playerName].Stats then
		PlayerData[playerName].Stats = {}
	end
	
	for key,value in pairs(statTable) do
		local originalValue = value or 0
		if key < 1000 then
			-- check for overflow
			if value > c_MaxStatValue then
				value = c_MaxStatValue
			end
			setPedStat(player, key, value)
		end
		setElementData(player, "stats."..key, originalValue, false)
	end
end


--
-- PLAYERS
--

function getActivePlayers()
	local ret = {}
	for _,player in ipairs(getAlivePlayers()) do
		local state = isElement(player) and getElementData(player, "state", false)
		if state == "alive" then
			ret[#ret + 1] = player
		end
	end
	return ret
end

function findPlayer(name)
	if not name then return end
	local player = getPlayerFromName(name)
	if not player then
		for _,p in ipairs(getElementsByType("player")) do
			if string.find(string.lower(getPlayerName(p)), string.lower(name)) then
				player = p
				break
			end
		end
	end
	return player
end

function getPlayerAndName(player)
	local playerName
	if type(player) == "string" then
		playerName = player
		player = nil
	else
		playerName = getPlayerName(player)
	end
	-- last chance
	if not player then
		for i,p in ipairs(getElementsByType("player")) do
			if getPlayerName(p) == playerName then
				player = p
				break
			end
		end
	end

	return player, playerName
end
