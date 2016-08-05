math.randomseed(getTickCount())

local delay = 3000


local powerTypes = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					--rare power types
					{"magnet"},
}



addEventHandler("onClientResourceStart", resourceRoot, 
function()
	sWidth, sHeight = guiGetScreenSize()
	
	setElementData(localPlayer, "coremarkers_powerType", false)
	setElementData(localPlayer, "coremarkers_isPlayerSlowedDown", false, true)
	setElementData(localPlayer, "coremarkers_isPlayerRektBySpikes", false, true)
	
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
	
	if math.random(50) == math.random(50) then 
		randomPower = unpack(powerTypes[math.random(9,9)]) --select rare power types
	else
		randomPower = unpack(powerTypes[math.random(1,8)])
	end
	
	if isElement(bgPicture) then destroyElement(bgPicture) end
	if isElement(_typePicture) then destroyElement(_typePicture) end
	bgPicture = guiCreateStaticImage(902.5*sWidth/1920, 120*sHeight/1080, 115*sHeight/1080, 115*sHeight/1080, "pics/background.png", false)
	_typePicture = guiCreateStaticImage(902.5*sWidth/1920, 120*sHeight/1080, 115*sHeight/1080, 115*sHeight/1080, "pics/repair.png", false)
	guiSetAlpha(_typePicture, 0.45)
	
	delayStop = delay-50
	stopRoulette = setTimer(function() if isElement(_typePicture) then destroyElement(_typePicture) end end, delayStop, 1)
	changePic(2)
	givePowerTimer = setTimer(givePower, delay, 1, randomPower)
end
addEvent("getRandomPower", true)
addEventHandler("getRandomPower", root, getRandomPower)

function changePic(s)
	if not isElement(_typePicture) then return end
	
	if not isTimer(stopRoulette) then return end
	
		timeleft = getTimerDetails(stopRoulette) 
		
		if s == 1 then
			guiStaticImageLoadImage(_typePicture, "pics/repair.png")
			setTimer(changePic, 50*(delayStop/timeleft), 1, 2)
		elseif s == 2 then
			guiStaticImageLoadImage(_typePicture, "pics/spikes.png")
			setTimer(changePic, 50*(delayStop/timeleft), 1, 3)
		elseif s == 3 then
			guiStaticImageLoadImage(_typePicture, "pics/boost.png")
			setTimer(changePic, 50*(delayStop/timeleft), 1, 4)
		elseif s == 4 then
			guiStaticImageLoadImage(_typePicture, "pics/oil.png")
			setTimer(changePic, 50*(delayStop/timeleft), 1, 5)
		elseif s == 5 then
			guiStaticImageLoadImage(_typePicture, "pics/hay.png")
			setTimer(changePic, 50*(delayStop/timeleft), 1, 6)
		elseif s == 6 then
			guiStaticImageLoadImage(_typePicture, "pics/barrels.png")
			setTimer(changePic, 50*(delayStop/timeleft), 1, 7)
		elseif s == 7 then
			guiStaticImageLoadImage(_typePicture, "pics/ramp.png")
			setTimer(changePic, 50*(delayStop/timeleft), 1, 8)
		elseif s == 8 then
			guiStaticImageLoadImage(_typePicture, "pics/rocket.png")
			setTimer(changePic, 50*(delayStop/timeleft), 1, 9)
		elseif s == 9 then
			guiStaticImageLoadImage(_typePicture, "pics/magnet.png")
			setTimer(changePic, 50*(delayStop/timeleft), 1, 1)
		end
end

function givePower(powerType)
	typePicture = guiCreateStaticImage(902.5*sWidth/1920, 120*sHeight/1080, 115*sHeight/1080, 115*sHeight/1080, "pics/"..powerType..".png", false)
	
	bindKey("fire", "down", onPlayerUsePower, powerType)
	bindKey("vehicle_fire", "down", onPlayerUsePower, powerType)
	
	setElementData(localPlayer, "coremarkers_powerType", powerType)
	
	if powerType == "rocket" then 
		setElementData(localPlayer, "laser.on", true)
	end	
end



function removePower()
	if onPlayerUsePower ~= nil then
		unbindKey("fire", "down", onPlayerUsePower)
		unbindKey("vehicle_fire", "down", onPlayerUsePower)
	end
	
	setElementData(localPlayer, "coremarkers_powerType", false)
	if isElement(bgPicture) then destroyElement(bgPicture) end
	if isElement(typePicture) then destroyElement(typePicture) end
	if isElement(_typePicture) then destroyElement(_typePicture) end
	if isTimer(givePowerTimer) then killTimer(givePowerTimer) end
end
addEvent('removePower', true)
addEventHandler('removePower', root, removePower)



function onPlayerUsePower(key, keyState, powerType)
	if getElementData(localPlayer, "coremarkers_powerType") == false then return end
	
	local theVehicle = getPedOccupiedVehicle(localPlayer)
	local x, y, z = getElementPosition(theVehicle)
	local _, _, rz = getElementRotation(theVehicle)
	local _, minY, minZ, _, _, _ = getElementBoundingBox(theVehicle)
	

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
	
	removePower()
end





addEventHandler( "onClientRender",  root,
	function()		
		if getElementData(localPlayer, "coremarkers_powerType") == "rocket" and not isTimer(delayTimer) then
				DrawLaser()
		end
		
		if isElement(getPedOccupiedVehicle(localPlayer)) then
			local s1, _, _, _ = getVehicleWheelStates(getPedOccupiedVehicle(localPlayer))
			if getElementData(localPlayer, "coremarkers_isPlayerRektBySpikes") and s1 ~= 0 then
				local timeLeft = getTimerDetails(spikesTimer)
				dxDrawImage(860*sWidth/1920, 890*sHeight/1080, 200*sHeight/1080, 200*sHeight/1080, "pics/wheel.png", 0, 0, 0, tocolor(255,255,255,255))
				dxDrawRectangle(1020*sWidth/1920, 897*sHeight/1080, 20*sWidth/1920, 174*sHeight/1080, tocolor(0, 0, 0, 160))
				dxDrawRectangle(1021*sWidth/1920, 898*sHeight/1080, 18*sWidth/1920, 172*sHeight/1080, tocolor(0, 0, 0, 180))
				dxDrawRectangle(1022*sWidth/1920, 899*sHeight/1080, 16*sWidth/1920, 170*sHeight/1080, tocolor(0, 0, 0, 200))
				dxDrawRectangle(1023*sWidth/1920, 900*sHeight/1080, 14*sWidth/1920, 168*sHeight/1080, tocolor(0, 255, 0, 200))
				dxDrawRectangle(1023*sWidth/1920, 900*sHeight/1080, 14*sWidth/1920, timeLeft/10000*168*sHeight/1080, tocolor(30, 30, 30, 200))
			end
		end
		
		if getElementData(localPlayer, "coremarkers_isPlayerSlowedDown") then
				dxDrawImage(0, 0, sWidth, sHeight, "pics/effect.png", 0, 0, 0, tocolor(255,255,255,50), true)
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


addEvent("slowDownPlayer", true)
addEventHandler("slowDownPlayer", root, 
function (magnetSlowDownTime)

	if isTimer(slowDownTimer) then
		killTimer(slowDownTimer)
	end
	
	setGameSpeed(0.7)
	setElementData(localPlayer, "coremarkers_isPlayerSlowedDown", true)
	slowDownTimer = setTimer(function() setGameSpeed(tonumber(1.0)) setElementData(localPlayer, "coremarkers_isPlayerSlowedDown", false, true) end, magnetSlowDownTime, 1)
	
end
)


addEvent('createExplosionEffect', true)
addEventHandler('createExplosionEffect', root, 
function (x, y, z)
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
)


addEvent("spikesTimerFunction", true)
addEventHandler("spikesTimerFunction", root, 
function ()
	if isTimer(spikesTimer) then
		killTimer(spikesTimer)
	end
	
	spikesTimer = setTimer(function() 
		setElementData(localPlayer, "coremarkers_isPlayerRektBySpikes", false, true) 
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		local s1, _, _, _ = getVehicleWheelStates(theVehicle)
		if s1 ~= 0 then
			playSoundFrontEnd(46)
			triggerServerEvent("fixVehicle", resourceRoot, localPlayer, theVehicle, false)
		end 
	end, 10000, 1)

end
)


addEvent("hideSpikesRepairHUD", true)
addEventHandler("hideSpikesRepairHUD", root, 
function ()
	if isTimer(spikesTimer) then
		killTimer(spikesTimer)
		setElementData(localPlayer, "coremarkers_isPlayerRektBySpikes", false, true)
	end
end
)