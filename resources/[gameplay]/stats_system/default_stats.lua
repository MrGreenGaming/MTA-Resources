--Handle connection on/off
addEventHandler('onResourceStart', resourceRoot,
function()
    database = dbConnect( "sqlite", ":/stats_mix.db" )
    if database then
        dbExec(database, "CREATE TABLE IF NOT EXISTS stats_mix (playerName TEXT, nts_wins INTEGER, rtf_flags INTEGER, dd_kills INTEGER, dd_deaths INTEGER, dd_wins INTEGER, ctf_taken INTEGER, ctf_delivered INTEGER, mh_victim_become INTEGER, mh_victim_deaths INTEGER, sprint_wins INTEGER, shooter_kills INTEGER, shooter_deaths INTEGER, shooter_wins INTEGER, dummy INTEGER)")
        for _, player in ipairs(getElementsByType('player')) do
            if not isPlayerInDatabase(player) then
                addPlayerInDatabase(player)
            end
        end
    end
end)

addEventHandler('onResourceStop', resourceRoot, function() destroyElement(database) end)
---------------------------


--Handle creation of default stats for each player
function isPlayerInDatabase(player)
    local query = dbQuery( database, "SELECT * FROM stats_mix WHERE playerName = ?", getPlayerName(player) )
    local result = dbPoll( query, -1 )
    if #result > 0 then
        return true
    end
    return false
end

function addPlayerInDatabase(player)
    dbExec( database, "INSERT INTO stats_mix  VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", getPlayerName(player), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
end

addEventHandler('onPlayerJoin', root,
function()
    if not isPlayerInDatabase(source) then
        addPlayerInDatabase(source)
    end
end)

addEventHandler('onPlayerChangeNick', root,
function(oldNick, newNick)
    setTimer(function(player, nick)
             if player and isElement(player) and getPlayerName(player) == nick then
                   if not isPlayerInDatabase(player) then
                        addPlayerInDatabase(player)
                   end
             end
             end, 500, 1, source, newNick)
end)
---------------------------------------------------------


--Handle outputting information
function findPlayerByName(playerPart)
	local pl = getPlayerFromName(playerPart)
	if isElement(pl) then
		return pl
	else
		for i,v in ipairs (getElementsByType ("player")) do
			if (string.find(string.gsub ( string.lower(getPlayerName(v)), '#%x%x%x%x%x%x', '' ),string.lower(playerPart))) then
				return v
			end
		end
    end
 end

function showStats(player, findName)
    local elem = findPlayerByName(findName)
    if elem then findName = getPlayerName(elem) end
    local query = dbQuery( database, "SELECT * FROM stats_mix WHERE playerName = ?", findName )
    local result = dbPoll( query, -1 )
    if not result then
        outputChatBox("Problem with Server script. Please contact an admin.", player, 0, 255, 0)
    elseif #result == 0 then
            outputChatBox("This player is inexistent in the Stats Database.", player, 0, 255, 0)
    else
        outputChatBox("[Stats_MIX] Information retrieved for user "..result[1].playerName..":", player, 0, 255, 0)
			outputChatBox("[Stats_MIX] NTS Wins: "..tostring(result[1].nts_wins or 0).." Race Wins: "..tostring(result[1].sprint_wins or 0), player, 0, 255, 0)
			outputChatBox("[Stats_MIX] Shooter Total kills: "..tostring(result[1].shooter_kills or 0).. " shooter Deaths: "..tostring(result[1].shooter_deaths or 0).." shooter Wins: "..tostring(result[1].shooter_wins or 0), player, 0, 255, 0)
			outputChatBox("[Stats_MIX] DD Total kills: "..tostring(result[1].dd_kills or 0).. " DD Deaths: "..tostring(result[1].dd_deaths or 0).." DD Wins: "..tostring(result[1].dd_wins or 0), player, 0, 255, 0)
			outputChatBox("[Stats_MIX] CTF Flags Delivered: "..tostring(result[1].ctf_delivered or 0).." RTF Reached Flags: "..tostring(result[1].rtf_flags or 0), player, 0, 255, 0)
        -- outputChatBox("[Stats_MIX] Became victim/Deaths as victim: "..tostring(result[1].mh_victim_become).."/"..tostring(result[1].mh_victim_deaths), player, 0, 255, 0)
    end
end

addCommandHandler('stats', function(player, command, argument)
    if not argument then
        showStats(player, getPlayerName(player))  --arg1 show who, arg2 show whose stats
    else
        showStats(player, argument)
    end
end)
-------------------------------

addEvent("sb_showMyStats",true)
addEventHandler("sb_showMyStats",root,function() showStats(client,getPlayerName(client)) end)


