-- When a vip uses their vip horn, the gc horn should terminate and be set on cooldown
local vipHorns = {
    -- [player] = {hornsTable}
}

local vipHornsCooldown = {
    -- [player] = timestamp
}

local vipHornCooldown = 20 -- Seconds
local canUseHorns = false

function initVipHorns(player)
    getVipHorns(player)
    bindVipHorns(player, false)
    if vipHorns[player] then
        sendClientVipHornsTable(player)
    end
end
-- Send horn table to client
function sendClientVipHornsTable(player)
    triggerClientEvent( player, 'onServerSendVipHornTable', player, vipHorns[player] or false)
end

function getVipHorns(player)
    local theID = exports.gc:getPlayerForumID(player)
	if not theID then return false end
    local query = dbQuery(handlerConnect, "SELECT * FROM vip_horns WHERE forumid=?", theID)
    local result = dbPoll(query,-1)
    if result then
        vipHorns[player] = result
        return result
    else
        return false
    end
end

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
			end
		end
	end
)