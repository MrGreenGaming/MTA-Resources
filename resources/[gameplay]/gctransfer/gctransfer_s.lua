local transfers = {}
local cooldown = 60

function transfer(player, cmd, argAmount, argTransferTo)
	--if not hasObjectPermissionTo(player, "command.ban", false) then return end -- Admin exclusive command for testing purposes removed
	
	if not argAmount or not argTransferTo then
		throwError(player, "Usage: /" .. cmd .. " [amount] [exact player name]")
		return
	end
	
	-- Args are sent
	
	if transfers[player] and transfers[player] + cooldown > getTimestamp() then
		throwError(player, "You can only transfer GCs every " .. tostring(cooldown) .. " seconds!")
		return
	end
	
	-- Player doesn't have cooldown
	
	local logged = exports.gc:isPlayerLoggedInGC(player)
	if not logged then
		throwError(player, "You must be logged in to transfer GCs!")
		return
	end
	
	-- Player is logged in
	
	local amount = tonumber(argAmount)
	
	if not amount then
		throwError(player, "You need to enter a number as the amount!")
		return
	elseif amount < 1 or amount > 10000 then
		throwError(player, "You need to enter a number between 1 and 10000 as the amount!")
		return
	end
	
	-- Amount is valid
	
	local transferTo = getPlayerFromName(argTransferTo)
	
	if not transferTo then
		throwError(player, "The player with that name was not found!")
		return
	end
	
	if player == transferTo then
		throwError(player, "You can't send GCs to yourself!")
		return
	end
	
	-- Player to transfer found
	
	logged = exports.gc:isPlayerLoggedInGC(transferTo)
	if not logged then
		throwError(player, "The player you want to transfer GCs to is not logged in!")
		return
	end
	
	-- Player to transfer logged in
	
	local playerMoney = exports.gc:getPlayerGreencoins(player)
	
	if playerMoney < amount then
		throwError(player, "You don't have enough GCs!")
		return
	end
	
	-- Player has enough GCs; ready for transaction
	
	local check1 = exports.gc:addPlayerGreencoins(player, amount * -1)
	local check2 = exports.gc:addPlayerGreencoins(transferTo, amount)
	
	
	-- Refunds
	if not check1 and check2 then -- failed to take GCs
		exports.gc:addPlayerGreencoins(transferTo, -amount) --take the GCs
		throwError(player, "Failed to take GCs from your account, the GCs haven't been added to the " .. argTransferTo .. "#FF0000's account!")
	elseif check1 and not check2 then -- failed to give GCs
		exports.gc:addPlayerGreencoins(player, amount) --give back GCs
		throwError(player, "Failed to give GCs, you haven't been charged!")
	elseif not check1 and not check2 then -- both failed
		throwError(player, "Failed to give GCs, you haven't been charged!")
	elseif check1 and check2 then -- both succeded
		success(player, transferTo, amount)
		transfers[player] = getTimestamp()
	end
	
	local name, acc, forumid = getPlayerName(player), (isGuestAccount(getPlayerAccount(player)) and '') or getAccountName(getPlayerAccount(player)), tostring(exports.gc:getPlayerForumID( player ))
	local serial, email = getPlayerSerial (player),  tostring(exports.gc:getPlayerGreencoinsLogin( player ) )
	local fid = tostring(exports.gc:getPlayerForumID( transferTo ))
	
	pcall(addToLog, 'GC TRANSFER - TRANSFER - TIME: ' .. getTimestamp() .. ' - ' .. amount .. ' GCS TO FORUM ID: ' .. fid .. ' (TAKEN GCS: ' .. tostring(check1) .. ' | GIVEN GCS: ' .. tostring(check2) .. ') - ' .. name ..'/'.. acc ..'/'.. forumid ..'/'.. serial ..'/'.. email)
end
addCommandHandler("givegc", transfer)

function throwError(player, text)
	outputChatBox("[GC Transfer] " .. text, player, 255, 0, 0, true)
end

function success(player, transferedTo, amount)
	outputChatBox("[GC Transfer] " .. tostring(amount) .. " GCs have been successfully sent to " .. getPlayerName(transferedTo) .. "#00FF00!", player, 0, 255, 0, true)
	outputChatBox("[GC Transfer] " .. tostring(amount) .. " GCs have been sent to your account by " .. getPlayerName(player) .. "#00FF00!", transferedTo, 0, 255, 0, true)
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
