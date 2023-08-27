function startRound()
    CurrentGamemode = exports.race:getRaceMode();

	f_round = false
	if c_round < rounds  then
		if round_ended then
			c_round = c_round + 1
		end
		round_started = true
--	else
	end
	for i,player in ipairs(getElementsByType('player')) do
		clientCall(player, 'updateRoundData', c_round, rounds, f_round)
	end
	round_ended = false
end
addEvent('onMapStarting', true)
addEventHandler('onMapStarting', getRootElement(), startRound)

function playerFinished(player, rank)
	if isElement(teams[1]) and isElement(teams[2]) and isElement(teams[3]) then
		if getPlayerTeam(player) ~= teams[3] and not f_round and c_round > 0 then
			local p_score = scoring[rank] or 0

			local t1r, t1g, t1b = getTeamColor(teams[1])
			local t1c = rgb2hex(t1r, t1g, t1b)
			local t2r, t2g, t2b = getTeamColor(teams[2])
			local t2c = rgb2hex(t2r, t2g, t2b)
			local old_score = getElementData(getPlayerTeam(player), 'Score')
			local new_score = old_score + p_score
			local old_p_score = getElementData(player, 'Score')
			local new_p_score = old_p_score + p_score
			setElementData(player, 'Score', new_p_score)
			setElementData(getPlayerTeam(player), 'Score', new_score)

            updateScoreData(player)

			if getPlayerTeam(player) == teams[1] then
				exports.messages:outputGameMessage(t1c .. getPlayerName( player ).. ' #ffffffgot #9b9bff' ..p_score.. ' #ffffffpoints #9b9bff('.. new_p_score .. ')', root, 2.5, 0,255,0, false, false,  true)
			elseif getPlayerTeam(player) == teams[2] then
				exports.messages:outputGameMessage(t2c .. getPlayerName( player ).. ' #ffffffgot #9b9bff' ..p_score.. ' #ffffffpoints #9b9bff('.. new_p_score .. ')', root, 2.5, 0,255,0, false, false,  true)
			end
		end
	end
end

function endRound()
	if isElement(teams[1]) and isElement(teams[2]) and not f_round then

		if c_round > 0 then
			if not round_ended then
				round_ended = true
			end
		end
		if c_round == rounds then
            if mode == "CW" then
                endClanWar()
            else
                endFreeForAll()
            end
            logScoreDataToConsole()
            destroyTeams(false)
            stopResource(getThisResource())
		end
	end
end
addEvent('onPostFinish', true)
addEventHandler('onPostFinish', getRootElement(), endRound)

function onPlayerChangeTeam(team)
    setColors(source, getPedOccupiedVehicle(source))
    if team == getTeamName(teams[3]) then
        exports.anti:forcePlayerSpectatorMode(source)
    end
end
addEvent("onPlayerChangeTeam", true)
addEventHandler("onPlayerChangeTeam", root, onPlayerChangeTeam)

function playerLogin(p_a, c_a)
	local accName = getAccountName(c_a)
	if isObjectInACLGroup("user."..accName, aclGetGroup("Admin")) then
		clientCall(source, 'updateAdminInfo', true)
	else
		clientCall(source, 'updateAdminInfo', false)
	end
end
addEventHandler('onPlayerLogin', getRootElement(), playerLogin)

addEventHandler('onPlayerReachCheckpoint', getRootElement(), function()
    local team = getPlayerTeam(source)
    if team == teams[3] then
        exports.anti:forcePlayerSpectatorMode(source)
        outputInfoForPlayer(source, '#FF0000You\'re not allowed to play as Spectator')
    end
end)

addEventHandler('onElementDataChange', root, function(key, old, new)
    if getElementType(source) ~= 'player' then return end
    if key == 'player state' then
        local playerTeam = getPlayerTeam(source)
        if playerTeam == teams[3] and new == 'alive' and old ~= 'not ready' then
            outputInfoForPlayer(source, '#FF0000You\'re not allowed to play as Spectator')
            exports.anti:forcePlayerSpectatorMode(source)
        end
    end
end)

addEventHandler('onElementModelChange', root, function()
    if mode == "FFA" then return end
    if getElementType(source)== 'vehicle' then
        local player = getVehicleOccupant(source)
        if not player then return end
        setTimer(setColors, 50, 1, player, source)
    end
end)

addEventHandler('onPlayerVehicleEnter', root, function(vehicle, seat)
    if mode == "FFA" then return end
    setColors(source, vehicle)
end)

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging",root,
	function(old, new)
		local players = getElementsByType("player")
		for k,v in ipairs(players) do
			local thePlayer = v
			local playerTeam = getPlayerTeam (thePlayer)
			local theBlip = getBlipAttachedTo(thePlayer)
			local r,g,b
			if ( playerTeam ) then
				if old == "Running" and new == "GridCountdown" then
					r, g, b = getTeamColor (playerTeam)
					setBlipColor(theBlip, tostring(r), tostring(g), tostring(b), 255)
					if playerTeam == teams[3] then
						exports.anti:forcePlayerSpectatorMode(thePlayer)
					end
				end
			end
		end
	end
)
