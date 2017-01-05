local shopTabPanel, modshopTab, modshop_gui

local modshop_upgrades, current_vehicle, vehicle_price = {}, nil, 550
local neons = {}
local player_perks

------------------------
----   Loading GUI   ---
------------------------

function onShopInit ( tabPanel )
	shopTabPanel = tabPanel
	colorPicker.constructor()
	modshopTab = guiCreateTab ( 'Modshop', shopTabPanel )
	if modshopTab then
			modshop_gui = build_modshopWidget( modshopTab, 35, 10 )
			guiSetText(modshop_gui['labelPrice'], 'You should register and log in to buy\nvehicles and upgrade them')
			addEventHandler( 'onClientGUIClick', modshop_gui["carsTable"], vehicleSelected, false)
			addEventHandler( 'onClientGUIClick', modshop_gui["upgradeTable"], upgradeSelected, false)
	end
	if modshop_gui then
            guiSetVisible(modshop_gui["tabBuyExtras"], false)
            guiSetVisible(modshop_gui["tabNeonlights"], false)
            guiSetVisible(modshop_gui["tabCustomHorns"], false)        
		loadVehicleList()
		--loadUpgradeList(tonumber(current_vehicle) or nil)
       -- loadNeon(tonumber(current_vehicle) or nil)
	end
	hasJustStarted = true
end
addEventHandler('onShopInit', resourceRoot, onShopInit )

function modshopLogin ( price, modshop_table )

	storeUpgrades ( modshop_table )

	if hasJustStarted then
		hasJustStarted = false
		guiDeleteTab(modshopTab, shopTabPanel)
	end
	vehicle_price = price
	
	if shopTabPanel and not isElement(modshopTab) then
		modshopTab = guiCreateTab ( 'Modshop', shopTabPanel )
		if modshopTab then
			modshop_gui = build_modshopWidget( modshopTab, 35, 10 )
			guiSetText(modshop_gui['labelPrice'], 'Current price for one vehicle: ' .. (tostring(vehicle_price) or 550) .. ' GC\n\nAll upgrades are free for bought vehicles')
			addEventHandler( 'onClientGUIClick', modshop_gui["carsTable"], vehicleSelected, false)
			addEventHandler( 'onClientGUIClick', modshop_gui["upgradeTable"], upgradeSelected, false)
			addEventHandler( 'onClientGUIClick', modshop_gui["tabelPaintjob"], paintjobSelected, false)
		end
	end
	if modshop_gui then
        if not doesHaveExtraMods() then
            -- guiSetVisible(modshop_gui["tabBuyExtras"], true)		-- disabled for the moment
            guiSetVisible(modshop_gui["tabBuyExtras"], false)
            -- guiSetVisible(modshop_gui["tabNeonlights"], false)
            guiSetVisible(modshop_gui["tabCustomHorns"], false)
        else
            guiSetVisible(modshop_gui["tabNeonlights"], true)
            guiSetVisible(modshop_gui["tabCustomHorns"], true)
            if guiGetSelectedTab(modshop_gui["modshopTabs"]) == modshop_gui["tabBuyExtras"] then
                guiSetSelectedTab(modshop_gui["modshopTabs"], modshop_gui["tabNeonlights"])
            end
            guiSetVisible(modshop_gui["tabBuyExtras"], false)
        end
		loadVehicleList()
		loadUpgradeList(tonumber(current_vehicle) or nil)
        loadNeon(tonumber(current_vehicle) or nil)
		modshopLoadPJS(player_perks);
	end
end
addEvent('modshopLogin', true)
addEventHandler('modshopLogin', localPlayer, modshopLogin)

function modshopLogout()
	--[[if shopTabPanel and modshopTab then
		guiDeleteTab ( modshopTab, shopTabPanel )
		modshopTab = nil
	end]]
	
end
addEvent('modshopLogout', true)
addEventHandler('modshopLogout', localPlayer, modshopLogout)

function storeUpgrades ( modshop_table )
	modshop_upgrades = {}

	for k,v in pairs(modshop_table or {}) do
		modshop_upgrades[tostring(v.vehicle)] = v
	end

end

function loadVehicleList()
	guiGridListClear(modshop_gui["carsTable"])
	guiGridListSetColumnWidth(modshop_gui["carsTable"],modshop_gui["carsTable_col0"], 0.7, true)
	guiGridListSetColumnWidth(modshop_gui["carsTable"],modshop_gui["carsTable_col1"], 0.1, true)
	for k, group in pairs(getElementChildren(getElementByID("modshop_vehicles"))) do
		if getElementType(group) == "vehicle_group" and getElementData(group, "ignore", false) ~= "true" then
			local i = guiGridListAddRow(modshop_gui["carsTable"])
			local groupName = getElementData(group, "name", false)
			guiGridListSetItemText( modshop_gui["carsTable"], i, modshop_gui["carsTable_col0"], tostring(groupName), true, false )
			for k, vehicle in pairs(getElementChildren(group)) do
				if getElementType(vehicle) == "modshop_vehicle" and getElementData(vehicle, "ignore", false) ~= "true" then
					local i = guiGridListAddRow(modshop_gui["carsTable"])
					local vehicle_name, vehicle_id = getElementData(vehicle, "vehicle_name", false), getElementData(vehicle, "vehicle_id", false)
					guiGridListSetItemText( modshop_gui["carsTable"], i, modshop_gui["carsTable_col0"], tostring(vehicle_name), false, false )
					guiGridListSetItemText( modshop_gui["carsTable"], i, modshop_gui["carsTable_col1"], tostring(vehicle_id), false, true )

					-- outputChatBox(tostring(modshop_upgrades[vehicle_id]))
					if modshop_upgrades[vehicle_id] then
						guiGridListSetItemColor ( modshop_gui["carsTable"], i, modshop_gui["carsTable_col0"], 102, 205, 0 )
						guiGridListSetItemColor ( modshop_gui["carsTable"], i, modshop_gui["carsTable_col1"], 102, 205, 0 )
					end
				end
			end
		end
	end
	guiSetEnabled(modshop_gui["buyVehicleButton"], false)
	guiSetEnabled(modshop_gui["upgradeVehicleButton"], false)
	if current_vehicle then
		fillInCurrentUpgrades ( current_vehicle )
	end
end


-----------------------------
---   Buying the extras   ---
-----------------------------

function doesHaveExtraMods()
    local vehID = "0"
    local slot = "slot0"
    local key = 1
    return modshop_upgrades and modshop_upgrades[vehID] and tonumber(modshop_upgrades[vehID][slot]) == key
end

function on_btnEnableExtras_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	
	triggerServerEvent ( 'gcbuyextras', resourceRoot, localPlayer, 'gcbuyextras' )
	
end


----------------------------
---   Buying/selecting   ---
----------------------------

function vehicleSelected(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") or not shop_GUI or source ~= modshop_gui["carsTable"] then
		return
	end
	local row, col = guiGridListGetSelectedItem(source)
	if tonumber(row) and tonumber(col) then
		local vehID = guiGridListGetItemText(source, row, modshop_gui["carsTable_col1"])
		if modshop_upgrades[tostring(vehID)] then
			guiSetEnabled(modshop_gui["buyVehicleButton"], false)
			guiSetEnabled(modshop_gui["upgradeVehicleButton"], true)
		else
			guiSetEnabled(modshop_gui["buyVehicleButton"], true)
			guiSetEnabled(modshop_gui["upgradeVehicleButton"], false)
		end
	end
end

function on_buyVehicleButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local row, col = guiGridListGetSelectedItem(modshop_gui["carsTable"])
	local selectedVehicle = tonumber(guiGridListGetItemText(modshop_gui["carsTable"], row, modshop_gui["carsTable_col1"]))
	if type(selectedVehicle) =='number' then
		triggerServerEvent ( 'gcbuyveh', resourceRoot, localPlayer, 'gcbuyveh', tostring(selectedVehicle))
	end
end

function on_upgradeVehicleButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local row, col = guiGridListGetSelectedItem(modshop_gui["carsTable"])
	local selectedName = guiGridListGetItemText(modshop_gui["carsTable"], row, modshop_gui["carsTable_col0"])
	local selectedID = tonumber(guiGridListGetItemText(modshop_gui["carsTable"], row, modshop_gui["carsTable_col1"]))
	if not tonumber(current_vehicle) then
		guiSetEnabled(modshop_gui["btnApplyColor"], true)
		guiSetEnabled(modshop_gui["btnApplyColor_2"], true)
		guiSetEnabled(modshop_gui["btnCol1"], true)
		guiSetEnabled(modshop_gui["btnCol2"], true)
		guiSetEnabled(modshop_gui["btnLight"], true)
		guiSetEnabled(modshop_gui["btnApplyPaintjob"], true)
		guiSetEnabled(modshop_gui["btnApplyPaintjob2"], true)
		guiSetEnabled(modshop_gui["addUpgradeButton"], true)
		guiSetEnabled(modshop_gui["viewVehicleButton"], true)
		guiSetEnabled(modshop_gui["tabVehicleColors"], true)
		guiSetEnabled(modshop_gui["tabUpgrades"], true)
		guiSetEnabled(modshop_gui["tabNeonlights"], true)
	end
	current_vehicle = selectedID
	guiSetText( modshop_gui["labelCurrentVehicle"] , "Currently modding: " .. selectedName .. " (" .. current_vehicle .. ")")
	loadUpgradeList(current_vehicle)
    loadNeon(current_vehicle)
	
	local col = rgbaToHex(0, 0, 0, 0)
	guiSetProperty(modshop_gui["squareCol1"], "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", tostring(col), tostring(col), tostring(col), tostring(col)))
	guiSetProperty(modshop_gui["squareCol2"], "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", tostring(col), tostring(col), tostring(col), tostring(col)))
	guiSetProperty(modshop_gui["squareLight"], "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", tostring(col), tostring(col), tostring(col), tostring(col)))
	return fillInCurrentUpgrades(current_vehicle)
end

function on_viewVehicleButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	triggerServerEvent('gctestveh', localPlayer, localPlayer, 'gctestveh', tostring(current_vehicle));
end

function fillInCurrentUpgrades ( vehID )
	if not tonumber(vehID) then return end
	local upgrades = modshop_upgrades[tostring(vehID)]
	
	-- Paintjob
	local paintjob_id = tonumber(upgrades.slot17)
	if paintjob_id and ((0 <= paintjob_id and paintjob_id <= 2) or 4 <= paintjob_id) then
		guiGridListSetSelectedItem(modshop_gui["tabelPaintjob"], (paintjob_id + (4 <= paintjob_id and 0 or 1)), modshop_gui["tabelPaintjob_col0"])
		if 4 <= paintjob_id then
			previewPJ();
		end
	else
		guiGridListSetSelectedItem(modshop_gui["tabelPaintjob"], 0, modshop_gui["tabelPaintjob_col0"])
	end
	
	-- Vehicle colors
	guiSetText(modshop_gui["editCol1"], tonumber(upgrades.slot18) and '' or tostring(upgrades.slot18 or ''))
	guiSetText(modshop_gui["editCol2"], tonumber(upgrades.slot19) and '' or tostring(upgrades.slot19 or ''))
	guiSetText(modshop_gui["editLight"], tonumber(upgrades.slot22) and upgrades.slot22..','..upgrades.slot23..','..upgrades.slot24 or '')
	
	local t1, t2 = split(tostring(upgrades.slot18), ','), split(tostring(upgrades.slot19), ',')
	tempColors["veh_color1"] = #t1 == 3 and {r = t1[1], g = t1[2], b = t1[3]} or {}
	tempColors["veh_color2"] = #t2 == 3 and {r = t2[1], g = t2[2], b = t2[3]} or {}
	tempColors["light_color"] = tonumber(upgrades.slot22) and {r = tonumber(upgrades.slot22), g = tonumber(upgrades.slot23), b = tonumber(upgrades.slot24)} or {}
	
	local col1 = rgbaToHex(tonumber(t1[1]), tonumber(t1[2]), tonumber(t1[3]), 255)
	guiSetProperty(modshop_gui["squareCol1"], "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", tostring(col1), tostring(col1), tostring(col1), tostring(col1)))
	local col2 = rgbaToHex(tonumber(t2[1]), tonumber(t2[2]), tonumber(t2[3]), 255)
	guiSetProperty(modshop_gui["squareCol2"], "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", tostring(col2), tostring(col2), tostring(col2), tostring(col2)))
	local col3 = rgbaToHex(tonumber(upgrades.slot22), tonumber(upgrades.slot23), tonumber(upgrades.slot24), 255)
	guiSetProperty(modshop_gui["squareLight"], "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", tostring(col3), tostring(col3), tostring(col3), tostring(col3)))
end


----------------------------
---   Upgrading colors   ---
----------------------------

local editing = ''
local gui = {
	["veh_color1"] = "editCol1",
	["veh_color2"] = "editCol2",
	["light_color"] = "editLight"
}

local gui_square = {
	["veh_color1"] = "squareCol1",
	["veh_color2"] = "squareCol2",
	["light_color"] = "squareLight"
}

tempColors = {
	["veh_color1"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil,
		["gui"] = "editCol1"
	},
	["veh_color2"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil,
		["gui"] = "editCol1"
	},
	["light_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil,
		["gui"] = "editLight"
	}
}

function on_btnCol1_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	openColorPicker("veh_color1")
end

function on_btnCol2_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	openColorPicker("veh_color2")
end

function on_btnLight_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	openColorPicker ( "light_color")
end

function openColorPicker(color)
	guiSetVisible(shop_GUI._root, false)
	editing = color
	colorPicker.openSelect(color)
	colorPicker.setValue({tempColors[editing].r,tempColors[editing].g,tempColors[editing].b,255})
	addEventHandler("onClientRender", root, updateColor)
end

function updateColor()
	if (not colorPicker.isSelectOpen) then return end
	local r1, g1, b1 = tempColors.veh_color1.r, tempColors.veh_color1.g, tempColors.veh_color1.b
	local r2, g2, b2 = tempColors.veh_color2.r, tempColors.veh_color2.g, tempColors.veh_color2.b
	local rl, gl, bl = tempColors.light_color.r, tempColors.light_color.g, tempColors.light_color.b
	guiSetText(modshop_gui[gui[editing]], tempColors[editing].r ..','.. tempColors[editing].g ..','.. tempColors[editing].b)
	
	local col = rgbaToHex(tempColors[editing].r, tempColors[editing].g, tempColors[editing].b, 255)
	guiSetProperty(modshop_gui[gui_square[editing]], "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", tostring(col), tostring(col), tostring(col), tostring(col)))
	local editingVehicle = getPedOccupiedVehicle(localPlayer)
	if editingVehicle and current_vehicle == getElementModel(editingVehicle) then
		local r1_, g1_, b1_, r2_, g2_, b2_ = getVehicleColor(editingVehicle, true)
		setVehicleColor(editingVehicle, r1 or r1_, g1 or g1_, b1 or b1_, r2 or r2_, g2 or g2_, b2 or b2_)
		local rl_, gl_, bl_ = getVehicleHeadLightColor(editingVehicle)
		setVehicleHeadLightColor(editingVehicle, rl or rl_, gl or gl_, bl or bl_)
	end
end

function closedColorPicker()
	removeEventHandler("onClientRender", root, updateColor)
	
	editing = ''
	guiSetVisible(shop_GUI._root, true)
end

function on_btnApplyColor_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local col1 = split(guiGetText(modshop_gui["editCol1"]), ',')
	local col2 = split(guiGetText(modshop_gui["editCol2"]), ',')
	local coll = split(guiGetText(modshop_gui["editLight"]), ',')
	triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', tostring(current_vehicle), 'vcolor2', col1[1], col1[2], col1[3], col2[1], col2[2], col2[3])
	triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', tostring(current_vehicle), 'lcolor', coll[1], coll[2], coll[3])
end

function on_btnApplyColor_2_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local col1 = split(guiGetText(modshop_gui["editCol1"]), ',')
	local col2 = split(guiGetText(modshop_gui["editCol2"]), ',')
	local coll = split(guiGetText(modshop_gui["editLight"]), ',')
	triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', '*', 'vcolor2', col1[1], col1[2], col1[3], col2[1], col2[2], col2[3])
	triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', '*', 'lcolor', coll[1], coll[2], coll[3])
end

function on_btnApplyPaintjob_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local row, col = guiGridListGetSelectedItem(modshop_gui["tabelPaintjob"])
	if row == -1 then row = 0 end
	triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', tostring(current_vehicle), 'paintjob', tostring(row or 0))
end

function on_btnApplyPaintjob2_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local row, col = guiGridListGetSelectedItem(modshop_gui["tabelPaintjob"])
	if row == -1 then row = 0 end
	triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', '*', 'paintjob', tostring(row or 0))
end

function paintjobSelected(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") or not shop_GUI or source ~= modshop_gui["tabelPaintjob"] then
		return
	end
	local row, col = guiGridListGetSelectedItem(source)
	if row >= 4 then
		guiSetEnabled(modshop_gui["btnUploadPaintjob"], true)
	else
		guiSetEnabled(modshop_gui["btnUploadPaintjob"], false)
	end
	previewPJ();
end

function previewPJ() 
	local row, col = guiGridListGetSelectedItem(modshop_gui["tabelPaintjob"])
	if row >= 4 then
		local filename = 'items/paintjob/' .. forumID .. '-' .. row - 3 .. '.bmp';
		if fileExists(filename) then
			if not modshop_gui["imgPreviewPaintjob"] then
				modshop_gui["imgPreviewPaintjob"] = guiCreateStaticImage( 484, 80, 120, 120, filename, false, modshop_gui["tabVehicleColors"] )
			else
				guiStaticImageLoadImage(modshop_gui["imgPreviewPaintjob"], filename);
			end
		elseif modshop_gui["imgPreviewPaintjob"] then
			destroyElement(modshop_gui["imgPreviewPaintjob"]);
			modshop_gui["imgPreviewPaintjob"] = nil;
		end
	else
		if modshop_gui["imgPreviewPaintjob"] then
			destroyElement(modshop_gui["imgPreviewPaintjob"]);
			modshop_gui["imgPreviewPaintjob"] = nil;
		end
	end
end

function on_btnUploadPaintjob_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local row, col = guiGridListGetSelectedItem(modshop_gui["tabelPaintjob"])
	if row < 4 then
		outputChatBox('Choose a custom from the list!', 255, 0, 0);
	else
		triggerServerEvent('setUpCustomPaintJob', resourceRoot, localPlayer, guiGetText(modshop_gui["editFilename"]), row - 3);
	end
end

function modshopLoadPJS(player_perks_)
	player_perks = player_perks_
	if not modshop_gui["tabelPaintjob"] then return end
	
	if player_perks and player_perks[4] and player_perks[4].options.amount >= 1 and guiGridListGetRowCount(modshop_gui["tabelPaintjob"]) ~= player_perks[4].options.amount + 4 then
		guiGridListClear(modshop_gui["tabelPaintjob"]);
		
		previewPJ();

		local tabelPaintjob_row = guiGridListAddRow(modshop_gui["tabelPaintjob"])
		guiGridListSetItemText(modshop_gui["tabelPaintjob"], tabelPaintjob_row, modshop_gui["tabelPaintjob_col0"], "No paintjob", false, false )
		
		tabelPaintjob_row = guiGridListAddRow(modshop_gui["tabelPaintjob"])
		guiGridListSetItemText(modshop_gui["tabelPaintjob"], tabelPaintjob_row, modshop_gui["tabelPaintjob_col0"], "Paintjob 1", false, false )
		
		tabelPaintjob_row = guiGridListAddRow(modshop_gui["tabelPaintjob"])
		guiGridListSetItemText(modshop_gui["tabelPaintjob"], tabelPaintjob_row, modshop_gui["tabelPaintjob_col0"], "Paintjob 2", false, false )
		
		tabelPaintjob_row = guiGridListAddRow(modshop_gui["tabelPaintjob"])
		guiGridListSetItemText(modshop_gui["tabelPaintjob"], tabelPaintjob_row, modshop_gui["tabelPaintjob_col0"], "Paintjob 3", false, false )

		for i=1,player_perks[4].options.amount do
			tabelPaintjob_row = guiGridListAddRow(modshop_gui["tabelPaintjob"])
			guiGridListSetItemText(modshop_gui["tabelPaintjob"], tabelPaintjob_row, modshop_gui["tabelPaintjob_col0"], "Custom " .. i, false, false )
		end
	end
end

function HexToRGB(hex)
	-- input: "#XXX" or "#XXXXX" (string)
	hex = hex:sub(2,7)
	color = {}
	if (hex:len() == 3) then
		color.r = tonumber('0x' .. string.rep(hex:sub(1, 1),2))
		color.g = tonumber('0x' .. string.rep(hex:sub(2, 2),2))
		color.b = tonumber('0x' .. string.rep(hex:sub(3, 3),2))
	elseif(hex:len() == 6) then
		color.r = tonumber('0x' .. hex:sub(1, 2))
		color.g = tonumber('0x' .. hex:sub(3, 4))
		color.b = tonumber('0x' .. hex:sub(5, 6))
	end
	return color.r, color.g, color.b
end


--------------------
---   Upgrades   ---
--------------------

local selected_upgrade, selected_row
function loadUpgradeList(vehID)
	guiGridListClear(modshop_gui["upgradeTable"])
	selected_upgrade = nil
	guiSetEnabled(modshop_gui["addUpgradeButton"], false)
	guiSetEnabled(modshop_gui["delUpgradeButton"], false)
	if not vehID then return end
	compatibleUpgrades = getCompatibleUpgrades(vehID)
	guiGridListSetColumnWidth(modshop_gui["upgradeTable"],modshop_gui["upgradeTable_col0"], 0.60, true)
	guiGridListSetColumnWidth(modshop_gui["upgradeTable"],modshop_gui["upgradeTable_col1"], 0.25, true)
	for slot = 0,16 do
		local compatibleSlot = false
		for k, upgradeID in ipairs(compatibleUpgrades) do
			if getVehicleUpgradeSlotName ( slot ) == getVehicleUpgradeSlotName ( upgradeID ) then
				compatibleSlot = true
				break
			end
		end
		if compatibleSlot and slot ~= 8 and slot ~= 9 then
			local slotName = getVehicleUpgradeSlotName ( slot )
			local i = guiGridListAddRow(modshop_gui["upgradeTable"])
			local a = guiGridListSetItemText( modshop_gui["upgradeTable"], i, modshop_gui["upgradeTable_col0"], tostring(slotName), true, false )
			for k, upgradeID in ipairs(compatibleUpgrades) do
				if (upgradeID~=1008 and upgradeID~=1009 and upgradeID~=1010 and upgradeID~=1087) and slotName == getVehicleUpgradeSlotName ( upgradeID ) then
					local i = guiGridListAddRow(modshop_gui["upgradeTable"])
					local element = getElementByID( "upgrade_" .. upgradeID)
					if element then
						local upgrade_name = getElementData(element,"name",false)
						local added = false
						guiGridListSetItemText( modshop_gui["upgradeTable"], i, modshop_gui["upgradeTable_col0"], tostring(upgrade_name), false, false )
						guiGridListSetItemText( modshop_gui["upgradeTable"], i, modshop_gui["upgradeTable_col1"], tostring(upgradeID), false, true )
						if modshop_upgrades[tostring(vehID)] and tonumber(modshop_upgrades[tostring(vehID)]['slot' .. slot]) == upgradeID then
							guiGridListSetItemColor ( modshop_gui["upgradeTable"], i, modshop_gui["upgradeTable_col0"], 102, 205, 0 )
							guiGridListSetItemColor ( modshop_gui["upgradeTable"], i, modshop_gui["upgradeTable_col1"], 102, 205, 0 )
							added = true
						end
						if i == selected_row then
							guiGridListSetSelectedItem ( modshop_gui["upgradeTable"], i, modshop_gui["upgradeTable_col0"])
							selected_upgrade = upgradeID
							if added then
								guiSetEnabled(modshop_gui["addUpgradeButton"], false)
								guiSetEnabled(modshop_gui["delUpgradeButton"], true)
							else
								guiSetEnabled(modshop_gui["addUpgradeButton"], true)
								guiSetEnabled(modshop_gui["delUpgradeButton"], false)
							end
						end
					end
				end
			end
		end
	end
end

function getCompatibleUpgrades ( vehicle )
	local tempveh
	if type(vehicle) == 'number' and getVehicleNameFromModel(vehicle) ~= '' then
		tempveh = createVehicle(vehicle, 0,0,-50)
		local compUpgrades = getVehicleCompatibleUpgrades(tempveh)
		destroyElement(tempveh)
		tempveh = nil
		return compUpgrades or false
	end
	return false
end

function upgradeSelected(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") or not shop_GUI or source ~= modshop_gui["upgradeTable"] then
		return
	end
	local row, col = guiGridListGetSelectedItem(source)
	if tonumber(row) and tonumber(col) then
		selected_row = row
		selected_upgrade = tonumber(guiGridListGetItemText(source, row, modshop_gui["upgradeTable_col1"]))
		local r,g,b,a = guiGridListGetItemColor(source, row, modshop_gui["upgradeTable_col1"])
		if selected_upgrade and r == 102 and g == 205 and b == 0 then
			guiSetEnabled(modshop_gui["addUpgradeButton"], false)
			guiSetEnabled(modshop_gui["delUpgradeButton"], true)
			guiSetEnabled(modshop_gui["addUpgradeForAllButton"], true)
		elseif selected_upgrade then
			guiSetEnabled(modshop_gui["addUpgradeButton"], true)
			guiSetEnabled(modshop_gui["delUpgradeButton"], false)
			guiSetEnabled(modshop_gui["addUpgradeForAllButton"], true)
		else
			guiSetEnabled(modshop_gui["addUpgradeButton"], false)
			guiSetEnabled(modshop_gui["delUpgradeButton"], false)
			guiSetEnabled(modshop_gui["addUpgradeForAllButton"], false)
			selected_row = nil
			selected_upgrade = nil
		end
	end
end

function on_addUpgradeButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	if getVehicleUpgradeSlotName(selected_upgrade) and getVehicleNameFromModel ( tonumber(current_vehicle) ) then
		triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', tostring(current_vehicle), 'upgrade', selected_upgrade)
	end
end

function on_delUpgradeButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	if getVehicleUpgradeSlotName(selected_upgrade) and getVehicleNameFromModel ( tonumber(current_vehicle) ) then
		triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', tostring(current_vehicle), 'remupgrade', selected_upgrade)
	end
end

function on_addUpgradeForAllButton_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	if getVehicleUpgradeSlotName(selected_upgrade) and getVehicleNameFromModel ( tonumber(current_vehicle) ) then
		triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', '*', 'upgrade', selected_upgrade)
	end
end

addCommandHandler ( "getvehid", function ()
	local veh = getPedOccupiedVehicle ( localPlayer )
	if veh then
		local model = getElementModel(veh)
		outputChatBox('Vehicle: ' .. getVehicleNameFromModel(model) .. ' [' .. model .. ']', 255, 0 ,125)
	end
end)


-----------------------
---   Neon lights   ---
-----------------------

function installNeon ( data_neons )
    neons = data_neons
    for k,v in pairs(neons) do
        local dff = engineLoadDFF( v[1], v[2]) 
        engineReplaceModel(dff, v[2])
    end
end
addEvent('installNeon', true)
addEventHandler('installNeon', localPlayer, installNeon)

function loadNeon ( model )
    local data = getModelNeonData ( tonumber(model) )
    local enable = (not not model) and (not not data)
    guiSetEnabled(modshop_gui["btnNeonGreen"], enable)
    guiSetEnabled(modshop_gui["btnNeonOrange"], enable)
    guiSetEnabled(modshop_gui["btnNeonRed"], enable)
    guiSetEnabled(modshop_gui["btnNeonYellow"], enable)
    guiSetEnabled(modshop_gui["btnNeonAqua"], enable)
    guiSetEnabled(modshop_gui["btnNeonRemove"], false)
    local vehID = tostring ( model )
    local color = modshop_upgrades and modshop_upgrades[vehID] and type(modshop_upgrades[vehID].slot26) == 'string' and modshop_upgrades[vehID].slot26:gsub("^%l", string.upper)
    if color and modshop_gui["btnNeon" .. color] then
        guiSetEnabled(modshop_gui["btnNeon" .. color], false)
        guiSetEnabled(modshop_gui["btnNeonRemove"], true)
    end
end

function applyNeon ( color )
    triggerServerEvent ( 'gcsetmod', resourceRoot, localPlayer, 'gcsetmod', tostring(current_vehicle), 'neon', color)
end

function getModelNeonData ( id )
    for k,v in ipairs( getElementsByType('modshop_vehicle', getElementByID("modshop_vehicles")) ) do
        if tonumber(getElementData(v, "vehicle_id", false)) == id then
            local data = false
            local neon_data = getElementData(v, "neon_data", false)
            if neon_data and type(neon_data) == "string" and #neon_data > 0 then
                neon_data = split(neon_data, ",")
                for i = 1,#neon_data do
                    neon_data[i] = tonumber(neon_data[i])
                end
                if #neon_data == 9 then
                    data = neon_data
                end
            end
            return data
        end
    end
    return false
end

function on_btnNeonGreen_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	applyNeon ( "green" )
end

function on_btnNeonOrange_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	applyNeon ( "orange" )
end

function on_btnNeonRed_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	applyNeon ( "red" )
end

function on_btnNeonYellow_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	applyNeon ( "yellow" )
end

function on_btnNeonAqua_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	applyNeon ( "aqua" )
end

function on_btnNeonRemove_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	applyNeon ()
end






function var_dump(...)
	-- default options
	local verbose = false
	local firstLevel = true
	local outputDirectly = true
	local noNames = false
	local indentation = "\t\t\t\t\t\t"
	local depth = nil
 
	local name = nil
	local output = {}
	for k,v in ipairs(arg) do
		-- check for modifiers
		if type(v) == "string" and k < #arg and v:sub(1,1) == "-" then
			local modifiers = v:sub(2)
			if modifiers:find("v") ~= nil then
				verbose = true
			end
			if modifiers:find("s") ~= nil then
				outputDirectly = false
			end
			if modifiers:find("n") ~= nil then
				verbose = false
			end
			if modifiers:find("u") ~= nil then
				noNames = true
			end
			local s,e = modifiers:find("d%d+")
			if s ~= nil then
				depth = tonumber(string.sub(modifiers,s+1,e))
			end
		-- set name if appropriate
		elseif type(v) == "string" and k < #arg and name == nil and not noNames then
			name = v
		else
			if name ~= nil then
				name = ""..name..": "
			else
				name = ""
			end
 
			local o = ""
			if type(v) == "string" then
				table.insert(output,name..type(v).."("..v:len()..") \""..v.."\"")
			elseif type(v) == "userdata" then
				local elementType = "no valid MTA element"
				if isElement(v) then
					elementType = getElementType(v)
				end
				table.insert(output,name..type(v).."("..elementType..") \""..tostring(v).."\"")
			elseif type(v) == "table" then
				local count = 0
				for key,value in pairs(v) do
					count = count + 1
				end
				table.insert(output,name..type(v).."("..count..") \""..tostring(v).."\"")
				if verbose and count > 0 and (depth == nil or depth > 0) then
					table.insert(output,"\t{")
					for key,value in pairs(v) do
						-- calls itself, so be careful when you change anything
						local newModifiers = "-s"
						if depth == nil then
							newModifiers = "-sv"
						elseif  depth > 1 then
							local newDepth = depth - 1
							newModifiers = "-svd"..newDepth
						end
						local keyString, keyTable = var_dump(newModifiers,key)
						local valueString, valueTable = var_dump(newModifiers,value)
 
						if #keyTable == 1 and #valueTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>\t"..valueString)
						elseif #keyTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>")
							for k,v in ipairs(valueTable) do
								table.insert(output,indentation..v)
							end
						elseif #valueTable == 1 then
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							table.insert(output,indentation.."\t=>\t"..valueString)
						else
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							for k,v in ipairs(valueTable) do
								if k == 1 then
									table.insert(output,indentation.." => "..v)
								else
									table.insert(output,indentation..v)
								end
							end
						end
					end
					table.insert(output,"\t}")
				end
			else
				table.insert(output,name..type(v).." \""..tostring(v).."\"")
			end
			name = nil
		end
	end
	local string = ""
	for k,v in ipairs(output) do
		if outputDirectly then
			outputConsole(v)
		end
		string = string..v
	end
	return string, output
end



function rgbaToHex(r, g, b, a)
	if not r then
		r, g, b, a = 255, 255, 255, 0
	end
	return string.format("%02X%02X%02X%02X", a, r, g, b)
end