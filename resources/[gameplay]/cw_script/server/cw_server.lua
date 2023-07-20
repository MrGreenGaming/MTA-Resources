--init
local teams = {}
local mode = "CW" -- CW or FFA
local tags = {}
local playerData = {}
local rounds = 10
local c_round = 0
local f_round = false
local round_started = false
local round_ended = true
local isWarEnded  = false

CurrentGamemode = "Sprint"

addEventHandler("onResourceStart", resourceRoot,
    function()
        if getResourceFromName("gcshop") and getResourceState(getResourceFromName("gcshop")) == "running" then
            cancelEvent(true, "Can't start CW while GcShop is running. Stop the GcShop resource (Greencoin Shop)")
            outputChatBox("Can't start CW while GcShop is running. Stop the GcShop resource using '/stop gcshop'", root, 255, 0, 0)
        end

        if getResourceFromName("mrgreen-vip") and getResourceState(getResourceFromName("mrgreen-vip")) == "running" then
            cancelEvent(true, "Can't start CW while VIP is running. Stop the VIP resource (Mrgreen VIP)")
            outputChatBox("Can't start CW while VIP is running. Stop the VIP resource using '/stop mrgreen-vip'", root, 255, 0, 0)
        end
    end
)

-----------------
-- Call functions
-----------------
function serverCall(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do arg[key] = tonumber(value) or value end
    end
    loadstring("return "..funcname)()(unpack(arg))
end

addEvent("onClientCallsServerFunction", true)
addEventHandler("onClientCallsServerFunction", resourceRoot , serverCall)

function clientCall(client, funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    triggerClientEvent(client, "onServerCallsClientFunction", resourceRoot, funcname, unpack(arg or {}))
end

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
            if mode == "FFA" then
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
            if mode == "CW" then
                clientCall(player, 'createGUI', getTeamName(teams[1]), getTeamName(teams[2]))
            end
		end
	else
		outputChatBox('[CW] #ffffffYou are not admin', player, 155, 155, 255, true)
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
	else
		outputChatBox('[CW] #ffffffYou are not admin', player, 155, 155, 255, true)
	end
end

function funRound(player)
	if isAdmin(player) then
		f_round = true
		for i,player in ipairs(getElementsByType('player')) do
			clientCall(player, 'updateRoundData', c_round, rounds, f_round)
		end
		outputInfo('#ffffffFree round')
	else
		outputChatBox('[CW] #ffffffYou are not admin', player, 155, 155, 255, true)
	end
end

--------- { COMMANDS } ----------
addCommandHandler('newtr', preStart)
addCommandHandler('endtr', destroyTeams)
addCommandHandler('fun', funRound)

function outputInfo(info)
	for i, player in ipairs(getElementsByType('player')) do
		outputChatBox('[CW] #ffffff' ..info, player, 155, 155, 255, true)
	end
end

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
	if isWarEnded then
		destroyTeams(false)
		isWarEnded = false
	end
end

function playerFinished(player, rank)
	if isElement(teams[1]) and isElement(teams[2]) and isElement(teams[3]) then
		if getPlayerTeam(player) ~= teams[3] and not f_round and c_round > 0 then
			local p_score = 0
			if rank == 1 then
				p_score = 15
			elseif rank == 2 then
				p_score = 13
			elseif rank == 3 then
				p_score = 11
			elseif rank == 4 then
				p_score = 9
			elseif rank == 5 then
				p_score = 7
			elseif rank == 6 then
				p_score = 5
			elseif rank == 7 then
				p_score = 4
			elseif rank == 8 then
				p_score = 3
			elseif rank == 9 then
				p_score = 2
			elseif rank == 10 then
				p_score = 1
			end
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

			if getPlayerTeam(player) == teams[1] then
				exports.messages:outputGameMessage(t1c .. getPlayerName(player).. ' #ffffffgot #9b9bff' ..p_score.. ' #ffffffpoints #9b9bff('.. new_p_score .. ')', root, 2.5, 0,255,0, false, false,  true)
			elseif getPlayerTeam(player) == teams[2] then
				exports.messages:outputGameMessage(t2c .. getPlayerName(player).. ' #ffffffgot #9b9bff' ..p_score.. ' #ffffffpoints #9b9bff('.. new_p_score .. ')', root, 2.5, 0,255,0, false, false,  true)
			end
		end
	end
end

function getPlayerScore(player)
	local c_score = 0
	if getPlayerTeam(player) ~= teams[3] then
		c_score = getElementData(player, 'Score')
	end
end

function endRound()
	if isElement(teams[1]) and isElement(teams[2]) and not f_round then
		if c_round > 0 then
			if not round_ended then
				round_ended = true
				outputInfo('#ffffffRound has been ended')
			end
		end
		if c_round == rounds then
            if mode == "CW" then
                endClanWar()
            else
                endFreeForAll()
            end
		end
	end
end

function rgb2hex(r,g,b)
	return string.format("#%02X%02X%02X", r,g,b)
end

function endFreeForAll()
    isWarEnded = true

    local t1 = getTeamName(teams[1])
    local t1t = getTeamFromName(t1)
    local t1Players = getPlayersInTeam(t1t)

    if t1Players[1] then
        local score = getElementData(t1Players[1], 'Score')
        local playerName = getPlayerName(t1Players[1])
        outputChatBox("#FFD700In 1st place with " .. score .. " points: " .. playerName, root, 255, 255, 255, true)
    end

    if t1Players[2] then
        local score = getElementData(t1Players[2], 'Score')
        local playerName = getPlayerName(t1Players[2])
        outputChatBox("#C0C0C0In 2nd place with " .. score .. " points: " .. playerName, root, 255, 255, 255, true)
    end

    if t1Players[3] then
        local score = getElementData(t1Players[3], 'Score')
        local playerName = getPlayerName(t1Players[3])
        outputChatBox("#CD7F32In 3rd place with " .. score .. " points: " .. playerName, root, 255, 255, 255, true)
    end

    for i, player in ipairs(t1Players) do
        local score = getElementData(player, 'Score')
        outputChatBox("You finished in " .. i .. getPrefix(i) .. " place with " .. score .. " points.", player, 255, 255, 255, true)
    end

end

function endClanWar()
	isWarEnded  = true

    local t1tag = tags[1]
    local t2tag = tags[2]
    local t1 = getTeamName(teams[1])
    local t2 = getTeamName(teams[2])
    local t1t = getTeamFromName(t1)
    local t2t = getTeamFromName(t2)
    local t1Players = getPlayersInTeam(t1t)
    local t2Players = getPlayersInTeam(t2t)
    local t1mvp = t1Players[1]
    local t2mvp = t2Players[1]
    local t1mvpName = getPlayerName(t1mvp)
    local t2mvpName = getPlayerName(t2mvp) or ''
    local t1r, t1g, t1b = getTeamColor(teams[1])
    local t1c = rgb2hex(t1r, t1g, t1b)
    local t2r, t2g, t2b = getTeamColor(teams[2])
    local t2c = rgb2hex(t2r, t2g, t2b)
    local pts1 = getElementData(t1mvp, 'Score')
    local pts2 = getElementData(t2mvp, 'Score') or 0
    local t1score = tonumber(getElementData(teams[1], 'Score'))
    local t2score = tonumber(getElementData(teams[2], 'Score'))

    if #t1Players == 0 and #t2Players >= 1 then
        outputInfo(t1c .. t1tag .. ' #ffffffMVP: ' .. t1c .. '-')
        outputInfo(t2c .. t2tag .. ' #ffffffMVP: ' .. t2c .. t2mvpName .. ' #9b9bff(' .. pts2 .. ')')
    elseif #t1Players >= 1 and #t2Players == 0 then
        outputInfo(t1c .. t1tag .. ' #ffffffMVP: ' .. t1c .. t1mvpName .. ' #9b9bff(' .. pts1 .. ')')
        outputInfo(t2c .. t2tag .. ' #ffffffMVP: ' .. t2c .. '-')
    elseif #t1Players >= 1 and #t2Players >= 1 then
        outputInfo(t1c .. t1tag .. ' #ffffffMVP: ' .. t1c .. t1mvpName .. ' #9b9bff(' .. pts1 .. ')')
        outputInfo(t2c .. t2tag .. ' #ffffffMVP: ' .. t2c .. t2mvpName .. ' #9b9bff(' .. pts2 .. ')')
    else
        outputInfo(t1c .. t1tag .. ' #ffffffMVP: ' .. t1c .. '-')
        outputInfo(t2c .. t2tag .. ' #ffffffMVP: ' .. t2c .. '-')
    end

	if t1score > t2score then
		outputInfo(t1c .. getTeamName(teams[1]).. ' #ffffffwon against ' .. t2c ..getTeamName(teams[2]).. ' #ffffff ' ..t1score.. ' : ' ..t2score)
	elseif t1score < t2score then
		outputInfo(t2c .. getTeamName(teams[2]).. ' #ffffffwon against ' .. t1c ..getTeamName(teams[1]).. ' #ffffff ' ..t2score.. ' : ' ..t1score)
	elseif t1score == t2score then
		outputInfo(t1c .. getTeamName(teams[1]).. ' #ffffffand '.. t2c ..getTeamName(teams[2]).. ' #fffffftied ' ..t1score.. ' : ' ..t2score)
	end
end

function isAdmin(thePlayer)
	if not thePlayer then return true end
	if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(thePlayer)), aclGetGroup("Admin")) then
		return true
	else
		return false
	end
end

function isClientAdmin(client)
	local accName = getAccountName(getPlayerAccount(client))
	if isObjectInACLGroup("user."..accName, aclGetGroup("Admin")) then
		clientCall(client, 'updateAdminInfo', true)
	else
		clientCall(client, 'updateAdminInfo', false)
	end
end

function playerJoin(source)
    if isElement(teams[1]) then
        clientCall(source, 'updateTeamData', teams[1], teams[2], teams[3])
        clientCall(source, 'updateRoundData', c_round, rounds, f_round)
        clientCall(source, 'updateModeData', mode)
        if (mode == "FFA") then
            setPlayerTeam(source, teams[1])
        else
            setPlayerTeam(source, teams[3])
        end
    end
    local serial = getPlayerSerial(source)
    if playerData[serial] ~= nil then
            setElementData(source, 'Score', playerData[serial]["score"])
            --setElementData(source, 'Pts per map', playerData[serial]["ppm"])
            --setElementData(source, 'Maps played', playerData[serial]["mp"])
        else
            setElementData(source, 'Score', 0)
            --setElementData(source, 'Pts per map', 0)
            --setElementData(source, 'Maps played', 0)
    end
end

function playerLogin(p_a, c_a)
	local accName = getAccountName(c_a)
	if isObjectInACLGroup("user."..accName, aclGetGroup("Admin")) then
		clientCall(source, 'updateAdminInfo', true)
	else
		clientCall(source, 'updateAdminInfo', false)
	end
end

-------------------
-- FROM ADMIN PANEL
-------------------
function startWar(team1name, team2name, t1tag, t2tag, r1, g1, b1, r2, g2, b2, m)
	destroyTeams()
    tags[1] = t1tag
    tags[2] = t2tag
	teams[1] = m == "CW" and createTeam(team1name, r1, g1, b1) or createTeam("Free-for-All", 52, 110, 68)
	teams[2] = m == "CW" and createTeam(team2name, r2, g2, b2) or createTeam("-", 0, 0, 0)
	teams[3] = m == "CW" and createTeam("Spectators", 255, 255, 255) or createTeam("--", 0, 0, 0)
    mode = m

	for i,player in ipairs(getElementsByType('player')) do
        if mode == "FFA" then
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
	call(getResourceFromName("scoreboard"), "scoreboardAddColumn", "Score")
	for i, player in ipairs(getElementsByType('player')) do
		clientCall(player, 'updateTeamData', teams[1], teams[2], teams[3])
		clientCall(player, 'updateTagData', tags[1], tags[2])
		clientCall(player, 'updateRoundData', c_round, rounds, f_round)
        clientCall(player, 'updateModeData', mode)
        if mode == "CW" then
            clientCall(player, 'createGUI', getTeamName(teams[1]), getTeamName(teams[2]))
        end
	end
end

function updateRounds(cur_round, ma_round)
	c_round = cur_round
	rounds = ma_round
	for i, player in ipairs(getElementsByType('player')) do
		clientCall(player, 'updateRoundData', c_round, rounds, f_round)
	end
end

function sincAP()
	for i,player in ipairs(getElementsByType('player')) do
		clientCall(player, 'updateAdminPanelText')
	end
end

--------------------
-- CAR & BLIP COLORS
--------------------
function setColors()
	local s_team = getPlayerTeam(source)
	local p_veh = getPedOccupiedVehicle(source)
	if s_team then
		local r, g, b = getTeamColor(s_team)
		setVehicleColor(p_veh, r, g, b, 255, 255, 255)
	end
end

function getBlipAttachedTo(thePlayer)
	local blips = getElementsByType("blip")
	for k, theBlip in ipairs(blips) do
		if getElementAttachedTo(theBlip) == thePlayer then
			return theBlip
		end
   end
   return false
end

------------
-- EVENTS
------------
addEvent('onMapStarting', true)
addEventHandler('onMapStarting', getRootElement(), startRound)

addEvent('onPostFinish', true)
addEventHandler('onPostFinish', getRootElement(), endRound)

addEventHandler('onPlayerLogin', getRootElement(), playerLogin)

addEventHandler('onPlayerVehicleEnter', getRootElement(), setColors)

addEvent('onPlayerReachCheckpoint', true)
addEventHandler('onPlayerReachCheckpoint', getRootElement(), setColors)
--addEventHandler('onPlayerReachCheckpoint', getRootElement(), getRank)

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging",getRootElement(),
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
						triggerClientEvent(thePlayer, 'onSpectateRequest', getRootElement())
					end
				end
			end
		end
	end
)

--------------------
-- ADDITIONAL EVENTS
--------------------
addEventHandler("onPlayerQuit", getRootElement(),
    function()
        if isElement(teams[1]) and isElement(teams[2]) and isElement(teams[3]) then
            if getElementData(source, 'Score') > 0 and isWarEnded == false then
                local serial = getPlayerSerial(source)
                playerData[serial] = {}
                playerData[serial]["score"] = getElementData(source, 'Score')
                -- playerData[serial]["ppm"] = getElementData(source, 'Pts per map')
                -- playerData[serial]["mp"] = getElementData(source, 'Maps played')
            end
        end
    end
)
