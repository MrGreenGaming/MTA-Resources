--
-- c_exported_functions.lua
--

function createCorona(posX,posY,posZ,size,colorR,colorG,colorB,colorA,...)
	local reqParam = {posX,posY,posZ,size,colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param~=nil and (type(param) == "number")
	end
	local optParam = {...}
	if not isThisValid or (#optParam > 1 or #reqParam ~= 8 ) or (countParam ~= 8) then
		outputDebugString('createCorona fail!')
		return false 
	end
	if (type(optParam[1]) ~= "boolean") then
		optParam[1] = false
	end
	local isDepthEffect =  optParam[1]
	if isDepthEffect then isDepthEffect = 2 else isDepthEffect = 1 end
	local SHCelementID = funcTable.createCorona(isDepthEffect,posX,posY,posZ,size,colorR,colorG,colorB,colorA)
	return createElement("SHCustomCorona",tostring(SHCelementID))
end

function createMaterialCorona(texImage,posX,posY,posZ,size,colorR,colorG,colorB,colorA,...)
	local reqParam = {posX,posY,posZ,size,colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param~=nil and (type(param) == "number")
	end
	local optParam = {...}
	if not isThisValid or (#optParam > 1 or #reqParam ~= 8 ) or (countParam ~= 8) or not isElement(texImage) then
		outputDebugString('createMaterialCorona fail!')
		return false 
	end
	if (type(optParam[1]) ~= "boolean") then
		optParam[1] = false
	end
	local isDepthEffect =  optParam[1]
	if isDepthEffect then isDepthEffect = 2 else isDepthEffect = 1 end
	local SHCelementID = funcTable.createMaterialCorona(texImage,isDepthEffect,posX,posY,posZ,size,colorR,colorG,colorB,colorA)
	return createElement("SHCustomCorona",tostring(SHCelementID))
end

function destroyCorona(w)
	if not isElement(w) then 
		return false
	end
	local SHCelementID = tonumber(getElementID(w))
	if type(SHCelementID) == "number" then
		return destroyElement(w) and funcTable.destroy(SHCelementID)
	else
		outputDebugString('destroyCorona fail!')
		return false
	end
end

function setCoronaMaterial(w,texImage)
	if not isElement(w) then 
		return false
	end
	local SHCelementID = tonumber(getElementID(w))
	if coronaTable.inputCoronas[SHCelementID]  and isElement(texImage)  then
		coronaTable.isInValChanged = true
		return funcTable.setMaterial(SHCelementID,texImage)
	else
		outputDebugString('setCoronaMaterial fail!')
		return false
	end
end

function setCoronaPosition(w,posX,posY,posZ)
	if not isElement(w) then 
		return false
	end
	local SHCelementID = tonumber(getElementID(w))
	local reqParam = {SHCelementID,posX,posY,posZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if coronaTable.inputCoronas[SHCelementID] and isThisValid  and (countParam == 4) then
		coronaTable.inputCoronas[SHCelementID].pos = {posX,posY,posZ}
		coronaTable.isInValChanged = true
		return true
	else
		outputDebugString('setCoronaPosition fail!')
		return false
	end
end

function setCoronaColor(w,colorR,colorG,colorB,colorA)
	if not isElement(w) then 
		return false
	end
	local SHCelementID = tonumber(getElementID(w))
	local reqParam = {SHCelementID,colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if coronaTable.inputCoronas[SHCelementID] and isThisValid  and (countParam == 5)  then
		coronaTable.inputCoronas[SHCelementID].color = {colorR,colorG,colorB,colorA}
		coronaTable.isInValChanged = true
		return true
	else
		outputDebugString('setCoronaColor fail!')
		return false
	end
end

function setCoronaSize(w,size)
	if not isElement(w) then 
		return false
	end
	local SHCelementID = tonumber(getElementID(w))
	if coronaTable.inputCoronas[SHCelementID] and (type(size) == "number") then 
		coronaTable.inputCoronas[SHCelementID].size = {size,size}
		coronaTable.inputCoronas[SHCelementID].dBias = math.min(size,1)
		coronaTable.isInValChanged = true
		return true
	else
		outputDebugString('setCoronaSize fail!')
		return false
	end
end

function setCoronaDepthBias(w,depthBias)
	if not isElement(w) then 
		return false
	end
	local SHCelementID = tonumber(getElementID(w))
	if coronaTable.inputCoronas[SHCelementID] and (type(depthBias) == "number") then 
		coronaTable.inputCoronas[SHCelementID].dBias = depthBias
		coronaTable.isInValChanged = true
		return true
	else
		outputDebugString('setCoronaDepthBias fail!')
		return false
	end
end

function setCoronaSizeXY(w,sizeX,sizeY)
	if not isElement(w) then 
		return false
	end
	local SHCelementID = tonumber(getElementID(w))
	if coronaTable.inputCoronas[SHCelementID] and (type(sizeX) == "number") and (type(sizeY) == "number") then 
		coronaTable.inputCoronas[SHCelementID].size = {sizeX,sizeY}
		coronaTable.inputCoronas[SHCelementID].dBias = math.min((sizeX + sizeY)/2,1)
		coronaTable.isInValChanged = true
		return true
	else
		outputDebugString('setCoronaSizeXY fail!')
		return false
	end
end

function setCoronasDistFade(dist1,dist2)
	if (type(dist1) == "number") and (type(dist2) == "number") then
		return funcTable.setDistFade(dist1,dist2)
	else
		outputDebugString('setCoronasDistFade fail!')
		return false
	end
end

function enableDepthBiasScale(depthBiasEnable)
	if type(depthBiasEnable) == "boolean" then
		coronaTable.depthBias = depthBiasEnable
		return true
	else
		outputDebugString('enableDepthBiasScale fail!')
		return false
	end
end
