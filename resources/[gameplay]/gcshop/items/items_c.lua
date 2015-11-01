local shopTabPanel,items_gui;
itemsTab = nil;
local perks = {};
player_perks = {};

--------------------
--- Loading GUI ----
--------------------

function onShopInit ( tabPanel )
	shopTabPanel = tabPanel
	if shopTabPanel and not itemsTab then
		itemsTab = guiCreateTab ( 'GC Perks', shopTabPanel )
		if itemsTab then
			items_gui = build_itemsWidget( itemsTab, 40, 30 )
			guiSetVisible(items_gui["btnExtendScrollarea"], false);
		end
	end	
end
addEventHandler('onShopInit', resourceRoot, onShopInit )

function itemLogin ( perks_, player_perks_ )
	perks, player_perks = perks_, player_perks_; 
	if itemsTab then
		for id, perk in pairs(perks) do
			if not perk.requires then
				guiSetText(items_gui["btnBuyPerk_" .. id], 'Price:\n ' .. (tostring(perk.price)) .. ' GC')
				guiSetEnabled(items_gui["btnBuyPerk_" .. id], true)
			else
				local ok = true;
				for _, req in pairs(perk.requires) do
					if not player_perks[req] then
						ok = false;
						break;
					end
				end
				if ok then
					guiSetText(items_gui["btnBuyPerk_" .. id], 'Price:\n ' .. (tostring(perk.price)) .. ' GC')
					guiSetEnabled(items_gui["btnBuyPerk_" .. id], true)
				else
					guiSetText(items_gui["btnBuyPerk_" .. id], 'Requires perk' .. ((#(perk.requires) > 1) and 's' or '') .. ':\n' .. table.concat(perk.requires, ', '))
					guiSetEnabled(items_gui["btnBuyPerk_" .. id], false)
				end
			end
		end
		for id, perk in pairs(player_perks) do
			if items_gui["btnBuyPerk_" .. perk.ID] then
				if perk.exp then
					guiSetText(items_gui["btnBuyPerk_" .. perk.ID], 'Price:\n ' .. (tostring(perk.price)) .. ' GC\nExpires ' .. string.format('%02d/%02d', getRealTime(perk.expires).monthday, getRealTime(perk.expires).month + 1))
					guiSetEnabled(items_gui["btnBuyPerk_" .. perk.ID], false)
					if id == 10 then -- If colored rockets are bought, enable coloring button
						guiSetEnabled(items_gui["setRocketColorButton"],true)
						local theColor = getElementData(localPlayer,"gc_projectilecolor")
						if theColor then
							guiSetProperty(RocketColorImage, "ImageColours", setIMGcolor(theColor:gsub("#","")))
						end
					end
				elseif perk.defaultAmount then
					guiSetText(items_gui["btnBuyPerk_" .. perk.ID], 'Extra Price:\n ' .. (tostring(perk.extraPrice)) .. '\n\nCurrent amount:\n' .. perk.options.amount )
				else
					guiSetText(items_gui["btnBuyPerk_" .. perk.ID], 'Price:\n ' .. (tostring(perk.price)) .. ' GC\nBought!')
					guiSetEnabled(items_gui["btnBuyPerk_" .. perk.ID], false)
				end
			end
		end
	end
	if modshopLoadPJS then
		modshopLoadPJS(player_perks);
	end
end
addEvent('itemLogin', true)
addEventHandler('itemLogin', localPlayer, itemLogin)


function on_btnBuyPerk_1_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (1);
end

function on_btnBuyPerk_2_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (2);
end

function on_btnBuyPerk_3_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (3);
end

function on_btnBuyPerk_4_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (4);
end

function on_btnBuyPerk_5_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (5);
end

function on_btnBuyPerk_6_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (6);
end

function on_btnBuyPerk_7_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (7);
end

function on_btnBuyPerk_8_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (8);
end

function on_btnBuyPerk_9_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (9);
end

function on_btnBuyPerk_10_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (10);
end

function on_btnBuyPerk_11_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	button_buy_perk (11);
end


function button_buy_perk ( id )
	if not player_perks[id] then
		triggerServerEvent('gcbuyperk', localPlayer, localPlayer, 'gcbuyperk', id);
		if perks[id].defaultAmount and amount_GCS >= perks[id].extraPrice then
			--guiSetText(items_gui["btnBuyPerk_" .. id], 'Extra Price:\n ' .. (tostring(perks.extraPrice)) .. '\n\nCurrent amount:\n' .. perks.options.amount)
		end
	elseif player_perks[id].defaultAmount then
		if amount_GCS >= player_perks[id].extraPrice then
			--guiSetText(items_gui["btnBuyPerk_" .. id], 'Extra Price:\n ' .. (tostring(player_perks.extraPrice)) .. '\n\nCurrent amount:\n' .. player_perks.options.amount)
		end
		triggerServerEvent('gcbuyperkextra', localPlayer, localPlayer, 'gcbuyperkextra', id, 1);
	end
end


-- Handle projectile color setting
function button_set_rocketcolor()
	openPicker(200,"#FF0000","Nitro Color") -- TODO set saved color
end

function setIMGcolor(hex)
	local hex = hex:gsub("#","")
	return "tl:FF"..hex.." tr:FF"..hex.." bl:FF"..hex.." br:FF"..hex
end

local colorCache = false
function rocketColorChangeHandler(id, color, alpha)
	if id == 200 then -- if it's the rocket colorpicker
		
		colorCache = color
		local askServer = triggerServerEvent( "serverRocketColorChange", root, colorCache )

		if not askServer then rocketColorChangeConfirm(false) end -- if fail then continue with next function
		-- rocketColorChangeConfirm(true)

		
	end
end
addEventHandler("onColorPickerOK", resourceRoot, rocketColorChangeHandler)

addEvent("clientRocketColorChangeConfirm",true)
function rocketColorChangeConfirm(bool)
	if bool then
		outputChatBox( "Rocket color is now: "..colorCache.."COLOR", 255, 255, 255, true )
		outputChatBox( "Colored rockets will only appear when you have bought the perk.", 255, 255, 255, true )
		guiSetProperty(RocketColorImage, "ImageColours", setIMGcolor(colorCache:gsub("#","")))
	else
		colorCache = false
	end
end
addEventHandler("clientRocketColorChangeConfirm",root,rocketColorChangeConfirm)