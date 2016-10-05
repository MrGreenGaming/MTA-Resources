addEvent("onPlayerReachCheckpoint", true)
addEventHandler("onPlayerReachCheckpoint", root,
	function()
		incrementPlayerStatsData(source, "temp_id4", 1)
	end
)

addEvent("onPlayerFinish")
addEventHandler("onPlayerFinish", root,
	function(rank)
		local modename = exports.race:getRaceMode()
		if modename == "Sprint" then 
			incrementPlayerStatsData(source, "temp_id4", 1)
			savePlayerStat(source, "id2", 1)
			if rank == 1 then
				savePlayerStat(source, "id3", 1)
			end
		elseif modename == "Never the same" then 
			incrementPlayerStatsData(source, "temp_id4", 1)
			savePlayerStat(source, "id8", 1)
			if rank == 1 then
				savePlayerStat(source, "id9", 1)
			end
		elseif modename == "Reach the flag" then 
			savePlayerStat(source, "id11", 1)
		end
	end
)

local startRaceModeIDs = { 
					["Sprint"] = "temp_id1",
					["Never the same"] = "temp_id7",
					["Reach the flag"] = "temp_id10"
}

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", root,
	function(newStateName, oldStateName)
		local modename = exports.race:getRaceMode()
		local id = startRaceModeIDs[modename]
		if not id then return end
		
		currentRaceStateName = newStateName
		if oldStateName == "GridCountdown" and newStateName == "Running" then
			for _, player in ipairs(getElementsByType"player") do
				incrementPlayerStatsData(player, id, 1)
			end
		end
	end
)

addEvent("onNotifyPlayerReady", true)
addEventHandler("onNotifyPlayerReady", root, 
	function()
		local modename = exports.race:getRaceMode()
		local id = startRaceModeIDs[modename]
		if not id then return end
		
		if currentRaceStateName == "Running" then
			incrementPlayerStatsData(source, id, 1)
		end
	end
)

addEventHandler("onPlayerWasted", root,
	function(ammo, attacker, weapon, bodypart)
		incrementPlayerStatsData(source, "temp_id6", 1)
	end
)

addEvent('onPlayerFinishDD')
addEventHandler('onPlayerFinishDD', root, 
	function()
		incrementPlayerStatsData(source, "temp_id12", 1)
	end
)

addEvent('onPlayerWinDD')
addEventHandler('onPlayerWinDD', root, 
	function()
		savePlayerStat(source, "id13", 1)
	end
)

addEvent('onDDPlayerKill')
addEventHandler('onDDPlayerKill', root, 
	function()
		savePlayerStat(source, "id14", 1)
	end
)

addEventHandler('onCTFFlagDelivered', root, 
	function()
		savePlayerStat(source, "id15", 1)
	end
)

addEvent('onPlayerFinishShooter')
addEventHandler('onPlayerFinishShooter', root, 
	function()
		incrementPlayerStatsData(source, "temp_id16", 1)
	end
)

addEvent('onPlayerWinShooter')
addEventHandler('onPlayerWinShooter', root, 
	function()
		savePlayerStat(source, "id17", 1)
	end
)

addEvent('onShooterPlayerKill')
addEventHandler('onShooterPlayerKill', root, 
	function()
		savePlayerStat(source, "id18", 1)
	end
)

function showGUI(playerInitiator, _, _, player)
	if not playerInitiator then playerInitiator = client end
	if not player then player = playerInitiator end

	local forumID = exports.gc:getPlayerForumID(player)
	if not forumID then return false end
	if not playerStatsCache[forumID] then return false end
	
	updateToptimes(forumID)
	
	playerStatsCache[forumID]["joinDate"] = getDateFromTimestamp( exports.gc:getPlayerForumJoinTimestamp(player) )
	
	local this_session = getPlaytime(playerStatsCache[forumID]["joinTime"])
	playerStatsCache[forumID]["total_playtime"] = this_session + playerStatsCache[forumID]["id5"]
	
	triggerClientEvent(playerInitiator, "sendPlayerStats", resourceRoot, playerStatsCache[forumID], player)
end
addEvent("showGUI", true)
addEventHandler("showGUI", root, showGUI)

addEventHandler("onResourceStart", resourceRoot, 
	function()
		for _, player in pairs(getElementsByType"player") do
			bindKey(player, "F10", "down", showGUI)
		end
	end
)

addEventHandler("onPlayerJoin", root, 
	function()
		bindKey(source, "F10", "down", showGUI)
	end
)