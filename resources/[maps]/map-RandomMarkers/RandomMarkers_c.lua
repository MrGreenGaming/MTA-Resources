------------------------------------------
------------------------------------------
----------Script By KaliBwoy--------------
------------------------------------------
------------------------------------------


function define ()
player = localPlayer
playerveh = getPedOccupiedVehicle(player)
jumpheight = 0.3
tec9usagetime = 7000 -- Usage time allowed for tec9 (in MS)--
superramspeed = 150 -- speed of the superram (in km/h)--
returntopositiontime = 400 -- ms before superRam player retunrs to original position--
setElementData (player, "isItemPickedUp", "no", true)
setElementData (localPlayer, "isArrowbehindCar", "no")
setElementData (localPlayer, "isBarrelbehindCar", "no")
setElementData (localPlayer, "isHaybalebehindCar", "no")
setElementData (localPlayer, "isSpikeStripbehindCar", "no")
end
addEventHandler("onClientResourceStart", resourceRoot, define)

-- Makes the icons --
screenWidth,screenHeight = guiGetScreenSize() -- get the screen size --
function rendertheicons () -- Draws the blank icon --
	blankicon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/blankicon.png", false )
		guiSetVisible(blankicon,false)
	barrelicon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/barrelicon.png", false )
		guiSetVisible(barrelicon,false)
	fullhealthicon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/fullhealthicon.png", false )
		guiSetVisible(fullhealthicon,false)
	haybaleicon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/haybaleicon.png", false )
		guiSetVisible(haybaleicon,false)
	jumpicon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/jumpicon.png", false )
		guiSetVisible(jumpicon,false)
	nosicon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/nosicon.png", false )
		guiSetVisible(nosicon,false)
	rocketicon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/rocketicon.png", false )
		guiSetVisible(rocketicon,false)
	tec9icon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9icon.png", false )
		guiSetVisible(tec9icon,false)
	tec9count10 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown10.png", false )
		guiSetVisible(tec9count10,false)
	tec9count9 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown9.png", false )
		guiSetVisible(tec9count9,false)
	tec9count8 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown8.png", false )
		guiSetVisible(tec9count8,false)
	tec9count7 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown7.png", false )
		guiSetVisible(tec9count7,false)
	tec9count6 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown6.png", false )
		guiSetVisible(tec9count6,false)
	tec9count5 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown5.png", false )
		guiSetVisible(tec9count5,false)
	tec9count4 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown4.png", false )
		guiSetVisible(tec9count4,false)
	tec9count3 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown3.png", false )
		guiSetVisible(tec9count3,false)
	tec9count2 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown2.png", false )
		guiSetVisible(tec9count2,false)
	tec9count1 = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/tec9countdown1.png", false )
		guiSetVisible(tec9count1,false)
	superramicon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/superramicon.png", false )
		guiSetVisible(superramicon,false)
	spikestripicon = guiCreateStaticImage (screenWidth/2 - 50, 50, 100, 100, "/files/spikestripicon.png", false )
		guiSetVisible(spikestripicon,false)
end
addEventHandler ("onClientResourceStart", root, rendertheicons)


function updateElementBoundingBox() -- Updates elementBoundingBox and updates "objects behind cars" (barrel, haybale etc)
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	if playerveh then
	minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(playerveh)
	if getElementData(localPlayer,"isBarrelbehindCar") == "yes" then
		setElementAttachedOffsets(barrelbehindcar, 0, miny - 1.5, minz + 0.2, 0, 0, 90 ) elseif

		getElementData(localPlayer,"isHaybalebehindCar") == "yes" then
		setElementAttachedOffsets(haybalebehindcar, 0, miny - 1.5, minz + 0.6, 0, 0, 90 ) elseif

		getElementData(localPlayer,"isArrowbehindCar") == "yes" then
		setElementAttachedOffsets(superramarrowbehindcarfront, 0, maxy +1, minz + 0.2, 180, 90, -90 )
		setElementAttachedOffsets(superramarrowbehindcarback, 0, miny -1, minz + 0.2, 180, 90, 90 )

end
end
end
setTimer(updateElementBoundingBox,250,0)


function checkforblankicon()
	if guiGetVisible(blankicon) == true then
		setTimer(fadeoutblankicon, 50, 1)
	end
end


function fadeoutblankicon()
	guiSetAlpha(blankicon,1)
	setTimer(guiSetAlpha, 50, 1, blankicon, 0.90)
	setTimer(guiSetAlpha, 100, 1, blankicon, 0.80)
	setTimer(guiSetAlpha, 150, 1, blankicon, 0.70)
	setTimer(guiSetAlpha, 200, 1, blankicon, 0.60)
	setTimer(guiSetAlpha, 250, 1, blankicon, 0.50)
	setTimer(guiSetAlpha, 300, 1, blankicon, 0.40)
	setTimer(guiSetAlpha, 350, 1, blankicon, 0.30)
	setTimer(guiSetAlpha, 400, 1, blankicon, 0.20)
	setTimer(guiSetAlpha, 450, 1, blankicon, 0.10)
	setTimer(guiSetAlpha, 500, 1, blankicon, 0)
	setTimer(guiSetVisible, 500, 1, blankicon, false)
	setTimer(guiSetAlpha, 501, 1, blankicon, 1)
end

-- Weapon tables for ammo.
		resourceroot = getResourceRootElement(getThisResource())
	local noreloadweapons = {} --Weapons that doesn't reload (including the flamethrower, minigun, which doesn't have reload anim).
	noreloadweapons[16] = true
	noreloadweapons[17] = true
	noreloadweapons[18] = true
	noreloadweapons[19] = true
	noreloadweapons[25] = true
	noreloadweapons[33] = true
	noreloadweapons[34] = true
	noreloadweapons[35] = true
	noreloadweapons[36] = true
	noreloadweapons[37] = true
	noreloadweapons[38] = true
	noreloadweapons[39] = true
	noreloadweapons[41] = true
	noreloadweapons[42] = true
	noreloadweapons[43] = true

	local meleespecialweapons = {} --Weapons that don't shoot, and special weapons.
	meleespecialweapons[0] = true
	meleespecialweapons[1] = true
	meleespecialweapons[2] = true
	meleespecialweapons[3] = true
	meleespecialweapons[4] = true
	meleespecialweapons[5] = true
	meleespecialweapons[6] = true
	meleespecialweapons[7] = true
	meleespecialweapons[8] = true
	meleespecialweapons[9] = true
	meleespecialweapons[10] = true
	meleespecialweapons[11] = true
	meleespecialweapons[12] = true
	meleespecialweapons[13] = true
	meleespecialweapons[14] = true
	meleespecialweapons[15] = true
	meleespecialweapons[40] = true
	meleespecialweapons[44] = true
	meleespecialweapons[45] = true
	meleespecialweapons[46] = true



-- Handlers to trigger from server --
function SpikeStriphandler ()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (localPlayer, "isSpikeStripbehindCar", "yes")
	guiSetVisible(blankicon,false)
	guiSetVisible(spikestripicon,true)
	local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(playerveh)
	spikestripbehindcar = createObject ( 2892, 0, 0, -200 ) --Creates spikestrip behind car --

    attachElements ( spikestripbehindcar, playerveh, 0, miny -2, minz + 0.2, 0, 0, 90 )
    setElementCollisionsEnabled (spikestripbehindcar,false)
    setObjectScale (spikestripbehindcar,0.5)



	bindKey ( "mouse1", "down", onPlayerUseSpikeStrip )
	bindKey ( "lctrl", "down", onPlayerUseSpikeStrip )
end
addEvent( "onSpikeStrip", true )
addEventHandler( "onSpikeStrip", localPlayer, SpikeStriphandler )



function SuperRamhandler ()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (localPlayer, "isArrowbehindCar", "yes")
	guiSetVisible(blankicon,false)
	guiSetVisible(superramicon,true)
	local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(playerveh)
	superramarrowbehindcarfront = createObject ( 1318, 0, 0, -200 ) --Creates behind car --
	superramarrowbehindcarback = createObject ( 1318, 0, 0, -200 ) --Creates behind car --

    attachElements ( superramarrowbehindcarfront, playerveh, 0, maxy +1, minz + 0.2, 180, 90, -90 )
    attachElements ( superramarrowbehindcarback, playerveh, 0, miny -1, minz + 0.2, 180, 90, 90 )

    setElementCollisionsEnabled (superramarrowbehindcarfront,false)
    setElementCollisionsEnabled (superramarrowbehindcarback,false)

    setObjectScale (superramarrowbehindcarfront,1.5)
    setObjectScale (superramarrowbehindcarback,1.5)



	bindKey ( "mouse1", "down", onPlayerUseSuperRam )
	bindKey ( "lctrl", "down", onPlayerUseSuperRam )
end
addEvent( "onSuperRam", true )
addEventHandler( "onSuperRam", localPlayer, SuperRamhandler )




function Rockethandler ()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	guiSetVisible(blankicon,false)
	guiSetVisible(rocketicon,true)
	bindKey ( "mouse1", "down", onPlayerUseRocket )
	bindKey ( "lctrl", "down", onPlayerUseRocket )
end
addEvent( "onRocket", true )
addEventHandler( "onRocket", localPlayer, Rockethandler )


function NOShandler()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	guiSetVisible(blankicon,false)
	guiSetVisible(nosicon,true)
	bindKey ( "mouse1", "down", onPlayerUseNOS )   -- bind the player's LMB
	bindKey ( "lctrl", "down", onPlayerUseNOS )
end
addEvent("onNOS",true)
addEventHandler("onNOS", localPlayer, NOShandler)


function FullHealthhandler()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	guiSetVisible(blankicon,false)
	guiSetVisible(fullhealthicon,true)
	bindKey ( "mouse1", "down", onPlayerUseFullHealth )   -- bind the player's LMB
	bindKey ( "lctrl", "down", onPlayerUseFullHealth )
end
addEvent("onFullHealth",true)
addEventHandler("onFullHealth", localPlayer, FullHealthhandler)


function Jumphandler()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	guiSetVisible(blankicon,false)
	guiSetVisible(jumpicon,true)
	bindKey ( "mouse1", "down", onPlayerUseJump )   -- bind the player's LMB
	bindKey ( "lctrl", "down", onPlayerUseJump )
end
addEvent("onJump",true)
addEventHandler("onJump", localPlayer, Jumphandler)


function Barrelhandler()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (localPlayer, "isBarrelbehindCar", "yes")
	guiSetVisible(blankicon,false)
	guiSetVisible(barrelicon,true)
	bindKey ( "mouse1", "down", onPlayerUseBarrel )   -- bind the player's LMB 
	bindKey ( "lctrl", "down", onPlayerUseBarrel )
	barrelbehindcar = createObject ( 1225, 0, 0, -200 ) --Creates barrel behind car --
    attachElements ( barrelbehindcar, playerveh, 0, miny - 1.5, minz + 0.2, 0, 0, 90 )
    setElementCollisionsEnabled (barrelbehindcar,false)
    setObjectScale (barrelbehindcar,1)
    setElementAlpha (barrelbehindcar,141)
end
addEvent("onBarrel",true)
addEventHandler("onBarrel", localPlayer, Barrelhandler)


function Haybalehandler()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (localPlayer, "isHaybalebehindCar", "yes")
	guiSetVisible(blankicon,false)
	guiSetVisible(haybaleicon,true)
	bindKey ( "mouse1", "down", onPlayerUseHaybale )   -- bind the player's LMB 
	bindKey ( "lctrl", "down", onPlayerUseHaybale )
	haybalebehindcar = createObject ( 3374, 0, 0, -200 ) --Creates haybale--
    attachElements ( haybalebehindcar, playerveh, 0, miny - 1.5, minz + 0.6, 0, 0, 90 ) -- Puts haybale behind car --
    setElementCollisionsEnabled (haybalebehindcar,false)
    setObjectScale (haybalebehindcar,0.5)
	setElementAlpha (haybalebehindcar,141)
    
end
addEvent("onHaybale",true)
addEventHandler("onHaybale", localPlayer, Haybalehandler)

function Tec9handler()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	guiSetVisible(blankicon,false)
	guiSetVisible(tec9icon,true)
	bindKey ( "mouse2", "down", onPlayerUseTec9 )   -- bind the player's RMB 
	

end
addEvent("onTec9",true)
addEventHandler("onTec9", localPlayer, Tec9handler)


-- END Handlers to trigger from server --




-- If player uses item functions --

function onPlayerUseSpikeStrip()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (localPlayer, "isSpikeStripbehindCar", "no")
	setElementData (player, "isItemPickedUp", "no", true)
	guiSetVisible(blankicon,true)
	guiSetVisible(spikestripicon,false)
	spikedropx,spikedropy,spikedropz = getElementPosition(spikestripbehindcar)
	spikerotx,spikeroty,spikerotz = getElementRotation(spikestripbehindcar)
	playerveh = getPedOccupiedVehicle(player)
	--GET GROUND POSITION --
	local playerx,playery,playerz = getElementPosition(spikestripbehindcar)
	groundz = getGroundPosition(playerx,playery,playerz)
	--END GET GROUND POSITION END--
	triggerServerEvent ( "DropSpikeStripEvent", localPlayer, spikedropx, spikedropy, spikedropz, spikerotx, spikedropy, spikerotz, playerveh, groundz ) 
	destroyElement (spikestripbehindcar)
	unbindKey ( "mouse1", "down", onPlayerUseSpikeStrip ) -- Unbinds the key to this function --
	unbindKey ( "lctrl", "down", onPlayerUseSpikeStrip )
	setTimer(checkforblankicon,50,1)
end




function getElementSpeed(element,unit)
	if (unit == nil) then unit = 0 end
	if (isElement(element)) then
		local x,y,z = getElementVelocity(element)
		if (unit=="mph" or unit==1 or unit =='1') then
			return (x^2 + y^2 + z^2) ^ 0.5 * 100
		else
			return (x^2 + y^2 + z^2) ^ 0.5 * 1.8 * 100
		end
	else
		return false
	end
end
function setElementSpeed(element, unit, speed) -- only work if element is moving!
	if (unit == nil) then unit = 0 end
	if (speed == nil) then speed = 0 end
	speed = tonumber(speed)
	local acSpeed = getElementSpeed(element, unit)
	if (acSpeed~=false) then -- if true - element is valid, no need to check again
		local diff = speed/acSpeed
		local x,y,z = getElementVelocity(element)
		setElementVelocity(element,x*diff,y*diff,z*diff)
		return true
	end

	return false
end



function onPlayerUseSuperRam()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	local x,y,z = getElementPosition(playerveh)
	local rotx, roty, rotz = getElementRotation(playerveh)
	local velx, vely, velz = getElementVelocity(playerveh)
	if velx == 0 or vely == 0 then else
	setElementData (localPlayer, "isArrowbehindCar", "no")
	setElementData (player, "isItemPickedUp", "no", true)
	guiSetVisible(blankicon,true)
	guiSetVisible(superramicon,false)
    createExplosion(x, y, z + 15, 12, false, 1.4, false)
	beforeblurlevel = getBlurLevel ()
	setBlurLevel(255)
	local turnvelx, turnvely, turnvelz = getVehicleTurnVelocity(playerveh)
	setElementSpeed(playerveh,0,getElementSpeed(playerveh) + superramspeed)
	setTimer(setElementVelocity, returntopositiontime + 50, 1, playerveh, velx, vely, 0)
	setTimer(setElementPosition, returntopositiontime, 1, playerveh, x, y, z)
	setTimer(setElementRotation, returntopositiontime, 1, playerveh, rotx, roty, rotz)
	setTimer(setVehicleTurnVelocity, returntopositiontime, 1, playerveh, turnvelx, turnvely, turnvelz)
	setTimer(setBlurLevel, returntopositiontime, 1, beforeblurlevel)
	unbindKey("mouse1", "down", onPlayerUseSuperRam)
	unbindKey("lctrl", "down", onPlayerUseSuperRam)
	destroyElement(superramarrowbehindcarfront)
	destroyElement(superramarrowbehindcarback)
	superramsound = playSound ("/files/superram.mp3")
	setSoundVolume(superramsound, 0.45)
	guiSetVisible(blankicon,true)
	guiSetVisible(superramicon,false)


	setTimer(checkforblankicon,50,1)
end
end



function onPlayerUseRocket()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (player, "isItemPickedUp", "no", true)
	guiSetVisible(blankicon,true)
	guiSetVisible(rocketicon,false)

	local x,y,z = getElementPosition(playerveh)
    local rX,rY,rZ = getElementRotation(playerveh)
    local x = x+4*math.cos(math.rad(rZ+90))
    local y = y+4*math.sin(math.rad(rZ+90))
    createProjectile(playerveh, 19, x, y, z, 1.0, nil)
    unbindKey ( "mouse1", "down", onPlayerUseRocket )
    unbindKey ( "lctrl", "down", onPlayerUseRocket )
    setTimer(checkforblankicon,50,1)
end



function onPlayerUseNOS()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (player, "isItemPickedUp", "no", true)
	guiSetVisible(blankicon,true)
	guiSetVisible(nosicon,false)
	addVehicleUpgrade(playerveh,1009)
	setTimer(function() removeVehicleUpgrade(playerveh,1009) end, 15000, 1)
	unbindKey ( "mouse1", "down", onPlayerUseNOS ) -- Unbinds the key to this function --
	unbindKey ( "lctrl", "down", onPlayerUseNOS )
	playSoundFrontEnd(46)
	setTimer(checkforblankicon,50,1)
end

function onPlayerUseFullHealth()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (player, "isItemPickedUp", "no", true)
	guiSetVisible(blankicon,true)
	guiSetVisible(fullhealthicon,false)
	setElementHealth (playerveh,1000)
	setVehicleWheelStates( playerveh, 0, 0, 0, 0)
	unbindKey ( "mouse1", "down", onPlayerUseFullHealth ) -- Unbinds the key to this function --
	unbindKey ( "lctrl", "down", onPlayerUseFullHealth )
	playSoundFrontEnd(46)
	setTimer(checkforblankicon,50,1)
end

function onPlayerUseJump()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (player, "isItemPickedUp", "no", true)
	guiSetVisible(blankicon,true)
	guiSetVisible(jumpicon,false)
	    	local jumpsound = playSound ("/files/jump.mp3")
			setSoundVolume(jumpsound, 0.7)        
    		local sx,sy,sz = getElementVelocity ( playerveh )
    		setElementVelocity( playerveh ,sx, sy, sz+jumpheight )

	unbindKey ( "mouse1", "down", onPlayerUseJump ) -- Unbinds the key to this function --
	unbindKey ( "lctrl", "down", onPlayerUseJump )
	setTimer(checkforblankicon,50,1)
end

function onPlayerUseBarrel()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (localPlayer, "isBarrelbehindCar", "no")
	setElementData (player, "isItemPickedUp", "no", true)
	guiSetVisible(blankicon,true)
	guiSetVisible(barrelicon,false)
	bardropx,bardropy,bardropz = getElementPosition(barrelbehindcar)
	playerveh = getPedOccupiedVehicle(player)
	triggerServerEvent ( "DropBarrelEvent", localPlayer, bardropx, bardropy, bardropz, playerveh ) 
	destroyElement (barrelbehindcar)
	unbindKey ( "mouse1", "down", onPlayerUseBarrel ) -- Unbinds the key to this function --
	unbindKey ( "lctrl", "down", onPlayerUseBarrel )
	setTimer(checkforblankicon,50,1)
end

function onPlayerUseHaybale()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)
	setElementData (localPlayer, "isHaybalebehindCar", "no")
	setElementData (player, "isItemPickedUp", "no", true)
	guiSetVisible(blankicon,true)
	guiSetVisible(haybaleicon,false)
	haydropx,haydropy,haydropz = getElementPosition(haybalebehindcar)
	playerveh = getPedOccupiedVehicle(player)
	triggerServerEvent ( "DropHaybaleEvent", localPlayer, haydropx, haydropy, haydropz, playerveh ) 
	destroyElement (haybalebehindcar)
	unbindKey ( "mouse1", "down", onPlayerUseHaybale ) -- Unbinds the key to this function --
	unbindKey ( "lctrl", "down", onPlayerUseHaybale )
	setTimer(checkforblankicon,50,1)
end


function onPlayerUseTec9()
	local player = localPlayer
	local playerveh = getPedOccupiedVehicle(player)

	setTimer (setElementData, tec9usagetime, 1, player, "isItemPickedUp", "no", true )
	setTimer (guiSetVisible, tec9usagetime, 1, blankicon, true)

	playerwithweap = getLocalPlayer()
	-- Count Down--
	setTimer (guiSetVisible, 50, 1, tec9icon, false)
	-- count10 = setTimer (guiSetVisible, 50, 1, tec9count10, true)

	-- setTimer (guiSetVisible, 1000, 1, tec9count10, false)
	-- count9 = setTimer (guiSetVisible, 1000, 1, tec9count9, true)

	-- setTimer (guiSetVisible, 2000, 1, tec9count9, false)
	-- count8 = setTimer (guiSetVisible, 2000, 1, tec9count8, true)

	-- setTimer (guiSetVisible, 3000, 1, tec9count8, false)
	count7 = setTimer (guiSetVisible, 50, 1, tec9count7, true)

	setTimer (guiSetVisible, 1000, 1, tec9count7, false)
	count6 = setTimer (guiSetVisible, 1000, 1, tec9count6, true)

	setTimer (guiSetVisible, 2000, 1, tec9count6, false)
	count5 = setTimer (guiSetVisible, 2000, 1, tec9count5, true)

	setTimer (guiSetVisible, 3000, 1, tec9count5, false)
	count4 = setTimer (guiSetVisible, 3000, 1, tec9count4, true)

	setTimer (guiSetVisible, 4000, 1, tec9count4, false)
	count3 = setTimer (guiSetVisible, 4000, 1, tec9count3, true)

	setTimer (guiSetVisible, 5000, 1, tec9count3, false)
	count2 = setTimer (guiSetVisible, 5000, 1, tec9count2, true)

	setTimer (guiSetVisible, 6000, 1, tec9count2, false)
	count1 = setTimer (guiSetVisible, 6000, 1, tec9count1, true)

	setTimer (guiSetVisible, 7000, 1, tec9count1, false)

	setTimer(checkforblankicon,tec9usagetime,1)


	--END Count Down END--
	tec9timer = setTimer(function() triggerServerEvent ( "removeAmmo", localPlayer, playerwithweap ) end, tec9usagetime, 1)
	unbindKey ( "mouse2", "down",  onPlayerUseTec9 ) -- Unbinds the key to this function --
		toggleControl ( "vehicle_look_left",true )
		toggleControl ( "vehicle_look_right",true )
		toggleControl ( "vehicle_secondary_fire",true )
		

end


-- END If player uses item functions --

--Hide/Show GUI for dead/alive players --
function ClientHideGUIfunction() -- Also removes any pickup the player had before dying --
	if blankicon then
		guiSetVisible(blankicon,false)
		guiSetVisible(barrelicon,false)
		guiSetVisible(fullhealthicon,false)
		guiSetVisible(haybaleicon,false)
		guiSetVisible(jumpicon,false)
		guiSetVisible(nosicon,false)
		guiSetVisible(rocketicon,false)
		guiSetVisible(tec9icon,false)
		guiSetVisible(superramicon,false)
		guiSetVisible(spikestripicon,false)
		setTimer(checkforblankicon,50,1)

				-- UNBIND FUNCTION KEYS --
			unbindKey ( "mouse1", "down",  onPlayerUseHaybale ) -- Unbinds the key to this function --
			unbindKey ( "lctrl", "down",  onPlayerUseHaybale )
			unbindKey ( "mouse1", "down",  onPlayerUseBarrel ) -- Unbinds the key to this function --
			unbindKey ( "lctrl", "down",  onPlayerUseBarrel )
			unbindKey ( "mouse2", "down",  onPlayerUseTec9 ) -- Unbinds the key to this function --
			unbindKey ( "mouse1", "down",  onPlayerUseJump )
			unbindKey ( "lctrl", "down",  onPlayerUseJump )
			unbindKey("mouse1", "down",  onPlayerUseSuperRam)
			unbindKey("lctrl", "down",  onPlayerUseSuperRam)
			unbindKey ( "mouse1", "down",  onPlayerUseRocket )
			unbindKey ( "lctrl", "down",  onPlayerUseRocket )
			unbindKey ( "mouse1", "down",  onPlayerUseNOS )
			unbindKey ( "lctrl", "down",  onPlayerUseNOS )
			unbindKey ( "mouse1", "down",  onPlayerUseFullHealth )
			unbindKey ( "lctrl", "down",  onPlayerUseFullHealth )
			unbindKey ( "mouse1", "down",  onPlayerUseSpikeStrip ) -- Unbinds the key to this function --
			unbindKey ( "lctrl", "down",  onPlayerUseSpikeStrip )
			setElementData (player, "isItemPickedUp", "no", true)
		end
			-- REMOVE ATTACHED OBJECTS BEHIND CAR --
		if getElementData(localPlayer,"isSpikeStripbehindCar") == "yes" then
		destroyElement(spikestripbehindcar)
		setElementData(localPlayer,"isSpikeStripbehindCar", "no")
		 elseif

		getElementData(localPlayer,"isBarrelbehindCar") == "yes" then
		destroyElement(barrelbehindcar)
		setElementData(localPlayer,"isBarrelbehindCar", "no")
		 elseif

		getElementData(localPlayer,"isHaybalebehindCar") == "yes" then
		destroyElement(haybalebehindcar)
		setElementData(localPlayer,"isHaybalebehindCar", "no")
		 elseif

		getElementData(localPlayer,"isArrowbehindCar") == "yes" then
		destroyElement(superramarrowbehindcarfront)
		destroyElement(superramarrowbehindcarback)
		setElementData(localPlayer,"isArrowbehindCar", "no")
end

		-- END REMOVE ATTACHED OBJECTS BEHINC CAR --
		-- REMOVE TEC9 COUNTDOWN--
		if isTimer(count1) then killTimer(count1) end
		if	isTimer(count2) then killTimer(count2) end
		if	isTimer(count3) then killTimer(count3) end
		if	isTimer(count4) then killTimer(count4) end
		if	isTimer(count5) then killTimer(count5) end
		if	isTimer(count6) then killTimer(count6) end
		if	isTimer(count7) then killTimer(count7) end
		if	isTimer(count8) then killTimer(count8) end
		if	isTimer(count9) then killTimer(count9) end
		if	isTimer(count10) then killTimer(count10) end
		-- END REMOVE TEC9 COUNTDOWN END--


end
addEvent("ClientHideGUI",true)
addEventHandler("ClientHideGUI", root, ClientHideGUIfunction)

function ClientShowGUIFunction ()
	if blankicon then
		guiSetVisible(blankicon,true)
		guiSetVisible(barrelicon,false)
		guiSetVisible(fullhealthicon,false)
		guiSetVisible(haybaleicon,false)
		guiSetVisible(jumpicon,false)
		guiSetVisible(nosicon,false)
		guiSetVisible(rocketicon,false)
		guiSetVisible(tec9icon,false)
		guiSetVisible(spikestripicon,false)
		setTimer(checkforblankicon,50,1)
	end
end
addEvent("ClientShowGUI",true)
addEventHandler( "ClientShowGUI", root, ClientShowGUIFunction)


--Draw a warning when in the marker while having another pickup already --
function DrawtheWarning()
	local screenW, screenH = guiGetScreenSize()
       warningtext = dxDrawText("#ff0000Use your current pickup first!", (screenW - 541) / 2, (screenH - 44) / 2, ((screenW - 541) / 2) + 541, ( (screenH - 44) / 2) + 44, tocolor(255, 255, 255, 255), 3.00, "default-bold", "center", "top", false, false, true, true, false)


end

function useitemfirstWarning(source)
	if not isTimer(thewarningtimer) then
addEventHandler ("onClientRender", root, DrawtheWarning)


thewarningtimer = setTimer ( function() removeEventHandler("onClientRender", root, DrawtheWarning) end, 3000, 1 )
else end


end
addEvent("useitemWarning",true)
addEventHandler("useitemWarning", localPlayer, useitemfirstWarning)








