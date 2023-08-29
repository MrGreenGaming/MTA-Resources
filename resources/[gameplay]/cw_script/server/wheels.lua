-- [player] = true/false
local useOffroad = {}

function applySetting(b)
    if b then
        outputInfoForPlayer(source, "You're using offroad wheels for this event. Switch to default using F1 > Settings > Gameplay.")
        useOffroad[source] = true
    else
        outputInfoForPlayer(source, "You're using default wheels for this event. Switch to offroad using F1 > Settings > Gameplay.")
        useOffroad[source] = false
    end
    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle then return end
    applyWheels(source, vehicle)
end
addEvent("eventApplyWheelSetting", true)
addEventHandler("eventApplyWheelSetting", root, applySetting)

addEventHandler('onElementModelChange', root, function()
    if getElementType(source)== 'vehicle' then
        local player = getVehicleOccupant(source)
        if not player then return end
        setTimer(applyWheels, 50, 1, player, source)
    end
end)

addEventHandler('onPlayerVehicleEnter', root, function(vehicle, seat)
    applyWheels(source, vehicle)
end)

function applyWheels(player, vehicle)
    if not areTeamsSet() then return end
    if useOffroad[player] then addVehicleUpgrade(vehicle, 1025) else removeVehicleUpgrade ( vehicle, 1025 ) end
end
