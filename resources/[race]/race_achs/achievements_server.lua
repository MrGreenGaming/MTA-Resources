function nosFired(player, key, state)
	if state == "down" then
	local car = getPedOccupiedVehicle(player)
	if car then
		local isNos = getVehicleUpgradeOnSlot(car, 8)
		if isNos == 1010 then
			--nos is activated
			g_Players[player].nos = true
		end	
	end	
	end
end

addEventHandler('onResourceStart', getResourceRootElement(),
function()
	if not doesTableExist ( "gcAchievements" ) then
		executeSQLCreateTable("gcAchievements", "id TEXT, achievements TEXT")
	end
	g_Players = {}
	for i,j in ipairs(getElementsByType('player')) do 
		g_Players[j] = {}
		g_Players[j].nos = false 
		g_Players[j].mapsWon = 0
		g_Players[j].countMapsWithNoDeaths = 0
		g_Players[j].countMapsWithNoDamage = 0
		g_Players[j].hasBeenChatting = false
		g_Players[j].deathCount = 0
		g_Players[j].timer = false
		--bindKey(j, "vehicle_fire", "down", nosFired)
		--bindKey(j, "vehicle_secondary_fire", "down", nosFired)
	end	
end
)

function doesTableExist ( name )
	if type(name) ~= "string" then
		outputDebugString("doesTableExist: #1 not a string", 1)
		return false
	end
	name = safeString (name)
	local cmd = "SELECT tbl_name FROM sqlite_master WHERE tbl_name = '" .. name .. "'"
	local results = executeSQLQuery( cmd )
	return results and (#results > 0)
end

function safeString(s)
    s = string.gsub(s, '&', '&amp;')
    s = string.gsub(s, '"', '&quot;')
    s = string.gsub(s, '<', '&lt;')
    s = string.gsub(s, '>', '&gt;')
    return s
end

addEventHandler('onPlayerJoin', root,
function()
	--bindKey(source, "vehicle_fire", "down", nosFired)
	--bindKey(source, "vehicle_secondary_fire", "down", nosFired)
	g_Players[source] = {}
	g_Players[source].nos = false 
	g_Players[source].countMapsWithNoDeaths = 0
	g_Players[source].countMapsWithNoDamage = 0
	g_Players[source].hasBeenChatting = false
	g_Players[source].deathCount = 0
	g_Players[source].mapsWon = 0
	g_Players[source].timer = false
end
)

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



function bPlayerHasAchievement(player, achievement)
		local count = getPlayerCount()
		if count < 5 then return true end
		if not isElement(player) then return true end  
		local isLogged = exports.gc:isPlayerLoggedInGC(player)
		if isLogged then
			local id = exports.gc:getPlayerGreencoinsID(player)
			id = tostring(id)
			local sql = executeSQLQuery("SELECT id, achievements FROM gcAchievements WHERE id = '"..id.."'")
			if #sql == 0 then
				return false
			else 
				local achievements = sql[1].achievements
				achievements = split(achievements, string.byte(','))
				for i,j in ipairs(achievements) do 
					if j == achievement then
						return true
					end
				end
				return false	
			end	
		else
			return true 
		end
end

function _getPlayerName(player)
	return string.gsub(getPlayerName(player), "#%x%x%x%x%x%x", "")
end

function isMapTesting()
	return getResourceInfo(exports.mapmanager:getRunningGamemodeMap(), 'newupload') == "true"
end
function addPlayerAchievement(player, achievement)
	if isMapTesting() or not isElement(player) then return end
	local isLogged = exports.gc:isPlayerLoggedInGC(player)
	if isLogged then
		local id = exports.gc:getPlayerGreencoinsID(player)
		id = tostring(id)
		local sql = executeSQLQuery("SELECT id, achievements FROM gcAchievements WHERE id = '"..id.."'")
			if #sql == 0 then
				executeSQLInsert("gcAchievements", "'"..id.."', '"..achievement.."'")
			else
				local achievements = sql[1].achievements..","..achievement
				executeSQLUpdate("gcAchievements", "achievements = '"..achievements.."'", "id = '"..id.."'")
			end	
		local howMuch
		if string.find(achievement, "(50 GC)") then
				howMuch = 50
		else
				howMuch = 100
		end	
		exports.gc:addPlayerGreencoins(player, howMuch)
		outputChatBox(_getPlayerName(player).." has unlocked the achievement: "..achievement, root, 255, 0, 0)
		if getResourceFromName('irc') and getResourceState(getResourceFromName('irc')) == "running" then
			if exports.irc then
				exports.irc:outputIRC("06* ".._getPlayerName(player).." has unlocked the achievement: "..achievement)
			end
		end	
	else
		outputChatBox("Please login into GreenCoins to get rewarded for the achievement.", player, 255, 255, 255)
	end
end

addEvent('onPlayerFinish', true)
addEventHandler('onPlayerFinish', root,
function(rank, time)
	if rank == 1 then
		g_Players[source].mapsWon = g_Players[source].mapsWon + 1
		if g_Players[source].mapsWon == 10 then
			if (not bPlayerHasAchievement(source, achievementList[27])) then
					addPlayerAchievement(source, achievementList[27]) 
			end
		end	
	end	
	tableOfWinners[rank] = source
	if not mapGM then
		local wtf, test = getElementData(source, "overrideCollide.uniqueblah")
		local cps = #getElementsByType('checkpoint')
		if (wtf == 0) and (cps > 5) then
			if (not bPlayerHasAchievement(source, achievementList[11])) then
				addPlayerAchievement(source, achievementList[11]) 
			end
		end	
	end	
	if (not bPlayerHasAchievement(source, achievementList[1])) and (getMapName() == "Hell Choose Me") then
		addPlayerAchievement(source, achievementList[1])
	end
	if (not bPlayerHasAchievement(source, achievementList[2])) and (getMapName() == "Drift Project 2") then
		addPlayerAchievement(source, achievementList[2])
	end
	if (not bPlayerHasAchievement(source, achievementList[30])) and (getMapName() == "promap") then
		addPlayerAchievement(source, achievementList[30])
	end
	if (not bPlayerHasAchievement(source, achievementList[31])) and (getMapName() == "Sprinten") and (rank == 1) and (getPlayerCount() > 29) then
		addPlayerAchievement(source, achievementList[31])
	end
	if (not bPlayerHasAchievement(source, achievementList[3])) then
		if (rank == 1) and not g_Players[source].won then
			g_Players[source].wins = 1
			g_Players[source].won = true
		elseif (g_Players[source].won) and (rank == 1) then
			g_Players[source].wins = g_Players[source].wins + 1
			if g_Players[source].wins == 3 then
				addPlayerAchievement(source, achievementList[3])
			end
		else 
			g_Players[source].wins = 0
			g_Players[source].win = false
		end	
	
	elseif (not bPlayerHasAchievement(source, achievementList[4])) then
		if (rank == 1) and not g_Players[source].won then
			g_Players[source].wins = 1
			g_Players[source].won = true
		elseif (g_Players[source].won) and (rank == 1) then
			g_Players[source].wins = g_Players[source].wins + 1
			if g_Players[source].wins == 5 then
				addPlayerAchievement(source, achievementList[4])
			end
		else 
			g_Players[source].wins = 0
			g_Players[source].win = false
		end	
	end
	if (not bPlayerHasAchievement(source, achievementList[13]))	then
		local ok = true
		for i,j in ipairs(tableOfPlayers) do 
			if j == source then
				ok = false
			end
		end
		if ok then
			addPlayerAchievement(source, achievementList[13]) 	
		end	
	end
	if (not bPlayerHasAchievement(source, achievementList[14])) and ( rank == 1 ) then
		local ok = true
		for i,j in ipairs(tableOfPlayers) do 
			if j == source then
				ok = false
			end
		end
		if ok then
			addPlayerAchievement(source, achievementList[14]) 	
		end	
	end	
	if (not bPlayerHasAchievement(source, achievementList[15]))	then
		if time <= 20000 then
			addPlayerAchievement(source, achievementList[15])
		end
	end	
	if (not bPlayerHasAchievement(source, achievementList[16])) and (rank == 1)	then
		if time <= 20000 then
			addPlayerAchievement(source, achievementList[16])
		end
	end	
	if (not g_Players[source].damaged) and (not bPlayerHasAchievement(source, achievementList[17])) then
		addPlayerAchievement(source, achievementList[17])
	end	
	if (g_Players[source].countMapsWithNoDamage == 3) and (not bPlayerHasAchievement(source, achievementList[18])) then
		addPlayerAchievement(source, achievementList[18])
	end	
	if (g_Players[source].deathCount >= 3) and (not bPlayerHasAchievement(source, achievementList[19])) then
		addPlayerAchievement(source, achievementList[19])
	end	
	if (g_Players[source].deathCount >= 1) and (not bPlayerHasAchievement(source, achievementList[20])) and (rank == 1) then
		addPlayerAchievement(source, achievementList[20])
	end	
	if (g_Players[source].hasBeenChatting) and (not bPlayerHasAchievement(source, achievementList[22])) then
		addPlayerAchievement(source, achievementList[22])
	end	
	if (g_Players[source].nos == false) and (not bPlayerHasAchievement(source, achievementList[23])) and (rank == 1) and (hasNitro) and (getVehicleType(getPedOccupiedVehicle(source)) ~= "Bike") then
		addPlayerAchievement(source, achievementList[23])
	end
	if (not bPlayerHasAchievement(source, achievementList[25])) and (rank == 1) and (getElementHealth(getPedOccupiedVehicle(source)) < 250) then
		addPlayerAchievement(source, achievementList[25])
	end		
	if (not bPlayerHasAchievement(source, achievementList[26])) and (getElementHealth(getPedOccupiedVehicle(source)) < 250) then
		addPlayerAchievement(source, achievementList[26])
	end	
	if (rank == 1) then
		c = 0
		tickTimer = setTimer(function()
				c = c + 1
		end, 1000, 44)         --this needs to be adjusted in case Green server changes max Hurry time.
		g_Players[source].timer = true
	end	
	if (c >= 43) and (g_Players[source].timer == false) then  --this needs to be adjusted in case Green server changes max Hurry time.
		if (not bPlayerHasAchievement(source, achievementList[28])) then
			addPlayerAchievement(source, achievementList[28]) 
		end
	end	
end
)



function wastedFunc(ammo, killer, deathReason)
	g_Players[source].died = true  	--for noob thing
end


addEvent('onPostFinish', true)
addEventHandler('onPostFinish', root,
function()
--this is for "Be the only noob to die in a map"
--this is for "be the only person who hasn't died in a map"
	for i,j in ipairs(getElementsByType('player')) do 
		local isFinished = getElementData(j, "race.finished")
		if (g_Players[j].wins ~= 0) and (g_Players[j].win ~= false) and (isFinished == false) then
			g_Players[j].wins = 0
			g_Players[j].win = false
		end	
	end	
	count = 0
	for i,j in pairs(g_Players) do 
		for k, m in pairs(j) do 
			if (k == "died") and (m == true) then
				count = count + 1
				onlyPlayer = i
			end	
		end
	end
	if count == 1 then	
		 if (not bPlayerHasAchievement(onlyPlayer, achievementList[5])) then addPlayerAchievement(onlyPlayer, achievementList[5]) end
	end
	count = 0
	for i,j in pairs(g_Players) do 
		for k,m in pairs(j) do 
			if (k == "died") and ( m == false ) then
				count = count + 1
				onlyPlayer = i
			end
		end
	end
	if count == 1 then	
		 if (not bPlayerHasAchievement(onlyPlayer, achievementList[8])) then addPlayerAchievement(onlyPlayer, achievementList[8]) end
	end
	removeEventHandler('onPlayerWasted', root, wastedFunc)
end
)

function dieFunc()
	g_Players[source].dead = true
	g_Players[source].deathCount = g_Players[source].deathCount + 1
end

function firstNoob()
	if (not bPlayerHasAchievement(source, achievementList[12])) and (firstDead == false) then
		addPlayerAchievement(source, achievementList[12])	
	end
	firstDead = true
end

function vehicleFunc()
	local player = getVehicleController(source)
	if player and getElementType(player) == 'player' then
		g_Players[player].damaged = true
		g_Players[player].countMapsWithNoDamage = 0
	end	
end

addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', root,
function(state)
	if state == "Running" then
		tableOfPlayers = getElementsByType('player')
	end
end
)

addEventHandler('onMapStarting', root,
function(mapInfo, mapOptions, gameOptions)
	for i,j in pairs(g_Players) do 
		j.died = false
	end	
	removeEventHandler('onPlayerWasted', root, wastedFunc)
	removeEventHandler('onPlayerWasted', root, dieFunc)
	removeEventHandler('onVehicleDamage', root, vehicleFunc)
	removeEventHandler('onPlayerWasted', root, firstNoob)
	if isTimer(delayDeath) then killTimer(delayDeath) end
	delayDeath = setTimer(function() addEventHandler('onPlayerWasted', root, wastedFunc)
	addEventHandler('onPlayerWasted', root, firstNoob)
	addEventHandler('onVehicleDamage', root, vehicleFunc)
	addEventHandler('onPlayerWasted', root, dieFunc) end, 10000, 1)
	firstDead = false
	mapGM = mapOptions['ghostmode']
	hasNitro = false
	racepickups = getElementsByType('racepickup')
	if #racepickups > 0 then
		for id, pickup in ipairs(racepickups) do 
			if getElementData(pickup, "type") == "nitro" then
				hasNitro = true
				break
			end
		end
	end	
	tableOfWinners = {}
	for i,j in pairs(g_Players) do 
		j.hasBeenChatting = false
		j.deathCount = 0
		j.nos = false
		j.timer = false
		if j.damaged then
			j.damaged = false
			j.countMapsWithNoDamage = 0
		else	
		j.countMapsWithNoDamage = j.countMapsWithNoDamage + 1
		end
		if j.dead then
			j.countMapsWithNoDeaths = 0
			j.dead = false
			j.countMapsWithNoDeaths = j.countMapsWithNoDeaths + 1
		else
			j.countMapsWithNoDeaths = j.countMapsWithNoDeaths + 1
		end	
	end
end
)	

addEvent('onPostFinish', true)
addEventHandler('onPostFinish', root,
function()
	if isTimer(delayDeath) then killTimer(delayDeath) end
	if #tableOfWinners == 1 then
		if (not bPlayerHasAchievement(tableOfWinners[1], achievementList[21])) then addPlayerAchievement(tableOfWinners[1], achievementList[21]) end
	end	
	tableOfWinners = {}	
	for i,j in ipairs(getElementsByType('player')) do
		if g_Players[j].dead then
			g_Players[j].countMapsWithNoDeaths = 0
			g_Players[j].dead = false
			g_Players[j].deathCount = 0
		end	
		if g_Players[j].countMapsWithNoDeaths == 3 then
			if (not bPlayerHasAchievement(j, achievementList[6])) then
				addPlayerAchievement(j, achievementList[6]) 
			end
		elseif 	g_Players[j].countMapsWithNoDeaths == 5 then
			if (not bPlayerHasAchievement(j, achievementList[7])) then
				addPlayerAchievement(j, achievementList[7]) 
			end
		end	
	end
	removeEventHandler('onPlayerWasted', root, dieFunc)
	removeEventHandler('onVehicleDamage', root, vehicleFunc)
	removeEventHandler('onPlayerWasted', root, firstNoob)
end
)

addEvent("onClientAchievement", true)
addEventHandler("onClientAchievement", root,
function(achievement)
	if (not bPlayerHasAchievement(source, achievement)) then
		addPlayerAchievement(source, achievement) 
	end
end
)


addEvent("onClientChatAchievement", true)
addEventHandler("onClientChatAchievement", root,
function()
	g_Players[source].hasBeenChatting = true
end
)

addEvent("onClientHasUsedNOS", true)
addEventHandler("onClientHasUsedNOS", root,
function()
	g_Players[source].nos = true
end
)

function getPlayerAchievements(player)
	local isLogged = exports.gc:isPlayerLoggedInGC(player)
	if isLogged then
		local id = exports.gc:getPlayerGreencoinsID(player)
		id = tostring(id)
		local sql = executeSQLQuery("SELECT id, achievements FROM gcAchievements WHERE id = '"..id.."'")
		if #sql == 0 then
			return false
		else
			local achs = sql[1].achievements
			achs = split(achs, string.byte(','))
			return achs
		end
	end
	return false
end


addCommandHandler('removea',
function(player, cmd)
if getPlayerName(player) == "BinSlayer" then
	ach = ",Win a map without using NOS. (100 GC)"
	sql = executeSQLQuery("SELECT id, achievements FROM gcAchievements")
	for i = 1, #sql do 
		achs = sql[i].achievements
		achTable = split(achs, string.byte(','))
		for k,m in ipairs(achTable) do 
			if m == ach then
				here = k
				break
			end	
		end	
		table.remove(achTable, here)
		newachs = table.concat(achTable, ",")
		executeSQLUpdate("gcAchievements", "achievements = '"..newachs.."'", "id = '"..sql[i].id.."'")
	end	
end
end
)

function getPlayersAchievements()
	local a = 0
	local accounts = getAccounts()
	local tableForEachAccount = {}
	if accounts then
		for i,j in ipairs(accounts) do 
			a = a + 1
			tableForEachAccount[a] = {}
			tableForEachAccount[a].countAchievements = 0
			tableForEachAccount[a].name = "unknown"
			for k,m in ipairs(achievementList) do 
				local accData = getAccountData(j, "achievements."..m)
				if accData then
					tableForEachAccount[a].name = accData
					tableForEachAccount[a].countAchievements = tableForEachAccount[a].countAchievements + 1
						
				end
			end
		end
		--[[aux = {}
		for i = 1, (#tableForEachAccount)-1 do 
			for j = i+1 , #tableForEachAccount do 
				if tableForEachAccount[i].countAchievements < tableForEachAccount[j].countAchievements then
					aux = tableForEachAccount[i]
					tableForEachAccount[i] = tableForEachAccount[j]
					tableForEachAccount[j] = aux
				end
			end
		end	
		for i = 1, #tableForEachAccount do
			if (tableForEachAccount[i].name == "unknown") then
				tableForEachAccount[i] = nil
				--table.remove(tableForEachAccount, i)
				--table.remove seems to not work.. use nil instead
			end
		end
		for i = 1, #tableForEachAccount do 
			if i > 10 then
				tableForEachAccount[i] = nil
			end			
		end
		return tableForEachAccount]]	
	end
	return false
end

addEvent('onAchievementsBoxLoad', true)
addEventHandler('onAchievementsBoxLoad', root,
function()
	local isLogged = exports.gc:isPlayerLoggedInGC(source)
	if isLogged then
		local achievementTable = getPlayerAchievements(source)     
		triggerClientEvent(source, "sendAchievementsData", source, "login", achievementTable)  --upload all achievements too!
	else
		triggerClientEvent(source, "sendAchievementsData", source, "unlogin", false)
	end
end
)

addEvent('onOwnAccountCreate', true)
addEventHandler('onOwnAccountCreate', root,
function(user,pass)
	local login
	local account = addAccount(user,pass)
	if account then
		login = logIn(source, account, pass)
		if login then
			if (getPlayerAccount(source)) and (not isGuestAccount(getPlayerAccount(source))) then
				local achievementTable = getPlayerAchievements(source)
				triggerClientEvent(source, "sendAchievementsData", source, "secondLogin", achievementTable)
			end	
		end
	else
		local acc = getAccount(user, pass)
		if acc then
			login = logIn(source, acc, pass)	
			if login then
				if (getPlayerAccount(source)) and (not isGuestAccount(getPlayerAccount(source))) then
					local achievementTable = getPlayerAchievements(source)
					triggerClientEvent(source, "sendAchievementsData", source, "secondLogin", achievementTable)
				end	
			end
		else
		outputChatBox("Wrong password or username.", source)
		end
	end	
end
)

addEvent('onRequestAchievementsPlayer', true)
addEventHandler('onRequestAchievementsPlayer', root,
function(thePlayer)
	local isLogged = exports.gc:isPlayerLoggedInGC(thePlayer)
	if isLogged then
		local achievementTable = getPlayerAchievements(thePlayer)
		triggerClientEvent(source,'sendAchievementsData', source, "sendOther", achievementTable)
	else
		triggerClientEvent(source,'sendAchievementsData', source, "sendOther", nil)
	end	
end
)

addEvent("onPlayerToptimeImprovement",true)
addEventHandler("onPlayerToptimeImprovement",root,
        function (newPos,newTime,oldPos,oldTime)
		if newPos == 1 then
			if pl == source then
				if (not bPlayerHasAchievement(source, achievementList[24])) then
					addPlayerAchievement(source, achievementList[24]) 
				end
			end	
			pl = source
		end	
        end
)





