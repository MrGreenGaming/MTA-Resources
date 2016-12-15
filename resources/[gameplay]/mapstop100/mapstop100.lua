handlerConnect = nil
canScriptWork = true
addEventHandler('onResourceStart', getResourceRootElement(),
function()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname", get("*gcshop.user"), get("*gcshop.pass"))
	if handlerConnect then
		dbExec( handlerConnect, "CREATE TABLE IF NOT EXISTS `mapstop100` ( `id` int(11) NOT NULL AUTO_INCREMENT, `mapresourcename` VARCHAR(70) BINARY NOT NULL, `mapname` VARCHAR(70) BINARY NOT NULL, `author` VARCHAR(70) BINARY NOT NULL, `gamemode` VARCHAR(70) BINARY NOT NULL, `rank` INTEGER, `votes` INTEGER, PRIMARY KEY (`id`) )" )
		dbExec( handlerConnect, "CREATE TABLE IF NOT EXISTS `votestop100` ( `id` int(11) NOT NULL AUTO_INCREMENT, `forumid` int(10) unsigned NOT NULL, `choice1` VARCHAR(70) BINARY NOT NULL, `choice2` VARCHAR(70) BINARY NOT NULL, `choice3` VARCHAR(70) BINARY NOT NULL, `choice4` VARCHAR(70) BINARY NOT NULL, `choice5` VARCHAR(70) BINARY NOT NULL, PRIMARY KEY (`id`) )" )
		else
		outputDebugString('Maps top 100 error: could not connect to the mysql db')
		canScriptWork = false
		return
	end
end
)

function maps100_fetchMaps(player)
    refreshResources()

    local mapList = {}

    -- Get race and uploaded maps
    local raceMps = exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName("race"))
    if not raceMps then return false end

    for _,map in ipairs(raceMps) do
        local name = getResourceInfo(map,"name")

        local author = getResourceInfo(map,"author")
        local resname = getResourceName(map)

        if not name then name = resname end
        if not author then author = "N/A" end
		
		local gamemode
        local t = {name = name, author = author, resname = resname, gamemode = "Race"}
		
        table.insert(mapList,t)
    end

    table.sort(mapList,function(a,b) return tostring(a.name) < tostring(b.name) end)
	
	local map100 = {}
	local qh = dbQuery(handlerConnect, "SELECT * FROM `mapstop100`")
	local map100_sql = dbPoll(qh,-1)
	if not map100_sql then return false end
	
    for _,row in ipairs(map100_sql) do
        local name = tostring(row.mapname)
        local author = tostring(row.author)
        local resname = tostring(row.mapresourcename)
		local gamemode = tostring(row.gamemode)
		
        local t = {name = name, author = author, resname = resname, gamemode = gamemode}
        table.insert(map100,t)
    end
    table.sort(map100,function(a,b) return tostring(a.name) < tostring(b.name) end)

	triggerClientEvent(player,"maps100_receiveMapLists",resourceRoot,mapList,map100)
end

function maps100_command(p)
	maps100_fetchMaps(p)
	triggerClientEvent(p,"maps100_openCloseGUI",resourceRoot)
end
addCommandHandler("maps100", maps100_command)

function maps100_addMap(p, name, author, gamemode, resname)
	local qh = dbQuery(handlerConnect, "SELECT * FROM `mapstop100` WHERE `mapresourcename`=?", tostring(resname))
	local resCheck = dbPoll(qh,-1)
	if resCheck[1] then
		if tostring(resCheck[1].mapresourcename) == tostring(resname) then
			outputChatBox("Map already added", p)
			return
		end
	end
	local qh = dbQuery(handlerConnect, "INSERT INTO `mapstop100` (`mapresourcename`, `mapname`, `author`, `gamemode`, `rank`, `votes`) VALUES (?,?,?,?,?,?)", resname, name, author, gamemode, "0", "0" )
	if dbFree( qh ) then
		outputChatBox("Map added succesfully", p)
	end
	maps100_fetchMaps(p)
end
addEvent("maps100_addMap", true)
addEventHandler("maps100_addMap", resourceRoot, maps100_addMap)

function maps100_delMap(p, name, author, gamemode, resname)
	local qh = dbQuery(handlerConnect, "DELETE FROM `mapstop100` WHERE `mapresourcename`=?", resname)
	if dbFree( qh ) then
		outputChatBox("Map deleted succesfully", p)
	end
	maps100_fetchMaps(p)
end
addEvent("maps100_delMap", true)
addEventHandler("maps100_delMap", resourceRoot, maps100_delMap)