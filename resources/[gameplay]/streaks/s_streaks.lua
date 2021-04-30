--------------------------------
-- Streak
--------------------------------
-- 2: 10, 3: 15, 4: 20, 5:25



local currentStreakPlayer;
local currentPlayerStreakCount = 0;
local requiredPlayersToRecordAStreak = 1;

function GetGreenCoinsAmountForStreak()
	if (currentPlayerStreakCount == 2) then
		return 10;
	elseif (currentPlayerStreakCount == 3) then
		return 15;
	elseif (currentPlayerStreakCount == 4) then
		return 20;
	elseif (currentPlayerStreakCount >= 5) then
		return 25;
	end
end

addEventHandler('onPlayerFinish', root, 
	function(rank) 
		if (getPlayerCount() >= requiredPlayersToRecordAStreak) then
			if (rank == 1) then
				if (currentStreakPlayer ~= source) then
					currentStreakPlayer = source
					currentPlayerStreakCount = 1;
				else
					if (currentStreakPlayer) then
						currentPlayerStreakCount = currentPlayerStreakCount+1;
						exports.gc:addPlayerGreencoins(source, GetGreenCoinsAmountForStreak())
						outputChatBox("[Streak] "..getFullPlayerName(currentStreakPlayer).." #00ff00has made a streak! (#FFFFFFX".. currentPlayerStreakCount.."#00ff00) (earned "..GetGreenCoinsAmountForStreak().."GC)", root, 0, 255, 0, true)
						if IsRecordBroken() then
							SaveRecordHolder(getFullPlayerName(currentStreakPlayer), currentPlayerStreakCount)
						end
					end
				end
			end
		else
			if (rank == 1) then
				outputChatBox("There aren't enough players online to record this streak. ("..getPlayerCount().."/"..requiredPlayersToRecordAStreak..")", root, 0, 255, 0)
			end
		end
    end
)

function TriggerStreakForOtherGamemodes()
	if (getPlayerCount() >= requiredPlayersToRecordAStreak) then
		if (currentStreakPlayer ~= source) then
			currentStreakPlayer = source
			currentPlayerStreakCount = 1;
		else
			if (currentStreakPlayer) then
				currentPlayerStreakCount = currentPlayerStreakCount+1;
				exports.gc:addPlayerGreencoins(source, GetGreenCoinsAmountForStreak())
				outputChatBox("[Streak] "..getFullPlayerName(currentStreakPlayer).." #00ff00has made a streak! (#FFFFFFX".. currentPlayerStreakCount.."#00ff00) (earned "..GetGreenCoinsAmountForStreak().."GC)", root, 0, 255, 0, true)
				if IsRecordBroken() then
					SaveRecordHolder(getFullPlayerName(currentStreakPlayer), currentPlayerStreakCount)
				end
			end
		end
	else
		outputChatBox("There aren't enough players online to record this streak. ("..getPlayerCount().."/"..requiredPlayersToRecordAStreak..")", root, 0, 255, 0)
	end
end
addEventHandler("onPlayerWinDD", root, TriggerStreakForOtherGamemodes)
addEventHandler("onPlayerWinShooter", root, TriggerStreakForOtherGamemodes)
addEventHandler("onPlayerWinDeadline", root, TriggerStreakForOtherGamemodes)

function IsRecordBroken()
	local record = GetRecordHolder()
	
	if not record[1] or currentPlayerStreakCount > tonumber(record[1]) then
		local streakPlayerName = getFullPlayerName(currentStreakPlayer)
		
		if record[0] then
			if streakPlayerName == record[0] then
				-- Player has broken his own record
				outputChatBox("[Streak] " .. streakPlayerName .. "#00FF00 has broken their own record of " .. record[1] .. "!", root, 0, 255, 0, true)
			else
				-- Player has broken somebody else's record
				outputChatBox("[Streak] " .. streakPlayerName .. "#00FF00 has broken " .. record[0] .. "#00FF00's record of " .. record[1] .. "!", root, 0, 255, 0, true)
			end
		else
			outputChatBox("[Streak] " .. streakPlayerName .. "#00FF00 has a new record of " .. currentPlayerStreakCount, root, 0, 255, 0, true)
		end
		return true
	end
	return false
end

function StreakRecordCommand(source)
	local record = GetRecordHolder()

	if record[0] then
		outputChatBox("[Streak] " .. record[0] .. " #00FF00is the current streak record holder with a streak of " .. record[1], source, 0, 255, 0, true)
	else
		outputChatBox("[Streak] Currently there is no streak holder.", root, 0, 255, 0, true)
	end
end
addCommandHandler("streak", StreakRecordCommand, false)
addCommandHandler("streaks", StreakRecordCommand, false)

function getFullPlayerName(player)
	local playerName = getElementData( player, "vip.colorNick" ) or getPlayerName( player )
	local teamColor = "#FFFFFF"
	local team = getPlayerTeam(player)
	if (team) then
		r,g,b = getTeamColor(team)
		teamColor = string.format("#%.2X%.2X%.2X", r, g, b)
	end
	return "" .. teamColor .. playerName
end