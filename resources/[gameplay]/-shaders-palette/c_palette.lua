--
-- c_palette.lua
--

paletteTable = { customPalette = dxCreateTexture("palette/enbpalette.bmp"), palEffectEnabled = false, paletteEnabled = true, 
				chromaticEnabled = false, orderPriority = "-3.5" }

Settings = {}
Settings.var = {}


--------------------------------
-- Switch effect on
--------------------------------
function enablePalette()
	if paletteTable.palEffectEnabled then return end

	-- Input texture
    myScreenSourceFull = dxCreateScreenSource( scx, scy )

	-- Shaders
	chromaticShader = dxCreateShader( "fx/chromatic.fx" )
	paletteShader = dxCreateShader( "fx/palette.fx" )
	chosenPalette = paletteTable.customPalette
	
	-- A table to store the results of scene luminance calculations
	lumTemp = dxCreateScreenSource( 512, 512 )
	lumSamples = {}
	currLumSample = 0

	-- Get list of all elements used
	effectParts = {
						myScreenSourceFull,
						paletteShader,
						chromaticShader,
						chosenPalette,
						lumTemp
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end

	setEffectVariables ()
	paletteTable.palEffectEnabled = true

	if not bAllValid then
		outputChatBox( "Could not create some things. Please use debugscript 3" )
		disablePalette()
		else
		dxSetShaderValue( paletteShader, "sPaletteTexture", chosenPalette )
	end
end


--------------------------------
-- Switch effect off
--------------------------------
function disablePalette()
	if not paletteTable.palEffectEnabled then return end

	-- Destroy all shaders
	-- for _,part in ipairs(effectParts) do
	-- 	if part then
	-- 		destroyElement( part )
	-- 	end
	-- end
	effectParts = {}
	bAllValid = false
	RTPool.clear()

	-- Flag effect as stopped
	paletteTable.palEffectEnabled = false
end


---------------------------------
-- Settings for effect
---------------------------------
function setEffectVariables()
    local v = Settings.var
    -- Palette
    v.PaletteEnabled = paletteTable.paletteEnabled
    v.timeGap = 5
    v.maxLumSamples = 50
-- Chromatic Abberation
    v.ChromaticEnabled = paletteTable.chromaticEnabled
    v.ChromaticAmount = 0.009
    v.LensSize = 0.515
    v.LensDistortion = 0.05
    v.LensDistortionCubic = 0.05
	-- Debugging
    v.PreviewEnable=0
    v.PreviewPosY=0
    v.PreviewPosX=100
    v.PreviewSize=70
end


----------------------------------------------------------------
-- Render
----------------------------------------------------------------
addEventHandler( "onClientHUDRender", root,
    function()
		if not bAllValid or not Settings.var then return end
		local v = Settings.var

		RTPool.frameStart()
		DebugResults.frameStart()

		dxUpdateScreenSource( myScreenSourceFull, true )
		dxUpdateScreenSource( lumTemp, true )

		local current1 = myScreenSourceFull
		if v.ChromaticEnabled then
			current1 = applyChromatic( current1, v.ChromaticAmount,v.LensSize, v.LensDistortion, v.LensDistortionCubic )
		end
		if v.PaletteEnabled then
			local myPixel = countLuminanceForPalette(lumTemp,v.timeGap,v.maxLumSamples)
			current1 = applyPalette( current1, myPixel )
		end

		dxSetRenderTarget()
		if current1 then dxDrawImage( 0, 0, scx, scy, current1, 0, 0, 0, tocolor(255,255,255,255) ) end
		-- Debug stuff
		if v.PreviewEnable > 0.5 then
			DebugResults.drawItems ( v.PreviewSize, v.PreviewPosX, v.PreviewPosY )
		end
    end
,true ,"low" .. paletteTable.orderPriority )


----------------------------------------------------------------
-- post process items
----------------------------------------------------------------
function applyChromatic( src, chromaticAmount,lensSize, lensDistortion, lensDistortionCubic )
	if not src then return nil end
	local mx,my = dxGetMaterialSize( src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( chromaticShader, "sBaseTexture", src )
	dxSetShaderValue( chromaticShader, "ChromaticAmount", chromaticAmount )
	dxSetShaderValue( chromaticShader, "LensSize", lensSize )
	dxSetShaderValue( chromaticShader, "LensDistortion", lensDistortion )
	dxSetShaderValue( chromaticShader, "LensDistortionCubic", lensDistortionCubic )
	dxDrawImage( 0, 0, mx,my, chromaticShader )
	DebugResults.addItem( newRT, "Chromatic" )
	return newRT
end

function applyPalette( src, lumPixel )
	if not src then return nil end
	local mx,my = dxGetMaterialSize( src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( paletteShader, "sBaseTexture", src )
	dxSetShaderValue( paletteShader, "sLumPixel", lumPixel )
	dxDrawImage( 0, 0, mx,my, paletteShader )
	DebugResults.addItem( newRT, "Palette" )
	return newRT
end

function countMedianPixelColor(daTable)
	local sum_r,sum_g,sum_b=0,0,0
	for _,tValue in ipairs(daTable) do
	local r,g,b,a = dxGetPixelColor( tValue, 0, 0 )
		sum_r=sum_r+r
		sum_g=sum_g+g
		sum_b=sum_b+b
	end
	return {(sum_r/#daTable)/255,(sum_g/#daTable)/255,(sum_b/#daTable)/255}
end

local lastPix={1,1,1}
local lastTickCount=0
function countLuminanceForPalette(luminance,lumPause,maxLumSamples)
	if getTickCount() > lastTickCount then
		local mx,my = dxGetMaterialSize( luminance );
		local size = 1
		while ( size < mx / 2 or size < my / 2 ) do
			size = size * 2
		end
		luminance = applyResize( luminance, size, size )
		while ( size > 1 ) do
			size = size / 2
			luminance = applyDownsample( luminance, 2 )
		end
		if (currLumSample>maxLumSamples) then 
			currLumSample=0 
		end
		lumSamples[currLumSample]=dxGetTexturePixels(luminance)
		local pix=countMedianPixelColor(lumSamples)
		currLumSample=currLumSample+1
		lastPix=pix
		lastTickCount=getTickCount()+lumPause
		return pix
	else
		return lastPix
	end
end

function applyResize( src, tx, ty )
	if not src then return nil end
	local newRT = RTPool.GetUnused(tx, ty)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0,  0, tx, ty, src )
	DebugResults.addItem( newRT, "Resize" )
	return newRT
end

function applyDownsampleSteps( src, steps )
	if not src then return nil end
	for i=1,steps do
		src = applyDownsample ( src )
	end
	return src
end

function applyDownsample( src )
	if not src then return nil end
	local mx,my = dxGetMaterialSize( src )
	mx = mx / 2
	my = my / 2
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, src )
	DebugResults.addItem( newRT, "Downsample" )
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
