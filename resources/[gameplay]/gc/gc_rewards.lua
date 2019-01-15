-------------------------------------------
---  GC rewards for our different modes ---
-------------------------------------------


local modename, mapname, topTime
local prefix = '[GC] '
local compareToTopPos = 5
-- local anti = exports.anti -- anti:isPlayerAFK(plyr)

function resetMap(mapInfo, mapOptions, gameOptions)
	rewarded_Players = {}
	topTime, modename, mapname = nil, nil, nil
 	local raceResRoot = getResourceRootElement( getResourceFromName( "race" ) )
	local raceInfo = raceResRoot and getElementData( raceResRoot, "info" )
	if raceInfo then
		modename = raceInfo.mapInfo.modename
		mapname = raceInfo.mapInfo.name
		topTime = getTopTime ( compareToTopPos )
	end
end
addEvent('onMapStarting')
addEventHandler("onMapStarting",root,resetMap)
addEventHandler("onResourceStart",resourceRoot,resetMap)

function getTopTime ( intTopTime )
	if type(intTopTime) ~='number' and 1 > intToptime then return false end
	local toptable = 'race maptimes ' .. modename ..' '.. mapname
	if not doesTableExist ( toptable ) then return false end
	select = executeSQLQuery('SELECT * FROM ?', toptable )
	if select and select[intTopTime] then
		return select[intTopTime]['timeMs'] or getTopTime ( intTopTime - 1 )
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


-------------------------
---   Race (Sprint)   ---
-------------------------
local rewarded_Players = {}
local maxRewardedToptimes = 3
local maxRewardedFinishes = 5
local minimumRewardTimeR = 2 * 60 * 1000
local maximumRewardTimeR = 8 * 60 * 1000
local defaultRewardTime = 2 * 60 * 1000
local defaultRewardGC = 10


--[[
function ontoptime( newPos, newTime, oldPos, oldTime, player )
	local player = source or player
	if modename == "Sprint" and compareToTopPos and (not oldPos or newPos < oldPos) and newPos <= maxRewardedToptimes then
		if not rewarded_Players[player] then rewarded_Players[player] = {} end
		if rewarded_Players[player].finishReward and rewarded_Players[player].finishReward > 1 then
			local rank = tonumber(rewarded_Players[player].rank)
			if not rank then
				rewarded_Players[player].top = {newPos, newTime, oldPos, oldTime}
				return
			end
			-- outputDebugString(tostring(rank) .. '.' .. newPos .. " "  .. getPlayerName(player) )

			local topReward = math.floor(rewarded_Players[player].finishReward*(1.7 - 2 * (newPos - rank + 1)/10))
			
			addPlayerGreencoins ( player, getRewardAmount(topReward - rewarded_Players[player].finishReward))
			-- outputDebugString ( prefix .. getPlayerName(player) .. "#00FF00 earned " .. rewarded_Players[player].finishReward .. '/' .. topReward .. " Green-Coins for the new top" .. newPos .. " (" .. ")",2)
			outputChatBox ( prefix .. getPlayerName(player) .. "#00FF00 earned " .. getRewardAmount(topReward - rewarded_Players[player].finishReward) .. " Green-Coins for the new top" .. newPos .. " (" .. getPlayerGreencoins ( player ) .. ")", root, 0, 255, 0, true)
		end
	end
end
addEventHandler("onPlayerToptimeImprovement", root, ontoptime)
--]]

function finish(rank)
	if modename ~= "Sprint" then
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
		rewarded_Players[player].rank = rank
		if isHoliday() then rewarded_Players[player].finishReward = rewarded_Players[player].finishReward * 2 end
		
		if rewarded_Players[player].finishReward > 1 then
			addPlayerGreencoins(player, rewarded_Players[player].finishReward)
			
			exports.messages:outputGameMessage(getPlayerName(player) .."#00FF00 finished ".. tostring(rank) .. suffix .." earning ".. rewarded_Players[player].finishReward .." GC", getRootElement(), nil, 0, 255, 0, false, false, true)
			outputChatBox(prefix .."You earned ".. rewarded_Players[player].finishReward .." GC for finishing ".. tostring(rank) .. suffix ..". You now have ".. comma_value(getPlayerGreencoins(player)) .." GC.", player, 0, 255, 0, true)				
			
			return
		end
	end
	
	exports.messages:outputGameMessage(getPlayerName(player) .." finished ".. tostring(rank) .. suffix, getRootElement(), nil, nil, nil, nil, false, false, true)
end
addEventHandler("onPlayerFinish", root, finish)

function calcFinishReward(player, rank)
	--if not tonumber(topTime) then return 0 end
	topTime = tonumber(topTime) or defaultRewardTime
	local topTime = math.max(math.min(topTime, maximumRewardTimeR), minimumRewardTimeR)
	local mapratio = math.floor ( topTime/defaultRewardTime * 2 ) / 2
	local reward = mapratio * defaultRewardGC * (1 - (rank - 1) / maxRewardedFinishes)
	-- outputDebugString("mapratio " .. mapratio .. " * defaultRewardGC " .. defaultRewardGC ..  " * (1 - (rank " .. rank .. " - 1) / maxRewardedFinishes" .. maxRewardedFinishes)
	return math.floor(math.round(math.max(reward,0)))
end

---------------
---   Mix   ---
---------------

local minPlayers = 5
function areRewardsActivated()
	-- return true -- Testing Purposes
	return getPlayerCount() >= minPlayers
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

	if not areRewardsActivated() then
		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 scored 1 point but ' .. minPlayers .. ' or more players required to get GCs', root, 0, 255, 0, true)
		return
	else
	-- elseif isPlayerLoggedInGC(player) then
		local reward = getRewardAmount(rewardCTFFlagDeliver)
		local rewar2 = getRewardAmount(rewardCTFFlagDeliverTeam)
		if isHoliday() then
			reward = reward * 2
			rewar2 = rewar2 * 2
		end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 scored 1 point and earned '..reward.. ' GC for himself and '.. rewar2 ..' GC for the ' .. getTeamName(team), root, 0, 255, 0, true)
	-- else
		-- outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 scored 1 point and wasn\t logged in but earned '.. rewardCTFFlagDeliverTeam ..' GC for the ' .. getTeamName(team), root, 0, 255, 0, true)
	end
	for _, pl in ipairs(getPlayersInTeam(team)) do 
		if pl ~= player then
		-- if pl ~= player and isPlayerLoggedInGC(pl) then
			if not exports.anti:isPlayerAFK(pl) then
				local reward = getRewardAmount(rewardCTFFlagDeliverTeam)
				if isHoliday() then reward = reward * 2 end
				addPlayerGreencoins(player, reward)
			end
		end
	end
	
end
addEventHandler('onCTFFlagDelivered', root, CTFFlagDelivered)

function CTFTeamWon()
	if modename ~= "Capture the flag" then return end
	local team = source
	if not areRewardsActivated() then
		outputChatBox( prefix .. minPlayers .. ' or more players required to get GCs', root, getTeamColor(team))
	else
		for _, player in ipairs(getPlayersInTeam(team)) do 
			-- if isPlayerLoggedInGC(player) then
			if not exports.anti:isPlayerAFK(pl) then
				local reward = getRewardAmount(rewardCTFTeamWin)
				if isHoliday() then reward = reward * 2 end
				addPlayerGreencoins(player, reward)
			end
			-- end
		end
		outputChatBox(prefix .. getTeamName(team) .. ' has been rewarded ' .. getRewardAmount(rewardCTFTeamWin) .. ' GC for outscoring the opponent!', root, getTeamColor(team))
	end
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
	if not areRewardsActivated() then
		outputChatBox(prefix .. getPlayerName(player) ..'#00FF00 finished ' .. rank .. str .. ' but ' .. minPlayers .. ' or more players required to get GCs', root, 0, 255, 0, true)
	else
	-- elseif isPlayerLoggedInGC(player) then
		local reward = getRewardAmount(rewardDeadline[rank])
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
	-- else
		-- outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 finished ' .. rank .. str .. ' but wasn\'t logged in', root, 0, 255, 0, true)
	end		
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
	if areRewardsActivated() then
		local reward = rewardKillDeadline
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. 'You earned ' .. reward .. ' GC for a kill', player, 0, 255, 0, true)
	else
		-- outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 finished ' .. rank .. str .. ' but wasn\'t logged in', root, 0, 255, 0, true)
	end		
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
	local player = source

	local str = rankSuffix(rank)
	if not areRewardsActivated() then
		outputChatBox(prefix .. getPlayerName(player) ..'#00FF00 finished ' .. rank .. str .. ' but ' .. minPlayers .. ' or more players required to get GCs', root, 0, 255, 0, true)
	else
	-- elseif isPlayerLoggedInGC(player) then
		local reward = getRewardAmount(rewardShooter[rank])
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
	-- else
		-- outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 finished ' .. rank .. str .. ' but wasn\'t logged in', root, 0, 255, 0, true)
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
	if areRewardsActivated() then
		local reward = rewardKill
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. 'You earned ' .. reward .. ' GC for a kill', player, 0, 255, 0, true)
	else
		-- outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 finished ' .. rank .. str .. ' but wasn\'t logged in', root, 0, 255, 0, true)
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
	local player = source

	local str = rankSuffix(rank)
	if not areRewardsActivated() then
		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 finished ' .. rank .. str .. ' but ' .. minPlayers .. ' or more players required to get GCs', root, 0, 255, 0, true)
	else
	-- elseif isPlayerLoggedInGC(player) then
		local reward = getRewardAmount(rewardDD[rank])
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
	-- else
		-- outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 finished ' .. rank .. str .. ' but wasn\'t logged in', root, 0, 255, 0, true)
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
	if areRewardsActivated() then
		local reward = rewardKill
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. 'You earned ' .. reward .. ' GC for a kill', player, 0, 255, 0, true)
	else
		-- outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 finished ' .. rank .. str .. ' but wasn\'t logged in', root, 0, 255, 0, true)
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

	if not areRewardsActivated() then
		outputChatBox( prefix .. getPlayerName(player) .. '#00FF00 has reached the flag first but ' .. minPlayers.. ' or more players are required to get GCs', root, 0, 255, 0, true)
	else
	-- elseif isPlayerLoggedInGC(player) then
		local reward = getRewardAmount(rewardRTFwinner)
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix..getPlayerName(player)..'#00FF00 has earned '.. reward .. ' GC for reaching the flag first! ', root, 0, 255, 0, true)
	-- else
		-- outputChatBox(prefix..getPlayerName(player)..'#00FF00 reached the flag first but wasn\'t logged in!', root, 0, 255, 0, true)
	end
end
addEventHandler("onPlayerFinish", root, RTFfinish)


---------------
---   NTS   ---
---------------

rewardNTS = {16, 12, 8, 5, 3}
function NTSfinish( rank, time )
	if modename ~= "Never the same" or not rewardNTS[rank] then return end
	local player = source

	local str = rankSuffix(rank)
	if not areRewardsActivated() then
		outputChatBox(prefix .. getPlayerName(player) ..'#00FF00 finished ' .. rank .. str .. ' but ' .. minPlayers .. ' or more players required to get GCs', root, 0, 255, 0, true)
	else
	-- elseif isPlayerLoggedInGC(player) then
		local reward = getRewardAmount(rewardNTS[rank])
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
	-- else
		-- outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 finished ' .. rank .. str .. ' but wasn\'t logged in', root, 0, 255, 0, true)
	end		
end
addEventHandler("onPlayerFinish", root, NTSfinish)


-------------------
---   Manhunt   ---
-------------------

rewardManhunt = {16, 12, 8}

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
	-- elseif isPlayerLoggedInGC(player) then
		local reward = getRewardAmount(rewardManhunt[rank])
		if isHoliday() then reward = reward * 2 end
		addPlayerGreencoins(player, reward)
		outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 has earned ' .. reward .. ' GC for finishing ' .. rank .. str, root, 0, 255, 0, true)
	-- else
		-- outputChatBox(prefix .. getPlayerName(player) .. '#00FF00 finished ' .. rank .. str .. ' but wasn\'t logged in', root, 0, 255, 0, true)
	end
end
addEventHandler("onManhuntRoundEnded", root, onManhuntRoundEnded)


-----------------
---   Utils   ---
-----------------

function getRewardAmount(amount)
	local lowPopMultiplier = 0
	local pCnt = getPlayerCount()
	if pCnt >= 3 and pCnt < 8 then 
		lowPopMultiplier = 0.5 
	elseif pCnt >= 8 then
		lowPopMultiplier = 1
	end
	local endReward = math.floor(amount * lowPopMultiplier)

	if endReward < 1 then endReward = 1 end -- prevent from giving 0 gc

	return endReward
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
	local cmd = "SELECT tbl_name FROM sqlite_master WHERE tbl_name = ?"
	local results = executeSQLQuery( cmd, name )
	return results and (#results > 0)
end

function safeString(s)
    s = string.gsub(s, '&', '&amp;')
    s = string.gsub(s, '"', '&quot;')
    s = string.gsub(s, '<', '&lt;')
    s = string.gsub(s, '>', '&gt;')
    return s
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
