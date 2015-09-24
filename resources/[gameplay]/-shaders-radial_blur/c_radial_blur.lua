--
-- c_radial_blur.lua
--

-----------------------------------------------------------------------------------
-- Settings for changing
-----------------------------------------------------------------------------------
bSuspendSpeedEffectOnLowFPS = false		-- true for auto FPS saving
bSuspendRotateEffectOnLowFPS = false    -- true for auto FPS saving


-----------------------------------------------------------------------------------
-- Settings for not really changing
-----------------------------------------------------------------------------------
local orderPriority = "-2.8"					-- The lower this number, the later the effect is applied (Radial blur should be one of the last full screen effects)
local bShowDebug = false


-----------------------------------------------------------------------------------
-- Runtime variables
-----------------------------------------------------------------------------------
local fpsScaler = 1
local scx, scy = guiGetScreenSize()


----------------------------------------------------------------
-- enableRadialBlur
----------------------------------------------------------------
function enableRadialBlur()
	if bEffectEnabled then return end

	-- Turn GTA blur off
	setBlurLevel(0)

	-- Create things
    myScreenSource = dxCreateScreenSource( scx/2, scy/2 )
    radialMaskTexture = dxCreateTexture( "images/radial_mask.tga", "dxt5" )
    radialBlurShader,tecName = dxCreateShader( "fx/radial_blur.fx" )
	-- outputDebugString( "Radial blur is using technique " .. tostring(tecName) )

	-- Get list of all elements used
	effectParts = {
						myScreenSource,
						radialBlurShader,
						radialMaskTexture,
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end

	bEffectEnabled = true

	if not bAllValid then
		outputChatBox( "Radial blur: Could not create some things. Please use debugscript 3" )
		disableRadialBlur()
	else
		dxSetShaderValue( radialBlurShader, "sSceneTexture", myScreenSource )
		dxSetShaderValue( radialBlurShader, "sRadialMaskTexture", radialMaskTexture )
	end
end

----------------------------------------------------------------
-- disableRadialBlur
----------------------------------------------------------------
function disableRadialBlur()
	if not bEffectEnabled then return end

	-- Destroy all shaders
	for _,part in ipairs(effectParts) do
		if part then
			destroyElement( part )
		end
	end
	effectParts = {}
	bAllValid = false

	-- Flag effect as stopped
	bEffectEnabled = false
end


----------------------------------------------------------------
-- onClientHUDRender
--    Effect is applied here
----------------------------------------------------------------
addEventHandler( "onClientHUDRender", root,
    function()
        if not bAllValid then return end

		local vars = getBlurVars()

		if not vars then
			return
		end

		-- Set settings
		dxSetShaderValue( radialBlurShader, "sLengthScale", vars.lengthScale )
		dxSetShaderValue( radialBlurShader, "sMaskScale", vars.maskScale )
		dxSetShaderValue( radialBlurShader, "sMaskOffset", vars.maskOffset )
		dxSetShaderValue( radialBlurShader, "sVelZoom", vars.velDirForCam[2] )
		dxSetShaderValue( radialBlurShader, "sVelDir", vars.velDirForCam[1]/2, -vars.velDirForCam[3]/2 )
		dxSetShaderValue( radialBlurShader, "sAmount", vars.amount )

		-- Update screen
		dxUpdateScreenSource( myScreenSource, true )
		dxDrawImage( 0, 0, scx, scy, radialBlurShader )
    end
,true ,"low" .. orderPriority )


----------------------------------------------------------------
-- getBlurVars
--	 Choose which set to use
----------------------------------------------------------------
function getBlurVars()
	local vehVars = getVehicleSpeedBlurVars()
	local camVars = getCameraRotateBlurVars()

	if camVars and camVars.amount > 0.1 then
		return camVars
	end
	if vehVars then
		return vehVars
	end
	if camVars then
		return camVars
	end
	return false
end


----------------------------------------------------------------
-- getVehicleSpeedBlurVars
----------------------------------------------------------------
local camMatPrev = matrix( {{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}} )
function getVehicleSpeedBlurVars()

		-- Get velocity vector and speed
		local camTarget = getCameraTarget()
        if not camTarget then return false end

		local vx,vy,vz = getElementVelocity(camTarget)
		local vehSpeed = getDistanceBetweenPoints3D ( 0,0,0, vx,vy,vz )

		-- Ramp blyr between these two speeds
		local amount = math.unlerpclamped(0.025,vehSpeed,1.22)

		if bSuspendSpeedEffectOnLowFPS then
			amount = amount * fpsScaler
		end

		if amount < 0.001 then
			return false
		end

		-- Calc inverse camera matrix
		local camMat = getRealCameraMatrix()
		local camMatInv = matrix.invert( camMat )

		-- If invalid for some reason, use last valid matrix
		if not camMatInv then
			camMatInv = matrix.invert( camMatPrev )
		else
			camMatPrev = matrix.copy( camMat )
		end

		-- Calculate vehicle velocity direction as seen from the camera
		local velDir = Vector3D:new(vx,vy,vz)
		velDir:Normalize()
		local velDirForCam = matTransformNormal ( camMatInv, {velDir.x,velDir.y,velDir.z} )

		local vars = {}
		vars.lengthScale = 1
		vars.maskScale = {1,1.25}
		vars.maskOffset = {0,0.1}
		vars.velDirForCam = velDirForCam
		vars.amount = amount
		return vars
end


----------------------------------------------------------------
-- getCameraRotateBlurVars
----------------------------------------------------------------
function getCameraRotateBlurVars()
	
		local camTarget = getCameraTarget()
        if not camTarget then return false end

		local bIsInVehicle = (getElementType(camTarget) == "vehicle")

		local obx, oby, obz = getCameraOrbitVelocity()

		local camSpeed = getDistanceBetweenPoints3D ( 0,0,0, obx,oby,obz )
		local amount = math.unlerpclamped(4.20,camSpeed,8.52)
		if bIsInVehicle then
			amount = math.unlerpclamped(8.20,camSpeed,16.52)
		end

		if bSuspendRotateEffectOnLowFPS then
			amount = amount * fpsScaler
		end

		if amount < 0.001 then
			return
		end

		local velDir = Vector3D:new(-obz,oby,-obx)
		velDir:Normalize()
		local velDirForCam = {velDir.x,velDir.y,velDir.z*2}

		local vars = {}
		vars.lengthScale = 0.8
		vars.maskScale = {3,1.25}
		vars.maskOffset = {0,-0.15}
		vars.velDirForCam = velDirForCam
		vars.amount = amount
		return vars
end


-----------------------------------------------------------------------------------
-- getCameraOrbitVelocity
-----------------------------------------------------------------------------------
local prevOrbitX, prevOrbitY, prevOrbitZ = 0,0,0
local prevVel = 0
local prevVelX, prevVelY, prevVelZ = 0,0,0

function getCameraOrbitVelocity ()
	-- Calc Rotational difference from last call
	local x,y,z = getCameraOrbitRotation()
	local vx = x - prevOrbitX
	local vy = y - prevOrbitY
	local vz = z - prevOrbitZ
	prevOrbitX,prevOrbitY,prevOrbitZ = x,y,z

	-- Check for z wrap-around
	vz = vz % 360
	if vz > 180 then
		vz = vz - 360
	end

	-- Check for big instant movements due to camera placement
	local newVel = getDistanceBetweenPoints3D ( 0,0,0, vx,vy,vz )
	if prevVel < 0.01 then
		vx,vy,vz = 0,0,0
	end
	prevVel = newVel

	-- Average with last frame to make it a bit smoother
	local avgX = (prevVelX + vx) * 0.5
	local avgY = (prevVelY + vy) * 0.5
	local avgZ = (prevVelZ + vz) * 0.5
	prevVelX,prevVelY,prevVelZ = vx,vy,vz
	return avgX,avgY,avgZ
end

-----------------------------------------------------------------------------------
-- getCameraOrbitRotation
-----------------------------------------------------------------------------------
function getCameraOrbitRotation ()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local camTarget = getCameraTarget() or localPlayer
	local tx,ty,tz = getElementPosition( camTarget )
	local dx = tx - px
	local dy = ty - py
	local dz = tz - pz
	return getRotationFromDirection( dx, dy, dz )
end

-----------------------------------------------------------------------------------
-- getRotationFromDirection
-----------------------------------------------------------------------------------
function getRotationFromDirection ( dx, dy, dz )
	local rotz = 6.2831853071796 - math.atan2 ( ( dx ), ( dy ) ) % 6.2831853071796
 	local rotx = math.atan2 ( dz, getDistanceBetweenPoints2D ( 0, 0, dx, dy ) )
	rotx = math.deg(rotx)	--Convert to degrees
	rotz = -math.deg(rotz)
 	return rotx, 180, rotz
end

-----------------------------------------------------------------------------------
-- getRealCameraMatrix
--    Returns 4x4 matrix
--    Assumes up is up
-----------------------------------------------------------------------------------
function getRealCameraMatrix()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local fwd = Vector3D:new(lx - px, ly - py, lz - pz)
	local up = Vector3D:new(0, 0, 1)
	fwd:Normalize()
	local dot = fwd:Dot(up)				-- Dot product of primary and secondary axis
	up = up:AddV( fwd:Mul(-dot) )		-- Adjust secondary axis
	up:Normalize()
	local right = fwd:CrossV(up)		-- Calculate last axis

	return matrix{ {right.x, right.y, right.z, 0}, {fwd.x, fwd.y, fwd.z, 0}, {up.x, up.y, up.z, 0}, {px, py, pz, 1} }
end


----------------------------------------------------------------
-- onClientResourceStart
--     Used for auto FPS adjustment
----------------------------------------------------------------
addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		triggerServerEvent("onResourceStartedAtClient",resourceRoot)
	end
)

----------------------------------------------------------------
-- onClientNotifyServerFPSLimit
--     Used for auto FPS adjustment
----------------------------------------------------------------
addEvent("onClientNotifyServerFPSLimit",true)
addEventHandler( "onClientNotifyServerFPSLimit", resourceRoot,
	function(fpsLimit)
		serverFPSLimit = fpsLimit
	end
)

-----------------------------------------------------------------------------------
-- Auto FPS adjustment
-----------------------------------------------------------------------------------
local ticksSmooth = 10
local tickCountPrev = 0
local FPSValue = 60
local fpsScalerRaw = 0

addEventHandler('onClientPreRender', root,
	function(ticks)
		local tickCount = getTickCount()
		ticks = tickCount - tickCountPrev
		ticks = math.min(ticks,100)
		tickCountPrev = tickCount

		ticksSmooth = math.lerp(ticksSmooth,0.025,ticks)
		FPSValue = math.lerp(FPSValue,0.05,1000 / ticksSmooth)

		serverFPSLimit = serverFPSLimit or 36

		-- How much of the FPS limit is being used
		local MaxFPSPercent = 100 * FPSValue / serverFPSLimit

		-- Switch effect between 88% and 95% of FPS
		if fpsScalerRaw > 0 and MaxFPSPercent < 88 then
			fpsScalerRaw = 0
		end
		if fpsScalerRaw == 0 and MaxFPSPercent > 95 then
			fpsScalerRaw = 1
		end

		local dif = fpsScalerRaw - fpsScaler
		local maxDif = ticksSmooth/1000
		dif = math.clamp ( -maxDif, dif, maxDif )
		fpsScaler = fpsScaler + dif

		if bShowDebug then
			dxDrawDBTextPosStart(10,500)
			dxDrawDBText("serverFPSLimit: "..string.format("%1.2f", serverFPSLimit), 10)
			dxDrawDBText("FPSValue: "..string.format("%1.2f", FPSValue), 10)
			dxDrawDBText("ticksSmooth: "..string.format("%1.2f", ticksSmooth), 10)
			dxDrawDBText("fpsScalerRaw: "..string.format("%1.2f", fpsScalerRaw), 10)
			dxDrawDBText("fpsScaler: "..string.format("%1.2f", fpsScaler), 10)
		end

	end
)


---------------------------------------------------------------------------
-- Math extentions
---------------------------------------------------------------------------
function math.lerp(from,alpha,to)
    return from + (to-from) * alpha
end

function math.unlerp(from,pos,to)
	if ( to == from ) then
		return 1
	end
	return ( pos - from ) / ( to - from )
end

function math.clamp(low,value,high)
    return math.max(low,math.min(value,high))
end

function math.unlerpclamped(from,pos,to)
	return math.clamp(0,math.unlerp(from,pos,to),1)
end


---------------------------------------------------------------------------
-- Matrix stuffs
---------------------------------------------------------------------------
function matTransformVector( mat, vec )
	local offX = vec[1] * mat[1][1] + vec[2] * mat[2][1] + vec[3] * mat[3][1] + mat[4][1]
	local offY = vec[1] * mat[1][2] + vec[2] * mat[2][2] + vec[3] * mat[3][2] + mat[4][2]
	local offZ = vec[1] * mat[1][3] + vec[2] * mat[2][3] + vec[3] * mat[3][3] + mat[4][3]
	return {offX, offY, offZ}
end

function matTransformNormal( mat, vec )
	local offX = vec[1] * mat[1][1] + vec[2] * mat[2][1] + vec[3] * mat[3][1]
	local offY = vec[1] * mat[1][2] + vec[2] * mat[2][2] + vec[3] * mat[3][2]
	local offZ = vec[1] * mat[1][3] + vec[2] * mat[2][3] + vec[3] * mat[3][3]
	return {offX, offY, offZ}
end


---------------------------------------------------------------------------
-- Vector3D for somewhere
---------------------------------------------------------------------------
Vector3D = {
	new = function(self, _x, _y, _z)
		local newVector = { x = _x or 0.0, y = _y or 0.0, z = _z or 0.0 }
		return setmetatable(newVector, { __index = Vector3D })
	end,

	Copy = function(self)
		return Vector3D:new(self.x, self.y, self.z)
	end,

	Normalize = function(self)
		local mod = self:Module()
		if mod < 0.00001 then
			self.x, self.y, self.z = 0,0,1
		else
			self.x = self.x / mod
			self.y = self.y / mod
			self.z = self.z / mod
		end
	end,

	Dot = function(self, V)
		return self.x * V.x + self.y * V.y + self.z * V.z
	end,

	Module = function(self)
		return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	end,

	AddV = function(self, V)
		return Vector3D:new(self.x + V.x, self.y + V.y, self.z + V.z)
	end,

	SubV = function(self, V)
		return Vector3D:new(self.x - V.x, self.y - V.y, self.z - V.z)
	end,

	CrossV = function(self, V)
		return Vector3D:new(self.y * V.z - self.z * V.y,
		                    self.z * V.x - self.x * V.z,
							self.x * V.y - self.y * V.x)
	end,

	Mul = function(self, n)
		return Vector3D:new(self.x * n, self.y * n, self.z * n)
	end,

	Div = function(self, n)
		return Vector3D:new(self.x / n, self.y / n, self.z / n)
	end,
}



---------------------------------------------------------------------------
-- debug assist
---------------------------------------------------------------------------
local dbypos = 200
local dbxpos = 200
function dxDrawDBTextPosStart(x,y)
	dbxpos = x
	dbypos = y
end
function dxDrawDBText(msg)
	local shadowColor = tocolor(0,0,0,255)
	local textColor = tocolor(255,255,0,255)
	local textScale = 1.5
	local textFont = "default"
	dxDrawText(msg, dbxpos+1,dbypos+1, 200,20, shadowColor, textScale, textFont, "left", "top", false, false, true )
	dxDrawText(msg, dbxpos,dbypos, 200,20, textColor, textScale, textFont, "left", "top", false, false, true )
	dbypos = dbypos + 30
end
