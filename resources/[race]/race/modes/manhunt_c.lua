Manhunt = {}
Manhunt.damageDetection = {}
Manhunt.reportTimer = false

function Manhunt.startDamageDetection(bool)
    if bool then
        removeEventHandler("onClientVehicleDamage", root, Manhunt.damageHandler)
        addEventHandler("onClientVehicleDamage", root, Manhunt.damageHandler)
        if not isTimer(Manhunt.reportTimer) then Manhunt.reportTimer = setTimer(Manhunt.reportDamage, 250, 0) end
    else
        removeEventHandler("onClientVehicleDamage", root, Manhunt.damageHandler)
        if isTimer(Manhunt.reportTimer) then killTimer(Manhunt.reportTimer) end
        Manhunt.damageDetection = {}
    end
end

function Manhunt.damageHandler(attacker, weapon, loss)
    if (source == localPlayer or source == getPedOccupiedVehicle(localPlayer)) and attacker and attacker ~= localPlayer and (getElementType(attacker) == "player" or  getElementType(attacker) == "vehicle")and loss > 0 then
        if getElementType(attacker) == "vehicle" then
            attacker = getVehicleOccupant(attacker)
        end
        if not attacker or attacker == localPlayer then return end
        local current = Manhunt.damageDetection[attacker] or 0
        Manhunt.damageDetection[attacker] = current + loss
    end
end

function Manhunt.reportDamage()
    local t = {}
    for p, v in pairs(Manhunt.damageDetection) do
        local insertVal = {player = p, damage = v}
        table.insert(t, insertVal)
    end
    triggerServerEvent("onManhuntVictimReportsDamage", resourceRoot, t)
end