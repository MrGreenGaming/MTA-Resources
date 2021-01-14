-------------------------------------------
---  GC rewards for our different modes ---
-------------------------------------------


local modename, mapname, topTime
local prefix = '[GC] '
local compareToTopPos = 5

local fetchToptimesTimer = false
local fetchToptimeRetries = 5

function resetMap(mapInfo, mapOptions, gameOptions)
	rewarded_Players = {}
	topTime, modename, mapname = nil, nil, nil
 	local raceResRoot = getResourceRootElement( getResourceFromName( "race" ) )
	local raceInfo = raceResRoot and getElementData( raceResRoot, "info" )
	if raceInfo then
		modename = raceInfo.mapInfo.modename
		mapname = raceInfo.mapInfo.name
		topTime = getTopTime ( compareToTopPos )
		-- If tops are fetching, set a timer to get it a bit later
		if not topTime then
			if isTimer(fetchToptimesTimer) then killTimer(fetchToptimesTimer) end
			fetchToptimesTimer = setTimer( function()
				topTime = getTopTime(compareToTopPos)
				if topTime and isTimer(fetchToptimesTimer) then
					killTimer( fetchToptimesTimer )
				end
			end, 5000, fetchToptimeRetries)
		end
	end
end
addEvent('onMapStarting')
addEventHandler("onMapStarting",root,resetMap)
addEventHandler("onResourceStart",resourceRoot,resetMap)

function getTopTime ( intTopTime )
	if type(intTopTime) ~='number' and 1 > intToptime then return false end
	if not getResourceFromName('race_toptimes') or getResourceState(getResourceFromName('race_toptimes')) ~= 'running' then return false end
	local mapTimes = exports['race_toptimes']:getCurrentMapTopTimes()
	if mapTimes and mapTimes[intTopTime] then
		return mapTimes[intTopTime]['value'] or getTopTime ( intTopTime - 1 )
	end
	return false
end


------------------------
--- Playtime Rewards ---
------------------------

local playerTimes = {
	-- [player] = {tick = getTickCount(), hoursPlayed = 0}  
}
local rewardPerHour = tonumber(get("rewardPerHour")) --100 default -- rewards
local gracePeriod = 5*60

-- Instead of a timer for every player, compare playtime of all players
local aMin = 60 -- minute
local minuteTickAmount = 1 

function updatePlaytimes()
	rewardPerHour = tonumber(get("rewardPerHour"))
	local currentTick = getRealTime().timestamp
	for s, t in pairs(playerTimes) do
		if currentTick - t.time >= gracePeriod then
			playerTimes[s] = nil
		end
	end
	for k, p in ipairs(getElementsByType'player') do
		local jointick = getElementData(p, 'jointick')
		local hoursPlayed = getElementData(p, 'hoursPlayed')
		if not jointick or not hoursPlayed then
			jointick, hoursPlayed = currentTick, 0
			setElementData(p, 'jointick', currentTick)
			setElementData(p, 'hoursPlayed', 0)
		elseif currentTick - jointick >= aMin * 60 then
			hoursPlayed = hoursPlayed + 1
			if isPlayerLoggedInGC(p) then
				local hourstring, anotherString = " hours",  " another "
				if hoursPlayed == 1 then hourstring = " hour" anotherString = " an " end
				local reward = math.floor (rewardPerHour / ( getElementData(p, 'player state') ~= 'away' and 1 or 2))
				if isHoliday() then reward = reward * 2 end
				outputChatBox ( prefix .. "#00FF00 You have been rewarded " .. tostring(reward) .. " Green-Coins for playing for"..anotherString.."hour! (" .. tostring(hoursPlayed) .. hourstring .. ")", p, 0, 255, 0, true)
				-- outputDebugString("Player: "..getPlayerName(p).." triggered time reward ("..hoursPlayed.."H)")
				addPlayerGreencoins(p, reward)
			else
				outputChatBox ( prefix .. "#00FF00 You weren\'t logged in, login to get your " .. rewardPerHour .. " GC each hour you play!", p, 0, 255, 0, true)
			end
			jointick = currentTick
			setElementData(p, 'jointick', currentTick)
			setElementData(p, 'hoursPlayed', hoursPlayed)
		end
		local minutes = math.floor((currentTick - jointick)/60)
		setElementData(p, 'playtime', getElementData(p, 'hoursPlayed') .. ':' .. string.format('%02d', minutes))
	end
end
setTimer(updatePlaytimes, aMin*1000*minuteTickAmount + 1500, 0) -- minuteTickAmount loop
setTimer(updatePlaytimes, 50, 1)

addEventHandler("onPlayerJoin", root, function()
	local serial = getPlayerSerial(source)
	if playerTimes[serial] then
		setElementData(source, 'jointick', playerTimes[serial].tick)
		setElementData(source, 'hoursPlayed', playerTimes[serial].hoursPlayed)
		outputChatBox('Welcome back', source)
		
		local minutes = math.floor((getRealTime().timestamp - playerTimes[serial].tick)/60)
		setElementData(source, 'playtime', playerTimes[serial].hoursPlayed .. ':' .. string.format('%02d', minutes))
		
		playerTimes[serial] = nil
	else
		setElementData(source, 'jointick', getRealTime().timestamp)
		setElementData(source, 'hoursPlayed', 0)
	end
end)

addEventHandler("onPlayerQuit", root, function()
	if not getElementData(source , 'gotomix') then
		playerTimes[getPlayerSerial(source)] = {
			tick = getElementData(source, 'jointick'),
			hoursPlayed = getElementData(source, 'hoursPlayed'),
			time = getRealTime().timestamp
		}
	end
end)

addEvent("onPlayerReplaceTime")
addEventHandler("onPlayerReplaceTime", root, function(serial, tick, hoursPlayed)
	playerTimes[serial] = {
		tick = tick or getRealTime().timestamp,
		hoursPlayed = hoursPlayed,
		time = getRealTime().timestamp
	}
end)


---------------------------------
---   Race (Sprint) and NTS   ---
---------------------------------
local rewarded_Players = {}
local maxRewardedFinishes = 5
local minimumRewardTimeR = 2 * 60 * 1000
local maximumRewardTimeR = 8 * 60 * 1000
local defaultRewardTime = 2 * 60 * 1000
local defaultRewardGC = 12 -- Base for calculation
local maxRaceReward = 45
local minRaceReward = {18, 14, 10, 6, 3}


function finish(rank)
	if modename ~= "Sprint" and modename ~= "Never the same" then
		return
	end
	local player = source
	
	--Ordinal indicator
	local suffix
	if (rank == 11) or (rank == 12) or (rank == 13) then
		suffix = "th"
	else
		local lastNumber = rank % 10
		if lastNumber == 1 then
			suffix = "st"
		elseif lastNumber == 2 then
			suffix = "nd"
		elseif lastNumber == 3 then
			suffix = "rd"
		else
			suffix = "th"
		end
	end
	
	if compareToTopPos and rank <= maxRewardedFinishes then
		if not rewarded_Players[player] then
			rewarded_Players[player] = {}
		end
		rewarded_Players[player].finishReward = calcFinishReward(player, rank)
		-- outputDebugString( 'CalcFinishReward = '..tostring(rewarded_Players[player].finishReward) )
		rewarded_Players[player].finishReward = vipRewardMult(player,rewarded_Players[player].finishReward)
		rewarded_Players[player].finishReward = getRewardAmount(rewarded_Players[player].finishReward)		
		rewarded_Players[player].rank = rank
		if isHoliday() then rewarded_Players[player].finishReward = rewarded_Players[player].finishReward * 2 end
		
		if rewarded_Players[player].finishReward > 1 then
			addPlayerGreencoins(player, rewarded_Players[player].finishReward)
			if not getResourceFromName('tournament_point_system') or getResourceState(getResourceFromName('tournament_point_system')) ~= 'running' then
				if modename == 'Sprint' then
					exports.messages:outputGameMessage(getPlayerName(player) .."#00FF00 finished ".. tostring(rank) .. suffix .." earning ".. rewarded_Players[player].finishReward .." GC", getRootElement(), nil, 0, 255, 0, false, false, true)
					outputChatBox(prefix .."You earned ".. rewarded_Players[player].finishReward .." GC for finishing ".. tostring(rank) .. suffix ..". You now have ".. comma_value(getPlayerGreencoins(player)) .." GC.", player, 0, 255, 0, true)
				else
					exports.messages:outputGameMessage(getPlayerName(player) .."#00FF00 finished ".. tostring(rank) .. suffix .." earning ".. rewarded_Players[player].finishReward .." GC", getRootElement(), nil, 0, 255, 0, false, false, true)
					outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 has earned ' .. rewarded_Players[player].finishReward .. ' GC for finishing ' .. tostring(rank) .. suffix, root, 0, 255, 0, true)
				end
			end
			return
		end
	end
	if not getResourceFromName('tournament_point_system') or getResourceState(getResourceFromName('tournament_point_system')) ~= 'running' then
		exports.messages:outputGameMessage(getPlayerName(player) .." finished ".. tostring(rank) .. suffix, getRootElement(), nil, nil, nil, nil, false, false, true)
	end
end
addEventHandler("onPlayerFinish", root, finish)

function calcFinishReward(player, rank)
	--if not tonumber(topTime) then return 0 end
	-- outputDebugString('toptime:'..tostring(topTime))
	topTime = tonumber(topTime) or defaultRewardTime
	local topTime = math.max(math.min(topTime, maximumRewardTimeR), minimumRewardTimeR)
	local mapratio = math.floor ( topTime/defaultRewardTime * 2 ) / 2
	local reward = mapratio * defaultRewardGC * (1 - (rank - 1) / maxRewardedFinishes)
	-- outputDebugString("mapratio " .. mapratio .. " * defaultRewardGC " .. defaultRewardGC ..  " * (1 - (rank " .. rank .. " - 1) / maxRewardedFinishes" .. maxRewardedFinishes)
	local calculatedReward = math.floor(math.round(math.max(reward,0)))
	if minRaceReward[rank] > calculatedReward then
		return minRaceReward[rank]
	elseif calculatedReward > (maxRaceReward + rank) then
		return maxRaceReward + rank
	end
	return calculatedReward
end

local minPlayers = 5
function areRewardsActivated()
	-- return true -- Testing Purposes
	return getPlayerCount() >= minPlayers
end

function getActivePlayerCount()
	if not getResourceFromName('anti') or getResourceState(getResourceFromName('anti')) ~= 'running' then
		return getPlayerCount()
	end

	local count = 0
	for _,p in ipairs(getElementsByType('player')) do
		if not exports.anti:isPlayerAFK(p) then
			count = count + 1
		end
	end
	return count
end
---------------
---   CTF   ---
---------------

rewardCTFFlagDeliver = 3
rewardCTFFlagDeliverTeam = 1
rewardCTFTeamWin = 10
rewardCTFPlayerKill = 2
rewardCTFFlagCarrierKill = 5
local maxCTFIndivKill = 2 -- max amount players can kill eachother, to prevent gc farming and abuse

-- function CTFPlayerKill(victim,amount)
-- 	if modename ~= "Capture the flag" then return end
-- 	local player = source

-- 	if not areRewardsActivated() then
-- 		outputChatBox(prefix..getPlayerName(player)..'#00FF00 defended his flag by killing '..getPlayerName(source)..', but '..minPlayers..' or more players are required to get GCs',root,0,255,0,true)
-- 		return
-- 	elseif amount <= maxCTFIndivKill then
-- 		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 earned '..rewardCTFPlayerKill.. ' GC for defending the flag by killing '..getPlayerName(victim)..'#00FF00 in the defend zone.', root, 0, 255, 0, true)
-- 		addPlayerGreencoins(player, rewardCTFPlayerKill)
-- 	end
-- end
-- addEvent("onCTFPlayerKill")
-- addEventHandler("onCTFPlayerKill",root,CTFPlayerKill)

function CTFFlagCarrierKill(victim)
	if modename ~= "Capture the flag" then return end
	local player = source
	if not areRewardsActivated() then
		outputChatBox(prefix..getPlayerName(player)..'#00FF00 killed the flag carrier, but '..minPlayers..' or more players are required to get GC.',root,0,255,0,true)
		return
	else
		local victimTeam = getPlayerTeam(victim)
		local victimTeam = getTeamName( victimTeam )
		local vName = getPlayerName(victim)
		local reward = getRewardAmount(rewardCTFFlagCarrierKill)
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. getPlayerName(player) .. "#00FF00 earned "..reward.. " GC for killing the "..victimTeam.."'s flag carrier ("..vName.."#00FF00)", root, 0, 255, 0, true)
	end
end
addEvent("onCTFFlagCarrierKill")
addEventHandler("onCTFFlagCarrierKill",root,CTFFlagCarrierKill)

function CTFFlagDelivered()
	if modename ~= "Capture the flag" then return end
	local player = source
	local team = getPlayerTeam(player)
	local reward = getRewardAmount(rewardCTFFlagDeliver)
	local rewar2 = getRewardAmount(rewardCTFFlagDeliverTeam)
	if isHoliday() then
		reward = reward * 2
		rewar2 = rewar2 * 2
	end

	addPlayerGreencoins(player, reward)
	outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 scored 1 point and earned '..reward.. ' GC for himself and '.. rewar2 ..' GC for the ' .. getTeamName(team), root, 0, 255, 0, true)


	for _, pl in ipairs(getPlayersInTeam(team)) do 
		if pl ~= player then
			if not exports.anti:isPlayerAFK(pl) then
				local reward = rewardCTFFlagDeliverTeam
				reward = vipRewardMult(player,reward)
				if isHoliday() then reward = reward * 2 end
				getRewardAmount(reward)
				addPlayerGreencoins(player, reward)
			end
		end
	end
	
end
addEventHandler('onCTFFlagDelivered', root, CTFFlagDelivered)

function CTFTeamWon()
	if modename ~= "Capture the flag" then return end
	local team = source
	local reward = rewardCTFTeamWin
	if isHoliday() then reward = reward * 2 end
	reward = getRewardAmount(reward)
	for _, player in ipairs(getPlayersInTeam(team)) do 
		if not exports.anti:isPlayerAFK(pl) then
			addPlayerGreencoins(player, reward)
		end
	end
	outputChatBox(prefix .. getTeamName(team) .. ' has been rewarded ' .. reward .. ' GC for outscoring the opponent!', root, getTeamColor(team))
	
end
addEventHandler('onCTFTeamWon', root, CTFTeamWon)

-------------------
---   DeadLine   ---
-------------------

rewardDeadline = {16, 12, 8}
rewardKillDeadline = 1

function deadlineFinish(rank)
	if string.lower(modename) ~= "deadline" or not rewardDeadline[rank] then return end
	local player = source
	local str = rankSuffix(rank)
	-- Check for active players in 'no respawn' gamemodes
	if getActivePlayerCount() < 3 then
		outputChatBox(prefix .. getPlayerName(source) .. '#00FF00 finished ' .. rank .. str .. ' but 3 or more active players are required to get GC', root, 0, 255, 0, true)
		return
	end

	local reward = rewardDeadline[rank]
	reward = vipRewardMult(player,reward)
	if isHoliday() then reward = reward * 2 end
	reward = getRewardAmount(reward)
	addPlayerGreencoins(player, reward)
	outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
end
addEvent('onPlayerFinishDeadline')
addEventHandler('onPlayerFinishDeadline', root, deadlineFinish)

function deadlineWin()
	deadlineFinish(1)
end
addEvent('onPlayerWinDeadline')
addEventHandler('onPlayerWinDeadline', root, deadlineWin)

function onDeadlinePlayerKill()

	if string.lower(modename) ~= "deadline" or not rewardKillDeadline then return end
	local player = source
	local reward = rewardKillDeadline
	if isHoliday() then reward = reward * 2 end
	addPlayerGreencoins(player, reward)
	outputChatBox(prefix .. 'You earned ' .. reward .. ' GC for a kill', player, 0, 255, 0, true)	
end
addEvent('onDeadlinePlayerKill')
addEventHandler('onDeadlinePlayerKill', root, onDeadlinePlayerKill)


-------------------
---   Shooter   ---
-------------------

rewardShooter = {16, 12, 8}
rewardKill = 1

function shooterFinish(rank)
	if modename ~= "Shooter" or not rewardShooter[rank] then return end
	if exports.anti:isPlayerAFK(source) then return end
	local str = rankSuffix(rank)
	-- Check for active players in 'no respawn' gamemodes
	if getActivePlayerCount() < 3 then
		outputChatBox(prefix .. getPlayerName(source) .. '#00FF00 finished ' .. rank .. str .. ' but 3 or more active players are required to get GC', root, 0, 255, 0, true)
		return
	end
	local reward = rewardShooter[rank]
	reward = vipRewardMult(source,reward)
	if isHoliday() then reward = reward * 2 end
	reward = getRewardAmount(reward)
	addPlayerGreencoins(source, reward)
	if not getResourceFromName('tournament_point_system') or getResourceState(getResourceFromName('tournament_point_system')) ~= 'running' then
		outputChatBox(prefix .. getPlayerName(source) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
	end
end
addEvent('onPlayerFinishShooter')
addEventHandler('onPlayerFinishShooter', root, shooterFinish)

function shooterWin()
	shooterFinish(1)
end
addEvent('onPlayerWinShooter')
addEventHandler('onPlayerWinShooter', root, shooterWin)

function onShooterPlayerKill()
	if modename ~= "Shooter" or not rewardKill then return end
	local player = source
	local reward = rewardKill
	if isHoliday() then reward = reward * 2 end
	addPlayerGreencoins(player, reward)
	if not getResourceFromName('tournament_point_system') or getResourceState(getResourceFromName('tournament_point_system')) ~= 'running' then
		outputChatBox(prefix .. 'You earned ' .. reward .. ' GC for a kill', player, 0, 255, 0, true)
	end
end
addEvent('onShooterPlayerKill')
addEventHandler('onShooterPlayerKill', root, onShooterPlayerKill)

--------------
--  CarGame --
--------------

rewardCarGame = {16, 12, 8}
rewardCarGameLevel = 1
function winCargame(t)
	if exports.race:getShooterMode() == "cargame" then

		for rank,tab in ipairs(t) do
			local theLVL = tab.level
			if tonumber(theLVL) then
				if areRewardsActivated() and getElementType(tab.player) == "player"then
					local reward = theLVL * rewardCarGameLevel
					if isHoliday() then reward = reward * 2 end
					outputChatBox(prefix .. 'You have earned ' .. tostring(reward) .. ' GC for reaching Level '.. tostring(theLVL), tab.player, 0, 255, 0, true)
					addPlayerGreencoins(tab.player, reward)
				end
			end

			if rank <= #rewardCarGame then -- Reward top 3 players
				if t[rank] then
					local str = rankSuffix(rank)
					if areRewardsActivated() then
						local reward = rewardCarGame[rank]
						reward = vipRewardMult(player,reward)
						if isHoliday() then reward = reward * 2 end
						addPlayerGreencoins(player, reward)
						outputChatBox(prefix .. t[rank].name .. '#00FF00 has earned ' .. reward .. ' GC for finishing '.. rank .. str, root, 0, 255, 0, true)
					else
						outputChatBox(prefix .. t[rank].name ..'#00FF00 finished '.. rank .. str ..' but ' .. minPlayers .. ' or more players required to get GCs', root, 0, 255, 0, true)
					end
				end
			end
		end
	end
end

addEvent("onPlayerWinCarGame")
addEventHandler("onPlayerWinCarGame",root,winCargame)

--------------
---   DD   ---
--------------

rewardDD = {16, 12, 8}
rewardKill = 1

function ddFinish(rank)
	if modename ~= "Destruction derby" or not rewardDD[rank] then return end
	if exports.anti:isPlayerAFK(source) then return end
	local str = rankSuffix(rank)
	-- Check for active players in 'no respawn' gamemodes
	if getActivePlayerCount() < 3 then
		outputChatBox(prefix .. getPlayerName(source) .. '#00FF00 finished ' .. rank .. str .. ' but 3 or more active players are required to get GC', root, 0, 255, 0, true)
		return
	end
	local reward = rewardDD[rank]
	reward = vipRewardMult(source,reward)
	if isHoliday() then reward = reward * 2 end
	reward = getRewardAmount(reward)
	addPlayerGreencoins(source, reward)
	if not getResourceFromName('tournament_point_system') or getResourceState(getResourceFromName('tournament_point_system')) ~= 'running' then
		outputChatBox(prefix .. getPlayerName(source) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
	end
end
addEvent('onPlayerFinishDD')
addEventHandler('onPlayerFinishDD', root, ddFinish)

function ddWin()
	ddFinish(1)
end
addEvent('onPlayerWinDD')
addEventHandler('onPlayerWinDD', root, ddWin)

function onDDPlayerKill()
	if modename ~= "Destruction derby" or not rewardKill then return end
	local player = source
	local reward = rewardKill
	if isHoliday() then reward = reward * 2 end
	addPlayerGreencoins(player, reward)
	if not getResourceFromName('tournament_point_system') or getResourceState(getResourceFromName('tournament_point_system')) ~= 'running' then
		outputChatBox(prefix .. 'You earned ' .. reward .. ' GC for a kill', player, 0, 255, 0, true)
	end
end
addEvent('onDDPlayerKill')
addEventHandler('onDDPlayerKill', root, onDDPlayerKill)


---------------
---   RTF   ---
---------------

local rewardRTFwinner = 20	-- greencoins
function RTFfinish( rank, time )
	if modename ~= "Reach the flag" then return end
	local player = source
	local reward = rewardRTFwinner
	reward = vipRewardMult(player,reward)
	if isHoliday() then reward = reward * 2 end
	reward = getRewardAmount(reward)
	addPlayerGreencoins(player, reward)
	if not getResourceFromName('tournament_point_system') or getResourceState(getResourceFromName('tournament_point_system')) ~= 'running' then
		outputChatBox(prefix..getPlayerName(player)..'#00FF00 has earned '.. reward .. ' GC for reaching the flag first! ', root, 0, 255, 0, true)
	end
end
addEventHandler("onPlayerFinish", root, RTFfinish)


-- ---------------
-- ---   NTS   ---
-- ---------------

-- rewardNTS = {16, 12, 8, 5, 3}
-- function NTSfinish( rank, time )
-- 	if modename ~= "Never the same" or not rewardNTS[rank] then return end
-- 	local player = source

-- 	local str = rankSuffix(rank)
-- 	local reward = getRewardAmount(rewardNTS[rank])
-- 	reward = vipRewardMult(player,reward)
-- 	if isHoliday() then reward = reward * 2 end
-- 	reward = lowPopModifier(reward)
-- 	addPlayerGreencoins(player, reward)
-- 	outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
	
-- end
-- addEventHandler("onPlayerFinish", root, NTSfinish)


-------------------
---   Manhunt   ---
-------------------

rewardManhunt = {16, 12, 8}
local victimKillReward = 1
local victimKillTopToReward = 3

function onManhuntRoundEnded( results )
	for i=#results, 1, -1 do
		manhuntFinish(results[i].player, i)
	end
end

function manhuntFinish (player, rank)
	if not rewardManhunt[rank] then return end
	local str = rankSuffix(rank)
	if not areRewardsActivated() then
		outputChatBox(prefix .. getPlayerName(player) ..'#00FF00 finished ' .. rank .. str .. ' but ' .. minPlayers .. ' or more players required to get GCs', root, 0, 255, 0, true)
	else
		local reward = getRewardAmount(rewardManhunt[rank])
		reward = vipRewardMult(player,reward)
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
	end
end
addEventHandler("onManhuntRoundEnded", root, onManhuntRoundEnded)

function manhuntVictimKills(list)
	local victim = source
	for i, v in ipairs(list) do
		if i > victimKillTopToReward then break end
		if v.player and isElement(v.player) and getElementType(v.player) == "player" then
			if areRewardsActivated() then
				local reward = getRewardAmount(victimKillReward)
				reward = vipRewardMult(player,reward)
				if isHoliday() then reward = reward * 2 end
				addPlayerGreencoins(v.player, reward)
				outputChatBox(prefix .. getPlayerName(v.player) .. '#00FF00 has earned ' .. reward .. ' GC for being in the top '..victimKillTopToReward..' victim damage dealers.', root, 0, 255, 0, true)
			end
		end
	end
end
addEvent("onManhuntVictimKillList")
addEventHandler("onManhuntVictimKillList", root, manhuntVictimKills)

-----------------
---   Utils   ---
-----------------

function getRewardAmount(amount)
	local lowPopMultiplier = 0
	local pCnt = getPlayerCount()
	if pCnt < 5 then 
		lowPopMultiplier = 0.5 
	else
		lowPopMultiplier = 1
	end
	local endReward = math.ceil(amount * lowPopMultiplier)

	if endReward < 1 then endReward = 1 end -- prevent from giving 0 gc

	return endReward
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function rankSuffix(rank)
	return (rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th'
end

-- remove color coding from string
function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

-- getPlayerName with color coding removed
function _getPlayerName ( player )
	return removeColorCoding ( getPlayerName ( player ) )
end

function isMapTesting()
	return getResourceInfo(exports.mapmanager:getRunningGamemodeMap(), 'newupload') == "true"
end

--http://lua-users.org/wiki/FormattingNumbers
function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function vipRewardMult(player, theReward)
	if not player then return theReward end
	if getResourceFromName('mrgreen-vip') and getResourceState(getResourceFromName('mrgreen-vip')) == "running" and exports['mrgreen-vip']:isPlayerVIP(player) then
		return math.ceil(theReward * 1.5)
	end
	return theReward
end
