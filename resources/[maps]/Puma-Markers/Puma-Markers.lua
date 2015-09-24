gMe = getLocalPlayer()
gRoot = getRootElement()
screenWidth, screenHeight = guiGetScreenSize()
-- setTimer(function() StartRes() end,100,1)

function StartRes()
	oldHittedCollShape = nil
	MarkerTypes = {"Teleport","TeleportD","SlowDown","SpeedUp","Stop","Fire","BlowUp","Jump","Flip","Reverse","Rotate","CarsFly","CarsSwim","Gravity","Magnet","Beer","Camera","FlatTires","Freeze","GameSpeed","Color","Weather","Time","Text","AntiSC"}
	isSelected = {}
	isDestroyed = {}
	FM = 0
	SM = 0
	MW = 0
	TeleporterData = {}
	
	addEventHandler ( "onClientRender", gRoot,EditorRender)
	addEventHandler ( "onClientPlayerWasted", gMe, wasted )
	addEventHandler ( "onClientPlayerVehicleExit", gMe, wasted )
	
	addEvent("onClientElementSelect",true)
	addEvent("onClientElementDrop",true)
	addEvent("onClientElementDestroyed",true)
	addEventHandler ( "onClientElementSelect", gRoot,onClientElementSelect)
	addEventHandler ( "onClientElementDrop", gRoot,onClientElementDrop)
	addEventHandler ( "onClientElementDestroyed", gRoot,onClientElementDestroyed)
	setTimer(outputChatBox, 1000, 1, "ՠPuma-Markers (2.2) MrGreen Activated! Պ", 0,0,255)
end
addEventHandler( "onClientResourceStart", resourceRoot,StartRes)
-------------------------------- [ EDITOR ACTIONS ] --------------------------------
function onClientElementSelect()
	for MT=1,#MarkerTypes do
		if getElementType(getElementParent(source)) == MarkerTypes[MT] then 
			isSelected[getElementParent(source)] = true
		elseif getElementType(source) == MarkerTypes[MT] then 
			isSelected[source] = true
		end
	end
end
function onClientElementDrop()
	for MT=1,#MarkerTypes do
		if getElementType(source) == MarkerTypes[MT] then 
			isSelected[source] = false
			if MT ~= 2 then
				lastSelected = source
			end
			if MT == 2 then
				if lastSelected and getElementType(lastSelected) == "Teleport" then
					setElementData(lastSelected,"destination",getElementID(source))
				end
			end
		end
	end
end
function onClientElementDestroyed()
	for MT=1,#MarkerTypes do
		if getElementType(source) == MarkerTypes[MT] then 
			isDestroyed[source] = true
		end
	end
end
-------------------------------- [ EDITOR RENDER ] --------------------------------
function EditorRender()
	for MT=1,#MarkerTypes do
		for i,p in ipairs(getElementsByType(MarkerTypes[MT])) do
			-- local ax,ay,az = exports.edf:edfGetElementPosition(p)
			local ax,ay,az = getElementData(p, 'posX'), getElementData(p, 'posY'), getElementData(p, 'posZ')
			local px,py,pz,lx,ly,lz = getCameraMatrix (gMe)
			local x1,y1 = getScreenFromWorldPosition(ax,ay,az)
			local dist = getDistanceBetweenPoints3D(ax,ay,az,px,py,pz)
			local size = tonumber(getElementData(p, "size"))
			if not size or size == 0 then size = 1 end
			if dist < 500 and dist > 6 and x1 and (not isDestroyed[p]) then
				local hit, x, y, z, elementHit = processLineOfSight ( ax,ay,az,px,py,pz )
				if not hit then
					local Tsize = (250/dist)*size
					if MT == 24 then
						local text = getElementData(p, "text")
						local tsize2 = getElementData(p, "tsize")
						if not tsize2 or tsize2 == 0 then tsize2 = 1 end
						local tfont = getElementData(p, "tfont")
						local tcolor = getElementData(p, "tcolor")
						local tr, tg, tb, ta = conwert(tcolor)
						dxDrawText(text,(x1-Tsize)+4,(y1-Tsize),x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize*tsize2/10,tfont,"center","center")
						dxDrawText(text,(x1-Tsize)+4,(y1-Tsize)+4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize*tsize2/10,tfont,"center","center")
						dxDrawText(text,(x1-Tsize),(y1-Tsize)+4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize*tsize2/10,tfont,"center","center")
						dxDrawText(text,(x1-Tsize)-4,(y1-Tsize)+4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize*tsize2/10,tfont,"center","center")
						dxDrawText(text,(x1-Tsize)-4,(y1-Tsize),x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize*tsize2/10,tfont,"center","center")
						dxDrawText(text,(x1-Tsize)-4,(y1-Tsize)-4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize*tsize2/10,tfont,"center","center")
						dxDrawText(text,(x1-Tsize),(y1-Tsize)-4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize*tsize2/10,tfont,"center","center")
						dxDrawText(text,(x1-Tsize)+4,(y1-Tsize)-4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize*tsize2/10,tfont,"center","center")
						dxDrawText(text,x1-Tsize,y1-Tsize,x1+Tsize,y1+Tsize,tocolor(tr,tg,tb,ta),Tsize*tsize2/10,tfont,"center","center")
					end
					local icon = getElementData(p, "icon")
					local scale = getElementData(p, "iconsize")
					if not scale then scale = 1 end
					if icon or icon == true or icon == "true" then
						if MT == 25 then
							local checkpoint = getElementData(p, "checkpoint")
							if not checkpoint then checkpoint = 1 end
							local textcolor = getElementData(p, "iconcolor")
							local tr, tg, tb, ta = conwert(textcolor)
							local cptext = ""..checkpoint
							dxDrawText(cptext,(x1-Tsize)+4,(y1-Tsize),x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize/scale/10,"pricedown","center","center")
							dxDrawText(cptext,(x1-Tsize)+4,(y1-Tsize)+4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize/scale/10,"pricedown","center","center")
							dxDrawText(cptext,(x1-Tsize),(y1-Tsize)+4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize/scale/10,"pricedown","center","center")
							dxDrawText(cptext,(x1-Tsize)-4,(y1-Tsize)+4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize/scale/10,"pricedown","center","center")
							dxDrawText(cptext,(x1-Tsize)-4,(y1-Tsize),x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize/scale/10,"pricedown","center","center")
							dxDrawText(cptext,(x1-Tsize)-4,(y1-Tsize)-4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize/scale/10,"pricedown","center","center")
							dxDrawText(cptext,(x1-Tsize),(y1-Tsize)-4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize/scale/10,"pricedown","center","center")
							dxDrawText(cptext,(x1-Tsize)+4,(y1-Tsize)-4,x1+Tsize,y1+Tsize,tocolor(0,0,0,ta/2),Tsize/scale/10,"pricedown","center","center")
							dxDrawText(cptext,x1-Tsize,y1-Tsize,x1+Tsize,y1+Tsize,tocolor(tr,tg,tb,ta),Tsize/scale/10,"pricedown","center","center")
						else
							dxDrawImage(x1-Tsize/(2/scale),y1-Tsize/(2/scale),Tsize*scale,Tsize*scale,":Puma-Markers/Icons/"..MarkerTypes[MT]..".png")
							if MT == 12 or MT == 13 or MT == 15 then
								local o = getElementData(p,"ON")
								if not o then
									dxDrawImage(x1-Tsize/(2/scale),y1-Tsize/(2/scale),Tsize*scale,Tsize*scale,":Puma-Markers/Icons/X.png")
								end
							end
						end
					end
				end
			end
			--[[
			-- if exports.edf:edfGetElementProperty (p, "type") == "ring" then
			if getElementData(p, "type") == "ring" then
				if isSelected[p] then
					local obrep = getRepresentation(p,"object")
					local rx,ry,rz = getElementRotation(obrep)
					local temp = createVehicle(594,ax,ay,az,rx,ry,-rz)
					setElementAlpha(temp,0)
					local matrix = getElementMatrix ( temp )
					destroyElement (temp)
					local offX = 0 * matrix[1][1] + 50 * matrix[2][1] + 0 * matrix[3][1] + matrix[4][1]
					local offY = 0 * matrix[1][2] + 50 * matrix[2][2] + 0 * matrix[3][2] + matrix[4][2]
					local offZ = 0 * matrix[1][3] + 50 * matrix[2][3] + 0 * matrix[3][3] + matrix[4][3]
					local marker = getRepresentation(p,"marker")
					setMarkerTarget (marker, tonumber(offX), tonumber(offY), tonumber(offZ))
				end
			end
			if MT == 1 then
				local dest = getElementData(p,"destination")
				if dest and dest ~= "" then
					if getElementByID ( dest ) then
						destmark = getElementByID ( dest )
						if getElementType(destmark) == "TeleportD" then
							-- local x,y,z = exports.edf:edfGetElementPosition(destmark)
							local x,y,z = getElementData(destmark, 'posX'), getElementData(destmark, 'posY'), getElementData(destmark, 'posZ')
							local a,b = getScreenFromWorldPosition ( x, y, z )
							local c,d = getScreenFromWorldPosition ( ax, ay, az )
							if a and b and c and d then
								if not isDestroyed[p] and not isDestroyed[destmark] then
									dxDrawLine ( a,b,c,d, tocolor ( 0, 70, 255, 230 ), 3)
								end
							end
						end
					end
				end
			end
			--]]
		end
	end
end
-------------------------------- [ EDITOR TEST ] --------------------------------
addEventHandler( "onClientResourceStart", gRoot,
    function ( startedRes )
		if #getElementsByType('spawnpoint', source) > 0 then
			AntiSCChecker = 0
			addEventHandler ( "onClientColShapeHit", gRoot, ColShapeHit )
			Markery={}
			Teleport = {} TeleportD = {} SlowDown = {} SpeedUp = {} Stop = {} Fire = {} BlowUp = {} Jump = {} Flip = {} Reverse = {} Rotate = {} CarsFly = {} CarsSwim = {} Gravity = {} Magnet = {} Beer = {} Camera = {} FlatTires = {} Freeze = {} GameSpeed = {} Color = {} Weather = {} Time = {} Text = {} AntiSC = {}
			CollShapes = {Teleport,TeleportD,SlowDown,SpeedUp,Stop,Fire,BlowUp,Jump,Flip,Reverse,Rotate,CarsFly,CarsSwim,Gravity,Magnet,Beer,Camera,FlatTires,Freeze,GameSpeed,Color,Weather,Time,Text,AntiSC}
			for MT=1,#MarkerTypes do
				local ScriptType = getElementsByType(MarkerTypes[MT])
				for i,p in ipairs(ScriptType) do
					-- if i > (#ScriptType)/2 then 
						local x,y,z = getElementPosition (p)
						local size = getElementData(p, "size")
						local type = getElementData(p,"type")
						local color = getElementData(p, "color")
						local r, g, b, a = conwert(color)
						local power = getElementData(p,"power")
						local marker = createMarker(x,y,z,type,size,r,g,b,a)
						if type == "checkpoint" then
							local shape = createColCircle ( x, y, size ) CollShapes[MT][i] = shape
						elseif type == "ring" or type == "arrow" or type == "corona" then
							local shape = createColSphere ( x, y, z, size ) CollShapes[MT][i] = shape
						elseif type == "cylinder" then
							local shape = createColTube ( x, y, z, size , size ) CollShapes[MT][i] = shape
						end
						if type == "ring" then
							-- local rx,ry,rz = exports.edf:edfGetElementRotation(p)
							local rx,ry,rz = getElementData(p, 'rotX'), getElementData(p, 'rotY'), getElementData(p, 'rotZ')
							local temp = createVehicle(594,x,y,z,rx,ry,rz)
							setElementAlpha(temp,0)
							local matrix = getElementMatrix ( temp )
							destroyElement (temp)
							local offX = 0 * matrix[1][1] + 50 * matrix[2][1] + 0 * matrix[3][1] + matrix[4][1]
							local offY = 0 * matrix[1][2] + 50 * matrix[2][2] + 0 * matrix[3][2] + matrix[4][2]
							local offZ = 0 * matrix[1][3] + 50 * matrix[2][3] + 0 * matrix[3][3] + matrix[4][3]
							setMarkerTarget (marker, tonumber(offX), tonumber(offY), tonumber(offZ))
						end
						table.insert(Markery,marker)
					-- end
				end
			end
		end
    end
)

addEventHandler( "onClientResourceStop", gRoot,
    function ( startedRes )
		if #getElementsByType('spawnpoint', source) > 0 then
			removeEventHandler ( "onClientColShapeHit", gRoot, ColShapeHit )
			for i=1, #Markery do
				destroyElement(Markery[i])
			end		
			for MT=1,#MarkerTypes do
				local ScriptType = getElementsByType(MarkerTypes[MT])
				for i=1, #ScriptType do
					if i > (#ScriptType)/2 then 
						destroyElement(CollShapes[MT][i])
					end
				end
			end
		end
    end
)
-------------------------------- [ EDITOR TEST HIT ] --------------------------------
function ColShapeHit(player,machdimension)
	if (player == gMe) then
		for MT=1,#MarkerTypes do
			local ScriptType = getElementsByType(MarkerTypes[MT])
			for i,p in ipairs(ScriptType) do
				if CollShapes[MT][i] == source then
					local veh = getPedOccupiedVehicle(player)		
					if veh and isElement(veh) and (getVehicleOccupant(veh,0) == player) then
						local x,y,z = getElementPosition(veh)
						local vx,vy,vz = getElementVelocity(veh)
						local rx,ry,rz = getElementRotation(veh)
						----------------------------------------------------------------------------
						if MT == 1 then
							local dest = getElementData(p,"destination")
							if dest and dest ~= "" then
								if getElementByID ( dest ) then
									destmark = getElementByID ( dest )
									if getElementType(destmark) == "TeleportD" then
										TeleporterData[i] = 1
										local fade = getElementData(p,"fade")
										local stop = getElementData(p,"stop")
										-- local tx,ty,tz = exports.edf:edfGetElementPosition(destmark)
										local tx,ty,tz = getElementData(destmark, 'posX'), getElementData(destmark, 'posY'), getElementData(destmark, 'posZ')
										local vrx,vry,vrz = getVehicleTurnVelocity(veh)
										setElementFrozen(veh,true)
										if fade == "true" then fadeCamera ( false, 1) end
										setTimer(function(veh,tx,ty,tz,fade,stop)
											setElementFrozen(veh,false)
											setElementPosition(veh,tx,ty,tz)
											setElementFrozen(veh,true)
											if fade == "true" then fadeCamera ( true, 1) end
											setTimer(function(stop)
												setElementFrozen(veh,false)
												if stop == "false" then setElementVelocity(veh,vx,vy,vz) setVehicleTurnVelocity(veh,vrx,vry,vrz) end
											end,1000,1,stop)
										end,1000,1,veh,tx,ty,tz,fade,stop)
									else
										if TeleporterData ~= 1 then
											TeleporterData[i] = 2 
										end
									end
								end
							else
								outputDebugString("• Puma-Markers : ( You must set a destination for "..getElementID(p).."! DoubleClick on this teleporter. )",255,255,255,true)
							end
							if TeleporterData[i] == 2 then
								outputDebugString("• Puma-Markers : ( Can't find destination for "..getElementID(p).."! ["..dest.."] )",255,255,255,true)
							end
						elseif MT == 3 then
							local power = getElementData(p,"power")
							if tonumber(power) < 1 then power = 1 end
							local power = 1/power
							setElementVelocity (veh,vx*power,vy*power,vz*power)
						elseif MT == 4 then
							local power = getElementData(p,"power")
							if tonumber(power) < 1 then power = 1 end
							setElementVelocity (veh,vx*power,vy*power,vz*power)
						elseif MT == 5 then	
							setElementVelocity (veh,0,0,0)
						elseif MT == 6 then	
							setElementHealth (veh,249)
						elseif MT == 7 then	
							setElementHealth (veh,0)
						elseif MT == 8 then	
							local power = getElementData(p,"power")
							setElementVelocity (veh,vx,vy,vz+(power/10))
						elseif MT == 9 then
							setElementRotation(veh,0,0,rz)
							setVehicleTurnVelocity(veh,0,0,0)
						elseif MT == 10 then
							setElementVelocity(veh, -vx,-vy,-vz)
							setElementRotation(veh, -rx, -ry, rz+180)
						elseif MT == 11 then
							setElementRotation(veh, -rx, -ry, rz+180)
						elseif MT == 12 then
							local o = getElementData(p,"ON")
							if o == "true" and MW == 0 then
								if not isWorldSpecialPropertyEnabled("aircars") then
									setWorldSpecialPropertyEnabled ( "aircars" , true )
									FM = 1
								end
							else
								if isWorldSpecialPropertyEnabled("aircars") then
									setWorldSpecialPropertyEnabled ( "aircars" , false )
									FM = 0
								end
							end
						elseif MT == 13 then
							local o = getElementData(p,"ON")
							if o == "true" and MW == 0 then
								if not isWorldSpecialPropertyEnabled("hovercars") then
									setWorldSpecialPropertyEnabled ( "hovercars" , true )
									SM = 1
								end
							else
								if isWorldSpecialPropertyEnabled("hovercars") then
									setWorldSpecialPropertyEnabled ( "hovercars" , false )
									SM = 0
								end
							end
						elseif MT == 14 then
							local power = getElementData(p,"power")
							local aim = getElementData(p,"destination")
							if string.lower(aim) == "up" or string.lower(aim) == "u" then
								setVehicleGravityPoint( veh, x, y, z+1000, power )
							elseif string.lower(aim) == "down" or string.lower(aim) == "d" then
								setVehicleGravityPoint( veh, x, y, z-1000, power )
							elseif string.lower(aim) == "n" or string.lower(aim) == "north" then
								setVehicleGravityPoint( veh, x, y+1000, z, power )
							elseif string.lower(aim) == "s" or string.lower(aim) == "south"then
								setVehicleGravityPoint( veh, x, y-1000, z, power )
							elseif string.lower(aim) == "e" or string.lower(aim) == "east"then
								setVehicleGravityPoint( veh, x+1000, y, z, power )
							elseif string.lower(aim) == "w" or string.lower(aim) == "west"then
								setVehicleGravityPoint( veh, x-1000, y, z, power )
							end
						elseif MT == 15 then
							local o = getElementData(p,"ON")
							if MW == 0 and o == "true" and FM == 0 then
								addEventHandler("onClientRender",gRoot,magnetWheels)
								MW = 1
								magnetObject = createObject(902, 200, 200, 200)
								setElementCollisionsEnabled ( magnetObject, "false" )
								setElementInterior(magnetObject, 25)
								setElementAlpha(magnetObject,0)
							elseif MW == 1 and o == "false" then
								removeEventHandler("onClientRender",gRoot,magnetWheels)
								setVehicleGravityPoint( veh, x, y, z-1000, 1)
								MW = 0
								if magnetObject then destroyElement(magnetObject) end
							end
						elseif MT == 16 then
							local time = getElementData(p,"time")
							createExplosion ( x, y, z-30, 1 ,false, 2, false )
							setTimer(function() local x,y,z = getElementPosition(veh) createExplosion ( x, y, z-30, 2 ,false, 1, false ) end, 500,time*2,veh)
						elseif MT == 17 then
							local time = getElementData(p,"time")
							local col = getElementData(p,"fadecolor")
							local r,g,b,a = conwert(col)
							fadeCamera ( false, 1, r,g,b)
							setTimer(function() fadeCamera ( true, 1) end, time*1000,1)
						elseif MT == 18 then
							setVehicleWheelStates ( veh, 1, 1, 1, 1)
						elseif MT == 19 then
							local time = getElementData(p,"time")
							setElementFrozen(veh,true)
							setTimer(function() setElementFrozen(veh,false) end,time*1000,1,veh)
						elseif MT == 20 then
							local speed = getElementData(p,"speed")
							setGameSpeed(speed)
						elseif MT == 21 then
							local r,g,b,a = conwert(getElementData(p,"skyup"))
							local r2,g2,b2,a = conwert(getElementData(p,"skydown"))
							setSkyGradient ( r, g, b, r2, g2, b2 )
							local r,g,b,a = conwert(getElementData(p,"water"))
							setWaterColor ( r,g,b,a )
						elseif MT == 22 then
							local weather = getElementData(p,"weather")
							setWeather ( weather )
						elseif MT == 23 then
							local hr = getElementData(p,"hour")
							local mn = getElementData(p,"minute")
							setTime (hr,mn)
						elseif MT == 25 then
							local cpnr = getElementData(p,"checkpoint")
							if tonumber(cpnr) > tonumber(AntiSCChecker)+1 then
								blowVehicle(veh)
								SCUTERtext = getElementData(p,"text")
								SCr,SCg,SCb,SCa = conwert(getElementData(p,"textcolor"))
								addEventHandler("onClientRender",gRoot,SCuter)
								setTimer(function() removeEventHandler("onClientRender",gRoot,SCuter,text,r,g,b,a) end,10000,1)
							else
								AntiSCChecker = cpnr
							end
						end
					end
				end
			end
		end
	end
end

function SCuter()
	if SCScale then
		SCScale = SCScale+0.002
	else
		SCScale = 0
	end
	dxDrawText(SCUTERtext,5,0,screenWidth, screenHeight-55,tocolor(0,0,0,128),1.5+SCScale,"pricedown","center","center")
	dxDrawText(SCUTERtext,5,0,screenWidth, screenHeight-55,tocolor(0,0,0,128),1.5+SCScale,"pricedown","center","center")
	dxDrawText(SCUTERtext,5,0,screenWidth, screenHeight-50,tocolor(0,0,0,128),1.5+SCScale,"pricedown","center","center")
	dxDrawText(SCUTERtext,5,5,screenWidth, screenHeight-50,tocolor(0,0,0,128),1.5+SCScale,"pricedown","center","center")
	dxDrawText(SCUTERtext,0,5,screenWidth, screenHeight-50,tocolor(0,0,0,128),1.5+SCScale,"pricedown","center","center")
	dxDrawText(SCUTERtext,0,5,screenWidth-5, screenHeight-50,tocolor(0,0,0,128),1.5+SCScale,"pricedown","center","center")
	dxDrawText(SCUTERtext,0,0,screenWidth-5, screenHeight-50,tocolor(0,0,0,128),1.5+SCScale,"pricedown","center","center")
	dxDrawText(SCUTERtext,0,0,screenWidth-5, screenHeight-55,tocolor(0,0,0,128),1.5+SCScale,"pricedown","center","center")
	dxDrawText(SCUTERtext,0,0,screenWidth, screenHeight-55,tocolor(0,0,0,128),1.5+SCScale,"pricedown","center","center")
	dxDrawText(SCUTERtext,0,0,screenWidth, screenHeight-50,tocolor(SCr,SCg,SCb,SCa),1.5+SCScale,"pricedown","center","center")
end

function wasted ()
	if source ~= gMe then return end
	removeEventHandler("onClientRender",gRoot,magnetWheels) 
	MW = 0
	setGameSpeed(1)
	setWorldSpecialPropertyEnabled ( "aircars" , false )
	setWorldSpecialPropertyEnabled ( "hovercars" , false )
end
---------------------------------------------------------------
function setVehicleGravityPoint( targetVehicle, pointX, pointY, pointZ, strength )
	if isElement( targetVehicle ) and getElementType( targetVehicle ) == "vehicle" then
		local vehicleX,vehicleY,vehicleZ = getElementPosition( targetVehicle )
		local vectorX = vehicleX-pointX
		local vectorY = vehicleY-pointY
		local vectorZ = vehicleZ-pointZ
		local length = ( vectorX^2 + vectorY^2 + vectorZ^2 )^0.5
 
		local propX = vectorX^2 / length^2
		local propY = vectorY^2 / length^2
		local propZ = vectorZ^2 / length^2
 
		local finalX = ( strength^2 * propX )^0.5
		local finalY = ( strength^2 * propY )^0.5
		local finalZ = ( strength^2 * propZ )^0.5
 
		if vectorX > 0 then finalX = finalX * -1 end
		if vectorY > 0 then finalY = finalY * -1 end
		if vectorZ > 0 then finalZ = finalZ * -1 end
 
		return setVehicleGravity( targetVehicle, finalX, finalY, finalZ )
	end
	return false
end
local max_grav = 0.01 -- normal gravity is 0.01

function magnetWheels()
	if(getPedOccupiedVehicle(gMe) == false)then return end
	local vehicle = getPedOccupiedVehicle(gMe)
	attachElements(magnetObject, vehicle, 0, 0, -0.001)
	local velX, velY, velZ = getElementVelocity(vehicle)
	local mX, mY, mZ = getDiff(vehicle, magnetObject)
	mX = mX * max_grav
	mY = mY * max_grav
	mZ = mZ * max_grav
	setVehicleGravity(vehicle, 0, 0, 0)
	setElementVelocity(vehicle, velX + mX, velY + mY, velZ + mZ)
end

function getDiff(vehicle, object)
	local vehX, vehY, vehZ = getElementPosition(vehicle)
	local objX, objY, objZ = getElementPosition(object)
	local dist2D = math.sqrt((vehX - objX)^2 + (vehY - objY)^2)
	local dist3D = math.sqrt(dist2D^2 + (vehZ - objZ)^2)
	
	local distX = (objX - vehX) / dist3D
	local distY = (objY - vehY) / dist3D
	local distZ = (objZ - vehZ) / dist3D
	
	if(distX > 1)then
		distX = 1
	end
	if(distY > 1)then
		distY = 1
	end
	if(distZ > 1)then
		distZ = 1
	end
	
	return distX, distY, distZ
end

--[[function magnetWheels()
    local veh = getPedOccupiedVehicle(gMe)
	local x,y,z = getElementPosition(veh)
    local underx,undery,underz = getPositionUnderTheElement(veh)
    setVehicleGravity(veh,underx - x,undery - y,underz - z)	
end

function getPositionUnderTheElement(element)
    local matrix = getElementMatrix (element)
    local offX = 0 * matrix[1][1] + 0 * matrix[2][1] - 1 * matrix[3][1] + matrix[4][1]
    local offY = 0 * matrix[1][2] + 0 * matrix[2][2] - 1 * matrix[3][2] + matrix[4][2]
    local offZ = 0 * matrix[1][3] + 0 * matrix[2][3] - 1 * matrix[3][3] + matrix[4][3]
    return offX,offY,offZ
end]]--
function getRepresentation(element,type)
	for i,elem in ipairs(getElementsByType(type,element)) do
		if elem ~= exports.edf:edfGetHandle ( elem ) then
			return elem
		end
	end
	return false
end

function conwert(color)
	local hexTodecim = {["0"]=0,["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,["9"]=9,["a"]=10,["b"]=11,["c"]=12,["d"]=13,["e"]=14,["f"]=15}
	local red = (hexTodecim[string.lower(string.sub(color, 2, 2))]*16) + hexTodecim[string.lower(string.sub(color, 3, 3))]
	local gren = (hexTodecim[string.lower(string.sub(color, 4, 4))]*16) + hexTodecim[string.lower(string.sub(color, 5, 5))]
	local blue = (hexTodecim[string.lower(string.sub(color, 6, 6))]*16) + hexTodecim[string.lower(string.sub(color, 6, 6))]
	local alpha = (hexTodecim[string.lower(string.sub(color, 8, 8))]*16) + hexTodecim[string.lower(string.sub(color, 9, 9))]
	return red, gren, blue, alpha
end