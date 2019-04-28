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


addEventHandler("onClientResourceStart", resourceRoot, function()
    browserWindow = guiCreateWindow((screenW - 913) / 2, (screenH - 642) / 2, 913, 642, "Leaderboards", false)
    local closebutton = guiCreateStaticImage(806, 37, 21, 21, ":stats/images/close.png", false, browserWindow)
    addEventHandler("onClientGUIClick", closebutton,onLeaderboardsCloseClick)
    guiSetProperty(closebutton, "AlwaysOnTop", "true")
    guiSetVisible(browserWindow, false)
    guiWindowSetSizable(browserWindow, false)
end
)

function createLeaderboardsBrowser(bool)
    if bool then
        -- Create browser
        browserPanel = guiCreateBrowser(0 , 15, 894, 610, false, false, false, browserWindow)
        browserElement = guiGetBrowser( browserPanel ) -- Get the browser element from gui-browser
    else
        if isElement(browserPanel) then destroyElement(browserPanel) end
        if isElement(browserElement) then destroyElement(browserElement) end
    end
end

addCommandHandler("leaderboards", function()
    if (guiGetVisible (browserWindow) == true) then 
        createLeaderboardsBrowser(false)
        guiSetVisible (browserWindow, false)
        showCursor(false)
    else
        createLeaderboardsBrowser(true)
        guiSetVisible (browserWindow, true)
        showCursor(true)
    end 
end
)


function onLeaderboardsCloseClick()
    guiSetVisible(browserWindow, false)
    showCursor(false)
    createLeaderboardsBrowser(false)
end


-- If URL is not whitelisted, request, otherwise load
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