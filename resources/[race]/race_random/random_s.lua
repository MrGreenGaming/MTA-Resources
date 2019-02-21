currentVictim = false
victimSpectateKey = "c"

addEventHandler("onResourceStart",resourceRoot,function() for _,p in ipairs(getElementsByType("player")) do bindKey(p,victimSpectateKey,"down",victimSpectate) end end)
addEventHandler("onPlayerJoin",root,function() bindKey(source,victimSpectateKey,"down",victimSpectate) end)

_outputChatBox = outputChatBox
local function outputChatBox(text, who)
	if getResourceFromName"messages" and getResourceState(getResourceFromName"messages") == "running" then
		exports.messages:outputGameMessage(text, who or root, nil, 0, 255, 0)
	else
		_outputChatBox("[Random Stuff] ".. text, who or root,0,255,0)
	end
end

local function getAlivePlayers()
	local players = {}
	for _, player in ipairs(getElementsByType('player')) do
		if getElementData(player, 'state') == 'alive' then
			table.insert(players, player)
		end
	end

	table.sort(players,sortFunction)
	return players
end

function sortFunction(a,b)
	return getElementData( a, "kills" ) < getElementData( b, "kills" )
end

local function getDeadPlayers()
	local players = {}
	for _, player in ipairs(getElementsByType('player')) do
		if getElementData(player, 'state') ~= 'alive' then
			table.insert(players, player)
		end
	end
	return players
end

local function isPlayerAlive(player)
	if not isElement(player) then return false end
	return getElementData(player, 'state') == 'alive'
end



local voteOutcomes = {
	{'Falling Dumper for %s', 'B', root},
	{'Give %s a shitty Sweeper', 'C', root},
	{'Hallelujah for %s', 'D', root},
	{'Darkness', 'E', root},
	{'Teleport everyone back', 'F', root},
	{'Turn everyone around', 'G', root},
	{'Increase gamespeed', 'H', root},
	{'Massive slap', 'I', root},
	{'Set low gravity for %s', 'J', root},
	{'Give %s a Tank', 'K', root},
	{'Set %s\'s speed to 200 KM/h', 'L', root},
	{'Give %s a shitty ForkLift', 'ForkLiftEvent', root},
	{'Send %s to Heaven', 'N', root},
	{'Let %s sleep with the Fish', 'O', root},
	{'Make %s invisible', 'P', root},
	{'Disable %s\'s brakes', 'Z', root},
	{'Missiles %s', 'Q', root},
	{'Double Damage', 'doubleDamage', root},
	{'Remove Pickups', 'removePickupsEvent', root},
	{'Sudden Death for %s', 'M', root},
	{'Ravebreak!!', 'RavebreakEvent', root},
	{'Send nuke %s', 'Firenuke', root},
	{'Personalizado mode', 'lowfps', root},
	{'Falling Rocks on %s', 'fallingRocksEvent', root},
	{'Weather', 'weatherEvent', root},
	{'Blocker mode for %s', 'blockerEvent', root},
	{'Give %s a Hunter', 'onRandomHunter', root},
}
local pollDidStart

local function removeHEXFromString(str)
	return str:gsub("#%x%x%x%x%x%x", "")
end

local function getPlayerStrippedName(player)
	if not isElement(player) then error('getPlayerStrippedName error', 2) end
	return removeHEXFromString(getPlayerName(player))
end

function table.copy(tab, recursive)
    local ret = {}
    for key, value in pairs(tab) do
        if (type(value) == "table") and recursive then ret[key] = table.copy(value)
        else ret[key] = value end
    end
    return ret
end


local function poll(a, va)
	local _alivePlayers = getAlivePlayers()
	local alivePlayers = {}
	for i,player in ipairs(_alivePlayers) do -- Add players without kills to alivePlayers
		local kills = getElementData(player,"kills")
		if tonumber(kills) and tonumber(kills) == 0 then
			table.insert(alivePlayers,player)
		end
	end

	if not a and (pollDidStart or #alivePlayers < 3) then
		return
	end
	
	triggerClientEvent("serverN", root)

	--TODO: Prevent duplicate victims
	local victimA, victimB = alivePlayers[math.random(1,#alivePlayers)], alivePlayers[math.random(1,#alivePlayers)]
	-- local victimA, victimB = va or alivePlayers[1], alivePlayers[2]

	local pollTable =
	{
		title = 'What will happen?',
		percentage = 50,
		timeout = 7,
		allowchange = true,
		visibleTo = getDeadPlayers(),
	}
	
	local randA, randB = voteOutcomes[tonumber(a)] and tonumber(a) or math.random(1,#voteOutcomes), math.random(1,#voteOutcomes)

	--Copy to prevent string.format issues
	pollTable[1] = table.copy(voteOutcomes[randA])
	pollTable[2] = table.copy(voteOutcomes[randB])

	--Get other option when same outcome
	--[[if pollTable[2][2] == pollTable[1][2] then
		if randA == #voteOutcomes then
			randA = 0
		end
		pollTable[2] = voteOutcomes[randA+1]
	end]]

	--Format nicknames
	local victimName = getPlayerStrippedName(victimA)
	pollTable[1][1] = string.format(pollTable[1][1],'random')
	local victimName = getPlayerStrippedName(victimB)
	pollTable[2][1] = string.format(pollTable[2][1],'random')

	--Add victims to outcomes
	table.insert(pollTable[1],victimA)
	table.insert(pollTable[2],victimB)
	
	pollDidStart = exports.votemanager:startPoll(pollTable)
end

local pollTimer


addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', root, function(new)
	if new == "Running" and exports.race:getRaceMode() == "Destruction derby" then
		pollTimer = setTimer(poll, 40000, 0)

	else
		stopRandom()
	end
end)

function stopRandom() 
	if isTimer(pollTimer) then
		killTimer(pollTimer)
	end

	if pollDidStart then
		exports.votemanager:stopPoll()
		pollDidStart = nil
	end
end
addEvent('onPostFinish')
addEventHandler('onPostFinish', root, stopRandom)

--Double Damage
addEvent("doubleDamage", true)
function typeDoubleDamage()
	pollDidStart = nil

	outputChatBox("Everyone is taking double damage")
	for _,veh in pairs( getElementsByType( "vehicle" ) ) do
		setVehicleHandling(veh, "collisionDamageMultiplier", 2)
	end

end
addEventHandler("doubleDamage", root, typeDoubleDamage)

--Spawning Dumper
addEvent("B", true)
function typeB(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim

	local victimName = getPlayerStrippedName(victim)
	outputChatBox("Spawning a Dumper above ".. victimName .." in 3 seconds")
	outputVictimNotice(victim,victimName)

	setTimer(function()
		if not isPlayerAlive(victim) then
			poll()
			return
		end

		local x, y, z = getElementPosition(victim)
		local dumperVehicle = createVehicle(406, x, y, z + 3)
		setTimer(destroyElement, 5000, 1, dumperVehicle)
		setElementData(dumperVehicle, 'race.collideothers', 1)
	end, 3000, 1)
end
addEventHandler("B", root, typeB)

--Sweeper
addEvent( "C", true )
function typeC(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	outputChatBox(victimName .." became a sweeper, hunt him down")
	outputVictimNotice(victim,victimName)

	local vehicle = getPedOccupiedVehicle(victim)
	local vehicleModel = getElementModel(vehicle)

	local function sweeper()
		if not isPlayerAlive(victim) then
			poll()
			return
		end

		setElementModel(vehicle, 574)
		outputChatBox("You have a sweeper for 20 seconds, run!", victim)
		triggerClientEvent(victim, "playRunSound", root)
	end

	local function changeBack()
		if not isPlayerAlive(victim) then
			return
		end

		setElementModel(vehicle, vehicleModel)
	end

	setTimer(sweeper, 50, 1)
	setTimer(changeBack, 20000, 1)
end
addEventHandler("C", root, typeC)

--Hallelujah
addEvent("D", true)
function typeD(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	outputChatBox(victimName .." will be launched in the air")
	outputVictimNotice(victim,victimName)

	local vehicle = getPedOccupiedVehicle(victim)

	triggerClientEvent(victim, "playHallelujahSound", root)

	local function flyhigh()
		if not isPlayerAlive(victim) then
			poll()
			return
		end

		setElementVelocity(vehicle, 0, 0, 1)
	end
	setTimer(flyhigh, 1500, 1)
end
addEventHandler("D", root, typeD)


--Darkness
addEvent("E", true)
function typeE()
	pollDidStart = nil

	outputChatBox("It's getting dark and silent")

	triggerClientEvent("serverDarkness", root)
end
addEventHandler("E", root, typeE)


--Part of typeF
local function tp(vehicle, posx, posy, posz, rotx, roty, rotz)
	setElementPosition(vehicle, posx, posy, posz)
	setElementRotation(vehicle, rotx, roty, rotz)
	-- triggerClientEvent("serverH", root)
end

--Teleport back
addEvent("F", true)
function typeF()
	pollDidStart = nil

	local alivePlayers = getAlivePlayers()
	for _, player in ipairs(alivePlayers) do
		local vehicle = getPedOccupiedVehicle(player)
		local posx, posy, posz = getElementPosition(vehicle)
		local rotx, roty, rotz = getElementRotation(vehicle)
		--TODO: Maybe add velocity and angular velocity (omega)

		setTimer(tp, 5000, 1, vehicle, posx, posy, posz, rotx, roty, rotz)
	end
	
	outputChatBox("Teleporting back to current location in 5 seconds")
end
addEventHandler("F", root, typeF)

--Turn around
addEvent("G", true)
function typeG()
	pollDidStart = nil

	outputChatBox("Turned everyone around")

	triggerClientEvent("playerTurnAround", root)
end
addEventHandler("G", root, typeG)

--Increase gamespeed
addEvent("H", true)
function typeH()
	pollDidStart = nil

	outputChatBox("Increased gamespeed for 10 seconds")

	setTimer(setGameSpeed, 50, 1, tonumber(1.6)) --TODO: Remove this timer?
	setTimer(setGameSpeed, 10000, 1, tonumber(1.0))
end
addEventHandler("H", root, typeH)

--Massive Slap
addEvent( "I", true)
function typeI()
	pollDidStart = nil

	outputChatBox("Mu-ha-ha-ha!!!")
	triggerClientEvent("playerMassiveSlap", root)
end
addEventHandler("I", root, typeI)

--Floating
addEvent("J", true)
function typeJ(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	outputChatBox(victimName .." starts floating for 15 seconds")
	outputVictimNotice(victim,victimName)

	triggerClientEvent(victim, "serverGravityFloat", victim)
end
addEventHandler ( "J", root, typeJ )

--Tank!
addEvent("K", true)
function typeK(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	outputChatBox(victimName .." became a Tank")
	outputVictimNotice(victim,victimName)

	setElementModel(getPedOccupiedVehicle(victim), 432)
end
addEventHandler("K", root, typeK)

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
		outputDebugString("Not an element. Can't get speed")
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

--Speed
addEvent("L", true)
function typeL(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	currentVictim = victim	


	if not isPlayerAlive(victim) then
		poll()
		return
	end

	local vehicle = getPedOccupiedVehicle(victim)

	local function giveSpeedBoost(vehicle,retry)
		local retry = retry or 0
		if retry > 20 then return end
		local vX,vY,vZ = getElementVelocity(vehicle)
		if vX == 0 or vY == 0 then
			retry = retry + 1
			setTimer(giveSpeedBoost,500,1,vehicle,retry)
		else
			setElementSpeed(vehicle,0,200)
			outputChatBox(victimName .." is going home with 200 KM/h")
			
			outputVictimNotice(victim,victimName)
		end
	end
	giveSpeedBoost(vehicle)




end
addEventHandler ( "L", root, typeL )


--Sudden Death
addEvent("M", true)
function typeM(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	outputChatBox("It's sudden death for ".. victimName)
	outputVictimNotice(victim,victimName)

	setTimer(function()
		if not isPlayerAlive(victim) then
			poll()
			return
		end

		local vehicle = getPedOccupiedVehicle(victim)
		setElementHealth(vehicle,270)
	end, 1000, 1)
end
addEventHandler("M", root, typeM)

--??
addEvent("N", true)
function typeN(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	outputChatBox(victimName .." found the stairwell to heaven")
	outputVictimNotice(victim,victimName)

	triggerClientEvent(victim, "serverGravityFloatStairwell", victim)
end
addEventHandler("N", root, typeN)

--Sleep with the fish
addEvent ( "O", true )
function typeO(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)	
	outputChatBox(victimName .." is sleeping with the fish")
	outputVictimNotice(victim,victimName)
	
	triggerClientEvent("serverSleepWithFish", victim)
end
addEventHandler("O", root, typeO)


--Invisibility
addEvent("P", true)
function typeP(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local vehicle = getPedOccupiedVehicle(victim)
	local originalAlpha, originalAlphaV = getElementAlpha(vehicle), getElementAlpha(victim)

	setElementAlpha(vehicle,0)
	setElementAlpha(victim,0)
	setPlayerNametagShowing(victim, false)
	
	local victimName = getPlayerStrippedName(victim)	
	outputChatBox(victimName .." is invisible for 15 seconds")
	
	local function changeBack()
		if not isPlayerAlive(victim) then
			return
		end

		setElementAlpha(vehicle, originalAlpha)
		setElementAlpha(victim, originalAlphaV)
		setPlayerNametagShowing(victim, true)
	end

	setTimer(changeBack, 15000, 1)
end
addEventHandler("P", root, typeP)


--No Brakes
addEvent("Z", true)
function typeZ(victim)
		pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)	
	outputChatBox(victimName .."'s brakes malfunctioned!")
	outputVictimNotice(victim,victimName)
	triggerClientEvent(victim, "serverNoBrakes", root)
end
addEventHandler("Z", root, typeZ)

--Missiles
addEvent("Q", true)
function typeQ(victim)
		pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	local Amount = math.random(2,4)
	outputChatBox("There are "..tostring(Amount).." missiles coming "..victimName.."'s way!")
	outputVictimNotice(victim,victimName)
	triggerClientEvent(victim, "serverNuke", root, Amount)
end
addEventHandler("Q", root, typeQ)




--Remove pickups
addEvent("removePickupsEvent", true)
function removePickups()
	pollDidStart = nil


	triggerClientEvent( getRootElement(  ), "clientRemovePickups", getRootElement(  ) )

end
addEventHandler("removePickupsEvent", root, removePickups)

--Forklift
addEvent( "ForkLiftEvent", true )
function s_Forklift(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	outputChatBox(victimName .." became a forklift, hunt him down")
	outputVictimNotice(victim,victimName)

	local vehicle = getPedOccupiedVehicle(victim)
	local vehicleModel = getElementModel(vehicle)

	local function forklift()
		if not isPlayerAlive(victim) then
			poll()
			return
		end

		setElementModel(vehicle, 530)
		outputChatBox("You have a forklift for 20 seconds, run!", victim)
		triggerClientEvent(victim, "playRunSound", root)
	end

	local function changeBack()
		if not isPlayerAlive(victim) then
			return
		end

		setElementModel(vehicle, vehicleModel)
	end

	setTimer(forklift, 50, 1)
	setTimer(changeBack, 20000, 1)
end
addEventHandler("ForkLiftEvent", root, s_Forklift)

--AleksCore's Rave Mode
local raveDisplay = textCreateDisplay ()
local raveText = textCreateTextItem ( "ravebreak", 0.5, 0.4, 2, 0, 255, 0, 255, 2, "center", "center", 255 )
textDisplayAddText ( raveDisplay, raveText )
addEvent( "RavebreakEvent", true )

function s_Ravebreak() 
	pollDidStart = nil

	outputConsole( "Ravebreak By AleksCore!" )
	for _,plyr in pairs(getElementsByType("player")) do
		textDisplayAddObserver ( raveDisplay, plyr )
	end


	
	
	local RaveTime = 10000 -- time of the rave in MS
	local colorInterval = 50 -- How fast will the color change in MS
	
	colorTimes = 0
	local function tcolorChange()
		colorTimes = colorTimes + 1
		local r = math.random(0,255)
		local b = math.random(0,255)
		local g = math.random(0,255)
		textItemSetColor ( raveText, r, b, g, 255 )

		if colorTimes == RaveTime/colorInterval then -- If it's the last call
			for _,plyr in pairs(getElementsByType("player")) do
				textDisplayRemoveObserver( raveDisplay, plyr )
			end
		triggerClientEvent( root, "stopRaveBreak", root )
		end
	end
	setTimer(tcolorChange, colorInterval, RaveTime/colorInterval)

	triggerClientEvent(root, "onRavebreakStart", root,RaveTime)
end
addEventHandler("RavebreakEvent", root, s_Ravebreak)

--Nuke
addEvent("Firenuke")
function Firenuke(victim)
		pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	outputChatBox("Nuke launched to  "..getPlayerStrippedName(victim).."'s position!")
	outputVictimNotice(victim,getPlayerStrippedName(victim))
	--setTimer(function()
			--if isPlayerAlive(victim) then
				local x, y, z = getElementPosition( victim )
				triggerClientEvent("ClientFireN", root, x, y, z)
		-- 	end
		-- end, 1000, 1)
end
addEventHandler("Firenuke", root, Firenuke)

function lowfps()
	pollDidStart = nil
	outputChatBox ( "Low fps for everyone!" )
	triggerClientEvent ("serverLowFPS", resourceRoot)
end
addEvent ( "lowfps", true )
addEventHandler ( "lowfps", root, lowfps )



--Hunter!
addEvent("onRandomHunter", true)
function hunterHandler(victim)
	pollDidStart = nil

	if not isPlayerAlive(victim) then
		poll()
		return
	end
	currentVictim = victim
	local victimName = getPlayerStrippedName(victim)
	outputChatBox(victimName .." became a Hunter")
	outputVictimNotice(victim,victimName)

	setElementModel(getPedOccupiedVehicle(victim), 425)
end
addEventHandler("onRandomHunter", root, hunterHandler)
  
function fallingRocksHandler(victim)
	pollDidStart = nil
	-- if not isPlayerAlive(victim) then
	-- 	poll()
	-- 	return
	-- end
	currentVictim = victim
	outputChatBox("Falling rocks at  "..getPlayerStrippedName(victim).."'s position!")
	outputVictimNotice(victim,getPlayerStrippedName(victim))

	local theRocks = {}
	local distanceOffset = 20 -- maximum distance in front of player
	local rockTimer = setTimer(
		function()
			local offset = math.random(-distanceOffset,distanceOffset)
			local rockSizes = {1303,1305}

			
			local veh = getPedOccupiedVehicle(victim)
			if not (veh and isElement(veh)) then 
				return 
			end

			local speed = getElementSpeed(veh,1)
			local x, y, z = getElementPosition( veh )
			local rX,rY,rZ = getElementRotation(veh)
			local x = x+offset*math.cos(math.rad(rZ+90))
			local y = y+offset*math.sin(math.rad(rZ+90))

			local x = x+math.random(-1,1)
			local y = y+math.random(-1,1)
			local z = z+math.random(20,30)

			local vehicle = createVehicle(594,x,y,z)
			setElementAlpha(vehicle,0)
			setVehicleDamageProof(vehicle,true)

			local rock = createObject(rockSizes[math.random(1,#rockSizes)], x,y,z)
			local rX,rY,rZ = getElementPosition(rock)
			attachElements( rock, vehicle )


			table.insert(theRocks,rock)
			

			setElementVelocity( vehicle, 0, 0, -0.5)

			setTimer(
				function() -- Destroy rc car 
					detachElements(rock,vehicle)
					destroyElement(vehicle)
				end
			,100,1)
			
			
		end
	,200,math.random(25,35))

	local remaining, executes = getTimerDetails(rockTimer)
	setTimer(
		function()
			for _,rocks in ipairs(theRocks) do 
				if isElement(rocks) then 
					destroyElement(rocks)
				end 
			end 
		end
	,remaining*executes+10000,1)
				
end
addEvent ( "fallingRocksEvent", true )
addEventHandler("fallingRocksEvent",root,fallingRocksHandler)

function weather()
	pollDidStart = nil
	local weathers={
		8, --storming
		9, --cloudy and foggy
		19, --sandstorm
	}
	outputChatBox ( "Bad weather!" )
	setWeather(weathers[math.random(#weathers)])
end
addEvent ( "weatherEvent", true )
addEventHandler ( "weatherEvent", root, weather )

function blocker(victim)
	pollDidStart = nil
	local anti = getResourceFromName'anti'
	if anti then
		outputChatBox(getPlayerStrippedName(victim).." is a blocker for 10 seconds!")
		currentVictim = victim
		outputVictimNotice(victim,getPlayerStrippedName(victim))
		triggerClientEvent("onClientReceiveCollisionlessTable",root,{[victim] = true})
		setTimer(triggerClientEvent, 10000, 1, "onClientReceiveCollisionlessTable",root,{})
	end
end
addEvent ( "blockerEvent", true )
addEventHandler ( "blockerEvent", root, blocker )



--Admin Command to trigger poll--
function adminPollTrigger(plyr)
	if hasObjectPermissionTo( plyr, "function.banPlayer" ) then
		if exports.race:getRaceMode() == "Destruction derby" then
			local alivePlayers = getAlivePlayers()
			if #alivePlayers > 3 then
				poll()
				_outputChatBox("Triggered new random vote.",plyr)
			else
				_outputChatBox( "No random vote with less than 3 people alive." ,plyr )
			end
		else _outputChatBox("Gamemode is not DD",plyr) end
	end
end
addCommandHandler( "ddrandomvote", adminPollTrigger )

function adminTestTrigger(plyr, cmd, event, name)
	if hasObjectPermissionTo( plyr, "function.banPlayer" ) then
		poll(event, getPlayerFromName(name or ''))
	end
end
addCommandHandler( "ddtestvote", adminTestTrigger )

function ddshowvotes(plyr)
	if hasObjectPermissionTo( plyr, "function.banPlayer" ) then
		for i, v in ipairs(voteOutcomes) do
			outputConsole( tostring(i) .. ': ' .. tostring(v[1]), plyr )
		end
	end
end
addCommandHandler( "ddshowvotes", ddshowvotes )


-- Quick spectate victim
function outputVictimNotice(victim,victimName)
	_outputChatBox("Press "..victimSpectateKey.." to spectate "..victimName.." (random vote victim)",root,0,255,0)
end


function victimSpectate(player)
	if not currentVictim or getElementData(currentVictim, 'state') ~= 'alive' or exports.race:getRaceMode() ~= "Destruction derby" then return end
	triggerClientEvent(player,"onSpectateVictim",root,getPlayerName(currentVictim))
end


addEventHandler("onPlayerWasted",root,
	function()
		-- if exports.race:getRaceMode() == "Destruction derby" and not isKeyBound(source,victimSpectateKey,"down",victimSpectate) then
		-- 	bindKey(source,victimSpectateKey,"down",victimSpectate)
		-- end
		if source == currentVictim then
			currentVictim = false
		end
	end
)

