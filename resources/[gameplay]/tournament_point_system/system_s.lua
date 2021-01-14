local Tournament = {}
Tournament.currentGamemode = ""
Tournament.playerPoints = {}

Tournament.sprintRank = tonumber(get("sprintRank"))
Tournament.ntsRank = tonumber(get("ntsRank"))
Tournament.ddRank = tonumber(get("ddRank"))
Tournament.ddKill = tonumber(get("ddKill"))
Tournament.shooterRank = tonumber(get("shooterRank"))
Tournament.shooterKill = tonumber(get("shooterKill"))
Tournament.rtfPoints = tonumber(get("rtfPoints"))

Tournament.chatPrefix = '#1FB907[Tournament]#FFFFFF '

exports.scoreboard:addScoreboardColumn('TourPoints', 'userdata', 80, 'TourPoints', MAX_PRIRORITY_SLOT)

for _, pl in ipairs(getElementsByType('player')) do
	setElementData(pl, 'TourPoints', 0)
end

function logStartEvent(resource)
	if getResourceName(resource) ~= "tournament_point_system" then return end

	exports.messages:outputGameMessage("Tournament has started!", root, 2.5, 255, 0, 0)
	outputChatBox(Tournament.chatPrefix .. "Tournament Points System | Developed by #40FF29Nick_026#FFFFFF | BETA MIX 1.1", root, 255, 255, 255, true)
	onMapChange()
end
addEventHandler("onResourceStart", getRootElement(), logStartEvent)

function onMapChange()
	local raceResRoot = getResourceRootElement( getResourceFromName( "race" ) )
	local raceInfo = raceResRoot and getElementData( raceResRoot, "info" )
	if raceInfo then
		Tournament.currentGamemode = raceInfo.mapInfo.modename
	end

	if Tournament.currentGamemode == "Sprint" then
		outputChatBox(Tournament.chatPrefix .. "Finish in " .. Tournament.sprintRank .. getSuffix(Tournament.sprintRank) .. " place or better to earn points.", root, 255, 255, 255, true)
	elseif Tournament.currentGamemode == "Never the same" then
		outputChatBox(Tournament.chatPrefix .. "Finish in " .. Tournament.ntsRank .. getSuffix(Tournament.ntsRank) .. " place or better to earn points.", root, 255, 255, 255, true)
	elseif Tournament.currentGamemode == "Shooter" then
		outputChatBox(Tournament.chatPrefix .. "Earn " .. Tournament.shooterKill .. " point(s) by killing someone and finish in " .. Tournament.shooterRank .. getSuffix(Tournament.shooterRank) .. " place or better to earn points.", root, 255, 255, 255, true)
	elseif Tournament.currentGamemode == "Destruction derby" then
		outputChatBox(Tournament.chatPrefix .. "Earn " .. Tournament.ddKill .. " point(s) by killing someone and finish in " .. Tournament.ddRank .. getSuffix(Tournament.ddRank) .. " place or better to earn points.", root, 255, 255, 255, true)
	elseif Tournament.currentGamemode == "Reach the flag" then
		outputChatBox(Tournament.chatPrefix .. "Reach the flag and earn " .. Tournament.rtfPoints .. " points.", root, 255, 255, 255, true)
	else
		outputChatBox(Tournament.chatPrefix .. "The gamemode '" .. Tournament.currentGamemode .. "' has not been implemented. No points will be earned!", root, 255, 255, 255, true)
	end

end
addEventHandler("onMapStarting", getRootElement(), onMapChange)


function logStopEvent(resource)
	if getResourceName(resource) ~= "tournament_point_system" then return end

	exports.messages:outputGameMessage("Tournament has ended!", root, 2.5, 255, 0, 0)
	outputChatBox(Tournament.chatPrefix .. "Thank you for using the Tournament Points System", root, 255, 255, 255, true)
	table.sort(Tournament.playerPoints, function(a, b) return a["points"] > b["points"] end)
	if Tournament.playerPoints[1] then
		outputChatBox("#FFD700In 1st place with " .. Tournament.playerPoints[1].points .. " points: " .. Tournament.playerPoints[1].nickname, root, 255, 255, 255, true)
	end
	if Tournament.playerPoints[2] then
		outputChatBox("#C0C0C0In 2nd place with " .. Tournament.playerPoints[2].points .. " points: " .. Tournament.playerPoints[2].nickname, root, 255, 255, 255, true)
	end
	if Tournament.playerPoints[3] then
		outputChatBox("#CD7F32In 3rd place with " .. Tournament.playerPoints[3].points .. " points: " .. Tournament.playerPoints[3].nickname, root, 255, 255, 255, true)
	end

	for k, player in ipairs(getElementsByType("player")) do
		local serial = getPlayerSerial(player)
		for i, line in ipairs(Tournament.playerPoints) do
			if line["serial"] == serial then
				outputChatBox(Tournament.chatPrefix .. "You finished in " .. i .. getSuffix(i) .. " place with " .. line["points"] .. " points", player, 255, 255, 255, true)
				break
			end
		end
	end
end
addEventHandler("onResourceStop", getRootElement(), logStopEvent)

function incrementPoints(player, points)

	local playerName = getFullPlayerName(player)

	local playerFound = false
	for i,line in ipairs(Tournament.playerPoints) do
		if line["serial"] == getPlayerSerial(source) then
			line["nickname"] = playerName
			line["points"] = line["points"] + points
			setElementData(source, "TourPoints", line["points"])
			playerFound = true
		end

	end
	if playerFound == false then
		table.insert(Tournament.playerPoints, {serial=getPlayerSerial(source), nickname = playerName, points = points})
		setElementData(source, "TourPoints", points)
	end

end

-- RACE

function onSprintFinish(rank)
	if Tournament.currentGamemode ~= "Sprint" then return end
	local playerName = getFullPlayerName(source)

	if (rank <= Tournament.sprintRank) then
		local pointsEarned = (Tournament.sprintRank - rank + 1) * 2

		outputChatBox(Tournament.chatPrefix .. "You earned " .. pointsEarned .. " points by placing " .. rank .. getSuffix(rank) .. "!", source, 255, 255, 255, true)
		exports.messages:outputGameMessage(playerName .. " finished " .. rank .. getSuffix(rank) .. " earning " .. pointsEarned .. " points", root, 2.5, 0,255,0, false, false,  true)
		incrementPoints(source, pointsEarned)

	else
		outputChatBox(Tournament.chatPrefix .. "You need to be at least " .. Tournament.sprintRank .. getSuffix(Tournament.sprintRank) .. " to earn points!", source, 255, 255, 255, true)
		exports.messages:outputGameMessage(playerName .. " finished " .. rank .. getSuffix(rank), root, 2.5, 255, 255, 255, false, false, true)
	end
end
addEventHandler("onPlayerFinish", getRootElement(), onSprintFinish)

-- Never the same

function onNtsFinish(rank)
	if Tournament.currentGamemode ~= "Never the same" then return end
	local playerName = getFullPlayerName(source)

	if (rank <= Tournament.ntsRank) then
		local pointsEarned = (Tournament.ntsRank - rank + 1) * 2

		outputChatBox(Tournament.chatPrefix .. "You earned " .. pointsEarned .. " points by placing " .. rank .. getSuffix(rank) .. "!", source, 255, 255, 255, true)
		exports.messages:outputGameMessage(playerName .. " finished " .. rank .. getSuffix(rank) .. " earning " .. pointsEarned .. " points", root, 2.5, 0,255,0, false, false,  true)
		incrementPoints(source, pointsEarned)
	else
		outputChatBox(Tournament.chatPrefix .. "You need to be at least " .. Tournament.ntsRank .. getSuffix(Tournament.ntsRank) .. " to earn points!", source, 255, 255, 255, true)
		exports.messages:outputGameMessage(playerName .. " finished " .. rank .. getSuffix(rank), root, 2.5, 255, 255, 255, false, false, true)
	end
end
addEventHandler("onPlayerFinish", getRootElement(), onNtsFinish)

-- Shooter

function onShooterFinish(rank)
	if Tournament.currentGamemode ~= "Shooter" then return end
	if exports.anti:isPlayerAFK(source) then return end

	local playerName = getFullPlayerName(source)

	if (rank <= Tournament.shooterRank) then
		local pointsEarned = (Tournament.shooterRank - rank + 1) * 2

		outputChatBox(Tournament.chatPrefix .. playerName .. " #FFFFFFfinished " .. rank .. getSuffix(rank) .. " earning " .. pointsEarned .. " points", root, 255, 255, 255, true)
		incrementPoints(source, pointsEarned)
	else 
		outputChatBox(Tournament.chatPrefix .. "You need to be at least " .. Tournament.shooterRank .. getSuffix(Tournament.shooterRank) .. " to earn points!", source, 255, 255, 255, true)
	end
end
addEventHandler("onPlayerFinishShooter", getRootElement(), onShooterFinish)

function onShooterWin()
	onShooterFinish(1)
end
addEventHandler("onPlayerWinShooter", getRootElement(), onShooterFinish)

function onShooterKill()
	if Tournament.currentGamemode ~= "Shooter" then return end
	incrementPoints(source, Tournament.shooterKill)
	outputChatBox(Tournament.chatPrefix .. "You earned " .. Tournament.shooterKill .. " point(s) for a kill.", source, 255, 255, 255, true)
end
addEventHandler("onShooterPlayerKill", getRootElement(), onShooterKill)

-- Derby

function onDerbyFinish(rank)
	if Tournament.currentGamemode ~= "Destruction derby" then return end
	if exports.anti:isPlayerAFK(source) then return end

	local playerName = getFullPlayerName(source)

	if (rank <= Tournament.ddRank) then
		local pointsEarned = (Tournament.ddRank - rank + 1) * 2

		outputChatBox(Tournament.chatPrefix .. playerName .. "#FFFFFF has earned " .. pointsEarned .. " points for finishing " .. rank .. getSuffix(rank), root, 255, 255, 255, true)
		incrementPoints(source, pointsEarned)
	else
		outputChatBox(Tournament.chatPrefix .. "You need to be at least " .. Tournament.ddRank .. getSuffix(Tournament.ddRank) " to earn points!", source, 255, 255, 255, true) 
	end
end
addEventHandler("onPlayerFinishDD", getRootElement(), onDerbyFinish)

function onDerbyWin()
	onDerbyFinish(1)
end
addEventHandler("onPlayerWinDD", getRootElement(), onDerbyWin)

function onDerbyKill() 
	if Tournament.currentGamemode ~= "Destruction derby" then return end
	incrementPoints(source, Tournament.ddKill)
	outputChatBox(Tournament.chatPrefix .. "You earned " .. Tournament.ddKill .. " point(s) for a kill", source, 255, 255, 255, true)
end
addEventHandler("onDDPlayerKill", getRootElement(), onDerbyKill)

-- Reach the flag

function onRTFFinish(rank, time)
	if Tournament.currentGamemode ~= "Reach the flag" then return end

	local playerName = getFullPlayerName(source)
	incrementPoints(source, Tournament.rtfPoints)
	outputChatBox(Tournament.chatPrefix .. playerName .. "#FFFFFF has earned " .. Tournament.rtfPoints .. " points for reaching the flag first!", root, 255, 255, 255, true)
end
addEventHandler("onPlayerFinish", getRootElement(), onRTFFinish)

function playerJoin()
	for i, line in ipairs(Tournament.playerPoints) do
		if line["serial"] == getPlayerSerial(source) then
			local points = line["points"]
			setElementData(source, "TourPoints", points, true)
			outputChatBox(Tournament.chatPrefix .. "You currently have " .. points .. " points!", source, 255, 255, 255, true)
			return
		end
	end
	setElementData(source, "TourPoints", 0)
end
addEventHandler("onPlayerJoin", getRootElement(), playerJoin)

function playerChangeNick(oldNick, newNick)
	for i, line in ipairs(Tournament.playerPoints) do
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
	outputChatBox(Tournament.chatPrefix .. "The scoring is as follows:", root, 255, 255, 255, true)
	table.sort(Tournament.playerPoints, function(a, b) return a["points"] > b["points"] end)
	for i,line in ipairs(Tournament.playerPoints) do
		if i > 5 then break end
		local player = line["nickname"]
		local points = line["points"]
		outputChatBox(i .. getSuffix(i) .. ": " .. player .. "#FFFFFF with " .. points .. " points", root, 255, 255, 255, true)
	end

	for k, player in ipairs(getElementsByType("player")) do
		local serial = getPlayerSerial(player)
		for i, line in ipairs(Tournament.playerPoints) do
			if line["serial"] == serial then
				outputChatBox(Tournament.chatPrefix .. "You are in " .. i .. getSuffix(i) .. " place with " .. line["points"] .. " points", player, 255, 255, 255, true)
				break
			end
		end
	end
end
addEventHandler("onPostFinish",getRootElement(), logPoints)
addCommandHandler("logTournamentPoints", logPoints, true)

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
