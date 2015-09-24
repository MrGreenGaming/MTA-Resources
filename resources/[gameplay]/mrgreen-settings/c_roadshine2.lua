--
-- c_roadshine2.lua
--
local shader

function createRoadShader(load)
	if load then
		createCarPaintShader(false)
		-- Version check
		local ver = getVersion ().sortable
		local type = string.sub( ver, 7, 7 )
		local build = string.sub( ver, 9, 13 )
		if build < "02888" and type ~= "1" or ver < "1.1.0" then
			outputChatBox( "Resource is not compatible with this client." )
			outputChatBox( "Please get latest 1.1 nightly from nightly.mtasa.com" )
			return
		end

		-- Create shader
		shader, tec = dxCreateShader ( "roadshine2.fx" )

		if not shader then
			outputChatBox( "Could not create shader. Please use debugscript 3" )
		else

			-- Apply shader to all world textures
			engineApplyShaderToWorldTexture ( shader, "*" )

			-- Begin automatic update of shine direction
			if isTimer(update) then killTimer(update) end
			update = setTimer( updateShineDirection, 600, 0 )
		end
		local node = xmlLoadFile('settings.xml')
		if node then
			local child = xmlFindChild(node, "shader", 1)
			if child then
				local useCarShader = xmlNodeGetAttribute(child, "use")
				if useCarShader == "true" then
					createCarPaintShader(true)
				end	
			end
			xmlSaveFile(node)
			xmlUnloadFile(node)
		end
	else
		if isElement(shader) then destroyElement(shader) end
		if isTimer(update) then killTimer(update) end
	end	
end	

-- Big list describing light direction at a particular game time
shineDirectionList = {
			-- H   M    Direction x, y, z,                  sharpness,	brightness
			{  0,  0,	-0.019183,	0.994869,	-0.099336,	4,			0.0 },			-- Moon fade in start
			{  0, 30,	-0.019183,	0.994869,	-0.099336,	4,			0.25 },			-- Moon fade in end
			{  3, 00,	-0.019183,	0.994869,	-0.099336,	4,			1.0 },			-- Moon bright
			{  6, 30,	-0.019183,	0.994869,	-0.099336,	4,			0.5 },			-- Moon fade out start
			{  6, 39,	-0.019183,	0.994869,	-0.099336,	4,			0.0 },			-- Moon fade out end

			{  6, 40,	-0.914400,	0.377530,	-0.146093,	16,			0.0 },			-- Sun fade in start
			{  6, 50,	-0.914400,	0.377530,	-0.146093,	16,			1.0 },			-- Sun fade in end
			{  7,  0,	-0.891344,	0.377265,	-0.251386,	16,			1.0 },			-- Sun
			{ 10,  0,	-0.678627,	0.405156,	-0.612628,	16,			1.0 },			-- Sun
			{ 13,  0,	-0.303948,	0.490790,	-0.816542,	16,			1.0 },			-- Sun
			{ 16,  0,	 0.169642,	0.707262,	-0.686296,	16,			1.0 },			-- Sun
			{ 18,  0,	 0.380167,	0.893543,	-0.238859,	16,			1.0 },			-- Sun
			{ 18, 30,	 0.398043,	0.911378,	-0.104649,	16,			1.0 },			-- Sun
			{ 18, 53,	 0.360288,	0.932817,	 0.006769,	16,			1.0 },			-- Sun fade out start
			{ 19, 00,	 0.360288,	0.932817,	 0.006769,	16,			0.0 },			-- Sun fade out end

			{ 19, 01,	 0.360288,	0.932817,	-0.612628,	4,			0.0 },			-- General fade in start
			{ 19, 30,	 0.360288,	0.932817,	-0.612628,	4,			0.5 },			-- General fade in end
			{ 21, 00,	 0.360288,	0.932817,	-0.612628,	4,			0.5 },			-- General fade out start
			{ 22, 09,	 0.360288,	0.932817,	-0.612628,	4,			0.0 },			-- General fade out end

			{ 22, 10,	-0.744331,	0.663288,	-0.077591,	32,			0.0 },			-- Star fade in start
			{ 22, 30,	-0.744331,	0.663288,	-0.077591,	32,			0.5 },			-- Star fade in end
			{ 23, 50,	-0.744331,	0.663288,	-0.077591,	32,			0.5 },			-- Star fade out start
			{ 23, 59,	-0.744331,	0.663288,	-0.077591,	32,			0.0 },			-- Star fade out end
			}


function updateShineDirection ()

	-- Get game time
	local h, m = getTime ()
	local fhoursNow = h + m / 60

	-- Find which two lines in the shineDirectionList to blend between
	for idx,v in ipairs( shineDirectionList ) do
		local fhoursTo = v[1] + v[2] / 60
		if fhoursNow <= fhoursTo then

			-- Work out blend from line
			local vFrom = shineDirectionList[ math.max( idx-1, 1 ) ]
			local fhoursFrom = vFrom[1] + vFrom[2] / 60

			-- Calc blend factor
			local f = math.unlerp( fhoursFrom, fhoursTo, fhoursNow )

			-- Calc final direction, sharpness and brightness
			local x = math.lerp( vFrom[3], v[3], f )
			local y = math.lerp( vFrom[4], v[4], f )
			local z = math.lerp( vFrom[5], v[5], f )
			local sharpness  = math.lerp( vFrom[6], v[6], f )
			local brightness = math.lerp( vFrom[7], v[7], f )

			-- Update shader
			dxSetShaderValue( shader, "gLightDir", x, y, z/4 )
			dxSetShaderValue( shader, "gSpecularPower", sharpness )
			dxSetShaderValue( shader, "gLightColor", brightness, brightness, brightness )
			break
		end
	end
end


----------------------------------------------------------------
-- Math helper functions
----------------------------------------------------------------
function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end

function math.unlerp(from,to,pos)
	if ( to == from ) then
		return 1
	end
	return ( pos - from ) / ( to - from )
end

