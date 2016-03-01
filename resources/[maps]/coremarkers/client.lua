math.randomseed(getTickCount())

local pickupDelay = 5000

local powerTypes = {
{"repair"},
{"spikes"},
{"boost"},
{"oil"},
{"hay"},
{"barrels"},
{"ramp"},
{"rocket"}
}


addEventHandler("onClientResourceStart", resourceRoot, 
function()
setElementData(localPlayer, "power_type", nil)
setElementData(localPlayer, "player_have_power", false, true)
setElementData(localPlayer, "slowed down right now", nil, true)
setElementData(localPlayer, "slowDown", false, true)
setElementData(localPlayer, "rektBySpikes", false, true)
setElementData(localPlayer, "boostx3", nil, true)
engineImportTXD ( engineLoadTXD ( "oil.txd" ) , 2717 ) 
engineImportTXD ( engineLoadTXD ( "crate.txd" ) , 3798 ) 
engineSetModelLODDistance(1225, 300)
engineSetModelLODDistance(3374, 300)
engineSetModelLODDistance(2717, 300)
engineSetModelLODDistance(3798, 300)
engineSetModelLODDistance(13645, 300)
end
)

function getRandomPower()
	playSound("marker.mp3")
	local randomPower = unpack(powerTypes[math.random(#powerTypes)])
	
	--Visual effect of random selecting
	setTimer(function() setElementData(localPlayer, "power_type", unpack(powerTypes[math.random(#powerTypes)])) end, 100, pickupDelay/100)
	
	--Delay after picking up pickup
	delayTimer = setTimer(function()
				if math.random(80) == math.random(80) then
					bindKeys("magnet")
				elseif math.random(100) == math.random(100) then
					bindKeys("boostx3")
					setElementData(localPlayer, "boostx3", 3)
				else
					bindKeys(randomPower)
				end
			end,
	pickupDelay+500, 1)
end
addEvent("getRandomPower", true)
addEventHandler("getRandomPower", root, getRandomPower)

function bindKeys(powerType)
bindKey("fire", "down", onPlayerUsePower, powerType)
bindKey("vehicle_fire", "down", onPlayerUsePower, powerType)
	if powerType == "boostx3" then
		setElementData(localPlayer, "power_type", "boost")
	else
		setElementData(localPlayer, "power_type", powerType)
	end
	if powerType == "rocket" then 
		setElementData(localPlayer, "laser.on", true)
	end	
end

function unbindKeys()
unbindKey("fire", "down", onPlayerUsePower)
unbindKey("vehicle_fire", "down", onPlayerUsePower)
setElementData(localPlayer, "power_type", nil)
setElementData(localPlayer, "player_have_power", false, true)	
end
addEvent('unbindKeys', true)
addEventHandler('unbindKeys', root, unbindKeys)

function onPlayerUsePower(key, keyState, powerType)
local theVehicle = getPedOccupiedVehicle(localPlayer)
local x, y, z = getElementPosition(theVehicle)
local _, _, rz = getElementRotation(theVehicle)
local _, minY, minZ, _, _, _ = getElementBoundingBox(theVehicle)
setElementData(localPlayer, "player_have_power", false, true)
unbindKeys()

	if powerType == "spikes" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.2, 0)
		local z = getGroundPosition(x, y, z)		
		triggerServerEvent("dropSpikes", resourceRoot, localPlayer, x, y, z, rz)
	elseif powerType == "boost" then
		local engineAcc = getVehicleOriginalProperty(theVehicle, "engineAcceleration")*2.5
		if engineAcc >= 25 then
			setElementSpeed(theVehicle, "kmh", 290)
		else
			setElementSpeed(theVehicle, "kmh", 260)
		end
	elseif powerType == "boostx3" then
		local boost = getElementData(localPlayer, "boostx3")
		if boost <= 3 then
			setElementData(localPlayer, "player_have_power", true, true)
			local boost = boost-1
			setElementData(localPlayer, "boostx3", boost)
			local engineAcc = getVehicleOriginalProperty(theVehicle, "engineAcceleration")*2.5
			if engineAcc >= 25 then
				setElementSpeed(theVehicle, "kmh", 290)
			else
				setElementSpeed(theVehicle, "kmh", 260)
			end
			if boost == 0 then
				setElementData(localPlayer, "boostx3", nil)
				setElementData(localPlayer, "player_have_power", false, true)
			else
				bindKeys("boostx3")
			end
		end
	elseif powerType == "oil" then 
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.2, 0)
		local z = getGroundPosition(x, y, z)	
		triggerServerEvent("dropOil", resourceRoot, x, y, z, rz)
	elseif powerType == "magnet" then
		triggerServerEvent("doMagnet", resourceRoot, localPlayer)
	elseif powerType == "hay" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-2.4, 0)
		local z = getGroundPosition(x, y, z)	
		triggerServerEvent("dropHay", resourceRoot, x, y, z, rz)
	elseif powerType == "ramp" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-2.1, 0)
		local z = getGroundPosition(x, y, z)	
		triggerServerEvent("dropRamp", resourceRoot, x, y, z, rz)
	elseif powerType == "rocket" then
		triggerServerEvent("outputChatBoxForAll", resourceRoot, localPlayer, "#FFFFFF"..getPlayerName(localPlayer).." #FF4000launches missiles into someone.")
		local x, y, z, vx, vy, vz = getPositionAndVelocityForProjectile(theVehicle, x, y, z)
		createProjectile(theVehicle, 21, x, y, z+0.45, 1, nil, 0, 0, 360 - rz, vx*15, vy*15, vz*15)
		setTimer(createProjectile, 50, 1, theVehicle, 21, x, y, z+0.45, 1, nil, 0, 0, 360 - rz, vx*15, vy*15, vz*15)
		setTimer(createProjectile, 70, 1, theVehicle, 21, x, y, z+0.45, 1, nil, 0, 0, 360 - rz, vx*15, vy*15, vz*15)
	elseif powerType == "barrels" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-1.1, 0)
		local z = getGroundPosition(x, y, z)
		triggerServerEvent("dropBarrels", resourceRoot, 1225, x, y, z, rz)
	elseif powerType == "repair" then
		triggerServerEvent("fixVehicle", resourceRoot, localPlayer, theVehicle, true)
	end
end

addEventHandler("onClientResourceStart", root, function()
	sWidth, sHeight = guiGetScreenSize()

	if sWidth == 1280 and sHeight == 1024 then
		xRight = 1056
		xRightShadow = xRight+2
	elseif sWidth == 1024 and sHeight == 768 then
		xRight = 1050
		xRightShadow = xRight+2
	elseif sWidth == 1280 and sHeight == 720 then
		xRight = 1013
		xRightShadow = xRight+2
	else
		xRight = 1010
		xRightShadow = xRight+2
	end
end
)

addEventHandler( "onClientRender",  root,
	function()
		if getElementData(localPlayer, "power_type") ~= nil then
			dxDrawImage(902.5*sWidth/1920, 120*sHeight/1080, 115*sHeight/1080, 115*sHeight/1080, "pics/"..getElementData(localPlayer, "power_type")..".png", 0, 0, 0, tocolor(255,255,255,255), true)
		end
		
		if getElementData(localPlayer, "power_type") == "rocket" and not isTimer(delayTimer) then
				DrawLaser()
		end
		
		if isElement(getPedOccupiedVehicle(localPlayer)) then
			local s1, _, _, _ = getVehicleWheelStates(getPedOccupiedVehicle(localPlayer))
			if getElementData(localPlayer, "rektBySpikes") and s1 ~= 0 then
				local timeLeft = getTimerDetails(spikesTimer)
				dxDrawImage(860*sWidth/1920, 890*sHeight/1080, 200*sHeight/1080, 200*sHeight/1080, "pics/wheel.png", 0, 0, 0, tocolor(255,255,255,255))
				dxDrawRectangle(1020*sWidth/1920, 897*sHeight/1080, 20*sWidth/1920, 174*sHeight/1080, tocolor(0, 0, 0, 160))
				dxDrawRectangle(1021*sWidth/1920, 898*sHeight/1080, 18*sWidth/1920, 172*sHeight/1080, tocolor(0, 0, 0, 180))
				dxDrawRectangle(1022*sWidth/1920, 899*sHeight/1080, 16*sWidth/1920, 170*sHeight/1080, tocolor(0, 0, 0, 200))
				dxDrawRectangle(1023*sWidth/1920, 900*sHeight/1080, 14*sWidth/1920, 168*sHeight/1080, tocolor(0, 255, 0, 200))
				dxDrawRectangle(1023*sWidth/1920, 900*sHeight/1080, 14*sWidth/1920, timeLeft/10000*168*sHeight/1080, tocolor(30, 30, 30, 200))
			end
		end
		
		if getElementData(localPlayer, "slowDown") then
				dxDrawImage(0, 0, sWidth, sHeight, "pics/effect.png", 0, 0, 0, tocolor(255,255,255,50), true)
		end

		if getElementData(localPlayer, "boostx3") then
			dxDrawText("x"..getElementData(localPlayer, "boostx3"), 0*sWidth/1920, 126*sHeight/1080, xRightShadow*sWidth/1920, 0, tocolor ( 0, 0, 0, 255 ), 1.5*sHeight/1080, "clear", "right", "top", false, false, true, true )
			dxDrawText("x"..getElementData(localPlayer, "boostx3"), 0*sWidth/1920, 124*sHeight/1080, xRight*sWidth/1920, 0, tocolor ( 255, 255, 255, 255 ), 1.5*sHeight/1080, "clear", "right", "top", false, false, true, true )
		end
	end
)

function DrawLaser()
if isElement(getPedOccupiedVehicle(localPlayer)) then
local x, y, z = getElementPosition(getPedOccupiedVehicle(localPlayer))
local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(getPedOccupiedVehicle(localPlayer))
local x2, y2, z2 = getPositionFromElementOffset(getPedOccupiedVehicle(localPlayer), 0, maxY+100, 0.45)
dxDrawLine3D(x,y,z+0.45,x2,y2,z2, tocolor(255,0,0,255), 1)
end
end

function slowDownPlayer(magnetSlowDownTime)
	if isTimer(slowDownTimer) then
		killTimer(slowDownTimer)
	end
	
	setGameSpeed(0.7)
	setElementData(localPlayer, "slowDown", true)
	slowDownTimer = setTimer(function() setGameSpeed(tonumber(1.0)) setElementData(localPlayer, "slowDown", false) end, magnetSlowDownTime, 1)
end
addEvent("slowDownPlayer", true)
addEventHandler("slowDownPlayer", root, slowDownPlayer)

function createExplosionEffect(x, y, z)
createExplosion(x, y, z, 0, true, -1.0, false)

local effects = {}
effects[1] = createEffect("fire", x, y, z-math.random(0.4, 1.2), 0, 0, 0, 100)

effects[2] = createEffect("fire", x+math.random(0.1, 2.0), y+math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[3] = createEffect("fire", x+math.random(0.1, 2.0), y-math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[4] = createEffect("fire", x-math.random(0.1, 2.0), y+math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[5] = createEffect("fire", x-math.random(0.1, 2.0), y-math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)

effects[6] = createEffect("fire", x-math.random(0.1, 2.0), y, z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[7] = createEffect("fire", x+math.random(0.1, 2.0), y, z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[8] = createEffect("fire", x, y-math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)
effects[9] = createEffect("fire", x, y+math.random(0.1, 2.0), z-math.random(0.4, 1.2), 0, 0, 0, 100)

setTimer(function() for k, effect in ipairs(effects) do  destroyElement(effect) end end, 30000, 1)
end
addEvent('createExplosionEffect', true)
addEventHandler('createExplosionEffect', root, createExplosionEffect)

function spikesTimerFunction()
	if isTimer(spikesTimer) then
		killTimer(spikesTimer)
	end
	spikesTimer = setTimer(function() 
		setElementData(localPlayer, "rektBySpikes", false, true) 
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		local s1, _, _, _ = getVehicleWheelStates(theVehicle)
		if s1 ~= 0 then
			playSoundFrontEnd(46)
			triggerServerEvent("fixVehicle", resourceRoot, localPlayer, theVehicle, false)
		end 
	end, 10000, 1)
end
addEvent("spikesTimerFunction", true)
addEventHandler("spikesTimerFunction", root, spikesTimerFunction)

function hideSpikesRepairHUD()
	if isTimer(spikesTimer) then
		killTimer(spikesTimer)
		setElementData(localPlayer, "rektBySpikes", false, true)
	end
end
addEvent("hideSpikesRepairHUD", true)
addEventHandler("hideSpikesRepairHUD", root, hideSpikesRepairHUD)