---------------------------------------------------------------------------------
--
-- Nitro shader
--
--
---------------------------------------------------------------------------------

addEvent("e_ToggleNitroColor", true)
function toggleNitroColor(bln,hex)
	if bln and hex then
		if not nitroShader then
			nitroShader = dxCreateShader("nitro.fx")
		end
		
		local alpha,red,green,blue = getColorFromString(hex)

		updateNitroColor(red,green,blue)
	elseif not bln then
		resetNitroColor()
	end
end
addEventHandler("e_ToggleNitroColor", resourceRoot, toggleNitroColor)

addEventHandler("onClientResourceStart",resourceRoot,
function()
	
end)

-- This function will set the new color of the nitro
function updateNitroColor(r,g,b)
	if nitroShader then
		if r and g and b then
			engineApplyShaderToWorldTexture (nitroShader,"smoke")
			dxSetShaderValue (nitroShader, "gNitroColor", r/255, g/255, b/255 )
		end
	end
end

-- This function will reset the nitro back to the original
function resetNitroColor()
	if nitroShader then
		engineRemoveShaderFromWorldTexture(nitroShader,"smoke")
	end
end



-- Example command use
addCommandHandler("nitro",
function(command,r,g,b)
	if r and g and b then
		local r,g,b = tonumber(r),tonumber(g),tonumber(b)
		if r <= 255 and g <= 255 and b <= 255 then
			updateNitroColor(r,g,b)
			outputChatBox("Nitro color updated!",255,255,255,true)
		else
			outputChatBox("Colors must be between 0 and 255",255,255,255,true)
		end
	else
		resetNitroColor()
		outputChatBox("Nitro color reset to original!",255,255,255,true)
	end
end)
