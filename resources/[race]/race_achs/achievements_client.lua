tableasd = {2,{{{{anothertable,1}}}}}
achievementList = {"Finish the map *Hell Choose Me* (100 GC)",     --done
"Finish the map *Drift Project 2* (100 GC)",     --done
"Win 3 times in a row (100 GC)",     --done
"Win 5 times in a row (100 GC)",     --done
"The only noob to die in a map (100 GC)",     --done
"No death in 3 maps (50 GC)",     --done
"No death in 5 maps (100 GC)",     --done
"The only person who hasn't died in a map (100 GC)",     --done
"Drive at 300 km/h for 10 seconds (100 GC)",     --done
"Drive at over 197 km/h for 30 seconds (50 GC)",     --done
"Finish a non-ghostmode map with GM on (50 GC)",     --done
"First noob to die in a map (50 GC)",     --done
"Finish a map as a late joiner (50 GC)",     --done
"Win a map as a late joiner (100 GC)",     --done
"Finish a map in less than 20 seconds (50 GC)",     --done
"Win a map in less than 20 seconds (100 GC)",     --done
"Finish a map without getting any damage (50 GC)",     --done
"Finish 3 maps in a row without getting any damage (100 GC)",     --done
"Finish a map yet dieing 3 times (100 GC)",     --done
"Win a map yet dieing once (100 GC)",     --done
"The only person to finish a map (100 GC)",     --done
"Finish a map yet having chatted for 30 seconds (50 GC)",     --done
"Win a map without using Nitro (100 GC)",     --done
"Get 2 first toptimes consecutively (100 GC)",     --done
"Win a map on fire (100 GC)",     --done
"Finish a map on fire (50 GC)",     --done
"Accumulate 10 wins in a gaming session (100 GC)",     --done
"Finish a race at the very last moment (50 GC)",     --done
"Play for 4 hours with no disconnecting (100 GC)",
"Finish the map *promap* (100 GC)",
"Win the map *Sprinten* against 30+ players (50 GC)"}

function _getPlayerFromName(name)
	for i,j in ipairs(getElementsByType('player')) do 
		if string.gsub ( getPlayerName(j), '#%x%x%x%x%x%x', '' ) == name then
			return j
		end	
	end
	return false	
end


function nosFired(key, state)
			local car = getPedOccupiedVehicle(getLocalPlayer())
			if car then
				local isNos = getVehicleUpgradeOnSlot(car, 8)
				if (isNos == 1010) and (checkRequired) then
					triggerServerEvent("onClientHasUsedNOS", getLocalPlayer())
					checkRequired = false
				end	
			end
end

bindKey("vehicle_fire", "both", nosFired)
bindKey("vehicle_secondary_fire", "both", nosFired)


addEvent('onNosLoad', true)
addEventHandler('onNosLoad', getLocalPlayer(),
function()
	local keys = getBoundKeys("vehicle_fire")
	local otherKeys = getBoundKeys("vehicle_secondary_fire")
	if keys and otherKeys then
		for keyName,state in pairs(keys) do 
			if (getKeyState(keyName)) and (checkRequired) then
				triggerServerEvent("onClientHasUsedNOS", getLocalPlayer())
				checkRequired = false
			end
		end
		for keyName,state in pairs(otherKeys) do 
			if (getKeyState(keyName)) and (checkRequired) then
				triggerServerEvent("onClientHasUsedNOS", getLocalPlayer())
				checkRequired = false
			end
		end
	end	
end
)



function createWindow(achievementsTable, bool)
		guiSetInputEnabled(true)
		alreadyLabel = false
		newLabel = false
		rows = {}
		topRows = {}
		showCursor(true)
		window = guiCreateWindow(0.35, 0.35, 0.3, 0.3, "Player Achievements", true)
		tabPanel = guiCreateTabPanel(0, 0.1, 1, 1, true, window)
		ownStats = guiCreateTab("My Achievements", tabPanel)
		otherStats = guiCreateTab("Other players", tabPanel)
		if (bool == "login") then
			if achievementsTable ~= false then guiSetText(ownStats, "My Achievements: "..tostring(#achievementsTable).."/"..tostring(#achievementList)) end
			achGrid = guiCreateGridList(0,0, 1, 1, true, ownStats)
			guiGridListClear(achGrid)
			achCol = guiGridListAddColumn(achGrid, "Achievements", 0.7)
			achLockCol = guiGridListAddColumn(achGrid, "Status", 0.3)
			for i,j in ipairs(achievementList) do
				isUnlocked = false
				rows[i] = guiGridListAddRow(achGrid)
				guiGridListSetItemText(achGrid, rows[i], achCol, j, false, false)
				if achievementsTable ~= false then
					for k,m in ipairs(achievementsTable) do 
						if j == m then
							guiGridListSetItemText(achGrid, rows[i], achLockCol, "Unlocked", false, false)
							guiGridListSetItemColor(achGrid, rows[i], achLockCol, 154, 205, 50, 255)
							guiGridListSetItemColor(achGrid, rows[i], achCol, 154, 205, 50, 255)
							isUnlocked = true
							break
						end		
					end
				end	
				if isUnlocked == false then
					guiGridListSetItemText(achGrid, rows[i], achLockCol, "Locked", false, false)
				end	
			end
			others = guiCreateEdit(0.1, 0.03, 0.4, 0.1, "Search player name", true, otherStats)
			bOnceUse = false
			addEventHandler('onClientGUIClick', others,
			function()
				if bOnceUse == false then
					guiSetText(others, "")
					bOnceUse = true
				end	
			end
			)
			addEventHandler('onClientGUIChanged', others,
			function()
				local otherName = guiGetText(others)
				otherName = string.gsub ( otherName, '#%x%x%x%x%x%x', '' )
				if isElement(_getPlayerFromName(otherName)) then
					if isElement(lab3) then destroyElement(lab3) newLabel = false end
					triggerServerEvent('onRequestAchievementsPlayer', getLocalPlayer(), _getPlayerFromName(otherName))	
				else
					if isElement(lab4) then destroyElement(lab4) end
					if newLabel == false then
						lab3 = guiCreateLabel(0.6, 0.03, 0.9, 0.1, "No player by that name", true, otherStats)
						if isElement(otherachGrid) then destroyElement(otherachGrid) end
						newLabel = true
					end	
				end
			end
			)
		--	counter = guiCreateLabel(0.6, 0.1, 0.4, 0.1, "Achievements unlocked: "..tostring(#achievementsTable).."/"..tostring(#achievementList), true, window)
		elseif bool == "unlogin" then
			lab1 = guiCreateLabel(0.2, 0.1, 0.6, 0.1, "Please login into GreenCoins", true, ownStats)
			lab2 = guiCreateLabel(0.2, 0.3, 0.6, 0.1, "/gclogin <user> <pass>", true, ownStats)
		end	
end

addEvent("sendAchievementsData", true)
addEventHandler("sendAchievementsData", getRootElement(),
function(logged, achievements)
	--if (logged == "login") and (achievements) and (topAchievements) then
	if (logged == "login") then
		createWindow(achievements, logged)
	elseif (logged == "unlogin") then
		--outputChatBox("Please login. /login ")
		createWindow(achievements, logged)
	elseif logged == "sendOther" then
		if achievements == nil then
			if (not isElement(lab4)) and (isElement(otherStats)) then
				lab4 = guiCreateLabel(0.6, 0.03, 0.9, 0.1, "Player is not logged in.", true, otherStats)
			end	
			if isElement(otherachGrid) then destroyElement(otherachGrid) end
		else
			if isElement(otherachGrid) then destroyElement(otherachGrid) end 
			if achievements ~= false then guiSetText(otherStats, guiGetText(others)..": "..tostring(#achievements).."/"..tostring(#achievementList)) end
			otherrows = {}
			otherachGrid = guiCreateGridList(0,0.15, 1, 1, true, otherStats)
			guiGridListClear(otherachGrid)
			otherachCol = guiGridListAddColumn(otherachGrid, "Achievements", 0.7)
			otherachLockCol = guiGridListAddColumn(otherachGrid, "Status", 0.3)
			for i,j in ipairs(achievementList) do
				isUnlocked = false
				otherrows[i] = guiGridListAddRow(otherachGrid)
				guiGridListSetItemText(otherachGrid, otherrows[i], otherachCol, j, false, false)
				if achievements ~= false then	
					for k,m in ipairs(achievements) do 
						if j == m then
							guiGridListSetItemText(otherachGrid, otherrows[i], otherachLockCol, "Unlocked", false, false)
							guiGridListSetItemColor(otherachGrid, otherrows[i], otherachLockCol, 154, 205, 50, 255)
							guiGridListSetItemColor(otherachGrid, otherrows[i], otherachCol, 154, 205, 50, 255)
							isUnlocked = true
							break
						end		
					end
				end	
				if isUnlocked == false then
					guiGridListSetItemText(otherachGrid, otherrows[i], otherachLockCol, "Locked", false, false)
				end	
			end
		end	
	end
end
)

addEvent("sb_showAchievements")

bGuiOpen = false
function createWindowReq(key, keyState)
	if keyState ~= "down" then if keyState then return end end
	if bGuiOpen == false then
		bGuiOpen = true
		triggerServerEvent("onAchievementsBoxLoad", getLocalPlayer())
	else
		if isElement(window) then
			guiSetInputEnabled(false)
			destroyElement(window)
			bGuiOpen = false
			showCursor(false)
		end	
	end	
end

bindKey("f4", "down", createWindowReq)
addEventHandler("sb_showAchievements", root, createWindowReq)

bCheckTimer = false
secs = 0
sec = 0
bCheckOtherTimer = false

function checkSeconds()
	secs = secs + 1
	if secs == 30 then
		triggerServerEvent("onClientAchievement", getLocalPlayer(), achievementList[10])
		if isTimer(checkTimer) then killTimer(checkTimer) end
		bCheckTimer = false
		secs = 0
	end	
end

function checkOtherSeconds()
	sec = sec + 1
	if sec == 10 then
		triggerServerEvent("onClientAchievement", getLocalPlayer(), achievementList[9])
		if isTimer(checkOtherTimer) then killTimer(checkOtherTimer) end
		bCheckOtherTimer = false
		sec = 0
	end	
end

addEventHandler('onClientRender', getRootElement(),
function()
	local car = getPedOccupiedVehicle(getLocalPlayer())
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
			triggerServerEvent("onClientChatAchievement", getLocalPlayer())
			if isTimer(chatTimer) then killTimer(chatTimer) end
			bChatTimer = false
			removeEventHandler('onClientRender', getRootElement(), checkChatbox)
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
addEventHandler('onClientMapStarting', getRootElement(),
function()
	checkRequired = true
	addEventHandler('onClientRender', getRootElement(), checkChatbox)
end
)

addEvent('onClientMapStopping', true)
addEventHandler('onClientMapStopping', getRootElement(),
function()
	removeEventHandler('onClientRender', getRootElement(), checkChatbox)
	if isTimer(chatTimer) then killTimer(chatTimer) end
	bChatTimer = false
	chatsec = 0
end
)

countHours = 0
timeCounter = setTimer(function()
	countHours = countHours + 1
	if countHours == 4 then  	--if countHours == 4 actually, because setTimer runs after that time. so it's  +1 more
		triggerServerEvent("onClientAchievement", getLocalPlayer(), achievementList[29])
	end	
end, 3600000, 0)



