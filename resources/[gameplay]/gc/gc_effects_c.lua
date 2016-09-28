local screenW, screenH = guiGetScreenSize()

local t = {
				["+"] = {
						r = 0,
						g = 255,
						b = 0,
						},
				["-"] = {
						r = 255,
						g = 0,
						b = 0,
						},
}

local g_GCText = {}

function GCTextPopUp( amount )
	local gc = amount or 1
	
	local symbol = "+"
	if gc < 0 then
		symbol = "-"
	end
	
	local startTime = getTickCount()
	local data = {
				["startInterp"] = {0.5, 255, 0},
				["startTime"] = startTime,
				["endInterp"] = {0.3, 0, 0},
				["endTime"] = startTime + 2000,
				["gc"] = math.abs(gc),
				["symbol"] = symbol,
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
 
		local s = v.symbol
		dxDrawText(v.symbol..""..v.gc.." GC", 0, h*screenH, screenW, screenH, tocolor(t[s].r, t[s].g, t[s].b, a), 1, "bankgothic", "center", "top", false, false, true, false, true)
		
		if now >= v.endTime then
			table.remove (g_GCText, i)
		end
	end
end
addEventHandler("onClientRender", root, popGCTextUp)