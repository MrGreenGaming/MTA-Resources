
Deadline = {}
Deadline.recordData = {}
Deadline.lastRecordTime = 0
Deadline.recordInterval = 15
Deadline.boostCooldownTimer = false
Deadline.jumpCooldownTimer = false
Deadline.notMovingTick = false
Deadline.speedTimer = false
Deadline.wasAlreadyHit = false


Deadline.deadWallTex = false
Deadline.deadWallColorTex = false
Deadline.deadWallTexWidth = 500 -- Width of .gif texture used
Deadline.deadWallTexHeight = 432 -- Height of .gif texture used
Deadline.deadWallTexMover = 0 
Deadline.deadWallAlpha = 0
Deadline.texSplitInto_Cache = false
Deadline.deadWallBlip = false

Deadline.gcshop_deadlinecolor_table = {}
------------------------
-- Gameplay Variables Standards - Will be updated serversided --
DeadlineOptions = {}
-- DeadlineOptions.size = 50 -- Size of line
-- DeadlineOptions.minimumSpeed = 60 -- Minimum speed (in km/h)
-- DeadlineOptions.boostSpeed = 100 -- Boost Speed (added to current speed)
-- DeadlineOptions.boost_cooldown = 35000 -- boost cooldown in ms
-- DeadlineOptions.jumpHeight = 0.25 -- Jump Height
-- DeadlineOptions.jump_cooldown = 15000 -- jump cooldown in ms
-- DeadlineOptions.notMovingKillTime = 10000 -- Kill time for not moving, also counts if reversing (ms)
-- DeadlineOptions.godmode = true -- set bool if vehicles should be immume to collisions or not
-- DeadlineOptions.lineAliveTime = 1600 -- Set how long a line should be alive (in ms) -- 1200
-- DeadlineOptions.deadWallRadiusMin -- Minimum dead wall radius
-- DeadlineOptions.deadWallRadiusMax -- Maxiumum dead wall radius
-- DeadlineOptions.deadWallX -- deadWall X pos
-- DeadlineOptions.deadWallY -- deadwall Y pos
-- DeadlineOptions.deadWallRadius = getElementData(resourceRoot,'deadline.radius')
-- 
-- Gameplay Variables Standards - Will be updated serversided --
------------------------







function Deadline.load(settings)


	Deadline.unload()
	dl_initTimeBars()

	Deadline.deadWallTex = createBrowser(Deadline.deadWallTexWidth,Deadline.deadWallTexHeight,true,true)
	Deadline.deadWallColorTex = dxCreateTexture("img/dl_colorTex.png")




	DeadlineOptions = settings
	if getResourceFromName'customblips' then
		Deadline.deadWallBlip1 = exports.customblips:createCustomBlip ( DeadlineOptions.deadWallX, DeadlineOptions.deadWallY, 90, 90, 'img/dl_DeadWallIcon.png', 50000 )
	end
		
	Deadline.deadWallBlip2 = createBlip( DeadlineOptions.deadWallX, DeadlineOptions.deadWallY, 0, 56, 10 )
	setBlipVisibleDistance(Deadline.deadWallBlip2,0) -- Hide real blip, only show custom blip
	setElementData(Deadline.deadWallBlip2,"customBlipPath",':race/img/dl_DeadWallIcon.png')
	setElementData(Deadline.deadWallBlip2,"customBlipIgnoreDist", true)

	--------------------------------
	-----Load GC shop line color----
	for id, player in ipairs(getElementsByType("player")) do 
		local color = getElementData( player, 'gcshop_deadlinecolor' )
		if color and getColorFromString(color) then
			local pr,pb,pg = getColorFromString(color)
			Deadline.gcshop_deadlinecolor_table[player] = {r=pr,b=pb,g=pg}
		end
	end 
	-----Load GC shop line color----
	--------------------------------

	addEventHandler("onClientRender", root, Deadline.record)
	addEventHandler("onClientRender", root, Deadline.draw)

	if isTimer(Deadline.speedTimer) then killTimer( Deadline.speedTimer ) end
	Deadline.speedTimer = setTimer( Deadline.handleSpeed, 100,0 )
	
end
addEvent("onClientSetUpDeadlineDefinitions", true)
addEventHandler("onClientSetUpDeadlineDefinitions", root, Deadline.load)
addEventHandler('onClientBrowserCreated',root,
	function()
		if source == Deadline.deadWallTex then
			loadBrowserURL(Deadline.deadWallTex,'http://mta/local/img/dl_DeadWallTex.html')
		end
	end
)

function Deadline.unload()

	dl_stopTimeBars()
	Deadline.notMovingTick = false
	warnedPlayerNotMoving = false
	if isTimer(Deadline.speedTimer) then
		killTimer( Deadline.speedTimer )
	end

	if isTimer(Deadline.jumpCooldownTimer) then
		killTimer( Deadline.jumpCooldownTimer )

	end
	if isTimer(Deadline.boostCooldownTimer) then
		killTimer( Deadline.boostCooldownTimer )

	end
	
	Deadline.gcshop_deadlinecolor_table = {}
	Deadline.recordData = {}
	Deadline.wasAlreadyHit = false
	setElementData(localPlayer, "Deadline_size", DeadlineOptions.size)
	
	removeEventHandler("onClientRender", root, Deadline.record)
	removeEventHandler("onClientRender", root, Deadline.draw)

	-- Deadwall unload
	if Deadline.deadWallBlip1 then
		if getResourceFromName'customblips' then
			exports.customblips:destroyCustomBlip(Deadline.deadWallBlip1)
		end
	Deadline.deadWallBlip1 = false
	end

	if isElement(Deadline.deadWallBlip2) then destroyElement(Deadline.deadWallBlip2) end
	if isElement(Deadline.deadWallTex) then destroyElement( Deadline.deadWallTex ) end
	if isElement(Deadline.deadWallColorTex) then destroyElement(Deadline.deadWallColorTex) end
	
end
addEvent("onClientSetDownDeadlineDefinitions", true)
addEventHandler("onClientSetDownDeadlineDefinitions", root, Deadline.unload)


local warnedPlayerNotMoving = false
function Deadline.handleSpeed()
	localVehicle = getPedOccupiedVehicle(localPlayer)
	if not localVehicle then return end
	-- damageproof
	if DeadlineOptions.godmode and not isVehicleDamageProof(localVehicle) then
		setVehicleDamageProof(localVehicle,true)
		fixVehicle( localVehicle )
	end
	
	if not isVehicleOnGround(localVehicle) then return end

	

	local currentSpeed = dl_getElementSpeed(localVehicle,'km/h')
	if not currentSpeed then return end
	-- Deadline.notMovingTick
	-- Anti Camp Check
	if currentSpeed == 0 or dl_isVehicleReversing(localVehicle) then
		if Deadline.notMovingTick then -- If tick already exists,
			local timeDiff = getTickCount() - Deadline.notMovingTick
			-- outputDebugString('Not Moving/ Reversing time Difference = '..tostring(timeDiff))
			-- outputDebugString('Diff: '..tostring(timeDiff)..' - notmovingTime: '..DeadlineOptions.notMovingKillTime)

			if timeDiff > (DeadlineOptions.notMovingKillTime/2) and warnedPlayerNotMoving == false then -- warn player for not moving forward, warns at half time of killing
				outputChatBox("WARNING: you will be killed if you don't move forward!", 255, 0, 0)
				outputChatBox("WARNING: you will be killed if you don't move forward!", 255, 0, 0)
				warnedPlayerNotMoving = true

			elseif timeDiff > DeadlineOptions.notMovingKillTime then -- Kill player for not moving forward
				setElementHealth( localPlayer, 0 )
				warnedPlayerNotMoving = false
				outputChatBox("You have been killed for not moving forward!", 255, 0, 0)
			end

		else -- If tick doesnt exist, make tick
			Deadline.notMovingTick = getTickCount()
		end

		return
	end


	if currentSpeed < DeadlineOptions.minimumSpeed then
		-- Instead of putting speed to minimumSpeed, gradually increase it.
		-- dl_setElementSpeed(localVehicle,'km/h',DeadlineOptions.minimumSpeed)
		-- outputDebugString( 5+currentSpeed)
		local incrSpeed = (DeadlineOptions.minimumSpeed/3)+currentSpeed
		dl_setElementSpeed(localVehicle,'km/h',(incrSpeed))

	end
	Deadline.notMovingTick = false
	warnedPlayerNotMoving = false
end




function Deadline.record()

	if getTickCount() - Deadline.lastRecordTime < Deadline.recordInterval then return end
	
	Deadline.lastRecordTime = getTickCount()

	
	for i, player in pairs(getElementsByType('player')) do
	
		while true do
		
			local vehicle = getPedOccupiedVehicle(player)
			if isPedDead(player) then 
				Deadline.recordData[player] = nil
				break 
			end
			if not vehicle then break end

			if not Deadline.recordData[player] then
			
				Deadline.recordData[player] = {}
				
			end

			local playerRecordTable = Deadline.recordData[player]

			local firstInsertCreated = false
			if Deadline.recordData[player][1] then
				firstInsertCreated = getTickCount() - Deadline.recordData[player][1]['timeCreated']
			end
			
			if firstInsertCreated and firstInsertCreated > DeadlineOptions.lineAliveTime  then
				
				table.remove(Deadline.recordData[player], 1)
				
			end

			

			local vehPosx,vehPosy,vehPosz = getElementPosition( vehicle )

			
			if isElementStreamedIn( vehicle ) then
				local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(vehicle)
				-- outputDebugString('minx: '..minx..'  miny: '..miny..'  minz: '..minz..'  maxx: '..maxx..'  maxy: '..maxy..'  maxz: '..maxz)
				local MatrixvehPosx,MatrixvehPosy,MatrixvehPosz = dl_getPositionFromElementOffset(vehicle,0,(miny+0.7),0)
				if MatrixvehPosx then
					vehPosx,vehPosy,vehPosz = MatrixvehPosx,MatrixvehPosy,MatrixvehPosz 
				end
			end


			local size = DeadlineOptions.size

			-- if dl_isVehicleReversing(vehicle) or dl_getElementSpeed(vehicle,'km/h') < (DeadlineOptions.minimumSpeed/100*80) then return end			
			
			table.insert(Deadline.recordData[player], {position = {x=vehPosx,y=vehPosy,z=vehPosz}, size = size, timeCreated = getTickCount() })
		
			break
			
		end
		
	end
	
end



function Deadline.draw()
	local wallRadius = getElementData(resourceRoot,'deadline.radius')
	if tonumber(wallRadius) and DeadlineOptions.deadWallEnabled then
		Deadline.drawWall(DeadlineOptions.deadWallX,DeadlineOptions.deadWallY,wallRadius)
	end

	for i, player in pairs(getElementsByType('player')) do
		
		while true do

			if not Deadline.recordData[player] or #Deadline.recordData[player] < 2 then break end
			if isPedDead( player ) then 
				break 
			end

			if not getPedOccupiedVehicle(player) then break end

			if not isElementStreamedIn(player) then break end
			-- local r1, g1, b1, r2, g2, b2 = getVehicleColor(getPedOccupiedVehicle(player), true)
			local r1, b1, g1 = 255,255,255


			-- local gcshop_color = getElementData(player,'gcshop_deadlinecolor')
			local gcshop_color = Deadline.gcshop_deadlinecolor_table[player]

			if gcshop_color then
				

				r1, g1, b1 = gcshop_color['r'],gcshop_color['b'],gcshop_color['g']
			end

			
		
			for i = 2, #Deadline.recordData[player], 1 do
				
				local r, g, b = r1, g1, b1
				local opacity = 255
				if player == localPlayer then
					opacity = 140
				end
				

				
				while true do
					
					if player ~= localPlayer then
						dxDrawLine3D(Deadline.recordData[player][i-1].position.x, Deadline.recordData[player][i-1].position.y, Deadline.recordData[player][i-1].position.z, Deadline.recordData[player][i].position.x, Deadline.recordData[player][i].position.y, Deadline.recordData[player][i].position.z, tocolor ( 255, 255, 255, 150 ), (Deadline.recordData[player][i-1].size+2) )
					end
					dxDrawLine3D(Deadline.recordData[player][i-1].position.x, Deadline.recordData[player][i-1].position.y, Deadline.recordData[player][i-1].position.z, Deadline.recordData[player][i].position.x, Deadline.recordData[player][i].position.y, Deadline.recordData[player][i].position.z, tocolor ( r, g, b, opacity ), Deadline.recordData[player][i-1].size)

					if Deadline.wasAlreadyHit then break end
					
					if player == localPlayer then break end
					

					


					Deadline.checkHit(player, Deadline.recordData[player][i-1].position.x, Deadline.recordData[player][i-1].position.y, Deadline.recordData[player][i-1].position.z, Deadline.recordData[player][i].position.x, Deadline.recordData[player][i].position.y, Deadline.recordData[player][i].position.z)
	
					break
					
				end
	
			end
				
		break
		
		end
		
	end
	
end


function Deadline.checkHit(player, x, y, z, x1, y1, z1)

	if Deadline.wasAlreadyHit then return end
	-- Save resources, processLineOfSight is an expensive function
	-- outputDebugString(getDistanceBetweenPoints3D(x, y, z, getElementPosition(localPlayer)) )
	if getDistanceBetweenPoints3D(x, y, z, getElementPosition(localPlayer)) > 20 then return end



	local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(x, y, z, x1, y1, z1, false, true, true, false, false, false, nil, false, false)
					
	if not hit then return end
	
	local localVehicle = getPedOccupiedVehicle(localPlayer)
		
	if hitElement ~= localPlayer and hitElement ~= localVehicle then return end
		
	triggerServerEvent("onPlayerDeadlineWasted", localPlayer, player)

	blowVehicle(localVehicle)

	Deadline.wasAlreadyHit = true
	
end




-- Late joiners, draw lines
addEventHandler( "onClientResourceStart", getResourceRootElement(),
    function ( )
    	triggerServerEvent('deadlineShouldDrawLines',getResourceRootElement())
    end
);
addEvent( 'clientShouldDrawLines' ,true)
function Deadline.drawLinesLateJoiner(bool,settings)
	if bool then
		DeadlineOptions = settings
		Deadline.wasAlreadyHit = true
		Deadline.deadWallTex = createBrowser(Deadline.deadWallTexWidth,Deadline.deadWallTexHeight,true,true)
		Deadline.deadWallColorTex = dxCreateTexture("img/dl_colorTex.png")
		addEventHandler("onClientRender", root, Deadline.record)
		addEventHandler("onClientRender", root, Deadline.draw)
	end
end
addEventHandler( 'clientShouldDrawLines', getResourceRootElement(), Deadline.drawLinesLateJoiner )

-- TimeBars
-- TIME BARS


function dl_redGreen_prc(percent)
	return tocolor(r,g,0)
end

function dl_cd_handler(boostorjump)
	-- outputChatBox('Triggered for '..tostring(boostorjump)..' while timer is '..tostring(isTimer(Deadline.boostCooldownTimer))..' '..tostring(isTimer(Deadline.jumpCooldownTimer)))

	if boostorjump == "boost" and isTimer(Deadline.boostCooldownTimer) == false then
		-- deadlineBoost()
		setElementData( localPlayer, 'deadline.boostOnCooldown', true)
		Deadline.boostCooldownTimer = setTimer(function() Deadline.boostCooldownTimer = false setElementData( localPlayer, 'deadline.boostOnCooldown', false) end,DeadlineOptions.boost_cooldown,1)
	elseif boostorjump == "jump" and isTimer(Deadline.jumpCooldownTimer) == false then
		-- deadlineJump()
		setElementData( localPlayer, 'deadline.jumpOnCooldown', true)
		Deadline.jumpCooldownTimer = setTimer(function() Deadline.jumpCooldownTimer = false setElementData( localPlayer, 'deadline.jumpOnCooldown', false) end,DeadlineOptions.jump_cooldown,1)
	end
end


local screenW, screenH = guiGetScreenSize()
local scaleH = screenH/1080
local jumpBar_x = math.ceil(screenW * 0.415)
local jumpBar_y = math.ceil(screenH * 0.860)
local jumpBar_w = math.ceil(screenW * 0.194)
local jumpBar_h = math.ceil(screenH * 0.020)
local jumpBar_color = tocolor(0, 255, 0, 100)

local boostBar_x = math.ceil(screenW * 0.415)
local boostBar_y = math.ceil(screenH * 0.824)
local boostBar_w = math.ceil(screenW * 0.194)
local boostBar_h = math.ceil(screenH * 0.020)
local boostBar_color = tocolor(0, 255, 0, 100)

local percentColor = {}
function dl_draw_timerbars()
	if getElementData(localPlayer,"state") ~= "alive" then return end -- draw only when player is alive
	
	local boostWidth = boostBar_w
	local jumpWidth = jumpBar_w
	local jumpDynamicColor = jumpBar_color
	local boostDynamicColor = boostBar_color

	if isTimer(Deadline.boostCooldownTimer) then -- check Shoot timer
		local msLeft = getTimerDetails(Deadline.boostCooldownTimer)
		local percentageLeft = msLeft/DeadlineOptions.boost_cooldown*100-100
		boostWidth = boostWidth/100*math.abs(percentageLeft)

		-- color
		local red,green = sh_getColorFromPercent(math.floor(math.abs(percentageLeft)))
		if red and green then
			boostDynamicColor = tocolor(red,green,0,100)
		end
	end
	if isTimer(Deadline.jumpCooldownTimer) then -- Check jump timer
		local msLeft = getTimerDetails(Deadline.jumpCooldownTimer)
		local percentageLeft = msLeft/DeadlineOptions.jump_cooldown*100-100
		jumpWidth = jumpWidth/100*math.abs(percentageLeft)
		
		-- color
		local red,green = dl_getColorFromPercent(math.floor(math.abs(percentageLeft)))
		if red and green then
			jumpDynamicColor = tocolor(red,green,0,100)
		end
	end



	local bg = dxDrawRectangle(screenW * 0.385, screenH * 0.813, screenW * 0.230, screenH * 0.078, tocolor(0, 0, 0, 181), false)
	local jumpBar_bg_outline = dxDrawRectangle( jumpBar_x - 1, jumpBar_y - 1, jumpBar_w + 2, jumpBar_h + 2, tocolor(0, 0, 0, 255), false)
	local jumpBar_bg = dxDrawRectangle(jumpBar_x, jumpBar_y, jumpBar_w, jumpBar_h, tocolor(15, 15, 15, 255), false)
	local jumpBar = dxDrawRectangle(jumpBar_x, jumpBar_y, jumpWidth, jumpBar_h, jumpDynamicColor, false)

	local boostBar_bg_outline = dxDrawRectangle(boostBar_x - 1, boostBar_y - 1, boostBar_w + 2, boostBar_h + 2, tocolor(0, 0, 0, 255), false)
	local boostBar_bg = dxDrawRectangle(boostBar_x, boostBar_y, boostBar_w, boostBar_h, tocolor(15, 15, 15, 255), false)
	local boostBar = dxDrawRectangle(boostBar_x, boostBar_y, boostWidth, boostBar_h, boostDynamicColor, false)
	
	local rocketIMG = dxDrawImage(math.ceil(screenW * 0.393), math.ceil(screenH * 0.824), math.ceil(screenW * 0.013), math.ceil(screenW * 0.013), "img/speedicon.png", 0, 0, 0, boostDynamicColor, false)
	local jumpIMG = dxDrawImage(math.ceil(screenW * 0.393), math.ceil(screenH * 0.859), math.ceil(screenW * 0.013), math.ceil(screenW * 0.013), "img/arrow-up.png", 0, 0, 0, jumpDynamicColor, false)


end

function dl_initTimeBars()
	addEventHandler("onClientRender",root,dl_draw_timerbars)
end

function dl_stopTimeBars()
	removeEventHandler("onClientRender",root,dl_draw_timerbars)
end
addEventHandler( 'onClientMapStarting',resourceRoot, dl_stopTimeBars )

function dl_getColorFromPercent(percentage)
	local percentage = tonumber(percentage)
    if not percentage or percentage and type(percentage) ~= "number" or percentage > 100 or percentage < 0 then outputDebugString( "Invalid argument @ 'getRGColorFromPercentage'", 2 ) return false end
    if percentage > 50 then
	local temp = 100 - percentage
        return temp*5.1, 255
    elseif percentage == 50 then
	return 255, 255
    else
	return 255, percentage*5.1
    end
end


function deadlineBoost()
	if isTimer(Deadline.boostCooldownTimer) then return end
	local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
	local currentSpeed = dl_getElementSpeed(occupiedVehicle,'km/h')
	dl_setElementSpeed(occupiedVehicle,'km/h',DeadlineOptions.boostSpeed+currentSpeed)
	dl_cd_handler("boost")

end

function deadlineJump()
	if isTimer(Deadline.jumpCooldownTimer) then return end
	local veh = getPedOccupiedVehicle(localPlayer)
	local vehID = getElementModel( veh )
	if vehID == 444 or vehID == 556 or vehID == 557 then -- If veh is a monster --
		local posX, posY, posZ = getElementPosition( veh )
		local grndZ = getGroundPosition(posX,posY,posZ)

		if posZ-grndZ < 2 then
			local vx, vy, vz = getElementVelocity ( veh )
       			setElementVelocity ( veh ,vx, vy, vz + DeadlineOptions.jumpHeight )
       			dl_cd_handler("jump")
		end
	elseif (isVehicleOnGround(veh)) then
		local vx, vy, vz = getElementVelocity ( veh )
       		setElementVelocity ( veh ,vx, vy, vz + DeadlineOptions.jumpHeight )
       		dl_cd_handler("jump")
	end
end

function Deadline.receiveNewSettings (settings)
	if settings then
		DeadlineOptions = settings
	end
end



-- Death Wall
function Deadline.drawWall(x,y,rad)
	if not Deadline.deadWallTex or not Deadline.deadWallColorTex then return end

	Deadline.handleDeadWallAlpha()

	local theTarget = getCameraTarget()
	if not isElement(theTarget) or not getElementType(theTarget) then
		theTarget = getLocalPlayer()
	end

	local a,b,c = getElementPosition(theTarget)
	local lowerZ = c - 500 -- lowest point to start drawing
	local upperZ = lowerZ + 10000 -- highest point to stop drawing
	local originx,originy = x,y
	local connections = 150
	
	local point = math.pi * 2 / connections
	local sx,sy

	local widthPart = 1

	local texHeightRepeatTimes = 200
	local radiusBase = 500
	local widthBase = 20.95
	local singleWidth = rad/100*4.19
	local theRatio = widthBase/singleWidth

	local texSplitInto =  math.ceil(theRatio*4)
	if texSplitInto > 10 then -- If bigger then 10, only change every 25, to reduce jenky resizing when small
		if not texSplitInto_Cache then
			texSplitInto_Cache = texSplitInto
		elseif texSplitInto > texSplitInto_Cache + 25 then
			texSplitInto_Cache = texSplitInto
			texSplitInto = texSplitInto_Cache
		elseif texSplitInto_Cache then
			texSplitInto = texSplitInto_Cache
		end
	end



	local texSplitSingle = Deadline.deadWallTexWidth/texSplitInto

	-- Move texture downwards
	Deadline.deadWallTexMover = Deadline.deadWallTexMover + 0.25
	if Deadline.deadWallTexMover > Deadline.deadWallTexHeight then
		Deadline.deadWallTexMover = 0
	end
	


	for i=0,connections do
		local ex = math.cos ( i * point ) * rad
		local ey = math.sin ( i * point ) * rad
		
		if sx then

			-- if (math.fmod(i,6) == 0) then
				-- dxDrawMaterialLine3D( x+sx, y+sy, c+2+(alpha/100*3),x+sx, y+sy, c-1+(alpha/100*3), mrgreenfaceTexture, 4,tocolor(255,255,255,255),false, originx,originy,0 ) -- mrgreen texture
			-- end


			-- Color Texture
			dxDrawMaterialLine3D( x+sx, y+sy, lowerZ, x+sx, y+sy, upperZ,Deadline.deadWallColorTex, rad/100*4.19, tocolor( 0, 255, 0, (Deadline.deadWallAlpha/100)*15 ), originx,originy,0 )
			
			-- Wall Texture
			dxDrawMaterialSectionLine3D( x+sx, y+sy, lowerZ, x+sx, y+sy, upperZ, texSplitSingle*widthPart-texSplitSingle, Deadline.deadWallTexMover, texSplitSingle, Deadline.deadWallTexHeight*texHeightRepeatTimes, Deadline.deadWallTex, rad/100*4.19 , tocolor( 0, 255, 0, Deadline.deadWallAlpha ), originx,originy,0 )
			
			widthPart = widthPart + 1
			if widthPart > texSplitInto then
				widthPart = 1
			end

		end


		sx,sy = ex,ey
	end
end


local dl_alphaMode = 'up' -- 'up' or 'down'
local dl_alphaMax = 180
local dl_alphaMin = 80
local dl_alphaStepUp = 4
local dl_alphaStepDown = 3
local dl_alphaTiming = 50 --ms
local dl_alphaLast = false
function Deadline.handleDeadWallAlpha()
	if not dl_alphaLast then dl_alphaLast = getTickCount() return end

	if getTickCount() < dl_alphaLast + dl_alphaTiming then return end

	if dl_alphaMode == 'up' then
		if Deadline.deadWallAlpha > dl_alphaMax then dl_alphaMode = 'down' return end

		Deadline.deadWallAlpha = Deadline.deadWallAlpha+dl_alphaStepUp
		dl_alphaLast = getTickCount()
		return
	elseif dl_alphaMode == 'down' then
		if Deadline.deadWallAlpha < dl_alphaMin then dl_alphaMode = 'up' return end

		Deadline.deadWallAlpha = Deadline.deadWallAlpha-dl_alphaStepDown
		dl_alphaLast = getTickCount()
		return
	end
end 

-- UTIL

function dl_setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = dl_getElementSpeed(element, unit)
	if (acSpeed) then -- if true - element is valid, no need to check again
		local diff = speed/acSpeed
		if diff ~= diff then return false end -- if the number is a 'NaN' return false.
        local x, y, z = getElementVelocity(element)
        -- outputDebugString(type(x)..' - '..type(y)..' - '..type(z)..' - '..type(diff) )
        if type(x) ~= 'number' or type(y) ~= 'number' or type(z) ~= 'number' or type(diff) ~= 'number' then return false end
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end

	return false
end

function dl_getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ dl_getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ dl_getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ dl_getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function dl_isVehicleReversing(theVehicle)
	local getMatrix = getElementMatrix (theVehicle)
	local getVelocity = Vector3 (getElementVelocity(theVehicle))
	local getVectorDirection = (getVelocity.x * getMatrix[2][1]) + (getVelocity.y * getMatrix[2][2]) + (getVelocity.z * getMatrix[2][3]) 
	if (getVectorDirection >= 0) then
		return false
	end
	return true
end

function dl_getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    if not m then return false end
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end