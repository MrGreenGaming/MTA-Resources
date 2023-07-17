function incrementPoints(player, points)
	local playerName = getFullPlayerName(player)
	local playerFound = false

	for i, line in ipairs(Tournament.playerPoints) do
		if line.serial == getPlayerSerial(player) then
			line.nickname = playerName
			line.points = line.points + points
			setElementData(player, "TourPoints", line.points)
			playerFound = true
			break
		end
	end

	if not playerFound then
		table.insert(Tournament.playerPoints, { serial = getPlayerSerial(player), nickname = playerName, points = points })
		setElementData(player, "TourPoints", points)
	end
end

function getSuffix(rank)
	local lastDigit = rank % 10
	local lastTwoDigits = rank % 100

	if lastTwoDigits >= 11 and lastTwoDigits <= 13 then
		return "th"
	elseif lastDigit == 1 then
		return "st"
	elseif lastDigit == 2 then
		return "nd"
	elseif lastDigit == 3 then
		return "rd"
	else
		return "th"
	end
end

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

function calculateF1Score(position)
    local scores = {25, 18, 15, 12, 10, 8, 6, 4, 2, 1}
    return scores[position] or 0
end
