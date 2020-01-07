math.randomseed(getTickCount())

local delay = 500
local animSpeed = 20
local speedItemTime = 12000

local powerTypes = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					{"magnet"},
					{"jump"},
					{"rock"},
					{"smoke"},
					{"nitro"},
					{"speed"},
					{"fly"},
					{"kmz"},
					{"minigun"},
}

local powerTypesBackup = {
					{"repair"},
					{"spikes"},
					{"boost"},
					{"oil"},
					{"hay"},
					{"barrels"},
					{"ramp"},
					{"rocket"},
					{"magnet"},
					{"jump"},
					{"rock"},
					{"smoke"},
					{"nitro"},
					{"speed"},
					{"fly"},
					{"kmz"},
					{"minigun"},
}

local driveby_blocked_vehicles = {432,601,437,431,592,553,577,488,497,548,563,512,476,447,425,519,520,460,417,469,487,513,441,464,501,465,564,538,449,537,539,570472,473,493,595,484,430,453,452,446,454,606,591,607,611,610,590,569,611,435,608,584,450,571 }

addEventHandler("onClientResourceStart", resourceRoot, 
function()
	sWidth, sHeight = guiGetScreenSize()
	
	setElementData(localPlayer, "coremarkers_powerType", false)
	setElementData(localPlayer, "coremarkers_isPlayerSlowedDown", false, true)
	setElementData(localPlayer, "coremarkers_isPlayerRektBySpikes", false, true)
	
	engineImportTXD ( engineLoadTXD ( "oil.txd" ) , 2717 ) 
	engineImportTXD ( engineLoadTXD ( "crate.txd" ) , 3798 ) 
	
	engineSetModelLODDistance(1225, 100)
	engineSetModelLODDistance(3374, 300)
	engineSetModelLODDistance(2717, 300)
	engineSetModelLODDistance(3798, 300)
	engineSetModelLODDistance(13645, 300)
end
)


function getRandomPower()
	playSound("marker.mp3")
	
	if #powerTypes == 0 then
		powerTypes = table.copy(powerTypesBackup)
	end
	local randomNumber = math.random(#powerTypes)
	randomPower = unpack(powerTypes[randomNumber])
	table.remove(powerTypes, randomNumber)
	
	if isElement(bgPicture) then destroyElement(bgPicture) end
	if isElement(_typePicture) then destroyElement(_typePicture) end
	bgPicture = guiCreateStaticImage(902.5*sWidth/1920, 120*sHeight/1080, 115*sHeight/1080, 115*sHeight/1080, "pics/background.png", false)
	_typePicture = guiCreateStaticImage(902.5*sWidth/1920, 120*sHeight/1080, 115*sHeight/1080, 115*sHeight/1080, "pics/"..randomPower..".png", false)
	guiSetAlpha(_typePicture, 0.45)
	
	stopRoulette = setTimer(function() end, delay-animSpeed, 1)
	changePic(math.random(1,15))
	givePowerTimer = setTimer(
		function(randomPower) 
			if isTimer(changePicTimer) then
				killTimer(changePicTimer)
			end
			givePower(randomPower) 
		end
	, delay, 1, randomPower)
end
addEvent("getRandomPower", true)
addEventHandler("getRandomPower", root, getRandomPower)

function changePic(s)
	if not isElement(_typePicture) then return end
	
	if not isTimer(stopRoulette) then return end
	
		timeleft = getTimerDetails(stopRoulette) 
		if s == 1 then
			guiStaticImageLoadImage(_typePicture, "pics/repair.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 2)
		elseif s == 2 then
			guiStaticImageLoadImage(_typePicture, "pics/spikes.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 3)
		elseif s == 3 then
			guiStaticImageLoadImage(_typePicture, "pics/boost.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 4)
		elseif s == 4 then
			guiStaticImageLoadImage(_typePicture, "pics/oil.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 5)
		elseif s == 5 then
			guiStaticImageLoadImage(_typePicture, "pics/hay.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 6)
		elseif s == 6 then
			guiStaticImageLoadImage(_typePicture, "pics/barrels.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 7)
		elseif s == 7 then
			guiStaticImageLoadImage(_typePicture, "pics/ramp.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 8)
		elseif s == 8 then
			guiStaticImageLoadImage(_typePicture, "pics/rocket.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 9)
		elseif s == 9 then
			guiStaticImageLoadImage(_typePicture, "pics/magnet.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 10)
		elseif s == 10 then
			guiStaticImageLoadImage(_typePicture, "pics/jump.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 11)
		elseif s == 11 then
			guiStaticImageLoadImage(_typePicture, "pics/rock.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 12)
		elseif s == 12 then
			guiStaticImageLoadImage(_typePicture, "pics/smoke.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 13)
		elseif s == 13 then
			guiStaticImageLoadImage(_typePicture, "pics/nitro.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 14)
		elseif s == 14 then
			guiStaticImageLoadImage(_typePicture, "pics/speed.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 15)
		elseif s == 15 then
			guiStaticImageLoadImage(_typePicture, "pics/fly.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 16)
		elseif s == 16 then
			guiStaticImageLoadImage(_typePicture, "pics/fly.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 17)
		elseif s == 17 then
			guiStaticImageLoadImage(_typePicture, "pics/fly.png")
			changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, 1)
		end
end

function givePower(powerType)
	destroyElement(_typePicture)

	typePicture = guiCreateStaticImage(902.5*sWidth/1920, 120*sHeight/1080, 115*sHeight/1080, 115*sHeight/1080, "pics/"..powerType..".png", false)
	
	bindKey("mouse1", "down", onPlayerUsePower, powerType)
	bindKey("lctrl", "down", onPlayerUsePower, powerType)
	
	setElementData(localPlayer, "coremarkers_powerType", powerType)
	
	if powerType == "rocket" then 
		setElementData(localPlayer, "laser.on", true)
	end	
end



function removePower()
	setElementData(localPlayer, "coremarkers_powerType", false)
	if isElement(bgPicture) then destroyElement(bgPicture) end
	if isElement(typePicture) then destroyElement(typePicture) end
	if isElement(_typePicture) then destroyElement(_typePicture) end
	if isTimer(givePowerTimer) then killTimer(givePowerTimer) end
	unbindKey("mouse1", "down", onPlayerUsePower)
	unbindKey("lctrl", "down", onPlayerUsePower)
end
addEvent('removePower', true)
addEventHandler('removePower', root, removePower)



function onPlayerUsePower(key, keyState, powerType)
	if getElementData(localPlayer, "coremarkers_powerType") == false then return end
	
	local theVehicle = getPedOccupiedVehicle(localPlayer)
	local x, y, z = getElementPosition(theVehicle)
	local _, _, rz = getElementRotation(theVehicle)
	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(theVehicle)
	

	if powerType == "spikes" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.2, 0)
		local z = getGroundPosition(x, y, z)		
		triggerServerEvent("dropSpikes", resourceRoot, localPlayer, x, y, z, rz)
	elseif powerType == "boost" then
		local currentSpeed = getElementSpeed(theVehicle, "kmh")
		setElementSpeed(theVehicle, "kmh", currentSpeed+250)
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
	elseif powerType == "rock" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-1.5, 0)
		local z = getGroundPosition(x, y, z)	
		triggerServerEvent("dropRock", resourceRoot, x, y, z, rz)
	elseif powerType == "ramp" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-2.1, 0)
		local z = getGroundPosition(x, y, z)	
		triggerServerEvent("dropRamp", resourceRoot, x, y, z, rz)
	elseif powerType == "rocket" then
		local x, y, z, vx, vy, vz = getPositionAndVelocityForProjectile(theVehicle, x, y, z)
		createProjectile(localPlayer, 19, x, y, z+0.45, 1, nil, 0, 0, 360 - rz, vx*15, vy*15, vz*15)
	elseif powerType == "minigun" then
		local vehicleModel = getElementModel(theVehicle)
		for _, model in ipairs(driveby_blocked_vehicles) do
			if vehicleModel == model then
				sendClientMessage("This vehicle don't support drive-by shooting", 255, 0, 0, "bottom")
				removePower()
				return
			end
		end
		triggerServerEvent("giveMinigun", resourceRoot)
	elseif powerType == "barrels" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-1.1, 0)
		local z = getGroundPosition(x, y, z)
		triggerServerEvent("dropBarrels", resourceRoot, x, y, z, rz)
	elseif powerType == "repair" then
		triggerServerEvent("fixVehicle", resourceRoot, localPlayer, theVehicle, true)
	elseif powerType == "jump" then
		triggerServerEvent("doJump", resourceRoot, theVehicle)
	elseif powerType == "smoke" then 
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.2, 0)
		local z = getGroundPosition(x, y, z)	
		triggerServerEvent("doSmoke", resourceRoot, x, y, z, rz, theVehicle)
	elseif powerType == "nitro" then 
		addVehicleUpgrade(theVehicle, 1010)
		setVehicleNitroLevel(theVehicle, 1)
	elseif powerType == "speed" then
		if isTimer(speedTimer) then
			killTimer(speedTimer)
		end
		if isTimer(screenColorTimer) then
			killTimer(screenColorTimer)
		end
		if isTimer(slowDownTimer) then
			killTimer(slowDownTimer)
		end
		setElementData(localPlayer, "coremarkers_isPlayerSlowedDown", false)
		
		setGameSpeed(2.0)
		
		radioChannel = getRadioChannel()
		setRadioChannel(0)
		
		tRestoreAllSounds = {}
		for _,sound in pairs(getElementsByType("sound")) do
			if getElementData(sound, "isCoreMarkersSound") then
				--skip
			else
				tRestoreAllSounds[sound] = getSoundVolume(sound)
				setSoundVolume(sound, 0)
			end
		end

		screenColor = 2
		screenColorTimer = setTimer(function() screenColor = 1 setTimer(function() if isTimer(screenColorTimer) then screenColor = 2 end end, 200, 1) end, 400, 0)
		
		triggerServerEvent("startSound3D", resourceRoot, theVehicle, "speed.mp3")
		triggerServerEvent("speedMode", resourceRoot, theVehicle, speedItemTime)
		
		speedTimer = setTimer(
			function() 
				setGameSpeed(tonumber(1.0)) 
				for sound,volume in pairs(tRestoreAllSounds) do
					if isElement(sound) and getElementType(sound) == "sound" and tonumber(volume) then
						setSoundVolume(sound, volume)
					end
				end
				setRadioChannel(radioChannel)
				if isTimer(screenColorTimer) then 
					killTimer(screenColorTimer) 
				end
				screenColor = nil
			end
		, speedItemTime, 1)
	elseif powerType == "fly" then
		vehicleModel = getElementModel(theVehicle)
		local x, y, z = getElementVelocity(theVehicle)
		setElementVelocity(theVehicle, x, y, z+0.2)
		local speed = getElementSpeed(theVehicle, "kmh")
		setElementSpeed(theVehicle, "kmh", speed+100)
		setElementModel(theVehicle, 411)
		if isTimer(flyTimer) then killTimer(flyTimer) end
		flyTimer = setTimer(
			function() 
				if isElement(theVehicle) then
					setElementModel(theVehicle, vehicleModel)
					setWorldSpecialPropertyEnabled("aircars", false)
				end 
			end
		, 6000, 1)
		setWorldSpecialPropertyEnabled("aircars", true)
	elseif powerType == "kmz" then
		triggerServerEvent("kamikazeMode", resourceRoot)
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
				dxDrawImage(0, 0, sWidth, sHeight, "pics/effect.png", 0, 0, 0, tocolor(255,255,255,25), true)
		end
		if screenColor == 1 then
			dxDrawRectangle(0, 0, sWidth, sHeight, tocolor(255, 0, 255, 50))
		elseif screenColor == 2 then
			dxDrawRectangle(0, 0, sWidth, sHeight, tocolor(255, 125, 0, 50))
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
	stopSpeed()
	if isTimer(slowDownTimer) then
		killTimer(slowDownTimer)
	end
	
	setGameSpeed(0.8)
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

local attachedEffects = {}
function attachEffect(effect, element, pos)
	attachedEffects[effect] = { effect = effect, element = element, pos = pos }
	addEventHandler("onClientElementDestroy", effect, function() attachedEffects[effect] = nil end)
	addEventHandler("onClientElementDestroy", element, function() attachedEffects[effect] = nil end)
	return true
end

addEventHandler("onClientPreRender", root, 	
	function()
		for fx, info in pairs(attachedEffects) do
			local x, y, z = getPositionFromElementOffset(info.element, info.pos.x, info.pos.y, info.pos.z)
			setElementPosition(fx, x, y, z)
		end
	end
)

addEvent("createSmokeEffect", true)
addEventHandler("createSmokeEffect", root,
function (x, y, z, rz, theVehicle)
	local effect0 = createEffect("riot_smoke", x, y, z, 0, 0, rz, 300)
	local effect1 = createEffect("riot_smoke", x, y, z, 0, 0, rz, 300)
	local effect2 = createEffect("riot_smoke", x, y, z, 0, 0, rz, 300)
	local effect3 = createEffect("riot_smoke", x, y, z, 0, 0, rz, 300)
	attachEffect(effect0, theVehicle, Vector3(0, -1, -0.2))
	attachEffect(effect1, theVehicle, Vector3(0, -0.75, -0.1))
	attachEffect(effect2, theVehicle, Vector3(0, -0.5, 0))
	attachEffect(effect3, theVehicle, Vector3(0, -0.25, 0.1))
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


function stopSpeed()
	setGameSpeed(1)
	if tRestoreAllSounds then
		for sound,volume in pairs(tRestoreAllSounds) do
			if isElement(sound) and getElementType(sound) == "sound" and tonumber(volume) then
				setSoundVolume(sound, volume)
			end
		end
	end
	if radioChannel then
		setRadioChannel(radioChannel)
	end
	if isTimer(screenColorTimer) then killTimer(screenColorTimer) end
	if isTimer(speedTimer) then killTimer(speedTimer) end
	screenColor = nil
end
addEvent("stopSpeed", true)
addEventHandler("stopSpeed", root, stopSpeed)

addEvent("stopFly", true)
addEventHandler("stopFly", root, 
function ()
	if isTimer(flyTimer) then killTimer(flyTimer) end
	setWorldSpecialPropertyEnabled("aircars", false)
end
)

sounds = {}
soundTimer = {}
killSoundTimer = {}
function create3DSound(theVehicle, sound)
	if not isElement(theVehicle) then return end
	local x, y, z = getElementPosition(theVehicle)
	if isElement(sounds[theVehicle]) then stopSound(sounds[theVehicle]) end
	sounds[theVehicle] = playSound3D(sound, x, y, z, false)
	setElementData(sounds[theVehicle], "isCoreMarkersSound", true)
	setSoundMaxDistance(sounds[theVehicle], 200)
    local soundLength = getSoundLength(sounds[theVehicle])*1000
	
	soundTimer[theVehicle] = setTimer(
		function(theVehicle, sound)
			if not isElement(sound) or not isElement(theVehicle) then return end
			if getElementData(getVehicleOccupant(theVehicle), "state") ~= "alive" then
				if isTimer(soundTimer[theVehicle]) then
					killTimer(soundTimer[theVehicle])
					stopSound(sounds[theVehicle])
					return
				end
			end
            local x, y, z = getElementPosition(theVehicle)
            setElementPosition(sound, x, y, z)
		end
	, 50, 0, theVehicle, sounds[theVehicle])
	
	if isTimer(killSoundTimer[theVehicle]) then killTimer(killSoundTimer[theVehicle]) end
	killSoundTimer[theVehicle] = setTimer(
		function(soundTimer, theVehicle) 
			if isTimer(soundTimer) then 
				killTimer(soundTimer) 
			end 
		end
	, soundLength, 50, soundTimer[theVehicle], theVehicle)
	return sounds[theVehicle]
end
addEvent("create3DSound", true)
addEventHandler("create3DSound", root, create3DSound)


local lasthit, lasttick

function onClientVehicleDamage( attacker, weapon, loss, x, y, z, tyre )
	if attacker == localPlayer or source ~= getPedOccupiedVehicle(localPlayer) then return end
	lasthit = attacker
	lasttick = getTickCount()
	--outputDebugString( "onClientVehicleDamage " .. var_dump("ped", source, 'attacker', attacker, 'weapon', weapon, 'loss', loss) )
end
addEventHandler("onClientVehicleDamage", root, onClientVehicleDamage)


function onClientPlayerWasted()
	if source ~= localPlayer then return end
	if lasthit and isElement(lasthit) and lasttick and getTickCount() - lasttick <= 5000 then
		if getElementData(localPlayer, "kamikaze") then 
			lasthit = nil
			lasttick = nil
			return 
		end
		triggerServerEvent('Kill', localPlayer, lasthit)
		lasthit = nil
		lasttick = nil
	end
end
addEventHandler("onClientPlayerWasted", root, onClientPlayerWasted)