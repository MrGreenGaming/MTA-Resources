function getPositionAndVelocityForProjectile(theVehicle, x, y, z)
	local matrix = getElementMatrix(theVehicle)
	local offX = 0 * matrix[1][1] + 1 * matrix[2][1] + 0 * matrix[3][1] + 1 * matrix[4][1]
	local offY = 0 * matrix[1][2] + 1 * matrix[2][2] + 0 * matrix[3][2] + 1 * matrix[4][2]
	local offZ = 0 * matrix[1][3] + 1 * matrix[2][3] + 0 * matrix[3][3] + 1 * matrix[4][3]
	local vx = offX - x
	local vy = offY - y
	local vz = offZ - z
	local x = 0 * matrix[1][1] + 3 * matrix[2][1] + 0 * matrix[3][1] + 1 * matrix[4][1]
	local y = 0 * matrix[1][2] + 3 * matrix[2][2] + 0 * matrix[3][2] + 1 * matrix[4][2]
	local z = 0 * matrix[1][3] + 3 * matrix[2][3] + 0 * matrix[3][3] + 1 * matrix[4][3]
	return x, y, z, vx, vy, vz
end	
	
function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z 
end

function getElementSpeed(element,unit)
if (unit == nil) then unit = 0 end
if (isElement(element)) then
	local x,y,z = getElementVelocity(element)
	if (unit=="mph" or unit==1 or unit =='1') then
		return (x^2 + y^2 + z^2) ^ 0.5 * 100
	else
		return (x^2 + y^2 + z^2) ^ 0.5 * 1.8 * 100
	end
else
	outputDebugString("Not an element. Can't get speed")
	return false
end
end

function setElementSpeed(element, unit, speed)
if (unit == nil) then unit = 0 end
if (speed == nil) then speed = 0 end
speed = tonumber(speed)
local acSpeed = getElementSpeed(element, unit)
if (acSpeed~=false) and (acSpeed~=0) then
	local diff = speed/acSpeed
	local x,y,z = getElementVelocity(element)
		setElementVelocity(element,x*diff,y*diff,z*diff)
	return true
else
	return false
end
return false
end