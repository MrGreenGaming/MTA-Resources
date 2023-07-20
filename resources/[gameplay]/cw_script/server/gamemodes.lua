-- Race & NTS

function onSprintNtsFinish(rank)
	if CurrentGamemode ~= "Sprint" and CurrentGamemode ~= "Never the same" then return end
    playerFinished(source, rank)
end
addEventHandler("onPlayerFinish", root, onSprintNtsFinish)

-- Shooter & Derby

function onShDdFinish(rank)
	if CurrentGamemode ~= "Shooter" and CurrentGamemode ~= "Destruction derby" then return end
	if exports.anti:isPlayerAFK(source) then return end

    playerFinished(source, rank)
end
addEventHandler("onPlayerFinishShooter", root, onShDdFinish)
addEventHandler("onPlayerWinShooter", root, function() onShDdFinish(1) end)
addEventHandler("onPlayerFinishDD", root, onShDdFinish)
addEventHandler("onPlayerWinDD", root, function() onShDdFinish(1) end)

-- Reach the flag

function onRTFFinish(rank, time)
	if CurrentGamemode ~= "Reach the flag" then return end

    playerFinished(source, rank)
end
addEventHandler("onPlayerFinish", root, onRTFFinish)
