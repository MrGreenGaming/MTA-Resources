------------------------ Spawnpoints ------------------------

local Spawnpoints = { }
local currentGamemode = ""

addEvent("onMapStarting",true)
addEventHandler('onMapStarting', getRootElement(),
function()
	Spawnpoints = getAll("spawnpoint")
    currentGamemode = exports.race:getRaceMode();
end)

function getAll(name)
	local result = {}
	for i,element in ipairs(getElementsByType(name)) do
		result[i] = {}
		result[i].id = getElementID(element) or i
		local position = { tonumber(getElementData(element,"posX")), tonumber(getElementData(element,"posY")), tonumber(getElementData(element,"posZ")) }
		local rotation = 0
		if getElementData(element,"rotation") then
            rotation = {0, 0, tonumber(getElementData(element,"rotation")) or 0}
		elseif getElementData(element,"rotZ") then
            rotation = {tonumber(getElementData(element,"rotX")) or 0, tonumber(getElementData(element,"rotY")) or 0, tonumber(getElementData(element,"rotZ")) or 0}
		end
		local vehicle = tonumber(getElementData(element,"vehicle"))
		result[i].position = position
		result[i].rotation = rotation
		result[i].vehicle = vehicle
	end
	return result
end

addEvent("onRaceStateChanging",true)
addEventHandler("onRaceStateChanging", getRootElement(),
function ( state )
    if (state == "GridCountdown") and (currentGamemode == "Sprint" or currentGamemode == "Never the same") then
	    for i,player in ipairs(getElementsByType("player")) do
			if getPedOccupiedVehicle(player) then
			    local spawn = Spawnpoints[1]
				local veh = getPedOccupiedVehicle(player)
				local x, y, z = unpack(spawn.position)
				local model = spawn.vehicle
				local rx, ry, rz = unpack(spawn.rotation)
				setElementModel ( veh, model )
                setElementPosition ( veh, x, y, z )
				setElementRotation ( veh, rx, ry, rz )
			end
		end
        outputInfo("Enforcing spawnpoints...")
	end
end)

function round(what,prec) return math.floor(what*math.pow(10,prec)+0.5) / math.pow(10,prec) end
