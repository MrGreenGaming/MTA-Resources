
--
-- COMMANDS
--

function consoleDeleteStat(playerSource, commandName, statKey)
	if not statKey then
		alert("Syntax: /delete_stat <stat key>", "chat", playerSource)
		return
	end
	local result = DeleteStats(statKey)
	if result then
		for _,player in ipairs(getElementsByType("player")) do
			ClearPlayerStats(getPlayerName(player), tonumber(statKey))
		end
		local message = "Stats for key "..statKey.." were deleted by "..getPlayerName(playerSource)
		alert(message, "chat")
	else
		local message = "Could not delete stat for key " .. statKey
		alert(message)
		alert(message, "chat", playerSource)
	end
end
addCommandHandler("delete_stat", consoleDeleteStat, true, true)

function consoleDeletePlayerStats(playerSource, commandName, playerName)
	if not playerName then
		alert("Syntax: /delete_player_stats <player name>", "chat", playerSource)
		return
	end
	local result = DeletePlayerStats(playerName)
	if result then
		ClearPlayerStats(playerName)
		local message = "Stats for player "..playerName.." were deleted by "..getPlayerName(playerSource)
		--alert(message)
		alert(message, "chat")
	else
		local message = "Could not delete stats for player " .. playerName
		alert(message)
		alert(message, "chat", playerSource)
	end
end
addCommandHandler("delete_player_stats", consoleDeletePlayerStats, true, true)


function consoleResetStats(playerSource, commandName)
	local result = DeleteAllStats()
	if result then
		-- signal a stats reset
		g_StatsReset = true

		for _,player in ipairs(getElementsByType("player")) do
			ClearPlayerStats(getPlayerName(player))
		end
		local message = "Stats have been reset by "..getPlayerName(playerSource)
		--alert(message)
		alert(message, "chat")
	else
		local message = "Could not reset stats"
		alert(message)
		alert(message, "chat", playerSource)
	end
end
addCommandHandler("reset_stats", consoleResetStats, true, true)


function consoleDisplayStats(playerSource, commandName, playerName)
	local targetPlayer = nil
	if playerName then
		targetPlayer = findPlayer(playerName)
	end
	if not targetPlayer then
		targetPlayer = playerSource
	end
	playerName = getPlayerName(targetPlayer)
	triggerClientEvent(playerSource, "onClientUpdateStats", playerSource, playerName, PlayerData[playerName].Stats)
	triggerClientEvent(playerSource, "onClientStatsDisplay", playerSource, true)
end
addCommandHandler("stats", consoleDisplayStats, false, false)


function consoleClearUnusedStats(playerSource, commandName)
	local players = GetPlayerList()
	alert("Processing "..tostring(#players).." players...")
	local deleted = {}
	for _,player in ipairs(players) do
		local playerId = tonumber(player["rowid"])
		local playerName = tostring(player["nick"])
		local playerStats = LoadPlayerStats(playerName)
		if #playerStats > 0 then
			local points = playerStats[2010] or 0
			if points <= 0 then
				deleted[#deleted + 1] = playerName
			end
		else
			deleted[#deleted + 1] = playerName
		end
	end
	
	if #deleted > 0 then
		local count = 0
		for _, playerName in ipairs(deleted) do
			if DeletePlayer(playerName) then
				count = count + 1
			end
		end
		alert("Deleted "..tostring(count).." players from database")
	else
		alert("No players meet the deletion criteria")
	end
	
end