--
-- c_light_disable.lua
--

local lightDissShader

addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		-- Create shader
		lightDissShader, tec = dxCreateShader ( "light_disable.fx", 0, 0, false, "object" )
		if not lightDissShader then
			outputChatBox( "Could not create light_disable effect.", 255, 0, 0 )
		else
			outputDebugString( tec.." effect has started." )
			-- Apply to world texture
			engineApplyShaderToWorldTexture ( lightDissShader, "*" )
		end
	end
)
