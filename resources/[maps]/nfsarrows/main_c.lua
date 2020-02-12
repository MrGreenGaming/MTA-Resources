local UVSpeed = { -0.5, 0 }
local UVResize = { 1, 1 }
local pSpeed = 0 --pendulum speed - must be a multiplication of 0.25 value ( set 0 - to turn off )
local pMinBright = 1 --minimum brightness ( 0 - 1)
local shader = nil
local colors = { "red", "green", "blue", "cyan", "purple", "orange", "yellow", "pink" }


function preLoadArrows()
	triggerServerEvent("getArrowsData", resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, preLoadArrows)


function updateArrowsState(arrows, color)
	---------------------------------------------
	if not color then 
		if isElement(shader) then
			destroyElement(shader)
			engineRestoreModel(18000)
			engineRestoreCOL(18000)
		end
		--outputChatBox("[Debug] NFS Arrows disabled.")
		return 
	end
	---------------------------------------------
	shader = dxCreateShader(":nfsarrows/shader.fx")
	--------------------------------------------------------------------------------------------------
	if not shader then 
	--outputChatBox( "Could not create shader. Please use debugscript 3" ) 
	return 
	end
	--outputChatBox("[Debug] Shader enabled.")
	--------------------------------------------------------------------------------------------------
	local texture = dxCreateTexture(":nfsarrows/img/"..color..".png", "dxt5")
	dxSetShaderValue(shader, "Tex", texture)
	dxSetShaderValue(shader, "UVSpeed", UVSpeed)
	dxSetShaderValue(shader, "UVResize", UVResize)
	dxSetShaderValue(shader, "pSpeed", pSpeed)
	dxSetShaderValue(shader, "pMinBright", pMinBright)
	engineApplyShaderToWorldTexture(shader, "ws_carshowwin1")
	------ New object as a collision, attaches to NFS Arrows ---------
	engineReplaceCOL(engineLoadCOL(":nfsarrows/barrier.col"), 18000)
	engineReplaceModel(engineLoadDFF(":nfsarrows/barrier.dff"), 18000)
	------------------------------------------------------------------
	engineSetModelLODDistance (3851, 170)
	--------------------------------
	for _, v in pairs(arrows) do
		setObjectBreakable(v, false)
	end
	--------------------------------
end
addEvent("updateArrowsState", true)
addEventHandler("updateArrowsState", root, updateArrowsState)