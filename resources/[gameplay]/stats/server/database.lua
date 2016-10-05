----------------------------------------------------------------------------------------------------------------
---	I N T R O D U C T I O N ------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--- "Specific stats": This is how I call stats which saves to DB only between maps and on player quit/logout ---
--- All other statistics saves immediately when you win etc ----------------------------------------------------
----------------------------------------------------------------------------------------------------------------


resName = getResourceName( getThisResource() )

---------------------------
--- Cached player stats ---
---------------------------
playerStatsCache = {}

-------------------
--- DB Settings ---
-------------------
local dbSettings = {
    host = get("*gcshop.host"),
    username = get("*gcshop.user"),
    password = get("*gcshop.pass"),
    database = get("*gcshop.dbname"),
}

---------------------------------------------------------
--- onResourceStart: Connect to DB and do MySQL query ---
---------------------------------------------------------
addEventHandler("onResourceStart", resourceRoot, 
	function()
		if isElement(database) then
			destroyElement(database)
		end

		database = dbConnect( 'mysql', 'host='..dbSettings.host..';dbname='..dbSettings.database, dbSettings.username, dbSettings.password, "multi_statements=1") 
		
		queryStatsAll()
	end
)

-------------------------------------------
--- onResourceStop: Save specific stats ---
-------------------------------------------
addEventHandler("onResourceStop", resourceRoot, 
	function()
		local forumIDs = {}
		for _, player in ipairs(getElementsByType'player') do 
			local forumID = exports.gc:getPlayerForumID (player)
			if forumID then
				table.insert(forumIDs, forumID)
			end
		end
	
		if #forumIDs > 0 then 
			savePlayerSpecificStats(forumIDs)
		end
	end
)

-------------------------------------
--- onGCLogin: Cache player stats ---
-------------------------------------
addEventHandler("onGCLogin" , root, 
	function(forumID)
		cachePlayerStats( { forumID } )
	end
)

-------------------------------------------------------
--- onGCLogout: Save specific stats and clean cache ---
-------------------------------------------------------
addEventHandler("onGCLogout" , root, 
	function(forumID)
		savePlayerSpecificStats( { forumID }, true)
	end
)

---------------------------------------------------
--- Get logged in players and start MySQL query ---
---------------------------------------------------
function queryStatsAll()
	local resGC = getResourceFromName'gc'
	if not resGC or getResourceState ( resGC ) ~= 'running' then return false end
	
	local forumIDs = {}
	for _, player in ipairs(getElementsByType'player') do 
		local forumID = exports.gc:getPlayerForumID (player)
		if forumID then
			table.insert(forumIDs, forumID)
		end
	end
	
	if #forumIDs > 0 then 
		cachePlayerStats(forumIDs)
	end
end

----------------------------------------------------
--- Query Player Stats from MySQL and cache them ---
----------------------------------------------------
function cachePlayerStats(tableForumIDs)
	if not database then outputDebugString(resName..": no db connection", 0, 255, 0, 0) return false end
	
	local query = dbQuery(database, "SELECT * FROM `stats` WHERE forumID IN(??)", table.concat(tableForumIDs, ','))
	local result = dbPoll(query, -1)
	
	if result then
		------------------------
		-- Add stats to cache --
		------------------------
		for _, row in ipairs(result) do 
			playerStatsCache[row.forumID] = {}
			playerStatsCache[row.forumID] = row
		end
		
		local forumIDs = {} --table with forumIDs which not in DB yet
		for _, forumID in pairs(tableForumIDs) do
			if not playerStatsCache[forumID] then 
				playerStatsCache[forumID] = {}
				table.insert(forumIDs, forumID)
			end
			playerStatsCache[forumID]["joinTime"] = getTickCount()
			-- Temp = this gaming session (specific stats)
			playerStatsCache[forumID]["temp_id6"] = 0
			playerStatsCache[forumID]["temp_id4"] = 0
			playerStatsCache[forumID]["temp_id12"] = 0
			playerStatsCache[forumID]["temp_id16"] = 0
			playerStatsCache[forumID]["temp_id1"] = 0
			playerStatsCache[forumID]["temp_id7"] = 0
			playerStatsCache[forumID]["temp_id10"] = 0
		end
		
		if #forumIDs > 0 then
			local forumidsString = ""
			for i=1, #forumIDs do
				if i == 1 then
					forumidsString = "("..forumIDs[i]..")"
				else
					forumidsString = forumidsString..", ("..forumIDs[i]..")"
				end
			end
			
			------------------------------------------------
			-- Add forumIDs to DB if they isn't there yet --
			------------------------------------------------
			if forumidsString ~= "" then
				local inserted = dbExec(database, "INSERT INTO `stats`(forumID) VALUES "..forumidsString.." ON DUPLICATE KEY UPDATE forumID=forumID")
				
				if inserted then
					if debugMode then 
						outputDebugString(resName..": cachePlayerStats() - INSERTed new forumIDs: "..forumidsString)
					end
					------------------------
					-- Add stats to cache --
					------------------------
					for _, forumID in pairs(forumIDs) do
						for id, _ in pairs(allStats) do
							playerStatsCache[forumID][id] = 0
						end
					end
				end
			end
		end
	elseif not result then 
		outputDebugString("cachePlayerStats() - Error: Query not ready or error") 
		return false
	end
end

-------------------------
--- Save player stats ---
-------------------------
function savePlayerStat(player, statID, amount)
	local forumID = exports.gc:getPlayerForumID(player)
	if not forumID then return end
	if not database then outputDebugString(resName..": savePlayerStat() - no db connection", 0, 255, 0, 0) return end

	incrementPlayerStatsData(nil, statID, amount, forumID)
	local updated = dbExec(database, "UPDATE `stats` SET "..statID.." = "..statID.." + "..amount.." WHERE forumID = ?", forumID)
	
	if debugMode and updated then
		outputDebugString(resName..": savePlayerStat() | forumID: "..forumID.." | Stat name: "..allStats[statID].." | Value: +"..amount)
	elseif debugMode and not updated then
		outputDebugString(resName.." Failed to savePlayerStat() for forumID: "..forumID, 0, 255, 0, 0)
	end
end

----------------------------------
--- Save player specific stats ---
----------------------------------
function savePlayerSpecificStats(tableForumIDs, logout)
	if not tableForumIDs then return false end
	if not database then outputDebugString(resName..": savePlayerSpecificStats() - no db connection", 0, 255, 0, 0) return false end
	
	local queryString = ""
	local debugString = ""
	
	for _, forumID in ipairs(tableForumIDs) do
		local s = playerStatsCache[forumID]
	
		if s["joinTime"] then
			queryString = queryString .. dbPrepareString(database, "UPDATE `stats` SET id4 = id4 + ?, id5 = id5 + ?, id6 = id6 + ?, id12 = id12 + ?, id16 = id16 + ?, id1 = id1 + ?, id7 = id7 + ?, id10 = id10 + ? WHERE forumID = ?;", s["temp_id4"], getPlaytime(s["joinTime"]), s["temp_id6"], s["temp_id12"], s["temp_id16"], s["temp_id1"], s["temp_id7"], s["temp_id10"], forumID)
			if debugMode then
				if debugString == "" then
					debugString = forumID
				else
					debugString = debugString..", "..forumID
				end
			end
		end
	
		if logout then
			playerStatsCache[forumID] = nil
		end
	end
	
	if queryString ~= "" then
		local updated = dbExec(database, queryString)
		if debugMode and updated then
			outputDebugString(resName..": savePlayerSpecificStats() | forumIDs: "..debugString)
		elseif debugMode and not updated then
			outputDebugString(resName.." Failed to savePlayerSpecificStats() for forumIDs: "..debugString, 0, 255, 0, 0)
		end
	end
end


addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", root,
	function(newStateName, oldStateName)
		if not database then outputDebugString(resName..": no db connection", 0, 255, 0, 0) return end
		
		if newStateName == "LoadingMap" then
			local forumIDs = {}
			for forumID, stats in ipairs(playerStatsCache) do
				if stats then
					table.insert(forumIDs, forumID)
				end
			end
			
			if #forumIDs > 0 then 
				savePlayerSpecificStats(forumIDs)
			end
		end
	end
)