local UVSpeed = { -0.5, 0 }
local UVResize = { 1, 1 }
local pSpeed = 0 --pendulum speed - must be a multiplication of 0.25 value ( set 0 - to turn off )
local pMinBright = 1 --minimum brightness ( 0 - 1)
local shader = nil
local colors = { "red", "green", "blue", "cyan", "purple", "orange", "yellow", "pink" }


function onStart() --Callback triggered by EDF
	------- New object as a collision, attaches to NFS Arrows --------
	engineReplaceCOL(engineLoadCOL(":mrgreen/nfsarrows/barrier.col"), 18000)
	engineReplaceModel(engineLoadDFF(":mrgreen/nfsarrows/barrier.dff"), 18000)
	------------------------------------------------------------------
	engineSetModelLODDistance (3851, 170)
	changeArrowsColor("blue")
	--outputChatBox("edf start")
end


function onStop() --Callback triggered by EDF
	changeArrowsColor(false)
	--outputChatBox("edf stop")
end


function changeArrowsColor(color)
	if not color then 
		if isElement(shader) then
			destroyElement(shader)
		end
		--outputChatBox("[Debug EDF] Shader disabled.")
		return 
	end
	----------------------------------------------------
	if isElement(shader) then destroyElement(shader) end
	----------------------------------------------------
	shader = dxCreateShader(":mrgreen/nfsarrows/shader.fx")
	--------------------------------------------------------------------------------------------------
	if not shader then 
	--outputChatBox( "[Debug EDF] Could not create shader. Please use debugscript 3" ) 
	return 
	end
	--------------------------------------------------------------------------------------------------
	local texture = dxCreateTexture(":mrgreen/nfsarrows/img/"..color..".png", "dxt5")
	dxSetShaderValue(shader, "Tex", texture)
	dxSetShaderValue(shader, "UVSpeed", UVSpeed)
	dxSetShaderValue(shader, "UVResize", UVResize)
	dxSetShaderValue(shader, "pSpeed", pSpeed)
	dxSetShaderValue(shader, "pMinBright", pMinBright)
	engineApplyShaderToWorldTexture(shader, "ws_carshowwin1")
end
addEvent("changeArrowsColor", true)
addEventHandler("changeArrowsColor", resourceRoot, changeArrowsColor)


function setNFSArrowsUnbreakable(nfs_arrows)
	for _, nfs_arrow in pairs(nfs_arrows) do
		setObjectBreakable(nfs_arrow, false)
	end
end
addEvent("setNFSArrowsUnbreakable", true)
addEventHandler("setNFSArrowsUnbreakable", resourceRoot, setNFSArrowsUnbreakable)


--\\Live change of the NFS Arrows color
local nfsarrows_color_selected = false
addEventHandler("onClientGUIClick", root,
	function(button, state)
		if button == "left" and state == "up" and getElementType(source) == "gui-gridlist" then
			local items = guiGridListGetSelectedItems(source)
			if not items[1] then return end
			
			local selectedOption = guiGridListGetItemText(source, items[1]["row"], 1 )
			if selectedOption == "nfsarrows_color" then
				nfsarrows_color_selected = true
			elseif isColorOptionSelected(selectedOption) and nfsarrows_color_selected then --reloads shader with new color only if "nfsarrows_color" option selected
				changeArrowsColor(selectedOption)
			else
				nfsarrows_color_selected = false
			end
		end
	end
)


function isColorOptionSelected(color)
	for _, v in pairs(colors) do
		if color == v then
			return true
		end
	end
	return false
end
--//Live change of the NFS Arrows color