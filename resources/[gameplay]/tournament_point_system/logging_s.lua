function logStartEvent(resource)
	if getResourceName(resource) ~= "tournament_point_system" then return end

	exports.messages:outputGameMessage("Tournament has started!", root, 2.5, 255, 0, 0)
	outputChatBox(Tournament.chatPrefix .. "Tournament Points System | Developed by #40FF29Nick_026#FFFFFF | BETA MIX 1.1", root, 255, 255, 255, true)
	onMapChange()
end
addEventHandler("onResourceStart", root, logStartEvent)

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

function logCurrentGamemodeInfo()
    local gamemodeOutput = ""
	if gammode == "Sprint" or Tournament.currentGamemode == "Never the same" then
		gamemodeOutput = "Finish in 10th place or better to earn points."
	elseif Tournament.currentGamemode == "Shooter" then
		gamemodeOutput = "Earn " .. Tournament.shooterKill .. " point(s) by killing someone and finish in 10th place or better to earn points."
	elseif Tournament.currentGamemode == "Destruction derby" then
		gamemodeOutput = "Earn " .. Tournament.ddKill .. " point(s) by killing someone and finish in 10th place or better to earn points."
	elseif Tournament.currentGamemode == "Reach the flag" then
		gamemodeOutput = "Reach the flag and earn " .. calculateF1Score(1) .. " points."
	else
		gamemodeOutput = "The gamemode '" .. Tournament.currentGamemode .. "' has not been implemented. No points will be earned!"
	end
	outputChatBox(Tournament.chatPrefix .. gamemodeOutput, root, 255, 255, 255, true)
end

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
