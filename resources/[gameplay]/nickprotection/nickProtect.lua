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
        cmd = "SELECT pNick, forumId FROM gc_nickprotection WHERE pNick = ?"
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

function DoesPlayerMatchNickAsync(player, nick, id, callback)
    if handlerConnect then
        local cmd = "SELECT pNick, forumId FROM gc_nickprotection WHERE pNick = ?"
        dbQuery(function (qh)
            if not qh then callback(player, false) end
            local sql = dbPoll(qh, 0)
            if not sql then callback(player, false) end
            if #sql >0 then
                if sql[1].forumId == id then
                    callback(player, true)
                else
                    callback(player, false)
                end
            end
        end, {}, handlerConnect, cmd, nick)
    end
end

handlerConnect = nil
canScriptWork = true
addEventHandler('onResourceStart', getResourceRootElement(),
function()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))
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
        local cmd = "SELECT pNick, forumId FROM gc_nickprotection WHERE LOWER(pNick) = ? LIMIT 0,1"
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

function IsNickProtectedAsync(nick, callback)
    if handlerConnect then
        local cmd = "SELECT pNick, forumId FROM gc_nickprotection WHERE LOWER(pNick) = ? LIMIT 0,1"
        dbQuery(function(qh)
            if not qh then callback(false) end
            local sql = dbPoll(qh, 0)

            if not sql or #sql == 0 then callback(false) end
            callback(true)
            
        end, {}, handlerConnect, cmd, nick)
    else
        callback(false)
    end
end

function deleteNick(p, c, nick)
    if not nick then return end
    local cmd = "DELETE FROM gc_nickprotection WHERE pNick = ?"
    dbExec(handlerConnect, cmd, nick)
    outputChatBox("[NICK] Removed \"" .. nick .. "\" nickprotection", p)
end

addCommandHandler('deletenick', deleteNick, true)

function warnPlayer(player, oldNick)
    if oldNick then
        setPlayerName(player, oldNick)
    else
        local time = getRealTime()
        setPlayerName(player, "Guest" .. tostring(time.timestamp))
    end
    -- Remove VIP supernick when name is locked
    removeElementData(player, "vip.colorNick")
    outputChatBox('[NICK] Your nickname has been changed because your previous nickname has been locked.', player, 255, 0, 0)
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

            IsNickProtectedAsync(safeString(getPlayerName(player)), function (result)
                if not result then return end;
                local isLogged = exports.gc:isPlayerLoggedInGC(player)
                if not isLogged then
                    warnPlayer(player)
                    return
                end
    
                local id = exports.gc:getPlayerGreencoinsID(player)
                DoesPlayerMatchNickAsync(player, safeString(getPlayerName(player)), id, function (player, result)
                    if not result then
                        warnPlayer(player)
                    end
                end)
            end)
        end, 30000, 1, source)
    end
)

g_NickHandler = {}
addEventHandler('onPlayerChangeNick', getRootElement(),
    function(oldNick, newNick, byUser)
        if not canScriptWork then return end
        if byUser then
            nickChangeSpamProtection(source)
        end
        
        if not getResourceFromName('gc') or getResourceState(getResourceFromName('gc')) ~= "running" then
            return
        end

        local player = source

        if not isElement(player) then
            return
        end

        local nick = newNick
        IsNickProtectedAsync(nick, function (result)
            if not result then return end;
            
            local isLogged = exports.gc:isPlayerLoggedInGC(player)
            if not isLogged then
                cancelEvent()
                outputChatBox('[NICK] This nick is protected. If it\'s your name, please log into GCs or use another name.', player, 255, 0, 0)
                if getPlayerName(player) == newNick then
                    warnPlayer(player, oldNick)
                end
                return
            end
    
            local id = exports.gc:getPlayerGreencoinsID(player)
            -- if not doesPlayerMatchNick(safeString(nick), id) then
            --     cancelEvent()
            --     outputChatBox('[NICK] This nick is protected. If it\'s your name, please log into GCs or use another name.', player, 255, 0, 0)
            --     setTimer(function(oldNick, newNick) 
            --         if getPlayerName(player) == newNick then 
            --             warnPlayer(player, oldNick) 
            --         end
            --     end, 500, 1, oldNick, newNick)
            -- end
            DoesPlayerMatchNickAsync(player, safeString(nick), id, function (player, result)
                if not result then
                    cancelEvent()
                    outputChatBox('[NICK] This nick is protected. If it\'s your name, please log into GCs or use another name.', player, 255, 0, 0)
                    if getPlayerName(player) == newNick then
                     warnPlayer(player, oldNick)
                    end
                end
            end)
        end)
    end
)


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