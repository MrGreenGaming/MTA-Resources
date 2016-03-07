local g_Players = {}

achievementListMix = {
	-- { achText, achID (unique!!!!), reward, max }
	{ s = "CTF: Capture two flags in one map", 							id = 1,		reward = 50 },
	{ s = "CTF: Capture three flags in one map", 						id = 12,	reward = 100 },
	{ s = "CTF: Capture the winning flag", 								id = 2,		reward = 25 },
	{ s = "CTF: Capture the winning flag when the score is tied",		id = 30,	reward = 75 },
	{ s = "CTF: Capture the flag 20 times", 							id = 31, 	reward = 100,	max = 20 },
	{ s = "CTF: Capture the flag 100 times", 							id = 32, 	reward = 300,	max = 100 },
	{ s = "CTF: Capture the winning flag 10 times", 					id = 3, 	reward = 200,	max = 10 },
	-- { s = "CTF: Win 5 rounds", 										id = 10, 	reward = 75,	max = 5  },
	-- { s = "CTF: Win 20 rounds", 										id = 11, 	reward = 200,	max = 20 },
	
	{ s = "DD: Watcher - Be the first to get killed", 					id = 29, 	reward = 15 },
	{ s = "DD: Rampage - Accumulate 5 kills in 1 round", 				id = 4, 	reward = 100 },
	{ s = "DD: Monster Kill - Accumulate 8 kills in 2 rounds", 			id = 5, 	reward = 200 },
	{ s = "DD: UNSTOPPABLE!! - Accumulate 10 kills in 3 rounds", 		id = 6, 	reward = 300 },
	{ s = "DD: Win 5 rounds", 											id = 13,	reward = 75,	max = 5  },
	{ s = "DD: Win 20 rounds", 											id = 14,	reward = 200,	max = 20 },
	{ s = "DD: Make 20 kills", 											id = 15,	reward = 100,	max = 20 },
	{ s = "DD: Make 200 kills", 										id = 16,	reward = 300,	max = 200 },
	
	{ s = "SH: Spectator - Be the first to get killed", 				id = 28, 	reward = 15 },
	{ s = "SH: Badass - Accumulate 5 kills in 1 round", 				id = 7, 	reward = 100 },
	{ s = "SH: Hitman - Accumulate 8 kills in 2 rounds", 				id = 8, 	reward = 200 },
	{ s = "SH: Terminator - Accumulate 10 kills in 3 rounds",			id = 9, 	reward = 300 },
	{ s = "SH: Win 5 rounds", 											id = 17,	reward = 75,	max = 5  },
	{ s = "SH: Win 20 rounds", 											id = 18,	reward = 200,	max = 20 },
	{ s = "SH: Make 20 kills", 											id = 19,	reward = 100,	max = 20 },
	{ s = "SH: Make 200 kills", 										id = 20,	reward = 300,	max = 200 },
	
	{ s = "NTS: Finish the map NTS-Marathon", 							id = 21,	reward = 75 },
	{ s = "NTS: Win the map NTS-Marathon", 								id = 22,	reward = 200 },
	{ s = "NTS: Finish the map NTS-Sunday on a sunday", 				id = 23,	reward = 100 },
	{ s = "NTS: Finish 20 times", 										id = 24,	reward = 100,	max = 20 },
	{ s = "NTS: Finish 200 times", 										id = 25,	reward = 300,	max = 200 },
	{ s = "NTS: Win 5 times", 											id = 26,	reward = 75,	max = 5 },
	{ s = "NTS: Win 20 times", 											id = 27,	reward = 200,	max = 20 },
	
	{ s = "MIX: Besweeet award", 										id = 33,	reward = 44,	max = 4 },
}

function onDetectionStart()
	for _, player in ipairs(getElementsByType'player') do 
		resetPlayer ( player )
	end
end
addEventHandler('onResourceStart', resourceRoot, onDetectionStart)

function resetPlayer ( player )
	player = player or source
	g_Players[player] = {}
	g_Players[player].CTF_Flags_delivered = 0
	g_Players[player].DD_previous_kills = 0
	g_Players[player].DD_previous_previous_kills = 0
	g_Players[player].SH_previous_kills = 0
	g_Players[player].SH_previous_previous_kills = 0
end
addEventHandler('onPlayerJoin', root, resetPlayer)

function mapStarting(mapInfo, mapOptions, gameOptions)
	modename = mapInfo.modename
	resname = mapInfo.resname
	isFirstKill = true
	for _, player in pairs(getElementsByType'player') do
		g_Players[player].CTF_Flags_delivered = 0
	end
end
addEventHandler ( 'onMapStarting', root, mapStarting )


---------
-- CTF --
---------

-- 1  CTF: Capture two flags in one map
-- 12 CTF: Capture three flags in one map
function CTFFlagDelivered()
	local player = source
	local flags = g_Players[player].CTF_Flags_delivered + 1
	g_Players[player].CTF_Flags_delivered = flags
	
	if (flags == 2) then
		addPlayerAchievementMix ( player, 1 )
	elseif (flags == 3) then
		addPlayerAchievementMix ( player, 12 )
	end
	addAchievementProgressMix ( player, 31, 1 )
	addAchievementProgressMix ( player, 32, 1 )
end
addEventHandler('onCTFFlagDelivered', root, CTFFlagDelivered)

-- 2  CTF: Capture the winning flag
-- 3  CTF: Capture the winning flag 10 times
-- 10 CTF: Win 5 rounds
-- 11 CTF: Win 20 rounds
function CTFTeamWon(player)
	addPlayerAchievementMix ( player, 2 )
	addAchievementProgressMix ( player, 3, 1 )
	-- addAchievementProgressMix ( getPlayersInTeam(source), 10, 1 )
	-- addAchievementProgressMix ( getPlayersInTeam(source), 11, 1 )
	local blueFlags = (getElementData(getTeamFromName('Blue team'), 'ctf.points') or 0)
	local redFlags = (getElementData(getTeamFromName('Red team'), 'ctf.points') or 0)
	if redFlags == blueFlags + 1 or redFlags == blueFlags - 1 then
		addPlayerAchievementMix ( player, 30 )
	end
end
addEventHandler('onCTFTeamWon', root, CTFTeamWon)


--------
-- DD --
--------

-- 4  DD: Rampage - Accumulate 5 kills in 1 round
-- 5  DD: Monster Kill - Accumulate 8 kills in 2 rounds
-- 6  DD: UNSTOPPABLE!! - Accumulate 10 kills in 3 rounds
-- 13 DD: Win 5 rounds
-- 14 DD: Win 20 rounds
function playerFinishDD (player, rank)
	local kills = tonumber(getElementData(player, 'kills')) or 0
	if kills >= 5 then
		addPlayerAchievementMix ( player, 4 )
	end
	if kills + g_Players[player].DD_previous_kills >= 8 then
		addPlayerAchievementMix ( player, 5 )
	end
	if kills + g_Players[player].DD_previous_kills + g_Players[player].DD_previous_previous_kills >= 10 then
		addPlayerAchievementMix ( player, 6 )
	end
	g_Players[player].DD_previous_previous_kills = g_Players[player].DD_previous_kills
	g_Players[player].DD_previous_kills = kills
	
	if rank == 1 then
		addAchievementProgressMix ( player, 13, 1 )
		addAchievementProgressMix ( player, 14, 1 )
	elseif rank == 4 then
		addAchievementProgressMix ( player, 33, 1 )
	end
end
addEventHandler('onPlayerFinishDD', root, function(r) playerFinishDD(source, r) end)
addEventHandler('onPlayerWinDD', root, function() playerFinishDD(source, 1) end)

-- 15 DD: Make 20 kills
-- 16 DD: Make 200 kills
-- 29 DD: Watcher - Be the first to get killed
function onDDPlayerKill(target)
	addAchievementProgressMix ( source, 15, 1 )
	addAchievementProgressMix ( source, 16, 1 )
	if isFirstKill then
		isFirstKill = false
		addPlayerAchievementMix ( target, 29 )
	end

end
addEvent('onDDPlayerKill')
addEventHandler('onDDPlayerKill', root, onDDPlayerKill)


-- 7  SH: Badass - Accumulate 5 kills in 1 round
-- 8  SH: Hitman - Accumulate 8 kills in 2 rounds
-- 9  SH: Terminator - Accumulate 10 kills in 3 rounds
-- 17 SH: Win 5 rounds
-- 18 SH: Win 20 rounds
function playerFinishShooter (player, rank)
	local kills = tonumber(getElementData(player, 'kills')) or 0
	if kills >= 5 then
		addPlayerAchievementMix ( player, 7 )
	end
	if kills + g_Players[player].SH_previous_kills >= 8 then
		addPlayerAchievementMix ( player, 8 )
	end
	if kills + g_Players[player].SH_previous_kills + g_Players[player].SH_previous_previous_kills >= 10 then
		addPlayerAchievementMix ( player, 9 )
	end
	g_Players[player].SH_previous_previous_kills = g_Players[player].SH_previous_kills
	g_Players[player].SH_previous_kills = kills
	
	if rank == 1 then
		addAchievementProgressMix ( player, 17, 1 )
		addAchievementProgressMix ( player, 18, 1 )
	elseif rank == 4 then
		addAchievementProgressMix ( player, 33, 1 )
	end
end
addEventHandler('onPlayerFinishShooter', root, function(r) playerFinishShooter(source, r) end)
addEventHandler('onPlayerWinShooter', root, function() playerFinishShooter(source, 1) end)

-- 19 SH: Make 20 kills
-- 20 SH: Make 200 kills
-- 28 SH: Spectator - Be the first to get killed
function onShooterPlayerKill(target)
	addAchievementProgressMix ( source, 19, 1 )
	addAchievementProgressMix ( source, 20, 1 )
	if isFirstKill then
		isFirstKill = false
		addPlayerAchievementMix ( target, 28 )
	end
end
addEvent('onShooterPlayerKill')
addEventHandler('onShooterPlayerKill', root, onShooterPlayerKill)


---------
-- NTS --
---------

-- 21 NTS: Finish the map NTS-Marathon
-- 22 NTS: Win the map NTS-Marathon
-- 23 NTS: Finish the map NTS-Sunday on a sunday
-- 24 NTS: Finish 20 times
-- 25 NTS: Finish 200 times
-- 26 NTS: Win 5 times
-- 27 NTS: Win 20 times
function NTSfinish( rank, time )
	if exports.race:getRaceMode() ~= "Never the same" then return end
	
	if resname == 'nts-marathon' then
		addPlayerAchievementMix ( source, 21 )
		if rank == 1 then
			addPlayerAchievementMix ( source, 22 )
		end
	elseif resname == 'nts-sunday' and getRealTime().weekday == 0 then
		addPlayerAchievementMix ( source, 23 )
	end
	addAchievementProgressMix ( source, 24, 1 )
	addAchievementProgressMix ( source, 25, 1 )
	if rank == 1 then
		addAchievementProgressMix ( source, 26, 1 )
		addAchievementProgressMix ( source, 27, 1 )
	elseif rank == 4 then
		addAchievementProgressMix ( player, 33, 1 )
	end
end
addEventHandler("onPlayerFinish", root, NTSfinish)
