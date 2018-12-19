gcSkins = {}
local price = 1500

function handleBuying(player, id)
	-- exports.gc:addPlayerGreencoins(player, (-1*price))
	local ok = gcshopBuyItem ( source, price, 'Skin:' .. id)
	if ok then
		setTimer(setElementModel, 1000, 1, player, tonumber(id))
		triggerClientEvent(source, "onServerSkinData", source, true)
	end
	return ok
end


function setRandomSkinFromExistent(player, skin, forumid, skins)
	if handlerConnect then
		if getElementModel(player) ~= tonumber(skin) then
			setTimer(setElementModel,1000,1, player, tonumber(skin))
		end
		local cmd = "UPDATE custom_skins SET skin = ? WHERE forumid = ?"
		dbExec(handlerConnect, cmd, skins, forumid)
		cmd = "UPDATE custom_skins SET setting = ? WHERE forumid = ?"
		dbExec(handlerConnect, cmd, skin, forumid)
	end	
end

addEvent('onPlayerChooseSkin', true)
addEventHandler('onPlayerChooseSkin', root,
function(skinID)
	if not handlerConnect then return end
	local isLogged = exports.gc:isPlayerLoggedInGC(source)
	if not isLogged then 
		triggerClientEvent(source, "onServerSkinData", source, false)
		return
	end
	local money = exports.gc:getPlayerGreencoins(source)
	if money < price then
		triggerClientEvent(source, "onServerSkinData",source, false)
		return
	end
	local ok = handleBuying(source, skinID)
	if not ok then return end
	local forumid = exports.gc:getPlayerForumID(source)
	forumid = tostring(forumid)
	local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
	local query = dbQuery(handlerConnect, cmd, forumid)
	local sql = dbPoll(query, -1)
	local result
	if #sql == 0 then
		cmd = "INSERT INTO custom_skins VALUES(?, ?, ?)"
		result = dbExec(handlerConnect, cmd, forumid, tostring(skinID), tostring(skinID))
	else
		local playerSkins = split(sql[1].skin, string.byte(','))
		for i,j in ipairs(playerSkins) do 
			if j == tostring(skinID) then
				triggerClientEvent(source, "onServerSkinData",source, false)
				return
			end
		end
		local newSkins = sql[1].skin..","..tostring(skinID)
		cmd = "UPDATE custom_skins SET skin = ? WHERE forumid = ?"
		result = dbExec(handlerConnect, cmd, newSkins, forumid)
		cmd = "UPDATE custom_skins SET setting = ? WHERE forumid = ?"
		dbExec(handlerConnect, cmd, tostring(skinID), forumid)
	end
	addToLog ( '"' .. getPlayerName(source) .. '" (' .. tostring(forumid) .. ') bought skin=' .. tostring(skinID) ..  ' ' .. tostring(result))
end
)

addEvent('onPlayerSellSkin', true)
addEventHandler('onPlayerSellSkin', root,
function(skinID)
	if not hasObjectPermissionTo(source, "command.ban", false) then -- Admin exclusive function for testing purposes
		outputChatBox("This is currently only an admin function until we test it and make sure it works. Sorry.", source, 255, 0, 0)
		return 
	end 
	
	if not handlerConnect then return end
	local isLogged = exports.gc:isPlayerLoggedInGC(source)
	if not isLogged then 
		triggerClientEvent(source, "onServerSuccessfulSkinSell", source, false)
		return
	end
	
	local forumid = exports.gc:getPlayerForumID(source)
	forumid = tostring(forumid)
	local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
	local query = dbQuery(handlerConnect, cmd, forumid)
	local sql = dbPoll(query, -1)
	
	local hasSkin = false
	local newSkins = ""
	
	if #sql == 0 then
		triggerClientEvent(source, "onServerSuccessfulSkinSell", source, false)
		return
	else
		local playerSkins = split(sql[1].skin, string.byte(','))
		for i,j in ipairs(playerSkins) do 
			if j == tostring(skinID) then
				hasSkin = true
			else
				if newSkins == "" then
					newSkins = j
				else
					newSkins = newSkins .. "," .. j
				end
			end
		end
		
		if not hasSkin then
			triggerClientEvent(source, "onServerSuccessfulSkinSell", source, false)
			return
		end
				
		local result
		local returnedGC
		
		if string.len(newSkins) == 0 then -- if the player has no skins left
			cmd = "DELETE FROM custom_skins WHERE forumid = ?"
			result = dbExec(handlerConnect, cmd, forumid)
			
			returnedGC = exports.gc:addPlayerGreencoins(source, price / 2)
			
			if getResourceFromName("snow") and getResourceState(getResourceFromName("snow")) == "running" then
				setTimer(setElementModel, 1000, 1, source, 1) -- set back to skin id 1 which is the default skin for snow
			else
				setTimer(setElementModel, 1000, 1, source, 0) -- set back to cj
			end
			
			triggerClientEvent(source, "onServerSuccessfulSkinSell", source, true)
		else
			
			local cmd = "UPDATE custom_skins SET skin = ? WHERE forumid = ?"
			result = dbExec(handlerConnect, cmd, newSkins, forumid)
			
			local skins = split(newSkins, string.byte(','))
			cmd = "UPDATE custom_skins SET setting = ? WHERE forumid = ?"
			dbExec(handlerConnect, cmd, skins[1], forumid)
			
			setTimer(setElementModel, 1000, 1, source, tonumber(skins[1])) -- set his skin
			
			returnedGC = exports.gc:addPlayerGreencoins(source, price / 2)
			
			triggerClientEvent(source, "onServerSuccessfulSkinSell", source, true)
		
		end
		
		addToLog ( '"' .. getPlayerName(source) .. '" (' .. tostring(forumid) .. ') sold skin=' .. tostring(skinID) ..  ' ' .. tostring(result) .. ' has script returned GCs: ' .. tostring(returnedGC))
	end
	
	
end
)


addEvent('getSkinPurchases', true)
addEventHandler('getSkinPurchases', root,
function()
	if not handlerConnect then return end
	if getResourceFromName('gc') and getResourceState(getResourceFromName('gc')) == "running" and exports.gc:isPlayerLoggedInGC(source) then
		local forumid = exports.gc:getPlayerForumID(source)
		forumid = tostring(forumid)
		local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
		local query = dbQuery(handlerConnect, cmd, forumid)
		local sql = dbPoll(query, -1)
		if #sql == 0 then return end
		triggerClientEvent(source, "sendPlayerSkinPurchases", source, sql[1].skin, sql[1].setting)
		if sql[1].setting == "none" then     
			return
		end	
		if sql[1].setting == nil then 
			local skins = split(sql[1].skin, string.byte(','))
			setRandomSkinFromExistent(source, skins[1], forumid, sql[1].skin)
			return
		end
		if getElementModel(source) ~= tonumber(sql[1].setting) then
			setTimer(setElementModel, 1000, 1, source, tonumber(sql[1].setting))
		end	
	end
end
)

addEvent('onPlayerUseSkin', true)
addEventHandler('onPlayerUseSkin', root,
function(skin)
	if not handlerConnect then return end
	if not exports.gc:isPlayerLoggedInGC(source) then outputChatBox('You need to be logged into GreenCoins', source, 255, 0, 0) return end
	local forumid = exports.gc:getPlayerForumID(source)
	forumid = tostring(forumid)
	local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
	local query = dbQuery(handlerConnect, cmd, forumid)
	local sql = dbPoll(query, -1)
	if #sql == 0 then
		outputChatBox("You do not own this skin.", source)
	else
		local skins = split(sql[1].skin, string.byte(','))
		for i,j in ipairs(skins) do 
			if j == skin then
				if tonumber(sql[1].setting) ~= tonumber(skin) then
					setElementModel(source, tonumber(skin))
					outputChatBox('Success in changing skin.', source, 255, 0, 0)
					cmd = "UPDATE custom_skins SET skin = ? WHERE forumid = ?"
					dbExec(handlerConnect, cmd, sql[1].skin, forumid)
					cmd = "UPDATE custom_skins SET setting = ? WHERE forumid = ?"
					dbExec(handlerConnect, cmd, skin, forumid)
					return
				end	
				outputChatBox('You already have this skin set', source, 255, 0, 0)
				return
			end	
		end	
		outputChatBox("You do not own this skin.", source)
	end	
end
)



addEventHandler('onPlayerSpawn', root,
function()
	if not handlerConnect then return end
	if getResourceFromName('gc') and getResourceState(getResourceFromName('gc')) == "running" then
		if exports.gc and exports.gc:isPlayerLoggedInGC(source) then
			local forumid = exports.gc:getPlayerForumID(source)
			forumid = tostring(forumid)
			local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
			local query = dbQuery(handlerConnect, cmd, forumid)
			local sql = dbPoll(query, -1)
			if #sql > 0 then
				if sql[1].setting == "none" then     
					return
				end	
				if sql[1].setting == nil then 
					local skins = split(sql[1].skin, string.byte(','))
					setRandomSkinFromExistent(source, skins[1], forumid, sql[1].skin)
					return
				end
				if getElementModel(source) ~= tonumber(sql[1].setting) then
					if not tonumber(sql[1].setting) then
						outputDebugString('Skin applied to '..getPlayerName(source).. " forum id: "..forumid.. " skin id: "..tostring(sql[1].setting))
					end
					setTimer(setElementModel, 1000, 1, source, tonumber(sql[1].setting))
				end	
			end	
		end	
	end
end
)

addEvent('disableSkins', true)
addEventHandler('disableSkins', root,
function()
	if not handlerConnect then return end
	if not exports.gc:isPlayerLoggedInGC(source) then outputChatBox('You need to be logged into GreenCoins', source, 255, 0, 0) return end
	local forumid = exports.gc:getPlayerForumID(source)
	forumid = tostring(forumid)
	local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
	local query = dbQuery(handlerConnect, cmd, forumid)
	local sql = dbPoll(query, -1)
	if #sql > 0 then
		local option = "none"
		cmd = "UPDATE custom_skins SET setting = ? WHERE forumid = ?"
		dbExec(handlerConnect, cmd, option, forumid)
		outputChatBox('Success in removing skin. Changes will be seen nextmap', source, 255, 0, 0)
	end
end
)

addEvent("onGCShopLogout", true)
addEventHandler("onGCShopLogout", root,
function()
	triggerClientEvent(source, "skinsLogout", source)
end
)

addEvent("onGCShopLogin", true)
addEventHandler("onGCShopLogin", root,
function()
	triggerClientEvent(source, "skinsLogin", source)
end
)


