--
-- c_bloom.lua
--

local scx, scy = guiGetScreenSize()

-----------------------------------------------------------------------------------
-- Le settings
-----------------------------------------------------------------------------------
Settings = {}
Settings.var = {}
Settings.var.cutoff = 0.1
Settings.var.power = 1.88
Settings.var.bloom = 2
Settings.var.blendR = 204
Settings.var.blendG = 153
Settings.var.blendB = 130
Settings.var.blendA = 140
Settings.var.enabled = false



	function createBloomShader(load)
		if load then
		-- Version check
		local ver = getVersion ().sortable
		local type = string.sub( ver, 7, 7 )
		local build = string.sub( ver, 9, 13 )
		if build < "02855" and type ~= "1" or ver < "1.1.0" then
			outputChatBox( "Resource is not compatible with this client." )
			outputChatBox( "Please get latest 1.1 nightly from nightly.mtasa.com" )
			return
		end

		-- Create things
        myScreenSource = dxCreateScreenSource( scx/2, scy/2 )

        blurHShader,tecName = dxCreateShader( "blurH.fx" )
		-- outputDebugString( "blurHShader is using technique " .. tostring(tecName) )

        blurVShader,tecName = dxCreateShader( "blurV.fx" )
		-- outputDebugString( "blurVShader is using technique " .. tostring(tecName) )

        brightPassShader,tecName = dxCreateShader( "brightPass.fx" )
		-- outputDebugString( "brightPassShader is using technique " .. tostring(tecName) )

        addBlendShader,tecName = dxCreateShader( "addBlend.fx" )
		-- outputDebugString( "addBlendShader is using technique " .. tostring(tecName) )

		-- Check everything is ok
		bAllValid = myScreenSource and blurHShader and blurVShader and brightPassShader and addBlendShader
		if not bAllValid then
			outputChatBox( "Could not create some things. Please use debugscript 3" )
		end
		Settings.var.enabled = true
		else
			if isElement(blurHShader) then destroyElement(blurHShader) end
			if isElement(blurVShader) then destroyElement(blurVShader) end
			if isElement(brightPassShader) then destroyElement(brightPassShader) end
			if isElement(addBlendShader) then destroyElement(addBlendShader) end
			bAllValid = false
			Settings.var.enabled = false
		end
	end



-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
addEventHandler( "onClientHUDRender", root,
    function()
		if not Settings.var or not Settings.var.enabled then
			return
		end
        if bAllValid then
			-- Reset render target pool
			RTPool.frameStart()

			-- Update screen
			dxUpdateScreenSource( myScreenSource )

			-- Start with screen
			local current = myScreenSource

			-- Apply all the effects, bouncing from one render target to another
			current = applyBrightPass( current, Settings.var.cutoff, Settings.var.power )
			current = applyDownsample( current )
			current = applyDownsample( current )
			current = applyGBlurH( current, Settings.var.bloom )
			current = applyGBlurV( current, Settings.var.bloom )

			-- When we're done, turn the render target back to default
			dxSetRenderTarget()

			-- Mix result onto the screen using 'add' rather than 'alpha blend'
			dxSetShaderValue( addBlendShader, "tex0", current )
			local col = tocolor(Settings.var.blendR, Settings.var.blendG, Settings.var.blendB, Settings.var.blendA)
			dxDrawImage( 0, 0, scx, scy, addBlendShader, 0,0,0, col )
        end
    end
)








-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------
function applyDownsample( Src, amount )
	amount = amount or 2
	local mx,my = dxGetMaterialSize( Src )
	mx = mx / amount
	my = my / amount
	local newRT = RTPool.GetUnused(mx,my)
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, Src )
	return newRT
end

function applyGBlurH( Src, bloom )
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurHShader, "tex0", Src )
	dxSetShaderValue( blurHShader, "tex0size", mx,my )
	dxSetShaderValue( blurHShader, "bloom", bloom )
	dxDrawImage( 0, 0, mx, my, blurHShader )
	return newRT
end

function applyGBlurV( Src, bloom )
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurVShader, "tex0", Src )
	dxSetShaderValue( blurVShader, "tex0size", mx,my )
	dxSetShaderValue( blurVShader, "bloom", bloom )
	dxDrawImage( 0,  0, mx,my, blurVShader )
	return newRT
end

function applyBrightPass( Src, cutoff, power )
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( brightPassShader, "tex0", Src )
	dxSetShaderValue( brightPassShader, "cutoff", cutoff )
	dxSetShaderValue( brightPassShader, "power", power )
	dxDrawImage( 0,  0, mx,my, brightPassShader )
	return newRT
end


-----------------------------------------------------------------------------------
-- Pool of render targets
-----------------------------------------------------------------------------------
RTPool = {}
RTPool.list = {}

function RTPool.frameStart()
	for rt,info in pairs(RTPool.list) do
		info.bInUse = false
	end
end

function RTPool.GetUnused( mx, my )
	-- Find unused existing
	for rt,info in pairs(RTPool.list) do
		if not info.bInUse and info.mx == mx and info.my == my then
			info.bInUse = true
			return rt
		end
	end
	-- Add new
	-- outputDebugString( "creating new RT " .. tostring(mx) .. " x " .. tostring(mx) )
	local rt = dxCreateRenderTarget( mx, my )
	if rt then
		RTPool.list[rt] = { bInUse = true, mx = mx, my = my }
	end
	return rt
end
