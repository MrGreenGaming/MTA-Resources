local screenW, screenH = guiGetScreenSize()

local g_GCText = {}

function GCTextPopUp( amount )
	local gc = amount or 1
	local startTime = getTickCount()
	local data = {
				["startInterp"] = {0.5, 255, 0},
				["startTime"] = startTime,
				["endInterp"] = {0.3, 0, 0},
				["endTime"] = startTime + 2000,
				["gc"] = gc
				}
				
	table.insert(g_GCText, data)
end
addEvent("GCTextPopUp", true)
addEventHandler("GCTextPopUp", root, GCTextPopUp)
--bindKey("n", "down", GCTextPopUp)
 

function popGCTextUp()
	for i, v in pairs ( g_GCText ) do
		local now = getTickCount()
		local elapsedTime = now - v.startTime
		local duration = v.endTime - v.startTime
		local progress = elapsedTime / duration
 
		local h1, a1, z1 = unpack(v.startInterp)
		local h2, a2, z2 = unpack(v.endInterp)
		local h, a, z = interpolateBetween ( 
		h1, a1, z1,
		h2, a2, z2, 
		progress, "Linear")
 
		dxDrawText("+"..v.gc.." GC", 0, h*screenH, screenW, screenH, tocolor(0, 255, 0, a), 1, "bankgothic", "center", "top", false, false, true, false, true)
		
		if now >= v.endTime then
			table.remove (g_GCText, i)
		end
	end
end
addEventHandler("onClientRender", root, popGCTextUp)