-- Last place that still earns points
-- example: if set to 5, rank 1 through 5 will earn points
local nPlaceToGivePoints = tonumber(get("lastPositionToReward"))

local chatPrefix = '#1FB907[Tournament]#FFFFFF '

playerPoints = {
}


function logStartEvent(resource) 
	if getResourceName(resource) ~= "tournament_point_system" then return end

	exports.messages:outputGameMessage("Tournament has started!", root, 2.5, 255, 0, 0)
	outputChatBox(chatPrefix .. "Tournament Points System | Developed by #40FF29Nick_026#FFFFFF | BETA", root, 255, 255, 255, true)
	outputChatBox(chatPrefix .. "To earn points finish in " .. nPlaceToGivePoints .. getSuffix(nPlaceToGivePoints) .. " place or better!", root, 255, 255, 255, true)
end
addEventHandler("onResourceStart", getRootElement(), logStartEvent)

function logStopEvent(resource)
	if getResourceName(resource) ~= "tournament_point_system" then return end

	exports.messages:outputGameMessage("Tournament has ended!", root, 2.5, 255, 0, 0)
	outputChatBox(chatPrefix .. "Thank you for using the Tournament Points System", root, 255, 255, 255, true)
	table.sort(playerPoints, function(a, b) return a["points"] > b["points"] end)
	if playerPoints[1] then
		outputChatBox("#FFD700In 1st place with " .. playerPoints[1].points .. " points: " .. playerPoints[1].teamColor ..playerPoints[1].nickname, root, 255, 255, 255, true)
	end
	if playerPoints[2] then
		outputChatBox("#C0C0C0In 2nd place with " .. playerPoints[2].points .. " points: " .. playerPoints[2].teamColor.. playerPoints[2].nickname, root, 255, 255, 255, true)
	end
	if playerPoints[3] then
		outputChatBox("#CD7F32In 3rd place with " .. playerPoints[3].points .. " points: " .. playerPoints[3].teamColor .. playerPoints[3].nickname, root, 255, 255, 255, true)
	end

	for k, player in ipairs(getElementsByType("player")) do
		local serial = getPlayerSerial(player)
		for i, line in ipairs(playerPoints) do
			if line["serial"] == serial then
				outputChatBox(chatPrefix .. "You finished in " .. i .. getSuffix(i) .. " place with " .. line["points"] .. " points", player, 255, 255, 255, true)
				break
			end
		end
	end
end
addEventHandler("onResourceStop", getRootElement(), logStopEvent)


exports.scoreboard:addScoreboardColumn('TourPoints', 'userdata', 80, 'TourPoints', MAX_PRIRORITY_SLOT)

for _, pl in ipairs(getElementsByType('player')) do
	setElementData(pl, 'TourPoints', 0)
end

function calculatePoints(rank) 
	local playerName =getElementData( source, "vip.colorNick" ) or getPlayerName( source )
	local teamColor = "#FFFFFF"
	local team = getPlayerTeam(source)
	if (team) then
		r,g,b = getTeamColor(team)
		teamColor = string.format("#%.2X%.2X%.2X", r, g, b)
	end
	if (rank <= nPlaceToGivePoints) then
		local pointsEarned = (nPlaceToGivePoints - rank + 1) * 2
		local playerFound = false

		outputChatBox(chatPrefix .. "You earned " .. pointsEarned .. " points by placing " .. rank .. getSuffix(rank) .. "!", source, 255, 255, 255, true)

		exports.messages:outputGameMessage(playerName .. " finished " .. rank .. getSuffix(rank) .. " earning " .. pointsEarned .. " points", root, 2.5, 0,255,0, false, false,  true)
		for i,line in ipairs(playerPoints) do
			if line["serial"] == getPlayerSerial(source) then
				line["nickname"] = playerName
				line["teamColor"] = teamColor
				line["points"] = line["points"] + pointsEarned
				setElementData(source, "TourPoints", line["points"])
				playerFound = true
			end
			
		end
		if playerFound == false then
			table.insert(playerPoints, {serial=getPlayerSerial(source), nickname = playerName, points = pointsEarned, teamColor = teamColor})
			setElementData(source, "TourPoints", pointsEarned)
		end
	else 
		outputChatBox(chatprefix .. "You need to be at least " .. nPlaceToGivePoints .. getSuffix(nPlaceToGivePoints) .. " to earn points!", source, 255, 255, 255, true)
		exports.messages:outputGameMessage(playername .. " finished " .. rank .. getSuffix(rank), root, 2.5, 255, 255, 255, false, false, true)
	end
end
addEventHandler("onPlayerFinish", getRootElement(), calculatePoints)

function playerJoin() 
	for i, line in ipairs(playerPoints) do
		local points = 0
		if line["serial"] == getPlayerSerial(source) then
			points = line["points"]
			setElementData(source, "TourPoints", points, true)
			outputChatBox(chatPrefix .. "You currently have " .. points .. " points!", source, 255, 255, 255, true)
		else
			setElementData(source, "TourPoints", 0)
		end
	end
end
addEventHandler("onPlayerJoin", getRootElement(), playerJoin)

function playerChangeNick(oldNick, newNick)
	for i, line in ipairs(playerPoints) do
		if line["serial"] == getPlayerSerial(source) then
			line["nickname"] = newNick
		end
	end
end
addEventHandler("onPlayerChangeNick", getRootElement(), playerChangeNick)

function getSuffix(rank)
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
	return suffix
end

function logPoints() 
	outputChatBox(chatPrefix .. "The scoring is as follows:", root, 255, 255, 255, true)
	table.sort(playerPoints, function(a, b) return a["points"] > b["points"] end)
	for i,line in ipairs(playerPoints) do
		if i > 5 then break end
		local player = line["nickname"]
		local teamColor = line["teamColor"]
		local points = line["points"]
		outputChatBox(i .. getSuffix(i) .. ": " .. teamColor .. player .. "#FFFFFF with " .. points .. " points", root, 255, 255, 255, true)
	end

	for k, player in ipairs(getElementsByType("player")) do
		local serial = getPlayerSerial(player)
		for i, line in ipairs(playerPoints) do
			if line["serial"] == serial then
				outputChatBox(chatPrefix .. "You are in " .. i .. getSuffix(i) .. " place with " .. line["points"] .. " points", player, 255, 255, 255, true)
				break
			end
		end
	end
end
addEventHandler("onPostFinish",getRootElement(), logPoints)
addCommandHandler("logTournamentPoints", logPoints, true)