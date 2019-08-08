local g_Players = {}
tableOfWinners = {}
tableOfPlayers = {}

achievementListRace = {
	-- { achText, achID (unique!!!!), reward, max }
	{ s = "Accumulate 10 wins in a gaming session", 					id = 27,		reward = 100 },
	{ s = "Drive at 300 km/h for 10 seconds",			    			id = 9,			reward = 100 },
	{ s = "Drive at over 197 km/h for 30 seconds",     					id = 10,		reward = 50 },
	{ s = "Finish 3 maps in a row without getting any damage", 			id = 18,		reward = 100 },
	{ s = "Finish a map as a late joiner",     							id = 13,		reward = 50 },
	{ s = "Finish a map in less than 20 seconds",   				    id = 15,		reward = 50 },
	{ s = "Finish a map on fire",    						   			id = 26,		reward = 50 },
	{ s = "Finish a map without getting any damage",    	    		id = 17,		reward = 50 },
	{ s = "Finish a map yet dying 3 times",     						id = 19,		reward = 100 },
	{ s = "Finish a map yet having chatted for 30 seconds",    			id = 22,		reward = 50 },
	{ s = "Finish a non-ghostmode map with GM on",    		   			id = 11,		reward = 50 },
	{ s = "Finish a race at the very last moment",    		    		id = 28,		reward = 50 },
	{ s = "Finish the map *Drift Project 2*",   			   			id = 2,			reward = 100 },
	{ s = "Finish the map *Hell Choose Me*",     						id = 1,			reward = 100 },
	{ s = "Finish the map *promap*",									id = 30,		reward = 100 },
	{ s = "First noob to die in a map",     							id = 12,		reward = 50 },
	{ s = "Get 2 first toptimes consecutively",    		  				id = 24,		reward = 100 },
	{ s = "No death in 3 maps",     									id = 6,			reward = 50 },
	{ s = "No death in 5 maps",    						    			id = 7,			reward = 100 },
	{ s = "No death in 10 maps",    						    			id = 46,			reward = 200 },
	{ s = "No death in 20 maps",    						    			id = 47,			reward = 300 },
	{ s = "Play for 4 hours with no disconnecting",						id = 29,		reward = 100 },
	{ s = "The only noob to die in a map",     							id = 5,			reward = 100 },
	{ s = "The only person to finish a map",    						id = 21,		reward = 100 },
	{ s = "Finish the map *Hydratastic!*",               	   	                id = 42,		reward = 100 },
	{ s = "Win the map *Hydratastic!*",               	   	                id = 43,		reward = 300 },
	{ s = "The only person who hasn't died in a map",   	    		id = 8,			reward = 100 },
	{ s = "Win 3 times in a row",       					   			id = 3,			reward = 100 },
	{ s = "Win 5 times in a row",     									id = 4,			reward = 300 },
	{ s = "Win 10 times in a row",     									id = 45,			reward = 500 },
	{ s = "Win a map as a late joiner",     							id = 14,		reward = 100 },
	{ s = "Win a map in less than 20 seconds",    			    		id = 16,		reward = 100 },
	{ s = "Win a map on fire",     						   		 		id = 25,		reward = 100 },
	{ s = "Win a map without using Nitro",    				   			id = 23,		reward = 100 },
	{ s = "Win a map yet dying once",    					    		id = 20,		reward = 100 },
	{ s = "Win the map *Sprinten* against 30+ players",		    		id = 31,		reward = 50 },
	{ s = "Finish the map *Pirates Of Andreas*",               	   		id = 32,		reward = 100 },
	{ s = "Finish the map *Epic Sandking*",               	   		        id = 33,		reward = 100 },
        { s = "Finish the map *San Andreas Run Puma*",               	   		id = 34,		reward = 100 },
        { s = "Finish the map *Tour de San Andreas*",               	   		id = 35,		reward = 100 },
	{ s = "Win the map *I Wanna Find My Destiny*",               	   		id = 36,		reward = 300 },
	{ s = "Finish the map *I Wanna Find My Destiny*",               	   	id = 37,		reward = 100 },
	{ s = "Win the map *I Wanna Find My Destiny 2*",               	   	        id = 38,		reward = 300 },
	{ s = "Finish the map *I Wanna Find My Destiny 2*",               	   	id = 39,		reward = 100 },
	{ s = "Finish the map *DOOZYJude - Are You Infernus Pro?* in less than 10 minutes",                     id = 40,		reward = 300 },
        { s = "Win the map *Never The Same*",               	   	                id = 41,		reward = 100 },
	{ s = "Win the map *Chase The Checkpoints* against 30+ players",		    		id = 44,		reward = 200 },

}


addEventHandler('onResourceStart', resourceRoot,
function()
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
	end	
end
)

addEventHandler('onPlayerJoin', root,
function()
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


addEvent('onPlayerFinish', true)
addEventHandler('onPlayerFinish', root,
function(rank, time)
if exports.race:getRaceMode() ~= "Sprint" then return end
	if rank == 1 then
		g_Players[source].mapsWon = g_Players[source].mapsWon + 1
		if g_Players[source].mapsWon == 10 then
			addPlayerAchievementRace(source, 27)
		end	
	end	
	tableOfWinners[rank] = source
	if not mapGM then
		local collidable = getElementData(source, "overrideCollide.uniqueblah")
		local cps = #getElementsByType('checkpoint')
		if (collidable == 0) and (cps > 5) then
			addPlayerAchievementRace(source, 11)
		end	
	end	
	if (getMapName() == "Hell Choose Me") then
		addPlayerAchievementRace(source, 1)
	end
	if (getMapName() == "Drift Project 2") then
		addPlayerAchievementRace(source, 2)
	end
	if (getMapName() == "promap") then
		addPlayerAchievementRace(source, 30)
	end
	if (getMapName() == "Sprinten") and (rank == 1) and (getPlayerCount() > 29) then
		addPlayerAchievementRace(source, 31)
	end
	if (getMapName() == "[SRI]Pirates Of Andreas") then
		addPlayerAchievementRace(source, 32)
	end
	if (getMapName() == "Epic Sandking") then
		addPlayerAchievementRace(source, 33)
	end
	if (getMapName() == "San Andreas Run_Puma") then
		addPlayerAchievementRace(source, 34)
	end
	if (getMapName() == "[Race] Tour de San Andreas") then
		addPlayerAchievementRace(source, 35)
	end
	if (getMapName() == "I wanna find my destiny") and (rank == 1) then
		addPlayerAchievementRace(source, 36)
	end
	if (getMapName() == "I wanna find my destiny") then
		addPlayerAchievementRace(source, 37)
	end
	if (getMapName() == "I wanna find my destiny 2") and (rank == 1) then
		addPlayerAchievementRace(source, 38)
	end
	if (getMapName() == "I wanna find my destiny 2") then
		addPlayerAchievementRace(source, 39)
	end
	if (getMapName() == "!!- DOOZYJude - IUISO[ARE-YOU-INFERNUS-PRO?(EASY)]") then
		if time <= 600000 then	
		        addPlayerAchievementRace(source, 40)
	end
        if (getMapName() == "Never The Same") and (rank == 1) then
		addPlayerAchievementRace(source, 41)
	end
	if (getMapName() == "Hydratastic!") then
		addPlayerAchievementRace(source, 42)
	end
	if (getMapName() == "Hydratastic!") and (rank == 1) then
		addPlayerAchievementRace(source, 43)
	end
	if (getMapName() == "Chase the Checkpoints") and (rank == 1) and (getPlayerCount() > 29) then
		addPlayerAchievementRace(source, 44)
	end
	if (rank == 1) and not g_Players[source].won then
		g_Players[source].wins = 1
		g_Players[source].won = true
	elseif (g_Players[source].won) and (rank == 1) then
		g_Players[source].wins = g_Players[source].wins + 1
		if g_Players[source].wins == 3 then
			addPlayerAchievementRace(source, 3)
		elseif g_Players[source].wins == 5 then
			addPlayerAchievementRace(source, 4)
		elseif g_Players[source].wins == 10 then
			addPlayerAchievementRace(source, 45)
		end
	else 
		g_Players[source].wins = 0
		g_Players[source].win = false
	end	
	local ok = true
	for i,j in ipairs(tableOfPlayers) do 
		if j == source then
			ok = false
		end
	end
	if ok then
		addPlayerAchievementRace(source, 13)	
	end	
	if ( rank == 1 ) then
		local ok = true
		for i,j in ipairs(tableOfPlayers) do 
			if j == source then
				ok = false
			end
		end
		if ok then
			addPlayerAchievementRace(source, 14)	
		end	
	end	
	if time <= 20000 then
		addPlayerAchievementRace(source, 15)
	end
	if (rank == 1)	then
		if time <= 20000 then
			addPlayerAchievementRace(source, 16)
		end
	end	
	if (not g_Players[source].damaged) then
		addPlayerAchievementRace(source, 17)
	end	
	if (g_Players[source].countMapsWithNoDamage == 3) then
		addPlayerAchievementRace(source, 18)
	end	
	if (g_Players[source].deathCount >= 3) then
		addPlayerAchievementRace(source, 19)
	end	
	if (g_Players[source].deathCount >= 1) and (rank == 1) then
		addPlayerAchievementRace(source, 20)
	end	
	if (g_Players[source].hasBeenChatting) then
		addPlayerAchievementRace(source, 22)
	end	
	if (g_Players[source].nos == false) and (rank == 1) and (hasNitro) and (getVehicleType(getPedOccupiedVehicle(source)) ~= "Bike") then
		addPlayerAchievementRace(source, 23)
	end
	if (rank == 1) and (getElementHealth(getPedOccupiedVehicle(source)) < 250) then
		addPlayerAchievementRace(source, 25)
	end		
	if (getElementHealth(getPedOccupiedVehicle(source)) < 250) then
		addPlayerAchievementRace(source, 26)
	end	
	local c = 0
	if (rank == 1) then
		tickTimer = setTimer(function()
				c = c + 1
		end, 1000, 44)         --this needs to be adjusted in case Green server changes max Hurry time.
		g_Players[source].timer = true
	end	
	if (c >= 43) and (g_Players[source].timer == false) then  --this needs to be adjusted in case Green server changes max Hurry time.
		addPlayerAchievementRace(source, 28)
	end	
end
)


function wastedFunc(ammo, killer, deathReason)
	g_Players[source].died = true  	--for noob thing
end


addEvent('onPostFinish', true)
addEventHandler('onPostFinish', root,
function()
if exports.race:getRaceMode() ~= "Sprint" then return end

--this is for "Be the only noob to die in a map"
--this is for "be the only person who hasn't died in a map"
	for i,j in ipairs(getElementsByType('player')) do 
		local isFinished = getElementData(j, "race.finished")
		if (g_Players[j].wins ~= 0) and (g_Players[j].win ~= false) and (isFinished == false) then
			g_Players[j].wins = 0
			g_Players[j].win = false
		end	
	end	
	local count = 0
	local onlyPlayer
	for i,j in pairs(g_Players) do 
		for k, m in pairs(j) do 
			if (k == "died") and (m == true) then
				count = count + 1
				onlyPlayer = i
			end	
		end
	end
	if count == 1 then	
		addPlayerAchievementRace(onlyPlayer, 5)
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
		 addPlayerAchievementRace(onlyPlayer, 8)
	end
	removeEventHandler('onPlayerWasted', root, wastedFunc)
end
)

function dieFunc()
	g_Players[source].dead = true
	g_Players[source].deathCount = g_Players[source].deathCount + 1
end

function firstNoob()
	if (firstDead == false) then
		addPlayerAchievementRace(source, 12)	
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
if exports.race:getRaceMode() ~= "Sprint" then return end

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
if exports.race:getRaceMode() ~= "Sprint" then return end

	if isTimer(delayDeath) then killTimer(delayDeath) end
	if #tableOfWinners == 1 then
		addPlayerAchievementRace(tableOfWinners[1], 21)
	end
	tableOfWinners = {}	
	for i,j in ipairs(getElementsByType('player')) do
		if g_Players[j].dead then
			g_Players[j].countMapsWithNoDeaths = 0
			g_Players[j].dead = false
			g_Players[j].deathCount = 0
		end	
		if g_Players[j].countMapsWithNoDeaths == 3 then
			addPlayerAchievementRace(j, 6)
		elseif 	g_Players[j].countMapsWithNoDeaths == 5 then
			addPlayerAchievementRace(j, 7)
		elseif 	g_Players[j].countMapsWithNoDeaths == 10 then
			addPlayerAchievementRace(j, 46)
		elseif 	g_Players[j].countMapsWithNoDeaths == 20 then
			addPlayerAchievementRace(j, 47)
		end	
	end
	removeEventHandler('onPlayerWasted', root, dieFunc)
	removeEventHandler('onVehicleDamage', root, vehicleFunc)
	removeEventHandler('onPlayerWasted', root, firstNoob)
end
)

addEvent("onClientAchievement", true)
addEventHandler("onClientAchievement", root,
function(achID)
	addPlayerAchievementRace(client, achID)
end
)


addEvent("onClientChatAchievement", true)
addEventHandler("onClientChatAchievement", root,
function()
	g_Players[client].hasBeenChatting = true
end
)

addEvent("onClientHasUsedNOS", true)
addEventHandler("onClientHasUsedNOS", root,
function()
	g_Players[client].nos = true
end
)

addEvent("onPlayerToptimeImprovement",true)
addEventHandler("onPlayerToptimeImprovement",root,
    function (newPos,newTime,oldPos,oldTime)
	if exports.race:getRaceMode() ~= "Sprint" then return end
	
		if newPos == 1 then
			if pl == source then
				addPlayerAchievementRace(source, 24)
			end	
			pl = source
		end	
    end
)
