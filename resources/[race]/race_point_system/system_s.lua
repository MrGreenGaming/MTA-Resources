-- Last place that still earns points
-- example: if set to 5, rank 1 through 5 will earn points
local nPlaceToGivePoints = 5

local chatPrefix = '#1FB907[Tournament]#FFFFFF'

playerPoints = {
	
}


local isLogged = false;
function logStartEvent() 
	if isLogged == false then
		isLogged = true
		exports.messages:outputGameMessage("Tournament Points System", root, 2.5, 255, 255, 255)
		outputChatBox(chatPrefix .. "Tournament Points System | Developed by #40FF29Nick_026#FFFFFF | BETA", root, 255, 255, 255, true)
		outputChatBox(chatPrefix .. "To earn points finish in " .. nPlaceToGivePoints .. getSuffix(nPlaceToGivePoints) .. " place or better!", root, 255, 255, 255, true)
	end
end
addEventHandler("onResourceStart", getRootElement(), logStartEvent)

exports.scoreboard:addScoreboardColumn('TourPoints', 'userdata', 80, 'TourPoints', MAX_PRIRORITY_SLOT)

for _, pl in ipairs(getElementsByType('player')) do
	setElementData(pl, 'TourPoints', 0)
end

function calculatePoints(rank) 
	if (rank <= nPlaceToGivePoints) then
		local pointsEarned = nPlaceToGivePoints - rank + 1
		local playerName =getElementData( source, "vip.colorNick" ) or getPlayerName( source )
		local playerFound = false
		outputChatBox(chatPrefix .. "You earned " .. pointsEarned .. " point(s) by placing " .. rank .. getSuffix(rank) .. "!", source, 255, 255, 255, true)
		exports.messages:outputGameMessage(playerName .. " has earned " .. pointsEarned .. " points by placing " .. rank .. getSuffix(rank), root, 2.5, 255,255,255)
		for i,line in ipairs(playerPoints) do
			if line["serial"] == getPlayerSerial(source) then
				line["nickname"] = playerName
				line["points"] = line["points"] + pointsEarned
				setElementData(source, "TourPoints", line["points"])
				playerFound = true
			end
			
		end
		if playerFound == false then
			table.insert(playerPoints, {serial=getPlayerSerial(source), nickname = playerName, points = pointsEarned})
			setElementData(source, "TourPoints", pointsEarned)
		end
	else 
		outputChatBox("You need to be at least " .. nPlaceToGivePoints .. getSuffix(nPlaceToGivePoints) .. " to earn points!", source, 255, 255, 255, true)
	end
end
addEventHandler("onPlayerFinish", getRootElement(), calculatePoints)

function playerJoin() 
	for i, line in ipairs(playerPoints) do
		local points = 0
		if line["serial"] == getPlayerSerial(source) then
			points = line["points"]
			setElementData(source, "TourPoints", points, true)
			outputChatBox(chatPrefix .. "You currently have " .. points .. " point(s)!", source, 255, 255, 255, true)
		else
			setElementData(source, "TourPoints", 0)
		end
	end
end
addEventHandler("onPlayerJoin", getRootElement(), playerJoin)

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
		local points = line["points"]
		outputChatBox(i .. getSuffix(i) .. ": " .. player .. "#FFFFFF with " .. points .. " points", root, 255, 255, 255, true)
	end

	for k, player in ipairs(getElementsByType("player")) do
		local serial = getPlayerSerial(player)
		for i, line in ipairs(playerPoints) do
			if line["serial"] == serial then
				outputChatBox(chatPrefix .. "You are in " .. i .. getSuffix(i) .. " place with " .. line["points"] .. " point(s)", player, 255, 255, 255, true)
				break
			end
		end
	end
end
addEventHandler("onPostFinish",getRootElement(), logPoints)
addCommandHandler("logTournamentPoints", logPoints, true)