local price = 1500
unlimitedUses = 5000
canHornBeUsed = {}
howManyTimes = {}
newMap = nil
coolOffTimer = {}
coolOff = {}

function useHorn(player,commandName,horn)
	if (canHornBeUsed[player]) and (coolOff[player] == true) and (isPedInVehicle(player)) and (not isVehicleBlown(getPedOccupiedVehicle(player))) and (getElementHealth(getPedOccupiedVehicle(player)) > 250) and (getElementData(player, "state") == "alive") then
		local logged = exports.gc:isPlayerLoggedInGC(player)
		if logged then
			local forumid = exports.gc:getPlayerForumID(player)
			forumid = tostring(forumid)
			if not horn then -- If it's called by the bind H or /horn
			-- dbExec(handlerConnect, "INSERT INTO gc_items (forumid,itembought) VALUES (?,?)", forumid, ID)
				local query = dbQuery(handlerConnect, "SELECT current, unlimited FROM gc_horns WHERE forumid = ?", forumid)
				local sql = dbPoll(query,-1)
				-- local sql = executeSQLQuery("SELECT forumid, horns, current, unlimited FROM gc_horns WHERE forumid = '"..forumid.."'")
				if #sql > 0 then
					local horn = tonumber(sql[1].current) ~= 0 and tostring(sql[1].current) or "none"
					if horn == "none" then return end
					local car = getPedOccupiedVehicle(player)
					coolOffTimer[player] = setTimer(function(player) coolOff[player] = true end, 10000, 1, player)
					triggerClientEvent("onPlayerUsingHorn", player, horn, car)
					coolOff[player] = false
					howManyTimes[player] = howManyTimes[player] + 1
					if sql[1].unlimited == 1 then howManyTimes[player] = 0 end
					if howManyTimes[player] == 3 then
						canHornBeUsed[player] = false
					end
				end	
			elseif tonumber(horn) then


				local query = dbQuery(handlerConnect, "SELECT horns, unlimited FROM gc_horns WHERE forumid = ?", forumid)
				local sql = dbPoll(query,-1)
				-- local sql = executeSQLQuery("SELECT forumid, horns, current, unlimited FROM gc_horns WHERE forumid = '"..forumid.."'")
				if #sql > 0 then
					local allHorns = split(sql[1].horns, string.byte(','))
					
					local useHorn = false
					for i,j in ipairs(allHorns) do
						if tonumber(j) == tonumber(horn) then
							useHorn = true
							break
						end
					end

					if not useHorn then outputChatBox("Please buy the horn (".. tostring(horn) ..") first before using it",player,255,0,0) return end



					local car = getPedOccupiedVehicle(player)
					coolOffTimer[player] = setTimer(function(player) coolOff[player] = true end, 10000, 1, player)
					triggerClientEvent("onPlayerUsingHorn", player, horn, car)
					coolOff[player] = false
					howManyTimes[player] = howManyTimes[player] + 1
					if sql[1].unlimited == 1 then howManyTimes[player] = 0 end
					if howManyTimes[player] == 3 then
						canHornBeUsed[player] = false
					end
				end	
			else
				outputChatBox("Please use /gchorn or /gchorn hornNumber",player,255,0,0)
			end
		end	
	end	
end
addCommandHandler("gchorn",useHorn)

addEventHandler('onMapStarting', root,
function()
	newMap = true
end
)

addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', root,
function(new)
	if (new == 'Running') and (newMap == true) then
		for i,j in ipairs(getElementsByType('player')) do 
			canHornBeUsed[j] = true
			howManyTimes[j] = 0
		end
		newMap = false
	end	
end
)


addEvent('onPlayerBuyUnlimitedHorn', true)
addEventHandler('onPlayerBuyUnlimitedHorn', root,
function()
	local logged = exports.gc:isPlayerLoggedInGC(source)
	if logged then
		local forumid = exports.gc:getPlayerForumID(source)
		forumid = tostring(forumid)
		-- local sql = executeSQLQuery("SELECT forumid, horns, current, unlimited FROM gc_horns WHERE forumid = '"..forumid.."'")
		local query = dbQuery(handlerConnect, "SELECT unlimited FROM gc_horns WHERE forumid = ?", forumid)
		local sql = dbPoll(query,-1)
		if #sql > 0 then
			if sql[1].unlimited == 1 then
				outputChatBox("You already have unlimited horn usage.", source)
				return
			else
				local money = exports.gc:getPlayerGreencoins(source)
				if money >= unlimitedUses then
					-- exports.gc:addPlayerGreencoins(source, -1*unlimitedUses)
					local ok = gcshopBuyItem ( source, unlimitedUses, 'Unlimited horns' )
					if ok then
						-- executeSQLUpdate("gc_horns", "unlimited = 'true'", "forumid = '"..forumid.."'")
						local result = dbExec(handlerConnect, "UPDATE gc_horns SET unlimited=? WHERE forumid=?", 1, forumid)
						outputChatBox("You have bought unlimited horn usage for 5000 GC.", source)
						addToLog ( '"' .. getPlayerName(source) .. '" (' .. tostring(forumid) .. ') bought Unlimited horns ' .. tostring(result))
					end
				else
					outputChatBox("You do not have enough GreenCoins", source)
				end	
			end
		else
			outputChatBox("You have no horns bought.", source)
		end	
	else
		outputChatBox("You are not logged in GreenCoins", source)
	end
end
)

addEvent('onDisableHorn', true)
addEventHandler('onDisableHorn', root,
function()
	local logged = exports.gc:isPlayerLoggedInGC(source)
	if logged then
		local forumid = exports.gc:getPlayerForumID(source)
		forumid = tostring(forumid)
		-- local sql = executeSQLQuery("SELECT forumid, horns, current, unlimited FROM gc_horns WHERE forumid = '"..forumid.."'")
		local query = dbQuery(handlerConnect, "SELECT current, horns FROM gc_horns WHERE forumid = ?", forumid)
		local sql = dbPoll(query,-1)
		if #sql > 0 then
			if sql[1].current == 0 then
				outputChatBox('You\'ve already disabled your horns.', source)
			else
				-- executeSQLUpdate("gc_horns", "current = 'none'", "forumid = '"..forumid.."'")
				local result = dbExec(handlerConnect, "UPDATE gc_horns SET current=? WHERE forumid=?", 0, forumid)
				outputChatBox('Success removing horn', source)
				local allHorns = split(sql[1].horns, string.byte(','))
				triggerClientEvent(source, 'sendHornsData', source, 'none', allHorns)
			end	
		else
			outputChatBox('You have no horns', source)
		end	
	else
		outputChatBox('Not logged in.', source)
	end
end
)

addEvent("onGCShopLogout", true)
addEventHandler("onGCShopLogout", root,
function()
	unbindKey(source, "h", "down", "gchorn")
	triggerClientEvent(source, "hornsLogout", source)
end
)

addEvent("onGCShopLogin", true)
addEventHandler("onGCShopLogin", root,
function()
	bindKey(source, "h", "down", "gchorn")
	triggerClientEvent(source, "hornsLogin", source)
end
)

--for when they join, so the second gridList gets updated.
addEvent('getHornsData', true)
addEventHandler('getHornsData', root,
function()
end
)



addEventHandler('onResourceStart', getResourceRootElement(),
function()
	for i,j in ipairs(getElementsByType('player')) do 
		canHornBeUsed[j] = true
		howManyTimes[j] = 0
		coolOff[j] = true
	end
	-- if not doesTableExist( 'gc_horns') then
		-- executeSQLCreateTable('gc_horns', 'forumid TEXT, horns TEXT, current TEXT, unlimited TEXT')
	-- end
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
	canHornBeUsed[source] = true
	howManyTimes[source] = 0
	coolOff[source] = true
end
)

addEventHandler('onPlayerQuit', root,
function()
	canHornBeUsed[source] = nil
	howManyTimes[source] = nil
	coolOff[source] = nil
	coolOffTimer[source] = nil
end
)

addEvent('onPlayerBuyHorn', true)
addEventHandler('onPlayerBuyHorn', root,
function(horn)
	local logged = exports.gc:isPlayerLoggedInGC(source)
	if logged then
		local forumid = exports.gc:getPlayerForumID(source)
		forumid = tostring(forumid)
		-- local sql = executeSQLQuery("SELECT forumid, horns, current FROM gc_horns WHERE forumid = '"..forumid.."'")
		local query = dbQuery(handlerConnect, "SELECT horns FROM gc_horns WHERE forumid = ?", forumid)
		local sql = dbPoll(query,-1)
		if #sql > 0 then
			local allHorns = split(sql[1].horns, string.byte(','))
			for i,j in ipairs(allHorns) do 
				if j == tostring(horn) then
					triggerClientEvent(source, 'onClientSuccessBuyHorn', source, false)
					return
				end
			end
		end	
		local money = exports.gc:getPlayerGreencoins(source)
		if money >= price then
			-- exports.gc:addPlayerGreencoins(source, -1*price)
			local ok = gcshopBuyItem ( source, price, 'Horn:' .. horn)
			if ok then
				local result
				if #sql == 0 then
					-- executeSQLInsert("gc_horns", "'"..forumid.."', '"..tostring(horn).."', '"..tostring(horn).."', 'false'")
					result = dbExec(handlerConnect, "INSERT INTO gc_horns (forumid,horns, current) VALUES (?,?,?)", forumid, tostring(horn), horn)
				else
					local hornString = sql[1].horns..","..tostring(horn)
					-- executeSQLUpdate("gc_horns", "horns = '"..hornString.."'", "forumid = '"..forumid.."'")
					-- executeSQLUpdate("gc_horns", "current = '"..tostring(horn).."'", "forumid = '"..forumid.."'")
					result = dbExec(handlerConnect, "UPDATE gc_horns SET horns=?, current=? WHERE forumid=?", hornString, horn, forumid)
				end
				triggerClientEvent(source, 'onClientSuccessBuyHorn', source, true, horn)
				addToLog ( '"' .. getPlayerName(source) .. '" (' .. tostring(forumid) .. ') bought horn=' .. tostring(horn) ..  ' ' .. tostring(result))
			end
		else
			triggerClientEvent(source, 'onClientSuccessBuyHorn', source, false, nil)
		end
	else
		triggerClientEvent(source, 'onClientSuccessBuyHorn', source, false)
	end
end
)

addEvent('onPlayerSetHorn', true)
addEventHandler('onPlayerSetHorn', root,
function(horn)
	local logged = exports.gc:isPlayerLoggedInGC(source)
	if logged then
		local forumid = exports.gc:getPlayerForumID(source)
		forumid = tostring(forumid)
		-- local sql = executeSQLQuery("SELECT forumid, horns, current FROM gc_horns WHERE forumid = '"..forumid.."'")
		local query = dbQuery(handlerConnect, "SELECT current FROM gc_horns WHERE forumid = ?", forumid)
		local sql = dbPoll(query,-1)
		if #sql == 0 then
			triggerClientEvent(source, 'onClientSuccessSetHorn', source, false)
			return
		end
		if sql[1].current == horn then	
			triggerClientEvent(source, 'onClientSuccessSetHorn', source, false)
			return
		end
		-- executeSQLUpdate("gc_horns", "current = '"..tostring(horn).."'", "forumid = '"..forumid.."'")
		local result = dbExec(handlerConnect, "UPDATE gc_horns SET current=? WHERE forumid=?", horn, forumid)
		triggerClientEvent(source, 'onClientSuccessSetHorn', source, true)
	else
		triggerClientEvent(source, 'onClientSuccessSetHorn', source, false)
	end
end
)


addEvent('getHornsData', true)
addEventHandler('getHornsData', root,
function()
	local logged = exports.gc:isPlayerLoggedInGC(source)
	if logged then
		local forumid = exports.gc:getPlayerForumID(source)
		forumid = tostring(forumid)
		-- local sql = executeSQLQuery("SELECT forumid, horns, current FROM gc_horns WHERE forumid = '"..forumid.."'")
		local query = dbQuery(handlerConnect, "SELECT horns, current FROM gc_horns WHERE forumid = ?", forumid)
		local sql = dbPoll(query,-1)
		if #sql > 0 then
			local current = tonumber(sql[1].current) ~= 0 and tostring(sql[1].current) or "none"
			local allHorns = split(sql[1].horns, string.byte(','))
			triggerClientEvent(source, 'sendHornsData', source, current, allHorns)
		end
	end	
end
)
