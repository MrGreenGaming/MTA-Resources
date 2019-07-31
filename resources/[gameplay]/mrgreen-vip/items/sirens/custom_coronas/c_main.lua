-------------------------------------
--Resource: Shader Custom Coronas  --
--Author: Ren712                   --
--Contact: knoblauch700@o2.pl      --
-------------------------------------

coronaTable = { inputCoronas = {} , outputCoronas = {} , thisCorona = 0 , isInNrChanged = false,
				numberType = {0, 0, 0}, shaderType = {nil, nil}, isInValChanged = false, isStarted = false, 
				maxCoronas = 300, depthBias = true, sorted = 0, tempFade = 0 }
funcTable = {}
local img = dxCreateTexture( "textures/coronastar.png", "dxt5" )

---------------------------------------------------------------------------------------------------
-- editable variables
---------------------------------------------------------------------------------------------------						 
shaderSettings = {
				gDistFade = {420, 380}, -- [0]MaxEffectFade,[1]MinEffectFade
				fDepthSpread = 0.4, 
				fDistAdd = -2.5,
				fDistMult = 1.0,
				edgeTolerance = 0.35 -- cull the effects that are off the screen
				}


---------------------------------------------------------------------------------------------------
-- main functions
---------------------------------------------------------------------------------------------------
function funcTable.createCorona(cType,posX,posY,posZ,size,colorR,colorG,colorB,colorA)
	local w = findEmptyEntry(coronaTable.inputCoronas)
	if not coronaTable.inputCoronas[w] then 
		coronaTable.inputCoronas[w] = {}
	end
	coronaTable.inputCoronas[w].enabled = true
	coronaTable.inputCoronas[w].material = false
	coronaTable.inputCoronas[w].cType = cType
	coronaTable.numberType[cType] = coronaTable.numberType[cType] + 1
	coronaTable.inputCoronas[w].shader = funcTable.createShader(cType,coronaTable.numberType[cType])
	coronaTable.inputCoronas[w].size = {size,size}
	coronaTable.inputCoronas[w].dBias = math.min(size,1)
	coronaTable.inputCoronas[w].pos = {posX,posY,posZ}
	coronaTable.inputCoronas[w].color = {colorR,colorG,colorB,colorA}	
	coronaTable.isInNrChanged = true
	if not funcTable.applySettings( coronaTable.inputCoronas[w].shader, cType, coronaTable.numberType[cType] ) or
		not funcTable.applyTexture( coronaTable.inputCoronas[w].shader, img, cType, coronaTable.numberType[cType] ) then
		outputDebugString('Have Not Created Corona ID: '..w)
		return false
	else
		outputDebugString('Created Corona ID:'..w..' type: '..cType..' nr: '..coronaTable.numberType[cType])
		return w
	end
end

function funcTable.createMaterialCorona(texImage,cType,posX,posY,posZ,size,colorR,colorG,colorB,colorA)
	local w = findEmptyEntry(coronaTable.inputCoronas)
	if not coronaTable.inputCoronas[w] then 
		coronaTable.inputCoronas[w] = {}
	end
	coronaTable.inputCoronas[w].enabled = true
	coronaTable.inputCoronas[w].material = true
	coronaTable.inputCoronas[w].cType = cType
	coronaTable.numberType[3] = coronaTable.numberType[3] + 1
	coronaTable.inputCoronas[w].shader = funcTable.createShader(cType,false)
	coronaTable.inputCoronas[w].size = {size,size}
	coronaTable.inputCoronas[w].dBias = math.min(size,1)
	coronaTable.inputCoronas[w].pos = {posX,posY,posZ}
	coronaTable.inputCoronas[w].color = {colorR,colorG,colorB,colorA}	
	coronaTable.isInNrChanged = true
	if not funcTable.applySettings( coronaTable.inputCoronas[w].shader, false, false ) or 
		not funcTable.applyTexture( coronaTable.inputCoronas[w].shader, texImage, false, false ) then
		outputDebugString('Have Not Created Tex Corona ID: '..w)
		return false
	else
		outputDebugString('Created Tex Corona ID:'..w..' type: '..cType)
		return w
	end
end

function funcTable.destroy(w)
	if coronaTable.inputCoronas[w] then
		local cType = coronaTable.inputCoronas[w].cType
		coronaTable.inputCoronas[w].enabled = false
		if coronaTable.inputCoronas[w].material then
			coronaTable.numberType[3] = coronaTable.numberType[3] - 1
			coronaTable.inputCoronas[w].shader = not funcTable.destroyShader( coronaTable.inputCoronas[w].shader, false, false)
		else
			coronaTable.numberType[cType] = coronaTable.numberType[cType] - 1
			coronaTable.inputCoronas[w].shader = not funcTable.destroyShader( coronaTable.inputCoronas[w].shader, cType, coronaTable.numberType[cType])
		end
		coronaTable.isInNrChanged = true
		outputDebugString('Destroyed Corona ID: '..w..' nr: '..coronaTable.numberType[cType])
		return not coronaTable.inputCoronas[w].shader
	else
		outputDebugString('Have Not Destroyed Corona ID: '..w)
		return false 
	end
end

function funcTable.setMaterial(w,texImage)
	if coronaTable.inputCoronas[w].enabled then
		if coronaTable.inputCoronas[w].material then
			outputDebugString('Set Corona texture ID: '..w)
			return funcTable.applyTexture( coronaTable.inputCoronas[w].shader, texImage, false, false )
		else
			outputDebugString('Warning: Is not material Corona ID: '..w)
			return false
		end
	else
		return false
	end
end

function funcTable.setDistFade(w,v)
	if  (w >= v) then
		shaderSettings.gDistFade = {w,v}
		coronaTable.isInNrChanged = true
		for index,this in ipairs( coronaTable.inputCoronas ) do
			if this.enabled and this.material then
				funcTable.applySettings( this.shader, false, false )
			end
		end
		if coronaTable.shaderType[1] then funcTable.applySettings( coronaTable.shaderType[1], false, 1 ) end
		if coronaTable.shaderType[2] then funcTable.applySettings( coronaTable.shaderType[2], false, 1 ) end
		return true
	else
		return false
	end
end

---------------------------------------------------------------------------------------------------
-- creating and sorting a table of active coronas
---------------------------------------------------------------------------------------------------
local tickCount = getTickCount()
addEventHandler("onClientPreRender",root, function()
	if (#coronaTable.inputCoronas == 0) then
		return 
	end

	if coronaTable.isInNrChanged then
		local distFac = coronaTable.maxCoronas / coronaTable.sorted
		if distFac < 0.25 then coronaTable.tempFade = coronaTable.tempFade - 5/distFac 
			else coronaTable.tempFade = coronaTable.tempFade + 5/distFac  end
		coronaTable.tempFade = math.min(coronaTable.tempFade, shaderSettings.gDistFade[1]) 
		coronaTable.outputCoronas = sortedOutput( coronaTable.inputCoronas, true, coronaTable.tempFade, coronaTable.maxCoronas )
		coronaTable.sorted = #coronaTable.outputCoronas 
		coronaTable.isInNrChanged = false
		return
	elseif coronaTable.isInValChanged or ( tickCount + 120 < getTickCount() ) then
		local distFac = coronaTable.maxCoronas / coronaTable.sorted
		if distFac < 0.25 then coronaTable.tempFade = coronaTable.tempFade - 5/distFac 
			else coronaTable.tempFade = coronaTable.tempFade + 5/distFac  end
		coronaTable.tempFade = math.min(coronaTable.tempFade, shaderSettings.gDistFade[1])
		coronaTable.outputCoronas = sortedOutput( coronaTable.inputCoronas, true, coronaTable.tempFade, coronaTable.maxCoronas )
		coronaTable.sorted = #coronaTable.outputCoronas 
		coronaTable.isInValChanged = false
		tickCount = getTickCount()
	end
	if #coronaTable.outputCoronas == 0 then coronaTable.tempFade = shaderSettings.gDistFade[1] end
end
,true ,"low-1")

---------------------------------------------------------------------------------------------------
-- set shader values of active coronas
---------------------------------------------------------------------------------------------------
addEventHandler("onClientPreRender", root, function()
	if (#coronaTable.outputCoronas == 0) then
		return 
	end 
	if not coronaTable.isStarted then 
		return 
	end
	coronaTable.thisCorona = 0
	for index,this in ipairs( coronaTable.outputCoronas ) do
		if this.dist <= shaderSettings.gDistFade[1] and this.enabled and coronaTable.thisCorona < coronaTable.maxCoronas then
			local isOnScrX, isOnScrY, isOnScrZ = getScreenFromWorldPosition ( this.pos[1], this.pos[2], this.pos[3], shaderSettings.edgeTolerance, true )
			if ((( isOnScrX and isOnScrY and isOnScrZ ) or ( this.dist <= shaderSettings.gDistFade[1]*0.15 ))) then
				local current = nil
				if this.material then current = this.shader else current = coronaTable.shaderType[this.cType] end
				if current then
					dxSetShaderValue( current, "fCoronaPosition",this.pos[1], this.pos[2], this.pos[3])
					if coronaTable.depthBias then
						dxSetShaderValue( current, "fDepthBias",this.dBias)
					else
						dxSetShaderValue( current, "fDepthBias",1)
					end
					dxDrawMaterialLine3D( 0 + this.pos[1], 0 + this.pos[2], this.pos[3] - this.size[2] * 2, 0 + this.pos[1], 0 + this.pos[2], 
						this.pos[3] + this.size[2] * 2, current, this.size[1] * 4, tocolor(this.color[1],this.color[2],this.color[3],this.color[4]),
						0 + this.pos[1],1 +  this.pos[2],0 + this.pos[3] )	
					coronaTable.thisCorona = coronaTable.thisCorona + 1
				end
			end
		end
	end
end
,true ,"low-2")

---------------------------------------------------------------------------------------------------
-- add or remove shader settings 
---------------------------------------------------------------------------------------------------
function funcTable.createShader(cType,nrType)
	local pathString = "shaders/custom_corona"..(cType-1)..".fx"	
	local theShader = nil
	if nrType then
		if (nrType == 1) then 
			coronaTable.shaderType[cType], technique = dxCreateShader( pathString ,0,0,false,"all") 
			outputDebugString('Created base shader for non material coronas type: '..cType..' Technique: '..technique)
		end
		theShader = true
	else
		theShader, technique = dxCreateShader( pathString ,0,0,false,"all")
		outputDebugString('Created shader for material corona technique: '..technique)
	end	
	if theShader then
		--outputDebugString('Using shader type: '..cType)
		return theShader
	else
		return false
	end
end

function funcTable.destroyShader(theShader,cType,nrType)
	if cType then
		if (nrType == 0) then
			theShader = destroyElement ( coronaTable.shaderType[cType] )
			outputDebugString('Destroyed base shader for non material coronas type: '..cType)
		end
		theShader = nil
	else	
		theShader = destroyElement ( theShader )
		outputDebugString('Destroyed shader for material corona')
		theShader = nil
	end
	return not theShader
end

function funcTable.applySettings(theShader,cType,nrType)
	if theShader then
		if not cType or (cType > 2) then
			dxSetShaderValue ( theShader, "gDistFade", shaderSettings.gDistFade )
			dxSetShaderValue ( theShader, "fDepthSpread", shaderSettings.fDepthSpread )
			dxSetShaderValue ( theShader, "fDistAdd", shaderSettings.fDistAdd )
			dxSetShaderValue ( theShader, "fDistMult", shaderSettings.fDistMult )
			--outputDebugString('Applied settings to material shader')
			return true
		elseif cType and (nrType == 1) then
			dxSetShaderValue ( coronaTable.shaderType[cType], "gDistFade", shaderSettings.gDistFade )
			dxSetShaderValue ( coronaTable.shaderType[cType], "fDepthSpread", shaderSettings.fDepthSpread )
			dxSetShaderValue ( coronaTable.shaderType[cType], "fDistAdd", shaderSettings.fDistAdd )
			dxSetShaderValue ( coronaTable.shaderType[cType], "fDistMult", shaderSettings.fDistMult )
			--outputDebugString('Applied settings to non material shader')			
			return true
		else
			--outputDebugString('Settings already applied to non material shader')
			return true
		end
	else
		return false
	end
end

function funcTable.applyTexture(theShader,tex,cType,nrType)
	if theShader then
		if ((nrType == false)) then
			dxSetShaderValue ( theShader, "gCoronaTexture", tex )
			outputDebugString ('Applied texture to material corona shader')
			return true
		elseif cType and (nrType == 1) then
			dxSetShaderValue ( coronaTable.shaderType[cType], "gCoronaTexture", tex )
			outputDebugString ('Applied texture to type '..cType..' shader')			
			return true
		else
			--outputDebugString('Texture already applied to non material shader')
			return true
		end
	else
		return false
	end
end

---------------------------------------------------------------------------------------------------
-- onClientResourceStart 
---------------------------------------------------------------------------------------------------		
addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	if not isMTAUpToDate() then 
		outputChatBox('Custom Coronas: The resource is not compatible with this client version!',255,0,0)
		return
	end
	if not isDepthBufferAccessible() then
		outputDebugString('Custom Coronas: Shader readable depth buffer not available!')
	end
	if not img then
		outputChatBox('Custom Coronas: Could not load the corona texture!',255,0,0)
		return
	end
	coronaTable.tempFade = shaderSettings.gDistFade[1]
	coronaTable.sorted = coronaTable.maxCoronas
	coronaTable.isStarted = true
end
)
