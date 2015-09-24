--
-- c_water.lua
--
myWaterShader = nil
local isSunEnabled = true

function startWaterShine()
		if wsEffectEnabled then return end
		-- Create shader
		myWaterShader, tec = dxCreateShader ( "fx/water.fx",0,0,false )

		if not myWaterShader then
			outputChatBox( "Could not create shader. Please use debugscript 3" )
		else
			outputConsole( "Shader Water2: using technique " .. tec )
			if isSunEnabled then enableSunLight() end

			-- Set textures
			textureVol = dxCreateTexture ( "images/wavemap.png" );
			textureCube = dxCreateTexture ( "images/cube_env256.dds" );
			dxSetShaderValue ( myWaterShader, "sRandomTexture", textureVol );
			dxSetShaderValue ( myWaterShader, "sReflectionTexture", textureCube );

			-- Apply to global txd 13
			engineApplyShaderToWorldTexture ( myWaterShader, "waterclear256" ) 

			-- Update water color incase it gets changed by persons unknown
			watTimer = setTimer(	function()
							if myWaterShader then
								local r,g,b,a = getWaterColor()
								dxSetShaderValue ( myWaterShader, "sWaterColor", r/255, g/255, b/255, a/255 );
								local rSkyTop,gSkyTop,bSkyTop,rSkyBott,gSkyBott,bSkyBott = getSkyGradient ()
								dxSetShaderValue ( myWaterShader, "sSkyColorTop", rSkyTop/255, gSkyTop/255, bSkyTop/255)
								dxSetShaderValue ( myWaterShader, "sSkyColorBott", rSkyBott/255, gSkyBott/255, bSkyBott/255)
								
							end
						end
						,100,0 )
		end
	wsEffectEnabled = true
end

function stopWaterShine()
	if not wsEffectEnabled then return end
	if myWaterShader then
		killTimer(watTimer)
		engineRemoveShaderFromWorldTexture ( myWaterShader, "waterclear256" )
		destroyElement(myWaterShader)
		myWaterShader = nil
		destroyElement(textureVol)
		textureVol = nil
		destroyElement(textureCube)
		textureCube = nil
		wsEffectEnabled = false
	end
end