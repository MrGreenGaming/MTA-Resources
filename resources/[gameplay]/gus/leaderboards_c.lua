local toggleLeaderboardsWindow = false;
local screenW, screenH = guiGetScreenSize()
local browserPanel = false
local browserWindow = false
local browserElement = false
local neededDomains = {
    "mrgreengaming.com",
    "www.mrgreengaming.com",
    "fonts.googleapis.com",
    "fonts.gstatic.com"
}
local  closeButtonPos = { 
    x = 1353, 
    y = 231, 
    width = 1385, 
    height = 247 
}

function toggleLeaderboardsDxContent()   
    dxDrawRectangle(515, 228, 890, 10, tocolor(78, 200, 87, 255), false)
    dxDrawRectangle(515, 238, 890, 10, tocolor(12, 180, 24, 255), false)
    dxDrawText("Leaderboards", 866 + 1, 228 + 1, 1053 + 1, 247 + 1, tocolor(0, 0, 0, 255), 1.40, "default-bold", "center", "center", false, false, false, false, false)
    dxDrawText("Leaderboards", 866, 228, 1053, 247, tocolor(255, 255, 255, 255), 1.40, "default-bold", "center", "center", false, false, false, false, false)
    dxDrawText("Close", 1353 + 1, 231 + 1, 1385 + 1, 247 + 1, tocolor(1, 0, 0, 255), 1.00, "default", "left", "top", false, false, false, false, false)
    dxDrawText("Close", 1353, 231, 1385, 247, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, false, false, false)
end

addEventHandler ("onClientClick", root, function ( _, _, x, y ) 
    if ( x >= closeButtonPos.x and x <= closeButtonPos.x + closeButtonPos.width and y >= closeButtonPos.y and y <= closeButtonPos.y + closeButtonPos.height ) then 
        removeEventHandler("onClientRender", getRootElement(), toggleLeaderboardsDxContent)
        toggleLeaderboardsWindow = false
        createLeaderboardsBrowser(false)
        showCursor(false)
    end
end)

function createLeaderboardsBrowser(bool)
    if bool then
        browserPanel = guiCreateBrowser((screenW - 890) / 2, (screenH - 584) / 2, 890, 584, false, false, false, browserWindow)
        browserElement = guiGetBrowser( browserPanel )
    else
        if isElement(browserPanel) then destroyElement(browserPanel) end
        if isElement(browserElement) then destroyElement(browserElement) end
    end
end


addEvent("sb_showLeaderboards")
addEventHandler("sb_showLeaderboards", root, function()
    if (not toggleLeaderboardsWindow) then
        addEventHandler("onClientRender", getRootElement(), toggleLeaderboardsDxContent)
        toggleLeaderboardsWindow = true
        createLeaderboardsBrowser(true)
        showCursor(true)
    else
        removeEventHandler("onClientRender", getRootElement(), toggleLeaderboardsDxContent)
        toggleLeaderboardsWindow = false
        createLeaderboardsBrowser(false)
        showCursor(false)
    end
    end
)


function toggleWindowContents()
    if (not toggleLeaderboardsWindow) then
    addEventHandler("onClientRender", getRootElement(), toggleLeaderboardsDxContent)
    toggleLeaderboardsWindow = true
    createLeaderboardsBrowser(true)
    showCursor(true)
else
    removeEventHandler("onClientRender", getRootElement(), toggleLeaderboardsDxContent)
    toggleLeaderboardsWindow = false
    createLeaderboardsBrowser(false)
    showCursor(false)
end
end
addCommandHandler("leaderboards", toggleWindowContents)


addEventHandler("onClientBrowserCreated", resourceRoot, function()
    -- Check if it's our browser
    if source == browserElement then
        -- Check if the url is already whitelisted
        if not areDomainsBlocked() then
            -- Load url
            loadBrowserURL(browserElement, "https://www.mrgreengaming.com/mta/leaderboards/")
        else
            -- Whitelist first
            requestBrowserDomains(neededDomains,false, 
                function(wasAccepted)
                    if wasAccepted then
                        -- Whitelist accepted, load browser URL
                        loadBrowserURL(browserElement, "https://www.mrgreengaming.com/mta/leaderboards/")
                    else
                        -- Domains are still blocked, close GUI
                        createLeaderboardsBrowser(false)
                        guiSetVisible (browserWindow, false)
                        showCursor(false)
                    end
                end
            )
        end
    end
end
)


function areDomainsBlocked()
    for i, domain in ipairs(neededDomains) do
        if isBrowserDomainBlocked(domain) then
            return domain
        end
    end
    return false
end
