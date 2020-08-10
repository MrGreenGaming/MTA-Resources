-------------------------
-- Fire transfer stuff --
-------------------------

local limit = 2000
local lastTick = {}
local allowedVehicleTypes = {
	['Automobile'] = true,
	['Bike'] = true,
	['Monster Truck'] = true,
	['Quad'] = true
}

function onClientVehicleCollision (vehicleElement, force, bodyPart, colX, colY, colZ, vx, vy,vz)
	if not vehicleElement or  getElementType(vehicleElement) ~= 'vehicle' then return end

	if not lastTick[vehicleElement] then lastTick[vehicleElement] = 0 end
	if getTickCount() - lastTick[vehicleElement] > limit then
		local vehicle = source
		if getVehicleController(vehicle) == localPlayer
					and getVehicleController(vehicleElement)
					and not isVehicleBlown(vehicle)
					and not isVehicleBlown(vehicleElement)
					and (getElementHealth(vehicleElement) < 245 or getElementHealth(vehicle) < 245)    --reduce bandwidth
					and allowedVehicleTypes[getVehicleType(vehicleElement)] and allowedVehicleTypes[getVehicleType(vehicle)]
					and getElementData(localPlayer, 'state') == 'alive' and getElementData(getVehicleController(vehicleElement), 'state') == 'alive' then
			triggerServerEvent('onServerRecieveCollisionData', localPlayer, vehicleElement, vehicle)
			lastTick[vehicleElement] = getTickCount()
		end
	end
end
addEventHandler('onClientVehicleCollision', root, onClientVehicleCollision)

