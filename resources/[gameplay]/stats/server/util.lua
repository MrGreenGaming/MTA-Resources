function getPlaytime(s)	
	local currentTime = getTickCount()
	local joinTime = s
	
	return currentTime - joinTime
end

function incrementPlayerStatsData(player, id, amount, forumID)
	if not player and not forumID then return false end
	
	local k = ""
	if player then
		k = "+"
	end
	
	local forumID = forumID or exports.gc:getPlayerForumID(player)

	if forumID then
		playerStatsCache[forumID][id] = playerStatsCache[forumID][id] + amount
		if debugMode2 then
			outputDebugString(getResourceName( getThisResource() )..": incrementPlayerStatsData() | forumID: "..forumID.." | Stat name: "..allStats[id].." | Value: "..k..""..playerStatsCache[forumID][id])
		end
	end
end


local month = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }

function getDateFromTimestamp(timestamp)
	if not timestamp then return "unknown" end
	
	local time = getRealTime(timestamp)
	time.year = time.year + 1900
	time.month = time.month + 1
	local month = month[time.month]
	
	return month.." "..time.monthday..", "..time.year
end


function number(num)
    last_digit = num % 10
    if last_digit == 1 and num ~= 11
        then return 'st'
    elseif last_digit == 2 and num ~= 12
        then return 'nd'
    elseif last_digit == 3 and num ~= 13
        then return 'rd'
    else 
        return 'th'
    end
end

local racemodes = {
					[1] = "race",
					[2] = "nts",
					[3] = "dd",
					[4] = "sh",
					[5] = "rtf",
					--[6] = "ctf",
}

function updateToptimes(forumID)
	local resTops = getResourceFromName'race_toptimes'
	if not resTops or getResourceState ( resTops ) ~= 'running' then 
		for i=1, #racemodes do
			local racemode = racemodes[i]
			playerStatsCache[forumID][racemode.."_top1"] = " - "
		end	
		return
	end
	
	local tops = exports.race_toptimes:getPlayerToptimes(forumID)

	for i=1, #racemodes do
		local racemode = racemodes[i]
		if tops ~= false and tops[racemode] then
			local topsString = ""
			if tops[racemode][1] then
				topsString = tops[racemode][1]
			else
				topsString = "0"
			end
			playerStatsCache[forumID][racemode.."_top1"] = topsString
		else
			playerStatsCache[forumID][racemode.."_top1"] = "0" --"Top1s - 121; Top2s - 102; Top3s - 109."--No tops yet :("
		end
	end
	--[[
	for i=1, #racemodes do
		local racemode = racemodes[i]
		if tops[racemode] then
			local topsString = ""
			for pos=1, 3 do
				if tops[racemode][pos] then
					if pos == 1 then
						topsString = "1st - "..tops[racemode][pos]..";"
					elseif pos == 2 then
						topsString = topsString.." "..pos..""..number(pos).." - "..tops[racemode][pos]..";"
					elseif pos == 3 then
						topsString = topsString.." "..pos..""..number(pos).." - "..tops[racemode][pos].."."
					end
				else
					if pos == 1 then
						topsString = "1st - 0;"
					elseif pos == 2 then
						topsString = topsString.." "..pos..""..number(pos).." - 0;"
					elseif pos == 3 then
						topsString = topsString.." "..pos..""..number(pos).." - 0."
					end
				end
			end
			playerStatsCache[forumID][racemode.."_tops"] = topsString
		else
			playerStatsCache[forumID][racemode.."_tops"] = "Top1s - 121; Top2s - 102; Top3s - 109."--No tops yet :("
		end
	end
	]]
end