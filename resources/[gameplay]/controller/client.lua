CurrentController = "XBOX"

function onStart()
    -- PLACE GLOBAL BINDS HERE
    bindControllerKey("logo", "controllerShowScoreboard", "controllerHideScoreboard")
    bindControllerKey("select", "controllerToggleToptimes")
    bindControllerKey("select", "controllerToggleMapInfo")
    bindControllerKey("start", "controllerRemoveAFK")
    bindControllerKey("start", "controllerToggleSpectator")
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function updateControllerSettings(controller)
    CurrentController = controller
    triggerServerEvent("onPlayerChangeController", localPlayer, CurrentController)
end
addEvent("updateControllerSetting")
addEventHandler("updateControllerSetting", root, updateControllerSettings)


function getKey(key)
    if (CurrentController and key) then
        if (Keys[CurrentController] and Keys[CurrentController][key]) then
            return Keys[CurrentController][key].key
        end
    end
    return false
end

function getLabel(key)
    if (CurrentController and key) then
        if (Keys[CurrentController] and Keys[CurrentController][key]) then
            return Keys[CurrentController][key].label
        end
    end
    return false
end
