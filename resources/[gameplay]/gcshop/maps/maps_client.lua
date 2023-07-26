prices = {}
prices["race"] = 10
prices["rtf"] = 250
prices["ctf"] = 200
prices["nts"] = 275
prices["shooter"] = 500
prices["deadline"] = 175

lastWinnerDiscount = 50
isVipMap = false

PRICE = 1000

local main_window
local tab_panel
local tab = {}
local aGamemodeMapTable = {}

function createNextmapWindow(tabPanel)
    tab = {}
    tab.mainBuyPanel = guiCreateTab('Maps-Center', tabPanel)
    tab_panel = guiCreateTabPanel ( 0.01, 0.05, 0.98, 0.95, true, tab.mainBuyPanel )
    tab.maps = guiCreateTab ( "All Maps", tab_panel)
    tab.qmaps = guiCreateTab ( "Queued Maps", tab_panel)
    tab.MapListSearch = guiCreateEdit ( 0.03, 0.225, 0.31, 0.05, "", true, tab.maps )
    guiCreateStaticImage ( 0.34, 0.225, 0.035, 0.05, "nextmap/search.png", true, tab.maps )
    tab.MapList = guiCreateGridList ( 0.03, 0.30, 0.94, 0.55, true, tab.maps )
    guiGridListSetSortingEnabled(tab.MapList, false)
					  guiGridListAddColumn( tab.MapList, "Map Name", 0.45)
					  guiGridListAddColumn( tab.MapList, "Author", 0.4)
					  guiGridListAddColumn( tab.MapList, "Price", 0.2)
					  guiGridListAddColumn( tab.MapList, "Resource Name", 1)
					  guiGridListAddColumn( tab.MapList, "Gamemode", 0.5)

    tab.NextMap = guiCreateButton ( 0.49, 0.91, 0.30, 0.04, "Buy selected map", true, tab.maps )
    tab.RefreshList = guiCreateButton ( 0.03, 0.91, 0.35, 0.04, "Refresh list", true, tab.maps )
    addEventHandler ("onClientGUIClick", tab.NextMap, guiClickBuy, false)
    addEventHandler ("onClientGUIClick", tab.RefreshList, guiClickRefresh, false)
	addEventHandler ("onClientGUIChanged", tab.MapListSearch, guiChanged)

	tab.QueueList = guiCreateGridList (0.02, 0.04, 0.97, 0.92, true, tab.qmaps )
	guiGridListSetSortingEnabled(tab.QueueList, false)
                guiGridListAddColumn( tab.QueueList, "Priority", 0.15)
                guiGridListAddColumn( tab.QueueList, "Map Name", 2)

        tab.label1 = guiCreateLabel(0.40, 0.05, 0.50, 0.11, "This is the Maps-Center. Here you can buy maps.", true, tab.maps)
        tab.label2 = guiCreateLabel(0.40, 0.13, 0.50, 0.12, "Select a map you like and click \"Buy selected map\"", true, tab.maps)
        tab.label3 = guiCreateLabel(0.40, 0.18, 0.50, 0.17, "The map will be added to the Server Queue, where all bought maps are stored until they're played", true, tab.maps)

        guiLabelSetHorizontalAlign(tab.label3, "left", true)
        -- tab.label4 = guiCreateLabel(0.40, 0.28, 0.50, 0.13, "The queued maps will have priority against the usual server map cycler!", true, tab.maps)
        -- guiLabelSetHorizontalAlign(tab.label4, "left", true)

		tab.label5 = guiCreateLabel(0.03, 0.03, 0.30, 0.12, "The winner of the last map played\ngets "..tostring(lastWinnerDiscount).."% off!", true, tab.maps)
        guiLabelSetColor( tab.label5, 255, 0, 0 )
        guiSetFont( tab.label5, "default-bold-small" )

        tab.viplabel = guiCreateLabel(0.03, 0.14, 0.36, 0.08, "Purchase VIP to get a free map every day!", true, tab.maps)
        guiLabelSetColor( tab.viplabel, 255, 0, 0 )
        guiSetFont( tab.viplabel, "default-bold-small" )
        guiSetFont( tab.viplabel, "default-bold-small" )

	triggerServerEvent('refreshServerMaps', localPlayer)
end

addEventHandler('onShopInit', getResourceRootElement(), createNextmapWindow )

function getGamemodePrice(gamemode)
	return prices[gamemode] or PRICE
end


function loadMaps(gamemodeMapTable, queuedList)
	if gamemodeMapTable then
		aGamemodeMapTable = gamemodeMapTable
		for id,gamemode in pairs (gamemodeMapTable) do
			guiGridListSetItemText ( tab.MapList, guiGridListAddRow ( tab.MapList ), 1, gamemode.name, true, false )
			if #gamemode.maps == 0 and gamemode.name ~= "no gamemode" and gamemode.name ~= "deleted maps" then
				local row = guiGridListAddRow ( tab.MapList )
				guiGridListSetItemText ( tab.MapList, row, 1, gamemode.name, true, false )
				guiGridListSetItemText ( tab.MapList, row, 2, gamemode.resname, true, false )
				guiGridListSetItemText ( tab.MapList, row, 3, gamemode.resname, true, false )
				guiGridListSetItemText ( tab.MapList, row, 4, gamemode.resname, true, false )
				guiGridListSetItemText ( tab.MapList, row, 5, gamemode.resname, true, false )
			else
				for id,map in ipairs (gamemode.maps) do
					local row = guiGridListAddRow ( tab.MapList )
					if map.author then
						guiGridListSetItemText ( tab.MapList, row, 2, map.author, false, false )
					end

					guiGridListSetItemText ( tab.MapList, row, 1, map.name, false, false )

					guiGridListSetItemText ( tab.MapList, row, 3, getGamemodePrice(gamemode.name), false, false )

					guiGridListSetItemText ( tab.MapList, row, 4, map.resname, false, false )
					guiGridListSetItemText ( tab.MapList, row, 5, gamemode.resname, false, false )

				end
			end
		end
		for priority, mapName in ipairs(queuedList) do
            local row_ = guiGridListAddRow ( tab.QueueList )
            guiGridListSetItemText ( tab.QueueList, row_, 1, priority, false, false )
            guiGridListSetItemText ( tab.QueueList, row_, 2, queuedList[priority][1], false, false )
		end
	end
end
addEvent("sendMapsToBuy", true)
addEventHandler("sendMapsToBuy", getLocalPlayer(), loadMaps)


addEvent('onTellClientPlayerBoughtMap', true)
addEventHandler('onTellClientPlayerBoughtMap', root,
function(mapName, priority)
    local row_ = guiGridListAddRow ( tab.QueueList )
    guiGridListSetItemText ( tab.QueueList, row_, 1, priority, false, false )
    guiGridListSetItemText ( tab.QueueList, row_, 2, mapName, false, false )
end)


addEventHandler('onClientMapStarting', root,
function(mapinfo)
    local name = mapinfo.name
    local firstQueue = guiGridListGetItemText( tab.QueueList, 0, 2)
    if name == firstQueue then
        local rows = guiGridListGetRowCount(tab.QueueList)
        guiGridListRemoveRow(tab.QueueList, 0)
        guiGridListSetItemText(tab.QueueList, 0, 1, "1", false, false)
        local i
        for i = 1, rows-1 do
            --local oldPriority = tonumber(guiGridListGetItemText(tab.QueueList, i, 1))
            --oldPriority = tostring(oldPriority - 1)
            guiGridListSetItemText(tab.QueueList, i, 1, tostring(i+1), false, false)
        end
    end
end)

function guiClickBuy(button)
    if button == "left" then
        if not guiGridListGetSelectedItem ( tab.MapList ) == -1 then
            return
        end
        local mapName = guiGridListGetItemText ( tab.MapList, guiGridListGetSelectedItem( tab.MapList ), 1 )
        local mapResName = guiGridListGetItemText ( tab.MapList, guiGridListGetSelectedItem( tab.MapList ), 4 )
        local gamemode = guiGridListGetItemText ( tab.MapList, guiGridListGetSelectedItem( tab.MapList ), 5 )
        triggerServerEvent("sendPlayerNextmapChoice", getLocalPlayer(), { mapName, mapResName, gamemode, getPlayerName(localPlayer) })
    end
end

function guiClickRefresh(button)
    if button == "left" then
        guiGridListClear(tab.MapList)
        guiGridListClear(tab.QueueList)
        triggerServerEvent('refreshServerMaps', localPlayer)
    end
end

function guiChanged()
	guiGridListClear(tab.MapList)
	local text = string.lower(guiGetText(source))
	if ( text == "" ) then
		for id,gamemode in pairs (aGamemodeMapTable) do
			guiGridListSetItemText ( tab.MapList, guiGridListAddRow ( tab.MapList ), 1, gamemode.name, true, false )
			if #gamemode.maps == 0 and gamemode.name ~= "no gamemode" and gamemode.name ~= "deleted maps" then
				local row = guiGridListAddRow ( tab.MapList )
				guiGridListSetItemText ( tab.MapList, row, 1, gamemode.name, false, false )
				if map.author then
					guiGridListSetItemText ( tab.MapList, row, 2, map.author, false, false )
				end
				guiGridListSetItemText ( tab.MapList, row, 3, getGamemodePrice(gamemode.name), false, false )
				guiGridListSetItemText ( tab.MapList, row, 4, gamemode.resname, false, false )
				guiGridListSetItemText ( tab.MapList, row, 5, gamemode.resname, false, false )
			else
				for id,map in ipairs (gamemode.maps) do
					local row = guiGridListAddRow ( tab.MapList )
					guiGridListSetItemText ( tab.MapList, row, 1, map.name, false, false )
					if map.author then
						guiGridListSetItemText ( tab.MapList, row, 2, map.author, false, false )
					end
					guiGridListSetItemText ( tab.MapList, row, 3, getGamemodePrice(gamemode.name), false, false )
					guiGridListSetItemText ( tab.MapList, row, 4, map.resname, false, false )
					guiGridListSetItemText ( tab.MapList, row, 5, gamemode.resname, false, false )
				end
			end
		end
	else
		for id,gamemode in pairs (aGamemodeMapTable) do
			local gameModeRow = guiGridListAddRow ( tab.MapList )
			local noMaps = true
			guiGridListSetItemText ( tab.MapList, gameModeRow, 1, gamemode.name, true, false )
			if #gamemode.maps == 0 and gamemode.name ~= "no gamemode" and gamemode.name ~= "deleted maps" then
				if string.find(string.lower(gamemode.name.." "..gamemode.resname), text, 1, true) then
					local row = guiGridListAddRow ( tab.MapList )
					guiGridListSetItemText ( tab.MapList, row, 1, gamemode.name, false, false )
					if map.author then
						guiGridListSetItemText ( tab.MapList, row, 2, map.author, false, false )
					end
					guiGridListSetItemText ( tab.MapList, row, 3, getGamemodePrice(gamemode.name), false, false )
					guiGridListSetItemText ( tab.MapList, row, 4, gamemode.resname, false, false )
					guiGridListSetItemText ( tab.MapList, row, 5, gamemode.resname, false, false )
					noMaps = false
				end
			else
				for id,map in ipairs (gamemode.maps) do
					if not map.author then
						compareTo = string.lower(map.name.." "..map.resname)
					else
						compareTo = string.lower(map.name.." "..map.resname.." "..map.author)
					end
					if string.find(compareTo, text, 1, true) then
						local row = guiGridListAddRow ( tab.MapList )
						guiGridListSetItemText ( tab.MapList, row, 1, map.name, false, false )
						if map.author then
							guiGridListSetItemText ( tab.MapList, row, 2, map.author, false, false )
						end
						guiGridListSetItemText ( tab.MapList, row, 3, getGamemodePrice(gamemode.name), false, false )
						guiGridListSetItemText ( tab.MapList, row, 4, map.resname, false, false )
						guiGridListSetItemText ( tab.MapList, row, 5, gamemode.resname, false, false )
						noMaps = false
					end
				end
			end
			if noMaps then
				guiGridListRemoveRow(tab.MapList, gameModeRow)
			end
		end
	end
end

addEvent('onGCShopWinnerDiscount', true)
addEventHandler('onGCShopWinnerDiscount', root, function()
	if source == localPlayer then
		guiLabelSetColor( tab.label5, 0, 255, 0 )
		guiSetText(tab.label5, "Every map is "..lastWinnerDiscount.."% off\nbecause you have won the last map!" )
	else
		guiLabelSetColor( tab.label5, 255, 0, 0 )
		guiSetText(tab.label5, "The winner of the last map played\ngets "..lastWinnerDiscount.."% off!" )
	end
end)

-- VIP free map
local countdownTimer = false
addEvent('onVipFreeMapInfo', true)
addEventHandler('onVipFreeMapInfo', root, function(canUse)
	if source ~= localPlayer then return end

	if canUse == true then
		isVipMap = true
		guiLabelSetColor( tab.viplabel, 0, 255, 0 )
		guiSetText(tab.viplabel, "Your next map will be free! (VIP)" )
	else
		isVipMap = false
		guiLabelSetColor( tab.viplabel, 255, 0, 0 )
		guiSetText(tab.viplabel, "You have used your free VIP map. \nYou will get another one tomorrow! (00:00 CET)" )
	end
end)

addEvent('onVipFreeMapLogOut', true)
addEventHandler('onVipFreeMapLogOut', root, function()
	if source ~= localPlayer then return end

	isVipMap = false
	guiLabelSetColor( tab.viplabel, 255, 0, 0 )
	guiSetText(tab.viplabel, "Purchase VIP to get a free map every day!" )

end)

addEventHandler( 'onClientResourceStart', resourceRoot, function()
	if getResourceState(getResourceFromName( 'mrgreen-vip' )) == "running" then
		triggerServerEvent( 'onClientRequestsVipMap', root)
	end
end)


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

addEvent("mapstop100_refresh",true)
function mapstop100_refresh()
	guiGridListClear(tab.MapList)
	guiGridListClear(tab.QueueList)
end
addEventHandler("mapstop100_refresh",root,mapstop100_refresh)

-- [number "85"]	=>
-- table(3) "table: 2805A560"
-- 	{
-- 						[string(7) "resname"]	=>	string(15) "shooter-stadium"
-- 						[string(6) "author"]	=>	string(11) "salvadorc17"
-- 						[string(4) "name"]	=>	string(15) "Shooter-Stadiu
