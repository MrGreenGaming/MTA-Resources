--
-- c_dof.lua
--
local orderPriority = "-2.7"	-- The lower this number, the later the effect is applied

Settings = {}
Settings.var = {}

---------------------------------
-- Version check
---------------------------------
function isMTAUpToDate()
	local mtaVer = getVersion().sortable
	-- outputDebugString("MTA Version: "..tostring(mtaVer))
	if getVersion ().sortable < "1.3.4-9.05899" then
		return false
	else
		return true
	end
end

---------------------------------
-- DepthBuffer access
---------------------------------
function isDepthBufferAccessible()
	local info=dxGetStatus()
	local depthStatus=false
		for k,v in pairs(info) do
			if string.find(k, "DepthBufferFormat") then
				-- outputDebugString("DepthBufferFormat: "..tostring(v))
				depthStatus=true
				if tostring(v)=='unknown' then depthStatus=false end
			end
		end
	return depthStatus
end

----------------------------------
--dxGetStatus for debuging
----------------------------------
addCommandHandler( "dxGetStatus",
function()
	local info=dxGetStatus()
	local outStr = ''
	for k,v in pairs(info) do
		outStr = outStr..' '..k..': '..tostring(v)..'  ,'
	end
	-- outputDebugString(outStr)
	setClipboard(outStr)
	outputChatBox('---dxGetStatus copied to clipboard---' )
end
)

----------------------------------------------------------------
-- enableDoF
----------------------------------------------------------------
function enableDoF()
	if dEffectEnabled then return end
	-- Create things
	myScreenSource = dxCreateScreenSource( scx, scy )
	
	dBlurHShader,tecName = dxCreateShader( "fx/dBlurH.fx" )
	-- outputDebugString( "blurHShader is using technique " .. tostring(tecName) )

	dBlurVShader,tecName = dxCreateShader( "fx/dBlurV.fx" )
	-- outputDebugString( "blurVShader is using technique " .. tostring(tecName) )
	
	dBShader,tecName = dxCreateShader( "fx/getDepth.fx" )
	-- outputDebugString( "dBShader is using technique " .. tostring(tecName) )
	
	-- Get list of all elements used
	effectParts = {
						myScreenSource,
						dBlurHShader,
						dBlurVShader,
						dBShader,
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end
	
	setEffectVariables ()
	dEffectEnabled = true
	
	if not bAllValid then
		outputChatBox( "DoF: Could not create some things. Please use debugscript 3" )
		disableDoF()
	else
		distTimer = setTimer(function()
			Settings.var.farClip = getFarClipDistance () * 0.9995
		end,100,0 )
	end	
end

----------------------------------------------------------------
-- disableDoF
----------------------------------------------------------------
function disableDoF()
	if not dEffectEnabled then return end
	-- Destroy all shaders
	for _,part in ipairs(effectParts) do
		if part then
			destroyElement( part )
		end
	end
	effectParts = {}
	if distTimer then 
		killTimer(distTimer)
		distTimer = nil
	end
	bAllValid = false
	RTPool.clear()
	
	-- Flag effect as stopped
	dEffectEnabled = false
end

---------------------------------
-- Settings for effect
---------------------------------
function setEffectVariables()
    local v = Settings.var
    -- DoF
    v.blurFactor = 0.9 -- blur ammount
    v.brightBlur = true -- should darker pixel get less blur
	-- Depth Spread
    v.fadeStart = 1
    v.fadeEnd = 700
    v.maxCut = true -- should the sky not to be blured
    v.farClip = 1000 -- changes depending on the farClip
    v.maxCutBlur = 0.5 -- max sky blur (percentage of orig blur)

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
			local getDepth = getDepthBuffer( current,v.fadeStart,v.fadeEnd ,v.farClip,v.maxCut,v.maxCutBlur ) 
			current = applyGDepthBlurH( current,getDepth,v.blurFactor,v.brightBlur )
			current = applyGDepthBlurV( current,getDepth,v.blurFactor,v.brightBlur )

			-- When we're done, turn the render target back to default
			dxSetRenderTarget()
			
			if current then dxDrawImage( 0, 0, scx, scy, current, 0, 0, 0, tocolor(255,255,255,255) ) end
			--if getDepth then dxDrawImage( 0.75*scx, 0, scx/4, scy/4, getDepth, 0, 0, 0, tocolor(255,255,255,255) ) end
			-- Debug stuff
			if v.PreviewEnable > 0.5 then
				DebugResults.drawItems ( v.PreviewSize, v.PreviewPosX, v.PreviewPosY )
			end
		end
,true ,"low" .. orderPriority )

-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------
function getDepthBuffer(Src, fadeStart, fadeEnd, farClip, maxCut, maxCutBlur ) 
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( dBShader, "gFadeStart", fadeStart )
	dxSetShaderValue( dBShader, "gFadeEnd",fadeEnd )
	dxSetShaderValue( dBShader, "sFarClip", farClip )
	dxSetShaderValue( dBShader, "sMaxCut", maxCut )
	dxSetShaderValue( dBShader, "sMaxCutBlur", maxCutBlur )
	dxDrawImage( 0, 0, mx, my, dBShader )
	DebugResults.addItem( newRT, "GetDepthValues" )
	return newRT
end

function applyGDepthBlurH( Src,getDepth,blur,brightBlur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( dBlurHShader, "TEX0", Src )
	dxSetShaderValue( dBlurHShader, "TEX1", getDepth )
	dxSetShaderValue( dBlurHShader, "tex0size", mx,my )
	dxSetShaderValue( dBlurVShader, "gblurFactor",blur )
	dxSetShaderValue( dBlurVShader, "gBrightBlur",brightBlur )
	dxDrawImage( 0, 0, mx, my, dBlurHShader )
	DebugResults.addItem( newRT, "DepthBlurH" )
	return newRT
end

function applyGDepthBlurV( Src,getDepth,blur,brightBlur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( dBlurVShader, "TEX0", Src )
	dxSetShaderValue( dBlurVShader, "TEX1", getDepth )
	dxSetShaderValue( dBlurVShader, "tex0size", mx,my )
	dxSetShaderValue( dBlurVShader, "gblurFactor",blur )
	dxDrawImage( 0, 0, mx,my, dBlurVShader )
	DebugResults.addItem( newRT, "DepthBlurV" )
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