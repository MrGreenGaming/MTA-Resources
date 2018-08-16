-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- Nick protection based on GreenCoins account for eased up accessibility--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------



--TO DO:

--add admin /unlocknick <nick>
--add player /unlocknick 

bAllowCommands = {}

function doesPlayerMatchNick(nick, id)
    local cmd = ''
    local query
    if handlerConnect then
        cmd = "SELECT pNick, forumId, accountID FROM gc_nickprotection WHERE pNick = ?"
        query = dbQuery(handlerConnect, cmd, nick)
        if not query then return false end
        local sql = dbPoll(query, -1)
        if not sql then return false end
        if #sql > 0 then
            if sql[1].forumId == id then
                return true
            else
                return false
            end
        end
    end
end

handlerConnect = nil
canScriptWork = true
addEventHandler('onResourceStart', getResourceRootElement(),
    function()
        handlerConnect = dbConnect('mysql', 'host=' .. get "*gcshop.host" .. ';dbname=' .. get "*gcshop.dbname", get("*gcshop.user"), get("*gcshop.pass"))
        if not handlerConnect then
            outputDebugString('Nickprotection error: could not connect to the mysql db')
            canScriptWork = false
            return
        end
    end)

function safeString(playerName)
    playerName = string.gsub(playerName, "?", "")
    playerName = string.gsub(playerName, "'", "")
    playerName = string.gsub(playerName, "#%x%x%x%x%x%x", "")
    return playerName
end

function isNickProtected(nick)
    if handlerConnect then
        local cmd = "SELECT pNick, forumId, accountID FROM gc_nickprotection WHERE LOWER(pNick) = ? LIMIT 0,1"
        local query = dbQuery(handlerConnect, cmd, string.lower(nick))
        if not query then
            return false
        end

        local sql = dbPoll(query, -1)
        if not sql or #sql == 0 then
            return false
        end

        return true
    else
        return false
    end
end

function deleteNick(p, c, nick)
    if not nick then return end
    local cmd = "DELETE FROM gc_nickprotection WHERE pNick = ?"
    dbExec(handlerConnect, cmd, nick)
    outputChatBox("[NICK] Removed \"" .. nick .. "\" nickprotection", p)
end

addCommandHandler('deletenick', deleteNick, true)

-- function protectNick(id, name)
-- 	if isNickProtected(name) then
-- 		return false
-- 	end
-- 	--local sql = executeSQLQuery("SELECT pNick, accountID FROM gcProtectedNames WHERE accountID = '"..id.."'")
-- 	local cmd = ''
-- 	local query 
-- 	if handlerConnect then
-- 		cmd = "SELECT pNick, accountID FROM gc_nickprotection WHERE accountID = ?"
-- 		query = dbQuery(handlerConnect, cmd, id)
-- 		if not query then return false end
-- 		local sql = dbPoll(query, -1)
-- 		if not sql then return false end
-- 		if #sql < 3 then
-- 			cmd = "INSERT INTO gc_nickprotection VALUES(?,?)"
-- 			dbExec(handlerConnect, cmd, name, id)
-- 			return true	
-- 		else return false
-- 		end
-- 	end	
-- end

-- addCommandHandler('locknick',
-- function(player)
-- 	if not canScriptWork then return end
-- 	--outputChatBox('test')
-- 	if not getResourceFromName('gc') or getResourceState(getResourceFromName('gc')) ~= "running" then 
-- 		outputChatBox('You can\'t lock your nick because GC resource isn\'t running now. Try again later.', player, 255, 0, 0)
-- 		return 
-- 	end
-- 	local logged = exports.gc:isPlayerLoggedInGC(player)
-- 	if logged then
-- 		local id = exports.gc:getPlayerGreencoinsID(player)
-- 		id = tostring(id)
-- 		local name = safeString(getPlayerName(player))
-- 		if protectNick(id, name) then
-- 			outputChatBox('Nick has been protected and attached to your current account.', player, 255, 0, 0)
-- 		else
-- 			outputChatBox('Nick is already attached to another account, or max protected nicks(3) has been reached for this account.', player, 255, 0, 0)
-- 		end
-- 	else
-- 		outputChatBox('You can\'t lock your nick unless you\'re logged in GCs.', player, 255, 0, 0)
-- 	end	
-- end
-- )

-- addCommandHandler('unlocknick',
-- function(player)
-- 	if not canScriptWork then return end
-- 	if not getResourceFromName('gc') or getResourceState(getResourceFromName('gc')) ~= "running" then 
-- 		outputChatBox('You can\'t unlock your nick because GC resource isn\'t running now. Try again later.', player, 255, 0, 0)
-- 		return 
-- 	end
-- 	id = exports.gc:getPlayerGreencoinsID(player)
-- 	local isLogged = exports.gc:isPlayerLoggedInGC(player)
-- 	id = tostring(id)
-- 	if isLogged then
-- 		if doesPlayerMatchNick(safeString(getPlayerName(player)), id) then
-- 			--local sql = executeSQLQuery("SELECT pNick, accountID FROM gcProtectedNames WHERE pNick = '"..safeString(getPlayerName(player)).."'")
-- 			local cmd = ''
-- 			local query 
-- 			if handlerConnect then
-- 				cmd = "SELECT pNick, accountID FROM gc_nickprotection WHERE pNick = ?"
-- 				query = dbQuery(handlerConnect, cmd, safeString(getPlayerName(player)))
-- 				if not query then outputChatBox('Nickname not locked.', player, 255, 0, 0) return false end
-- 				local sql = dbPoll(query, -1)
-- 				if not sql then outputChatBox('Nickname not locked.', player, 255, 0, 0) return false end
-- 				if #sql > 0 then
-- 					cmd = "DELETE FROM gc_nickprotection WHERE pNick = ?"
-- 					dbExec(handlerConnect, cmd, safeString(getPlayerName(player)))
-- 					outputChatBox('Your nick has been unlocked, it is now free to use by anyone.', player, 255, 0, 0)
-- 				else 
-- 					outputChatBox('Nickname not locked.', player, 255, 0, 0)
-- 				end			
-- 			end
-- 		else
-- 			outputChatBox("Nickname not locked, or it doesn't belong to you.", player, 255, 0, 0)
-- 		end
-- 	else
-- 		outputChatBox("Please login to use this command.", player, 255, 0, 0)
-- 	end
-- end
-- )

function warnPlayer(player, oldNick)
    if oldNick then
        setPlayerName(player, oldNick)
    else
        local time = getRealTime()
        setPlayerName(player, "Guest" .. tostring(time.timestamp))
    end

    outputChatBox('This nick is protected. If it\'s your name, please log into GCs or use another name.', player, 255, 0, 0)
end

g_JoinHandler = {}


addEvent('nickProtectionLoaded', true)
addEventHandler('nickProtectionLoaded', getRootElement(),
    function()
        if not canScriptWork then return end
        if not getResourceFromName('gc') or getResourceState(getResourceFromName('gc')) ~= "running" then
            return
        end
        g_JoinHandler[source] = setTimer(function(player)
            if not isElement(player) then
                return
            end

            local isCurrentNickProtected = isNickProtected(safeString(getPlayerName(player)))
            if not isCurrentNickProtected then
                return
            end

            local isLogged = exports.gc:isPlayerLoggedInGC(player)
            if not isLogged then
                warnPlayer(player)
                return
            end

            local id = exports.gc:getPlayerGreencoinsID(player)
            if not doesPlayerMatchNick(safeString(getPlayerName(player)), id) then
                warnPlayer(player)
            end
        end, 15000, 1, source)
    end)

g_NickHandler = {}
addEventHandler('onPlayerChangeNick', getRootElement(),
    function(oldNick, newNick)
        if not canScriptWork then return end
        nickChangeSpamProtection(source)
        if not getResourceFromName('gc') or getResourceState(getResourceFromName('gc')) ~= "running" then
            return
        end

        local player = source

        if not isElement(player) then
            return
        end

        local nick = newNick

        local isCurrentNickProtected = isNickProtected(safeString(nick))
        if not isCurrentNickProtected then
            return
        end

        local isLogged = exports.gc:isPlayerLoggedInGC(player)
        if not isLogged then
            cancelEvent()
            outputChatBox('This nick is protected. If it\'s your name, please log into GCs or use another name.', player, 255, 0, 0)
            setTimer(function() if getPlayerName(player) == nick then warnPlayer(player, oldNick) end end, 10000, 1)
            return
        end

        local id = exports.gc:getPlayerGreencoinsID(player)
        if not doesPlayerMatchNick(safeString(nick), id) then
            cancelEvent()
            outputChatBox('This nick is protected. If it\'s your name, please log into GCs or use another name.', player, 255, 0, 0)
            setTimer(function() if getPlayerName(player) == nick then warnPlayer(player, oldNick) end end, 500, 1)
        end
    end)


addEvent('onGreencoinsLogin', true)
--[[addEventHandler('onGreencoinsLogin', getRootElement(),
    function()
        if not canScriptWork then
            return
        end

        id = exports.gc:getPlayerGreencoinsID(source)
        id = tostring(id)
    end)]]


addEventHandler('onPlayerQuit', getRootElement(), function()
    g_NickHandler[source] = nil
    g_JoinHandler[source] = nil
end)

-----------------------------------
-- ### Nick change flood protection
-----------------------------------


local count = {}
local last = {}

function nickChangeSpamProtection(player)
    local waitForSeconds = 30

    -- reset if waiting time has passed
    if last[player] ~= nil and last[player] < (getTickCount() - waitForSeconds * 1000) then
        count[player] = 0
    end

    -- increase count
    if count[player] == nil then
        count[player] = 1
    else
        count[player] = count[player] + 1
    end

    -- if count is too high, cancel changing of nick
    if count[player] > 2 then
        cancelEvent()
        outputChatBox("Please wait some time before changing your nick again.", player, 255, 100, 100)
    else
        last[player] = getTickCount()
    end
end