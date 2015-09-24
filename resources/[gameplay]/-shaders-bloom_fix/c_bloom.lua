--
-- c_bloom.lua
--
local orderPriority = "-1.0"	-- The lower this number, the later the effect is applied

Settings = {}
Settings.var = {}

----------------------------------------------------------------
-- enableBloom
----------------------------------------------------------------

function enableBloom()
	if bEffectEnabled then return end
	-- Create things
	myScreenSource = dxCreateScreenSource( scx/2, scy/2 )

	blurHShader,tecName = dxCreateShader( "fx/blurH.fx" )
	-- outputDebugString( "blurHShader is using technique " .. tostring(tecName) )

	blurVShader,tecName = dxCreateShader( "fx/blurV.fx" )
	-- outputDebugString( "blurVShader is using technique " .. tostring(tecName) )

	brightPassShader,tecName = dxCreateShader( "fx/brightPass.fx" )
	-- outputDebugString( "brightPassShader is using technique " .. tostring(tecName) )

    addBlendShader,tecName = dxCreateShader( "fx/addBlend.fx" )
	-- outputDebugString( "addBlendShader is using technique " .. tostring(tecName) )

	-- Get list of all elements used
	effectParts = {
						myScreenSource,
						blurVShader,
						blurHShader,
						brightPassShader,
						addBlendShader,
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end
	
	setEffectVariables ()
	bEffectEnabled = true
	
	if not bAllValid then
		outputChatBox( "Bloom: Could not create some things." )
		disableBloom()
	end	
end

-----------------------------------------------------------------------------------
-- disableBloom
-----------------------------------------------------------------------------------
function disableBloom()
	if not bEffectEnabled then return end
	-- Destroy all shaders
	for _,part in ipairs(effectParts) do
		if part then
			destroyElement( part )
		end
	end
	effectParts = {}
	bAllValid = false
	RTPool.clear()
	
	-- Flag effect as stopped
	bEffectEnabled = false
end

---------------------------------
-- Settings for effect
---------------------------------
function setEffectVariables()
    local v = Settings.var
    -- Bloom
    v.cutoff = 0.08
    v.power = 1.88
	v.blur = 0.9
    v.bloom = 1.7
    v.blendR = 204
    v.blendG = 153
    v.blendB = 130
    v.blendA = 100

	-- Debugging
    v.PreviewEnable=0
    v.PreviewPosY=0
    v.PreviewPosX=100
    v.PreviewSize=70
end

-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
addEventHandler( "onClientHUDRender", root,
    function()
		if not bAllValid or not Settings.var then return end
		local v = Settings.var	
			
		-- Reset render target pool
		RTPool.frameStart()
		DebugResults.frameStart()
		-- Update screen
		dxUpdateScreenSource( myScreenSource, true )
			
		-- Start with screen
		local current = myScreenSource

		-- Apply all the effects, bouncing from one render target to another
		current = applyBrightPass( current, v.cutoff, v.power )
		current = applyDownsample( current )
		current = applyDownsample( current )
		current = applyGBlurH( current, v.bloom, v.blur )
		current = applyGBlurV( current, v.bloom, v.blur )

		-- When we're done, turn the render target back to default
		dxSetRenderTarget()

		-- Mix result onto the screen using 'add' rather than 'alpha blend'
		if current then
			dxSetShaderValue( addBlendShader, "TEX0", current )
			local col = tocolor(v.blendR, v.blendG, v.blendB, v.blendA)
			dxDrawImage( 0, 0, scx, scy, addBlendShader, 0,0,0, col )
		end
		-- Debug stuff
		if v.PreviewEnable > 0.5 then
			DebugResults.drawItems ( v.PreviewSize, v.PreviewPosX, v.PreviewPosY )
		end
	end
,true ,"low" .. orderPriority )


-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------
function applyDownsample( Src, amount )
	if not Src then return nil end
	amount = amount or 2
	local mx,my = dxGetMaterialSize( Src )
	mx = mx / amount
	my = my / amount
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, Src )
	DebugResults.addItem( newRT, "applyDownsample" )
	return newRT
end

function applyGBlurH( Src, bloom, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurHShader, "TEX0", Src )
	dxSetShaderValue( blurHShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurHShader, "BLOOM", bloom )
	dxSetShaderValue( blurHShader, "BLUR", blur )
	dxDrawImage( 0, 0, mx, my, blurHShader )
	DebugResults.addItem( newRT, "applyGBlurH" )
	return newRT
end

function applyGBlurV( Src, bloom, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurVShader, "TEX0", Src )
	dxSetShaderValue( blurVShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurVShader, "BLOOM", bloom )
	dxSetShaderValue( blurVShader, "BLUR", blur )
	dxDrawImage( 0, 0, mx,my, blurVShader )
	DebugResults.addItem( newRT, "applyGBlurV" )
	return newRT
end

function applyBrightPass( Src, cutoff, power )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( brightPassShader, "TEX0", Src )
	dxSetShaderValue( brightPassShader, "CUTOFF", cutoff )
	dxSetShaderValue( brightPassShader, "POWER", power )
	dxDrawImage( 0, 0, mx,my, brightPassShader )
	DebugResults.addItem( newRT, "applyBrightPass" )
	return newRT
end


----------------------------------------------------------------
-- Avoid errors messages when memory is low
----------------------------------------------------------------
_dxDrawImage = dxDrawImage
function xdxDrawImage(posX, posY, width, height, image, ... )
	if not image then return false end
	return _dxDrawImage( posX, posY, width, height, image, ... )
end
