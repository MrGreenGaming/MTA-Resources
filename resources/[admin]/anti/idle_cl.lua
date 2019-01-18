afk = 0
warn = 45
maxAFK = 70
warned = false
inTime = true

spawnwarn = 3
spawnMaxAFK = 9
spawnTiming = true
spawnafk = 0

commandAFK = false

isPlayerAFK = false

function main()
	local car = getPedOccupiedVehicle(localPlayer)
	if (not spectating()) and isElement(car) and ( not isElementFrozen(car) ) and (inTime) then
		local x,y,z = getElementVelocity(car)
		local speed = math.floor((math.sqrt(x^2+y^2+z^2))*100*1.61)
		if (speed <= 20) and (speed >= 0) then
			afk = afk + 1
			if afk >= maxAFK then
				triggerServerEvent("warnPlayerIdle", localPlayer, "setAfkState")
				setPlayerSpectate(true)
				warned = nil
				isPlayerAFK = true
			elseif (afk >= warn) and commandAFK == false and not warned then		
				triggerServerEvent("warnPlayerIdle", localPlayer, "warnPlayer")
				warned = true	-- We warned the player
				isPlayerAFK = false
			end	
		else
			-- The player isn't afk anymore
			if warned ~= false then
				triggerServerEvent("warnPlayerIdle", localPlayer, "removeWarn")
			end	
			isPlayerAFK = false
			warned = false		-- False: The on screen warning is removed
			afk = 0
		end
	end
end
setTimer(main, 1000, 0)

function spawnAFKchecker()
	local car = getPedOccupiedVehicle(localPlayer)
	if (not spectating()) and isElement(car) and ( not isElementFrozen(car) ) and (inTime) then
		local x,y,z = getElementVelocity(car)
		local speed = math.floor((math.sqrt(x^2+y^2+z^2))*100*1.61)
			if (speed <= 20) and (speed >= 0) then
			spawnafk = spawnafk + 1
				if spawnafk >= spawnMaxAFK then
					triggerServerEvent("warnPlayerIdle", localPlayer, "setAfkState")
					setPlayerSpectate(true)
					warned = false
					isPlayerAFK = true
				elseif (spawnafk >= spawnwarn) and commandAFK == false and not warned then		
					triggerServerEvent("warnPlayerIdle", localPlayer, "warnPlayer")
					warned = true	-- We warned the player
					isPlayerAFK = false
				end	
			else
			-- The player isn't afk anymore
				if warned ~= false then
					triggerServerEvent("warnPlayerIdle", localPlayer, "removeWarn")
				end	
			warned = false		-- False: The on screen warning is removed
			spawnafk = 0
			isPlayerAFK = false
		end
	end
end



function detectInput(button,pressOrRelease)
	if pressOrRelease and button ~= "lalt" and button ~= "tab" and button ~= "escape" then
		if warned and not isPlayerAFK then 
			triggerServerEvent("warnPlayerIdle", localPlayer, "removeWarn")
			warned = false
			afk  = 0
			spawnafk = 0
		end
	end
end
addEventHandler("onClientKey", root, detectInput)

function removePlayerIdle()
	
		triggerServerEvent("warnPlayerIdle", localPlayer, "removeWarn")
		warned = false
		afk  = 0
		spawnafk = 0
		commandAFK = false

end
bindKey("b","down",removePlayerIdle)
bindKey("accelerate","down",removePlayerIdle)
bindKey("brake_reverse","down",removePlayerIdle)


addEvent("usedAFKcommand", true)
addEventHandler("usedAFKcommand", resourceRoot, function() commandAFK = true end)

function onMapRunning(bool)
	inTime = bool
end
addEvent("onMapRunning", true)
addEventHandler("onMapRunning", root, onMapRunning)

-- Is the player spectating
function spectating()
	return getElementData(localPlayer, "kKey") == "spectating"
	-- (getElementData(localPlayer, "kKey") == "spectating") or (getElementData(localPlayer, "state") ~= "alive")
end


function setPlayerSpectate(bln)
	local cTar = getCameraTarget()
	local pVeh = getPedOccupiedVehicle( localPlayer )
	if bln then
		if cTar == pVeh then -- If player is not spectating
			executeCommandHandler("spectate") -- sets player to spectate mode
		end
	elseif not bln then
		if cTar ~= pVeh then -- If player is spectating
			executeCommandHandler("spectate") -- remove spectate mode
		end
	end
end
addEvent("triggerPlayerSpectate", true)
addEventHandler("triggerPlayerSpectate", resourceRoot, setPlayerSpectate)


addEvent("setAFKTimeforGamemode",true)
function onSpawnAntiAfk(bln) -- Stricter anti afk for dd, sh and ctf --
	if bln then -- Cut off time for one respawn gamemodes --
		spawnTiming = true
		setTimer(spawnAFKchecker, 1000, 9)
	end
end
addEventHandler("setAFKTimeforGamemode", resourceRoot, onSpawnAntiAfk)


