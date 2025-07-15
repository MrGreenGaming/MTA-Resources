------------------------------------------------------------------------------------------
--  When a statistic is not present in the database, it will default to these values.   --
--  The new stats database has the structure [forumid] [category] [name] [value]        --
--  So new stats can be added without changing the database.                            --
--  If you want to add stats, you should add them to this table and make it save.       --
------------------------------------------------------------------------------------------
local defaultValues = {
    {
        ['name'] = 'General',
        ['items'] = {
            {name = 'Join Date', value = false},
            {name = 'Playtime', value = 0},
            {name = 'Total Checkpoints', value = 0},
            {name = 'Total Deaths', value = 0},
            {name = 'Total Wins', value = 0},
        }
    },
    {
        ['name'] = 'Race',
        ['items'] = {
            {name = 'Starts', value = 0},
            {name = 'Finishes', value = 0},
            {name = 'Wins', value = 0},
            {name = 'Top 1\'s', value = 0},
            {name = 'Total Rank', value = false},
        }
    },
    {
        ['name'] = 'Never The Same',
        ['items'] = {
            {name = 'Starts', value = 0},
            {name = 'Finishes', value = 0},
            {name = 'Wins', value = 0},
            {name = 'Top 1\'s', value = 0},
            {name = 'Total Rank', value = false},
        }
    },
    {
        ['name'] = 'Destruction Derby',
        ['items'] = {
            {name = 'Wins', value = 0},
            {name = 'Kills', value = 0},
            {name = 'Deaths', value = 0},
            {name = 'K/D Ratio', value = 0},
            {name = 'Top 1\'s', value = 0},
            {name = 'Total Rank', value = false},
        }
    },
    {
        ['name'] = 'Shooter',
        ['items'] = {
            {name = 'Wins', value = 0},
            {name = 'Kills', value = 0},
            {name = 'Deaths', value = 0},
            {name = 'K/D Ratio', value = 0},
            {name = 'Top 1\'s', value = 0},
            {name = 'Total Rank', value = false},
        }
    },
    {
        ['name'] = 'DeadLine',
        ['items'] = {
            {name = 'Wins', value = 0},
            {name = 'Kills', value = 0},
            {name = 'Deaths', value = 0},
            {name = 'K/D Ratio', value = 0},
            {name = 'Top 1\'s', value = 0},
            {name = 'Total Rank', value = false},
        }
    },
    {
        ['name'] = 'Reach The Flag',
        ['items'] = {
            {name = 'Starts', value = 0},
            {name = 'Wins', value = 0},
            {name = 'Top 1\'s', value = 0},
            {name = 'Total Rank', value = false},
        }
    },
    {
        ['name'] = 'Capture The Flag',
        ['items'] = {
            {name = 'Flags Delivered', value = 0},
        }
    }
}

-- Mapping index to avoid excessive looping to find/set a value
categoryMap = {
    -- Structure
    -- ['catName'] = index
}
statsMap = {
    -- Structure
    -- ['catName'] {
        -- ['statName'] = index
    -- },
}
function setStatMaps()
    for i, row in ipairs(defaultValues) do
        categoryMap[row.name] = i
        statsMap[row.name] = {}
        for i, stat in ipairs(row.items) do
            statsMap[row.name][stat.name] = i
        end
    end
end
setStatMaps()

-------------------
-- Database Init --
-------------------
function initStatsDB()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))
	if not handlerConnect then
		outputDebugString('Stats Database error: could not connect to the mysql db')
		return
	end
end
addEventHandler( 'onResourceStart', resourceRoot, initStatsDB)

---------------------
-- Loading/Saving  --
---------------------

local playerStats = {
    -- TABLE STRUCTURE
    -- [forumid] = defaultValues
}
local forumidPlayerMap = {
    -- TABLE STRUCTURE
    -- [forumid] = playerElement
}
local playerTopTimes = {
    -- TABLE STRUCTURE
    -- [forumid] = {
    --     {name = 'Name', items = {
    --         name = 'Item Name',
    --         value = 'Item Value'
    --     }}
    -- }
}
local playerTopTimeMaps = {
    -- [forumid] = {
    --     {
    --         racemode = 'nts',
    --         pos = '3',
    --         items = {
    --             {
    --                 mapname = 'Map Name',
    --                 resname = 'Map Res Name',
    --                 date = 'Top Time',
    --                 value = 'Top Value',
    --                 disabled = true
    --             },
    --             ...
    --         }
    --     },
    --     ...
    -- }
}
local playerMonthlyTopTimes = {
    -- TABLE STRUCTURE
    -- [forumid] = 0,
}
function buildPlayerStats()
    for _, p in ipairs(getElementsByType( 'player' )) do
        if canExport('gc') and exports.gc:isPlayerLoggedInGC(p) then
            local id = getPlayerID(p)
            loadPlayerStats(id)
            forumidPlayerMap[id] = p
        end
    end
end
addEventHandler( 'onResourceStart', resourceRoot, buildPlayerStats)

function loadPlayerStats(forumid)
    if not forumid or type(forumid) ~= 'number' then return end
    playerStats[forumid] = table.copy(defaultValues)
    local queryString = "SELECT * FROM player_stats WHERE forumid = ?"
    dbQuery( 
        function(qh) 
            local res = dbPoll(qh, 0)
            if not playerStats[forumid] or #res < 1 then return end
            for i, row in ipairs(res) do
                -- var_dump('-v', res)
                if not categoryMap[tostring(row.category)] then
                    outputDebugString('Stats: Could not find category '..tostring(row.category)..'. Make sure its added to defaultValues', 1)
                elseif not statsMap[tostring(row.category)][tostring(row.statName)] then
                    outputDebugString('Stats: Could not find statName '..tostring(row.statName)..' in category '..tostring(row.category)..'. Make sure its added to defaultValues', 1)
                else
                    local catIndex = categoryMap[tostring(row.category)]
                    local statIndex = statsMap[tostring(row.category)][tostring(row.statName)]
                    if tonumber(row.statVal) then row.statVal = tonumber(row.statVal) end
                    playerStats[forumid][catIndex].items[statIndex].value = row.statVal
                end
            end
            triggerEvent('onPlayerStatsLoaded', resourceRoot, forumid)
            fetchTopTimes(forumid)
            fetchTopTimeMaps(forumid)
            fetchMonthlyTops(forumid)
        end, 
    handlerConnect, queryString, forumid)
end
addEvent('onGCLogin')
addEventHandler('onGCLogin', root, function(id)
    playerTopTimes[id] = {}
    playerTopTimeMaps[id] = {}
    playerMonthlyTopTimes[id] = 0
    loadPlayerStats(id)
    forumidPlayerMap[id] = source
end)
addEvent('onGCLogout')
addEventHandler('onGCLogout', root, function(id) 
    if playerStats[id] then 
        playerStats[id] = nil
    end
    if forumidPlayerMap[id] then
        forumidPlayerMap[id] = nil 
    end
    if playerTopTimeMaps[id] then
        playerTopTimeMaps[id] = nil
    end
    if playerTopTimes[id] then
        playerTopTimes[id] = nil
    end
    if playerMonthlyTopTimes[id] then
        playerMonthlyTopTimes[id] = nil
    end
end)


-- Saved stats are saved in the queryCache, which will execute when race reaches 'NoMap' state
local queryCache = {}
local function saveStatsInDB()
    if not handlerConnect then return end
    for i, queryString in ipairs(queryCache) do
        dbExec( handlerConnect, queryString )
        queryCache[i] = nil
    end
end
addEvent('onRaceStateChanging')
addEventHandler('onRaceStateChanging', root, function(state) if state == 'NoMap' then saveStatsInDB() end end)
addEventHandler('onResourceStop', resourceRoot, saveStatsInDB)

function saveStat(forumid, category, name, value, increment)
    if not canExport('gc') or not handlerConnect or type(forumid) ~= 'number' then return false end
    -- Sanity checking
    if type(category) ~= 'string' or not categoryMap[category] then
        outputDebugString('Stats: Could not find category '..tostring(category)..'. Make sure its added to defaultValues', 1)
        return false
    elseif type(name) ~= 'string' or not statsMap[category][name] then
        outputDebugString('Stats: Could not find statName '..tostring(name)..' in category '..tostring(category)..'. Make sure its added to defaultValues', 1)
        return false
    elseif not playerStats[forumid] then
        outputDebugString('Stats: '..tostring(forumid)..' is not present in playerStats table', 1)
        return
    elseif value == nil then
        outputDebugString('Stats: saveStat() #3 argument is nil', 1)
        return false
    end
    local catIndex = categoryMap[category]
    local statIndex = statsMap[category][name]
    if increment then
        playerStats[forumid][catIndex].items[statIndex].value = playerStats[forumid][catIndex].items[statIndex].value + value
        local queryString = dbPrepareString(handlerConnect, [[
            INSERT INTO `player_stats` (forumid, category, statName, statVal) VALUES(?, ?, ?, ?) 
            ON DUPLICATE KEY UPDATE statVal = statVal + ?
        ]], forumid, category, name, value, value)
        table.insert(queryCache, queryString)
    else
        playerStats[forumid][catIndex].items[statIndex].value = value
        local queryString = dbPrepareString(handlerConnect, [[
            INSERT INTO `player_stats` (forumid, category, statName, statVal) VALUES(?, ?, ?, ?) 
            ON DUPLICATE KEY UPDATE statVal = ?
        ]], forumid, category, name, value, value)
        table.insert(queryCache, queryString)
    end
    triggerEvent('onPlayerStatsUpdated', root, forumid, category, name)
end

function getStat(idOrPlayer, statCat, statName)
    local forumid = idOrPlayer
    if isElement(idOrPlayer) and getElementType(idOrPlayer) == 'player' then
        forumid = getPlayerID(idOrPlayer)
        if not forumid then
            outputDebugString('getStat() player not logged in',1)
            return false
        end
    elseif type(idOrPlayer) == 'number' or (type(idOrPlayer) ~= 'number' and tonumber(idOrPlayer)) then
        forumid = tonumber(idOrPlayer)
    else
        outputDebugString('getStat() invalid forumid or player',1)
        return false
    end

    local catIndex = categoryMap[tostring(statCat)]
    local statIndex = statsMap[tostring(statCat)][tostring(statName)]
    if not catIndex or not statIndex then 
        outputDebugString('getStat() invalid category or stat name',1)
        return false
    end
    return playerStats[forumid] and playerStats[forumid][catIndex] and playerStats[forumid][catIndex].items[statIndex].value or false
end

-- Causes deprecated warning in console. False positive due to custom implementation
function getPlayerStat(...)
    return getStat(unpack({...}))
end
-----------------------
-- Server <-> Server --
-----------------------
local currentServer = get("*currentServer") or 'Race'


local otherServerPlayerStats = {
    -- TABLE STRUCTURE
    -- [forumid] = {
    --     ['name'] = playerName,
    --     ['gc'] = playerGC,
    --     ['vip'] = playerVIP,
    --     ['stats'] = playerStats,
    --     ['server'] = serverName,
    --     ['tops'] = tops,
    --     ['monthlyTops'] = monthlyTops
    -- }
}
function requestOtherServerStats()
    -- Request it
    local fetchServerIP = get("*fetchServerIP")
    if not fetchServerIP then return false end
    callRemote ( fetchServerIP, getResourceName(getThisResource()), "sendServerPlayerStats", receiveOtherServerStats )
end
setTimer( requestOtherServerStats, 60000, 0)
addEventHandler('onResourceStart', resourceRoot, requestOtherServerStats)

function receiveOtherServerStats(responseData, errno)
    if responseData == "ERROR" then
        outputDebugString( "callRemote: ERROR #" .. errno )
    elseif type(responseData) == 'table' then
        otherServerPlayerStats = responseData
    end
end

function sendServerPlayerStats()
    local obj = {}
    for id, stats in pairs(playerStats) do
        if forumidPlayerMap[id] and isElement(forumidPlayerMap[id]) and canExport('gc') then
            obj[id] = {}
            obj[id].name = getPlayerName(forumidPlayerMap[id]):gsub("#%x%x%x%x%x%x","")
            obj[id].gc = exports.gc:getPlayerGreencoins(forumidPlayerMap[id]) or 0
            obj[id].vip = getVipDays(exports.gc:getPlayerVip(forumidPlayerMap[id])) or false
            obj[id].stats = stats
            obj[id].server = currentServer
            obj[id].tops = playerTopTimes[id] or {}
            obj[id].topTimeMaps = playerTopTimeMaps[id] or {}
            obj[id].monthlyTops = playerMonthlyTopTimes[id] or 0
        end
    end
    return obj
end
-----------------------
-- Client <-> Server --
-----------------------
local playerListCache = false
local playerListCacheTTL = 10000 -- Time to live
local function getPlayerList()
    if playerListCache then return playerListCache end
    local list = {}
    -- Current Server
    for id, player in pairs(forumidPlayerMap) do
        if isElement(player) then
            local playerInf = {}
            playerInf.name = getPlayerName(player):gsub("#%x%x%x%x%x%x","")
            playerInf.id = id
            playerInf.server = currentServer
            table.insert(list, playerInf)
        end
    end
    -- Other Server
    for id, obj in pairs(otherServerPlayerStats) do
        local playerInf = {}
        playerInf.name = obj.name:gsub("#%x%x%x%x%x%x","")
        playerInf.id = id
        playerInf.server = obj.server
        table.insert(list, playerInf)
    end
    playerListCache = list
    setTimer(function() playerListCache = false end, playerListCacheTTL, 1)
    return playerListCache
end

addEvent('onClientRequestsStatsPlayerList', true)
addEventHandler('onClientRequestsStatsPlayerList', root, 
function() 
    if client then
        -- Send playerlist back to client
        triggerClientEvent(client, 'onServerSendsStatsPlayerList', client, getPlayerList())
    end
end)

-- Build table for client
local function sendStatsToClient(forumid)
    if not canExport('gc') or not client then
        if client then
            triggerClientEvent(client, 'onServerSendsStats', client, false)
        end
        outputDebugString('Could not access exports for GC',1)
        return false 
    end
    if isElement(forumid) and getElementType(forumid) == 'player' then
        -- forumid arg is player
        forumid = getPlayerID(forumid)
        if not forumid then
            triggerClientEvent(client, 'onServerSendsStats', client, false)
        end
    elseif not forumid then
        triggerClientEvent(client, 'onServerSendsStats', client, false)
        return false
    end
    -- First check if player is in this server, then look for other server
    if playerStats[forumid] and forumidPlayerMap[forumid] then
        -- Is in current server
        local player = forumidPlayerMap[forumid]
        local sendObj = {}
        sendObj.name = getPlayerName(player):gsub("#%x%x%x%x%x%x","")
        sendObj.gc = exports.gc:getPlayerGreencoins(player) or 0
        sendObj.vip = getVipDays(exports.gc:getPlayerVip(player)) or false
        sendObj.stats = specialFormat(table.copy(playerStats[forumid]))
        sendObj.tops = playerTopTimes[forumid] or {}
        sendObj.topTimeMaps = playerTopTimeMaps[forumid] or {}
        sendObj.monthlyTops = playerMonthlyTopTimes[forumid] or 0
        triggerClientEvent(client, 'onServerSendsStats', client, sendObj, player)
    elseif otherServerPlayerStats[tostring(forumid)] then
        -- Is player in other server
        local sendObj = {}
        sendObj.name = otherServerPlayerStats[tostring(forumid)].name
        sendObj.gc = otherServerPlayerStats[tostring(forumid)].gc
        sendObj.vip = otherServerPlayerStats[tostring(forumid)].vip
        sendObj.stats = specialFormat(table.copy(otherServerPlayerStats[tostring(forumid)].stats))
        sendObj.tops = otherServerPlayerStats[tostring(forumid)].tops
        sendObj.monthlyTops = otherServerPlayerStats[tostring(forumid)].monthlyTops
        triggerClientEvent(client, 'onServerSendsStats', client, sendObj)
    else
        -- No player found with requested ID
        triggerClientEvent(client, 'onServerSendsStats', client, false)
    end

end
addEvent('onClientRequestsStats', true)
addEventHandler('onClientRequestsStats', resourceRoot, sendStatsToClient)

function sendTopTimeMapsToClient(forumid, raceMode, position)
    if isElement(forumid) and getElementType(forumid) == 'player' then
        forumid = getPlayerID(forumid)
        if not forumid then
            triggerClientEvent(client, 'onServerSendsTopTimeMaps', client, false)
        end
    elseif not forumid then
        triggerClientEvent(client, 'onServerSendsTopTimeMaps', client, false)
        return false
    end

    local validRacemodes = {
        ['nts'] = true,
        ['race'] = true,
        ['rtf'] = true,
        ['dl'] = true,
        ['sh'] = true,
        ['dd'] = true
    }
    if not raceMode or not tonumber(position) or not validRacemodes[raceMode] then
        triggerClientEvent(client, 'onServerSendsTopTimeMaps', client, false)
        return false
    end

    forumid = 'f' .. forumid
    if not playerTopTimeMaps[forumid] or not playerTopTimeMaps[forumid][raceMode]
        or not playerTopTimeMaps[forumid][raceMode]['pos' .. position] then
        outputDebugString("Missing or undefined top time data (forumid: " .. tostring(forumid) ..
            ", raceMode: " .. tostring(raceMode) ..
            ", position: " .. tostring(position) .. ")", 1)
        triggerClientEvent(client, 'onServerSendsTopTimeMaps', client, false)
        return false
    end

    triggerClientEvent(client, 'onServerSendsTopTimeMaps', client,
        playerTopTimeMaps[forumid][raceMode]['pos' .. position] or {})
end

addEvent('onClientRequestsTopTimeMaps', true)
addEventHandler('onClientRequestsTopTimeMaps', resourceRoot, sendTopTimeMapsToClient)

-----------
-- Other --
-----------
function setJoinDate(id)
    if not getStat(id, 'General', 'Join Date') and forumidPlayerMap[id] then
        saveStat(id, 'General', 'Join Date', exports.gc:getPlayerForumJoinTimestamp(forumidPlayerMap[id]))
    end
end
addEvent('onPlayerStatsLoaded')
addEventHandler('onPlayerStatsLoaded', resourceRoot, setJoinDate)

local rankFetch = {
    ['race'] = 'Race',
    ['nts'] = 'Never The Same',
    ['dl'] = 'DeadLine',
    ['sh'] = 'Shooter',
    ['rtf'] = 'Reach The Flag',
    ['dd'] = 'Destruction Derby'
}

local rankQueryString = [[
    SELECT FIND_IN_SET( ??, (    
    SELECT GROUP_CONCAT( ??
    ORDER BY ?? DESC, forumid ASC ) 
    FROM leaderboards )
    ) AS rank
    FROM leaderboards
    WHERE forumid =  ?
]]

function setTotalRanking(id)
    if not handlerConnect then return end
    for abbr, full in pairs(rankFetch) do
        dbQuery( 
            function(qh)
                local res = dbPoll( qh, 0 )
                if not res or #res ~= 1 or not res[1] or type(res[1].rank) ~= 'number' then return end
                saveStat(id, full, 'Total Rank', res[1].rank)
            end, 
        handlerConnect, rankQueryString, abbr, abbr, abbr, id)
    end
end
addEventHandler('onPlayerStatsLoaded', resourceRoot, setTotalRanking)

local topOnesQueryString = [[
    SELECT COUNT(*) as amount FROM `toptimes` WHERE forumid = ? AND racemode = ? AND pos = 1
]]
function setTopOnes(id)
    if not handlerConnect then return end
    for abbr, full in pairs(rankFetch) do
        dbQuery( 
            function(qh) 
                local res = dbPoll( qh, 0 )
                if not res or #res ~= 1 or not res[1] or type(res[1].amount) ~= 'number' then return end
                saveStat(id, full, "Top 1's", res[1].amount)
            end, 
        handlerConnect, topOnesQueryString, id, abbr)
    end
end
addEventHandler('onPlayerStatsLoaded', resourceRoot, setTopOnes)

function fetchMonthlyTops(id)
    if not handlerConnect or not id or not tonumber(id) then return end
    local currentMonth = getRealTime().month + 1
    -- To make sure we are not getting last year's monthly top, we should make a minimum timestamp
    local timeStampMinimum = getRealTime().timestamp - 5184000
    local fetchMonthTopsString = [[
        SELECT
            COUNT(*) amount
        FROM
            `toptimes_month`
        WHERE
            `forumid` = ? AND `month` = ? AND `date` > ? AND `rewarded` = 0;
    ]]
    dbQuery(
        function(qh)
            local res = dbPoll( qh, 0 )
            if type(res) == 'table' and res[1] and res[1].amount then
                playerMonthlyTopTimes[id] = res[1].amount
            end
        end,
    handlerConnect, fetchMonthTopsString, id, currentMonth, timeStampMinimum)
end

function fetchTopTimeMaps(forumid)
    if not handlerConnect or not forumid or not tonumber(forumid) then return end

    local fetchTopTimeMapsString = [[
        SELECT
            `m`.`mapname`,
            `m`.`resname`,
            `tt`.`date`,
            `tt`.`value`,
            `tt`.`pos`,
            `tt`.`racemode`
        FROM
            `toptimes` tt
        INNER JOIN `maps` m ON `m`.`resname` = `tt`.`mapname`
        WHERE
            `tt`.`forumid` = ? AND
            `tt`.`pos` > 0 AND
            `tt`.`pos` < 11
        ORDER BY `tt`.`date` DESC;
    ]]
    dbQuery(
        function(qh)
            local res = dbPoll(qh, 0)
            local forumidWithPrefix = 'f' .. forumid
            local tempTable = {}
            for _, row in ipairs(res) do
                if type(row.mapname) == 'string' and type(row.resname) == 'string' and type(row.date) == 'number' and
                    type(row.value) == 'number' and type(row.pos) == 'number' and type(row.racemode) == 'string' then
                    local fullNames = {
                        ['nts'] = 'Never The Same',
                        ['race'] = 'Race',
                        ['rtf'] = 'Reach The Flag',
                        ['dl'] = 'DeadLine',
                        ['sh'] = 'Shooter',
                        ['dd'] = 'Destruction Derby'
                    }
                    local positionWithPrefix = 'pos' .. row.pos

                    tempTable[row.racemode] = tempTable[row.racemode] or {}
                    tempTable[row.racemode][positionWithPrefix] = tempTable[row.racemode][positionWithPrefix] or {
                        racemode = fullNames[row.racemode],
                        pos = row.pos,
                        items = {}
                    }

                    table.insert(tempTable[row.racemode][positionWithPrefix].items, {
                        mapname = row.mapname,
                        resname = row.resname,
                        date = row.date,
                        value = row.value,
                        disabled = not getResourceFromName(row.resname)
                    })
                end
            end

            playerTopTimeMaps[forumidWithPrefix] = tempTable
        end,
        handlerConnect, fetchTopTimeMapsString, forumid)
end

function fetchTopTimes(id)
    if not handlerConnect or not id or not tonumber(id) then return end
    local fetchTopsString = [[
        SELECT
            `racemode`,
            `pos`
        FROM
            `toptimes`
        WHERE
            `forumid` = ? AND `pos` < 11 AND(
                `racemode` = 'sh' OR `racemode` = 'dd' OR `racemode` = 'dl' OR `racemode` = 'race' OR `racemode` = 'rtf' OR `racemode` = 'nts'
            );
    ]]
    dbQuery(
        function (qh)
            local res = dbPoll( qh, 0 )
            local resTable = {}
            resTable["Total"] = {}
            resTable["Total"]["Total"] = 0

            local fullNames = {
                ['nts'] = 'Never The Same',
                ['race'] = 'Race',
                ['rtf'] = 'Reach The Flag',
                ['dl'] = 'DeadLine',
                ['sh'] = 'Shooter',
                ['dd'] = 'Destruction Derby'
            }
            for i, row in ipairs(res) do
                
                if type(row.pos) == 'number' and type(row.racemode) == 'string' and fullNames[row.racemode] then
                    local fullRacemodeName = fullNames[row.racemode]
                    if type(resTable[fullRacemodeName]) ~= 'table' then
                        resTable[fullRacemodeName] = {}
                    end
                    if type(resTable[fullRacemodeName][row.pos]) ~= 'number' then
                        resTable[fullRacemodeName][row.pos] = 0
                    end
                    if type(resTable[fullRacemodeName]["Total"]) ~= 'number' then
                        resTable[fullRacemodeName]["Total"] = 0
                    end
                    if type(resTable["Total"][row.pos]) ~= 'number' then
                        resTable["Total"][row.pos] = 0
                    end
                    
                    -- Set values
                    resTable[fullRacemodeName][row.pos] = resTable[fullRacemodeName][row.pos] + 1
                    resTable[fullRacemodeName]["Total"] = resTable[fullRacemodeName]["Total"] + 1
                    resTable["Total"]["Total"] = resTable["Total"]["Total"] + 1
                    resTable["Total"][row.pos] = resTable["Total"][row.pos] + 1
                end
            end

            local topTimesCatsOrder = {'Total', 'Race', 'Never The Same', 'Shooter', 'Destruction Derby', 'DeadLine', 'Reach The Flag'}
            local formattedTops = {}
            for i, catName in ipairs(topTimesCatsOrder) do
                local itemsTable = {}
                for i = 1, 11 do
                    local n = 'Top '..(i-1)
                    if i == 1 then
                        n = 'Total'
                    end
                    local resKey = i > 1 and i-1 or 'Total'
                    if not resTable[catName] then
                        resTable[catName] = {}
                    end
                    if not resTable[catName][resKey] then
                        resTable[catName][resKey] = 0
                    end
                    local resVal = resTable[catName][resKey] or 0
                    table.insert(itemsTable, {name = n, value = resVal})
                end
                table.insert(formattedTops, {name = catName, items = itemsTable})
            end
            playerTopTimes[id] = formattedTops
        end,
    handlerConnect, fetchTopsString, id)
end


-- Set timer to refetch top 1's and ranking
local topRankingRefetchTime = 600000
setTimer(
    function()
        if not handlerConnect then return end
        for id, _ in pairs(playerStats) do
            setTopOnes(id)
            setTotalRanking(id)
            fetchTopTimes(id)
            fetchTopTimeMaps(id)
            fetchMonthlyTops(id)
        end
    end, 
topRankingRefetchTime, 0)

----------------------------
-- GC Logged in/out state --
----------------------------
addEvent('onClientRequestsStatsLoggedInState', true)
addEvent('onGCLogin')
addEvent('onGCLogout')
function sendClientLoggedInState(player, bool)
    if type(bool) == 'boolean' then
        triggerClientEvent(player, 'onServerSendStatsLogedInState', player, bool)
    elseif canExport('gc') then
        triggerClientEvent(player, 'onServerSendStatsLogedInState', player, exports.gc:isPlayerLoggedInGC(player))
    else
        triggerClientEvent(player, 'onServerSendStatsLogedInState', player, false)
    end
end
addEventHandler('onClientRequestsStatsLoggedInState', resourceRoot, function() if client then sendClientLoggedInState(client) end end)
addEventHandler("onGCLogin" , root, function() if getElementType(source) == 'player' then sendClientLoggedInState(source) end end)
addEventHandler("onGCLogout" , root, function() if getElementType(source) == 'player' then sendClientLoggedInState(source) end end)