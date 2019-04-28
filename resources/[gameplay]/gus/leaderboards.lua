screenW, screenH = guiGetScreenSize()
g_root = getRootElement()

addEventHandler("onClientResourceStart", g_root, 
function()
browserwindow = guiCreateWindow((screenW - 913) / 2, (screenH - 642) / 2, 913, 642, "Leaderboards", false)
browserpanel = guiCreateBrowser(0 , 15, 894, 610, false, false, false, browserwindow)
closebutton = guiCreateStaticImage(806, 37, 21, 21, ":stats/images/close.png", false, browserwindow)  
theBrowserPanel = guiGetBrowser( browserpanel )
guiSetProperty(closebutton, "AlwaysOnTop", "true")
guiSetVisible(browserwindow, false)
guiWindowSetSizable(browserwindow, false)
end
)

function showtheWindowBrowser()
    if (guiGetVisible (browserwindow) == true) then 
        guiSetVisible (browserwindow, false)
        showCursor(false)
    else
        guiSetVisible (browserwindow, true)
        showCursor(true)
    end 
    end
addCommandHandler("leaderboard", showtheWindowBrowser, false, false)

addEventHandler("onClientBrowserCreated", g_root, function()
    requestBrowserDomains({"www.mrgreengaming.com"})
    loadBrowserURL(source, "https://mrgreengaming.com/mta/leaderboards")
end
)  

addEventHandler("onClientGUIClick", g_root,
function()
    if ( source == closebutton) then
        guiSetVisible(browserwindow, false)
        showCursor(false)
    end
end
)
