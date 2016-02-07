function nosFired(key, state)
			local car = getPedOccupiedVehicle(localPlayer)
			if car then
				local isNos = getVehicleUpgradeOnSlot(car, 8)
				if (isNos == 1010) and (checkRequired) then
					triggerServerEvent("onClientHasUsedNOS", resourceRoot)
					checkRequired = false
				end	
			end
end

bindKey("vehicle_fire", "both", nosFired)
bindKey("vehicle_secondary_fire", "both", nosFired)


addEvent('onNosLoad', true)
addEventHandler('onNosLoad', localPlayer,
function()
	local keys = getBoundKeys("vehicle_fire")
	local otherKeys = getBoundKeys("vehicle_secondary_fire")
	if keys and otherKeys then
		for keyName,state in pairs(keys) do 
			if (getKeyState(keyName)) and (checkRequired) then
				triggerServerEvent("onClientHasUsedNOS", resourceRoot)
				checkRequired = false
			end
		end
		for keyName,state in pairs(otherKeys) do 
			if (getKeyState(keyName)) and (checkRequired) then
				triggerServerEvent("onClientHasUsedNOS", resourceRoot)
				checkRequired = false
			end
		end
	end	
end
)

bCheckTimer = false
secs = 0
sec = 0
bCheckOtherTimer = false

function checkSeconds()
	secs = secs + 1
	if secs == 30 then
		triggerServerEvent("onClientAchievement", resourceRoot, 10) --"Drive at over 197 km/h for 30 seconds (50 GC)"
		if isTimer(checkTimer) then killTimer(checkTimer) end
		bCheckTimer = false
		secs = 0
	end	
end

function checkOtherSeconds()
	sec = sec + 1
	if sec == 10 then
		triggerServerEvent("onClientAchievement", resourceRoot, 9) --"Drive at 300 km/h for 10 seconds (100 GC)"
		if isTimer(checkOtherTimer) then killTimer(checkOtherTimer) end
		bCheckOtherTimer = false
		sec = 0
	end	
end

addEventHandler('onClientRender', root,
function()
	local car = getPedOccupiedVehicle(localPlayer)
	if car then
		local x,y,z = getElementVelocity(car)
		speed = math.floor(math.sqrt(x^2+y^2+z^2)*100*1.61)
		if (speed >= 197) and (bCheckTimer == false) and (getVehicleType(car) == "Automobile") then
			checkTimer = setTimer(checkSeconds, 1000, 0)
			bCheckTimer = true
		end	
		if ((bCheckTimer) and (speed < 197)) or ((bCheckTimer) and (isVehicleOnGround(car)=="false")) then
			if isTimer(checkTimer) then killTimer(checkTimer) end
			bCheckTimer = false
			secs = 0
		end	
		if (speed >= 300) and (bCheckOtherTimer == false) and (getVehicleType(car) == "Automobile") then
			checkOtherTimer = setTimer(checkOtherSeconds, 1000, 0)
			bCheckOtherTimer = true
		end
		if ((bCheckOtherTimer) and (speed < 300)) or ((bCheckOtherTimer) and (isVehicleOnGround(car)=="false")) then
			if isTimer(checkOtherTimer) then killTimer(checkOtherTimer) end
			bCheckOtherTimer = false
			sec = 0
		end
		if bCheckTimer or bCheckOtherTimer then
			if (getVehicleType(car) ~= "Automobile") then
				if isTimer(checkTimer) then killTimer(checkTimer) end
				if isTimer(checkOtherTimer) then killTimer(checkOtherTimer) end
				secs = 0
				sec = 0
				bCheckOtherTimer = true
				bCheckTimer = false
			end
		end	
	end	
end
)
chatsec = 0
function checkChatEverySecond()
	local isChat = isChatBoxInputActive()
	if isChat then 
		chatsec = chatsec + 1
		if chatsec == 30 then
			triggerServerEvent("onClientChatAchievement", resourceRoot)
			if isTimer(chatTimer) then killTimer(chatTimer) end
			bChatTimer = false
			removeEventHandler('onClientRender', root, checkChatbox)
		end	
	end	
end

function checkChatbox()
	local isChat = isChatBoxInputActive()
	if isChat and not bChatTimer then
		chatTimer = setTimer(checkChatEverySecond, 1000, 0)
		bChatTimer = true
		chatsec = 0
	end	
end

addEvent('onClientMapStarting', true)
addEventHandler('onClientMapStarting', root,
function()
	checkRequired = true
	addEventHandler('onClientRender', root, checkChatbox)
end
)

addEvent('onClientMapStopping', true)
addEventHandler('onClientMapStopping', root,
function()
	removeEventHandler('onClientRender', root, checkChatbox)
	if isTimer(chatTimer) then killTimer(chatTimer) end
	bChatTimer = false
	chatsec = 0
end
)

countHours = 0
timeCounter = setTimer(function()
	countHours = countHours + 1
	if countHours == 4 then  	--if countHours == 4 actually, because setTimer runs after that time. so it's  +1 more
		triggerServerEvent("onClientAchievement", resourceRoot, 29) --"Play for 4 hours with no disconnecting (100 GC)"
	end	
end, 3600000, 0)