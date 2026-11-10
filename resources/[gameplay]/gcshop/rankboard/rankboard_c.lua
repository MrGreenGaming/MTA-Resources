local rankboardGUI = {
    subTabPanel = nil,
    builtServerType = nil,
    tabs = {},
    topGrids = {},
    ownGrids = {},
    monthlyTopGrids = {},
    monthlyOwnGrids = {},
}

local modeDefinitionsByServer = {
    race = {
        {
            key = "race",
            title = "Race",
            insertMonthlyAfter = true,
            hasYearlyPrize = true,
            columns = {
                { name = "Rank",      width = 0.09 },
                { name = "Player",    width = 0.29 },
                { name = "Top 1's",   width = 0.12 },
                { name = "Wins",      width = 0.12 },
                { name = "Finishes",  width = 0.12 },
                { name = "Starts",    width = 0.12 },
                { name = "Win Ratio", width = 0.11 },
            }
        }
    },
    mix = {
        {
            key = "general",
            title = "General",
            insertMonthlyAfter = true,
            columns = {
                { name = "Rank",        width = 0.09 },
                { name = "Player",      width = 0.29 },
                { name = "Mix Wins",    width = 0.12 },
                { name = "Mix Top 1's", width = 0.12 },
                { name = "Mix Kills",   width = 0.12 },
                { name = "Mix Deaths",  width = 0.12 },
                { name = "CTF Flags",   width = 0.11 },
            }
        },
        {
            key = "nts",
            title = "NTS",
            hasYearlyPrize = true,
            columns = {
                { name = "Rank",      width = 0.09 },
                { name = "Player",    width = 0.29 },
                { name = "Top 1's",   width = 0.12 },
                { name = "Wins",      width = 0.12 },
                { name = "Finishes",  width = 0.12 },
                { name = "Starts",    width = 0.12 },
                { name = "Win Ratio", width = 0.11 },
            }
        },
        {
            key = "rtf",
            title = "RTF",
            hasYearlyPrize = true,
            columns = {
                { name = "Rank",      width = 0.10 },
                { name = "Player",    width = 0.34 },
                { name = "Top 1's",   width = 0.13 },
                { name = "Wins",      width = 0.13 },
                { name = "Starts",    width = 0.13 },
                { name = "Win Ratio", width = 0.13 },
            }
        },
        {
            key = "dd",
            title = "DD",
            columns = {
                { name = "Rank",      width = 0.09 },
                { name = "Player",    width = 0.29 },
                { name = "Top 1's",   width = 0.12 },
                { name = "Wins",      width = 0.12 },
                { name = "Kills",     width = 0.12 },
                { name = "Deaths",    width = 0.12 },
                { name = "K/D Ratio", width = 0.11 },
            }
        },
        {
            key = "sh",
            title = "SH",
            columns = {
                { name = "Rank",      width = 0.09 },
                { name = "Player",    width = 0.29 },
                { name = "Top 1's",   width = 0.12 },
                { name = "Wins",      width = 0.12 },
                { name = "Kills",     width = 0.12 },
                { name = "Deaths",    width = 0.12 },
                { name = "K/D Ratio", width = 0.11 },
            }
        },
        {
            key = "dl",
            title = "DL",
            columns = {
                { name = "Rank",      width = 0.09 },
                { name = "Player",    width = 0.29 },
                { name = "Top 1's",   width = 0.12 },
                { name = "Wins",      width = 0.12 },
                { name = "Kills",     width = 0.12 },
                { name = "Deaths",    width = 0.12 },
                { name = "K/D Ratio", width = 0.11 },
            }
        },
        {
            key = "ctf",
            title = "CTF",
            columns = {
                { name = "Rank",            width = 0.12 },
                { name = "Player",          width = 0.50 },
                { name = "Flags Delivered", width = 0.34 },
            }
        },
    }
}

local monthlyModeDefinitionsByServer = {
    race = {
        { key = "race", title = "Race (Monthly Top 10)" },
    },
    mix = {
        { key = "nts", title = "NTS (Monthly Top 10)" },
        { key = "rtf", title = "RTF (Monthly Top 10)" },
    }
}

local monthlyColumnsByServer = {
    race = {
        { name = "Rank",         width = 0.12 },
        { name = "Player",       width = 0.54 },
        { name = "Monthly Tops", width = 0.30 },
    },
    mix = {
        { name = "#",            width = 0.15 },
        { name = "Player",       width = 0.55 },
        { name = "Monthly Tops", width = 0.24 },
    }
}

local cachedTop10Data = nil
local cachedOwnData = nil

local function getRankColor(rank, isOwnRow)
    if isOwnRow then
        return 80, 255, 80
    elseif rank == 1 then
        return 255, 215, 0
    elseif rank == 2 then
        return 210, 210, 210
    elseif rank == 3 then
        return 205, 133, 63
    end
    return 255, 255, 255
end

local function populateRow(grid, colCount, rowData, r, g, b)
    local row = guiGridListAddRow(grid)
    local rankStr = tonumber(rowData.rank) and ("#" .. tostring(rowData.rank)) or tostring(rowData.rank or "-")
    guiGridListSetItemText(grid, row, 1, rankStr, false, false)
    guiGridListSetItemColor(grid, row, 1, r, g, b)

    guiGridListSetItemText(grid, row, 2, tostring(rowData.name or "-"), false, false)
    guiGridListSetItemColor(grid, row, 2, r, g, b)

    local cols = rowData.cols or {}
    for i = 1, colCount - 2 do
        local val = cols[i] ~= nil and tostring(cols[i]) or "0"
        guiGridListSetItemText(grid, row, i + 2, val, false, false)
        guiGridListSetItemColor(grid, row, i + 2, r, g, b)
    end
end

local function setOwnGridNotLoggedIn(grid, colCount, msg)
    guiGridListClear(grid)
    local row = guiGridListAddRow(grid)
    guiGridListSetItemText(grid, row, 1, "-", false, false)
    guiGridListSetItemColor(grid, row, 1, 180, 180, 180)
    guiGridListSetItemText(grid, row, 2, msg or "Log in to GreenCoins to see your rank", false, false)
    guiGridListSetItemColor(grid, row, 2, 180, 180, 180)
    for i = 3, colCount do
        guiGridListSetItemText(grid, row, i, "-", false, false)
        guiGridListSetItemColor(grid, row, i, 180, 180, 180)
    end
end

local function getActiveDefs()
    local sType = rankboardGUI.builtServerType or "mix"
    return modeDefinitionsByServer[sType], monthlyModeDefinitionsByServer[sType], monthlyColumnsByServer[sType]
end

local function refreshTop10Display()
    if not cachedTop10Data or not rankboardGUI.builtServerType then return end
    local modeDefs, monthlyDefs, monthlyCols = getActiveDefs()
    local myForumID = tonumber(forumID)

    for _, def in ipairs(modeDefs) do
        local grid = rankboardGUI.topGrids[def.key]
        if isElement(grid) then
            guiGridListClear(grid)
            local list = cachedTop10Data[def.key] or {}
            for _, rowData in ipairs(list) do
                local isMe = myForumID and tonumber(rowData.forumid) == myForumID
                local r, g, b = getRankColor(tonumber(rowData.rank), isMe)
                populateRow(grid, #def.columns, rowData, r, g, b)
            end
        end
    end

    local monthlyTops = cachedTop10Data.monthly or {}
    for _, mDef in ipairs(monthlyDefs) do
        local mGrid = rankboardGUI.monthlyTopGrids[mDef.key]
        if isElement(mGrid) then
            guiGridListClear(mGrid)
            local list = monthlyTops[mDef.key] or {}
            for _, rowData in ipairs(list) do
                local isMe = myForumID and tonumber(rowData.forumid) == myForumID
                local r, g, b = getRankColor(tonumber(rowData.rank), isMe)
                populateRow(mGrid, #monthlyCols, rowData, r, g, b)
            end
        end
    end
end

local function refreshOwnDisplay()
    if not rankboardGUI.builtServerType then return end
    local modeDefs, monthlyDefs, monthlyCols = getActiveDefs()

    for _, def in ipairs(modeDefs) do
        local grid = rankboardGUI.ownGrids[def.key]
        if isElement(grid) then
            if cachedOwnData and cachedOwnData[def.key] then
                guiGridListClear(grid)
                populateRow(grid, #def.columns, cachedOwnData[def.key], 80, 255, 80)
            else
                setOwnGridNotLoggedIn(grid, #def.columns)
            end
        end
    end

    local monthlyOwn = cachedOwnData and cachedOwnData.monthly or nil
    for _, mDef in ipairs(monthlyDefs) do
        local mGrid = rankboardGUI.monthlyOwnGrids[mDef.key]
        if isElement(mGrid) then
            if monthlyOwn and monthlyOwn[mDef.key] then
                guiGridListClear(mGrid)
                populateRow(mGrid, #monthlyCols, monthlyOwn[mDef.key], 80, 255, 80)
            else
                setOwnGridNotLoggedIn(mGrid, #monthlyCols, "Not logged in")
            end
        end
    end
end

local function createMonthlyTab(subTabPanel, serverType)
    local monthlyDefs = monthlyModeDefinitionsByServer[serverType]
    local monthlyCols = monthlyColumnsByServer[serverType]

    local monthlyTab = guiCreateTab("Monthly", subTabPanel)
    rankboardGUI.tabs["monthly"] = monthlyTab

    local bannerText = (serverType == "race")
        and "Monthly Race Top 3 Prizes:   #1: 2,000 GC   |   #2: 1,500 GC   |   #3: 1,000 GC"
        or  "Monthly Top 3 Prizes (Per Mode):   #1: 2,000 GC   |   #2: 1,500 GC   |   #3: 1,000 GC"

    local lblBanner = guiCreateLabel(10, 8, 700, 18, bannerText, false, monthlyTab)
    guiSetFont(lblBanner, "default-bold-small")
    guiLabelSetHorizontalAlign(lblBanner, "center", false)
    guiLabelSetColor(lblBanner, 255, 215, 0)

    local count = #monthlyDefs
    local totalWidth = 700
    local colGap = 10
    local colWidth = math.floor((totalWidth - (count - 1) * colGap) / count)
    local startX = 10

    for idx, mDef in ipairs(monthlyDefs) do
        local x = startX + (idx - 1) * (colWidth + colGap)

        local lblMode = guiCreateLabel(x, 30, colWidth, 18, mDef.title, false, monthlyTab)
        guiSetFont(lblMode, "default-bold-small")
        guiLabelSetHorizontalAlign(lblMode, "center", false)
        guiLabelSetColor(lblMode, 220, 220, 220)

        local mTopGrid = guiCreateGridList(x, 50, colWidth, 252, false, monthlyTab)
        guiGridListSetSortingEnabled(mTopGrid, false)
        for _, col in ipairs(monthlyCols) do
            guiGridListAddColumn(mTopGrid, col.name, col.width)
        end
        rankboardGUI.monthlyTopGrids[mDef.key] = mTopGrid

        local lblOwnM = guiCreateLabel(x + 2, 307, colWidth, 16, "Your Monthly Rank:", false, monthlyTab)
        guiSetFont(lblOwnM, "default-bold-small")
        guiLabelSetColor(lblOwnM, 80, 255, 80)

        local mOwnGrid = guiCreateGridList(x, 326, colWidth, 56, false, monthlyTab)
        guiGridListSetSortingEnabled(mOwnGrid, false)
        guiGridListSetScrollBars(mOwnGrid, false, false)
        for _, col in ipairs(monthlyCols) do
            guiGridListAddColumn(mOwnGrid, col.name, col.width)
        end
        rankboardGUI.monthlyOwnGrids[mDef.key] = mOwnGrid

        setOwnGridNotLoggedIn(mOwnGrid, #monthlyCols, "Not logged in")
    end
end

local function buildRankboardTabs(serverType)
    if not isElement(rankboardGUI.subTabPanel) then return end
    serverType = (serverType == "race") and "race" or "mix"
    if rankboardGUI.builtServerType == serverType then return end

    rankboardGUI.builtServerType = serverType
    local subTabPanel = rankboardGUI.subTabPanel
    local modeDefs = modeDefinitionsByServer[serverType]

    for _, def in ipairs(modeDefs) do
        local subTab = guiCreateTab(def.title, subTabPanel)
        rankboardGUI.tabs[def.key] = subTab

        local topGrid = guiCreateGridList(10, 10, 700, 290, false, subTab)
        guiGridListSetSortingEnabled(topGrid, false)
        for _, col in ipairs(def.columns) do
            guiGridListAddColumn(topGrid, col.name, col.width)
        end
        rankboardGUI.topGrids[def.key] = topGrid

        local lblOwn = guiCreateLabel(12, 306, 250, 18, "Your Rank & Statistics:", false, subTab)
        guiSetFont(lblOwn, "default-bold-small")
        guiLabelSetColor(lblOwn, 80, 255, 80)

        if def.hasYearlyPrize then
            local lblYearly = guiCreateLabel(270, 306, 438, 18, "New Year's Prize: #1 Player on Jan 1st receives 5,000 GC!", false, subTab)
            guiSetFont(lblYearly, "default-bold-small")
            guiLabelSetHorizontalAlign(lblYearly, "right", false)
            guiLabelSetColor(lblYearly, 255, 215, 0)
        end

        local ownGrid = guiCreateGridList(10, 326, 700, 56, false, subTab)
        guiGridListSetSortingEnabled(ownGrid, false)
        guiGridListSetScrollBars(ownGrid, false, false)
        for _, col in ipairs(def.columns) do
            guiGridListAddColumn(ownGrid, col.name, col.width)
        end
        rankboardGUI.ownGrids[def.key] = ownGrid

        setOwnGridNotLoggedIn(ownGrid, #def.columns)

        if def.insertMonthlyAfter then
            createMonthlyTab(subTabPanel, serverType)
        end
    end
end

addEventHandler("onShopInit", resourceRoot, function(tabPanel)
    local mainTab = guiCreateTab("Rankboard", tabPanel)
    rankboardGUI.subTabPanel = guiCreateTabPanel(5, 5, 720, 420, false, mainTab)

    if cachedTop10Data and cachedTop10Data.serverType then
        buildRankboardTabs(cachedTop10Data.serverType)
        refreshTop10Display()
        refreshOwnDisplay()
    end
end)

addEvent("onClientReceiveRankboardTop10", true)
addEventHandler("onClientReceiveRankboardTop10", resourceRoot, function(top10Data)
    cachedTop10Data = top10Data
    if top10Data and top10Data.serverType then
        buildRankboardTabs(top10Data.serverType)
    end
    refreshTop10Display()
    refreshOwnDisplay()
end)

addEvent("onClientReceiveOwnRankboard", true)
addEventHandler("onClientReceiveOwnRankboard", resourceRoot, function(ownData)
    cachedOwnData = ownData
    refreshOwnDisplay()
    refreshTop10Display()
end)

addEvent("onClientClearOwnRankboard", true)
addEventHandler("onClientClearOwnRankboard", resourceRoot, function()
    cachedOwnData = nil
    refreshOwnDisplay()
    refreshTop10Display()
end)
