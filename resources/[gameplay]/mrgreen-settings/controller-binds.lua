function allowControllerLogoBind(b)
    if (b) then
        exports.controller:bindControllerKey("logo", "controllerShowScoreboard", "controllerHideScoreboard")
    else
        exports.controller:unbindControllerKey("logo", "controllerShowScoreboard", "controllerHideScoreboard")
    end
end
addEvent("allowControllerLogoBind")
addEventHandler("allowControllerLogoBind", root, allowControllerLogoBind)

function allowControllerSelectBind(b)
    if (b) then
        exports.controller:bindControllerKey("select", "controllerToggleToptimes")
        exports.controller:bindControllerKey("select", "controllerToggleMapInfo")
    else
        exports.controller:unbindControllerKey("select", "controllerToggleToptimes")
        exports.controller:unbindControllerKey("select", "controllerToggleMapInfo")
    end
end
addEvent("allowControllerSelectBind")
addEventHandler("allowControllerSelectBind", root, allowControllerSelectBind)

function allowControllerStartBind(b)
    if (b) then
        exports.controller:bindControllerKey("start", "controllerRemoveAFK")
        exports.controller:bindControllerKey("start", "controllerToggleSpectator")
    else
        exports.controller:unbindControllerKey("start", "controllerRemoveAFK")
        exports.controller:unbindControllerKey("start", "controllerToggleSpectator")
    end
end
addEvent("allowControllerStartBind")
addEventHandler("allowControllerStartBind", root, allowControllerStartBind)
