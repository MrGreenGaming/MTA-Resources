function createRocket()
	local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
	local x,y,z = getElementPosition(occupiedVehicle)
	local rX,rY,rZ = getElementRotation(occupiedVehicle)
	local x = x+4*math.cos(math.rad(rZ+90))
	local y = y+4*math.sin(math.rad(rZ+90))
	createProjectile(occupiedVehicle, 19, x, y, z, 1.0, nil)
end
function shooterJump()
	local veh = getPedOccupiedVehicle(localPlayer)
	local posX, posY, posZ = getElementPosition( veh )
	local grndZ = getGroundPosition(posX,posY,posZ)
	if posZ-grndZ < 2 then
		local vx, vy, vz = getElementVelocity ( veh )
		setElementVelocity ( veh ,vx, vy, vz + 0.25 )
	end
end
function shooter(b)
	if b then
		bindKey("vehicle_fire", "down", createRocket)
		bindKey("vehicle_secondary_fire", "down", shooterJump)
	else
		unbindKey("vehicle_fire", "down", createRocket)
		unbindKey("vehicle_secondary_fire", "down", shooterJump)
	end
end
addEvent('shooter', true)
addEventHandler('shooter', root, shooter)
addEvent('onClientCall_race', true)
addEventHandler('onClientCall_race', root, function(fnName, ...)
	if fnName == 'initRace' then
		local vehicle, checkpoints, objects, pickups, mapoptions, ranked, duration, gameoptions, mapinfo, playerInfo = ...
		triggerServerEvent('checkpoints', resourceRoot, checkpoints)
	end
end)
startTick = getTickCount()
g_ModelForPickupType = { blue = 2048, red = 2914 }
models = {}
function onStart() --Callback triggered by edf
	for name,id in pairs(g_ModelForPickupType) do
		models[name] = {}
		models[name].txd = engineLoadTXD(':mrgreen/' .. name .. '.txd')
		engineImportTXD(models[name].txd, id)
		
		models[name].dff = engineLoadDFF(':mrgreen/flag.dff', id)
		engineReplaceModel(models[name].dff, id)
	end
	
	engineImportTXD( engineLoadTXD(":mrgreen/crate.txd"), 3798)
end
function onStop()
	for name,id in pairs(g_ModelForPickupType) do
		destroyElement ( models[name].txd )
		destroyElement ( models[name].dff )
	end
end
function updateFlags()
	local angle = math.fmod((getTickCount() - startTick) * 360 / 2000, 360)
	for i,element in pairs(getElementsByType"rtf") do
		setElementRotation(element, 0, 0, angle)
	end
	for i,element in pairs(getElementsByType"ctfblue") do
		setElementRotation(element, 0, 0, angle)
	end
	for i,element in pairs(getElementsByType"ctfred") do
		setElementRotation(element, 0, 0, angle)
	end
	for i,element in pairs(getElementsByType"object") do
		if getElementModel(element) == 2048 or getElementModel(element) == 2914 then
			setElementRotation(element, 0, 0, angle)
		end
	end
end
addEventHandler('onClientRender', root, updateFlags)

addEventHandler( "onClientElementStreamIn", root,
    function()
		if getElementModel(source) == 3798 then
			setObjectScale(source, 0.6)
		end
    end
)