math.randomseed(getTickCount())

local powerTypes = {
{"repair"},
{"spikes"},
{"speedboost"},
{"oil"},
{"magnet"},
{"hay"},
{"rocket"},
{"barrel"}
}

addEventHandler("onClientResourceStart", resourceRoot, 
function()
setElementData(localPlayer, "power_type", nil)
setElementData(localPlayer, "player_have_power", false, true)
setElementData(localPlayer, "dxShowTextToVictim", nil, true)
setElementData(localPlayer, "dxShowTextToKiller", nil, true)
setElementData(localPlayer, "slowDown", false)
setElementData(localPlayer, "rektBySpikes", false)
engineImportTXD ( engineLoadTXD ( "oil.txd" ) , 2717 ) 
engineImportTXD ( engineLoadTXD ( "crate.txd" ) , 3798 ) 
engineSetModelLODDistance(1225, 300)
engineSetModelLODDistance(3374, 300)
engineSetModelLODDistance(2717, 300)
engineSetModelLODDistance(3798, 300)
end
)

function getRandomPower()
playSound("marker.mp3")
local randomPower = unpack(powerTypes[math.random(#powerTypes)])
--local randomPower = "spikes"
bindKeys(randomPower)
	if randomPower == "rocket" then
		setElementData(localPlayer, "laser.on", true)
	end
end
addEvent("getRandomPower", true)
addEventHandler("getRandomPower", root, getRandomPower)

function bindKeys(powerType)
bindKey("fire", "down", onPlayerUsePower, powerType)
bindKey("vehicle_fire", "down", onPlayerUsePower, powerType)
setElementData(localPlayer, "power_type", powerType)	
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

	if powerType == "suicida" then
		local vx, vy, vz = getElementVelocity(theVehicle)
		setElementVelocity(theVehicle, -vx*5, -vy*5, 0.6)
		setTimer(setVehicleTurnVelocity, 100, 1, theVehicle, 0, 0.3, 0)
		setTimer(blowVehicle, 500, 1, theVehicle, true)
	elseif powerType == "spikes" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.2, 0)
		local z = getGroundPosition(x, y, z)		
		triggerServerEvent("dropSpikes", resourceRoot, theVehicle, x, y, z, rz)
	elseif powerType == "speedboost" then
		setElementSpeed(theVehicle, "kmh", 280)
	elseif powerType == "oil" then 
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.2, 0)
		local z = getGroundPosition(x, y, z)	
		triggerServerEvent("dropOil", resourceRoot, theVehicle, x, y, z, rz)
	elseif powerType == "magnet" then
		local killerRank = tonumber(getElementData(localPlayer, 'race rank'))
		if killerRank >= 2 then
		local victimRank = killerRank-1
			gotAlivePlayer = false
			for k, player in ipairs(getElementsByType("player")) do
				if type(getElementData(player, 'race rank')) == "number" then
					if getElementData(player, 'race rank') <= victimRank and getElementData(player,"state") == "alive" and getElementData(player, 'race rank') >= 1 and not gotAlivePlayer then
						gotAlivePlayer = true
						triggerServerEvent("slowDownPlayer", resourceRoot, player, localPlayer)
						outputChatBox( "You slowing down: "..getPlayerName(player), 0, 100, 255, true)
						local victimName = getPlayerName(player)
						setElementData(localPlayer, "dxShowTextToKiller", tostring("You slowing down: "..victimName), true)
						setTimer(setElementData, 8000, 1, localPlayer, "dxShowTextToKiller", nil, true)
					end
				end
			end
		end
	elseif powerType == "hay" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-2.4, 0)
		local z = getGroundPosition(x, y, z)	
		triggerServerEvent("dropHay", resourceRoot, theVehicle, x, y, z, rz)
	elseif powerType == "rocket" then
		local x, y, z, vx, vy, vz = getPositionAndVelocityForProjectile(theVehicle, x, y, z)
		createProjectile(theVehicle, 21, x, y, z+0.45, 1, nil, 0, 0, 360 - rz, vx*15, vy*15, vz*15)
		setTimer(createProjectile, 50, 1, theVehicle, 21, x, y, z+0.45, 1, nil, 0, 0, 360 - rz, vx*15, vy*15, vz*15)
		setTimer(createProjectile, 70, 1, theVehicle, 21, x, y, z+0.45, 1, nil, 0, 0, 360 - rz, vx*15, vy*15, vz*15)
	elseif powerType == "barrel" then
		local x, y, z = getPositionFromElementOffset(theVehicle, 0, minY-0.5, 0)
		local z = getGroundPosition(x, y, z)	
		triggerServerEvent("dropBarrel", resourceRoot, theVehicle, x, y, z, rz)
	elseif powerType == "repair" then
		triggerServerEvent("fixVehicle", resourceRoot, theVehicle)
	end
end

local sWidth, sHeight = guiGetScreenSize()

addEventHandler( "onClientRender",  root,
	function()
		if getElementData(localPlayer, "power_type") ~= nil then
			dxDrawImage(902.5*sWidth/1920, 120*sHeight/1080, 115*sHeight/1080, 115*sHeight/1080, "pics/"..getElementData(localPlayer, "power_type")..".png", 0, 0, 0, tocolor(255,255,255,255), true)
		end
	end
)

addEventHandler( "onClientRender",  root,
	function()
		if getElementData(localPlayer, "power_type") == "rocket" then
				DrawLaser()
		end
	end
)

addEventHandler( "onClientRender",  root,
	function()
		if isElement(getPedOccupiedVehicle(localPlayer)) then
			local s1, _, _, _ = getVehicleWheelStates(getPedOccupiedVehicle(localPlayer))
			if getElementData(localPlayer, "rektBySpikes") and s1 ~= 0 then
				local timeLeft = getTimerDetails(spikesTimer)
				dxDrawImage(860*sWidth/1920, 890*sHeight/1080, 200*sHeight/1080, 200*sHeight/1080, "pics/wheel.png", 0, 0, 0, tocolor(255,255,255,255))
				dxDrawRectangle(1020*sWidth/1920, 897*sHeight/1080, 20*sWidth/1920, 174*sHeight/1080, tocolor(0, 0, 0, 160))
				dxDrawRectangle(1021*sWidth/1920, 898*sHeight/1080, 18*sWidth/1920, 172*sHeight/1080, tocolor(0, 0, 0, 180))
				dxDrawRectangle(1022*sWidth/1920, 899*sHeight/1080, 16*sWidth/1920, 170*sHeight/1080, tocolor(0, 0, 0, 200))
				dxDrawRectangle(1023*sWidth/1920, 900*sHeight/1080, 14*sWidth/1920, 168*sHeight/1080, tocolor(0, 255, 0, 200))
				dxDrawRectangle(1023*sWidth/1920, 900*sHeight/1080, 14*sWidth/1920, timeLeft/spikesRepairTime*168*sHeight/1080, tocolor(30, 30, 30, 200))
			end
		end
	end
)

function DrawLaser()
if isElement(getPedOccupiedVehicle(localPlayer)) then
local x, y, z = getElementPosition(getPedOccupiedVehicle(localPlayer))
local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(getPedOccupiedVehicle(localPlayer))
--local x, y, z, vx, vy, vz = getPositionAndVelocityForProjectile(getPedOccupiedVehicle(localPlayer), x, y, z)
local x2, y2, z2 = getPositionFromElementOffset(getPedOccupiedVehicle(localPlayer), 0, maxY+100, 0.45)
dxDrawLine3D(x,y,z+0.45,x2,y2,z2, tocolor(255,0,0,255), 1)
end
end

addEventHandler( "onClientRender",  root,
	function()
		if getElementData(localPlayer, "slowDown") then
				dxDrawImage(0, 0, sWidth, sHeight, "pics/effect.png", 0, 0, 0, tocolor(255,255,255,50), true)
		end
	end
)

function slowDownPlayer(player, killer)
	if isTimer(slowDownTimer) then
	killTimer(slowDownTimer)
	killTimer(slowDownTimer2)
	end
	
	outputChatBox( "Player '"..getPlayerName(killer).."#006EFF' slowing you down", 0, 100, 255, true)
	setGameSpeed(0.7)
	slowDownTimer = setTimer(setGameSpeed, 8000, 1, tonumber(1.0))
	setElementData(localPlayer, "slowDown", true)
	slowDownTimer2 = setTimer(setElementData, 8000, 1, localPlayer, "slowDown", false)
end
addEvent("slowDownPlayer", true)
addEventHandler("slowDownPlayer", root, slowDownPlayer)

function dxShowTextToVictim()
	if getElementData(localPlayer, "dxShowTextToVictim") ~= nil then
		dxDrawText(string.gsub(getElementData(localPlayer, "dxShowTextToVictim"), "#%x%x%x%x%x%x", ""), 0, 0, 1922*sWidth/1920, 582*sHeight/1080, tocolor ( 0, 0, 0, 255 ), 2*sHeight/1080, "clear", "center", "center", false, false, false, true )
		dxDrawText(getElementData(localPlayer, "dxShowTextToVictim"), 0, 0, 1920*sWidth/1920, 580*sHeight/1080, tocolor ( 0, 100, 255, 255 ), 2*sHeight/1080, "clear", "center", "center", false, false, false, true )
	end
end
addEventHandler("onClientPreRender", root, dxShowTextToVictim)

function dxShowTextToKiller()
	if getElementData(localPlayer, "dxShowTextToKiller") ~= nil then
		dxDrawText(string.gsub(getElementData(localPlayer, "dxShowTextToKiller"), "#%x%x%x%x%x%x", ""), 0, 0, 1922*sWidth/1920, 652*sHeight/1080, tocolor ( 0, 0, 0, 255 ), 2*sHeight/1080, "clear", "center", "center", false, false, false, true )
		dxDrawText(getElementData(localPlayer, "dxShowTextToKiller"), 0, 0, 1920*sWidth/1920, 650*sHeight/1080, tocolor ( 0, 100, 255, 255 ), 2*sHeight/1080, "clear", "center", "center", false, false, false, true )
	end
end
addEventHandler("onClientPreRender", root, dxShowTextToKiller)

function createExplosionEffect(x, y, z)
createExplosion(x, y, z, 10, true, -1.0, false)
end
addEvent('createExplosionEffect', true)
addEventHandler('createExplosionEffect', root, createExplosionEffect)

function spikesTimerFunction(timems)
spikesRepairTime = timems
spikesTimer = setTimer(function() setElementData(localPlayer, "rektBySpikes", false, true) setVehicleWheelStates(getPedOccupiedVehicle(localPlayer), 0, 0, 0, 0) playSoundFrontEnd(46) end, timems, 1)
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