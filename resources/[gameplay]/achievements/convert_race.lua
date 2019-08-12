-- script to convert from old sqlite db to mysql with forumids

results = executeSQLQuery("SELECT * FROM gcAchievements" )

local achievementList = {
	["Accumulate 10 wins in a gaming session - (100 GC)"] = 27,
	["Drive at 300 km/h for 10 seconds - (100 GC)"] = 9,
	["Drive at over 197 km/h for 30 seconds - (50 GC)"] = 10,		
	["Finish 3 maps in a row without getting any damage - (100 GC)"] = 18,
	["Finish a map as a late joiner - (50 GC)"] = 13,		
	["Finish a map in less than 20 seconds - (50 GC)"] = 15,		
	["Finish a map on fire - (50 GC)"] = 26,		
	["Finish a map without getting any damage - (50 GC)"] = 17,		
	["Finish a map yet dieing 3 times - (100 GC)"] = 19,
	["Finish a map yet having chatted for 30 seconds - (50 GC)"] = 22,	
	["Finish a non-ghostmode map with GM on - (50 GC)"] = 11,	
	["Finish a race at the very last moment - (50 GC)"] = 28,	
	["Finish the map *This Time in the Dark* - (100 GC)"] = 2,
	["Finish the map *Hell Choose Me* - (100 GC)"] = 1,
	["Finish the map *promap* - (100 GC)"] = 30,
	["Finish the map *DOOZYJude - Are You Infernus Pro?* in less than 10 minutes - (200 GC)"] = 41,
	["First noob to die in a map - (50 GC)"] = 12,	
	["Get 2 first toptimes consecutively - (100 GC)"] = 24,
	["No death in 3 maps - (50 GC)"] = 6,	
	["No death in 5 maps - (100 GC)"] = 7,
	["Play for 4 hours with no disconnecting - (100 GC)"] = 29,
	["The only noob to die in a map (Min 5 players) - (100 GC)"] = 5,
	["The only person to finish a map - (100 GC)"] = 21,
	["The only person who hasn't died in a map (Min 5 players) - (100 GC)"] = 8,
	["Win 3 times in a row - (100 GC)"] = 3,
	["Win 5 times in a row - (100 GC)"] = 4,
	["Win a map as a late joiner - (100 GC)"] = 14,
	["Win a map in less than 20 seconds - (100 GC)"] = 16,
	["Win a map on fire - (100 GC)"] = 25,
	["Win a map without using Nitro - (100 GC)"] = 23,
	["Win a map yet dieing once - (100 GC)"] = 20,
	["Win the map *Sprinten* against 30+ players - (100 GC)"] = 31,
	["Win the map *Chase The Checkpoints* against 30+ players - (200 GC)"] = 40,
	["Finish the map *Pirates Of Andreas* - (100 GC)"] = 32,
	["Finish the map *Epic Sandking* - (100 GC)"] = 33,
    ["Finish the map *San Andreas Run Puma* - (100 GC)"] = 34,
    ["Finish the map *Tour de San Andreas* - (100 GC)"] = 35,
	["Win the map *I Wanna Find My Destiny* - (300 GC)"] = 36,
	["Finish the map *I Wanna Find My Destiny* - (100 GC)"] = 37,
	["Win the map *I Wanna Find My Destiny 2* - (300 GC)"] = 38,
	["Finish the map *I Wanna Find My Destiny 2* - (100 GC)"] = 39,
}


local fileHandle = fileCreate("convert2.sql")

fileWrite ( fileHandle, 'TRUNCATE TABLE `achievements_race`;\n\r')
for _,row in ipairs(results) do
	local gcID = row.id
	 outputDebugString(gcID)
	for __, achievement in ipairs(split(row.achievements, ',')) do
		 outputDebugString(achievement)
		local achID = achievementList[achievement]
		local query = "INSERT INTO `achievements_race`(`forumID`, `achievementID`, `unlocked`) VALUES (" .. row.id .. ", " .. achID .. ", 1);\n\r"
		fileWrite(fileHandle, query)
	end
	
end
fileWrite ( fileHandle, 'UPDATE `achievements_race` SET `forumID`= (SELECT `green_coins`.`forum_id` FROM `mrgreengaming_gc`.`green_coins` WHERE `id` = `forumID`);\n\r')
fileClose(fileHandle)
