local lobbyResName = "0MrGreenLobby"

function startRound(mapInfo)
    CurrentGamemode = exports.race:getRaceMode();

	f_round = false
	if c_round < rounds  then
		if round_ended then
			c_round = c_round + 1
		end
		round_started = true
	end

    eventName = exports.eventmanager:getEventName()
    local nextMapName = exports.eventmanager:getNextMapName()

    if not nextMapName then
        nextMapName = exports.gcshop:getQueuedMapName()
    end

    if mapInfo.resname == lobbyResName then
        f_round = true
    end

    -- sets next map to Lobby for CW's
    if mapInfo.resname ~= lobbyResName and c_round ~= rounds and ffa_mode == "CW" then
        triggerEvent("onEventSetNextMapLobby", root, lobbyResName)
    end

	for i,player in ipairs(getElementsByType('player')) do
		clientCall(player, 'updateRoundData', c_round, rounds, f_round)
        clientCall(player, 'updateEventMetadata', eventName, nextMapName)
	end
	round_ended = false
end
addEvent('onMapStarting', true)
addEventHandler('onMapStarting', getRootElement(), startRound)

function playerFinished(player, rank)
	if isElement(teams[1]) and isElement(teams[2]) and isElement(teams[3]) then
		if getPlayerTeam(player) ~= teams[3] and not f_round and c_round > 0 then
			local p_score = scoring[rank] or 0

            local playerTeam = getPlayerTeam(player)
            if playerTeam then
                local old_score = getElementData(playerTeam, 'Score') or 0
                local new_score = old_score + p_score
                setElementData(playerTeam, 'Score', new_score)
            end
			local old_p_score = getElementData(player, 'Score')
			local new_p_score = old_p_score + p_score
			setElementData(player, 'Score', new_p_score)

            updateScoreData(player)

            if p_score > 0 then
                exports.messages:outputGameMessage(getPlayerName( player ).. ' earned ' ..p_score.. ' points!', root, 2.5, 0,255,0, false, false,  true)
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
            if ffa_mode == "CW" then
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
    triggerClientEvent("updateDisplayPlayerData", root)
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
    if not areTeamsSet() or (ffa_mode == "FFA" and ffa_keep_modshop) then return end
    if getElementType(source)== 'vehicle' then
        local player = getVehicleOccupant(source)
        if not player then return end
        setTimer(setColors, 50, 1, player, source)
    end
end)

addEventHandler('onPlayerVehicleEnter', root, function(vehicle, seat)
    if not areTeamsSet() or (ffa_mode == "FFA" and ffa_keep_modshop) then return end
    setColors(source, vehicle)
end)

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging",root,
	function(new, old)
		local players = getElementsByType("player")
		for k,v in ipairs(players) do
			local thePlayer = v
			local playerTeam = getPlayerTeam (thePlayer)
			local theBlip = getBlipAttachedTo(thePlayer)
			local r,g,b
			if ( playerTeam ) then
				if new == "Running" and old == "GridCountdown" then
					r, g, b = getTeamColor (playerTeam)
					setBlipColor(theBlip, tostring(r), tostring(g), tostring(b), 255)
					if playerTeam == teams[3] then
                        if CurrentGamemode == "Destruction derby" or CurrentGamemode == "Shooter" then
                            killPed(thePlayer)
                        else
                            exports.anti:forcePlayerSpectatorMode(thePlayer)
                        end
					end
				end
			end
		end
	end
)

addEventHandler("onTellCwScriptPlayerBoughtMap", root, function(mapName)
    for i, player in ipairs(getElementsByType('player')) do
        clientCall(player, "updateNextMapNameIfNotSet", mapName)
    end
end)
