gcSkins = {}
local price = 1500

function handleBuying(player, id)
	-- exports.gc:addPlayerGreencoins(player, (-1*price))
	local ok = gcshopBuyItem ( player, price, 'Skin:' .. id)
	if ok then
		setTimer(setPlayerGcSkin, 1000, 1, player, tonumber(id))
		triggerClientEvent(player, "onServerSkinData", player, true)
	end
	return ok
end


function setRandomSkinFromExistent(player, skin, forumid, skins)
	if handlerConnect then
		if getElementModel(player) ~= tonumber(skin) then
			setTimer(setPlayerGcSkin,1000,1, player, tonumber(skin))
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

	local forumid = exports.gc:getPlayerForumID(source)
	forumid = tostring(forumid)
	local player = source
	local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
	dbQuery(
		function(query)
			local sql = dbPoll(query, 0)
			local result
			if #sql == 0 then
				if handleBuying(player, skinID) then
					cmd = "INSERT INTO custom_skins VALUES(?, ?, ?)"
					result = dbExec(handlerConnect, cmd, forumid, tostring(skinID), tostring(skinID))
					addToLog ( '"' .. getPlayerName(player) .. '" (' .. tostring(forumid) .. ') bought skin=' .. tostring(skinID) ..  ' ' .. tostring(result))
					triggerClientEvent(player, "onServerSkinData",player, true)
				else
					triggerClientEvent(player, "onServerSkinData",player, false)
				end
			else
				local playerSkins = split(sql[1].skin, string.byte(','))
				for i,j in ipairs(playerSkins) do
					if j == tostring(skinID) then
						triggerClientEvent(player, "onServerSkinData",player, false)
						return
					end
				end
				if handleBuying(player, skinID) then
					local newSkins = sql[1].skin..","..tostring(skinID)
					cmd = "UPDATE custom_skins SET skin = ? WHERE forumid = ?"
					result = dbExec(handlerConnect, cmd, newSkins, forumid)
					cmd = "UPDATE custom_skins SET setting = ? WHERE forumid = ?"
					dbExec(handlerConnect, cmd, tostring(skinID), forumid)
					addToLog ( '"' .. getPlayerName(player) .. '" (' .. tostring(forumid) .. ') bought skin=' .. tostring(skinID) ..  ' ' .. tostring(result))
					triggerClientEvent(player, "onServerSkinData",player, true)
				else
					triggerClientEvent(player, "onServerSkinData",player, false)
				end
			end
		end
	, handlerConnect, cmd, forumid)
end
)

addEvent('onPlayerSellSkin', true)
addEventHandler('onPlayerSellSkin', root,
function(skinID)
	if not handlerConnect then return end
	local isLogged = exports.gc:isPlayerLoggedInGC(source)
	if not isLogged then
		triggerClientEvent(source, "onServerSuccessfulSkinSell", source, false)
		return
	end
	local player = source
	local forumid = exports.gc:getPlayerForumID(source)
	forumid = tostring(forumid)
	local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
	dbQuery(
		function(query)
			local sql = dbPoll(query, 0)

			local hasSkin = false
			local newSkins = ""

			if #sql == 0 then
				triggerClientEvent(player, "onServerSuccessfulSkinSell", player, false)
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
					triggerClientEvent(player, "onServerSuccessfulSkinSell", player, false)
					return
				end

				local result
				local returnedGC

				if string.len(newSkins) == 0 then -- if the player has no skins left
					cmd = "DELETE FROM custom_skins WHERE forumid = ?"
					result = dbExec(handlerConnect, cmd, forumid)

					returnedGC = exports.gc:addPlayerGreencoins(player, price / 2)

					if getResourceFromName("snow") and getResourceState(getResourceFromName("snow")) == "running" then
						setTimer(setPlayerGcSkin, 1000, 1, player, 1) -- set back to skin id 1 which is the default skin for snow
					else
						setTimer(setPlayerGcSkin, 1000, 1, player, 0) -- set back to cj
					end

					triggerClientEvent(player, "onServerSuccessfulSkinSell", player, true)
				else

					local cmd = "UPDATE custom_skins SET skin = ? WHERE forumid = ?"
					result = dbExec(handlerConnect, cmd, newSkins, forumid)

					local skins = split(newSkins, string.byte(','))
					cmd = "UPDATE custom_skins SET setting = ? WHERE forumid = ?"
					dbExec(handlerConnect, cmd, skins[1], forumid)

					setTimer(setPlayerGcSkin, 1000, 1, player, tonumber(skins[1])) -- set his skin

					returnedGC = exports.gc:addPlayerGreencoins(player, price / 2)

					triggerClientEvent(player, "onServerSuccessfulSkinSell", player, true)

				end

				addToLog ( '"' .. getPlayerName(player) .. '" (' .. tostring(forumid) .. ') sold skin=' .. tostring(skinID) ..  ' ' .. tostring(result) .. ' has script returned GCs: ' .. tostring(returnedGC))
			end
		end,
	handlerConnect, cmd, forumid)
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
		local player = source
		dbQuery(
			function(query)
				local sql = dbPoll(query, 0)
				if #sql == 0 then
					triggerClientEvent(player, "sendPlayerSkinPurchases", player, false, false)
					return
				end
				triggerClientEvent(player, "sendPlayerSkinPurchases", player, sql[1].skin, sql[1].setting)
				if sql[1].setting == "none" then
					return
				end
				if sql[1].setting == nil then
					local skins = split(sql[1].skin, string.byte(','))
					setRandomSkinFromExistent(player, skins[1], forumid, sql[1].skin)
					return
				end
				if getElementModel(player) ~= tonumber(sql[1].setting) then
					setTimer(setPlayerGcSkin, 1000, 1, player, tonumber(sql[1].setting))
				end
			end,
		handlerConnect, cmd, forumid)
	end
end
)

addEvent('onPlayerUseSkin', true)
addEventHandler('onPlayerUseSkin', root,
function(skin)
	if not handlerConnect then return end
	if not exports.gc:isPlayerLoggedInGC(source) then outputChatBox(_.For(source, 'You are not logged in'), source, 255, 0, 0) return end
	local forumid = exports.gc:getPlayerForumID(source)
	forumid = tostring(forumid)
	local player = source
	local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
	dbQuery(
		function(query)
			local sql = dbPoll(query, 0)
			if #sql == 0 then
				outputChatBox(_.For(player, "You do not own this skin."), player)
			else
				local skins = split(sql[1].skin, string.byte(','))
				for i,j in ipairs(skins) do
					if j == skin then
						if tonumber(sql[1].setting) ~= tonumber(skin) then
							setPlayerGcSkin(player, tonumber(skin))
							outputChatBox(_.For(player, 'Success in changing skin.'), player, 255, 0, 0)
							cmd = "UPDATE custom_skins SET skin = ? WHERE forumid = ?"
							dbExec(handlerConnect, cmd, sql[1].skin, forumid)
							cmd = "UPDATE custom_skins SET setting = ? WHERE forumid = ?"
							dbExec(handlerConnect, cmd, skin, forumid)
							return
						end
						outputChatBox(_.For(player, 'You already have this skin set'), player, 255, 0, 0)
						return
					end
				end
				outputChatBox(_.For(player, "You do not own this skin."), player)
			end
		end,
	handlerConnect, cmd, forumid)
end
)



addEventHandler('onPlayerSpawn', root,
function()
	if not handlerConnect then return end
	if getResourceFromName('gc') and getResourceState(getResourceFromName('gc')) == "running" then
		if exports.gc and exports.gc:isPlayerLoggedInGC(source) then
			local forumid = exports.gc:getPlayerForumID(source)
			forumid = tostring(forumid)
			local player = source
			local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
			dbQuery(
				function(query)
					local sql = dbPoll(query, 0)
					if #sql > 0 then
						if sql[1].setting == "none" then
							return
						end
						if sql[1].setting == nil then
							local skins = split(sql[1].skin, string.byte(','))
							setRandomSkinFromExistent(player, skins[1], forumid, sql[1].skin)
							return
						end
						if getElementModel(player) ~= tonumber(sql[1].setting) then
							if not tonumber(sql[1].setting) then
								outputDebugString('Skin applied to '..getPlayerName(player).. " forum id: "..forumid.. " skin id: "..tostring(sql[1].setting))
							end
							setTimer(setPlayerGcSkin, 1000, 1, player, tonumber(sql[1].setting))
						end
					end
				end,
			handlerConnect, cmd, forumid)
		end
	end
end
)

addEvent('disableSkins', true)
addEventHandler('disableSkins', root,
function()
	if not handlerConnect then return end
	if not exports.gc:isPlayerLoggedInGC(source) then outputChatBox(_.For(source, 'You are not logged in'), source, 255, 0, 0) return end
	local forumid = exports.gc:getPlayerForumID(source)
	forumid = tostring(forumid)
	local cmd = "SELECT forumid, skin, setting FROM custom_skins WHERE forumid = ? LIMIT 1"
	local player = source
	dbQuery(
		function(query)
			local sql = dbPoll(query, 0)
			if #sql > 0 then
				local option = "none"
				cmd = "UPDATE custom_skins SET setting = ? WHERE forumid = ?"
				dbExec(handlerConnect, cmd, option, forumid)
				outputChatBox(_.For(player, 'Success in removing skin. Changes will be seen nextmap'), player, 255, 0, 0)
			end
		end,
	handlerConnect, cmd, forumid)
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


function setPlayerGcSkin(player, id)
	-- Do not change skin when a vip skin is active
	if getElementData(player, "vip.skin") then return false end
	return setElementModel( player, id )

end
