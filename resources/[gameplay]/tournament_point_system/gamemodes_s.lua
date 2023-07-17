-- Race & NTS

function onSprintNtsFinish(rank)
	if Tournament.currentGamemode ~= "Sprint" and Tournament.currentGamemode ~= "Never the same" then return end
	local playerName = getFullPlayerName(source)
    local score = calculateF1Score(rank)

	if (score > 0) then
		outputChatBox(Tournament.chatPrefix .. "You earned " .. score .. " points by placing " .. rank .. getSuffix(rank) .. "!", source, 255, 255, 255, true)
		exports.messages:outputGameMessage(playerName .. " finished " .. rank .. getSuffix(rank) .. " earning " .. score .. " points", root, 2.5, 0,255,0, false, false,  true)
		incrementPoints(source, score)
	else
		outputChatBox(Tournament.chatPrefix .. "You need to be at least 10th to earn points!", source, 255, 255, 255, true)
		exports.messages:outputGameMessage(playerName .. " finished " .. rank .. getSuffix(rank), root, 2.5, 255, 255, 255, false, false, true)
	end
end
addEventHandler("onPlayerFinish", root, onSprintNtsFinish)

-- Shooter

function onShooterFinish(rank)
	if Tournament.currentGamemode ~= "Shooter" then return end
	if exports.anti:isPlayerAFK(source) then return end

	local playerName = getFullPlayerName(source)
	local score = calculateF1Score(rank)

	if score > 0 then
		outputChatBox(Tournament.chatPrefix .. playerName .. " #FFFFFFfinished " .. rank .. getSuffix(rank) .. " earning " .. score .. " points", root, 255, 255, 255, true)
		incrementPoints(source, score)
	else
		outputChatBox(Tournament.chatPrefix .. "You need to be at least 10th to earn points!", source, 255, 255, 255, true)
	end
end
addEventHandler("onPlayerFinishShooter", root, onShooterFinish)
addEventHandler("onPlayerWinShooter", root, function() onShooterFinish(1) end)


function onShooterKill()
	if Tournament.currentGamemode ~= "Shooter" then return end
	incrementPoints(source, Tournament.shooterKill)
	outputChatBox(Tournament.chatPrefix .. "You earned " .. Tournament.shooterKill .. " point(s) for a kill.", source, 255, 255, 255, true)
end
addEventHandler("onShooterPlayerKill", root, onShooterKill)

-- Derby

function onDerbyFinish(rank)
	if Tournament.currentGamemode ~= "Destruction derby" then return end
	if exports.anti:isPlayerAFK(source) then return end

	local playerName = getFullPlayerName(source)
    local score = calculateF1Score(rank)

	if (score > 0) then
		outputChatBox(Tournament.chatPrefix .. playerName .. "#FFFFFF has earned " .. score .. " points for finishing " .. rank .. getSuffix(rank), root, 255, 255, 255, true)
		incrementPoints(source, score)
	else
		outputChatBox(Tournament.chatPrefix .. "You need to be at least 10th to earn points!", source, 255, 255, 255, true)
	end
end
addEventHandler("onPlayerFinishDD", root, onDerbyFinish)

function onDerbyWin()
	onDerbyFinish(1)
end
addEventHandler("onPlayerWinDD", root, onDerbyWin)

function onDerbyKill()
	if Tournament.currentGamemode ~= "Destruction derby" then return end
	incrementPoints(source, Tournament.ddKill)
	outputChatBox(Tournament.chatPrefix .. "You earned " .. Tournament.ddKill .. " point(s) for a kill", source, 255, 255, 255, true)
end
addEventHandler("onDDPlayerKill", root, onDerbyKill)

-- Reach the flag

function onRTFFinish(rank, time)
	if Tournament.currentGamemode ~= "Reach the flag" then return end

	local playerName = getFullPlayerName(source)
    local score = calculateF1Score(1)
	incrementPoints(source, score)
	outputChatBox(Tournament.chatPrefix .. playerName .. "#FFFFFF has earned " .. score .. " points for reaching the flag first!", root, 255, 255, 255, true)
end
addEventHandler("onPlayerFinish", root, onRTFFinish)
