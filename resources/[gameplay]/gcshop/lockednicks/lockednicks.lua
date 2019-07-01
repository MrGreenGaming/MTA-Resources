function getLockedNicks(forumID)
	if not handlerConnect then return end
	if getElementType(source) ~= "player" then return end
	if not forumID then forumID = exports.gc:getPlayerForumID(source) end
	local theID = exports.gc:getPlayerGreencoinsID(source)

	if not theID then return end
	local player = source
	-- Get all locked nicks
	local nameQuery = dbQuery(
		function(nameQuery) 
			local nameResult = dbPoll(nameQuery,0) 

			local theNames = {}
			if #nameResult > 0 then
				for _,t in ipairs(nameResult) do
					table.insert(theNames,t.pNick)
				end
			end

			-- Get amount of locknick slots
			dbQuery(
				function(amountQuery) 
					local amountResult = dbPoll(amountQuery,0)

					local locknickAmount = 3
					if #amountResult == 0 then
						-- Insert player into amount table db

						dbExec(handlerConnect, "INSERT INTO gc_nickprotection_amount (forumID) VALUES (?)", tostring(forumID))
					elseif #amountResult > 0 then
						locknickAmount = tonumber(amountResult[1].amount)
					end

					triggerClientEvent(player,"serverSendLockedNickInfo",player,theNames,locknickAmount)
				end, 
			handlerConnect,"SELECT amount FROM gc_nickprotection_amount WHERE forumID=?",forumID)
		end,
	handlerConnect,"SELECT pNick FROM gc_nickprotection WHERE forumID=?",theID)
end
addEventHandler("onGCShopLogin",root,getLockedNicks)
addEvent("clientRefreshNicks",true)
addEventHandler("clientRefreshNicks",root,getLockedNicks)

function handleAddRemoveNicks(nick,addRemoveBool)
	-- addRemoveBool true = add
	local theID = exports.gc:getPlayerGreencoinsID(client)
	if not theID then outputDebugString("Can't get player ID "..getPlayerName(client)) return end

	if addRemoveBool == true then -- ADD

		local action = protectNick(theID, __safeString(nick))
		if type(action) == "string" then 
			outputChatBox(action, client, 255, 0, 0)			
		elseif action == false then
			outputChatBox('Failed to lock '..nick..'.', client, 255, 0, 0)
		elseif action == true then
			outputChatBox(nick..' has succesfully been added to your locked nicks and is now protected.', client, 0, 255, 0)
			triggerClientEvent(client,"onServerSendLocknickResults",client,nick,"add")
		end


	elseif addRemoveBool == false then -- REMOVE
		local action = removeNick(theID,nick)

		if action then 
			outputChatBox(nick..' has succesfully been removed from your locked nicks.', client, 0, 255, 0)
			triggerClientEvent(client,"onServerSendLocknickResults",client,nick,"remove")
		else
			outputChatBox('Failed to unlock '..nick..'.', client, 255, 0, 0)
		end
	end
end
addEvent("clientNickLockAction",true)
addEventHandler("clientNickLockAction",root,handleAddRemoveNicks)


function __safeString(playerName)
	playerName = string.gsub(playerName, "?", "")
	playerName = string.gsub(playerName, "'", "")
	playerName = string.gsub (playerName, "#%x%x%x%x%x%x", "")
	return playerName
end

function isNickProtected(nick)
	local cmd = ''
	local query 
	if handlerConnect then
		cmd = "SELECT pNick, forumId FROM gc_nickprotection WHERE LOWER(pNick) = ?"
		query = dbQuery(handlerConnect, cmd, string.lower(nick))
		if not query then return false end
		local sql = dbPoll(query, -1)
		if not sql then return false end
		if #sql == 0 then 
			return false
		else
			return true
		end
	end	
end

function protectNick(id, name)
	if isNickProtected(name) then
		return "Nickname is already locked"
	end
	--local sql = executeSQLQuery("SELECT pNick, accountID FROM gcProtectedNames WHERE accountID = '"..id.."'")
	local cmd = ''
	local query 
	if handlerConnect then
		cmd = "SELECT pNick, forumId FROM gc_nickprotection WHERE forumId = ?"
		query = dbQuery(handlerConnect, cmd, id)

		if not query then return false end
		local sql = dbPoll(query, -1)
		if not sql then return false end
		

		cmd = "INSERT INTO gc_nickprotection VALUES(?,?)"
		dbExec(handlerConnect, cmd, name, id)
		return true	

	end	
end

function removeNick(id,nick)

	if not id or not nick then return false end

	local id = tostring(id)
	local cmd = ''
	local query 
	if handlerConnect then
		cmd = "SELECT pNick, forumId FROM gc_nickprotection WHERE pNick = ? AND forumId = ?"
		query = dbQuery(handlerConnect, cmd, nick,id)
		if not query then return false end
		local sql = dbPoll(query, -1)
		-- if not sql then return false end

		if #sql > 0 then

			cmd = "DELETE FROM gc_nickprotection WHERE pNick = ? AND forumId = ?"
			dbExec(handlerConnect, cmd, nick,id)
			return true	
		end
	end

	return false
end


local pLockSlotPrice = 750
function PlayerBuyLockedNickSlot()
	local player = client
	if getElementType(player) ~= "player" then return end
	if not exports.gc:isPlayerLoggedInGC(player) then outputChatBox("Please log in to GC before buying",player,255,0,0) return end

	local gc = exports.gc:getPlayerGreencoins(player)
	if gc > pLockSlotPrice then

		local forumID = exports.gc:getPlayerForumID(player)
		if forumID then

			local exec = dbExec(handlerConnect, "UPDATE gc_nickprotection_amount SET amount = amount + 1 WHERE forumID=?", tostring(forumID))
			if exec then
				if not hasObjectPermissionTo(player,"function.banPlayer",false) then
					exports.gc:addPlayerGreencoins(player,-pLockSlotPrice)
				end

				outputChatBox("You have succesfully bought a locknick slot",player,0,255,0)
				triggerClientEvent(client,"onPlayerLockNickSlotPurchase",client)
			end
		end
	else
		outputChatBox("Not enough greencoins!",player,255,0,0)
	end
end
addEvent("onPlayerBuyLockedNickSlot",true)
addEventHandler("onPlayerBuyLockedNickSlot",root,PlayerBuyLockedNickSlot)

