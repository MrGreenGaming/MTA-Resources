--------------
function preStart(player, command, t1_name, t2_name, t1tag, t2tag)
	if isAdmin(player) then
		destroyTeams()
		if t1_name ~= nil and t2_name ~= nil then
			teams[1] = createTeam(t1_name, 255, 0, 0)
			teams[2] = createTeam(t2_name, 0, 0, 255)
		else
			teams[1] = createTeam('Team 1', 255, 0, 0)
			teams[2] = createTeam('Team 2', 0, 0, 255)
			outputInfo('no team names')
			outputInfo('using default team names')
		end

		if t1tag ~= nil and t2tag ~= nil then
			tags[1] = tag1
			tags[2] = tag2
		else
			tags[1] = 't1'
			tags[2] = 't2'
			outputInfo('no tags')
			outputInfo('using default tags')
		end
		teams[3] = createTeam('Spectators', 255, 255, 255)
		for i,player in ipairs(getElementsByType('player')) do
            if ffa_mode == "FFA" then
                setPlayerTeam(player, teams[1])
            else
                setPlayerTeam(player, teams[3])
            end
			setElementData(player, 'Score', 0)
		end
		setElementData(teams[1], 'Score', 0)
		setElementData(teams[2], 'Score', 0)
		round_ended = true
		c_round = 0
        call(getResourceFromName("scoreboard"), "scoreboardAddColumn", "PtsPerMap")
		call(getResourceFromName("scoreboard"), "scoreboardAddColumn", "Score")
		for i, player in ipairs(getElementsByType('player')) do
			clientCall(player, 'updateTeamData', teams[1], teams[2], teams[3])
			clientCall(player, 'updateTagData', tags[1], tags[2])
			clientCall(player, 'updateRoundData', c_round, rounds, f_round)
            if ffa_mode == "CW" then
                clientCall(player, 'createGUI', getTeamName(teams[1]), getTeamName(teams[2]))
            end
		end
	else
		outputInfoForPlayer(player, 'You are not admin')
	end
end

function destroyTeams(player)
	if isAdmin(player) then
		for i,team in ipairs(teams) do
			if isElement(team) then
				destroyElement(team)
			end
		end
		for i,player in ipairs(getElementsByType('player')) do
			clientCall(player, 'updateTeamData', teams[1], teams[2], teams[3])
			clientCall(player, 'updateTagData', tags[1], tags[2])
			clientCall(player, 'updateRoundData', c_round, rounds, f_round)
		end

        for i, team in ipairs(getElementsByType('team')) do
            setElementData(team, 'Score', 0)
        end
	else
		outputInfoForPlayer(player, 'You are not admin')
	end
end

function funRound(player)
	if isAdmin(player) then
		f_round = true
		for i,player in ipairs(getElementsByType('player')) do
			clientCall(player, 'updateRoundData', c_round, rounds, f_round)
		end
		outputInfo('Free round')
	else
		outputInfoForPlayer(player, 'You are not admin')
	end
end

function realRound(player)
    if isAdmin(player) then
        f_round = false
        for i,player in ipairs(getElementsByType('player')) do
            clientCall(player, 'updateRoundData', c_round, rounds, f_round)
        end
        outputInfo('Active round')
    else
        outputInfoForPlayer(player, 'You are not admin')
    end
end

--------- { COMMANDS } ----------
addCommandHandler('newtr', preStart)
addCommandHandler('endtr', destroyTeams)
addCommandHandler('fun', funRound)
addCommandHandler('endfun', realRound)
