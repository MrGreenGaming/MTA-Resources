math.randomseed(getTickCount())

local delay = 2000
local animSpeed = 20

local speedItemTime = 12000
local flyItemTime = 7000
local minigunItemTime = 5000

local sWidth, sHeight = guiGetScreenSize()
local iconPosX = 902.5*sWidth/1920
local iconPosY = 70*sHeight/1080
local iconSize = 115*sHeight/1080
local circlePosX = iconPosX+(iconSize/2)
local circlePosY = iconPosY+(iconSize/2)
local circleSize = 170*sHeight/1080

local powerTypes
local powerTypesBackup
local lastModel

function getAllowedPowerTypes(tbl)
	powerTypes = tbl
	powerTypesBackup = table.copy(powerTypes)
end
addEvent("getAllowedPowerTypes", true)
addEventHandler("getAllowedPowerTypes", resourceRoot, getAllowedPowerTypes)


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		setElementData(localPlayer, "coremarkers_powerType", false, true)
		setElementData(localPlayer, "coremarkers_isPlayerSlowedDown", false, true)
		setElementData(localPlayer, "coremarkers_isPlayerRektBySpikes", false, true)

		engineImportTXD ( engineLoadTXD ( "oil.txd" ) , 2717 )
		engineImportTXD ( engineLoadTXD ( "crate.txd" ) , 3798 )

		engineSetModelLODDistance(1225, 100)
		engineSetModelLODDistance(3374, 300)
		engineSetModelLODDistance(2717, 300)
		engineSetModelLODDistance(3798, 300)
		engineSetModelLODDistance(13645, 300)
		triggerServerEvent("requestAllowedPowerTypes", resourceRoot)
	end
)


function getRandomPower()
	playSound("marker.mp3")

	if #powerTypes == 0 then
		powerTypes = table.copy(powerTypesBackup)
	end
	local randomNumber = math.random(#powerTypes)
	randomPower = powerTypes[randomNumber]
	table.remove(powerTypes, randomNumber)
	--Make kmz appear less often
	if randomPower == "kmz" then
		local num1 = math.random(10)
		local num2 = math.random(10)
		--outputChatBox(num1.." - "..num2)
		if num1 == num2 then
			--kmz!!!
		else
			--new item
			if #powerTypes == 0 then
				powerTypes = table.copy(powerTypesBackup)
				for i=1, #powerTypes do
					if powerTypes[i] == "kmz" then
						table.remove(powerTypes, i)
						--outputChatBox('removed kmz from new table')
					end
				end
			end
			local randomNumber = math.random(#powerTypes)
			randomPower = powerTypes[randomNumber]
			table.remove(powerTypes, randomNumber)
		end
	end
	------
	if isElement(bgPicture) then destroyElement(bgPicture) end
	if isElement(_typePicture) then destroyElement(_typePicture) end
	if isElement(typePicture) then destroyElement(typePicture) end
	bgPicture = guiCreateStaticImage(iconPosX, iconPosY, iconSize, iconSize, "pics/background.png", false)
	_typePicture = guiCreateStaticImage(iconPosX, iconPosY, iconSize, iconSize, "pics/"..randomPower..".png", false)
	guiSetAlpha(_typePicture, 0.45)

	stopRoulette = setTimer(function() end, delay-animSpeed, 1)
	changePic(1)
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
addEventHandler("getRandomPower", resourceRoot, getRandomPower)

function changePic(number)
	if not isElement(_typePicture) then return end
	if not isTimer(stopRoulette) then return end

	local timeleft = getTimerDetails(stopRoulette)
	guiStaticImageLoadImage(_typePicture, "pics/"..powerTypesBackup[number]..".png")

	if number >= 1 and number < #powerTypesBackup then
		nextNumber = number+1
	elseif number == #powerTypesBackup then
		nextNumber = 1
	end
	changePicTimer = setTimer(changePic, animSpeed*(delay/timeleft), 1, nextNumber)
end

function preShootMinigunController(button, pressed)
    if button == "joy11" or button == "joy9" then
        if pressed then
            triggerServerEvent("onClientControllerMinigunFire", root, localPlayer, nil, "down")
        else
            triggerServerEvent("onClientControllerMinigunFire", root, localPlayer, nil, "up")
        end
    end
end

function removeShootMinigunController()
    removeEventHandler("onClientKey", root, preShootMinigunController)
end
addEvent("onClientControllerMinigunFireStop", true)
addEventHandler("onClientControllerMinigunFireStop", root, removeShootMinigunController)

function givePower(powerType)
	if isElement(_typePicture) then destroyElement(_typePicture) end
	if isElement(typePicture) then destroyElement(typePicture) end
	typePicture = guiCreateStaticImage(iconPosX, iconPosY, iconSize, iconSize, "pics/"..powerType..".png", false)
	bindKey("mouse1", "down", onPlayerUsePower, powerType)
	bindKey("lctrl", "down", onPlayerUsePower, powerType)

    function onControllerUsePower(button, pressed)
        if pressed and (button == "joy11" or button == "joy9") then
            onPlayerUsePower(nil, nil, powerType)
        end
    end
    addEventHandler("onClientKey", root, onControllerUsePower)

	setElementData(localPlayer, "coremarkers_powerType", powerType, true)
	guiSetAlpha(typePicture, 1)
	guiSetAlpha(bgPicture, 1)

	local theVehicle = getPedOccupiedVehicle(localPlayer)
	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(theVehicle)
	if powerType == "rocket" then
		triggerServerEvent("createRocketLauncher", resourceRoot, maxY)
	elseif powerType == "minigun" then
        addEventHandler("onClientKey", root, preShootMinigunController)
		triggerServerEvent("preGiveMinigun", resourceRoot)
	end
end


function removePower(powerType, delay)
	unbindKey("mouse1", "down", onPlayerUsePower)
	unbindKey("lctrl", "down", onPlayerUsePower)
    if onControllerUsePower then
        removeEventHandler("onClientKey", root, onControllerUsePower)
    end
	if isElement(_typePicture) then destroyElement(_typePicture) end
	if isTimer(givePowerTimer) then killTimer(givePowerTimer) end
	if powerType == "rocket" then
		triggerServerEvent("removeRocketLauncher", resourceRoot)
	end

	if isTimer(removePowerTimer) then killTimer(removePowerTimer) end

	if delay == -1 then
		return
	end
	if delay then
		if isElement(typePicture) then guiSetAlpha(typePicture, 0.5) end
		if isElement(bgPicture) then guiSetAlpha(bgPicture, 0.5) end
	end
	removePowerTimer = setTimer(
		function()
			if isElement(bgPicture) then destroyElement(bgPicture) end
			if isElement(typePicture) then destroyElement(typePicture) end
			setElementData(localPlayer, "coremarkers_powerType", false, true)
		end
	, delay or 0, 1)
end
addEvent('removePower', true)
addEventHandler('removePower', resourceRoot, removePower)
addEvent('onClientPlayerFinish', true)
addEventHandler('onClientPlayerFinish', root, removePower)



function onPlayerUsePower(key, keyState, powerType)
	if getElementData(localPlayer, "coremarkers_powerType") == false then return end

	local theVehicle = getPedOccupiedVehicle(localPlayer)
	local x, y, z = getElementPosition(theVehicle)
	local _, _, rz = getElementRotation(theVehicle)
	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(theVehicle)


	if powerType == "spikes" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.2, 0)
		local z = getGroundPosition(x, y, z)
		triggerServerEvent("dropSpikes", resourceRoot, x, y, z, rz)
	elseif powerType == "boost" then
		local currentSpeed = getElementSpeed(theVehicle, "kmh")
		setElementSpeed(theVehicle, "kmh", currentSpeed+150)
		local blur = getBlurLevel(localPlayer)
		setBlurLevel(36)
		local blurTimer = setTimer(function() if blurTimer and isTimer(blurTimer) then killTimer(blurTimer) end setBlurLevel(blur) end, 1000, 1)
		triggerServerEvent("startSound3D", resourceRoot, "boost.mp3")
		triggerServerEvent("attachMarker", resourceRoot, nil, 1000, 0, 255, 0, 80)
	elseif powerType == "oil" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.2, 0)
		local z = getGroundPosition(x, y, z)
		triggerServerEvent("dropOil", resourceRoot, x, y, z, rz)
	elseif powerType == "magnet" then
		triggerServerEvent("doMagnet", resourceRoot)
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
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, maxY+1, 0)
		local projectile = createProjectile(theVehicle, 19, x, y, z)
		local vx, vy, vz = getElementVelocity(projectile)
		setElementVelocity(projectile, vx*15, vy*15, vz*15)
		removePower("rocket")
		return
	elseif powerType == "minigun" then
		removePower(nil, -1)
		return
	elseif powerType == "barrels" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-1.1, 0)
		local z = getGroundPosition(x, y, z)
		triggerServerEvent("dropBarrels", resourceRoot, x, y, z, rz)
	elseif powerType == "repair" then
		triggerServerEvent("fixVehicle", resourceRoot, true)
	elseif powerType == "jump" then
		triggerServerEvent("doJump", resourceRoot)
	elseif powerType == "smoke" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.2, 0)
		local z = getGroundPosition(x, y, z)
		triggerServerEvent("doSmoke", resourceRoot, x, y, z, rz)
	elseif powerType == "nitro" then
		addVehicleUpgrade(theVehicle, 1010)
		setVehicleNitroLevel(theVehicle, 1)
		triggerServerEvent("giveNitro", resourceRoot)
	elseif powerType == "speed" then
		if isTimer(speedTimer) then
			killTimer(speedTimer)
		end
		if isTimer(screenColorTimer) then
			killTimer(screenColorTimer)
		end
		--if isTimer(slowDownTimer) then
			--killTimer(slowDownTimer)
		--end
		--setElementData(localPlayer, "coremarkers_isPlayerSlowedDown", false)
		local speed = 2
		if getElementData(localPlayer, "coremarkers_isPlayerSlowedDown") == true then
			speed = 1.4
		end
		setGameSpeed(speed)
		--stop radio and pause all other music
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

		triggerServerEvent("startSound3D", resourceRoot, "speed.mp3")
		triggerServerEvent("speedMode", resourceRoot, speedItemTime)

		--//speed turn off timer
		speedTimer = setTimer(
			function()
				local speed = 1
				if getElementData(localPlayer, "coremarkers_isPlayerSlowedDown") == true then
					speed = 0.8
				end
				setGameSpeed(speed)
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
		removePower(nil, speedItemTime)
		--\\
		return
	elseif powerType == "fly" then
		outputChatBox(">#00ff00CoreMarkers: #ffffffYou can press LAlt or L3/LSB button to cancel Fly", 255, 255, 255, true)
		vehicleModel = getElementModel(theVehicle)
		local nitro = getVehicleUpgradeOnSlot(theVehicle, 8)
		local nitroCount
		local nitroLevel
		if nitro == 1010 then
			nitroCount = getVehicleNitroCount(theVehicle)
			nitroLevel = getVehicleNitroLevel(theVehicle)
		elseif nitro == 0 then
			nitro = false
		end
		local x, y, z = getElementVelocity(theVehicle)
		setElementVelocity(theVehicle, x, y, z+0.2)
		local speed = getElementSpeed(theVehicle, "kmh")
		setElementSpeed(theVehicle, "kmh", speed+100)
		setElementModel(theVehicle, 411)
		triggerServerEvent("startSound3D", resourceRoot, "fly.mp3")
		triggerServerEvent("flyMode", resourceRoot, flyItemTime)

		--stop radio and pause all other music
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

		if isTimer(flyTimer) then killTimer(flyTimer) end
		setWorldSpecialPropertyEnabled("aircars", true)
		removePower(nil, flyItemTime)
		--//
		local function stopFlying()
			unbindKey("lalt", "down", stopFlying)
			if isTimer(flyTimer) then killTimer(flyTimer) end
			if isTimer(gravityTimer) then killTimer(gravityTimer) end
			removePower()
			--stopFly()
			stopSound(sounds[theVehicle])
			for sound,volume in pairs(tRestoreAllSounds) do
				if isElement(sound) and getElementType(sound) == "sound" and tonumber(volume) then
					setSoundVolume(sound, volume)
				end
			end
			setRadioChannel(radioChannel)

			if isElement(theVehicle) then
				local x, y, z = getElementPosition(theVehicle)
				local groundZ = getGroundPosition(x, y, z)
				--outputChatBox(z.." - "..groundZ)
				setWorldSpecialPropertyEnabled("aircars", false)
				if not lastModel then lastModel = vehicleModel end
				if math.abs(z-groundZ) >= 7 and getVehicleType(lastModel) ~= "Helicopter" and getVehicleType(lastModel) ~= "Plane" and getVehicleType(lastModel) ~= "Boat" then
					setElementModel(theVehicle, 539)
					gravityTimer = setTimer(
						function()
							if not isElement(theVehicle) then return end
								local x, y, z = getElementPosition(theVehicle)
								local groundZ = getGroundPosition(x, y, z)
								local z = (z+vehicleBoundingBox[lastModel][3])-1
								--outputChatBox("vehicle min z: "..z.." - groundZ: "..groundZ)
							if z <= groundZ or isVehicleOnGround(theVehicle) then
								local x, y, z = getElementVelocity(theVehicle)
								setElementVelocity(theVehicle, x, y, z+0.1)
								setElementModel(theVehicle, lastModel)
								if nitro then
									addVehicleUpgrade(theVehicle, 1010)
									setVehicleNitroCount(theVehicle, nitroCount)
									setVehicleNitroLevel(theVehicle, nitroLevel)
								end
								if isTimer(gravityTimer) then killTimer(gravityTimer) end
							end
						end
					, 50, 0)
				else
					setElementModel(theVehicle, lastModel)
				end
			end
		end
		--\\
		flyTimer = setTimer(stopFlying, flyItemTime, 1)
		bindKey("lalt", "down", stopFlying)
        function stopFlyingController(button, pressed)
            if pressed and (button == "joy11" or button == "joy9") then
                stopFlying()
                removeEventHandler("onClientKey", root, stopFlyingController)
            end
        end
        addEventHandler("onClientKey", root, stopFlyingController)

		return
	elseif powerType == "kmz" then
		triggerServerEvent("kamikazeMode", resourceRoot)
		if isTimer(kmzTimer) then killTimer(kmzTimer) end
		kmzTimer = setTimer(function () end, kmzItemTime, 1)
		removePower(nil, kmzItemTime)
		return
	end

	removePower()
end



function DrawLaser(player)
	local theVehicle = getPedOccupiedVehicle(player)
	if isElement(theVehicle) then
		local _, _, _, _, maxY, _ = getElementBoundingBox(theVehicle)
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, maxY-1, 0)
		local x2, y2, z2 = getPositionFromElementOffset(theVehicle, 0, maxY+100, 0)
		dxDrawLine3D(x,y,z,x2,y2,z2, tocolor(255,0,0,255), 1)
	end
end

addEvent("slowDownPlayer", true)
addEventHandler("slowDownPlayer", resourceRoot,
	function (magnetSlowDownTime)
		--stopSpeed()
		local speed = 0.8
		if isTimer(speedTimer) then
			speed = 1.4
		end
		if isTimer(slowDownTimer) then
			killTimer(slowDownTimer)
		end

		setGameSpeed(speed)
		setElementData(localPlayer, "coremarkers_isPlayerSlowedDown", true)
		--//
		slowDownTimer = setTimer(function()
									local speed = 1
									if isTimer(speedTimer) then
										speed = 2
									end
									setGameSpeed(speed)
									setElementData(localPlayer, "coremarkers_isPlayerSlowedDown", false, true)
								end, magnetSlowDownTime, 1)
		--\\
	end
)

local minigun = {}
local minigunPlayer = {}
local minigunTimer = {}
addEvent("giveMinigun", true)
addEventHandler("giveMinigun", resourceRoot,
	function(theVehicle)
		local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(theVehicle)
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, maxY+1, 0)
		local thePlayer = getVehicleOccupant(theVehicle)
		if isTimer(minigunTimer[thePlayer]) then killTimer(minigunTimer[thePlayer]) end

		local minigun1 = createWeapon("minigun", x, y, z)
		setWeaponAmmo(minigun1, 100)
		setWeaponProperty(minigun1, "fire_rotation", 0, -30, 0)
		setWeaponProperty(minigun1, "damage", 10)
		setWeaponFiringRate(minigun1, 60)
		attachElements(minigun1, theVehicle, maxX, maxY-1, 0, 0, 30, 90)
		minigun[minigun1] = thePlayer

		local minigun2 = createWeapon("minigun", x, y, z)
		setWeaponAmmo(minigun2, 100)
		setWeaponProperty(minigun2, "fire_rotation", 0, -30, 0)
		setWeaponProperty(minigun2, "damage", 10)
		setWeaponFiringRate(minigun2, 60)
		attachElements(minigun2, theVehicle, minX, maxY-1, 0, 0, 30, 90)
		minigun[minigun2] = thePlayer

		minigunPlayer[thePlayer] = {minigun1, minigun2}
	end
)

addEvent("startShootMinigun", true)
addEventHandler("startShootMinigun", resourceRoot,
	function(thePlayer)
		if not isTimer(minigunTimer[thePlayer]) then
			if thePlayer == localPlayer then
				removePower(nil, minigunItemTime)
			end
			minigunTimer[thePlayer] = setTimer(
				function()
					if minigunPlayer[thePlayer] then
						if isElement(minigunPlayer[thePlayer][1]) then destroyElement(minigunPlayer[thePlayer][1]) end
						if isElement(minigunPlayer[thePlayer][2]) then destroyElement(minigunPlayer[thePlayer][2]) end
						if thePlayer == localPlayer then
							triggerServerEvent("removeMinigun", resourceRoot)
						end
					end
				end
			, minigunItemTime, 1)
		end

		local minigun1 = minigunPlayer[thePlayer][1]
		local minigun2 = minigunPlayer[thePlayer][2]
		if isElement(minigun1) and isElement(minigun2) then
			setWeaponState(minigun1, "firing")
			setWeaponState(minigun2, "firing")
		end
	end
)

addEvent("stopShootMinigun", true)
addEventHandler("stopShootMinigun", resourceRoot,
	function(thePlayer)
		local minigun1 = minigunPlayer[thePlayer][1]
		local minigun2 = minigunPlayer[thePlayer][2]
		if isElement(minigun1) and isElement(minigun2) then
			setWeaponState(minigun1, "ready")
			setWeaponState(minigun2, "ready")
		end
	end
)

addEvent('createExplosionEffect', true)
addEventHandler('createExplosionEffect', resourceRoot,
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

local smoke = {}
addEvent("createSmokeEffect", true)
addEventHandler("createSmokeEffect", resourceRoot,
function (x, y, z, rz, theVehicle)
	local effect0 = createEffect("riot_smoke", x, y, z, 0, 0, rz, 300)
	local effect1 = createEffect("riot_smoke", x, y, z, 0, 0, rz, 300)
	local effect2 = createEffect("riot_smoke", x, y, z, 0, 0, rz, 300)
	local effect3 = createEffect("riot_smoke", x, y, z, 0, 0, rz, 300)
	attachEffect(effect0, theVehicle, Vector3(0, -1, -0.2))
	attachEffect(effect1, theVehicle, Vector3(0, -0.75, -0.1))
	attachEffect(effect2, theVehicle, Vector3(0, -0.5, 0))
	attachEffect(effect3, theVehicle, Vector3(0, -0.25, 0.1))
	local thePlayer = getVehicleOccupant(theVehicle)
	smoke[thePlayer] = { effect0, effect1, effect2, effect3 }
end
)

addEvent("spikesTimerFunction", true)
addEventHandler("spikesTimerFunction", resourceRoot,
function ()
	if isTimer(spikesTimer) then
		killTimer(spikesTimer)
	end

	spikesTimer = setTimer(function()
		setElementData(localPlayer, "coremarkers_isPlayerRektBySpikes", false, true)
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		local s1, _, _, _ = getVehicleWheelStates(theVehicle)
		if s1 ~= 0 then
			triggerServerEvent("fixVehicle", resourceRoot, false)
		end
	end, 10000, 1)

end
)


addEvent("hideSpikesRepairHUD", true)
addEventHandler("hideSpikesRepairHUD", resourceRoot,
function ()
	if isTimer(spikesTimer) then
		killTimer(spikesTimer)
		setElementData(localPlayer, "coremarkers_isPlayerRektBySpikes", false, true)
	end
end
)


function stopSpeed()
	local speed = 1
	if getElementData(localPlayer, "coremarkers_isPlayerSlowedDown") == true then
		speed = 0.8
	end
	setGameSpeed(speed)
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
addEventHandler("stopSpeed", resourceRoot, stopSpeed)


function stopFly()
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
	if isTimer(flyTimer) then killTimer(flyTimer) end
	setWorldSpecialPropertyEnabled("aircars", false)
end
addEvent("stopFly", true)
addEventHandler("stopFly", resourceRoot, stopFly)

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
addEventHandler("create3DSound", resourceRoot, create3DSound)

function stop3DSound(theVehicle)
	if isElement(sounds[theVehicle]) then stopSound(sounds[theVehicle]) end
end
addEvent("stop3DSound", true)
addEventHandler("stop3DSound", resourceRoot, stop3DSound)

local lasthit, lasttick

function onClientVehicleDamage( attacker, weapon, loss, x, y, z, tyre )
	if attacker == localPlayer or source ~= getPedOccupiedVehicle(localPlayer) then return end
	lasthit = attacker
	if isElement(lasthit) and getElementType(lasthit) == "weapon" and weapon == 38 then
		lasthit = minigun[lasthit]
	end
	lasttick = getTickCount()
	--outputDebugString( "onClientVehicleDamage " .. var_dump("ped", source, 'attacker', attacker, 'weapon', weapon, 'loss', loss) )
end
addEventHandler("onClientVehicleDamage", root, onClientVehicleDamage)


function onClientPlayerWasted()
	if minigunPlayer[source] then
		if isElement(minigunPlayer[source][1]) then destroyElement(minigunPlayer[source][1]) end
		if isElement(minigunPlayer[source][2]) then destroyElement(minigunPlayer[source][2]) end
		if isTimer(minigunTimer[source]) then killTimer(minigunTimer[source]) end
	end
	if smoke[source] then
		if isElement(smoke[source][1]) then destroyElement(smoke[source][1]) end
		if isElement(smoke[source][2]) then destroyElement(smoke[source][2]) end
		if isElement(smoke[source][3]) then destroyElement(smoke[source][3]) end
		if isElement(smoke[source][4]) then destroyElement(smoke[source][4]) end
	end
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

function vehicleChange(oldModel, newModel)
	if getElementType(source) == "vehicle" then
		--outputChatBox("Model ID changing from: "..oldModel.." to: ".. newModel, 0, 255, 0)
		if getVehicleOccupant(source) == localPlayer then
			if newModel ~= 539 and newModel ~= 411 then
				lastModel = newModel
			end
			if isTimer(gravityTimer) then killTimer(gravityTimer) end
		end
		local thePlayer = getVehicleOccupant(source)
		if isElement(thePlayer) and getElementData(thePlayer, "coremarkers_powerType") == "minigun" then
			local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(source)
			attachElements(minigunPlayer[thePlayer][1], source, maxX, maxY-1, 0, 0, 30, 90)
			attachElements(minigunPlayer[thePlayer][2], source, minX, maxY-1, 0, 0, 30, 90)
		end
	end
end
addEventHandler("onClientElementModelChange", root, vehicleChange)

addEventHandler("onClientRender",  root,
	function()
		for _, player in pairs(getElementsByType"player") do
			if getElementData(player, "coremarkers_powerType") == "rocket" then
				DrawLaser(player)
			end
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

		if getElementData(localPlayer, "coremarkers_powerType") == "speed" then
			if isTimer(speedTimer) then
				local timeleft = getTimerDetails(speedTimer)
				local d = speedItemTime/360
				dxDrawCircle(circlePosX, circlePosY, circleSize, circleSize, tocolor(255,255,255,185), 0, 360-(timeleft/d), 10*sHeight/1080)
			end
		end

		if getElementData(localPlayer, "coremarkers_powerType") == "fly" then
			if isTimer(flyTimer) then
				local timeleft = getTimerDetails(flyTimer)
				local d = flyItemTime/360
				dxDrawCircle(circlePosX, circlePosY, circleSize, circleSize, tocolor(255,255,255,185), 0, 360-(timeleft/d), 10*sHeight/1080)
			end
		end

		if getElementData(localPlayer, "coremarkers_powerType") == "minigun" then
			if isTimer(minigunTimer[localPlayer]) then
				local timeleft = getTimerDetails(minigunTimer[localPlayer])
				local d = minigunItemTime/360
				dxDrawCircle(circlePosX, circlePosY, circleSize, circleSize, tocolor(255,255,255,185), 0, 360-(timeleft/d), 10*sHeight/1080)
			end
		end

		if getElementData(localPlayer, "coremarkers_powerType") == "kmz" then
			if isTimer(kmzTimer) then
				local timeleft = getTimerDetails(kmzTimer)
				local d = kmzItemTime/360
				dxDrawCircle(circlePosX, circlePosY, circleSize, circleSize, tocolor(255,255,255,185), 0, 360-(timeleft/d), 10*sHeight/1080)
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

function onClientObjectDamage(loss, attacker)
	if getElementModel(source) == 1225 then
		triggerServerEvent("destroyBarrel", resourceRoot, source)
	end
end
addEventHandler("onClientObjectDamage", root, onClientObjectDamage)
