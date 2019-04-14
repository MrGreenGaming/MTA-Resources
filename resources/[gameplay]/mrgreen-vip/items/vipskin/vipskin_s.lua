-- Reserved skin ID's for VIP skin. If more are needed, please check unbought GC shop skins via database and remove them from there
-- Do not forget to change client side too.
local playerSkins = {
	-- [player] = skinid
}

local skinIds = {
	[1] = 220,
	[2] = 25,
	[3] = 66,
	[4] = 56,
	[5] = 226,
	[6] = 221,
	[7] = 254,
	[8] = 16,
	[9] = 235,
	[10] = 186
}
function setVipSkin(player, id)

	if not player or not isElement(player) or getElementType( player ) ~= "player" then return end

	if id == false then

		-- Remove vip skin
		removeElementData( player, 'vip.skin' )
		setElementModel( player, 0 )
		if playerSkins[player] then playerSkins[player] = nil end

	elseif tonumber(id) and skinIds[id] then
		-- set Vip skin
		if not playerSkins[player] or playerSkins[player] ~= skinIds[id] then
			playerSkins[player] = skinIds[id]
		end
		setElementData( player, 'vip.skin', skinIds[id] )
		setElementModel(player, skinIds[id])
	end 
end

function checkVipSkin()
	-- Check all vip skins on a timer, and change player skins to it
	for player, id in pairs(playerSkins) do
		if not player or not isElement(player) or getElementType(player) ~= "player" then
			playerSkins[player] = nil
		else
			if getElementModel( player ) ~= id then
				setElementModel( player, id )
			end
		end
	end
end
setTimer( checkVipSkin, 1000, 0 )



addEvent('onClientRemoveVipSkin',true)
addEvent('onClientUseVipSkin',true)
addEventHandler('onClientRemoveVipSkin', root, 
	function() 
		if getElementType(source) ~= "player" or not isPlayerVIP(source) then return false end

		 -- save VIP skin
		 local saved = saveVipSetting(source, 5, 'skin', false)
		 if saved then
		 	setVipSkin(source,false)
		 	vip_outputChatBox("Your VIP skin has successfully been removed!",source,0,255,100)
		 else
		 	vip_outputChatBox("There was an error removing your VIP skin!",source,255,0,0)
		 end
	end
)
addEventHandler('onClientUseVipSkin', root, 
	function(id) 
		if getElementType(source) ~= "player" or not isPlayerVIP(source) or not tonumber(id) or not skinIds[id] then return false end

		local saved = saveVipSetting(source, 5, 'skin', tonumber(id))
		 if saved then
		 	setVipSkin(source,id)
		 	vip_outputChatBox("Your VIP skin has successfully been changed!",source,0,255,100)
		 else
		 	vip_outputChatBox("There was an error changing your VIP skin!",source,255,0,0)
		 end
	end
)




addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
			if loggedIn then
				
				local playerVipSkin = getVipSetting(player, 5, 'skin')
				if playerVipSkin and tonumber(playerVipSkin) then
					setVipSkin(player, playerVipSkin)
				end
			else
				-- Handle logout
				setVipSkin(player,false)
			end
		end
	end
)

addEventHandler('onResourceStop', resourceRoot,
function()
	for player, id in pairs(playerSkins) do
		setVipSkin(player, false)
	end
end)