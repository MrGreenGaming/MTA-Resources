-------------------
--- Autologin  ---
-------------------

local loginTable = "gc_autologin"
local handlerConnect

-- Setup sql database --
local function startup()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))
end
addEventHandler("onResourceStart", resourceRoot, startup)

local function clientStart(token)
    if not token or type(token) ~= 'string' then
        -- outputChatBox('[GC] Invalid auto-login token.', client)
        return
    end
    local player = client
    checkPlayerSerialGreencoins(player)
    local serial = getPlayerSerial(player)
    if handlerConnect then
        local query = dbQuery(autologinInfoReceived, { player }, handlerConnect, "SELECT forumid FROM `??` WHERE `last_serial` = ? AND `token` = ? LIMIT 0,1", loginTable, serial, token)
    end
end
addEvent('onClientGreenCoinsStart', true)
addEventHandler('onClientGreenCoinsStart', root, clientStart)

function autologinInfoReceived(query, player)
    local results = dbPoll(query, 0)
    if results and #results > 0 and tonumber(results[1].forumid) then
        setElementData( player, 'gc.autoLoginCache', tonumber(results[1].forumid), false ) -- Account Switch Bug TempFix - https://github.com/MrGreenGaming/MTA-Resources/issues/488
        onAutoLogin(tonumber(results[1].forumid), player)
    end
end

function updateAutologin(player, forumid)
    local serial = getPlayerSerial(player)
    local date = getRealDateTimeNowString()
    local ip = getPlayerIP(player)
    local newToken = generateAutoLoginToken()
    
    dbExec(handlerConnect, "INSERT INTO `??` (`forumid`, `last_serial`, `last_login`, `last_ip`, `token`) VALUES (?,?,?,?,?) ON DUPLICATE KEY UPDATE `forumid`=?, `last_login`=?, `last_ip`=?, `token`=?",
        loginTable, forumid, serial, date, ip, tostring(newToken), forumid, date, ip, tostring(newToken))
    triggerClientEvent( player, 'onNewAutoLoginToken', player, newToken)
end

function deleteAutologin(forumid)
    dbExec(handlerConnect, "DELETE FROM `??` WHERE forumid=?", loginTable, forumid)
end

function generateAutoLoginToken ()
    local allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } }
    math.randomseed ( getRealTime().timestamp + getTickCount () - math.random(1000, 100000) )
    local token = ""
    for i = 1, 200 do
        local charlist = allowed[math.random ( 1, 3 )]
        token = token .. string.char ( math.random ( charlist[1], charlist[2] ) )
    end
    return token
end

function autoLoginElementDataProtection(key, oldVal, newVal)
    if key == "gc.autoLoginCache" and (client or sourceResource ~= getResourceFromName('gc')) then
        setElementData(source, key, oldVal)
        if client then
            outputDebugString(tostring(getPlayerName(client))..' tried to change gc.autoLoginCache to '..tostring(newVal))
        else
            outputDebugString(tostring(getResourceName(sourceResource))..' tried to change gc.autoLoginCache to '..tostring(newVal))
        end
    end
end
addEventHandler("onElementDataChange", root, autoLoginElementDataProtection)