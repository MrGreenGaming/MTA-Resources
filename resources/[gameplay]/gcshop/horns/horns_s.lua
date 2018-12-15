local price = 2000
local unlimitedUses = 5000
local canHornBeUsed = {}
local howManyTimes = {}
local newMap = nil
local coolOffTimer = {}
local coolOff = {}

local keyTable = { "mouse1", "mouse2", "mouse3", "mouse4", "mouse5", "mouse_wheel_up", "mouse_wheel_down", "arrow_l", "arrow_u",
 "arrow_r", "arrow_d", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
 "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "num_0", "num_1", "num_2", "num_3", "num_4", "num_5",
 "num_6", "num_7", "num_8", "num_9", "num_mul", "num_add", "num_sep", "num_sub", "num_div", "num_dec", "num_enter", "F1", "F2", "F3", "F4", "F5",
 "F6", "F7", "F8", "F9", "F10", "F11", "F12", "escape", "backspace", "tab", "lalt", "ralt", "enter", "space", "pgup", "pgdn", "end", "home",
 "insert", "delete", "lshift", "rshift", "lctrl", "rctrl", "[", "]", "pause", "capslock", "scroll", ";", ",", "-", ".", "/", "#", "\\", "=" }
 
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

addEvent("onGCShopLogout", true)
addEventHandler("onGCShopLogout", root,
function()
	triggerClientEvent(source, "hornsLogout", source)
end
)

addEvent("onGCShopLogin", true)
addEventHandler("onGCShopLogin", root,
function(forumid)
	local query = dbQuery(handlerConnect, "SELECT unlimited FROM gc_horns WHERE forumid = ?", forumid)
	local sql = dbPoll(query,-1)
	local unlimited = false
	if #sql >= 1 then
		if sql[1].unlimited == 1 then unlimited = true else unlimited = false end	
	end
	triggerClientEvent(source, "hornsLogin", source, unlimited, forumid)
end
)

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

addEventHandler('onResourceStart', resourceRoot,
function()
	for i,j in ipairs(getElementsByType('player')) do 
		canHornBeUsed[j] = true
		howManyTimes[j] = 0
		coolOff[j] = true
	end
end
)

function useHorn(player, arg1, arg2, hornID)
	if (canHornBeUsed[player]) and (coolOff[player] == true) and (isPedInVehicle(player)) and (not isVehicleBlown(getPedOccupiedVehicle(player))) and (getElementHealth(getPedOccupiedVehicle(player)) > 250) and (getElementData(player, "state") == "alive") then
		local logged = exports.gc:isPlayerLoggedInGC(player)
		if logged then
			local forumid = exports.gc:getPlayerForumID(player)
			forumid = tostring(forumid)
			if tonumber(hornID or arg2) then
				local query = dbQuery(handlerConnect, "SELECT horns, unlimited FROM gc_horns WHERE forumid = ?", forumid)
				local sql = dbPoll(query,-1)
				if #sql > 0 then
					local allHorns = split(sql[1].horns, string.byte(','))
					
					local useHorn = false
					for i,j in ipairs(allHorns) do
						if tonumber(j) == tonumber(hornID or arg2) then
							useHorn = true
							break
						end
					end

					if not useHorn then outputChatBox("Please buy the horn (".. tostring(hornID or arg2) ..") first before using it",player,255,0,0) return end

					local car = getPedOccupiedVehicle(player)
					coolOffTimer[player] = setTimer(function(player) coolOff[player] = true end, 10000, 1, player)
					triggerClientEvent("onPlayerUsingHorn", player, hornID or arg2, car)
					triggerEvent("onPlayerUsingHorn_s", player, hornID or arg2, car)
					coolOff[player] = false
					howManyTimes[player] = howManyTimes[player] + 1
					if sql[1].unlimited == 1 then howManyTimes[player] = 0 end
					if howManyTimes[player] == 3 then
						canHornBeUsed[player] = false
					end
				end	
			else
				outputChatBox("Something went wrong",player,255,0,0)
			end
		end	
	end	
end
addCommandHandler("gchorn",useHorn)

addEvent("bindHorn", true)
addEventHandler("bindHorn", root, function(key, hornID, hornName)
	if not isKeyBound(client, key, "down", useHorn) then
		bindKey(client, key, "down", useHorn, hornID)
	end
end
)

addEvent("unbindHorn", true)
addEventHandler("unbindHorn", root, function(key)
	unbindKey(client, key, "down", useHorn)
end
)

addEvent("unbindAllHorns", true)
addEventHandler("unbindAllHorns", root, function()
	for i=1, #keyTable do
		unbindKey(client, keyTable[i], "down", useHorn)
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
		local query = dbQuery(handlerConnect, "SELECT unlimited FROM gc_horns WHERE forumid = ?", forumid)
		local sql = dbPoll(query,-1)
		if #sql > 0 then
			if sql[1].unlimited == 1 then
				outputChatBox("You already have unlimited horn usage.", source)
				return
			else
				local money = exports.gc:getPlayerGreencoins(source)
				if money >= unlimitedUses then
					local ok = gcshopBuyItem ( source, unlimitedUses, 'Unlimited horns' )
					if ok then
						local result = dbExec(handlerConnect, "UPDATE gc_horns SET unlimited=? WHERE forumid=?", 1, forumid)
						outputChatBox("You have bought unlimited horn usage for 5000 GC.", source)
						triggerClientEvent(source, 'onClientSuccessBuyUnlimitedUsage', source, true)
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

addEvent('onPlayerSellHorn', true)
addEventHandler('onPlayerSellHorn', root,
function(horn)
	local logged = exports.gc:isPlayerLoggedInGC(source)
	if not logged then triggerClientEvent(source, 'onClientSuccessSellHorn', source, false) end
	
	--player is logged in
	local forumid = exports.gc:getPlayerForumID(source)
	forumid = tostring(forumid)
	
	local query = dbQuery(handlerConnect, "SELECT horns FROM gc_horns WHERE forumid = ?", forumid)
	local sql = dbPoll(query,-1)
	if #sql == 0 then triggerClientEvent(source, 'onClientSuccessSellHorn', source, false) end
	
	--There is a row
	local hornString = ""
	local hasTheHorn = false
	local allHorns = split(sql[1].horns, string.byte(','))
	for i,j in ipairs(allHorns) do
		if j == tostring(horn) then
			hasTheHorn = true
		else 
			hornString = hornString .. "," .. j
		end
	end
	
	if not hasTheHorn or hasTheHorn == false then triggerClientEvent(source, 'onClientSuccessSellHorn', source, false) end
	
	--Player has the selected horn
	result = dbExec(handlerConnect, "UPDATE gc_horns SET horns=? WHERE forumid=?", hornString, forumid)
	exports.gc:addPlayerGreencoins(source, price / 2)
	triggerClientEvent(source, 'onClientSuccessSellHorn', source, true)
end)


addEvent('onPlayerBuyHorn', true)
addEventHandler('onPlayerBuyHorn', root,
function(horn)
	local logged = exports.gc:isPlayerLoggedInGC(source)
	if logged then
		local forumid = exports.gc:getPlayerForumID(source)
		forumid = tostring(forumid)
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
			local ok = gcshopBuyItem ( source, price, 'Horn:' .. horn)
			if ok then
				local result
				if #sql == 0 then
					result = dbExec(handlerConnect, "INSERT INTO gc_horns (forumid,horns) VALUES (?,?)", forumid, tostring(horn))
				else
					local hornString = sql[1].horns..","..tostring(horn)
					result = dbExec(handlerConnect, "UPDATE gc_horns SET horns=? WHERE forumid=?", hornString, forumid)
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


addEvent('getHornsData', true)
addEventHandler('getHornsData', root,
function()
	local logged = exports.gc:isPlayerLoggedInGC(source)
	if logged then
		local forumid = exports.gc:getPlayerForumID(source)
		forumid = tostring(forumid)
		local query = dbQuery(handlerConnect, "SELECT horns FROM gc_horns WHERE forumid = ?", forumid)
		local sql = dbPoll(query,-1)
		if #sql > 0 then
			local allHorns = split(sql[1].horns, string.byte(','))
			triggerClientEvent(source, 'sendHornsData', source, allHorns)
		end
	end	
end
)

function playerUsingHorn_s(horn,car)
	if getElementData(source, "state") == "alive" and getPedOccupiedVehicle(source) then
		local gamemode = exports.race:getRaceMode()
		--outputDebugString("Player: " .. getPlayerNametagText(source) .. " used horn " .. horn .. " in gamemode " .. gamemode, 0)
		
		if tonumber(horn) == 389 and not (gamemode == "Capture the flag") then -- Wololo horn from Age of Empires 2. Changes target's vehicle color to the color of the source's vehicle. Adds opponent to source's team for 5 minutes.
			local c = {}
			local d = {} -- delta
			local s = {} -- source
			local t = {} -- target
			local dist = 15
			local dis = {dist, false}
			
			local p = getElementsByType("player")
			local dim = getElementData(source, "dim")
			c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12] = getVehicleColor(getPedOccupiedVehicle(source), true)
			s[1],s[2],s[3] = getElementPosition(getPedOccupiedVehicle(source))
			
			for a,b in ipairs(p) do
				if getElementData(b, "state") == "alive" and getElementData(b, "dim") == dim and getPedOccupiedVehicle(b) and not (b == source) then
					t[1],t[2],t[3] = getElementPosition(getPedOccupiedVehicle(b))
					d[1] = s[1] - t[1] -- pythagoras
					d[2] = s[2] - t[2]
					d[3] = s[3] - t[3]
					local py = math.pow ( math.pow( math.pow(d[1],2) + math.pow(d[2],2) , 0.5) + math.pow(d[3],2) , 0.5)
					
					if py < dis[1] then
						dis[1] = py
						dis[2] = b
					end
				end
			end
			
			if dis[1] < dist and getPedOccupiedVehicle(dis[2]) and getElementData(dis[2], "state") == "alive" then
				local ct = {}
				ct[1], ct[2], ct[3], ct[4] = getVehicleColor(getPedOccupiedVehicle(dis[2]))
				if ct[1] == 1 and ct[2] == 1 and ct[3] == 0 and ct[4] == 0 then return end -- disabled for paintjobs
				setVehicleColor(getPedOccupiedVehicle(dis[2]), c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12])
			end
		end
	end	
end
addEvent("onPlayerUsingHorn_s", true)
addEventHandler("onPlayerUsingHorn_s", root,playerUsingHorn_s)

