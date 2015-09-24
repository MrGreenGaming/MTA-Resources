--get driver view

function getPositionInFrontOfElement(element)
	-- Get the matrix
	local matrix = getElementMatrix ( element )
	-- Get the transformation of a point 5 units in front of the element
	local offX = 0 * matrix[1][1] + 10 * matrix[2][1] + 0 * matrix[3][1] + 1 * matrix[4][1]
	local offY = 0 * matrix[1][2] + 10 * matrix[2][2] + 0 * matrix[3][2] + 1 * matrix[4][2]
	local offZ = 0 * matrix[1][3] + 10 * matrix[2][3] + 0 * matrix[3][3] + 1 * matrix[4][3]
	--Return the transformed point
	return offX, offY, offZ
end

function getPositionBehindElement(element)
	-- Get the matrix
	local matrix = getElementMatrix ( element )
	-- Get the transformation of a point 5 units in front of the element
	local offX = 0 * matrix[1][1] + -10 * matrix[2][1] + 0 * matrix[3][1] + 1 * matrix[4][1]
	local offY = 0 * matrix[1][2] + -10 * matrix[2][2] + 0 * matrix[3][2] + 1 * matrix[4][2]
	local offZ = 0 * matrix[1][3] + -10 * matrix[2][3] + 0 * matrix[3][3] + 1 * matrix[4][3]
	--Return the transformed point
	return offX, offY, offZ
end

function cursorMove( _, _, a, b , wx, wy, wz)
	if getElementData(getLocalPlayer(), "state")  ~= "alive" or getElementData(getLocalPlayer(), "kKey")  == "spectating" or isCursorShowing() or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() or lookingBack then
		return
	end
	local x,y,z = getPedBonePosition(getLocalPlayer(), 6)
	setCameraMatrix(x, y, z, wx, wy, wz)
	usingMouse = true
	if isTimer(timer) then killTimer(timer) end
	timer = setTimer(function() usingMouse = false end, 2000, 1)
end



usingMouse = false
function getPos()
	if not getPedOccupiedVehicle(localPlayer) or getElementData(getLocalPlayer(), "state")  ~= "alive" or getElementData(getLocalPlayer(), "kKey")  == "spectating" then  --kKey is admin element data for when spectating
		return
	end
	local veh = getPedOccupiedVehicle(localPlayer)
	local x,y,z = getPedBonePosition(getLocalPlayer(), 6)
	local roll = ({getElementRotation(veh)})[2]
	if roll > 180 then
		roll = roll - 360
	end
	roll = -roll

	if lookingBack then
		local fx, fy, fz = getPositionBehindElement(getLocalPlayer())
		setCameraMatrix(x,y,z, fx, fy, fz)
		if usingMouse then usingMouse = false end
		if isTimer(timer) then killTimer(timer) end
		return
	end
	if usingMouse then
		local _, _, _, fx, fy, fz = getCameraMatrix()
		setCameraMatrix(x,y,z, fx, fy, fz, roll)
	else
		local fx, fy, fz = getPositionInFrontOfElement(getLocalPlayer())
		setCameraMatrix(x,y,z, fx, fy, fz, roll)
	end	
end

lookingBack = false

function lookBack(key, state)
	if state == "down" then
		lookingBack = true
	elseif state == "up" then
		lookingBack = false
	end
end

isScriptRunning = false

function onChangeMode(key, state)
	if state == "down" then
		if getElementData(getLocalPlayer(), "state")  ~= "alive" or getElementData(getLocalPlayer(), "kKey")  == "spectating" or oldcam then  --kKey is admin element data for when spectating
			return
		end
		if isScriptRunning == true then
			removeEventHandler('onClientPreRender', getRootElement(), getPos)
			removeEventHandler( "onClientCursorMove", getRootElement( ), cursorMove)
			lookBackKeys = getBoundKeys("vehicle_look_behind")
			if lookBackKeys then
				for keyName, state in pairs(lookBackKeys) do 
					unbindKey(keyName, "both", lookBack)
				end	
			end	
			isScriptRunning = false
			setCameraTarget(getLocalPlayer())
			setCameraViewMode(0)
		end	
		if getCameraViewMode() == 1 then
			isScriptRunning = true
			addEventHandler('onClientPreRender', getRootElement(), getPos)
			addEventHandler( "onClientCursorMove", getRootElement( ), cursorMove)
			lookBackKeys = getBoundKeys("vehicle_look_behind")
			if lookBackKeys then
				for keyName, state in pairs(lookBackKeys) do 
					bindKey(keyName, "both", lookBack)
				end	
			end	
		end
			
	end
end

oldcam = false
addCommandHandler('oldcam',
function()
	oldcam = not oldcam
	if isScriptRunning then 
			removeEventHandler('onClientPreRender', getRootElement(), getPos)
			removeEventHandler( "onClientCursorMove", getRootElement( ), cursorMove)
			lookBackKeys = getBoundKeys("vehicle_look_behind")
			if lookBackKeys then
				for keyName, state in pairs(lookBackKeys) do 
					unbindKey(keyName, "both", lookBack)
				end	
			end	
			isScriptRunning = false
			setCameraTarget(getLocalPlayer())
			setCameraViewMode(0)
	end		
	outputChatBox('Bumper camera is now '.. (oldcam and 'Default GTA camera'  or 'Cockpit racer camera'))
end
)


--fix it for reconnecting.

addEventHandler('onClientResourceStart', getResourceRootElement(),
function()
	cameraKeys = getBoundKeys('change_camera')
	if cameraKeys then
		for keyName, state in pairs(cameraKeys) do 
			bindKey(keyName, "both", onChangeMode)
		end	
	end
end
)

