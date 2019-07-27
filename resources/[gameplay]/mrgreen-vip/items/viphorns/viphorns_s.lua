local hornPath = 'items/viphorns/horns/'
-- When a vip uses their vip horn, the gc horn should terminate and be set on cooldown
local vipHorns = {
    -- [player] = {hornsTable}
}
local checksums = {
    -- [player] = {
        -- [hornid] = checksum,
    -- }
}

local vipHornsCooldown = {
    -- [player] = timestamp
}

local vipHornCooldown = 20 -- Seconds
local canUseHorns = false

function initVipHorns(player)
    getVipHorns(player)
end
-- Send horn table to client
function sendClientVipHornsTable(player)
    triggerClientEvent( player, 'onServerSendVipHornTable', player, vipHorns[player] or false)
end

function getVipHorns(player)
    local theID = exports.gc:getPlayerForumID(player)
	if not theID then return false end
    local query = dbQuery(
        function(qh)
            local result = dbPoll(qh, 0)
            if result then
                vipHorns[player] = result
            end
            -- Iterate results , download/checksum
            for i, result in ipairs(result) do
                if fileExists(hornPath..result.forumid..'-'..result.hornid..'.mp3') then
                    -- Compare md5 checksum
                    local localChecksum = getMD5(hornPath..result.forumid..'-'..result.hornid..'.mp3')
                    if not localChecksum then
                        downloadVipHorn(result.forumid..'-'..result.hornid, player)
                    else
                        fetchRemote('https://mrgreengaming.com/api/viphornchecksum/?id='..result.forumid..'-'..result.hornid, 
                        function(res, err)
                            if err ~= 0 or res ~= localChecksum then
                                downloadVipHorn(result.forumid..'-'..result.hornid, player) 
                            else
                                if not checksums[player] then checksums[player] = {} end
                                checksums[player][result.forumid..'-'..result.hornid] = localChecksum
                            end
                        end)    
                    end
                else
                    -- Download file
                    downloadVipHorn(result.forumid..'-'..result.hornid, player)
                end
            end
            sendClientVipHornsTable(player)
            bindVipHorns(player, false)
        end, 
    handlerConnect, "SELECT * FROM vip_horns WHERE forumid=?", theID)    
end

function downloadVipHorn(id, player)
    fetchRemote('https://mrgreengaming.com/api/viphorn/?id='..id,
    function(res, err)
        if err ~= 0 then 
            outputDebugString('VIP horns: Could not download '..id)
            return 
        end
        local file = fileCreate(hornPath..id..'.mp3')
        fileWrite(file, res)
        fileClose(file)
        if not player then return end
        local fileChecksum = getMD5(hornPath..id..'.mp3')
        if not fileChecksum then return end
        if not checksums[player] then checksums[player] = {} end
        -- Save checksum
        checksums[player][id] = fileChecksum
        triggerEvent('onVIPHornFinishedDownloading', resourceRoot, id)
    end)
end

function sendClientVipHorn(id, sendTo)
    if not string.find(id, '.mp3') then
        id = id .. '.mp3'
    end
    if fileExists(hornPath..id) then
        local file = fileOpen(hornPath..id)
        local data = fileRead( file, fileGetSize(file) )
        fileClose(file)
        triggerLatentClientEvent( sendTo, 'onServerSendsClientVipHorn', 50000, false,resourceRoot, data, id)
    else
        downloadVipHorn(id)
    end
end
addEvent('onClientRequestsVipHorn', true)
addEventHandler('onClientRequestsVipHorn', root, 
function(id) 
    if type(id) == 'string' then
        sendClientVipHorn(id, client)
    end
end)

function bindVipHorns(player, unbind)
    if not vipHorns[player] then return end
    for i, row in ipairs(vipHorns[player]) do
        if row.boundkey then
            if unbind then
                unbindKey( player, row.boundkey, "down", useVipHorn)
            else
                bindKey(player, row.boundkey, "down", useVipHorn, row.hornid)
            end
        end
    end
end

function useVipHorn (player, key, state, hornid)
    if vipHornsCooldown[player] and vipHornsCooldown[player] >  getTickCount() or not canUseHorns then
        -- Still on cooldown
        return
    end
    local theID = exports.gc:getPlayerForumID(player)
    if not theID then return false end
    if not hornid then return false end

    --  Trigger VIP horn
    triggerEvent( 'onVipUseHorn', root, player, theID..'-'..hornid)
    triggerClientEvent( 'onClientVipUseHorn', root, player, theID..'-'..hornid)
    vipHornsCooldown[player] = getTickCount() + (vipHornCooldown * 1000)
end

-- VIP (un)binding
function handleClientVipBind(key, hornid)
    local theID = exports.gc:getPlayerForumID(client)
    if not theID then 
        outputChatBox('VIP horn: Could not get your forum ID. Please try again.',client,255,0,0)
        return 
    end
    -- Horn id is returned as forumid-hornid, get actual horn id
    local actualHornId = split(hornid,'-')[2]
    if not actualHornId or not tonumber(actualHornId) then
        outputChatBox('VIP horn: Could not get horn id. Please try again.',client,255,0,0)
        return
    end
    -- Unbind horns and remove from table
    bindVipHorns(client, true)
    vipHorns[client] = nil
    -- Save horns to DB
    dbExec(handlerConnect, "UPDATE vip_horns SET boundkey = ? WHERE forumid=? AND hornid = ?", key or nil, theID, tonumber(actualHornId))
    initVipHorns(client)
    if key then
        outputChatBox('VIP horn: Horn successfully set to '..key,client,0,255,0)
    else
        outputChatBox('VIP horn: Horn successfully unbound',client,0,255,0)
    end
end
addEvent('onClientVipHornBindsChanged', true)
addEventHandler('onClientVipHornBindsChanged', resourceRoot, handleClientVipBind)

-- canUseHorns state managing
local canUseStates = {
    ['GridCountdown'] = true,
    ['Running'] = true,
    ['PreGridCountdown'] = true,
    ['TimesUp'] = true
}
function setHornState(state)
    canUseHorns = canUseStates[state] or false
end
addEvent('onRaceStateChanging')
addEventHandler('onRaceStateChanging', root, setHornState)


addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
			if loggedIn then
                initVipHorns(player)
			else
                -- Handle logout
                bindVipHorns(player, true)
                if vipHorns[player] then vipHorns[player] = nil end
                if checksums[player] then checksums[player] = nil end
			end
		end
	end
)

function sendClientsChecksums(state)
    if state == 'NoMap' then
        local sendTable = {}
        for player, values in pairs(checksums) do
            for id, sum in pairs(values) do
                sendTable[id] = sum
            end
        end
        triggerClientEvent( 'onServerSendVipHornChecksum', resourceRoot, sendTable )
    end
end
addEventHandler('onRaceStateChanging', root, sendClientsChecksums)