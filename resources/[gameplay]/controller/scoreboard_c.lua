local currentMode = nil

addEventHandler("onClientKey", root, function(key, pressed)
    if (string.find(key, "joy") or string.find(key, "pov") or string.find(key, "axis")) then
        if (not currentMode or currentMode == 'keyboard') then
            currentMode = 'controller'
            setElementData(localPlayer, "controller",
                { type = "image", src = ":controller/images/controller.png", width = 20, height = 20 }, true)
        end
    else
        if (not currentMode or currentMode == 'controller') then
            currentMode = 'keyboard'
            setElementData(localPlayer, "controller",
                { type = "image", src = ":controller/images/wasd.png", width = 20, height = 20 }, true)
        end
    end
end)
