--Sweeper
local function playRunSound()
	local sound = playSound("files/run.wma")

end
addEvent("playRunSound", true)
addEventHandler("playRunSound", root, playRunSound)

--Launch in air/Send to Heaven
local function playHallelujahSound()
	local sound = playSound("files/hallelujah.wma")

end
addEvent("playHallelujahSound", true)
addEventHandler("playHallelujahSound", root, playHallelujahSound)

--Darkness
local function enableDarkness()
	fadeCamera(false, 3, 0, 0, 0)

	local function disableDarkness()
		fadeCamera(true, 3, 0, 0 , 0)
	end
	setTimer(disableDarkness, 6000, 1)
end
addEvent("serverDarkness", true)
addEventHandler("serverDarkness", root, enableDarkness)

--Teleport back
local function playTeleportSound()
	sound = playSound("files/tpsound.wma")

end
addEvent("playTeleportSound", true)
addEventHandler("playTeleportSound", root, playTeleportSound)

--Turn player around
local function playerTurnAround()
	if not (getPedOccupiedVehicle(localPlayer) and isElement(getPedOccupiedVehicle(localPlayer))) then
		return
	end

	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if not vehicle then
		return
	end

	local RotX, RotY, RotZ = getElementRotation(vehicle)
	setElementRotation(vehicle, RotX, RotY, RotZ+180)
end
addEvent("playerTurnAround", true)
addEventHandler("playerTurnAround", root, playerTurnAround)

--Massive Slap
local function playerMassiveSlap()
	if not (getPedOccupiedVehicle(localPlayer) and isElement(getPedOccupiedVehicle(localPlayer))) then
		return
	end

	local vehicle = getPedOccupiedVehicle(getLocalPlayer())

	setElementVelocity(vehicle, 0, 0, 0.2)
	setElementHealth(vehicle, getElementHealth(vehicle) - 100)
end
addEvent("playerMassiveSlap", true)
addEventHandler("playerMassiveSlap", root, playerMassiveSlap)

local function serverM()
	if getElementData(localPlayer,"state") ~= "alive" then
		local sound = playSound("files/votesound.wav")
	end

end
addEvent( "serverN", true )
addEventHandler( "serverN", root, serverM )


local function serverFloat()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle or not isElement(vehicle) then
		return
	end
	
    setVehicleGravity(vehicle, 0, 0, 0)
    setTimer(setVehicleGravity, 15000, 1, vehicle, 0, 0, -1)
end
addEvent( "serverGravityFloat", true )
addEventHandler( "serverGravityFloat", root, serverFloat )

local function serverFloatStairwell()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle or not isElement(vehicle) then
		return
	end

    setVehicleGravity(vehicle, 0, 0, 1)
    setTimer(setVehicleGravity,8000,1,vehicle,0,0,-1 )
end
addEvent( "serverGravityFloatStairwell", true )
addEventHandler( "serverGravityFloatStairwell", root, serverFloatStairwell )



local function serverSleepWithFish()
	local vehicle = getPedOccupiedVehicle(source)
	if not vehicle or not isElement(vehicle) then
		return
	end

    for _, object in ipairs(getElementsByType('object')) do
    	setElementCollidableWith(vehicle, object, false)
    end
end
addEvent( "serverSleepWithFish", true )
addEventHandler( "serverSleepWithFish", root, serverSleepWithFish )


function noBrakes()
	local time = {
	[1] = 10000,
	[2] = 12000,
	[3] = 14000,
	[4] = 16000,
	[5] = 20000
	} -- revert time
	local theTime = time[math.random(1,5)]
	toggleControl( "handbrake", false )
	toggleControl( "brake_reverse", false )
	exports.messages:outputGameMessage("You have no brakes for "..tostring(theTime/1000).." seconds!",2,255,0,0)

	setTimer(function()
		toggleControl( "handbrake", true )
		toggleControl( "brake_reverse", true )
		exports.messages:outputGameMessage("Your brakes returned!",2,0,255,0)
		end, theTime, 1)
end
addEvent( "serverNoBrakes", true )
addEventHandler( "serverNoBrakes", resourceRoot, noBrakes )

function Nuke(Amount)
	playRunSound()
	exports.messages:outputGameMessage("There are "..tostring(Amount).." missiles coming your way!",2.5,255,0,0)
	setTimer(function()
		local veh = getPedOccupiedVehicle( localPlayer )
		if veh then
			local px,py,pz = getElementPosition( veh )
			setTimer(function() 
				createProjectile( veh, 19, px, py, pz+100, 1,localPlayer,0,0,0,0,0,-45 )
				end, 200, 1)
			
		end
	end,1000,Amount)

end
addEvent( "serverNuke", true )
addEventHandler( "serverNuke", resourceRoot, Nuke )



addEvent("clientRemovePickups", true)
function c_removePickups()
	local pickups = exports["race"]:e_getPickups()

	for f, u in pairs(pickups) do
		setElementPosition(f, 0,0,-10000) -- Hides colshape to -10000 Z
		setElementPosition(u["object"],0,0,-10000) -- Hides pickup to -10000 Z
	end

		exports.messages:outputGameMessage("All pickups are removed!",2,255,255,255)
end

addEventHandler("clientRemovePickups", resourceRoot, c_removePickups)

addEvent("onRavebreakStart",true)
addEvent("stopRaveBreak",true)
function c_ravebreak(t)
	rb_soundVolumes = {}
	local rb_sounds = getElementsByType( "sound" )
	for _,snd in pairs(rb_sounds) do
		rb_soundVolumes[snd] = getSoundVolume( snd )
		setSoundVolume( snd, 0 )
	end

	local screenWidth, screenHeight = guiGetScreenSize()
	raveBreakBrowser = createBrowser(screenWidth, screenHeight, true, true)

	ravebreak = playSound("files/ravebreak"..tostring(math.random(1,4))..".mp3")


	shakeTimer = setTimer ( function()
		if getElementData(localPlayer,"state") == "alive" then -- If player's alive, explode under car, otherwise check for camera pos
			px,py,pz = getElementPosition(getLocalPlayer())	
			createExplosion(px, py, pz-30, 0, false, 2.5, false)
		else
			px,py,pz = getCameraMatrix()	
			createExplosion(px-30, py-30, pz-30, 0, false, 2.5, false)
		end

		end, 1000, 0 )
	colorTimer = setTimer ( function()	fadeCamera(false, 0.9, math.random(0,180), math.random(0,180), math.random(0,180) ) end, 250, 0 )
	resetTimer = setTimer ( function()	fadeCamera(true, 0.3 )	end, 320, 0 )



	
	
	
end
addEventHandler("onRavebreakStart",root,c_ravebreak)

function renderRaveBreak()
	
	local screenWidth, screenHeight = guiGetScreenSize()
	dxDrawImage(0, 0, screenWidth , screenHeight, raveBreakBrowser, 0, 0, 0, tocolor(255,255,255,180), false)
end

addEventHandler("onClientBrowserCreated", root, 
	function()

		if source ~= raveBreakBrowser then return end
		loadBrowserURL(raveBreakBrowser, "http://mta/local/ravebreak/ravebreak.html")
		
		
		addEventHandler("onClientRender", root, renderRaveBreak)
	end
)


function stopRaveBreak()
	stopSound( ravebreak )
	killTimer(shakeTimer)
	killTimer(colorTimer)
	killTimer(resetTimer)
	fadeCamera(true, 0.5 )
	
	for sound,volume in pairs(rb_soundVolumes) do
		if isElement(sound) and getElementType(sound) == "sound" and tonumber(volume) then
			setSoundVolume( sound, volume )
		end
	end
	removeEventHandler("onClientRender", root, renderRaveBreak)
	if isElement(raveBreakBrowser) then
		destroyElement(raveBreakBrowser)
	end
end
addEventHandler("stopRaveBreak",root,stopRaveBreak)

addCommandHandler("freeravebreak", function()
	c_ravebreak()
	setTimer ( stopRaveBreak, 10000, 1 )
end)


-- nuked http://community.mtasa.com/index.php?p=resources&s=details&id=71
N_loops = 0
N_cloudRotationAngle = 0  
NFlashDelay = 0
stopNFlash = false   

function FireN ( x, y, z )
	local sound = playSound3D( "files/BOMB_SIREN-BOMB_SIREN-247265934.mp3", x, y, z)
	setSoundMaxDistance(sound, 100)
	setTimer(destroyElement, 3000, 1, sound)
	NBeaconX = x --these are for the render function
	NBeaconY = y 
	NBeaconZ = z
	N_Cloud = NBeaconZ	
    setTimer ( function() setTimer ( NExplosion, 170, 35 ) end, 2700, 1 ) -- wait 2700 seconds then 35 loops @ 170ms
    setTimer ( NShot, 500, 1 )	
end
addEvent("ClientFireN",true)
addEventHandler("ClientFireN", getRootElement(), FireN)

function NShot ()
	NukeObjectA = createObject ( 16340, NBeaconX, NBeaconY, NBeaconZ + 200 )
	NukeObjectB = createObject ( 3865, NBeaconX + 0.072265, NBeaconY + 0.013731, NBeaconZ + 196.153122 )
	NukeObjectC = createObject ( 1243, NBeaconX + 0.060547, NBeaconY - 0.017578, NBeaconZ + 189.075554 )
	setElementRotation ( NukeObjectA, math.deg(3.150001), math.deg(0), math.deg(0.245437) )
	setElementRotation ( NukeObjectB, math.deg(-1.575), math.deg(0), math.deg(1.938950) )
	setElementRotation ( NukeObjectC, math.deg(0), math.deg(0), math.deg(-1.767145) )
	shotpath = NBeaconZ - 200
	moveObject ( NukeObjectA, 5000, NBeaconX, NBeaconY, shotpath, 0, 0, 259.9 ) 
	moveObject ( NukeObjectB, 5000, NBeaconX + 0.072265, NBeaconY + 0.013731, shotpath - 3.846878, 0, 0, 259.9 )
	moveObject ( NukeObjectC, 5000, NBeaconX + 0.060547, NBeaconY - 0.017578, shotpath - 10.924446, 0, 0, 259.9 )
end
  
function NExplosion ()
	N_loops = N_loops + 1	
	r = math.random(1.5, 4.5)
	angleup = math.random(0, 35999)/100
	explosionXCoord = r*math.cos(angleup) + NBeaconX
	ExplosionYCoord = r*math.sin(angleup) + NBeaconY	
	if N_loops == 1 then
		N_Cloud = NBeaconZ
		createExplosion ( explosionXCoord, ExplosionYCoord, N_Cloud, 7 )
		killXPosRadius = NBeaconX + 35
		killXNegRadius = NBeaconX - 35
		killYPosRadius = NBeaconY + 35
		killYNegRadius = NBeaconY - 35 --+/- 35 x/y
		killZPosRadius = NBeaconZ + 28-- +28
		killZNegRadius = NBeaconZ - 28-- -28
		local x, y, z = getElementPosition ( localPlayer )
		if ( x < killXPosRadius ) and ( x > killXNegRadius ) and ( y < killYPosRadius ) and ( y > killYNegRadius ) and 
		( z < killZPosRadius ) and ( z > killZNegRadius ) then
			--triggerServerEvent ( "serverKillNukedPlayer", localPlayer )
		end
	elseif N_loops == 2 then
		N_Cloud = NBeaconZ + 4
		createExplosion ( explosionXCoord, ExplosionYCoord, N_Cloud, 7 )
       	destroyElement ( NukeObjectA ) --Exploded, get rid of objects
		destroyElement ( NukeObjectB )
		destroyElement ( NukeObjectC )
	elseif N_loops > 20 then
		N_cloudRotationAngle = N_cloudRotationAngle + 22.5
		if N_explosionLimiter == false then
			N_cloudRadius = 7
			explosionXCoord = N_cloudRadius*math.cos(N_cloudRotationAngle) + NBeaconX --recalculate
			ExplosionYCoord = N_cloudRadius*math.sin(N_cloudRotationAngle) + NBeaconY --recalculate
			createExplosion ( explosionXCoord, ExplosionYCoord, N_Cloud, 7 )
			N_explosionLimiter = true
		elseif N_explosionLimiter == true then
			N_explosionLimiter = false
		end
		N_cloudRadius2 = 16
		explosionXCoord2 = N_cloudRadius2*math.cos(N_cloudRotationAngle) + NBeaconX
		ExplosionYCoord2 = N_cloudRadius2*math.sin(N_cloudRotationAngle) + NBeaconY
		createExplosion ( explosionXCoord2, ExplosionYCoord2, N_Cloud, 7 )
	else
    	N_Cloud = N_Cloud + 4
    	createExplosion ( explosionXCoord, ExplosionYCoord, N_Cloud, 7 )
    end
	
	if N_loops == 1 then
		NExplosionFlash = createMarker ( NBeaconX, NBeaconY, NBeaconZ, "corona", 0, 255, 255, 255, 255 )
		N_FlashSize = 1
		addEventHandler ( "onClientRender", root, NFlash )
	elseif N_loops == 35 then
		stopNFlash = true       
	end	
end

function NFlash () --Corona "flare". Grows after cp marker B grows a little
	if ( stopNFlash == false ) then
			if N_FlashSize > 60 then --beginning flash must grow fast, then delayed
				if NFlashDelay == 2 then
					N_FlashSize = N_FlashSize + 1
					NFlashDelay = 0
				else	
					NFlashDelay = NFlashDelay + 1									
				end  
			else
				N_FlashSize = N_FlashSize + 1			
			end                      
	else
		N_FlashSize = N_FlashSize - 1
	end	
	setMarkerSize ( NExplosionFlash, N_FlashSize )					
	if N_FlashSize == 0 then
		removeEventHandler ( "onClientRender", root, NFlash )
		destroyElement ( NExplosionFlash )
		N_loops = 0 --reset stuff
		N_cloudRotationAngle = 0 --reset stuff
		stopNFlash = false --reset stuff
		NFlashDelay = 0 --reset stuff
		--triggerServerEvent ( "serverNukeFinished", getRootElement() )
	end
end

function serverLowFPS(limit, duration)
	setTimer(setFPSLimit, 10 * 1000, 1, getFPSLimit() )
    setFPSLimit ( 30 )
end
addEvent( "serverLowFPS", true )
addEventHandler( "serverLowFPS", resourceRoot, serverLowFPS )

-- Server gave victim a hunter
function serverHunter()
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh then
		setHelicopterRotorSpeed(veh,0.2)
	end
end
addEvent("onServerVotedHunter", true)
addEventHandler("onServerVotedHunter", resourceRoot, serverHunter)

-- Quick spectate victims
addEvent("onSpectateVictim",true)
function spectateVictim(name)

	if name then
		executeCommandHandler("s",name)
	end
end
addEventHandler("onSpectateVictim",resourceRoot,spectateVictim)