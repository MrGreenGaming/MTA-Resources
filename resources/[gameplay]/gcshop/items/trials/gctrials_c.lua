-- Credit to http://community.multitheftauto.com/index.php?p=resources&s=details&id=430

local minus = false
local plus  = false

local bikes = { ['NRG-500']=true, ['PCJ-600']=true, ['FCR-900']=true, ['BF-400']=true, ['Sanchez']=true }

-------------
-- Loading --
-------------

function loadGCTrials( bool, settings )
	if bool then
		if not settings.dont_flip then
			-- Keep bike straight when flipping
			loadFlip()
		end
		-- Animation tricks in the air
		loadTricks()
	else
		unloadFlip()
		unloadTricks()
	end
end
addEvent( 'loadGCTrials', true )
addEventHandler( 'loadGCTrials', localPlayer, loadGCTrials)


function settingGCTrials ( settings )
	if not settings.dont_flip then
		loadFlip()
		loadTricks()
	else
		unloadFlip()
		unloadTricks()
	end
end
addEvent('settingGCTrials', true)
addEventHandler('settingGCTrials', localPlayer, settingGCTrials)

function loadFlip()
	addEventHandler( 'onClientPreRender', root, onClientPreRender)
	
	-- Flip it faster
	for k, v in pairs(getBoundKeys'steer_back') do
		bindKey( k, 'both', preRotation )
	end
	for k, v in pairs(getBoundKeys'steer_forward') do
		bindKey( k, 'both', preRotation )
	end
end

function unloadFlip()
	removeEventHandler( 'onClientPreRender', root, onClientPreRender)
	
	for k, v in pairs(getBoundKeys'steer_back') do
		unbindKey( k, 'both', preRotation )
	end
	for k, v in pairs(getBoundKeys'steer_forward') do
		unbindKey( k, 'both', preRotation )
	end
	
	minus, plus = false, false
	removeEventHandler( 'onClientPreRender', root, minusRotation )
	removeEventHandler( 'onClientPreRender', root, plusRotation )

end


function loadTricks()
	bindKey( '1', 'both', trick_Leggs )
	bindKey( '2', 'both', trick_Leggs )
	bindKey( '3', 'both', trick_Dive )
	bindKey( '4', 'both', trick_Stay )
	bindKey( '5', 'both', trick_Seat180 )
end

function unloadTricks()
	unbindKey( '1', 'both', trick_Leggs )
	unbindKey( '2', 'both', trick_Leggs )
	unbindKey( '3', 'both', trick_Dive )
	unbindKey( '4', 'both', trick_Stay )
	unbindKey( '5', 'both', trick_Seat180 )
	
	if isStunted then trick_End() end
end


-------------
-- Flippin --
-------------

function onClientPreRender()
	local bike = getPedOccupiedVehicle( localPlayer )
	
	if isElement(bike) then
		local x, y, z = getElementPosition(bike)
		local gz = getGroundPosition(x, y, z)
		local height = math.ceil(z-gz)
		if not isVehicleOnGround( bike ) and bikes[getVehicleNameFromModel( getElementModel(bike) )] and 0.1 < getDistanceBetweenPoints3D(0,0,0,getElementVelocity(bike)) and height > 11 and not isBikeCloseToGround(bike) then
			local rx, ry, rz  = getElementRotation( bike )
			setElementRotation( bike, rx, 0, rz )
		end
	end
end

function preRotation( key, keyState )
	if getBoundKeys('steer_back')[key] then
		if keyState == 'down'then
			if not minus then
				minus = true
				addEventHandler( 'onClientPreRender', root, minusRotation )
			end
		else
			minus = false
			removeEventHandler( 'onClientPreRender', root, minusRotation )
		end
	elseif getBoundKeys('steer_forward')[key] then
		if keyState == 'down'then
			if not plus then
				plus = true
				addEventHandler( 'onClientPreRender', root, plusRotation )
			end
		else
			plus = false
			removeEventHandler( 'onClientPreRender', root, plusRotation )
		end
	end
end

function minusRotation()
	local bike = getPedOccupiedVehicle( localPlayer )
	if isElement(bike) and not isVehicleOnGround( bike ) and bikes[getVehicleNameFromModel( getElementModel(bike) )] then
		local rx, ry, rz = getElementRotation( bike )
		setElementRotation( bike, rx + 0.5, ry, rz )
	end
end

function plusRotation()
	local bike = getPedOccupiedVehicle( localPlayer )
	if isElement(bike) and not isVehicleOnGround( bike ) and bikes[getVehicleNameFromModel( getElementModel(bike) )] then
		local rx, ry, rz = getElementRotation( bike )
		setElementRotation( bike, rx - 0.5, ry, rz )
	end
end

function onClientPlayerDamage()
	local vehicle = getPedOccupiedVehicle( localPlayer )
	if isElement(vehicle) then
		local vx, vy, vz = getVehicleTurnVelocity( vehicle )
		setElementAngularVelocity( vehicle, vx + 1, vy, 0.5 )
		local evx, evy, evz = getElementVelocity( vehicle )
		setElementVelocity( vehicle, evx, evy, evz + 0.5 )
		setTimer( function ()
			setGravity( 0.002 )
			setTimer( setGravity, 1000, 1, 0.008 )
		end, 100, 1 )
	end
end
--addEventHandler( 'onClientPlayerDamage', localPlayer, onClientPlayerDamage)


------------
-- Tricks --
------------

function trick_Leggs( key, keyState )
	if keyState == 'down' then
		local bike = getPedOccupiedVehicle( localPlayer )
		if isElement(bike) and bikes[getVehicleNameFromModel( getElementModel(bike) )] then
			local legg
			if key == '1' then legg = 'bmx_left' elseif key == '2' then legg = 'bmx_right' end
			triggerServerEvent( 'doTrickAnimation', localPlayer, 'bmx', legg, false )
			isStunted = true
		end
	else
		trick_End()
	end
end

function trick_Dive( key, keyState )
	if keyState == 'down' then
		local bike = getPedOccupiedVehicle( localPlayer )
		if isElement(bike) and bikes[getVehicleNameFromModel( getElementModel(bike) )] then
			triggerServerEvent( 'doTrickAnimation', localPlayer, 'parachute', 'fall_skydive', true )
			isStunted = true
		end
	else
		trick_End()
	end
end

function trick_Stay( key, keyState )
	if keyState == 'down' then
		local bike = getPedOccupiedVehicle( localPlayer )
		if isElement(bike) and bikes[getVehicleNameFromModel( getElementModel(bike) )] then
			triggerServerEvent( 'doTrickAnimation', localPlayer, 'shop', 'shp_jump_land', false )
			isStunted = true
		end
	else
		trick_End()
	end
end

function trick_Seat180( key, keyState )
	if keyState == 'down' then
		local bike = getPedOccupiedVehicle( localPlayer )
		if isElement(bike) and bikes[getVehicleNameFromModel( getElementModel(bike) )] then
			triggerServerEvent( 'doTrickAnimation', localPlayer, 'crib', 'crib_console_loop', false )
			isStunted = true
		end
	else
		trick_End()
	end
end

function trick_End()
	local bike = getPedOccupiedVehicle( localPlayer )
	if isElement(bike) then
		local bn = getVehicleNameFromModel( getElementModel( bike ) )
		if bn == 'NRG-500' or bn == 'PCJ-600' or bn == 'FCR-900' or bn == 'BF-400' then
			triggerServerEvent( 'doTrickAnimation', localPlayer, 'bikes', 'bikes_ride', false, 0 )
		elseif bn == 'Sanchez' then
			triggerServerEvent( 'doTrickAnimation', localPlayer, 'biked', 'biked_ride', false, 0 )
		end
	end
	isStunted = false
end

function onClientRender()
	local bike = getPedOccupiedVehicle( localPlayer )
	if isElement(bike) and isVehicleOnGround( bike ) and isStunted and 0.1 < getDistanceBetweenPoints3D(0,0,0,getElementVelocity(bike)) then
		trick_End()
	end
end
addEventHandler( 'onClientRender', root, onClientRender)

--This function need for isBikeCloseToGround() function
function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Function isBikeCloseToGround() needed because isVehicleOnGround() don't work correctly with bikes riding sideways, doing wheelie, etc. --
--------------------------------------------------------------------------------------------------------------------------------------------

function isBikeCloseToGround(bike)
	local x, y, z = getElementPosition(bike)
	
	local x2, y2, z2 = getPositionFromElementOffset(bike, 0, 0, -3) --a point under the bike
	local x3, y3, z3 = getPositionFromElementOffset(bike, 0, -2, 0) --behind
	local x4, y4, z4 = getPositionFromElementOffset(bike, 0, 2, 0) --front
	local x5, y5, z5 = getPositionFromElementOffset(bike, 2, 0, 0) --right
	local x6, y6, z6 = getPositionFromElementOffset(bike, -2, 0, 0) --left
	local x7, y7, z7 = getPositionFromElementOffset(bike, 0, 0, 2) --above 
	local clear1 = isLineOfSightClear(x, y, z, x2, y2, z2, true, false, false, true)
	local clear2 = isLineOfSightClear(x, y, z, x3, y3, z3, true, false, false, true)
	local clear3 = isLineOfSightClear(x, y, z, x4, y4, z4, true, false, false, true)
	local clear4 = isLineOfSightClear(x, y, z, x5, y5, z5, true, false, false, true)
	local clear5 = isLineOfSightClear(x, y, z, x6, y6, z6, true, false, false, true)
	local clear6 = isLineOfSightClear(x, y, z, x7, y7, z7, true, false, false, true)
	
	if testing then
		dxDrawLine3D(x, y, z, x2, y2, z2, tocolor(255, 0, 0))
		dxDrawLine3D(x, y, z, x3, y3, z3, tocolor(255, 0, 0))
		dxDrawLine3D(x, y, z, x4, y4, z4, tocolor(255, 0, 0))
		dxDrawLine3D(x, y, z, x5, y5, z5, tocolor(255, 0, 0))
		dxDrawLine3D(x, y, z, x6, y6, z6, tocolor(255, 0, 0))
		dxDrawLine3D(x, y, z, x7, y7, z7, tocolor(255, 0, 0))
	end
	
	if clear1 and clear2 and clear3 and clear4 and clear5 and clear6 then
		return false
	else
		return true
	end	
end

--for testing
--[[
testing = true
addEventHandler("onClientPreRender", root,
function()
	local bike = getPedOccupiedVehicle(localPlayer)
	if isElement(bike) then
		outputChatBox(tostring(isBikeCloseToGround(bike)))
	end
end
)]]