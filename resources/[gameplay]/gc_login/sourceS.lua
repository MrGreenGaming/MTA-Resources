function doLogin(player, username, password) 
	outputDebugString("User tried logging in")

end



-- local connection = false

-- addEventHandler("onDatabaseConnected", getRootElement(), function(db)
-- 	print("db conn")
-- 	connection = db
-- end)

-- addEventHandler("onResourceStart", getResourceRootElement(), function()
-- 	connection = exports.gc_database:getConnection()

-- 	for index, player in pairs(getElementsByType("player")) do
-- 		saveUser(player, true)

-- 		setElementData(player, "player.loggedIn", false)
-- 	end
-- end)

-- function doLogin(player, username, password1)
-- 	local fetchOptions = {
-- 		queueName = "API",
-- 		connectionAttempts = 3,
-- 		connectTimeout = 4000,
-- 		method = "POST",
-- 		postData = toJSON({
-- 			user = username,
-- 			password = password1,
-- 			appId = exports.gc_core:getAPIdetails().id,
-- 			appSecret = exports.gc_core:getAPIdetails().key
-- 		}, true),
-- 		headers = {
-- 			["Content-Type"] = "application/json",
-- 			["Accept"] = "application/json"
-- 		}
-- 	}

-- 	fetchRemote("https://mrgreengaming.com/api/account/login", fetchOptions, function(res, info)
-- 		if not info.success or not res then
-- 			if not res then
-- 				res = "EMPTY"
-- 			end
-- 			print("getPlayerLoginInfo: invalid response (status " .. info.statusCode .. "). Res: " .. res)
-- 			return
-- 		end

-- 		local APIresult = fromJSON(res)
-- 		if not APIresult or APIresult.error then
-- 			print("getForumAccountDetails: api error! " .. APIresult.error .. ' ' .. tostring(APIresult.errorMessage))
-- 			print("Nincs ilyen felhasználó")
-- 			return
-- 		end

-- 		if APIresult.banned then
-- 			print("Bannolva vagy")
-- 			return
-- 		end
		
-- 		dbQuery(function(queryHandle, source)
-- 			local result, rows = dbPoll(queryHandle, 0) 

-- 			if rows == 1 then
-- 				print("találat, login") 
-- 				loginUser(player, result[1])
-- 			elseif rows > 1 then
-- 				print("1nél több találat, keress fel 1 fejlesztőt")
-- 			elseif rows == 0 then
-- 				insertUser(player, APIresult)   
-- 			end
-- 		end, {source}, connection, "SELECT * FROM users WHERE forumId = ? LIMIT 1", APIresult.userId)
-- 	end)
-- end
-- addEvent("doLoginS", true)
-- addEventHandler("doLoginS", root, doLogin)

-- function doRegister(player, username, password1, password2, email)
-- 	if password1 ~= password2 then
-- 		print("A 2 jelszó nem egyezik")
-- 		return 
-- 	end

-- 	local fetchOptions = {
-- 		queueName = "API",
-- 		connectionAttempts = 3,
-- 		connectTimeout = 4000,
-- 		method = "POST",
-- 		postData = toJSON({
-- 			password = password1,
-- 			username = username,
-- 			email = email,
-- 			ip = getPlayerIP(player),
-- 			serial = getPlayerSerial(player),
-- 			appId = exports.gc_core:getAPIdetails().id,
-- 			appSecret = exports.gc_core:getAPIdetails().key
-- 		}, true),
-- 		headers = {
-- 			["Content-Type"] = "application/json",
-- 			["Accept"] = "application/json"
-- 		}
-- 	}

-- 	fetchRemote("https://mrgreengaming.com/api/account/register", fetchOptions, function(res, info)
-- 		if not info.success or not res then
-- 			if not res then
-- 				res = "EMPTY"
-- 			end
-- 			print("invalid response (status " .. info.statusCode .. "). Res: " .. res)
-- 			return
-- 		end

-- 		local APIresult = fromJSON(res)
-- 		if not APIresult or APIresult.error then
-- 			print("API error! " .. APIresult.error .. ' ' .. tostring(APIresult.errorMessage))
-- 			return
-- 		end

-- 		if APIresult.banned then
-- 			print("Bannolva vagy")
-- 			return
-- 		end
		
-- 		print("Sikeres reg")
-- 	end)
-- end
-- addEvent("doRegisterS", true)
-- addEventHandler("doRegisterS", root, doRegister)

-- function insertUser(source, data)
-- 	dbQuery(function(queryHandle)
-- 		print(source)
-- 		if not isElement(source) then
-- 			print("Nem jó element")
-- 			dbFree(queryHandle)
-- 			return
-- 		end

-- 		local result, rows, lastId = dbPoll(queryHandle, 0)

-- 	end, connection, "INSERT INTO users (forumId, username, serial, vip, coinsBalance, banned, language) VALUES (?, ?, ?, ?, ?, ?, ?)", data.userId, data.user, getPlayerSerial(source), data.vip or 0, data.coinsBalance, data.banned, getElementData(source, "player.language"))
-- end

-- function loginUser(player, data)
-- 	print(inspect(data))
	
-- 	setElementData(player, "player.dbId", data.dbId)
-- 	setElementData(player, "player.forumId", data.forumId)
-- 	setElementData(player, "player.vip", data.vip)
-- 	setElementData(player, "player.coinsBalance", data.coinsBalance)
-- 	setElementData(player, "player.banned", data.banned)
-- 	setElementData(player, "player.joinDate", data.joinDate)
-- 	setElementData(player, "player.adminlevel", data.adminlevel)
-- 	setElementData(player, "player.skin", data.skin)

-- 	setElementData(player, "player.loggedIn", true)

-- 	x, y, z, rz, int, dim = unpack(fromJSON(data.position))
	

-- 	spawnPlayer(player, x, y, z, rz, 0, int, dim)

-- 	setElementHealth(player, tonumber(data.health))
-- 	setPedArmor(player, tonumber(data.armor))
-- 	setElementModel(player, data.skin)

-- 	setCameraTarget(player)

-- 	triggerClientEvent(player, "hideLogin", player)
	
-- 	dbExec(connection, "UPDATE users SET lastLogin = ?, online = ? WHERE dbId = ?", getRealTime().timestamp, "Y", data.dbId)
-- end

-- function saveUser(player, loggedOut)
-- 	if isElement(player) then
-- 		if getElementData(player, "player.loggedIn") then
-- 			local dbId = getElementData(player, "player.dbId")

-- 			-- Position save
-- 			local pX, pY, pZ = getElementPosition(player)
-- 			local pRX, pRY, pRZ = getElementRotation(player)
-- 			local pInt, pDim = getElementInterior(player), getElementDimension(player)

-- 			local positionTable = {pX, pY, pZ, pRZ, pInt, pDim}

-- 			-- Data Table for save
-- 			local dataTable = {
-- 				online = loggedOut and "N" or "Y",
-- 				position = toJSON(positionTable),
-- 				coinsBalance = getElementData(player, "player.coinsBalance") or 0,
-- 				adminlevel = getElementData(player, "player.adminlevel") or 0,
-- 				skin = getElementData(player, "player.skin") or getElementModel(player) or 0,
-- 				health = getElementHealth(player) or 50,
-- 				armor = getPedArmor(player) or 0,
-- 			}

-- 			exports.gc_database:dbUpdate("users", dataTable, {dbId = dbId})
		
-- 			return true
-- 		else
-- 			return false
-- 		end
-- 	else
-- 		return false
-- 	end

-- 	return false
-- end

-- addEventHandler("onPlayerQuit", root, function()
-- 	saveUser(source, true)
-- end)

-- addCommandHandler("sp", function(p)
-- 	saveUser(p, true)
-- end)