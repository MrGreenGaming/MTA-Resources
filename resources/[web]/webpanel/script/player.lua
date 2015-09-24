local IP = true

function formatPlayer(value, num)
	local output_string = ""
	if isElement(value) then
		local name = getPlayerName(value) or ""
		local serial = getPlayerSerial(value) or ""
		local account = getAccountName(getPlayerAccount(value)) or ""
		local team_name = ""
		local playerip = "N/A"
		
		
		if IP then
			playerip = getPlayerIP(value) 
		end
		
		output_string = 
			"<tr class=\"player_row\">"..
			"<td>"..name.."</td>"..
			"<td>"..account.."</td>"..
			"<td>"..playerip.."</td>"..
			"<td>"..serial.."</td>"..
			"<td><input type=\"radio\" id=\"player_"..num.."_kick\" name=\"player_"..num.."\" value=\"".. name .."\"/></td>"..
			"<td><input type=\"radio\" id=\"player_"..num.."_ban\" name=\"player_"..num.."\" value=\"".. name .."\"/></td>"..
			"<td><input type=\"radio\" id=\"player_"..num.."_nothing\" name=\"player_"..num.."\" checked value=\"".. name .."\" /></td>"..
			"</tr>"
	end
	
	return output_string
end

function formatTeam(value) 
	local output_string = ""
	if isElement(value) then
		local r,g,b = getTeamColor(value)

		output_string = 
			"<tr class=\"team_row\">"..
			"<td colspan=\"7\"><span style='color: rgb(".. r ..", ".. g ..", ".. b ..");'>"..getTeamName(value).."</span>:</td>"..
			"</tr>"
	end

	return output_string
end

function getAllPlayers()
	local output_string = "<tr class=\"team_row\"><td colspan=\"7\">Unassigned:</td></tr>"
	local players_num = 0
	
	for _, value in pairs(getElementsByType("player")) do
		if isElement(value) then
			local team = getPlayerTeam(value)
			
			if not isElement(team) then
				output_string = output_string .. formatPlayer(value, players_num)
				players_num = players_num + 1
			end
		end
	end

	for _, value in pairs(getElementsByType("team")) do
		if isElement(value) then
			output_string = output_string .. formatTeam(value)
			local players = getPlayersInTeam(value)
			
			if #players > 0 then
				for _, player  in pairs(players) do
					output_string = output_string .. formatPlayer(player, players_num)
					players_num = players_num + 1
				end
			end
		end
	end

	return output_string
end

function banPlr(nick, reason, banner)
	if(nick)then
		local plr = getPlayerFromName(nick)
		if isElement(plr) then
			local serial = getPlayerSerial(plr)

			if addBan ( nil, nil, serial, getElementByIndex("console", 0), string.format("%s (nick: %s) %s", reason or "", getPlayerName(plr), "(by "..banner..")" or "") ) then
				outputServerLog("BAN: Webban account ("..banner..") serial: "..serial)
				return true
			end
		end
	end
	return false
end

function kickPlr(nick, reason, kicker)
	if(nick)then
		local plr = getPlayerFromName(nick)
		if(plr)then
			if(kickPlayer(plr, reason)) then
				outputServerLog("KICK: Webkick account ("..kicker..")")
				return true
			end
		end
	end
	return false
end