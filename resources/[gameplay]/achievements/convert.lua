-- script to convert from old sqlite db to mysql with forumids

results = executeSQLQuery("SELECT * FROM gcAchievements" )

local achievementList = {
	["CTF: Capture two flags in one map (50 GC)"] = 1,
	["CTF: Capture the winning flag (50 GC)"] = 2,
}

local fileHandle = fileCreate("convert.sql")

fileWrite ( fileHandle, 'TRUNCATE TABLE `achievements`;\n\r')
for _,row in ipairs(results) do
	local gcID = row.id
	-- outputDebugString(gcID)
	for __, achievement in ipairs(split(row.achievements, ',')) do
		-- outputDebugString(achievement)
		local achID = achievementList[achievement]
		local query = "INSERT INTO `achievements`(`forumID`, `achievementID`, `unlocked`) VALUES (" .. row.id .. ", " .. achID .. ", 1);\n\r"
		fileWrite(fileHandle, query)
	end
	
end
fileWrite ( fileHandle, 'UPDATE `achievements` SET `forumID`= (SELECT `green_coins`.`forum_id` FROM `mrgreengaming_gc`.`green_coins` WHERE `id` = `forumID`);\n\r')
fileClose(fileHandle)

function getElementResource (element)
	local parent = element
	repeat
		parent = getElementParent ( parent )
	until not parent or getElementType(parent) == 'resource'
	
	for _, resource in ipairs(getResources()) do
		if getResourceRootElement(resource) == parent then
			return resource
		end
	end
	return false
end

function isMap(resourceElement)
	return #getElementsByType('spawnpoint', resourceElement) > 0
end