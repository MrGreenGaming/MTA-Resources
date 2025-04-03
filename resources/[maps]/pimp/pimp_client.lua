w, h = guiGetScreenSize()

textTable, fadeInTable, fadeOutTable = {}, {}, {}
shadowOffX, shadowOffY = 2, 1
shadowMultiplier = 0.5

pimp3dTextElementTable = {}

function resourceStart ()
	triggerServerEvent ( "onRequest3dTextElements", getLocalPlayer() )
end
addEventHandler ( "onClientResourceStart", getResourceRootElement(), resourceStart )

function receive3dTextElements ( newTable )
	pimp3dTextElementTable = false
	if newTable then
		pimp3dTextElementTable = newTable
	end
end
addEvent ( "onClientReceive3dTextElements", true )
addEventHandler ( "onClientReceive3dTextElements", getRootElement(), receive3dTextElements )

function newPimp2dText ( child, data )
	local t = 0
	for key, value in pairs ( data ) do
		if key == "time" or key == "fadeTime" or key == "size" or key == "screenX" or key == "screenY" then
			data[key] = tonumber ( value )
		elseif key == "font" then
			data[key] = fontNameToDxName(value)
		end
	end

	if data.time < 50 then data.time = 0 end if data.fadeTime < 50 then data.fadeTime = 0 end
	
	local tableString = tostring(data)
	
	if data.fadeTime > 50 then
		local fadeInTimer = setTimer ( function(tableString)fadeInTable[tableString]=nil end, data.fadeTime, 1, tableString )
		fadeInTable[tableString] = {fadeInTimer,data}
		
		setTimer ( function ( tableString, data )
			local textTimer = setTimer ( function(tableString)textTable[tableString]=nil end, data.time, 1, tableString )
			textTable[tableString] = {textTimer,data}
		end, data.fadeTime, 1, tableString, data )
		
		setTimer ( function ( tableString, data )
			local fadeOutTimer = setTimer ( function(tableString)fadeOutTable[tableString]=nil end, data.fadeTime, 1, tableString )
			fadeOutTable[tableString] = {fadeOutTimer,data}
		end, data.fadeTime+data.time, 1, tableString, data )
	else
		local textTimer = setTimer ( function(tableString)textTable[tableString]=nil end, data.time, 1, tableString )
		textTable[tableString] = {textTimer,data}
	end
end
addEvent ( "onClientNewPimp2dText", true )
addEventHandler ( "onClientNewPimp2dText", getRootElement(), newPimp2dText )

function pimpFadeScreen ( time )
	if not fadingScreen then
		fadeTimer = setTimer ( function(time) fadeTimer2 = setTimer(function()fadingScreen=false end,time,1)  end, time, 1, time )
		fadingScreen = time
	end
end
addEvent ( "onClientPimpFadeScreen", true )
addEventHandler ( "onClientPimpFadeScreen", getRootElement(), pimpFadeScreen )

function clientSetElementVelocity ( p, v, vx, vy, vz, changedVx, changedVy, changedVz, velocityType )
	local vx2, vy2, vz2
	if v and vx and vy and vz then
		local rx, ry, rz = getElementRotation ( v )
		local x, y, z = getElementPosition ( v )
		local m = getElementMatrix ( v )
		vx2 = vx * m[1][1] + vy * m[2][1] + vz * m[3][1] + m[4][1] - x
		vy2 = vx * m[1][2] + vy * m[2][2] + vz * m[3][2] + m[4][2] - y
		vz2 = vx * m[1][3] + vy * m[2][3] + vz * m[3][3] + m[4][3] - z
	end
	if velocityType and velocityType == "change (fill in below)" then
		if v then
			setElementVelocity ( v, changedVx or vx2 or 0, changedVy or vy2 or 0, changedVz or vz2 or 0 )
		else
			setElementVelocity ( p, changedVx or 0, changedVy or 0, changedVz or 0 )
		end
	else
		if v then
			setElementVelocity ( v, vx2 or 0, vy2 or 0, vz2 or 0 )
		else
			setElementVelocity ( p, 0, 0, 0 )
		end
	end
end
addEvent ( "onClientSetElementVelocity", true )
addEventHandler ( "onClientSetElementVelocity", getRootElement(), clientSetElementVelocity )

function clientSetVehicleGravity ( gx, gy, gz )
	local v = getPedOccupiedVehicle ( getLocalPlayer() )
	if v then
		setVehicleGravity ( v, gx or 0, gy or 0, gz or -1 )
	end
end
addEvent ( "onClientSetVehicleGravity", true ) 
addEventHandler ( "onClientSetVehicleGravity", getRootElement(), clientSetVehicleGravity )

function render ()

	-- fade
	
	if fadingScreen and ( (fadeTimer and isTimer ( fadeTimer )) or (fadeTimer2 and isTimer ( fadeTimer2 ) ) ) then
		local theTimer
		local first = true
		if fadeTimer and isTimer ( fadeTimer ) then theTimer = fadeTimer elseif fadeTimer2 and isTimer ( fadeTimer2 ) then theTimer = fadeTimer2 first = false end
		if theTimer then
			local timeLeft, amountLeft = getTimerDetails ( theTimer )
			local index = timeLeft / fadingScreen
			if first then
				index = 1 - index
			end
			dxDrawRectangle ( 0, 0, w, h, tocolor(0,0,0,255*index) )
		end
	end
	
	-- 3d text ###################################################################
	
	local cx, cy, cz = getCameraMatrix()
	
	if pimp3dTextElementTable and type(pimp3dTextElementTable) == "table" and #pimp3dTextElementTable > 0 then
		for i, text3dElement in pairs ( pimp3dTextElementTable ) do
			local data, position = unpack(text3dElement)
			if data and type(data) == "table" and position and type(position) == "table" then
				local x, y, z = unpack ( position )
				
				local maxDist = data.maxDistance
				if maxDist and tonumber ( maxDist ) then
					local maxDist = tonumber ( maxDist )
					
					local dist = getDistanceBetweenPoints3D ( cx, cy, cz, x, y, z )
					
					if dist < maxDist then
						local sX, sY = getScreenFromWorldPosition ( x, y, z, 500, false )
						if sX and sY then
							local color = data.color
							local text = data.text
							local size = data.size
							local font = data.font
							local alignX = data.alignX
							local alignY = data.alignY
							
							if color and tostring(color) and text and size and tonumber(size) and font and fontNameToDxName(font) and alignX and alignY then
						
								local scaleIndex, fadeIndex = calculateScaleAndFadeIndexFromDistance ( dist, maxDist )
								
								if data.scaling and data.scaling == "false" then scaleIndex = 1 end
								if data.fading and data.fading == "false" then fadeIndex = 1 end
								
								local r, g, b, a = hexToRGB ( color )
								local a = a * fadeIndex

								if data.shadow and data.shadow == "true" then
									dxDrawText ( text, sX+(shadowOffX*data.size*shadowMultiplier)*scaleIndex, sY+(shadowOffY*data.size*shadowMultiplier)*scaleIndex, sX+(shadowOffX*data.size*shadowMultiplier)*scaleIndex, sY+(shadowOffY*data.size*shadowMultiplier)*scaleIndex, tocolor(0,0,0,a), tonumber(size)*scaleIndex, fontNameToDxName(font), alignX, alignY, true )
								end
								dxDrawText ( text, sX, sY, sX, sY, tocolor(r,g,b,a), tonumber(size)*scaleIndex, fontNameToDxName(font), alignX, alignY )
							end
						end
					end
				end
			end
		end
	end
	
	-- 2d text ###################################################################

	for tableString, dataTable in pairs ( fadeInTable ) do
		local timer, data = unpack(dataTable)
		if timer and isTimer ( timer ) and data and type(data) == "table" then
			local index = 0
			local timeLeft = getTimerDetails ( timer )
			local index = 1 - timeLeft / data.fadeTime
			local r, g, b, a = hexToRGB ( data.color )
			if data.shadow and data.shadow == "true" then
				dxDrawText ( data.text, w*data.screenX+shadowOffX*data.size*shadowMultiplier, h*data.screenY+shadowOffY*data.size*shadowMultiplier, w*data.screenX+shadowOffX*data.size*shadowMultiplier, h*data.screenY+shadowOffY*data.size*shadowMultiplier, tocolor(0,0,0,a*index), data.size, data.font, data.alignX, data.alignY, true )
			end
			dxDrawText ( data.text, w*data.screenX, h*data.screenY, w*data.screenX, h*data.screenY, tocolor(r,g,b,a*index), data.size, data.font, data.alignX, data.alignY )
		end
	end
	
	for tableString, dataTable in pairs ( fadeOutTable ) do
		local timer, data = unpack(dataTable)
		if timer and isTimer ( timer ) and data and type(data) == "table" then
			local index = 0
			local timeLeft = getTimerDetails ( timer )
			local index = timeLeft / data.fadeTime
			local r, g, b, a = hexToRGB ( data.color )
			if data.shadow and data.shadow == "true" then
				dxDrawText ( data.text, w*data.screenX+shadowOffX*data.size*shadowMultiplier, h*data.screenY+shadowOffY*data.size*shadowMultiplier, w*data.screenX+shadowOffX*data.size*shadowMultiplier, h*data.screenY+shadowOffY*data.size*shadowMultiplier, tocolor(0,0,0,a*index), data.size, data.font, data.alignX, data.alignY, true )
			end
			dxDrawText ( data.text, w*data.screenX, h*data.screenY, w*data.screenX, h*data.screenY, tocolor(r,g,b,a*index), data.size, data.font, data.alignX, data.alignY )
		end
	end
	
	for tableString, dataTable in pairs ( textTable ) do
		local timer, data = unpack(dataTable)
		if data and type(data) == "table" then
			local r, g, b, a = hexToRGB ( data.color )
			if data.shadow and data.shadow == "true" then
				dxDrawText ( data.text, w*data.screenX+shadowOffX*data.size*shadowMultiplier, h*data.screenY+shadowOffY*data.size*shadowMultiplier, w*data.screenX+shadowOffX*data.size*shadowMultiplier, h*data.screenY+shadowOffY*data.size*shadowMultiplier, tocolor(0,0,0,a), data.size, data.font, data.alignX, data.alignY, true )
			end
			dxDrawText ( data.text, w*data.screenX, h*data.screenY, w*data.screenX, h*data.screenY, tocolor(r,g,b,a), data.size, data.font, data.alignX, data.alignY )
		end
	end
end
addEventHandler ( "onClientRender", getRootElement(), render )

lineSpaceMultiplier = 0.1
_dxDrawText = dxDrawText
function dxDrawText ( text, x, y, x2, y2, color, size, font, alignX, alignY, shadow )
	if string.find ( text, "#N" ) then
		local stringTable = string.explode(text, "#N")
		local lineHeight = dxGetFontHeight ( size, font )
		local lineSpace = lineSpaceMultiplier * lineHeight
		local totalHeight = #stringTable * ( lineHeight + lineSpace ) - lineSpace
		local startY = y
		if alignY == "center" then startY = y - totalHeight/2 elseif alignY == "bottom" then startY = y - totalHeight end
		for i, lineString in pairs ( stringTable ) do
			if shadow then
				_dxDrawText ( string.gsub(lineString,"#%x%x%x%x%x%x",""), x, startY, x2, startY, color, size, font, alignX, alignY )
			else
				dxDrawColorText ( lineString, x, startY, x2, startY, color, size, font, alignX, alignY )
			end
			startY = startY + lineHeight + lineSpace
		end
	else
		dxDrawColorText ( text, x, y, x2, y2, color, size, font, alignX, alignY )
	end
end

function dxDrawColorText(str, ax, ay, bx, by, color, scale, font, alignX, alignY)
  bx, by, color, scale, font = bx or ax, by or ay, color or tocolor(255,255,255,255), scale or 1, font or "default"
  if alignX then
    if alignX == "center" then
      ax = ax + (bx - ax - dxGetTextWidth(str:gsub("#%x%x%x%x%x%x",""), scale, font))/2
    elseif alignX == "right" then
      ax = bx - dxGetTextWidth(str:gsub("#%x%x%x%x%x%x",""), scale, font)
    end
  end
  if alignY then
    if alignY == "center" then
      ay = ay + (by - ay - dxGetFontHeight(scale, font))/2
    elseif alignY == "bottom" then
      ay = by - dxGetFontHeight(scale, font)
    end
  end
  local alpha = string.format("%08X", color):sub(1,2)
  local pat = "(.-)#(%x%x%x%x%x%x)"
  local s, e, cap, col = str:find(pat, 1)
  local last = 1
  while s do
    if cap == "" and col then color = tocolor(getColorFromString("#"..col..alpha)) end
    if s ~= 1 or cap ~= "" then
      local w = dxGetTextWidth(cap, scale, font)
      _dxDrawText(cap, ax, ay, ax + w, by, color, scale, font)
      ax = ax + w
      color = tocolor(getColorFromString("#"..col..alpha))
    end
    last = e + 1
    s, e, cap, col = str:find(pat, last)
  end
  if last <= #str then
    cap = str:sub(last)
    _dxDrawText(cap, ax, ay, ax + dxGetTextWidth(cap, scale, font), by, color, scale, font)
  end
end

function calculateScaleAndFadeIndexFromDistance ( dist, maxDist )
	local scaleIndex, fadeIndex = 1, 1
	local startScaleDist, startFadeDist = maxDist^0.5, 0.4*maxDist
	if dist > startScaleDist then
		scaleIndex = -1*(dist-startScaleDist)^0.5 / ((maxDist-startScaleDist)^0.5) + 1
	end
	if dist > startFadeDist then
		fadeIndex = 1 - (dist-startFadeDist) / (maxDist-startFadeDist)
	end
	return scaleIndex, fadeIndex
end

function hexToRGB ( hex )
	local hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), tonumber("0x"..hex:sub(7,8))
end

function cameraPosition ( posElementID, lookAt, lookAtMarkerID, rollAngle, fov, time, fadeTime )
	if cameraTable then
		if cameraTimer and isTimer ( cameraTimer ) then
			killTimer ( cameraTimer )
		end
	else
		addEventHandler ( "onClientPreRender", getRootElement(), preRender )
	end
	cameraTable = { posElementID, lookAt, lookAtMarkerID, rollAngle, fov }
	if time > 50 then
		cameraTimer = setTimer ( function( fadeTime ) 
			if fadeTime then
				pimpFadeScreen ( fadeTime )
				setTimer ( function()
					cameraTable = false 
					removeEventHandler ( "onClientPreRender", getRootElement(), preRender ) 
					setCameraTarget ( getLocalPlayer() )
				end, fadeTime, 1 )
			else
				cameraTable = false 
				removeEventHandler ( "onClientPreRender", getRootElement(), preRender ) 
				setCameraTarget ( getLocalPlayer() )
			end
		end, time, 1, fadeTime )
	end
end
addEvent ( "onClientCameraPosition", true )
addEventHandler ( "onClientCameraPosition", getRootElement(), cameraPosition )

function preRender ()
	if cameraTable then
		local posElementID, lookAt, lookAtMarkerID, rollAngle, fov = unpack ( cameraTable )
		local posElement = getElementByID ( posElementID )
		if posElement and isElement ( posElement ) then
			local x, y, z = getElementPosition ( posElement )
			local tx, ty, tz = getElementPosition ( getLocalPlayer() )
			if lookAt == "marker" and lookAtMarkerID and getElementByID ( lookAtMarkerID ) then
				tx, ty, tz = getElementPosition ( getElementByID ( lookAtMarkerID ) )
			end
			setCameraMatrix ( x, y, z, tx, ty, tz, rollAngle, fov )
		end
	end
end

function cameraTargetPlayer ()
	if cameraTable then
		cameraTable = false
		removeEventHandler ( "onClientPreRender", getRootElement(), preRender ) 
	end
	if cameraTimer and isTimer ( cameraTimer ) then
		killTimer ( cameraTimer )
		removeEventHandler ( "onClientPreRender", getRootElement(), preRender ) 
	end
	setCameraTarget ( getLocalPlayer() )
end
addEvent ( "onClientCameraTargetPlayer", true )
addEventHandler ( "onClientCameraTargetPlayer", getRootElement(), cameraTargetPlayer )

function enableCheat ( type, enabled, time )
	if enabled == "true" then
		setWorldSpecialPropertyEnabled ( type, true )
	else
		setWorldSpecialPropertyEnabled ( type, false )
	end
	
	if enabled == "true" and time and tonumber(time) and tonumber(time) > 50 then
		setTimer ( setWorldSpecialPropertyEnabled, tonumber(time), 1, type, false )
	end
end
addEvent ( "onClientEnableCheat", true )
addEventHandler ( "onClientEnableCheat", getRootElement(), enableCheat )

function clientSetGameSpeed ( speed )
	setGameSpeed ( speed )
end
addEvent ( "onClientSetGameSpeed", true )
addEventHandler ( "onClientSetGameSpeed", getRootElement(), clientSetGameSpeed )

function clientSetGravity ( gravity )
	setGravity ( gravity )
end
addEvent ( "onClientSetGravity", true )
addEventHandler ( "onClientSetGravity", getRootElement(), clientSetGravity )

fontNameTable = {
	["Tahoma"] = "default",
	["Tahoma Bold"] = "default-bold",
	["Verdana"] = "clear",
	["Arial"] = "arial",
	["Microsoft Sans Serif"] = "sans",
	["Pricedown"] = "pricedown",
	["Bank Gothic Medium"] = "bankgothic",
	["Diploma Regular"] = "diploma",
	["Beckett Regular"] = "beckett"
				}
function fontNameToDxName ( name )
	return fontNameTable[name]
end

function string.explode(self, separator)
    Check("string.explode", "string", self, "ensemble", "string", separator, "separator")
 
    if (#self == 0) then return {} end
    if (#separator == 0) then return { self } end
 
    return loadstring("return {\""..self:gsub(separator, "\",\"").."\"}")()
end

function Check(funcname, ...)
    local arg = {...}
 
    if (type(funcname) ~= "string") then
        error("Argument type mismatch at 'Check' ('funcname'). Expected 'string', got '"..type(funcname).."'.", 2)
    end
    if (#arg % 3 > 0) then
        error("Argument number mismatch at 'Check'. Expected #arg % 3 to be 0, but it is "..(#arg % 3)..".", 2)
    end
 
    for i=1, #arg-2, 3 do
        if (type(arg[i]) ~= "string" and type(arg[i]) ~= "table") then
            error("Argument type mismatch at 'Check' (arg #"..i.."). Expected 'string' or 'table', got '"..type(arg[i]).."'.", 2)
        elseif (type(arg[i+2]) ~= "string") then
            error("Argument type mismatch at 'Check' (arg #"..(i+2).."). Expected 'string', got '"..type(arg[i+2]).."'.", 2)
        end
 
        if (type(arg[i]) == "table") then
            local aType = type(arg[i+1])
            for _, pType in next, arg[i] do
                if (aType == pType) then
                    aType = nil
                    break
                end
            end
            if (aType) then
                error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..table.concat(arg[i], "' or '").."', got '"..aType.."'.", 3)
            end
        elseif (type(arg[i+1]) ~= arg[i]) then
            error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..arg[i].."', got '"..type(arg[i+1]).."'.", 3)
        end
    end
end