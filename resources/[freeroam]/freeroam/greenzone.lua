addEventHandler ("onResourceStart", getRootElement(), 
function()
  local allGreenzones = getElementsByType ("radararea")
  for i,v in ipairs (allGreenzones) do
    local r,g,b,a = getRadarAreaColor (v)
    if (r == 0) and (g == 255) and (b == 0) and (a == 127) then
      local x,y = getElementPosition (v)
      local sx,sy = getRadarAreaSize (v)
      local col = createColCuboid (x,y, -50, sx,sy, 7500)
      setElementID (col, "greenzoneColshape")
    end
  end
end)

addEventHandler ("onColShapeHit", getRootElement(), 
function(hitElement, matchingDimension)
  if (getElementType (hitElement) == "player") and (getElementID (source) == "greenzoneColshape") then
    outputChatBox ("You entered the greenzone", hitElement, 255, 0, 0, false)
    toggleControl (hitElement, "fire", false)
    toggleControl (hitElement, "next_weapon", true)
    toggleControl (hitElement, "previous_weapon", true)
    toggleControl (hitElement, "sprint", true)
    toggleControl (hitElement, "aim_weapon", false)
    toggleControl (hitElement, "vehicle_fire", false)
    setPlayerHudComponentVisible (hitElement, "ammo", true)
    setPlayerHudComponentVisible (hitElement, "weapon", true)
    triggerClientEvent (hitElement, "enableGodMode", hitElement)
  end
end)

addEventHandler ("onColShapeLeave", getRootElement(), 
function(leaveElement, matchingDimension)
  if (getElementType (leaveElement) == "player") and (getElementID (source) == "greenzoneColshape") then
    outputChatBox ("You left the greenzone", leaveElement, 255, 0, 0, false)
    toggleControl (leaveElement, "fire", true)
    toggleControl (leaveElement, "next_weapon", true)
    toggleControl (leaveElement, "previous_weapon", true)
    toggleControl (leaveElement, "sprint", true)
    toggleControl (leaveElement, "aim_weapon", true)
    toggleControl (leaveElement, "vehicle_fire", true)
    setPlayerHudComponentVisible (leaveElement, "ammo", true)
    setPlayerHudComponentVisible (leaveElement, "weapon", true)
    triggerClientEvent (leaveElement, "disableGodMode", leaveElement)
  end
end)