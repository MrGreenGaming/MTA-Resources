local activeMoment = nil

local raceMoments = {
	-- 1
	{ name = "Best Race Player", task = "Finish to earn points.", rounds = 5, args = {}},
}

local mixMoments = {
	--1 
	{ name = "Best NTS Player", task = "Finish to earn points. (Only NTS maps will spawn!)", rounds = 5, args = { gamemode = "nts" }},
}

function rollDice()
	if activeMoment then return end
	local dice = math.random(1, 100)

	if dice ~= 14 and dice ~= 27 and dice ~= 42 and dice ~= 69 then
		logToConsole("No Happy Moment! Dice rolled: " .. dice)
		return
	end

	logToConsole("Happy Moment triggered! Dice rolled: " .. dice)

	if getPlayerCount() <= 2 then
		logToConsole("Not enough players to trigger Happy Moment.")
		return
	end

	if getResourceState(getResourceFromName("cw_script")) == "running" then
		logToConsole("Happy Moment not triggered due to CW script being active.")
		return
	end

	local isRace = (get("happy_moments.isRace") or false) == 'true'

	local moment = nil
	if isRace then
		moment = raceMoments[math.random(1, #raceMoments)]
	else
		moment = mixMoments[math.random(1, #mixMoments)]
	end

	triggerMoment(moment);

end
addEvent("onPostFinish", true)
addEventHandler("onPostFinish", root, rollDice)

function triggerThroughCommand(p, _, arg)
	local isRace = (get("happy_moments.isRace") or false) == 'true'
	
	if not p or not arg or #arg == 0 then
		outputChatBox("Usage: /triggerHappyMoment <moment id>", p, 255, 0, 0)
		return
	end
	local id = tonumber(arg)

	if activeMoment then
		outputChatBox("A Happy Moment is already active.", p, 255, 0, 0)
		return
	end

	local moment = nil
	if isRace then
		moment = raceMoments[id]
	else
		moment = mixMoments[id]
	end
	if not moment then
		outputChatBox("Invalid moment ID.", p, 255, 0, 0)
		return
	end


	if getResourceState(getResourceFromName("cw_script")) == "running" then
		outputChatBox("Happy Moment not triggered due to CW script being active.", p, 255, 0, 0)
		return
	end

	triggerMoment(moment);
end
addCommandHandler("triggerHappyMoment", triggerThroughCommand, true, false)

function triggerMoment(moment)
	activeMoment = moment;

	startResource(getResourceFromName("cw_script"));

	outputChatBox("Happy Moment - " .. moment.name .. " started!", root, 0, 255, 0)

	exports.messages:outputGameMessage('A Happy Moment has spawned!', root, 2.5, 100,255,100, false, false,  true)
	
	setTimer(function()
		exports.messages:outputGameMessage("Happy Moment - " .. moment.name .. " started!", root, 2.5, 255,100,100, false, false,  true)
	end, 1500, 1)

	setTimer(function()
		exports.messages:outputGameMessage("Task: " .. moment.task .. "! Good luck!",root, 2.5, 100,100,255, false, false,  true)
	end, 3000, 1)

	exports.cw_script:triggerHappyMoment(moment.name, moment.task, moment.rounds)
end

function endMoment(players)
	if not activeMoment then return end
	if not players or #players == 0 then return end

	local moment = activeMoment
	activeMoment = nil

	local nPlayers = #players

	if getResourceState(getResourceFromName("cw_script")) == "running" then
		stopResource(getResourceFromName("cw_script"))
	end

	local reward1st = nPlayers * 10
	local reward2nd = math.floor(reward1st * 2 / 3)
	local reward3rd = math.floor(reward1st * 1 / 3)

	outputChatBox("Happy Moment - " .. moment.name .. " ended!", root, 0, 255, 0)
	outputChatBox("------- REWARDS -------", root, 0, 255, 0)

	if players[1] then
		exports.gc:addPlayerGreencoins(players[1], reward1st)
		local name = getElementData(players[1], "vip.colorNick") or getPlayerName(players[1])
		outputChatBox("#FFD7001st Place: " .. name .. " received " .. reward1st .. " GC!", root, 255, 255, 255, true)
	end

	if players[2] then
		exports.gc:addPlayerGreencoins(players[2], reward2nd)
		local name = getElementData(players[2], "vip.colorNick") or getPlayerName(players[2])
		outputChatBox("#C0C0C02nd Place: " .. name .. " received " .. reward2nd .. " GC!", root, 255, 255, 255, true)
	end

	if players[3] then
		exports.gc:addPlayerGreencoins(players[3], reward3rd)
		local name = getElementData(players[3], "vip.colorNick") or getPlayerName(players[3])
		outputChatBox("#CD7F323rd Place: " .. name .. " received " .. reward3rd .. " GC!", root, 255, 255, 255, true)
	end
end
addEventHandler("cw_script.ended", root, endMoment)

function getHappyMomentArg(arg)
	if activeMoment and activeMoment.args[arg] then
		return activeMoment.args[arg]
	end
	return false
end


function logToConsole(message)
	outputDebugString("[Happy Moments] " .. message)
end