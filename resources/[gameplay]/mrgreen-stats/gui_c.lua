----------------------
-- CEF GUI Handling --
----------------------
DEBUG = false
local screenWidth, screenHeight = guiGetScreenSize()
function getBrowserDimensions(width)
	-- Specific scale (browser zoom) and width for all resolutions up to 4k
	-- Returns scale, width, height
	if width <= 640 and width < 800 then
		return 0.75, (screenWidth * 0.4), (screenHeight * 0.97)
	elseif width >= 800 and width < 1024 then
		return 0.8, (screenWidth * 0.5), (screenHeight * 0.95)
	elseif width >= 1024 and width < 1280 then
		return 0.85, (screenWidth * 0.65), (screenHeight * 0.9)
	elseif width >= 1280 and width < 1360 then
		return 0.9, (screenWidth * 0.6), (screenHeight * 0.8)
	elseif width >= 1360 and width < 1400 then
		return 1, (screenWidth * 0.5), (screenHeight * 0.65)
	elseif width >= 1400 and width < 1600 then
		return 1, (screenWidth * 0.5), (screenHeight * 0.65)
	elseif width >= 1600 and width < 1920 then
		return 1, (screenWidth * 0.5), (screenHeight * 0.65)
	elseif width >= 1920 and width < 2560 then
		return 1, (screenWidth * 0.5), (screenHeight * 0.65)
	elseif width >= 2560 and width < 3200 then
		return 1.4, (screenWidth * 0.5), (screenHeight * 0.55)
	elseif width >= 3200 and width < 3840 then
		return 1.6, (screenWidth * 0.5), (screenHeight * 0.55)
	elseif width >= 3840 then
		return 2, (screenWidth * 0.5), (screenHeight * 0.65)
	else
		return 2, (screenWidth * 0.5), (screenHeight * 0.65)
	end
end


local guiScale, guiWidth, guiHeight = getBrowserDimensions(screenWidth)
local browserX, browserY = (screenWidth/2) - (guiWidth/2), (screenHeight/2) - (guiHeight/2)
local browserGUI = guiCreateBrowser(browserX, browserY, guiWidth, guiHeight, true, true, false)
local browserElement = guiGetBrowser(browserGUI)
guiSetVisible( browserGUI, false )
guiSetAlpha(browserGUI, 0)



addEventHandler( "onClientBrowserCreated", resourceRoot, 
	function( )
        loadBrowserURL(source, "http://mta/local/gui/index.html")
        if DEBUG then
            setDevelopmentMode( true, true )
            toggleBrowserDevTools(source, true)
        end

		setBrowserRenderingPaused ( source, true )
	end
)

addEvent( 'onMapInfoBrowserMounted' )
addEventHandler('onMapInfoBrowserMounted', resourceRoot, function()
    -- Set zoom (scale)
    executeBrowserJavascript( source, "document.documentElement.style.zoom = "..guiScale)
    requestPlayerList()
end)

function showStatsWindow(bool, dontRequestOwnStats)
    local bool = bool
    if bool == nil then
        bool = not guiGetVisible(browserGUI)
    end
    bool = bool and true or false
    if bool then
        -- When hiding, pause on end of opacity animation inside doFade()
        setBrowserRenderingPaused ( browserElement, false )
    end
    showCursor( bool )
    if guiGetVisible(browserGUI) ~= bool then
        easeOpacity( bool )
    end

    if bool then
        guiSetVisible(browserGUI, bool)
        if not dontRequestOwnStats then
            requestMyStats()
        end
    end
end
-- Trigger setStatsWindowVisible in external scripts
addEvent('sb_showStats')
addEventHandler('sb_showStats', root, function() showStatsWindow() end)
addEvent('setStatsWindowVisible', true)
addEventHandler('setStatsWindowVisible', root, showStatsWindow)
addEvent('browserCloseStatsWindow')
addEventHandler('browserCloseStatsWindow', resourceRoot, function() showStatsWindow(false) end)
bindKey('F10', 'down', function() showStatsWindow() end)
-------------------------
-- Ease opacity (fade) --
-------------------------
local fadeMode = 'in'
local isFading = false
local fadeDuration = 200
local fadeStartPos = 0
local fadeEndPos = 0
local fadeStartTime = 0
local fadeEndTime = 0
local easingFunction = 'InQuad'
function easeOpacity(bool)
    removeEventHandler( 'onClientRender', root, doFade )
    fadeMode = bool and 'in' or 'out'
    fadeStartPos = bool and 0 or 1
    fadeEndPos = bool and 1 or 0
    isFading = true
    fadeStartTime = getTickCount()
    fadeEndTime = fadeStartTime + fadeDuration
    addEventHandler('onClientRender', root, doFade)
end

function doFade()
    local now = getTickCount()
    local elapsedTime = now - fadeStartTime
    local progress = elapsedTime / fadeDuration
    local alpha = interpolateBetween( fadeStartPos, 0, 0, fadeEndPos, 0, 0, progress, easingFunction )
    guiSetAlpha( browserGUI, alpha )
    if now >= fadeEndTime then
        removeEventHandler( 'onClientRender', root, doFade )
        if fadeMode == 'out' then
            setBrowserRenderingPaused ( browserElement, true )
            guiSetVisible(browserGUI, false)
        end
    end
end
-------------------
-- Drag Handling --
-------------------
local shouldSetPosition = false
local mousex, mousey, mousez = false, false, false
local offsetPos = {}

addEventHandler('onClientCursorMove', root, function(_, _, x, y) 
    if shouldSetPosition then
        browserX, browserY = x - offsetPos[ 1 ], y - offsetPos[ 2 ]
        guiSetPosition( browserGUI, browserX, browserY, false )
        
        
	end
end)

addEventHandler( "onClientClick", root,
    function ( btn, state )
        if btn == "left" and state == 'up' then
            shouldSetPosition = false
        end
    end
)

function windowDrag()
	if getKeyState( 'mouse1' ) then
		local mx, my = getCursorPosition()
		local x, y = mx*screenWidth, my*screenHeight
        local elementPos = { guiGetPosition( browserGUI, false ) }
        offsetPos = { x - elementPos[ 1 ], y - elementPos[ 2 ] }
        shouldSetPosition = true
	end
end
addEvent('startWindowDrag')
addEventHandler('startWindowDrag', resourceRoot, windowDrag)

-----------------------
-- Client <-> Server --
-----------------------
function requestStats(id)
    triggerServerEvent('onClientRequestsStats', resourceRoot, tonumber(id))
end
addEvent('browserRequestStats')
addEventHandler('browserRequestStats', resourceRoot, requestStats)
addEvent('extrenalRequestStats', true)
addEventHandler('extrenalRequestStats', root, requestStats)

function requestTopTimeMaps(forumid, raceMode, position)
    local player = (forumid and tonumber(forumid) ~= 0) and forumid or localPlayer
    triggerServerEvent('onClientRequestsTopTimeMaps', resourceRoot, player, raceMode, position)
end

addEvent('browserRequestTopTimeMaps')
addEventHandler('browserRequestTopTimeMaps', resourceRoot, requestTopTimeMaps)

function buyMap(resname, mapname)
    triggerServerEvent("sendPlayerNextmapChoice", localPlayer, { mapname, resname })
end

addEvent('browserRequestBuyMap')
addEventHandler('browserRequestBuyMap', resourceRoot, buyMap)

function receiveStats(stats, player)
    if stats and stats.forumid then
        local avatar = getPlayerAvatarString(player)
        if avatar then
            avatar = '`'..avatar..'`'
        else
            avatar = 'false'
        end

        -- Send player info to browser
        local playerObj = {}
        playerObj.name = safeString(stats.name)
        playerObj.gc = stats.gc
        playerObj.vip = stats.vip
        
        local countryCode = isElement(player) and getElementData(player, 'country') or false
        local countryName = isElement(player) and getElementData(player, 'fullCountryName') or false
        if type(countryCode) == 'string' and type(countryName) == 'string' then
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerCountry', `"..toJSON({name = countryName, code = countryCode}).."`)")
        else
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerCountry', false)")
        end
        executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerInfo', `"..toJSON(playerObj).."`)")
        executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerAvatar', "..avatar..")")
        executeBrowserJavascript(browserElement, "window.VuexStore.commit('setDialogChosenPlayer', "..stats.forumid..")")
        
        -- Set safe strings
        for catIndex, row in ipairs(stats.stats) do
            for statIndex, statObj in ipairs(row.items) do
                stats.stats[catIndex].items[statIndex].name = safeString(stats.stats[catIndex].items[statIndex].name)
                if type(statObj.value) == 'string' then
                    stats.stats[catIndex].items[statIndex].value = safeString(stats.stats[catIndex].items[statIndex].value)
                end
            end
            stats.stats[catIndex].name = safeString(stats.stats[catIndex].name)
        end

        local statsString = toJSON(stats.stats)
        if statsString then
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerStats', `"..statsString.."`)")
        end
        -- Send Tops to browser
        
        if stats.tops then
            local topsString = toJSON(stats.tops)
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerTops', `"..topsString.."`)")
        else
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerTops', false)")
        end

        if stats.topTimeMaps then
            local mapListString = toJSON(stats.topTimeMaps)
            if mapListString then
                executeBrowserJavascript(browserElement,
                    "window.VuexStore.commit('setTopTimeMaps', '" .. mapListString .. "')")
            end
        else
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('setTopTimeMaps', false)")
        end

        stats.monthlyTops = tonumber(stats.monthlyTops) and stats.monthlyTops or 0
        executeBrowserJavascript(browserElement, "window.VuexStore.commit('setMonthlyTopAmount', "..stats.monthlyTops..")")
        return
    end
    executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerStats', false)")
    executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerTops', false)")
    executeBrowserJavascript(browserElement, "window.VuexStore.commit('setTopTimeMaps', false)")
    executeBrowserJavascript(browserElement, "window.VuexStore.commit('setDialogChosenPlayer', false)")
end
addEvent('onServerSendsStats', true)
addEventHandler('onServerSendsStats', localPlayer, receiveStats)

function receiveTopTimeMaps(list)
    if list and list.items and type(list.items) == 'table' and #list.items > 0 then
        local mapListString = toJSON(list)
        if mapListString then
            executeBrowserJavascript(browserElement,
                "window.VuexStore.commit('setTopTimeMaps', '" .. mapListString .. "')")
            return
        end
    end
    executeBrowserJavascript(browserElement, "window.VuexStore.commit('setTopTimeMaps', false)")
end
addEvent('onServerSendsTopTimeMaps', true)
addEventHandler('onServerSendsTopTimeMaps', localPlayer, receiveTopTimeMaps)

function requestPlayerList()
    triggerServerEvent('onClientRequestsStatsPlayerList', resourceRoot)
end
addEvent('onBrowserOpenedPlayerList')
addEventHandler('onBrowserOpenedPlayerList', resourceRoot, requestPlayerList)

function receivePlayerList(list)
    if list and type(list) == 'table' and #list > 0 then
        for i, entry in ipairs(list) do
            list[i].name = safeString(entry.name)
        end
        local playerListString = toJSON(list)
        if playerListString then
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerList', '"..playerListString.."')")
            return
        end
    end
    executeBrowserJavascript(browserElement, "window.VuexStore.commit('setPlayerList', false)")
end
addEvent('onServerSendsStatsPlayerList', true)
addEventHandler('onServerSendsStatsPlayerList', localPlayer, receivePlayerList)

function requestMyStats()
    triggerServerEvent('onClientRequestsStats', resourceRoot, localPlayer)
end
addEvent('requestMyStats')
addEventHandler( 'requestMyStats', resourceRoot, requestMyStats)

----------------------------
-- GC logged in/out state --
----------------------------
function requestLoggedInState()
    triggerServerEvent('onClientRequestsStatsLoggedInState', resourceRoot)
end

function setLoggedInState(bool)
    if type(bool) == 'boolean' then
        if bool then
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('setLoggedIn', true)")
        else
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('setLoggedIn', false)")
            executeBrowserJavascript(browserElement, "window.VuexStore.commit('removeData')")
        end
    end
end
addEvent('onServerSendStatsLogedInState', true)
addEventHandler( 'onServerSendStatsLogedInState', localPlayer, setLoggedInState)

------------------------------
-- Scoreboard click handler --
------------------------------
function scoreboardClick ( row, x, y, columnName )
    if columnName == "forumAvatar" and getElementType(source) == "player" then
        executeCommandHandler("Toggle scoreboard", "0")
        triggerServerEvent('onClientRequestsStats', resourceRoot, source)
        showStatsWindow(true, true)
	end
end
addEventHandler ( "onClientPlayerScoreboardClick", root, scoreboardClick )

--http://lua-users.org/wiki/FormattingNumbers
function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
        if k == 0 then
            break
        end
    end
    return formatted
end
