addEvent("enableGodMode", true)
addEvent("disableGodMode", true)
addEventHandler ("enableGodMode", getRootElement(), 
function()
  addEventHandler ("onClientPlayerDamage", getRootElement(), cancelEventEvent)
end)

addEventHandler ("disableGodMode", getRootElement(), 
function()
  removeEventHandler ("onClientPlayerDamage", getRootElement(), cancelEventEvent)
end)

function cancelEventEvent () cancelEvent() end 

--liedje in piratenschip
pirShipMusicCol = createColCuboid (1997.58,1523.16,8,6,17.66,4)
addEventHandler ("onClientColShapeHit", getRootElement(), 
function(hitElement, matchingDimension)
  if (source == pirShipMusicCol) and (hitElement == getLocalPlayer()) then
    setRadioChannel (7)
  end
end)
addEventHandler ("onClientColShapeLeave", getRootElement(), 
function(leaveElement, matchingDimension)
  if (source == pirShipMusicCol) and (leaveElement == getLocalPlayer()) then
    setRadioChannel (0)
  end
end)