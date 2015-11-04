--
-- c_helper_functions.lua
--

---------------------------------------------------------------------------------------------------
-- Version check
---------------------------------------------------------------------------------------------------
function isMTAUpToDate()
	local mtaVer = getVersion().sortable
	outputDebugString("MTA Version: "..tostring(mtaVer))
	if getVersion ().sortable < "1.3.4-9.05899" then
		return false
	else
		return true
	end
end

---------------------------------------------------------------------------------------------------
-- DepthBuffer access
---------------------------------------------------------------------------------------------------
function isDepthBufferAccessible()
	if tostring(dxGetStatus().DepthBufferFormat)=='unknown' then 
		return false 
	else 
		return true 
	end
end

---------------------------------------------------------------------------------------------------
-- Toint
---------------------------------------------------------------------------------------------------
function toint(n)
    local s = tostring(n)
    local i = s:find('%.')
    if i then
        return tonumber(s:sub(1, i-1))
    else
        return n
    end
end

---------------------------------------------------------------------------------------------------
-- debug coronas
---------------------------------------------------------------------------------------------------
local coronaDebugSwitch = false

addCommandHandler( "debugCustomCoronas",
function()
	if isDebugViewActive() then 
		coronaDebugSwitch = switchDebugCoronas(not coronaDebugSwitch)
	end
end
)

function switchDebugCoronas(switch)
	if switch then
		addEventHandler("onClientRender",root,renderDebugCoronas)
	else
		outputDebugString('Debug mode: OFF')
		removeEventHandler("onClientRender",root,renderDebugCoronas)
	end
	return switch
end

local scx,scy = guiGetScreenSize()
function renderDebugCoronas()
	dxDrawText('Framerate: '..fpscheck()..' FPS',scx/2,25)
	dxDrawText('Type 1: '..coronaTable.numberType[1]..' Type 2: '..coronaTable.numberType[2],scx/2,40)
	dxDrawText('Type Material: '..coronaTable.numberType[3],scx/2,55)
	dxDrawText('DistFade: '..shaderSettings.gDistFade[1]..' TempFade: '..coronaTable.tempFade,scx/2,70)
	if (#coronaTable.outputCoronas<1) then 
		return
	end
	dxDrawText('Visible: '..coronaTable.thisCorona..' Sorted: '..coronaTable.sorted,scx/2,10)
end

local frames,lastsec,fpsOut = 0,0,0
function fpscheck()
	local frameticks = getTickCount()
	frames = frames + 1
	if frameticks - 1000 > lastsec then
		local prog = ( frameticks - lastsec )
		lastsec = frameticks
		fps = frames / (prog / 1000)
		frames = fps * ((prog - 1000) / 1000)
		fpsOut = tostring(math.floor( fps ))
	end
	return fpsOut
end

---------------------------------------------------------------------------------------------------
-- corona sorting
---------------------------------------------------------------------------------------------------
function sortedOutput(inTable,isSo,distFade,maxEntities)
	local outTable = {}
	for index,value in ipairs(inTable) do
		if inTable[index].enabled then
			local dist = getElementFromCameraDistance(value.pos[1],value.pos[2],value.pos[3])
			if dist <= distFade then 
				local w = #outTable + 1
				if not outTable[w] then 
					outTable[w] = {} 
				end
				outTable[w].enabled = value.enabled
				outTable[w].material = value.material
				outTable[w].cType = value.cType
				outTable[w].shader = value.shader
				outTable[w].size =  value.size
				outTable[w].dBias = value.dBias
				outTable[w].pos = value.pos
				outTable[w].dist = dist
				outTable[w].color = value.color	
			end
		end
	end
		if isSo and (#outTable > maxEntities) then
			table.sort(outTable, function(a, b) return a.dist < b.dist end)
		end
	return outTable
end

function findEmptyEntry(inTable)
	for index,value in ipairs(inTable) do
		if not value.enabled then
			return index
		end
	end
	return #inTable + 1
end

function getElementFromCameraDistance(hx,hy,hz)
	local cx,cy,cz,clx,cly,clz,crz,cfov = getCameraMatrix()
	local dist = getDistanceBetweenPoints3D(hx,hy,hz,cx,cy,cz)
	return dist
end
