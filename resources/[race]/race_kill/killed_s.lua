victimKillerTable = {
	-- victim = killer,
}

local hitby = {}

addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', getRootElement(),
	function(state)
		triggerClientEvent('killedDDMapRunning', resourceRoot, exports.race:getRaceMode() == "Destruction derby" and state == "Running")
		
		if state == "Running" then
			victimKillerTable = {}
			hitby = {}
			g_PlayersKills = {}
			if exports.race:getRaceMode() == "Destruction derby" then
				for _, pl in ipairs(getElementsByType('player')) do
					setElementData(pl, 'kills', 0)
					g_PlayersKills[pl] = 0
				end
				exports.scoreboard:addScoreboardColumn('kills')

			-- elseif exports.race:getRaceMode() == "CarGame" then
			-- 	for _, pl in ipairs(getElementsByType('player')) do
			-- 		setElementData(pl, 'kills', 0)
			-- 		g_PlayersKills[pl] = 0
			-- 	end
			-- 	exports.scoreboard:addScoreboardColumn('kills')
			-- 	triggerClientEvent('startShooterKillDetection', resourceRoot)
			

			elseif exports.race:getRaceMode() == "Shooter" then
				for _, pl in ipairs(getElementsByType('player')) do
					setElementData(pl, 'kills', 0)
					g_PlayersKills[pl] = 0
				end
				exports.scoreboard:addScoreboardColumn('kills')
				triggerClientEvent('startShooterKillDetection', resourceRoot)
			

			elseif exports.race:getRaceMode() == "Capture the flag" then
				triggerClientEvent('killedCTFMapRunning', resourceRoot, true)
				for _, pl in ipairs(getElementsByType('player')) do
					setElementData(pl, 'defends', 0)
					g_PlayersKills[pl] = 0
				end
				-- exports.scoreboard:addScoreboardColumn('defends')
			end

		elseif state == "LoadingMap" then
			exports.scoreboard:removeScoreboardColumn('kills')
			for _, pl in ipairs(getElementsByType('player')) do
				setElementData(pl, 'kills', nil)
			end
			ctfWipe()
        end    
	end
)
addEventHandler("onPlayerJoin",root,
	function()
		if exports.race:getRaceMode() == "Shooter" then
			setElementData(source, 'kills', 0)
			g_PlayersKills[source] = 0
			triggerClientEvent(source,'startShooterKillDetection', source)
		end
	end)


function onRaceAddRank(time)
	if not g_PlayersKills or (exports.race:getRaceMode() ~= "Destruction derby" and exports.race:getRaceMode() ~= "Shooter") then return end
	local player = source
	
	cancelEvent(true, 'Kills: ' .. g_PlayersKills[player])
	
end
addEventHandler('onRaceAddRank', root, onRaceAddRank)

-- function displayVehicleLoss(loss)
    -- local thePlayer = getVehicleOccupant(source)
    -- if(thePlayer) then -- Check there is a player in the vehicle
		-- local damage = loss
		-- local h = getElementHealth(source)
		-- local h2 = h - damage
      -- outputDebugString("damage " .. h .. "-" .. damage .. "=" .. h2) -- Display the message
    -- end
-- end
-- addEventHandler("onVehicleDamage", getRootElement(), displayVehicleLoss)

function killedlasthit(hit_by_vehicle)
	-- outputDebugString(string.gsub (getPlayerName(client), '#%x%x%x%x%x%x', '' ) .. ' lasthit ' .. tostring(hit_by_vehicle))
	if not (isElement(hit_by_vehicle) and getElementType(hit_by_vehicle) == 'vehicle' and getVehicleOccupant(hit_by_vehicle)) then return end
	-- outputDebugString(string.gsub (getPlayerName(client), '#%x%x%x%x%x%x', '' ) .. ' lasthit ' .. tostring(hit_by_vehicle))
	local hit_by_player = getVehicleOccupant(hit_by_vehicle)
	local hitPlayer = client
	hitby[hitPlayer] = {string.gsub (getPlayerName(hit_by_player), '#%x%x%x%x%x%x', '' ), getTickCount(), hit_by_player}

	victimKillerTable[hitPlayer] = hit_by_player
end
addEvent('killedlasthit', true)
addEventHandler('killedlasthit', resourceRoot, killedlasthit)


function wasted()
	if exports.race:getRaceMode() == "Destruction derby" then
		if hitby[source] and isElement(hitby[source][3]) and getElementHealth(hitby[source][3]) > 0.1 and (getTickCount() - hitby[source][2]) < 10000 then

			exports.messages:outputGameMessage(string.gsub (getPlayerName(source), '#%x%x%x%x%x%x', '' ) .. " was killed by " .. hitby[source][1], root, 2.5, 255, 255, 255)

			g_PlayersKills[hitby[source][3]] = g_PlayersKills[hitby[source][3]] + 1
			setElementData(hitby[source][3], 'kills', g_PlayersKills[hitby[source][3]])

			
			triggerEvent('onDDPlayerKill', hitby[source][3], source)
		end
	elseif exports.race:getRaceMode() == "Capture the flag" then 
		if hitby[source] and isElement(hitby[source][3]) and getElementHealth(hitby[source][3]) > 0.1 and (getTickCount() - hitby[source][2]) < 10000 then
			
			local killedTeamName = getPlayerTeam(source)
			local killedTeamName = getTeamName(killedTeamName)
			local killedTeamName = string.explode(killedTeamName," ")
			local killedTeamName = string.lower(killedTeamName[1]) -- Get's team color name instead of the whole name

			-- outputChatBox("Player is in team "..killedTeamName.." and is in colshape b:"..tostring(playersInDefendArea.blue[source]).." r:"..tostring(playersInDefendArea.red[source]))
			if playersInDefendArea[killedTeamName]["flagCarrier"] ~= source then -- If killed is not flag carrier
				if killedTeamName == "red" then

					if playersInDefendArea.blue[source] then
						local hitByPlayer = hitby[source][3]
						-- exports.messages:outputGameMessage(string.gsub (getPlayerName(source), '#%x%x%x%x%x%x', '' ) .. " was killed by " .. hitby[source][1], root, 2.5, 0, 255, 0)
						g_PlayersKills[hitByPlayer] = g_PlayersKills[hitByPlayer] + 1
						setElementData(hitByPlayer, 'defends', g_PlayersKills[hitByPlayer])

						addKillCount(hitByPlayer,source)
						
					end
				elseif killedTeamName == "blue" then
					if playersInDefendArea.red[source] then
						local hitByPlayer = hitby[source][3]
						-- exports.messages:outputGameMessage(string.gsub (getPlayerName(source), '#%x%x%x%x%x%x', '' ) .. " was killed by " .. hitby[source][1], root, 2.5, 255, 0, 0)
						g_PlayersKills[hitByPlayer] = g_PlayersKills[hitByPlayer] + 1
						setElementData(hitByPlayer, 'defends', g_PlayersKills[hitByPlayer])

						addKillCount(hitByPlayer,source)
						-- triggerEvent('onCTFPlayerKill', hitByPlayer, source, ctfPlayerKillsAmt[source][hitByPlayer])

					end
				end
			elseif playersInDefendArea[killedTeamName]["flagCarrier"] == source then
				local hitByPlayer = hitby[source][3]
				g_PlayersKills[hitByPlayer] = g_PlayersKills[hitByPlayer] + 1
				setElementData(hitByPlayer, 'defends', g_PlayersKills[hitByPlayer])
				triggerEvent('onCTFFlagCarrierKill', hitByPlayer, source)
			end

			
			
		end
	end
end
addEventHandler('onPlayerWasted', root, wasted)

-- CTF DefendColshape Hit and Leave
redDefColShape = nil
blueDefColShape = nil

playersInDefendArea = {}
playersInDefendArea.red = {}
playersInDefendArea.blue = {}
playersInDefendArea.red.flagCarrier = {}
playersInDefendArea.blue.flagCarrier = {}

ctfPlayerKillsAmt = {}

function receiveDefColshapes(col,name)
	if name == "Red team" then
		redDefColShape = col
		-- outputChatBox("Received RED")
		removeEventHandler("onColShapeHit",redDefColShape,DefColshapeHit)
		removeEventHandler("onColShapeLeave",redDefColShape,DefColshapeLeave)

		addEventHandler("onColShapeHit", redDefColShape, DefColshapeHit)
		addEventHandler("onColShapeLeave", redDefColShape, DefColshapeLeave)
	elseif name == "Blue team" then
		blueDefColShape = col
		-- outputChatBox("Received BLUE")
		removeEventHandler("onColShapeHit",blueDefColShape,DefColshapeHit)
		removeEventHandler("onColShapeLeave",blueDefColShape,DefColshapeLeave)

		addEventHandler("onColShapeHit", blueDefColShape, DefColshapeHit)
		addEventHandler("onColShapeLeave", blueDefColShape, DefColshapeLeave)
	end

end
addEvent("sendCTFDefendColshape",true)
addEventHandler("sendCTFDefendColshape",root,receiveDefColshapes)

function addKillCount(p,killed)
	if not ctfPlayerKillsAmt[p] then
		ctfPlayerKillsAmt[p] = {}
	end
	if not ctfPlayerKillsAmt[p][killed] then
		ctfPlayerKillsAmt[p][killed] = 0
	end
	ctfPlayerKillsAmt[p][killed] = ctfPlayerKillsAmt[p][killed] + 1

	
	triggerEvent('onCTFPlayerKill', p, killed, ctfPlayerKillsAmt[p][killed])
	
end

function DefColshapeHit(theElement)
	if not isElement then return end
	if getElementType(theElement) ~= "player" then return end

	
	if source == redDefColShape then
		-- outputChatBox(getPlayerName(theElement).." entered RED")
		playersInDefendArea.red[theElement] = true
	elseif source == blueDefColShape then
		-- outputChatBox(getPlayerName(theElement).." entered BLUE")
		playersInDefendArea.blue[theElement] = true
	end

end

function DefColshapeLeave(theElement)
	if not isElement then return end
	if getElementType(theElement) ~= "player" then return end


	if source == redDefColShape then
		playersInDefendArea.red[theElement] = nil
		-- outputChatBox(getPlayerName(theElement).." left RED")
	elseif source == blueDefColShape then
		playersInDefendArea.blue[theElement] = nil
		-- outputChatBox(getPlayerName(theElement).." left BLUE")
	end

end

function setCTFCarrier(theCarrier,whattodo)
	if not getElementType(theCarrier) then return end
	if whattodo == "add" then
		local teamName = getPlayerTeam(theCarrier)
		local teamName = getTeamName(teamName)

		if teamName == "Red team" then
			playersInDefendArea.red.flagCarrier = theCarrier
		elseif teamName == "Blue team" then
			playersInDefendArea.blue.flagCarrier = theCarrier
		end
	elseif whattodo == "remove" then
		local teamName = getPlayerTeam(theCarrier)
		local teamName = getTeamName(teamName)

		if teamName == "Red team" then
			setTimer(function() playersInDefendArea.red.flagCarrier = false end,200,1) -- Timer for kill detection on flag carrier
			-- playersInDefendArea.red.flagCarrier = false
		elseif teamName == "Blue team" then
			setTimer(function() playersInDefendArea.blue.flagCarrier = false end,200,1) -- Timer for kill detection on flag carrier
			-- playersInDefendArea.blue.flagCarrier = false
		end
	end
end



function ctfWipe()
redDefColShape = nil
blueDefColShape = nil

playersInDefendArea = {}
playersInDefendArea.red = {}
playersInDefendArea.blue = {}
playersInDefendArea.red.flagCarrier = {}
playersInDefendArea.blue.flagCarrier = {}
ctfPlayerKillsAmt = {}
end

-- Events to add/remove flag carrier
addEvent("onCTFFlagTaken",true)
addEventHandler("onCTFFlagTaken",root,function() local p = source setCTFCarrier(p,"add") end)

addEvent("onCTFFlagDelivered",true)
addEventHandler("onCTFFlagDelivered",root,function() local p = source setCTFCarrier(p,"remove") end)

addEvent("onCTFFlagDropped",true)
addEventHandler("onCTFFlagDropped",root,function() local p = source setCTFCarrier(p,"remove")  end)
----------


-- sh
function shooterKill(killer)
	if exports.race:getRaceMode() == "Shooter" then
		if exports.race:getShooterMode() == "shooter" then
			local victim = source
			local a = string.gsub (getPlayerName(victim), '#%x%x%x%x%x%x', '' )
			local b = string.gsub (getPlayerName(killer), '#%x%x%x%x%x%x', '' )
			
			exports.messages:outputGameMessage(a .. " was killed by " .. b, root, 2.5, 255, 255, 255)
			g_PlayersKills[killer] = g_PlayersKills[killer] + 1
			setElementData(killer, 'kills', g_PlayersKills[killer])

			triggerEvent('onShooterPlayerKill', killer, victim)
			victimKillerTable[victim] = killer

		else

			
			-- local victim = source
			-- local a = string.gsub (getPlayerName(victim), '#%x%x%x%x%x%x', '' )
			-- local b = string.gsub (getPlayerName(killer), '#%x%x%x%x%x%x', '' )
			
			-- exports.messages:outputGameMessage("You got killed by " .. b, victim, 2.5, 255, 255, 255)
			-- exports.messages:outputGameMessage("You killed " .. a, killer, 2.5, 255, 255, 255)

			-- g_PlayersKills[killer] = g_PlayersKills[killer] + 1
			-- setElementData(killer, 'kills', g_PlayersKills[killer])

			-- triggerEvent('onCarGamePlayerKill', killer)
			-- triggerEvent('onCarGamePlayerDeath', victim)
			
			-- victimKillerTable[victim] = killer
		end
	end
end
addEvent('shooterKill', true)
addEventHandler('shooterKill', root, shooterKill)


function getKiller(deadplyr)
	if victimKillerTable[deadplyr] then
		return victimKillerTable[deadplyr]
	else
		return false
	end
end


-- util
function Check(funcname, ...)
    local arg = {...}
 
    if (type(funcname) ~= "string") then
        error("Argument type mismatch at 'Check' ('funcname'). Expected 'string', got '"..type(funcname).."'.", 2)
    end
    if (#arg % 3 > 0) then
        error("Argument number mismatch at 'Check'. Expected #arg % 3 to be 0, but it is "..(#arg % 3)..".", 2)
    end
 
    for i=1, #arg-2, 3 do
        if (type(arg[i]) ~= "string" and type(arg[i]) ~= "table") then
            error("Argument type mismatch at 'Check' (arg #"..i.."). Expected 'string' or 'table', got '"..type(arg[i]).."'.", 2)
        elseif (type(arg[i+2]) ~= "string") then
            error("Argument type mismatch at 'Check' (arg #"..(i+2).."). Expected 'string', got '"..type(arg[i+2]).."'.", 2)
        end
 
        if (type(arg[i]) == "table") then
            local aType = type(arg[i+1])
            for _, pType in next, arg[i] do
                if (aType == pType) then
                    aType = nil
                    break
                end
            end
            if (aType) then
                error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..table.concat(arg[i], "' or '").."', got '"..aType.."'.", 3)
            end
        elseif (type(arg[i+1]) ~= arg[i]) then
            error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..arg[i].."', got '"..type(arg[i+1]).."'.", 3)
        end
    end
end
function string.explode(self, separator)
    Check("string.explode", "string", self, "ensemble", "string", separator, "separator")
 
    if (#self == 0) then return {} end
    if (#separator == 0) then return { self } end
 
    return loadstring("return {\""..self:gsub(separator, "\",\"").."\"}")()
end