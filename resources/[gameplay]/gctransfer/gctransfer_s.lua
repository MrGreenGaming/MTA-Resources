local transfers = {}
local cooldown = 60

function getPlayersTable()
	local players = {}
	local logged
	local temp
	local name
	for i, p in ipairs(getElementsByType("player")) do
		logged = exports.gc:isPlayerLoggedInGC(p)
		temp = {}
		name = string.gsub(getPlayerName(p), "#%x%x%x%x%x%x", "")
		table.insert(temp, name)
		table.insert(temp, logged)
		table.insert(players, temp)
	end
	
	return players
end

function getPlayersTableByTeam(team)
	local players = {}
	local logged
	local temp
	local name
	for i, p in ipairs(getElementsByType("player")) do
		if getPlayerTeam(p) == team then
			logged = exports.gc:isPlayerLoggedInGC(p)
			temp = {}
			name = string.gsub(getPlayerName(p), "#%x%x%x%x%x%x", "")
			table.insert(temp, name)
			table.insert(temp, logged)
			table.insert(players, temp)
		end
	end
	
	return players
end

function throwError(player, text)
	outputChatBox("[GC Transfer] " .. text, player, 255, 0, 0, true)
end

function success(player, transferedTo, amount)
	--outputChatBox("[GC Transfer] " .. tostring(amount) .. " GCs have been successfully sent to " .. getPlayerName(transferedTo) .. "#00FF00!", player, 0, 255, 0, true)
	outputChatBox("[GC Transfer] " .. tostring(amount) .. " GCs have been sent to your account by " .. getPlayerName(player) .. "#00FF00!", transferedTo, 0, 255, 0, true)
end

function getTeammates(player)
	local team = getPlayerTeam(player)
	if not team then return getPlayersTable() end
	return getPlayersTableByTeam(team)
end

function filterSearch(tbl, search)
	if not tbl or not search then return tbl end
	local retTable = {}
	for i, p in ipairs(tbl) do
		if string.find(string.lower(p[1]), string.lower(search)) then
			table.insert(retTable, p)
		end
	end
	
	return retTable
end

addEventHandler("onPlayerJoin", getRootElement(), 
function()
	triggerClientEvent(getRootElement(), "GCTransfer.UpdatePlayerData", source)
end)

addEvent("GCTransfer.RequestPlayerData", true)
addEventHandler("GCTransfer.RequestPlayerData", root, 
function(team, search)
	local tbl = {}
	
	if team then
		tbl = getTeammates(source)
	else
		tbl = getPlayersTable()
	end
	
	if search then
		tbl = filterSearch(tbl, search)
	end
	
	triggerClientEvent(source, "GCTransfer.PlayerDataResponse", source, tbl)
end)

addEvent("GCTransfer.SendTransferRequest", true)
addEventHandler("GCTransfer.SendTransferRequest", root,
function(pName, amount)
	--Do all kinds of checks
	if not pName or not amount then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "You didn't enter a player name or amount!")
		return
	end
	
	if transfers[source] and transfers[source] + cooldown > getTimestamp() then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "You can transfer GCs every " .. tostring(cooldown) .. " seconds!")
		return
	end
	
	local logged = exports.gc:isPlayerLoggedInGC(source)
	if not logged then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "You are not logged in!")
		return
	end
	
	if amount ~= math.floor(amount) then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "The amount must be a whole number!")
		return
	end
	
	if amount < 1 or amount > 10000 then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "The amount must be between 1 and 10000!")
		return
	end
	
	local transferTo = getPlayerFromPartialName(pName)
	if not transferTo then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "Player could not be found!")
		return
	end
	
	if source == transferTo then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "You cannot send GCs to yourself!")
		return
	end
	
	logged = exports.gc:isPlayerLoggedInGC(transferTo)
	if not logged then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "The player you want to transfer GCs to is not logged in!")
		return
	end
	
	local fid = tostring(exports.gc:getPlayerForumID( transferTo ))
	local forumid = tostring(exports.gc:getPlayerForumID( source ))
	
	if fid == forumid then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "You cannot send GCs to yourself!")
		return
	end
	
	-- Player to transfer logged in
	
	local playerMoney = exports.gc:getPlayerGreencoins(source)
	
	if playerMoney < amount then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "You don't have enough GCs!")
		return
	end
	
	local success = doTransfer(source, pName, amount)
	
	if not success then
		triggerClientEvent(source, "GCTransfer.TransferResponse", source, false, "An unknown error happened!")
		return
	end
	
	triggerClientEvent(source, "GCTransfer.TransferResponse", source, true, "You have successfully sent " .. tostring(amount) .. " GCs to " .. getPlayerName(transferTo) .. "#00FF00!")
end)

function doTransfer(player, argTransferTo, argAmount)	
	if not argAmount or not argTransferTo then
		return false
	end
	
	-- Args are sent
	
	if transfers[player] and transfers[player] + cooldown > getTimestamp() then
		return false
	end
	
	-- Player doesn't have cooldown
	
	local logged = exports.gc:isPlayerLoggedInGC(player)
	if not logged then
		return false
	end
	
	-- Player is logged in
	
	local amount = tonumber(argAmount)
	
	if not amount then
		return false
	elseif amount ~= math.floor(amount) then
		return false
	elseif amount < 1 or amount > 10000 then
		return false
	end
	
	-- Amount is valid
	
	local transferTo = getPlayerFromPartialName(argTransferTo)
	
	if not transferTo then
		return false
	end
	
	if player == transferTo then
		return false
	end
	
	-- Player to transfer found
	
	logged = exports.gc:isPlayerLoggedInGC(transferTo)
	if not logged then
		return false
	end
	
	local fid = tostring(exports.gc:getPlayerForumID( transferTo ))
	local forumid = tostring(exports.gc:getPlayerForumID( player ))
	
	if fid == forumid then
		return false
	end
	
	-- Player to transfer logged in
	
	local playerMoney = exports.gc:getPlayerGreencoins(player)
	
	if playerMoney < amount then
		return false
	end
	
	-- Player has enough GCs; ready for transaction
	
	local check1 = exports.gc:addPlayerGreencoins(player, amount * -1)
	local check2 = exports.gc:addPlayerGreencoins(transferTo, amount)
	
	
	-- Refunds
	if not check1 and check2 then -- failed to take GCs
		exports.gc:addPlayerGreencoins(transferTo, -amount) --take the GCs
	elseif check1 and not check2 then -- failed to give GCs
		exports.gc:addPlayerGreencoins(player, amount) --give back GCs
	elseif not check1 and not check2 then -- both failed

	elseif check1 and check2 then -- both succeded
		success(player, transferTo, amount)
		transfers[player] = getTimestamp()
	end
	
	local name, acc = getPlayerName(player), (isGuestAccount(getPlayerAccount(player)) and '') or getAccountName(getPlayerAccount(player))
	local serial, email = getPlayerSerial (player),  tostring(exports.gc:getPlayerGreencoinsLogin( player ) )
	
	
	pcall(addToLog, 'GC TRANSFER - TRANSFER - ' .. amount .. ' GCS TO FORUM ID: ' .. fid .. ' (TAKEN GCS: ' .. tostring(check1) .. ' | GIVEN GCS: ' .. tostring(check2) .. ') - ' .. name ..'/'.. acc ..'/'.. forumid ..'/'.. serial ..'/'.. email)
	return (check1 and check2)
end

local logFile = false

function addToLog(text)
	local t = getRealTime()
	if not isElement(logFile) then
		logFile = fileOpen("transfer.log")
		if not logFile then
			logFile = fileCreate("transfer.log")
		else
			fileSetPos(logFile, fileGetSize(logFile))
		end
	end
	text = "[" .. getRealDateTimeString(t) .. "] " .. tostring(text or '')
	fileWrite(logFile, text.."\r\n")
	fileFlush(logFile)
	fileClose(logFile)
	return true
end

function getPlayerFromPartialName(name) --https://wiki.multitheftauto.com/wiki/GetPlayerFromPartialName
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

function getTimestamp(year, month, day, hour, minute, second) -- https://wiki.multitheftauto.com/wiki/GetTimestamp
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end

function isLeapYear(year) -- https://wiki.multitheftauto.com/wiki/IsLeapYear
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function getRealDateTimeString( time )
	return string.format( '%04d-%02d-%02d %02d:%02d:%02d'
						,time.year + 1900
						,time.month + 1
						,time.monthday
						,time.hour
						,time.minute
						,time.second
						)
end
