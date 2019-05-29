function createBlurBox(posX,posY,sizeX,sizeY,colorR,colorG,colorB,colorA,postGUI)
	local reqParam = {posX,posY,sizeX,sizeY,colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param~=nil and (type(param) == "number")
	end
	if not isThisValid or (#reqParam ~= 8 ) or (countParam ~= 8) then 
		return false 
	end
	if (type(postGUI) ~= "boolean") then
		postGUI = false
	end
	local SHPelementID = funcTable.create(posX,posY,sizeX,sizeY,colorR,colorG,colorB,colorA,postGUI)
	return createElement("SHBlurBox",tostring(SHPelementID))
end

function destroyBlurBox(w)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	if type(SHPelementID) == "number" then
		return destroyElement(w) and funcTable.destroy(SHPelementID)
	else
		return false
	end
end

function setBlurBoxPosition(w,posX,posY)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	local reqParam = {SHPelementID,posX,posY}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if boxTable.inputBox[SHPelementID] and isThisValid  and (countParam == 3) then
		boxTable.inputBox[SHPelementID].pos = {posX,posY}
		boxTable.isInValChanged = true
		return true
	else
		return false
	end
end

function setBlurBoxColor(w,colorR,colorG,colorB,colorA)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	local reqParam = {SHPelementID,colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if boxTable.inputBox[SHPelementID] and isThisValid  and (countParam == 5)  then
		boxTable.inputBox[SHPelementID].color = {colorR,colorG,colorB,colorA}
		boxTable.isInValChanged = true
		return true
	else
		return false
	end
end

function setBlurBoxSize(w,sizeX,sizeY)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	if boxTable.inputBox[SHPelementID] and (type(sizeX) == "number") and (type(sizeY) == "number") then 
		boxTable.inputBox[SHPelementID].size = {sizeX,sizeY}
		boxTable.isInValChanged = true
		return true
	else
		return false
	end
end

function setBlurBoxEnabled(w,isEnabled)
	if not isElement(w) then 
		return false
	end
	local SHPelementID = tonumber(getElementID(w))
	if boxTable.inputBox[SHPelementID] and (type(isEnabled) == "boolean") then 
		boxTable.inputBox[SHPelementID].enabled = isEnabled
		boxTable.isInNrChanged = true
		return true
	else
		return false
	end
end

function setBlurIntensity(blurFactor)
	if boxTable.isStarted and (type(blurFactor) == "number") then 
		shaderSettings.blurFactor = blurFactor
		return true
	else
		return false
	end
end

function setScreenResolutionMultiplier(ssx,ssy)
	if boxTable.isStarted and (type(ssx) == "number") and (type(ssx) == "number") then
		if (ssx<=1 and ssx>0) and (ssy<=1 and ssy>0) then
			shaderSettings.screenSourceRes = {ssx,ssy}
			boxTable.isStarted = not funcTable.stopShaders()
			boxTable.isStarted = funcTable.startShaders()
			return boxTable.isStarted
		else
			return false
		end
	else
		return false
	end
end
