
----------------------------------------------------------
-- Some old script I made, which spectates your vehicle	--
-- exploding from a different camera point (SDK)		--
----------------------------------------------------------
local g_Me = getLocalPlayer()
local g_MapRunning = true
local g_MapOptions
local g_Matrix, g_Target
local g_Tick

local followDuration = 1500

function startFollowing()
	if g_MapRunning and not isPlayerFinished(g_Me) then
		g_Target = getPedOccupiedVehicle(g_Me) or g_Me
		
		findFollowSpot(2)
		g_Tick = getTickCount()
		addEventHandler('onClientPreRender', root, updateCamera)
	end
end
addEventHandler('onClientPlayerWasted', g_Me, startFollowing)

function findFollowSpot ( mode )
	g_Matrix = {getCameraMatrix()}
	if mode == 2 then
		local distance = 40
		local vector = { 0, 1, 0.2 }
		
		local vel = {getElementVelocity ( g_Target ) }
		local speed = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(g_Target))
		if speed > 0.09 then
			-- normalize
			vector = {- vel[1]/speed, math.abs(vel[2]/speed), vector[3] }
		end
		local posx, posy, posz = getPositionRelativeToElement(g_Target, distance * vector[1], distance * vector[2], distance * vector[3])
		
		local x, y, z = getElementPosition(g_Target)
		
		local hit, hitx, hity, hitz = processLineOfSight ( x, y, z, posx, posy, posz, true, false, true, true, false, true, false)
		if hit then
			-- find the distance
			distance = 0.8 * getDistanceBetweenPoints3D(hitx, hity, hitz,getElementPosition(g_Target))
			posx, posy, posz = getPositionRelativeToElement(g_Target, distance * vector[1], distance * vector[2], distance * vector[3])
		end
		if type(posz) == "number" then
			g_Matrix[1], g_Matrix[2], g_Matrix[3] = posx, posy, posz
		end
	end
end

function stopFollowing()
	if g_Target then
		removeEventHandler('onClientPreRender', root, updateCamera)
		g_Matrix, g_Target = nil, nil
	end
	-- setGameSpeed(1)
end

function updateCamera()
	if getTickCount() - g_Tick > followDuration or not g_MapRunning then return stopFollowing() end
	-- setGameSpeed(.5)
	local x, y, z = getElementPosition(g_Target)
	setCameraMatrix ( g_Matrix[1], g_Matrix[2], g_Matrix[3], x, y, z, g_Matrix[7] , g_Matrix[8] )
end

addEvent('onClientCall_race', true)
addEventHandler('onClientCall_race', root,  --if server gets restarted then players' cameras halt (unless this resource is restarted) because this event is never fired for some reason.. (By BinSlayer)
	function(fnName, ...)
		if fnName == 'Spectate.start' or fnName == 'remoteStopSpectateAndBlack' then
			stopFollowing()
		elseif fnName == 'updateOptions' then
			local gameoptions, mapoptions = ({...})[1], ({...})[2]
		elseif fnName == 'initRace' then
			local vehicle, checkpoints, objects, pickups, mapoptions, ranked, duration, gameoptions, mapinfo, playerInfo = ...
			g_MapOptions = mapoptions
		end
	end
)


addEventHandler('onClientMapStarting', root, function(mapinfo)
	g_MapRunning = true
end)

addEventHandler('onClientMapStopping', root, function()
	g_MapRunning = false
end)

function isPlayerFinished(player)
	return getElementData(player, 'race.finished')
end

function getPositionRelativeToElement(element, rx, ry, rz)
	-- Some magic
    local matrix = getElementMatrix (element)
    local offX = rx * matrix[1][1] + ry * matrix[2][1] + rz * matrix[3][1] + matrix[4][1]
    local offY = rx * matrix[1][2] + ry * matrix[2][2] + rz * matrix[3][2] + matrix[4][2]
    local offZ = rx * matrix[1][3] + ry * matrix[2][3] + rz * matrix[3][3] + matrix[4][3]
    return offX, offY, offZ
end

