addEventHandler("onClientVehicleCollision", root,
    function(collider,force, bodyPart, x, y, z, nx, ny, nz)
         if ( source == getPedOccupiedVehicle(localPlayer) and collider and getElementType(collider) == "vehicle" and getElementData(getVehicleOccupant(collider), 'ddbomb') == true) then
             triggerServerEvent('ddbombtouch', resourceRoot, getVehicleOccupant(collider))
         end
    end
)