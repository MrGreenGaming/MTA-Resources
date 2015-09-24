--
-- c_sunInfluence.lua
-- Most of the contents of this file come 
-- from roadshine3 shader (shader example)
--

local bSunLightEnabled

local lightDirection = {0,0,1}		-- This gets updated by updateShineDirection()
local sunBrightness = 0.8
--------------------------------
-- Switch effect on
--------------------------------
function enableSunLight()
	if bSunLightEnabled then return end

	-- Update direction all the time
	shineTimer = setTimer( updateShineDirection, 100, 0 )

	-- Flag effect as running
	bSunLightEnabled = true

	-- Some extra things to make it flicker free when starting
	updateVisibility(0)
	updateShineDirection()
	return true
end
--------------------------------
-- Switch effect off
--------------------------------
addEventHandler("onClientResourceStop", resourceRoot, function()
	if not bSunLightEnabled then return end

	killTimer( shineTimer )

	-- Flag effect as stopped
	bSunLightEnabled = false
end
)

--------------------------------
-- Light source visiblility detector
--		Prevent road shine when in tunnels etc.
--------------------------------
local dectectorPos = 1
local dectectorScore = 0
local detectorList = {
					{ x = -1, y = -1, status = 0 },
					{ x =  0, y = -1, status = 0 },
					{ x =  1, y = -1, status = 0 },

					{ x = -1, y =  0, status = 0 },
					{ x =  0, y =  0, status = 0 },
					{ x =  1, y =  0, status = 0 },

					{ x = -1, y =  1, status = 0 },
					{ x =  0, y =  1, status = 0 },
					{ x =  1, y =  1, status = 0 },
				}

function detectNext ()
	-- Step through detectorList - one item per call
	dectectorPos = ( dectectorPos + 1 ) % #detectorList
	dectector = detectorList[dectectorPos+1]

	local lightDirX, lightDirY, lightDirZ = unpack(lightDirection)
	local x, y, z = getElementPosition(localPlayer)

	x = x + dectector.x
	y = y + dectector.y

	local endX = x - lightDirX * 200
	local endY = y - lightDirY * 200
	local endZ = z - lightDirZ * 200

	if dectector.status == 1 then
		dectectorScore = dectectorScore - 1
	end

	dectector.status = isLineOfSightClear ( x,y,z, endX, endY, endZ, true, false, false ) and 1 or 0

	if dectector.status == 1 then
		dectectorScore = dectectorScore + 1
	end

	if dectectorScore < 0 or dectectorScore > 9 then

	end

end


--------------------------------
-- updateVisibility
--		Handle fading of the effect when the light source is not visible
--------------------------------
local fadeTarget = 0
local fadeCurrent = 0
local lastVis = 0
function updateVisibility ( deltaTicks )
	if not bSunLightEnabled then return end

	detectNext ()

	if dectectorScore > 0 then
		fadeTarget = 1
	else
		fadeTarget = 0
	end

	local dif = fadeTarget - fadeCurrent
	local maxChange = deltaTicks / 1000
	dif = math.clamp(-maxChange,dif,maxChange)
	fadeCurrent = fadeCurrent + dif



    local x, y, z,_ ,_ ,_ = getCameraMatrix ()
    local level = getWaterLevel ( x, y, z )
	local sunVis = 0
	if level then
        level = z - level
		sunVis = ((250 - level)/250)
        if sunVis>0 then sunVis = fadeCurrent * sunVis  
		if sunVis>lastVis then lastVis = lastVis + 0.01 end end
		if sunVis>1 then sunVis = 0 end
	else if sunVis<lastVis then lastVis = lastVis-0.01 end end
	-- Update shader
		if myWaterShader then
		dxSetShaderValue( myWaterShader, "sVisibility", lastVis )
		end
end
addEventHandler( "onClientPreRender", root, updateVisibility )


----------------------------------------------------------------
-- updateShineDirection
--		Tracks the strongest light source
----------------------------------------------------------------

-- Big list describing light direction at a particular game time
shineDirectionList = {
			-- H   M    Direction x, y, z,                  sharpness,	brightness,	nightness
			{  0,  0,	-0.019183,	0.994869,	-0.099336,	4,			0.0,		1 },			-- Moon fade in start
			{  0, 30,	-0.019183,	0.994869,	-0.099336,	4,			0.25,		1 },			-- Moon fade in end
			{  3, 00,	-0.019183,	0.994869,	-0.099336,	4,			0.5,		1 },			-- Moon bright
			{  5, 00,	-0.019183,	0.994869,	-0.099336,	4,			0.5,		1 },			-- Moon fade out start
			{  5, 10,	-0.019183,	0.994869,	-0.099336,	4,			0.0,		0 },			-- Moon fade out end

			{  5, 20,	-0.914400,	0.377530,	-0.146093,	4,			0.0,		0 },			-- Sun fade in start
			{  5, 30,	-0.914400,	0.377530,	-0.146093,	4,			1.0,		0 },			-- Sun fade in end
			{  7,  0,	-0.891344,	0.377265,	-0.251386,	4,			1.0,		0 },			-- Sun
			{ 10,  0,	-0.678627,	0.405156,	-0.612628,	4,			0.5,		0 },			-- Sun
			{ 13,  0,	-0.303948,	0.490790,	-0.816542,	4,			0.5,		0 },			-- Sun
			{ 16,  0,	 0.169642,	0.707262,	-0.686296,	4,			0.5,		0 },			-- Sun
			{ 18,  0,	 0.380167,	0.893543,	-0.238859,	4,			0.5,		0 },			-- Sun
			{ 18, 30,	 0.398043,	0.911378,	-0.238859,	4,			1.0,		0 },			-- Sun
			{ 18, 53,	 0.360288,	0.932817,	-0.238859,	1,			1.5,		0 },			-- Sun fade out start
			{ 19, 00,	 0.360288,	0.932817,	-0.238859,	1,			0.0,		0 },			-- Sun fade out end

			{ 19, 01,	 0.360288,	0.932817,	-0.612628,	4,			0.0,		0 },			-- General fade in start
			{ 19, 30,	 0.360288,	0.932817,	-0.612628,	4,			0.5,		0 },			-- General fade in end
			{ 21, 00,	 0.360288,	0.932817,	-0.612628,	4,			0.5,		0 },			-- General fade out start
			{ 22, 09,	 0.360288,	0.932817,	-0.612628,	4,			0.0,		0 },			-- General fade out end

			{ 22, 10,	-0.744331,	0.663288,	-0.077591,	4,			0.0,		1 },			-- Nothing
			{ 23, 59,	-0.744331,	0.663288,	-0.077591,	4,			0.0,		1 },			-- Nothing
			}

function updateShineDirection ()

	-- Get game time
	local h, m, s = getTimeHMS ()
	local fhoursNow = h + m / 60 + s / 3600

	-- Find which two lines in the shineDirectionList to blend between
	for idx,v in ipairs( shineDirectionList ) do
		local fhoursTo = v[1] + v[2] / 60
		if fhoursNow <= fhoursTo then

			-- Work out blend from line
			local vFrom = shineDirectionList[ math.max( idx-1, 1 ) ]
			local fhoursFrom = vFrom[1] + vFrom[2] / 60

			-- Calc blend factor
			local f = math.unlerp( fhoursFrom, fhoursNow, fhoursTo )

			-- Calc final direction, sharpness and brightness
			local x = math.lerp( vFrom[3], f, v[3] )
			local y = math.lerp( vFrom[4], f, v[4] )
			local z = math.lerp( vFrom[5], f, v[5] )
			local sharpness  = math.lerp( vFrom[6], f, v[6] )
			local brightness = math.lerp( vFrom[7], f, v[7] )
			local nightness = math.lerp( vFrom[8], f, v[8] )

			-- Modify depending upon the weather
			sharpness, brightness = applyWeatherInfluence ( sharpness, brightness, nightness )

			-- Half z component when it gets low
			local thresh = -0.128859
			if z < thresh then
				z = (z - thresh) / 2 + thresh
			end

			lightDirection = { x, y, z }
			
			local sunColorTop = {0,0,0}
			local sunColorBott = {0,0,0}
			if fhoursNow > 5.17 and fhoursNow < 23.9 then
			sunColorTop[0], sunColorTop[1], sunColorTop[2], sunColorBott[0], sunColorBott[1], sunColorBott[2] = getSunColor()
			else sunColorTop[0] = 255 sunColorTop[1] = 255 sunColorTop[2] = 255 sunColorBott[0] = 255 sunColorBott[1] = 255 sunColorBott[2] = 255 end
		
			-- Update shaders
			if myWaterShader then 
				dxSetShaderValue( myWaterShader, "sLightDir", x, y, z )
				dxSetShaderValue( myWaterShader, "sSpecularPower", sharpness )
				dxSetShaderValue( myWaterShader, "sSpecularBrightness", brightness )
				dxSetShaderValue( myWaterShader, "sSunColorTop", sunColorTop[0]/255 , sunColorTop[1]/255 , sunColorTop[2]/255 ,sunBrightness)
				dxSetShaderValue( myWaterShader, "sSunColorBott", sunColorBott[0]/255 , sunColorBott[1]/255 , sunColorBott[2]/255 ,sunBrightness)
				end
				
			break
		end
	end
end


----------------------------------------------------------------
-- getWeatherInfluence
--		Modify shine depending on the weather
----------------------------------------------------------------
weatherInfluenceList = {
			-- id   sun:size   :translucency  :bright      night:bright 
			{  0,       1,			0,			1,			1 },		-- Hot, Sunny, Clear
			{  1,       0.8,		0,			1,			1 },		-- Sunny, Low Clouds
			{  2,       0.8,		0,			1,			1 },		-- Sunny, Clear
			{  3,       0.8,		0,			0.8,		1 },		-- Sunny, Cloudy
			{  4,       1,			0,			0.2,		0 },		-- Dark Clouds
			{  5,       3,			0,			0.5,		1 },		-- Sunny, More Low Clouds
			{  6,       3,			1,			0.5,		1 },		-- Sunny, Even More Low Clouds
			{  7,       1,			0,			0.01,		0 },		-- Cloudy Skies
			{  8,       1,			0,			0,			0 },		-- Thunderstorm
			{  9,       1,			0,			0,			0 },		-- Foggy
			{  10,      1,			0,			1,			1 },		-- Sunny, Cloudy (2)
			{  11,      3,			0,			1,			1 },		-- Hot, Sunny, Clear (2)
			{  12,      3,			1,			0.5,		0 },		-- White, Cloudy
			{  13,      1,			0,			0.8,		1 },		-- Sunny, Clear (2)
			{  14,      1,			0,			0.7,		1 },		-- Sunny, Low Clouds (2)
			{  15,      1,			0,			0.1,		0 },		-- Dark Clouds (2)
			{  16,      1,			0,			0,			0 },		-- Thunderstorm (2)
			{  17,      3,			1,			0.8,		1 }, 		-- Hot, Cloudy
			{  18,      3,			1,			0.8,		1 },		-- Hot, Cloudy (2)
			{  19,      1,			0,			0,			0 },		-- Sandstorm
		}


function applyWeatherInfluence ( sharpness, brightness, nightness )

	-- Get info from table
	local id = getWeather()
	id = math.min ( id, #weatherInfluenceList - 1 )
	local item = weatherInfluenceList[ id + 1 ]
	local sunSize  = item[2]
	local sunTranslucency = item[3]
	local sunBright = item[4]
	local nightBright = item[5]

	-- Modify depending on nightness
	local useSize		  = math.lerp( sunSize, nightness, 1 )
	local useTranslucency = math.lerp( sunTranslucency, nightness, 0 )
	local useBright		  = math.lerp( sunBright, nightness, nightBright )

	-- Apply
	brightness = brightness * useBright
	sharpness = sharpness / useSize

	-- Return result
	return sharpness, brightness
end


----------------------------------------------------------------
-- getTimeHMS
--		Returns game time including seconds
----------------------------------------------------------------
local timeHMS = {0,0,0}
local minuteStartTickCount
local minuteEndTickCount

function getTimeHMS()
	return unpack(timeHMS)
end

addEventHandler( "onClientRender", root,
	function ()
		if not bSunLightEnabled then return end
		local h, m = getTime ()
		local s = 0
		if m ~= timeHMS[2] then
			minuteStartTickCount = getTickCount ()
			local gameSpeed = math.clamp( 0.01, getGameSpeed(), 10 )
			minuteEndTickCount = minuteStartTickCount + 1000 / gameSpeed
		end
		if minuteStartTickCount then
			local minFraction = math.unlerpclamped( minuteStartTickCount, getTickCount(), minuteEndTickCount )
			s = math.min ( 59, math.floor ( minFraction * 60 ) )
		end
		timeHMS = {h, m, s}
		--dxDrawText( string.format("%02d:%02d:%02d",h,m,s), 200, 200 )
	end
)



----------------------------------------------------------------
-- Math helper functions
----------------------------------------------------------------
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


