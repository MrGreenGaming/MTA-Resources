local vehicles = {}
local timers = {}
radius = 5
addEvent('onCheckCollisions', true)
addEventHandler('onCheckCollisions', root,
function()
    vehicles = {}
    for _, timer in pairs(timers) do
        if isTimer(timer) then
            killTimer(timer)
        end
    end
    timers = {}
    local car = getPedOccupiedVehicle(localPlayer)
    if not car or not isElement(car) then return end
    for _, player in ipairs(getElementsByType('player')) do
        local otherCar = getPedOccupiedVehicle(player)
        if otherCar and isElement(otherCar) and otherCar ~= car then
            if isBoundingBoxOverlapping(car, otherCar) then   -- we have successfully detected a vehicle that's in the local player's spawnpoint!
                table.insert(vehicles, otherCar)
            end
        end
    end
    --"vehicles" contains all the vehicles that are in the same spawnpoint as my local player. Turn all the collisions off for these particular vehicles in my local player's view.
    for _, vehicle in ipairs(vehicles) do
        setElementCollidableWith(vehicle, car, false)
        setElementAlpha(vehicle, 150)
        timers[vehicle] = setTimer(function(myCar, otherVehicle)
                                        if not (myCar and otherVehicle and isElement(myCar) and isElement(otherVehicle)) then
                                            --some error occured, like players leaving or dieing.. so just kill the timer.
                                            killTimer(timers[otherVehicle])
                                            return
                                        end
                                        if not isBoundingBoxOverlapping(myCar, otherVehicle) then
                                            setElementCollidableWith(otherVehicle, myCar, true)
                                            setElementAlpha(otherVehicle, 255)
                                            killTimer(timers[otherVehicle])
                                            triggerServerEvent("onGMoff",localPlayer)
                                        end
                                    end, 500, 0, car, vehicle)
    end
end)


function isBoundingBoxOverlapping(car1, car2)
	-- car1: localPlayer, car2: other player
    local min_x1, min_y1, min_z1, max_x1, max_y1, max_z1 = getElementBoundingBox(car1)
    local x,y,z = getElementPosition(car1)
    min_x1 = min_x1 + x;    min_y1 = min_y1 + y;    min_z1 = min_z1 + z;
    max_x1 = max_x1 + x;    max_y1 = max_y1 + y;    max_z1 = max_z1 + z;

    local min_x2, min_y2, min_z2, max_x2, max_y2, max_z2 = getElementBoundingBox(car2)
    if type(min_x2) == "boolean" then
        return false --min_x2 returning false means getElementBoundingBox failed, means remote vehicle is clearly away from local vehicle.
    end
    x,y,z = getElementPosition(car2)
    min_x2 = min_x2 + x;    min_y2 = min_y2 + y;    min_z2 = min_z2 + z;
    max_x2 = max_x2 + x;    max_y2 = max_y2 + y;    max_z2 = max_z2 + z;

    if (((min_x1 <= min_x2 and min_x2 <= max_x1) or (min_x2 <= min_x1 and min_x1 <= max_x2)) and
		((min_y1 <= min_y2 and min_y2 <= max_y1) or (min_y2 <= min_y1 and min_y1 <= max_y2)) and
		((min_z1 <= min_z2 and min_z2 <= max_z1) or (min_z2 <= min_z1 and min_z1 <= max_z2))) then
        return true
	end
	return false
end


