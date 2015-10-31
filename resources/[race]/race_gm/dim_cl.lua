local dimensionsEnabled = false
local rtfCarHideEnabled = false
-- Reset timers at the start of a new map
function onServerMapStarting(dimensionsEnabled_)
	if isTimer(dimTimer) then killTimer(dimTimer) end
	dimTimer = nil
	dimensionsEnabled = dimensionsEnabled_
end
addEvent('onServerMapStarting', true)
addEventHandler('onServerMapStarting', root, onServerMapStarting)


-- Check if it's save to change from dimension
function checkAgain()
	local isDim
	isDim = true
	for i,j in ipairs(getElementsByType('player')) do
		if j == localPlayer then
			deletei = i
			break
		end
	end
	theTable = getElementsByType('player')
	table.remove(theTable, deletei)
	--outputChatBox('Checking again')
	for i,j in ipairs(theTable) do
		local car = getPedOccupiedVehicle(j)
		if car then
			local playerCar = getPedOccupiedVehicle(localPlayer)
			if playerCar then
				x,y,z = getElementPosition(car)
			--	if getElementData(j, "temp.dimension") ~= getElementData(localPlayer, "temp.dimension") then
			--		z = z - add
			--		y = y - add
			--		x = x - add
			--	end
			--	outputChatBox(x..', '..y..', '..z)
				cx,cy,cz = getElementPosition(playerCar)
				--outputChatBox(cx..', '..cy..', '..cz)
				if (getVehicleType(car) == 'Plane') and (getVehicleType(playerCar) == 'Plane') then
					minimDistance = 90
				elseif (getVehicleType(car) == 'Boat') and (getVehicleType(playerCar) == 'Boat') then
					minimDistance = 80
				elseif (getVehicleType(car) == 'Helicopter') and (getVehicleType(playerCar) == 'Helicopter') then
					minimDistance = 80
				else minimDistance = 70
				end
				distance = getDistanceBetweenPoints3D(x,y,z,cx,cy,cz)
				--outputChatBox('Distance check again: '..tostring(distance))
				if distance <= minimDistance then
					isDim = false
					--outputChatBox(tostring(isOk))
					break
				end
			end
		end
	end
	if isDim == true and spectating() == false then
		triggerServerEvent('changeDimension', localPlayer)
		killTimer(dimTimer)
		return
	end
end


addEvent("checkDimensionOkay", true)
addEventHandler("checkDimensionOkay", localPlayer,
function()
	local isDim
	isDim = true
	for i,j in ipairs(getElementsByType('player')) do
		if j == localPlayer then
			deletei = i
			break
		end
	end
	theTable = getElementsByType('player')
	table.remove(theTable, deletei)
	for i,j in ipairs(theTable) do
		--outputChatBox('For Initialized')
		--if getElementData(j,"temp.dimension") ~= getElementData(localPlayer, "temp.dimension") then
		local car = getPedOccupiedVehicle(j)
		if car then
			local playerCar = getPedOccupiedVehicle(localPlayer)
			if playerCar then
				x,y,z = getElementPosition(car)
			--	if getElementData(j, "temp.dimension") ~= getElementData(localPlayer, "temp.dimension") then
			--		z = z - add
			--		y = y - add
			--		x = x - add
			--	end
				--outputChatBox(x..', '..y..', '..z)
				cx,cy,cz = getElementPosition(playerCar)
				--outputChatBox(cx..', '..cy..', '..cz)
				if (getVehicleType(car) == 'Plane') and (getVehicleType(playerCar) == 'Plane') then
					minimDistance = 90
				elseif (getVehicleType(car) == 'Boat') and (getVehicleType(playerCar) == 'Boat') then
					minimDistance = 80
				elseif (getVehicleType(car) == 'Helicopter') and (getVehicleType(playerCar) == 'Helicopter') then
					minimDistance = 80
				else minimDistance = 70
				end
				distance = getDistanceBetweenPoints3D(x,y,z,cx,cy,cz)
				--outputChatBox('Got distance'..tostring(distance))
				if (distance <= minimDistance) then
					isDim = false
					--outputChatBox(tostring(isOk))
					break
				end
			end
		end
		--end
	end
	if isDim == true and spectating() == false then
		triggerServerEvent('changeDimension', localPlayer)
	else
		if isTimer(dimTimer) then killTimer(dimTimer) end
		dimTimer = setTimer(checkAgain, 50, 0)
	end
end
)

-- Is the local player spectating
function spectating()
	return (getElementData(localPlayer, "kKey") == "spectating") or (getElementData(localPlayer, "state") ~= "alive")
end

-- Cancel explosions that didn't happen in the local dimension
function onClientExplosion()
	if not dimensionsEnabled then return end
	if getElementType(source) == "player" then
		if getElementData(source, "dim") ~= getElementData(localPlayer, "dim") then
			cancelEvent()
		end
	end
end
addEventHandler('onClientExplosion', root, onClientExplosion)


-- Applying dimensions to other players while racing and in spectator mode
function theTool()

	if spectating() then
		for i,j in ipairs(getElementsByType('player')) do
			if j ~= localPlayer and getPedOccupiedVehicle(j) and not getElementData(j,'gcmodshop.testing') then

				if getElementDimension(j) ~= 0 or getElementDimension(getPedOccupiedVehicle(j)) ~= 0 then
					setElementDimension(j, 0)
					setElementDimension(getPedOccupiedVehicle(j), 0)
				end
			end
		end
		return
	end

	if dimensionsEnabled then
		for i,j in ipairs(getElementsByType('player')) do
			if j ~= localPlayer and getPedOccupiedVehicle(j) and not getElementData(j,'gcmodshop.testing') then
				if getElementData(j,"player state") == "away" then
					setElementDimension(getPedOccupiedVehicle(j), 160)
					setElementDimension(j, 160)
				else
					if getElementData(j, "dim") ~= getElementData(localPlayer, "dim") then
						if getElementDimension(j) == 0 then
							setElementDimension(getPedOccupiedVehicle(j), 165)
							setElementDimension(j, 165)
						end
					else
						if getElementDimension(j) ~= 0 or getElementDimension(getPedOccupiedVehicle(j)) ~= 0 then
							setElementDimension(getPedOccupiedVehicle(j), 0)
							setElementDimension(j, 0)
						end
					end
				end
			end
		end
	
	elseif rtfCarHideEnabled then
		if getElementData(localPlayer,"rtf_carhide") == "true" then
			if getElementDimension(localPlayer) ~= 0 and getPedOccupiedVehicle(localPlayer) then
				setElementDimension(getPedOccupiedVehicle(localPlayer), 0)
				setElementDimension(localPlayer, 0)
			end


			for i,j in ipairs(getElementsByType('player')) do
				if j ~= localPlayer and getPedOccupiedVehicle(j) then
					setElementDimension(getPedOccupiedVehicle(j), 188)
					setElementDimension(j, 188)
				end
			end
		else
			for i,j in ipairs(getElementsByType('player')) do
				if j ~= localPlayer and getPedOccupiedVehicle(j) and not getElementData(j,'gcmodshop.testing') then
					if getElementData(j,"player state") == "away" then
						setElementDimension(getPedOccupiedVehicle(j), 196)
						setElementDimension(j, 196)
					else
						if getElementDimension(j) ~= 0 or getElementDimension(getPedOccupiedVehicle(j)) ~= 0 then
							setElementDimension(getPedOccupiedVehicle(j), 0)
							setElementDimension(j, 0)
						end
						
					end
				end
			end
		end
	else
		for i,j in ipairs(getElementsByType('player')) do
			if j ~= localPlayer and getPedOccupiedVehicle(j) and not getElementData(j,'gcmodshop.testing') then
				if getElementData(j,"player state") == "away" then
					setElementDimension(j, 212)
					setElementDimension(getPedOccupiedVehicle(j), 212)
				elseif getElementDimension(j) ~= 0 or getElementDimension(getPedOccupiedVehicle(j)) ~= 0 then
					setElementDimension(j, 0)
					setElementDimension(getPedOccupiedVehicle(j), 0)
				end
			end
		end
	end



end
addEventHandler('onClientRender', root, theTool)

-- RTF --
function rtf_dimensionsBool(bool)
	rtfCarHideEnabled = bool
end
addEvent("rtf_setDimensionEnabled",true)
addEventHandler("rtf_setDimensionEnabled",root,rtf_dimensionsBool)


