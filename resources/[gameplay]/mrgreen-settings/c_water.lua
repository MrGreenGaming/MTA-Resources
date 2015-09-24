--
-- c_water.lua
--
local myShader


function createWaterShader(load)
	if load then
		-- Version check
		local ver = getVersion ().sortable
		local type = string.sub( ver, 7, 7 )
		local build = string.sub( ver, 9, 13 )
		if build < "02866" and type ~= "1" or ver < "1.1.0" then
			outputChatBox( "Resource is not compatible with this client." )
			outputChatBox( "Please get latest 1.1 nightly from nightly.mtasa.com" )
			return
		end

		-- Create shader
		myShader, tec = dxCreateShader ( "water.fx" )

		if not myShader then
			outputChatBox( "Could not create shader. Please use debugscript 3" )
		else
--			outputChatBox( "Using technique " .. tec )

				-- Set textures
			local textureVol = dxCreateTexture ( "images/smallnoise3d.dds" );
			local textureCube = dxCreateTexture ( "images/cube_env256.dds" );
			dxSetShaderValue ( myShader, "microflakeNMapVol_Tex", textureVol );
			dxSetShaderValue ( myShader, "showroomMapCube_Tex", textureCube );
			engineApplyShaderToWorldTexture ( myShader, "waterclear256" )
			if isTimer(waterTimer) then killTimer(waterTimer) end
			waterTimer = setTimer ( checkWaterColor, 1000, 0 )
		end
	else
			if isTimer(waterTimer) then killTimer ( waterTimer ) end
			if isElement(myShader) then engineRemoveShaderFromWorldTexture ( myShader, "waterclear256" ) destroyElement(myShader) end
	end
	end


function checkWaterColor ( )
	if myShader then
		local r,g,b,a = getWaterColor()
		dxSetShaderValue ( myShader, "waterColor", r/255, g/255, b/255, a/255 );
	end
end


