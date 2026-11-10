local TOP_LIMIT = 10

local MONTHLY_REWARDS = {
    [1] = 2000,
    [2] = 1500,
    [3] = 1000,
}

local YEARLY_REWARD_GC = 5000

local function detectServerType()
    local s = get("*race_toptimes.server") or get("*mrgreen-stats.currentServer") or get("*interchat.this_server") or "mix"
    if type(s) == "string" and s:lower() == "race" then
        return "race"
    end
    return "mix"
end

local SERVER_TYPE = detectServerType()

local allModeConfigs = {
    race = {
        { key = "race", category = "Race", lbCol = "race", topMode = "race" },
    },
    mix = {
        { key = "general", category = "General" },
        { key = "nts",     category = "Never The Same",    lbCol = "nts", topMode = "nts" },
        { key = "rtf",     category = "Reach The Flag",    lbCol = "rtf", topMode = "rtf" },
        { key = "dd",      category = "Destruction Derby", lbCol = "dd",  topMode = "dd"  },
        { key = "sh",      category = "Shooter",           lbCol = "sh",  topMode = "sh"  },
        { key = "dl",      category = "DeadLine",          lbCol = "dl",  topMode = "dl"  },
        { key = "ctf",     category = "Capture The Flag" },
    }
}

local allMonthlyModes = {
    race = {
        { key = "race", name = "Race" },
    },
    mix = {
        { key = "nts", name = "Never The Same" },
        { key = "rtf", name = "Reach The Flag" },
    }
}

local modeConfigs = allModeConfigs[SERVER_TYPE]
local monthlyModes = allMonthlyModes[SERVER_TYPE]

local monthNames = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

local cachedTopLists = nil
local isCacheReady = false
local pendingClients = {}

local cachedPlayerRanks = {}

local function cleanNick(name, forumid)
    if type(name) == "string" and #name > 0 then
        local stripped = name:gsub("#%x%x%x%x%x%x", "")
        if #stripped > 0 then
            return stripped
        end
        return name
    end
    return "Player #" .. tostring(forumid)
end

local function formatKD(kills, deaths)
    local k = tonumber(kills) or 0
    local d = tonumber(deaths) or 0
    if k == 0 and d == 0 then
        return "0"
    elseif d == 0 then
        return "Perfect"
    end
    return tostring(math.floor((k / d) * 10 + 0.5) / 10)
end

local function formatWinRatio(wins, starts)
    local w = tonumber(wins) or 0
    local s = tonumber(starts) or 0
    if s <= 0 or w <= 0 then
        return "0%"
    end
    local pct = math.floor((w / s) * 1000 + 0.5) / 10
    if pct > 100 then pct = 100 end
    return tostring(pct) .. "%"
end

local function getPreviousMonthInfo()
    local rt = getRealTime()
    local curYear = rt.year + 1900
    local curMonth = rt.month + 1
    local prevMonth = curMonth - 1
    local prevYear = curYear
    if prevMonth < 1 then
        prevMonth = 12
        prevYear = curYear - 1
    end
    local ymKey = string.format("%04d-%02d", prevYear, prevMonth)
    return prevYear, prevMonth, ymKey, curYear, curMonth
end

local function getStatNum(catStats, catName, statName)
    if catStats and catStats[catName] and catStats[catName][statName] then
        return tonumber(catStats[catName][statName]) or 0
    end
    return 0
end

local function buildRowForMode(modeKey, rank, forumid, name, statsByCat, topsByMode)
    local catStats = statsByCat or {}
    local tops = topsByMode or {}
    local playerName = cleanNick(name, forumid)

    if modeKey == "general" then
        local mixWins = getStatNum(catStats, "Never The Same", "Wins")
                      + getStatNum(catStats, "Reach The Flag", "Wins")
                      + getStatNum(catStats, "Destruction Derby", "Wins")
                      + getStatNum(catStats, "Shooter", "Wins")
                      + getStatNum(catStats, "DeadLine", "Wins")

        local mixTop1 = (tonumber(tops["nts"]) or getStatNum(catStats, "Never The Same", "Top 1's"))
                      + (tonumber(tops["rtf"]) or getStatNum(catStats, "Reach The Flag", "Top 1's"))
                      + (tonumber(tops["dd"])  or getStatNum(catStats, "Destruction Derby", "Top 1's"))
                      + (tonumber(tops["sh"])  or getStatNum(catStats, "Shooter", "Top 1's"))
                      + (tonumber(tops["dl"])  or getStatNum(catStats, "DeadLine", "Top 1's"))

        local mixKills = getStatNum(catStats, "Destruction Derby", "Kills")
                       + getStatNum(catStats, "Shooter", "Kills")
                       + getStatNum(catStats, "DeadLine", "Kills")

        local mixDeaths = getStatNum(catStats, "Destruction Derby", "Deaths")
                        + getStatNum(catStats, "Shooter", "Deaths")
                        + getStatNum(catStats, "DeadLine", "Deaths")

        local ctfFlags = getStatNum(catStats, "Capture The Flag", "Flags Delivered")

        return {
            rank = rank,
            forumid = forumid,
            name = playerName,
            cols = { tostring(mixWins), tostring(mixTop1), tostring(mixKills), tostring(mixDeaths), tostring(ctfFlags) }
        }
    elseif modeKey == "race" or modeKey == "nts" then
        local catName = (modeKey == "race") and "Race" or "Never The Same"
        local st = catStats[catName] or {}
        local top1s = tonumber(tops[modeKey]) or tonumber(st["Top 1's"]) or 0
        local wins = tonumber(st["Wins"]) or 0
        local finishes = tonumber(st["Finishes"]) or 0
        local starts = tonumber(st["Starts"]) or 0
        return {
            rank = rank,
            forumid = forumid,
            name = playerName,
            cols = { tostring(top1s), tostring(wins), tostring(finishes), tostring(starts), formatWinRatio(wins, starts) }
        }
    elseif modeKey == "dd" or modeKey == "sh" or modeKey == "dl" then
        local catMap = { dd = "Destruction Derby", sh = "Shooter", dl = "DeadLine" }
        local st = catStats[catMap[modeKey]] or {}
        local top1s = tonumber(tops[modeKey]) or tonumber(st["Top 1's"]) or 0
        local wins = tonumber(st["Wins"]) or 0
        local kills = tonumber(st["Kills"]) or 0
        local deaths = tonumber(st["Deaths"]) or 0
        return {
            rank = rank,
            forumid = forumid,
            name = playerName,
            cols = { tostring(top1s), tostring(wins), tostring(kills), tostring(deaths), formatKD(kills, deaths) }
        }
    elseif modeKey == "rtf" then
        local st = catStats["Reach The Flag"] or {}
        local top1s = tonumber(tops["rtf"]) or tonumber(st["Top 1's"]) or 0
        local wins = tonumber(st["Wins"]) or 0
        local starts = tonumber(st["Starts"]) or 0
        return {
            rank = rank,
            forumid = forumid,
            name = playerName,
            cols = { tostring(top1s), tostring(wins), tostring(starts), formatWinRatio(wins, starts) }
        }
    elseif modeKey == "ctf" then
        local st = catStats["Capture The Flag"] or {}
        local flags = tonumber(st["Flags Delivered"]) or 0
        return {
            rank = rank,
            forumid = forumid,
            name = playerName,
            cols = { tostring(flags) }
        }
    end
end

local function initRewardTablesAndSnapshots()
    if not handlerConnect then return end

    dbExec(handlerConnect, [[
        CREATE TABLE IF NOT EXISTS `rankboard_monthly_rewards` (
            `year_month` VARCHAR(7) NOT NULL,
            `racemode` VARCHAR(10) NOT NULL,
            `pos` TINYINT(2) NOT NULL,
            `forumid` INT(11) NOT NULL,
            `tops_count` INT(11) NOT NULL DEFAULT 0,
            `reward_gc` INT(11) NOT NULL DEFAULT 0,
            `rewarded` TINYINT(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`year_month`, `racemode`, `pos`),
            INDEX `idx_monthly_forumid` (`forumid`, `rewarded`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    dbExec(handlerConnect, [[
        CREATE TABLE IF NOT EXISTS `rankboard_yearly_rewards` (
            `year` INT(4) NOT NULL,
            `racemode` VARCHAR(10) NOT NULL,
            `forumid` INT(11) NOT NULL,
            `reward_gc` INT(11) NOT NULL DEFAULT 5000,
            `rewarded` TINYINT(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`year`, `racemode`),
            INDEX `idx_yearly_forumid` (`forumid`, `rewarded`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    local _, prevMonth, prevYMKey, curYear, curMonth = getPreviousMonthInfo()
    local minTimePrevMonth = getRealTime().timestamp - 5616000

    for _, m in ipairs(monthlyModes) do
        local modeKey = m.key
        dbQuery(function(qh)
            local existing = dbPoll(qh, 0)
            if existing and #existing == 0 then
                local top3SQL = [[
                    SELECT tm.forumid, COUNT(*) AS cnt
                    FROM `toptimes_month` tm
                    INNER JOIN `maps` mp ON mp.resname = tm.mapname
                    WHERE tm.month = ? AND tm.date > ? AND mp.racemode = ?
                    GROUP BY tm.forumid
                    ORDER BY cnt DESC, MAX(tm.date) ASC, tm.forumid ASC
                    LIMIT 3
                ]]
                dbQuery(function(qh2)
                    local winners = dbPoll(qh2, 0)
                    if winners and #winners > 0 then
                        for pos, w in ipairs(winners) do
                            local gcPrize = MONTHLY_REWARDS[pos] or 0
                            local fid = tonumber(w.forumid)
                            local cnt = tonumber(w.cnt) or 0
                            if fid and gcPrize > 0 and cnt > 0 then
                                dbExec(
                                    handlerConnect,
                                    "INSERT IGNORE INTO `rankboard_monthly_rewards` (`year_month`, `racemode`, `pos`, `forumid`, `tops_count`, `reward_gc`, `rewarded`) VALUES (?, ?, ?, ?, ?, ?, 0)",
                                    prevYMKey, modeKey, pos, fid, cnt, gcPrize
                                )
                            end
                        end
                    end
                end, handlerConnect, top3SQL, prevMonth, minTimePrevMonth, modeKey)
            end
        end, handlerConnect, "SELECT pos FROM `rankboard_monthly_rewards` WHERE `year_month` = ? AND `racemode` = ? LIMIT 1", prevYMKey, modeKey)
    end

    if curMonth == 1 then
        for _, m in ipairs(monthlyModes) do
            local modeKey = m.key
            dbQuery(function(qh)
                local existing = dbPoll(qh, 0)
                if existing and #existing == 0 then
                    local q = string.format(
                        "SELECT forumid FROM `leaderboards` WHERE `%s` > 0 ORDER BY `%s` DESC, forumid ASC LIMIT 1",
                        modeKey, modeKey
                    )
                    dbQuery(function(qh2)
                        local top1 = dbPoll(qh2, 0)
                        if top1 and top1[1] and tonumber(top1[1].forumid) then
                            dbExec(
                                handlerConnect,
                                "INSERT IGNORE INTO `rankboard_yearly_rewards` (`year`, `racemode`, `forumid`, `reward_gc`, `rewarded`) VALUES (?, ?, ?, ?, 0)",
                                curYear, modeKey, tonumber(top1[1].forumid), YEARLY_REWARD_GC
                            )
                        end
                    end, handlerConnect, q)
                end
            end, handlerConnect, "SELECT forumid FROM `rankboard_yearly_rewards` WHERE `year` = ? AND `racemode` = ? LIMIT 1", curYear, modeKey)
        end
    end
end

local function loadInitialRankboards()
    if not handlerConnect then return end

    initRewardTablesAndSnapshots()

    local rawTopLists = {}
    local rawMonthlyLists = {}
    local uniqueForumIDs = {}
    local forumIDList = {}
    local pendingQueries = #modeConfigs + #monthlyModes

    local function addForumID(fid)
        fid = tonumber(fid)
        if fid and not uniqueForumIDs[fid] then
            uniqueForumIDs[fid] = true
            table.insert(forumIDList, fid)
        end
    end

    local function onAllModeTopsFetched()
        if #forumIDList == 0 then
            cachedTopLists = { serverType = SERVER_TYPE, monthly = {} }
            for _, cfg in ipairs(modeConfigs) do
                cachedTopLists[cfg.key] = {}
            end
            for _, m in ipairs(monthlyModes) do
                cachedTopLists.monthly[m.key] = {}
            end
            isCacheReady = true
            for player, _ in pairs(pendingClients) do
                if isElement(player) then
                    triggerClientEvent(player, "onClientReceiveRankboardTop10", resourceRoot, cachedTopLists)
                end
            end
            pendingClients = {}
            return
        end

        local idListStr = table.concat(forumIDList, ",")
        local namesByID = {}
        local statsByID = {}
        local topsByID = {}
        local subQueriesRemaining = 3

        local function finalizeCache()
            subQueriesRemaining = subQueriesRemaining - 1
            if subQueriesRemaining > 0 then return end

            cachedTopLists = { serverType = SERVER_TYPE, monthly = {} }
            for _, cfg in ipairs(modeConfigs) do
                local modeKey = cfg.key
                cachedTopLists[modeKey] = {}
                local rows = rawTopLists[modeKey] or {}
                for rankIndex, entry in ipairs(rows) do
                    local fid = tonumber(entry.forumid)
                    local name = namesByID[fid]
                    local pStats = statsByID[fid] or {}
                    local pTops = topsByID[fid] or {}
                    if modeKey == "ctf" and entry.flags then
                        pStats["Capture The Flag"] = pStats["Capture The Flag"] or {}
                        pStats["Capture The Flag"]["Flags Delivered"] = entry.flags
                    end
                    table.insert(
                        cachedTopLists[modeKey],
                        buildRowForMode(modeKey, rankIndex, fid, name, pStats, pTops)
                    )
                end
            end

            for _, m in ipairs(monthlyModes) do
                local mKey = m.key
                cachedTopLists.monthly[mKey] = {}
                local rows = rawMonthlyLists[mKey] or {}
                for rankIndex, entry in ipairs(rows) do
                    local fid = tonumber(entry.forumid)
                    local cnt = tonumber(entry.cnt) or 0
                    table.insert(cachedTopLists.monthly[mKey], {
                        rank = rankIndex,
                        forumid = fid,
                        name = cleanNick(namesByID[fid], fid),
                        cols = { tostring(cnt) }
                    })
                end
            end

            isCacheReady = true
            for player, _ in pairs(pendingClients) do
                if isElement(player) then
                    triggerClientEvent(player, "onClientReceiveRankboardTop10", resourceRoot, cachedTopLists)
                end
            end
            pendingClients = {}
        end

        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            if res then
                for _, r in ipairs(res) do
                    namesByID[tonumber(r.forumid)] = r.name
                end
            end
            finalizeCache()
        end, handlerConnect, "SELECT forumid, name FROM gc_nickcache WHERE forumid IN (" .. idListStr .. ")")

        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            if res then
                for _, r in ipairs(res) do
                    local fid = tonumber(r.forumid)
                    if fid then
                        statsByID[fid] = statsByID[fid] or {}
                        statsByID[fid][tostring(r.category)] = statsByID[fid][tostring(r.category)] or {}
                        statsByID[fid][tostring(r.category)][tostring(r.statName)] = r.statVal
                    end
                end
            end
            finalizeCache()
        end, handlerConnect, "SELECT forumid, category, statName, statVal FROM player_stats WHERE forumid IN (" .. idListStr .. ")")

        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            if res then
                for _, r in ipairs(res) do
                    local fid = tonumber(r.forumid)
                    local mode = tostring(r.racemode)
                    local cnt = tonumber(r.cnt) or 0
                    if fid then
                        topsByID[fid] = topsByID[fid] or {}
                        topsByID[fid][mode] = cnt
                    end
                end
            end
            finalizeCache()
        end, handlerConnect, "SELECT forumid, racemode, COUNT(*) AS cnt FROM toptimes WHERE forumid IN (" .. idListStr .. ") AND pos = 1 GROUP BY forumid, racemode")
    end

    for _, cfg in ipairs(modeConfigs) do
        local modeKey = cfg.key
        local q
        if cfg.lbCol then
            q = string.format(
                "SELECT forumid FROM leaderboards ORDER BY `%s` DESC, forumid ASC LIMIT %d",
                cfg.lbCol, TOP_LIMIT
            )
        elseif modeKey == "general" then
            q = string.format(
                "SELECT forumid FROM leaderboards ORDER BY (nts + rtf + dd + sh + dl) DESC, forumid ASC LIMIT %d",
                TOP_LIMIT
            )
        elseif modeKey == "ctf" then
            q = string.format(
                "SELECT forumid, CAST(statVal AS UNSIGNED) AS flags FROM player_stats WHERE category = 'Capture The Flag' AND statName = 'Flags Delivered' ORDER BY flags DESC, forumid ASC LIMIT %d",
                TOP_LIMIT
            )
        end

        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            rawTopLists[modeKey] = res or {}
            if res then
                for _, r in ipairs(res) do
                    addForumID(r.forumid)
                end
            end
            pendingQueries = pendingQueries - 1
            if pendingQueries == 0 then
                onAllModeTopsFetched()
            end
        end, handlerConnect, q)
    end

    local curMonth = getRealTime().month + 1
    local minTimeCurMonth = getRealTime().timestamp - 5184000
    for _, m in ipairs(monthlyModes) do
        local mKey = m.key
        local mSQL = [[
            SELECT tm.forumid, COUNT(*) AS cnt
            FROM `toptimes_month` tm
            INNER JOIN `maps` mp ON mp.resname = tm.mapname
            WHERE tm.month = ? AND tm.date > ? AND mp.racemode = ?
            GROUP BY tm.forumid
            ORDER BY cnt DESC, MAX(tm.date) ASC, tm.forumid ASC
            LIMIT ?
        ]]
        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            rawMonthlyLists[mKey] = res or {}
            if res then
                for _, r in ipairs(res) do
                    addForumID(r.forumid)
                end
            end
            pendingQueries = pendingQueries - 1
            if pendingQueries == 0 then
                onAllModeTopsFetched()
            end
        end, handlerConnect, mSQL, curMonth, minTimeCurMonth, mKey, TOP_LIMIT)
    end
end

addEventHandler("shopStarted", resourceRoot, loadInitialRankboards)

addEventHandler("onShopInit", root, function()
    local player = client
    if not isElement(player) then return end
    if isCacheReady and cachedTopLists then
        triggerClientEvent(player, "onClientReceiveRankboardTop10", resourceRoot, cachedTopLists)
    else
        pendingClients[player] = true
    end
end)

addEventHandler("onPlayerQuit", root, function()
    pendingClients[source] = nil
end)

local modeDisplayNames = {
    race = "Race",
    nts  = "Never The Same",
    rtf  = "Reach The Flag",
}

local function getServerModeListSQL()
    local parts = {}
    for _, m in ipairs(monthlyModes) do
        table.insert(parts, "'" .. m.key .. "'")
    end
    return table.concat(parts, ",")
end

local function checkAndGrantRankboardRewards(player, forumID)
    forumID = tonumber(forumID)
    if not forumID or not isElement(player) or not handlerConnect then return end

    local modeFilterSQL = getServerModeListSQL()

    dbQuery(function(qh)
        local yearlyWins = dbPoll(qh, 0)
        if not isElement(player) then return end
        if yearlyWins and #yearlyWins > 0 then
            dbExec(handlerConnect, "UPDATE `rankboard_yearly_rewards` SET `rewarded` = 1 WHERE `forumid` = ? AND `rewarded` = 0 AND `racemode` IN (" .. modeFilterSQL .. ")", forumID)
            for _, row in ipairs(yearlyWins) do
                local gcAmount = tonumber(row.reward_gc) or YEARLY_REWARD_GC
                local mName = modeDisplayNames[row.racemode] or tostring(row.racemode)
                local yearWon = tostring(row.year or "")
                if gcAmount > 0 then
                    exports.gc:addPlayerGreencoins(player, gcAmount)
                    outputChatBox(
                        string.format("[GC] Happy New Year! For being #1 in %s All-Time Rankboard (%s), you won %d GC!", mName, yearWon, gcAmount),
                        player, 0, 255, 0, true
                    )
                end
            end
        end
    end, handlerConnect, "SELECT `year`, `racemode`, `reward_gc` FROM `rankboard_yearly_rewards` WHERE `forumid` = ? AND `rewarded` = 0 AND `racemode` IN (" .. modeFilterSQL .. ")", forumID)

    dbQuery(function(qh)
        local monthlyWins = dbPoll(qh, 0)
        if not isElement(player) then return end
        if monthlyWins and #monthlyWins > 0 then
            dbExec(handlerConnect, "UPDATE `rankboard_monthly_rewards` SET `rewarded` = 1 WHERE `forumid` = ? AND `rewarded` = 0 AND `racemode` IN (" .. modeFilterSQL .. ")", forumID)
            for _, row in ipairs(monthlyWins) do
                local gcAmount = tonumber(row.reward_gc) or 0
                local pos = tonumber(row.pos) or 1
                local cnt = tonumber(row.tops_count) or 0
                local mName = modeDisplayNames[row.racemode] or tostring(row.racemode)
                local ym = tostring(row.year_month or "")
                local mNum = tonumber(ym:sub(6, 7))
                local mLabel = (mNum and monthNames[mNum]) and (monthNames[mNum] .. " " .. ym:sub(1, 4)) or ym

                if gcAmount > 0 then
                    exports.gc:addPlayerGreencoins(player, gcAmount)
                    outputChatBox(
                        string.format("[GC] You finished #%d in %s Monthly Rankboard (%s) with %d top(s) and won %d GC!", pos, mName, mLabel, cnt, gcAmount),
                        player, 0, 255, 0, true
                    )
                end
            end
        end
    end, handlerConnect, "SELECT `year_month`, `racemode`, `pos`, `tops_count`, `reward_gc` FROM `rankboard_monthly_rewards` WHERE `forumid` = ? AND `rewarded` = 0 AND `racemode` IN (" .. modeFilterSQL .. ") ORDER BY `year_month` ASC, `pos` ASC", forumID)
end

local function sendPlayerOwnRanks(player, forumID)
    forumID = tonumber(forumID)
    if not forumID or not isElement(player) or not handlerConnect then return end

    local pName = getPlayerName(player)

    if cachedPlayerRanks[forumID] then
        for k, row in pairs(cachedPlayerRanks[forumID]) do
            if k == "monthly" then
                for _, mRow in pairs(row) do
                    mRow.name = cleanNick(pName, forumID)
                end
            elseif type(row) == "table" then
                row.name = cleanNick(pName, forumID)
            end
        end
        triggerClientEvent(player, "onClientReceiveOwnRankboard", resourceRoot, cachedPlayerRanks[forumID])
        return
    end

    local ranksByMode = {}
    local statsByCat = {}
    local topsByMode = {}
    local monthlyOwn = {}
    local remaining = (SERVER_TYPE == "race" and 3 or 4) + #monthlyModes

    local function onPlayerDataComplete()
        remaining = remaining - 1
        if remaining > 0 then return end

        local ownData = { monthly = {} }
        for _, cfg in ipairs(modeConfigs) do
            local mKey = cfg.key
            local rnk = ranksByMode[mKey] or "-"
            ownData[mKey] = buildRowForMode(mKey, rnk, forumID, pName, statsByCat, topsByMode)
        end

        for _, m in ipairs(monthlyModes) do
            local mKey = m.key
            local info = monthlyOwn[mKey] or { rank = "-", cnt = 0 }
            ownData.monthly[mKey] = {
                rank = info.rank,
                forumid = forumID,
                name = cleanNick(pName, forumID),
                cols = { tostring(info.cnt) }
            }
        end

        cachedPlayerRanks[forumID] = ownData
        if isElement(player) then
            triggerClientEvent(player, "onClientReceiveOwnRankboard", resourceRoot, ownData)
        end
    end

    if SERVER_TYPE == "race" then
        local raceRankSQL = [[
            SELECT (SELECT COUNT(*) + 1 FROM leaderboards WHERE race > l.race) AS race_rank
            FROM leaderboards l
            WHERE l.forumid = ?
        ]]
        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            if res and res[1] then
                ranksByMode["race"] = tonumber(res[1].race_rank) or "-"
            end
            onPlayerDataComplete()
        end, handlerConnect, raceRankSQL, forumID)
    else
        local mixRankSQL = [[
            SELECT
                (SELECT COUNT(*) + 1 FROM leaderboards WHERE (nts+rtf+dd+sh+dl) > (l.nts+l.rtf+l.dd+l.sh+l.dl)) AS general_rank,
                (SELECT COUNT(*) + 1 FROM leaderboards WHERE nts > l.nts) AS nts_rank,
                (SELECT COUNT(*) + 1 FROM leaderboards WHERE rtf > l.rtf) AS rtf_rank,
                (SELECT COUNT(*) + 1 FROM leaderboards WHERE dd > l.dd) AS dd_rank,
                (SELECT COUNT(*) + 1 FROM leaderboards WHERE sh > l.sh) AS sh_rank,
                (SELECT COUNT(*) + 1 FROM leaderboards WHERE dl > l.dl) AS dl_rank
            FROM leaderboards l
            WHERE l.forumid = ?
        ]]
        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            if res and res[1] then
                ranksByMode["general"] = tonumber(res[1].general_rank) or "-"
                ranksByMode["nts"]     = tonumber(res[1].nts_rank) or "-"
                ranksByMode["rtf"]     = tonumber(res[1].rtf_rank) or "-"
                ranksByMode["dd"]      = tonumber(res[1].dd_rank) or "-"
                ranksByMode["sh"]      = tonumber(res[1].sh_rank) or "-"
                ranksByMode["dl"]      = tonumber(res[1].dl_rank) or "-"
            end
            onPlayerDataComplete()
        end, handlerConnect, mixRankSQL, forumID)

        local ctfRankSQL = [[
            SELECT COUNT(*) + 1 AS ctf_rank
            FROM player_stats
            WHERE category = 'Capture The Flag'
              AND statName = 'Flags Delivered'
              AND CAST(statVal AS UNSIGNED) > (
                  SELECT COALESCE(MAX(CAST(statVal AS UNSIGNED)), 0)
                  FROM player_stats
                  WHERE forumid = ? AND category = 'Capture The Flag' AND statName = 'Flags Delivered'
              )
        ]]
        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            if res and res[1] and res[1].ctf_rank then
                ranksByMode["ctf"] = tonumber(res[1].ctf_rank) or "-"
            end
            onPlayerDataComplete()
        end, handlerConnect, ctfRankSQL, forumID)
    end

    dbQuery(function(qh)
        local res = dbPoll(qh, 0)
        if res then
            for _, r in ipairs(res) do
                local cat = tostring(r.category)
                local sName = tostring(r.statName)
                statsByCat[cat] = statsByCat[cat] or {}
                statsByCat[cat][sName] = r.statVal
            end
        end
        if SERVER_TYPE == "mix" and (not statsByCat["Capture The Flag"] or not statsByCat["Capture The Flag"]["Flags Delivered"]) then
            ranksByMode["ctf"] = "-"
        end
        onPlayerDataComplete()
    end, handlerConnect, "SELECT category, statName, statVal FROM player_stats WHERE forumid = ?", forumID)

    dbQuery(function(qh)
        local res = dbPoll(qh, 0)
        if res then
            for _, r in ipairs(res) do
                local mode = tostring(r.racemode)
                local cnt = tonumber(r.cnt) or 0
                topsByMode[mode] = cnt
            end
        end
        onPlayerDataComplete()
    end, handlerConnect, "SELECT racemode, COUNT(*) AS cnt FROM toptimes WHERE forumid = ? AND pos = 1 GROUP BY racemode", forumID)

    local curMonth = getRealTime().month + 1
    local minTimeCurMonth = getRealTime().timestamp - 5184000
    for _, m in ipairs(monthlyModes) do
        local mKey = m.key
        local mOwnSQL = [[
            SELECT tm.forumid, COUNT(*) AS cnt
            FROM `toptimes_month` tm
            INNER JOIN `maps` mp ON mp.resname = tm.mapname
            WHERE tm.month = ? AND tm.date > ? AND mp.racemode = ?
            GROUP BY tm.forumid
            ORDER BY cnt DESC, MAX(tm.date) ASC, tm.forumid ASC
        ]]
        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            local foundRank = "-"
            local foundCnt = 0
            if res then
                for idx, r in ipairs(res) do
                    if tonumber(r.forumid) == forumID then
                        foundRank = idx
                        foundCnt = tonumber(r.cnt) or 0
                        break
                    end
                end
            end
            monthlyOwn[mKey] = { rank = foundRank, cnt = foundCnt }
            onPlayerDataComplete()
        end, handlerConnect, mOwnSQL, curMonth, minTimeCurMonth, mKey)
    end
end

addEventHandler("onGCShopLogin", root, function(forumID)
    local player = source
    sendPlayerOwnRanks(player, forumID)
    setTimer(function()
        if isElement(player) then
            checkAndGrantRankboardRewards(player, forumID)
        end
    end, 5000, 1)
end)

addEventHandler("onGCShopLogout", root, function()
    if isElement(source) then
        triggerClientEvent(source, "onClientClearOwnRankboard", resourceRoot)
    end
end)
