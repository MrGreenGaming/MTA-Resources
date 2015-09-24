
-- defined in s_util.lua
--resourceRoot = getResourceRootElement()
--local resourceName = getResourceName(getThisResource())


dbSchemaPlayers = {
	Name = "PlayerStats_Players",
	Columns = {
		{ Name="nick", Type="VARCHAR", Constraint="NOT NULL COLLATE NOCASE" },
		{ Name="serial", Type="VARCHAR", Constraint="COLLATE NOCASE" }
	}
}

dbSchemaStats = {
	Name = "PlayerStats_Stats",
	Columns = {
		{ Name="id_player", Type="INTEGER" },
		{ Name="key", Type="INTEGER" },
		{ Name="val", Type="REAL" }
	},
	Indices = {
		{ Name = "PlayerStats_PlayerIdKey", Constraint="UNIQUE", Column='"id_player", "key"' }
	}
}

function safestring(s)
    -- escape '
    return s:gsub("(['])", "''")
end

function qsafestring(s)
    -- ensure is wrapped in '
    return "'" .. safestring(s) .. "'"
end


function createTable(dbschema)
		
    local sql = "CREATE TABLE IF NOT EXISTS " .. qsafestring(dbschema.Name) .. " ("
    for i,col in ipairs(dbschema.Columns) do
        if i > 1 then
            sql = sql .. ", "
        end
        sql = sql .. qsafestring(col.Name) .. " " .. col.Type
        if col.Constraint then
        	sql = sql .. " " .. col.Constraint
        end
    end
    sql = sql .. ")"
    executeSQLQuery(sql)
    if dbschema.Indices then
    	for _,index in ipairs(dbschema.Indices) do
    		sql = "CREATE "
    		if index.Constraint then
    			sql = sql .. index.Constraint .. " "
    		end
    		sql = sql .. string.format("INDEX IF NOT EXISTS %s ON %s (%s)", index.Name, dbschema.Name, index.Column)
    		executeSQLQuery(sql)
    	end
    end
end


function GetPlayerList(sortKey, sortOrder)
	local sql = nil
	
	if not tonumber(sortKey) then
		sql = string.format("SELECT rowid, nick FROM %s", dbSchemaPlayers.Name)
	else
		sql = string.format("SELECT %s.rowid, %s.nick, %s.val ", dbSchemaPlayers.Name, dbSchemaPlayers.Name, dbSchemaStats.Name)
		sql = sql .. string.format("FROM %s JOIN %s ", dbSchemaPlayers.Name, dbSchemaStats.Name)
		sql = sql .. string.format("ON %s.rowid = %s.id_player ", dbSchemaPlayers.Name, dbSchemaStats.Name)
		sql = sql .. string.format("AND %s.key = %u ", dbSchemaStats.Name, tonumber(sortKey))
		if sortOrder then
			sql = sql .. string.format("ORDER BY %s.val %s", dbSchemaStats.Name, tostring(sortOrder))
		end
	end
	local rows = executeSQLQuery(sql)
	if rows and #rows > 0 then
		return rows
	end
	return {}
end


function GetPlayerId(player)
	if type(player) ~= "string" then 
		player = getPlayerName(player)
	end
	local cmd = string.format("SELECT rowid FROM %s WHERE nick=?", dbSchemaPlayers.Name)
	local rows = executeSQLQuery(cmd, player)
	if rows and #rows > 0 then
		return tonumber(rows[1].rowid)
	end
	return 0
end


function InsertPlayer(player)
	local cmd = string.format("INSERT INTO %s (nick, serial) VALUES (?, ?); SELECT last_insert_rowid() AS [id]", dbSchemaPlayers.Name)
	local serial = isElement(player) and getPlayerSerial(player) or ""
	local rows = executeSQLQuery(cmd, getPlayerName(player), serial)
	if rows and #rows > 0 then
		return tonumber(rows[1].id)
	end
	return 0
end


function CreatePlayer(player)
	local playerId = InsertPlayer(player)
	if playerId == 0 then
		playerId = GetPlayerId(player)
	end
	local stats = CreateDefaultStats()
	alert("Created stats for player "..getPlayerName(player)..". ID = "..tostring(playerId))
	SavePlayerStats(player, stats)
	return playerId
end


function DeletePlayer(player)
	if isElement(player) and getElementType(player) == "player" then
		player = getPlayerName(player)
	end
	local playerId = GetPlayerId(player)
	if playerId > 0 then
		if DeletePlayerStats(player) then
			local sql = string.format("DELETE FROM %s WHERE rowid=%u", dbSchemaPlayers.Name, playerId)
			local result = executeSQLQuery(sql)
			if not result then
				alert("DeletePlayer: Error deleting player "..player)
			else
				return true
			end
		end
	else
		alert("DeletePlayer: player "..player.." not found.")
	end
	return false
end

function CreateDefaultStats()
	local ret = {}
	for key,value in pairs(Stat) do
		if DefaultStats[key] then
			ret[value] = DefaultStats[key]
		end
	end
	return ret
end


function LoadPlayerStats(player)
	if not player then return nil end
	local playerId = GetPlayerId(player)
	if playerId == 0 then 
		playerId = CreatePlayer(player)
	end
	local cmd = string.format("SELECT key, val FROM %s WHERE id_player=%u", dbSchemaStats.Name, playerId)
	local rows = executeSQLQuery(cmd)
	local ret = {}
	if rows and #rows > 0 then
		for i,row in ipairs(rows) do
			ret[rows[i].key] = rows[i].val
		end
	end
	return ret
end


function SavePlayerStats(playerName, stats)
	local ret = false
	local playerId = GetPlayerId(playerName)
	if playerId == 0 then
		playerId = CreatePlayer(player)
		--alert("SavePlayerStats: Player "..playerName.." not found.")
		--return ret
	end
	executeSQLQuery("BEGIN TRANSACTION");
	for k,v in pairs(stats) do
		local cmd = string.format("INSERT OR REPLACE INTO %s (id_player, key, val) VALUES (%u, %u, %f)", dbSchemaStats.Name, playerId, k, v)
		local result = executeSQLQuery(cmd)
		if not result then
			alert("SavePlayerStats: Error updating stats for player "..tostring(playerName))
		else
			ret = true
		end
	end
	executeSQLQuery("END TRANSACTION");
	return ret
end


function DeletePlayerStats(playerName)
	local ret = false
	local playerId = GetPlayerId(playerName)
	if playerId == 0 then
		alert("DeletePlayerStats: Player "..playerName.." not found.")
		return ret
	end
--	executeSQLQuery("BEGIN TRANSACTION");
	local cmd = string.format("DELETE FROM %s WHERE id_player=%u", dbSchemaStats.Name, playerId)
	local result = executeSQLQuery(cmd)
	if not result then
		alert("DeletePlayerStats: Error deleting stats for player "..playerName)
	else
		ret = true
	end
--	executeSQLQuery("END TRANSACTION");
	return ret
end


function DeleteAllStats()
	local ret = false
--	executeSQLQuery("BEGIN TRANSACTION");
	local cmd = string.format("DELETE FROM %s", dbSchemaStats.Name)
	local result = executeSQLQuery(cmd)
	if not result then
		alert("DeleteAllStats: Error deleting stats")
	else
		ret = true
	end
--	executeSQLQuery("END TRANSACTION");
	return ret
end


function DeleteStats(statKey)
	local ret = false
	if not(tonumber(statKey)) then
		alert("DeleteStats: Invalid stat key '"..statKey.."'.")
		return ret
	end
	local cmd = string.format("DELETE FROM %s WHERE key=%u", dbSchemaStats.Name, tonumber(statKey))
	local result = executeSQLQuery(cmd)
	if not result then
		alert("DeleteStats: Error deleting stats for key "..statKey)
	else
		ret = true
	end
	return ret
end


addEventHandler("onResourceStart", resourceRoot,
	function()
		createTable(dbSchemaPlayers)
		createTable(dbSchemaStats)
	end
)