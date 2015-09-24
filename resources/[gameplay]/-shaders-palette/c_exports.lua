function setPalette(isString)
	if (type(isString) ~= "string") then return false end
	if string.len(isString)>50 then return false end		
	local tempPalette = dxCreateTexture(isString,"argb", true, "wrap")
	if tempPalette then
		triggerEvent( "switchPalette", resourceRoot, false )
		paletteTable.customPalette = tempPalette
		triggerEvent( "switchPalette", resourceRoot, true )
		return true
	else
		return false
	end
end

function setPaletteEnabled(isTrue)
	if (type(isTrue) ~= "boolean") then
		return false
	else
		paletteTable.paletteEnabled = isTrue
		setEffectVariables()
		return true
	end
end

function setChromaticEnabled(isTrue)
	if (type(isTrue) ~= "boolean") then
		return false
	else
		paletteTable.chromaticEnabled = isTrue
		setEffectVariables()
		return true
	end
end

function setOrderPriority(setValue)
	if (type(setValue) ~= "number") then
		return false
	else
		paletteTable.orderPriority = setValue
		return true
	end
end