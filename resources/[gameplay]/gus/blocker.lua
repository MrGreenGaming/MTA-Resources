-- /blocker
local dbHandler = false
local blockers = {}		-- [player] = expireTimestamp
local _blockerCache = {}
local blockerDuration = 1000 * 60 * 60 * 1


function blocker(player, _, nick, duration, timeType)
	local blockPlayer = findPlayerByName(nick)
	if not blockPlayer then
		outputChatBox("No player found", player, 0, 255,0)
	else

		outputChatBox("Marking " .. getPlayerName(blockPlayer) .. "#FF0000 as Ghost for " .. (duration or "1") .. " " .. (timeType or "hours"), player, 255, 0, 0 , true)
		if not getElementData(blockPlayer,"markedblocker") then
			duration = tonumber(duration)
			if not duration then
				duration = 1
			elseif not timeType or timeType == "h" or timeType == "hour" or timeType == "hours" then
				duration = duration
			elseif timeType == "d" or timeType == "day" or timeType == "days" then
				duration = duration * 24
			elseif timeType == "w" or timeType == "week" or timeType == "weeks" then
				duration = duration * 24 * 7
			elseif timeType == "M" or timeType == "month" or timeType == "months" then
				duration = duration * 24 * 31
			elseif timeType == "y" or timeType == "year" or timeType == "years" then
				duration = duration * 24 * 365
			else
				return outputChatBox("Invalid timetype", player, 255, 0, 0, true)
			end


			-- Mods can mark someone as blocker for up to 24 hours
			if duration > 24 and not hasObjectPermissionTo ( player, "command.serialblocker", false ) then
				outputChatBox("As a moderator you can mark someone for up to 24 hours", player, 255, 0, 0, true)
				duration = 24
			end

			local t = {
				serial = getPlayerSerial(blockPlayer),
				name = getPlayerName(blockPlayer):gsub("#%x%x%x%x%x%x",""),
				expireTimestamp = getExpireTimestamp(duration),
				byAdmin = getPlayerName(player):gsub("#%x%x%x%x%x%x",""),
				canmodsoverride = tostring( not hasObjectPermissionTo ( player, "command.serialblocker", false ) )
			}

			local added = addBlockerToDB(t.serial,t.name,t.expireTimestamp,t.byAdmin,t.canmodsoverride)

			if added then
				setElementData(blockPlayer , 'markedblocker', t)

				outputChatBox(remcol(getPlayerName(player)).." has marked "..remcol(getPlayerName(blockPlayer)).. " as a Ghost.", root, 255, 0, 0)

                if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
                    exports.discord:send("admin.log", { log = getAccountName( getPlayerAccount(player)) .. " marked " .. remcol(getPlayerName(blockPlayer)) .. " as Ghost for " ..duration .. " hours"})
                end

				logBlockAction(player, blockPlayer,"marked",duration)
				if useIRC() then
					exports.irc:outputIRC("05** "..remcol(getPlayerName(player)).." has marked "..remcol(getPlayerName(blockPlayer)).. " as a Ghost.")
				end
			else
				outputChatBox("Something went wrong, please contact a developer. 'blocker() add'",player)
			end
		else
			if not hasObjectPermissionTo ( player, "function.banPlayer", false ) and getElementData(blockPlayer,"markedblocker").canmodsoverride == "false" then
				outputChatBox("Only admins can unmark /blocker's marked by admins",player)
				return false
			end
            if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
                exports.discord:send("admin.log", { log = getAccountName( getPlayerAccount(player)) .. " unmarked " .. remcol(getPlayerName(blockPlayer)) .. " as Ghost"})
            end
			outputChatBox(remcol(getPlayerName(player)).." has unmarked "..remcol(getPlayerName(blockPlayer)).. " as a Ghost.", root, 255, 0, 0)
			setElementData(blockPlayer , 'markedblocker', nil)

			removeBlockerFromDB(getPlayerSerial(blockPlayer))
			logBlockAction(player, blockPlayer,"unmarked")
            if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
                exports.discord:send("admin.log", { log = getAccountName( getPlayerAccount(player)) .. " unmarked " .. remcol(getPlayerName(blockPlayer)) .. " as Ghost"})
            end
			if useIRC() then
				exports.irc:outputIRC("05** "..remcol(getPlayerName(player)).." has unmarked "..remcol(getPlayerName(blockPlayer)).. " as a Ghost.")
			end
		end
	end
end
addCommandHandler('blocker', blocker, true, true)

function unblocker(player, _, nick)
	local blockPlayer = findPlayerByName(nick)
	if not blockPlayer then
		outputChatBox("No player found", player, 0, 255,0)
	else
		if not hasObjectPermissionTo ( player, "function.banPlayer", false ) and getElementData(blockPlayer,"markedblocker").canmodsoverride == "false" then
			outputChatBox("Only admins can unmark /blocker's marked by admins",player)
			return false
		end

		local serial = getPlayerSerial(blockPlayer)
		if getElementData(blockPlayer,"markedblocker") then
			outputChatBox(remcol(getPlayerName(player)).." has unmarked "..remcol(getPlayerName(blockPlayer)).. " as a Ghost.", root, 255, 0, 0)
            if getResourceFromName('discord') and getResourceState(getResourceFromName('discord')) == 'running' then
                exports.discord:send("admin.log", { log = getAccountName( getPlayerAccount(player)) .. " has unmarked " .. remcol(getPlayerName(blockPlayer)) .. " as Ghost"})
            end

			setElementData(blockPlayer , 'markedblocker', nil)
			removeBlockerFromDB(serial)
			logBlockAction(player, blockPlayer,"unmarked")
			if useIRC() then
				exports.irc:outputIRC("05** "..remcol(getPlayerName(player)).." has unmarked "..remcol(getPlayerName(blockPlayer)).. " as a Ghost.")
			end

		end

	end

end
addCommandHandler('unblocker', unblocker, true, true)

function serialblocker(player, _, serial, duration)
	if not serial or #serial ~= 32 then
		outputChatBox("Not a valid serial", player, 0, 255,0)
	else
		if getPlayerFromSerial(serial) then
			blocker(player, nil, getPlayerName(getPlayerFromSerial(serial)), duration)
		else
			local expireTimestamp = getExpireTimestamp(duration)
			if expireTimestamp then
				addBlockerToDB(serial,"",expireTimestamp,getPlayerName(player):gsub("#%x%x%x%x%x%x",""),tostring( not hasObjectPermissionTo ( player, "command.serialblocker", false ) ) )
				logBlockAction(player, serial, "marked", duration)
				outputChatBox("Marked "..serial.. " as a Ghost for " .. math.round(((tonumber(duration) or 24) * 1000 * 60 * 60 * 1) / (60*60*1000), 1, ceil) .. 'hr', player, 255, 0, 0)
			else
				outputChatBox("Something went wrong, contact a developer please. 'serialblocker()' ",player)
			end
		end
	end
end
addCommandHandler('serialblocker', serialblocker, true, true)

function unserialblocker(player, _, serial)
	if not serial or #serial ~= 32 then
		outputChatBox("Not a valid serial", player, 0, 255,0)
	else
		removeBlockerFromDB(serial)
		logBlockAction(player, serial,"unmarked")
		outputChatBox("Unmarked "..serial.. " as a Ghost", player, 255, 0, 0)
	end
end
addCommandHandler('unserialblocker', unserialblocker, true, true)

function dispBlockers(source)
	local t = {}
	for _, player in pairs(getElementsByType'player') do
		if getElementData(player, 'markedblocker') then
			local serial = getPlayerSerial(player)
			local byAdmin = getElementData(player, 'markedblocker').byAdmin
			local expireTimestamp = getElementData(player, 'markedblocker').expireTimestamp
			local secondsLeft = expireTimestamp - getRealTime().timestamp



			local duration = secondsToTimeDesc(secondsLeft)



			t[#t+1] = remcol(getPlayerName(player)) .. ' (' .. duration .. ' by: '..byAdmin..')'

			outputConsole("Ghost: "..getPlayerName(player).." ("..duration..") by: "..byAdmin)

		end
	end
	if #t < 1 then
		outputChatBox('No Ghosts online at the moment!', source, 255, 0, 0)
	else
		local chatboxLines = splitStringforChatBox('Ghosts online: ' .. table.concat(t, ', '))
		for _,line in ipairs(chatboxLines) do
			outputChatBox(line,source,255,0,0)
		end

	end

end
addCommandHandler('blockers', dispBlockers, true, true)


function checkBlockerJoin(thePlayer)
	local player = false
	if getElementType(source) == "player" then
		player = source
	else
		player = thePlayer
	end

	local serial = getPlayerSerial(player)

	if isElement(dbHandler) then
		dbQuery(
			function(query)
				local sql = dbPoll(query,0)

				if sql and #sql > 0 then
					local currentTime = getRealTime().timestamp
					local expire = sql[1].expireTimestamp - currentTime
					if expire > 1 then
						local expireReadable = secondsToTimeDesc(expire)

						local t = sql[1]
						setElementData(player,"markedblocker",t)



						outputChatBox("You have been marked as a Ghost by "..t.byAdmin..", you will be unmarked in "..expireReadable,player,255,0,0)
					else
						removeBlockerFromDB(getPlayerSerial(player))
					end
				end
			end,
		dbHandler, "SELECT * FROM blockers WHERE serial = ?", serial)
	end
end
addEventHandler('onPlayerJoin', root, checkBlockerJoin)



function removeBlockerFromDB(s)
	if not s then return false end
		local q = dbExec(dbHandler,"DELETE FROM `blockers` WHERE `serial`=?",s)
	return q
end

function addBlockerToDB(ser,pName,expTimestamp,admName,canmodsoverride)
	if not dbHandler then outputDebugString("no handler?") end

	if ser and #ser == 32 and pName and expTimestamp and admName then
		local q = dbExec(dbHandler,"INSERT INTO blockers (serial, name, expireTimestamp, byAdmin, canmodsoverride) VALUES (?,?,?,?,?)",ser,pName,expTimestamp,admName,canmodsoverride or "true")

		return q
	end
end



function checkBlockerExpire()

	setElementData(resourceRoot,"serverTimestamp",getRealTime().timestamp)
	for _,player in ipairs(getElementsByType("player")) do
		if getElementData(player,"markedblocker") then
			local t = getElementData(player,"markedblocker")
			local timeleft =  t.expireTimestamp - getRealTime().timestamp
			if timeleft < 1 then
				removeBlockerFromDB(getPlayerSerial(player))
				setElementData(player,"markedblocker",nil)
				outputChatBox("You are no longer marked as a Ghost.",player,255,0,0)
			end
		end
	end


end
setTimer(checkBlockerExpire,1000,0)

function getExpireTimestamp(duration)
	local current = getRealTime().timestamp
	local duration = math.ceil(duration * 3600)

	return tonumber(current + duration)
end

function logBlockAction(playerResponsible, playerBlocked,wording,hours)
    local file
    if fileExists("killers.log") then
        file = fileOpen("killers.log")
    else
        file = fileCreate("killers.log")
    end
    local dateTime = getRealTime().monthday.."."..tostring(getRealTime().month+1).."."..tostring(getRealTime().year+1900).." - "..getRealTime().hour..":"..getRealTime().minute
    playerResponsible = getPlayerName(playerResponsible)
    playerBlocked = "serial: "..playerBlocked .. "unknown"
    local hoursString = ""
    if hours then
    	hoursString = " ("..tostring(hours).."h)"
    end

    local fullString = dateTime.." "..playerResponsible.." "..wording.." as Ghost "..playerBlocked..hoursString
    fileSetPos(file, fileGetSize(file))
    fileWrite(file, "\n"..fullString)
    fileClose(file)
end






-- GC Handler and resource start handling

addEventHandler("onResourceStart",resourceRoot,
	function()
		dbHandler = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))
		if dbHandler then
			for _,p in ipairs(getElementsByType("player")) do
				checkBlockerJoin(p)
			end
		end
  end)
addEventHandler("onResourceStop",resourceRoot,
	function()
		for _,p in ipairs(getElementsByType("player")) do
			setElementData(p,"markedblocker",nil)
		end
	end)

-- Misc
function secondsToTimeDesc( seconds )
	if seconds then
		local results = {}
		local sec = ( seconds %60 )
		local min = math.floor ( ( seconds % 3600 ) /60 )
		local hou = math.floor ( ( seconds % 86400 ) /3600 )
		local day = math.floor ( seconds /86400 )

		if day > 0 then table.insert( results, day .. ( day == 1 and " d" or " d" ) ) end
		if hou > 0 then table.insert( results, hou .. ( hou == 1 and " h" or " h" ) ) end
		if min > 0 then table.insert( results, min .. ( min == 1 and " m" or " m" ) ) end
		if sec > 0 then table.insert( results, sec .. ( sec == 1 and " s" or " s" ) ) end

		return string.reverse ( table.concat ( results, ", " ):reverse():gsub(" ,", " dna ", 1 ) )
	end
	return ""
end

function getPlayerFromSerial ( serial )
    assert ( type ( serial ) == "string" and #serial == 32, "getPlayerFromSerial - invalid serial" )
    for index, player in ipairs ( getElementsByType ( "player" ) ) do
        if ( getPlayerSerial ( player ) == serial ) then
            return player
        end
    end
    return false
end

function splitStringforChatBox(str)
	local max_line_length = 127
   local lines = {}
   local line
   str:gsub('(%s*)(%S+)',
      function(spc, word)
         if not line or #line + #spc + #word > max_line_length then
            table.insert(lines, line)
            line = word
         else
            line = line..spc..word
         end
      end
   )
   table.insert(lines, line)
   return lines
end
