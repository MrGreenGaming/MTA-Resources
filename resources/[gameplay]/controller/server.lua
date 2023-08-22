-- { [player]: XBOX}
local playerControllers = {}

addEvent("onPlayerChangeController", true)
addEventHandler("onPlayerChangeController", root,
    function(controller)
        playerControllers[source] = controller
    end
)

function getControllerForPlayer(player)
    return playerControllers[player] or "XBOX"
end

function getKeyForPlayer(player, key)
    local controller = getControllerForPlayer(player)
    if (controller and key) then
        if (Keys[controller] and Keys[controller][key]) then
            return Keys[controller][key].key
        end
    end
    return false
end

function getLabelForPlayer(player, key)
    local controller = getControllerForPlayer(player)
    if (controller and key) then
        if (Keys[controller] and Keys[controller][key]) then
            return Keys[controller][key].label
        end
    end
    return false
end
