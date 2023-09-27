-- todo, speed zoom, move settings to xml, 1280*1024, health/speed, wrong amount of checkpoints {NTS}Oh nooo

local resX, resY		= 	guiGetScreenSize()
local waterCol 			=	tocolor(67,86,88,250);	-- Color used for drawing water
local radarX, radarY	=	30, 60
local radarWidth, rw	= 	256, 256		-- Width of the radar on screen in pixels
local drawWidth, radarRatio		= 	0.24 * resX, 3/4		-- width / heigth
local radarZoom 		= 	10		-- Image pixels zoom radius (so the shown square = 2*radarZoom)
local rotate			=	true
local tilted			= 	true
local heightRotation 	= 	-45		-- Y degree transformation of the map
local mapFile 			= 	'images/radar.jpg'
local mapFile 			= 	'images/world.png'
-- local mapFile = 	'images/gtasa-blank-1.0.jpg'
local h1, h2			=	0.09, 0.71		-- blip clamping borders
local x1, x2			=	0.13, 0.28
local borderSize		=	0.015
local borderColour		=	tocolor(0,0,0,240)
local healthHeight		= 	0.03
local speedHeight		= 	0.03
local nosHeight			= 	0.03
-- local bdrawDebug 		= 	true

-- Map texture, 6000x6000, with clamping and border color
local mapTexture	=	dxCreateTexture(mapFile, 'argb', true, 'clamp')
dxSetTextureEdge(mapTexture, 'border', waterCol)

local imgSizeX, imgSizeY	= 	dxGetMaterialSize(mapTexture)						-- Get map texture size


radarWidth = radarWidth * 2
local sqrt2		= 	math.sqrt(2)
-- local sqrt2		= 	1
-- We first draw a larger (*sqrt2) version of the radar area bigger than its texture holder, so the radar can rotate without loss
local offset 	= 	- radarWidth * (sqrt2-1) / 2
local diagonal	= 	radarWidth * sqrt2
local clip3D	=	{
	NW = {	x = radarWidth * x1,
			y = radarWidth * h1 },
	NE = {	x = radarWidth * (1 - x1),
			y = radarWidth * h1 },
	SE = {	x = radarWidth * (1 - x2),
			y = radarWidth * h2 },
	SW = {	x = radarWidth * x2,
			y = radarWidth * h2 },
}
local healthImage 		=	dxCreateRenderTarget ( drawWidth, drawWidth, true )			-- Texture holder for health bar
dxSetTextureEdge(healthImage, 'clamp')
local speedImage 		=	dxCreateRenderTarget ( drawWidth, drawWidth, true )			-- Texture holder for speed bar
dxSetTextureEdge(speedImage, 'clamp')
local nosImage 			=	dxCreateRenderTarget ( drawWidth, drawWidth, true )			-- Texture holder for nos bar
dxSetTextureEdge(nosImage, 'clamp')
local radarImage 		=	dxCreateRenderTarget ( radarWidth, radarWidth, true )		-- Texture holder for normal version of the radar area around player
-- dxSetTextureEdge(radarImage, 'clamp')
local radarTransformed	=	dxCreateRenderTarget ( radarWidth, radarWidth, true )		-- Texture holder for transformed version
dxSetTextureEdge(radarTransformed, 'clamp')
local transformShader 	=	dxCreateShader ( 'files/textureReplace.fx' )						-- Extra step, shader needed to be able to use dxSetShaderTransform
dxSetShaderValue(transformShader, 'tex', radarImage)
if tilted then
dxSetShaderTransform(transformShader, 0, heightRotation, 0, 0, -.7, -0.19, false, 0)	-- Transform the map
end
local zoom = 2
local blipTextures = {
	['images/blips/0.png'] = dxCreateTexture ( 'images/blips/0.png', 'argb', true, 'clamp' ),
	['images/blips/0-up.png'] = dxCreateTexture ( 'images/blips/0-up.png', 'argb', true, 'clamp' ),
}


-- Drawing --

function render()
	if not isRadarActivated() then return end
	-- dxSetAspectRatioAdjustmentEnabled( true, 16/9 )
	local radarImage, rot = renderRadar()
	local healthImage =  renderHealth()
	local speedImage =  renderSpeed()
	local nosImage =  renderNos()
	local width, radarH = math.ceil(drawWidth /(radarRatio*2)), math.ceil(drawWidth / 2)
	local borderH, healthH, speedH, nosH = math.ceil(radarH * borderSize), math.ceil(radarH * healthHeight), math.ceil(radarH * speedHeight), math.ceil(radarH * nosHeight)
	local dX, dY = math.ceil(radarX), math.ceil(resY - radarY - radarH - 4 * borderH - healthH - speedH)

	if not nosImage then
		dxDrawRectangle ( dX - borderH, dY - borderH, borderH, radarH + 4 * borderH + healthH + speedH, borderColour )
		dxDrawRectangle ( dX + width,   dY - borderH, borderH, radarH + 4 * borderH + healthH + speedH, borderColour )
		dxDrawRectangle ( dX, dY - borderH, width, borderH, borderColour )
	else
		dxDrawRectangle ( dX - borderH, dY - 2 * borderH - nosH, borderH, radarH + 5 * borderH + healthH + speedH + nosH, borderColour )
		dxDrawRectangle ( dX + width,   dY - 2 * borderH - nosH, borderH, radarH + 5 * borderH + healthH + speedH + nosH, borderColour )
		dxDrawRectangle ( dX,           dY - 2 * borderH - nosH, width, 2 * borderH + nosH, borderColour )
	end

	dxDrawRectangle ( dX, dY + radarH, width, 3 * borderH + healthH + speedH, borderColour )

	if radarImage then
		dxDrawImage ( dX, dY, width, radarH, radarImage, 0, 0, 0, tocolor(255,255,255,255) )
	end

	if healthImage then
		dxDrawImage ( dX, dY + radarH + borderH, width, healthH, healthImage)
	end

	if speedImage then
		dxDrawImage ( dX, dY + radarH + 2 * borderH + healthH, width, speedH, speedImage)
	end

	if nosImage then
		dxDrawImage ( dX, dY - borderH - nosH, width, nosH, nosImage)
	end

	drawTime(dX+2.5, dY, dX + width, dY+radarH )

	drawNorth(dX, dY, width, radarH, rot)


	drawDebug()
end
addEventHandler('onClientRender', root, render, true, 'high' )

function drawNorth (dX, dY, w, h, rot_)
	local size = 24
	local rot = rot_ - 90
	if rot < 0 then rot = rot + 360	end
	local switchAngle = math.deg(math.atan(h/w))		-- the angle where we switch between horizontal or vertical border
	if cos(switchAngle + 180) < cos(rot) and cos(rot) < cos(switchAngle) then
		-- intersect y=0 or y=h with x = 1/slope * (y - y0) + x0 when x,y=w/2,h/2 and slope=tan(rot)
		N_Y = rot > 180 and 0 or h						-- y = h or 0
		N_X = 1/tan(rot) * (N_Y - h/2) + w/2			-- x = intersect
	else
		-- intersect x=0 or x=w with y = 1*slope * (x - x0) + y0 when x,y=w/2,h/2 and slope=tan(rot)
		N_X = cos(rot) > cos(switchAngle) and w or 0	-- x = w or 0
		N_Y = tan(rot) * ( N_X - w/2 ) + h/2			-- y = intersect
	end
	dxDrawImage(dX + N_X - size/2, dY + N_Y - size/2, size, size, 'images/blips/4.png')
end


-- Health --

function renderHealth()
	if not healthImage then return false end
	dxSetRenderTarget(healthImage, true)
	local w, h = dxGetMaterialSize ( healthImage )
	local green = {r=0,g=139,b=0}
	local orange = {r=255,g=165,b=0}
	local red = {r=205,g=51,b=51}
	local c = {r=0, g=0, b=0}
	local target = getTargetPlayer() and getPedOccupiedVehicle(getTargetPlayer()) or false
	local health = target and (getElementHealth(target) - 250) / 750 or 0
	for x=0,math.ceil(w*health) do
		local p = x/w * 2
		if p > 1 then
			p = p-1
			c.r, c.g, c.b = orange.r * (1-p) + green.r * p, orange.g * (1-p) + green.g * p, orange.b * (1-p) + green.b * p
		else
			c.r, c.g, c.b = red.r * (1-p) + orange.r * p, red.g * (1-p) + orange.g * p, red.b * (1-p) + orange.b * p
		end
		dxDrawRectangle(x, 0, 1, h, tocolor(c.r, c.g, c.b) )
	end
	dxSetRenderTarget()
	return healthImage
end


-- Speed --

function renderSpeed()
	local target = getTargetPlayer() and getPedOccupiedVehicle(getTargetPlayer()) or false
	if not target or not speedImage then return false end
	dxSetRenderTarget(speedImage, true)
	local w, h = dxGetMaterialSize ( speedImage )
	local black = {r=0,g=100,b=0}
	local blue = {r=127,g=255,b=0}
	local c = {r=0, g=0, b=0}
	local vx, vy, vz = getElementVelocity(target)
	local speed = math.clip(0, math.sqrt(vx*vx + vy*vy + vz*vz) / 1.5, 1)
	for x=1,math.floor(w*speed) do
		local p = x/w
		c.r, c.g, c.b = black.r * (1-p) + blue.r * p, black.g * (1-p) + blue.g * p, black.b * (1-p) + blue.b * p
		dxDrawRectangle(x, 0, 1, h, tocolor(c.r, c.g, c.b) )
	end
	dxSetRenderTarget()
	return speedImage
end


-- Nos --

function renderNos()
	local target = getTargetPlayer() and getPedOccupiedVehicle(getTargetPlayer()) or false
	local nos = target and getVehicleNitroLevel(target)
	if not nos or nos < 0 or not nosImage then return false end
	dxSetRenderTarget(nosImage, true)
	local w, h = dxGetMaterialSize ( nosImage )
	local a = {r=30,g=70,b=255}
	local b = isVehicleNitroRecharging(target) and a or {r=200,g=255,b=255}
	local c = {r=0, g=0, b=0}
	for x=1,math.floor(w*nos) do
		local p = x/w
		c.r, c.g, c.b = a.r * (1-p) + b.r * p, a.g * (1-p) + b.g * p, a.b * (1-p) + b.b * p
		dxDrawRectangle(x, 0, 1, h, tocolor(c.r, c.g, c.b) )
	end
	dxSetRenderTarget()
	return nosImage
end


-- Radar --

function renderRadar()
	if not imgSizeX then return false end
	local radar = radarImage
	local px, py, pz = getElementPosition ( localPlayer )								-- Player position and rotation
	local rot = rotate and -math.deg(getRot()) or 0
	-- local imgSizeX, imgSizeY	= 	dxGetMaterialSize(mapTexture)						-- Get map texture size
	local imgx, imgy = (px + 3000) * imgSizeX / 6000, (3000 - py) * imgSizeY / 6000		-- Convert players position to image coords with (0, 0) being left top
																						-- and (imgSizeX, imgSizeY) right bottom of the image
	-- Draw the normal radar area, section from mapTexture
	dxSetRenderTarget ( radarImage, true )
	dxDrawImageSection ( offset, offset, diagonal, diagonal, imgx - imgSizeX / radarZoom *sqrt2, imgy - imgSizeY / radarZoom*sqrt2, imgSizeX / radarZoom*2*sqrt2, imgSizeY / radarZoom*2*sqrt2, mapTexture, rot)
	-- Draw blips on normal map area
	drawBlips(rot)

	-- Transform the map, create a tilted 3d effect
	if (tilted) then
		radar = radarTransformed
		dxSetRenderTarget ( radarTransformed, true )
		-- remove 1/4 left and right
		-- remove 1/2 from top,
		dxDrawImage ( -radarWidth/4, -radarWidth*2/4, radarWidth*6/4, radarWidth*2, transformShader)
	end

	-- Draw radar on screen
	dxSetRenderTarget()

	return radar, rot
end


-- Blips --

function drawBlips(rot)
	if bdrawDebug then
		-- draw clipping of 3d blips
		dxDrawLine(clip3D.NW.x, clip3D.NW.y, clip3D.NE.x, clip3D.NE.y, tocolor(255,255,0) )
		dxDrawLine(clip3D.NE.x, clip3D.NE.y, clip3D.SE.x, clip3D.SE.y, tocolor(255,255,0) )
		dxDrawLine(clip3D.SE.x, clip3D.SE.y, clip3D.SW.x, clip3D.SW.y, tocolor(255,255,0) )
		dxDrawLine(clip3D.SW.x, clip3D.SW.y, clip3D.NW.x, clip3D.NW.y, tocolor(255,255,0) )
	end
	rot_ = rot
	local target = getTargetPlayer()
	local px,py,pz=getElementPosition(target)
	local midx, midy = radarWidth/2, radarWidth/2
	local blips = getElementsByType("blip",root,true)
	local blipSize = 32
	table.sort(blips,function(b1,b2) return getBlipOrdering(b1)<getBlipOrdering(b2)	end)
	for _,blip in ipairs(blips) do
		if getElementInterior(target)==getElementInterior(blip) and getElementDimension(target)==getElementDimension(blip) and not (getElementData(target, 'state') and getElementData(target, 'state') ~= 'alive') and not (getElementAttachedTo(blip) and getElementData(getElementAttachedTo(blip), 'state') and getElementData(getElementAttachedTo(blip), 'state') ~= 'alive') then
			local ex,ey,ez=getElementPosition(blip)
			local a = 4/9
			local blipPointRot = 0
			local color = {255,255,255,255}
			local id=getBlipIcon(blip)
			local path = 'images/blips/'..id..'.png'
			local size = math.round ( blipSize*3/5 * getBlipSize(blip)/2 / 2)
			local attachedTo = getElementAttachedTo(blip)

			if id==0 then --handling normal blip showing up or down
				color = {getBlipColor(blip)}
				if pz<ez-5 then
					path='images/blips/0-up.png'
				elseif pz>ez+5 then
					path='images/blips/0-up.png'
					blipPointRot=180
				end
				if attachedTo and getElementType(attachedTo) == 'player' and attachedTo ~= localPlayer then
					local team = getPlayerTeam(attachedTo) or false
					color = team and {getTeamColor ( team )} or color
					-- player blip, alpha, size, whiter
					if path ~= 'images/blips/0-up.png' then
						path = 'images/blips/2.png'
						blipPointRot = -(getPedRotation(attachedTo)) + rot
					size = size * sqrt2
					end
					size = size * sqrt2
					if color[1] == 200 and color[2] == 200 and color[3] == 200 and color[4] == 255 then
						color = {255, 255, 255, 240}
					end
				end
			end

			local bx, by =  (ex - px)*a, -(ey - py)*a
			local d = math.sqrt(bx^2 + by^2)
			-- local angle = math.deg(math.atan2(bx,by))
			local angle = math.rad(90 - math.deg(math.atan2(bx,by)) + rot)
			bx = math.round( d*math.cos(angle) + midx)
			by = math.round( d*math.sin(angle) + midy)

			if tilted then
				local minH, maxH = (h1 - 0.0) * radarWidth, (h2 - 0.0) * radarWidth
				sl_l, sl_r 	= ( h2 - h1 ) / ( x2 - x1 ), ( h2 - h1 ) / ( x1 - x2 )
				i_l, i_r 	= ( h2 - sl_l * x2 ) * radarWidth, ( h2 - sl_r * (1-x2) ) * radarWidth

				-- dxDrawLine ( (rw*2-i_l)/sl_l, rw*2, (-i_l)/sl_l, 0, tocolor(0, 0, 255) )
				-- dxDrawLine ( (rw*2-i_r)/sl_r, rw*2, (-i_r)/sl_r, 0, tocolor(0, 0, 255) )

				if (by > sl_l * (bx) + i_l) then
					-- color = tocolor(255,0,0,100)
					local bx_, by_ = getProjectionOffPointOnLine ( sl_l, i_l, bx, by )
					-- dxDrawLine(bx, by, bx_, by_, tocolor(0,255,0))
					bx, by = bx_, by_
				elseif (by > sl_r * (bx) + i_r) then
					-- color = tocolor(0,0,0,100)
					local bx_, by_ = getProjectionOffPointOnLine ( sl_r, i_r, bx, by )
					-- dxDrawLine(bx, by, bx_, by_, tocolor(0,255,0))
					bx, by = bx_, by_
				end
				if ( by < minH ) then
					by = minH
					bx = math.clip ( x1 * radarWidth, bx, (1 - x1) * radarWidth )
				elseif ( maxH < by ) then
					by = maxH
					-- bx = math.clip ( (x2 - 0.5) * radarWidth, bx, (1 - x2 - 0.5) * radarWidth )
					bx = math.clip ( x2 * radarWidth, bx, (1 - x2) * radarWidth )
				end
			else
				bx = math.clip ( 0, bx, radarWidth )
				by = math.clip ( 0, by, radarWidth )
			end
			local customBlipPath = getElementData(blip,'customBlipPath')
			if type(customBlipPath)=='string' then
				path=customBlipPath
			end

			dxDrawImage ( bx - size, by - size, size*2, size*2, blipTextures[path] or path, blipPointRot, 0, 0, tocolor(color[1], color[2], color[3], color[4] ))
		end
	end
	if getPedOccupiedVehicle(localPlayer) and getCameraTarget() == getPedOccupiedVehicle(localPlayer) then
		local playerBlipPath = 'images/blips/2.png'
        local team = getPlayerTeam(localPlayer) or false
        local color = team and {getTeamColor ( team )} or {255, 255, 255, 255}
		dxDrawImage(midx - blipSize/2,midx - blipSize/2, blipSize, blipSize, blipTextures[playerBlipPath] or playerBlipPath, rot -(getPedRotation(localPlayer)), 0, 0, tocolor(color[1], color[2], color[3], color[4]))
	end
end

-- Time --
local showTime = true
function drawTime(left,top,right,bottom)
	if not showTime then return end
	local time = getRealTime()
	local hour = time.hour
	if hour < 10 then
		hour = "0"..hour
	end
	local minute = time.minute
	if minute < 10 then
		minute = "0"..minute
	end

	dxDrawText(tostring(hour)..":"..tostring(minute),left+1,top+1,right+1,bottom+1,tocolor(0,0,0,180),1,"default-bold","left","top")
	dxDrawText(tostring(hour)..":"..tostring(minute),left,top,right,bottom,tocolor(255,255,255,180),1,"default-bold","left","top")
end


-- Utility --
sin = function(a) return math.sin(math.rad(a)) end
cos = function(a) return math.cos(math.rad(a)) end
tan = function(a) return math.tan(math.rad(a)) end
asin = function(a) return math.deg(math.asin(a)) end
acos = function(a) return math.deg(math.acos(a)) end
atan = function(a) return math.deg(math.atan(a)) end

function getProjectionOffPointOnLine(slope, intercept, x, y)
	-- local px = (slope * y + x - slope * intercept) / (slope^2 + 1)
	-- local py = (slope^2 * y + slope * x + intercept) / (slope^2 + 1)
	local px = (y - intercept) / slope
	local py = y
	return px, py
end

function getTargetPlayer()
	local target = getCameraTarget()
	if not (target or isElement(target)) then
		return localPlayer
	elseif getElementType ( target ) == 'player' then
		return target
	elseif getElementType ( target ) == 'vehicle' then
		return getVehicleController(target) or localPlayer
	end
	return localPlayer
end

function getRot() --function extracted from customblips resource
	local camRot
	local cameraTarget = getCameraTarget()
	if not cameraTarget then
		local px,py,_,lx,ly = getCameraMatrix()
		camRot = getVectorRotation(px,py,lx,ly)
	else
		if vehicle then
			-- if getControlState'vehicle_look_behind' or ( getControlState'vehicle_look_left' and getControlState'vehicle_look_right' ) or ( getVehicleType(vehicle)~='Plane' and getVehicleType(vehicle)~='Helicopter' and ( getControlState'vehicle_look_left' or getControlState'vehicle_look_right' ) ) then
				-- camRot = -math.rad(getPedRotation(localPlayer))
			-- else
				local px,py,_,lx,ly = getCameraMatrix()
				camRot = getVectorRotation(px,py,lx,ly)
			-- end
		elseif getPedControlState(getLocalPlayer(), "look_behind") then
			camRot = -math.rad(getPedRotation(localPlayer))
		else
			local px,py,_,lx,ly = getCameraMatrix()
			camRot = getVectorRotation(px,py,lx,ly)
		end
	end
	return camRot
end

function getVectorRotation(px,py,lx,ly)
	local rotz=6.2831853071796-math.atan2(lx-px,ly-py)%6.2831853071796
	return -rotz
end

function getPointFromDistanceRotation(x,y,dist,angle)
	local a=math.rad(90-angle)
	local dx=math.cos(a)*dist
	local dy=math.sin(a)*dist
	return x+dx,y+dy
end

function math.clip(min,val,max)
	return math.max(min,math.min(max,val))
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

-- local px,py,pz=getElementPosition(localPlayer)
-- local blip1 = createBlip( px-380, py+250, pz, 0, 2, 255, 255, 255, 255 )
-- for i=-1,1,2 do for j = -1,1,2 do
-- local blip1 = createBlip( px+i*500, py+j*500, pz, 0, 2, 255, 255, 255, 255 )
-- local blip2 = createBlip( px+i*250, py+j*250, pz, 0, 2, 255, 0, 255, 255 )
-- local blip3 = createBlip( px+i*375, py+j*375, pz, 0, 2, 255, 255, 0, 255 )
-- end end

function drawDebug()
	if not bdrawDebug then return end
	_, py = getElementPosition(localPlayer)
	t = {
		tick = tick,
		NOS = NOS,
		lastNOS = lastNOS,
		d = d,
		angle = angle,
		bax = bax,
		bay = bay,
		debughealth = debughealth,
	}
	local i = 0
	for k, v in pairs(t) do
		i = i+1
		dxDrawText(i .. '. '.. k .. ' : ' .. tostring(v), 10, 200 + i*20)
	end
	if true then return end
	dxSetRenderTarget()

	local x, y = 200, 50
	dxDrawImage ( x, y+radarWidth, radarWidth, -radarWidth, radarImage)	-- Normal map
	for i = 1,10 do	-- Line grid over normal map
		-- dxDrawLine(x + radarWidth *i/10,y,x + radarWidth *i/10,y + radarWidth, tocolor(255,0,0) )
		-- dxDrawLine(x,y + radarWidth *i/10,x + radarWidth,y + radarWidth *i/10, tocolor(255,0,0) )
	end
	-- dxDrawLine(x , y , x + radarWidth, y + radarWidth, tocolor(255,0,0) )
	-- dxDrawLine(x + clip3D.NW.x, y + clip3D.NW.y, x + clip3D.NE.x, y + clip3D.NE.y, tocolor(255,255,0) )
	-- dxDrawLine(x + clip3D.NE.x, y + clip3D.NE.y, x + clip3D.SE.x, y + clip3D.SE.y, tocolor(255,255,0) )
	-- dxDrawLine(x + clip3D.SE.x, y + clip3D.SE.y, x + clip3D.SW.x, y + clip3D.SW.y, tocolor(255,255,0) )
	-- dxDrawLine(x + clip3D.SW.x, y + clip3D.SW.y, x + clip3D.NW.x, y + clip3D.NW.y, tocolor(255,255,0) )


	shaderX, shaderY = dxGetMaterialSize(transformShader)
	dxDrawImage ( 1000, 50, shaderX, shaderY, transformShader)	-- Transformed map
	dxDrawRectangle(1000, 50, shaderX, shaderY,tocolor(255,255,255,155),false)	-- Original drawing area before transformation
	local b = 0.06
	dxDrawLine(1000 - shaderX * (b), 50, 1000 + shaderX * (1+b), 50, tocolor(255,0,0) )-- Top line transformed map


	dxDrawLine(radarX * resX,radarY * resY+radarWidth/2,radarX * resX+radarWidth /(radarRatio*2),radarY * resY, tocolor(255,255,0) )	-- Corner line over final map

	-- dxDrawImage ( 1000, 400, radarWidth*3/2, radarWidth*2, transformShader)
	-- dxDrawLine(radarX * resX,radarY * resY,radarX * resX+radarWidth /(radarRatio*2),radarY * resY+radarWidth/2, tocolor(255,0,0) )
	-- dxDrawLine(radarX * resX,radarY * resY+radarWidth/2,radarX * resX+radarWidth /(radarRatio*2),radarY * resY, tocolor(255,0,0) )
end

function handleRestore( didClearRenderTargets )
    if didClearRenderTargets then
        outputDebugString ( 'render targets cleared' )
    end
end
addEventHandler("onClientRestore",root,handleRestore)

local rockets = {}
function rocket (creator)
	if getElementType(creator) == "vehicle" then
		local projectile = source
		local blip = createBlipAttachedTo ( projectile, 0, 1, 0, 0, 0, 255, -1000)
		rockets[getVehicleController(creator)] = blip
		setElementParent(blip, projectile)
		setTimer(function() if blip and isElement(blip) then destroyElement(blip) end end, 4000, 1)
	end
end
addEventHandler('onClientProjectileCreation', root, rocket)

addEventHandler('onClientExplosion', root, function(x, y, z, type)
	if rockets[source] and isElement(rockets[source]) then
		destroyElement(rockets[source])
	end
end)


--[[
lastNOS = nil
NOS = -1
function checkNOS()
	if not lastNOS then return end
	local tick = (getTickCount() - lastNOS) / 1000
	if tick <= 20 then
		NOS = (20 - tick) * 5
	elseif tick <= 40 then
		NOS = (tick - 20) * 5
	else
		NOS = 100
		lastNOS = nil
		outputDebugString('NOS reloaded')
	end
end

function NOS_refill()
	outputDebugString('NOS_refill')
	NOS = 100
	lastNOS = nil
end
addEvent('NOS_refill', true)
addEventHandler('NOS_refill', resourceRoot, NOS_refill)

function onClientVehicleNitroStateChange(state)
	outputDebugString('onClientVehicleNitroStateChange ' .. tostring(state))
	if state == true and getVehicleController(source) == localPlayer then
		lastNOS = getTickCount()
	end
end
addEventHandler('onClientVehicleNitroStateChange', root, onClientVehicleNitroStateChange)

function onClientPlayerWasted()
	outputDebugString('onClientPlayerWasted ')
	lostNOS()
end
addEventHandler('onClientPlayerWasted', localPlayer, onClientPlayerWasted)

local prev
setTimer( function()
	local veh = getPedOccupiedVehicle(localPlayer)
	if prev then
		if not (veh and isElement(veh)) then
			prev = nil
			lostNOS()
		elseif prev ~= getElementModel(veh) then
			prev = getElementModel(veh)
			lostNOS()
		end
	elseif veh and getElementModel(veh) then
		prev = getElementModel(veh)
		lostNOS()
	end

end, 50, 0)

function lostNOS()
	outputDebugString('lostNOS()')
	lastNOS = nil
	NOS = -1
end
]]
