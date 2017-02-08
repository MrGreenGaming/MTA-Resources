local shopTabPanel

function previewSkin(button, state)
	if state == "up" and button == "left" then
		local row, col = guiGridListGetSelectedItem(skinGrid)
		if row == -1 or col == -1 or row == false then return end
		local id = guiGridListGetItemText(skinGrid, row, colId)
		if id == "" then return end
		if getElementModel(getLocalPlayer()) ~= tonumber(id) then 
			setElementModel(getLocalPlayer(), tonumber(id))
		end
		if isTimer(changeBack) then killTimer(changeBack) end
		changeBack = setTimer(setElementModel, 5000, 1, getLocalPlayer(), 0)  --back to cj
	end
end

addEvent("onServerSkinData", true)
addEventHandler("onServerSkinData", root,
function(success)
	if not success then
		if guiGetVisible(successLabel) or guiGetVisible(failLabel3) then
			guiSetVisible(successLabel, false)
			guiSetVisible(failLabel3, false)
		end
		guiSetVisible(failLabel, true)
		guiSetVisible(failLabel2, true)
	else
		if isTimer(changeBack) then killTimer(changeBack) end
		triggerServerEvent('getSkinPurchases', getLocalPlayer())
		if guiGetVisible(failLabel) or guiGetVisible(failLabel3) then
			guiSetVisible(failLabel, false)
			guiSetVisible(failLabel2, false)
			guiSetVisible(failLabel3, false)
		end
		guiSetVisible(successLabel, true)	
	end
end
)


function buySkin(button, state)
	if state == "up" and button == "left" then
		local row, col = guiGridListGetSelectedItem(skinGrid)
		if row == -1 or col == -1 or row == false then return end
		local id = guiGridListGetItemText(skinGrid, row, colId)
		if id == "" then return end
		if isTimer(changeBack) then killTimer(changeBack) end
		setElementModel(getLocalPlayer(), currentID)
		triggerServerEvent('onPlayerChooseSkin', getLocalPlayer(), tostring(id))
	end
end


function useButton(button, state)
	if state == "up" and button == "left" then
			local row, col = guiGridListGetSelectedItem(skinGrid)
			if row == -1 or col == -1 or row == false then return end
			local id = guiGridListGetItemText(skinGrid, row, colId)
			if id == "" then return end
			if isTimer(changeBack) then killTimer(changeBack) end
			setElementModel(getLocalPlayer(), currentID)
			triggerServerEvent('onPlayerUseSkin', getLocalPlayer(), tostring(id))
	end
end

function disableSkins(button, state)
	if state == "up" and button == "left" then
		triggerServerEvent('disableSkins', getLocalPlayer())
	end
end

--[[addEvent('onClientGreencoinsLogin', true)
addEventHandler('onClientGreencoinsLogin', root,
function()
	triggerServerEvent('getSkinPurchases', getLocalPlayer())
end
)
]]


function onShopInit ( tabPanel )
	shopTabPanel = tabPanel
	--triggerServerEvent('getSkinPurchases', getLocalPlayer())
	skinTab = guiCreateTab("Buy skins", shopTabPanel)
	skinGrid = guiCreateGridList(0.01,0.02,0.40,0.97, true, skinTab)
	guiGridListSetSortingEnabled(skinGrid, false)
	local colName = guiGridListAddColumn(skinGrid, "Skin", 0.7)
	colId = guiGridListAddColumn(skinGrid, "ID", 0.2)
	local node = xmlLoadFile('skin/skins.xml')
	local childrenGroups = xmlNodeGetChildren(node)
	for _, group in ipairs(childrenGroups) do 
		local skinName = xmlNodeGetAttribute(group, "name")
		local row = guiGridListAddRow(skinGrid)
		guiGridListSetItemText(skinGrid, row, colName, "Group: "..skinName, false, false)
		guiGridListSetItemColor(skinGrid, row, colName, 255, 0, 0)
		for __, name in ipairs(xmlNodeGetChildren(group)) do 
			skinName = xmlNodeGetAttribute(name, "name")
			local skinID = xmlNodeGetAttribute(name, "id")
			row = guiGridListAddRow(skinGrid)
			guiGridListSetItemText(skinGrid, row, colName, "       "..skinName, false, false)
			guiGridListSetItemText(skinGrid, row, colId, skinID, false, false)
		end
	end	
	guiCreateLabel(0.4274,0.0505,0.45,0.05,"Skin price: 3000 GCs",true,skinTab)
	guiCreateLabel(0.4274,0.1009,0.45,0.05,"You can have as many skins as you want, but you are only able to use 1 skin at a time.",true, skinTab)
	exactSkins = guiCreateLabel(0.4274,0.1537,0.55,0.05,"Your ID purchases so far: none",true,skinTab)
	exactSkins2 = guiCreateLabel(0.4274,0.2037,0.55,0.05,"",true,skinTab)
	exactSkins3 = guiCreateLabel(0.4274,0.2537,0.55,0.05,"",true,skinTab)
	failLabel = guiCreateLabel(0.55, 0.75, 0.45, 0.1, "Not enough money/skin already bought", true, skinTab)
	failLabel3 = guiCreateLabel(0.55, 0.75, 0.45, 0.1, "Please input a number.", true, skinTab)
	failLabel2 = guiCreateLabel(0.55, 0.80, 0.45, 0.1, "Or not logged in", true, skinTab)
	successLabel = guiCreateLabel(0.55, 0.75, 0.45, 0.1, "Skin bought successfully!", true, skinTab)
	guiSetVisible(failLabel, false)
	guiSetVisible(failLabel2, false)
	guiSetVisible(successLabel, false)
	guiSetVisible(failLabel3, false)
	local preview = guiCreateButton(0.55, 0.85, 0.15, 0.05, "Preview skin", true,skinTab)
	addEventHandler ( "onClientGUIClick", preview, previewSkin,false )
	local buy = guiCreateButton(0.75, 0.85, 0.15, 0.05, "Buy skin", true,skinTab) 
	addEventHandler ( "onClientGUIClick", buy, buySkin,false)
	local use = guiCreateButton(0.4342,0.5298,0.15,0.05,"Set primary skin",true,skinTab) 
	addEventHandler ( "onClientGUIClick",use, useButton,false)
	--edit = guiCreateEdit(0.4342,0.4151,0.15,0.05, "Enter skin ID", true, skinTab)
	local disable = guiCreateButton(0.4342,0.4151,0.15,0.05, "Disable feature", true,skinTab) 
	--addEventHandler ( "onClientGUIClick", edit, editBox,false)
	addEventHandler ( "onClientGUIClick", disable, disableSkins,false)
	currentID = getElementModel(localPlayer) or 0
end
addEvent('onShopInit', true)
addEventHandler('onShopInit', root, onShopInit )


addEvent("sendPlayerSkinPurchases", true)
addEventHandler("sendPlayerSkinPurchases", root,
function(purchases, current)
	oPurchases = purchases
	oPurchases = ','..oPurchases..','
	currentID = tonumber(current) or 0
	local _table = split(purchases, ',')
	local rows = guiGridListGetRowCount(skinGrid)
	for i, purchase in ipairs(_table) do 
		if i < 10 then
			if guiGetText(exactSkins) == 'Your ID purchases so far: none' then
				guiSetText(exactSkins, "Your ID purchases so far: "..tostring(purchase))
			else
				guiSetText(exactSkins, guiGetText(exactSkins)..','..tostring(purchase))
			end	
		elseif i < 25 then
			if guiGetText(exactSkins2) == '' then
				guiSetText(exactSkins2, tostring(purchase))
			else	
				guiSetText(exactSkins2, guiGetText(exactSkins2)..','..tostring(purchase))
			end	
		else
			if guiGetText(exactSkins3) == '' then
				guiSetText(exactSkins3, tostring(purchase))
			else	
				guiSetText(exactSkins3, guiGetText(exactSkins3)..','..tostring(purchase))
			end	
		end		
	end
	local x,y
	for i = 0, rows do 
		local gridID = guiGridListGetItemText(skinGrid, i, 2)
		if string.find(oPurchases, ','..gridID..',') and not string.find(guiGridListGetItemText(skinGrid, i, 1), 'Group') then
			guiGridListSetItemColor(skinGrid, i, 1, 0, 255, 0)
			guiGridListSetItemColor(skinGrid, i, 2, 0, 255, 0)
		end	
	end
	--guiSetText(exactSkins, "Your ID purchases so far: "..purchases)
	--guiLabelSetHorizontalAlign(exactSkins,"left",true)
end
)


addEvent("skinsLogout", true)
addEventHandler("skinsLogout", root,
function()
	logged = false
	--[[if shopTabPanel and skinTab then
		guiDeleteTab ( skinTab, shopTabPanel )
		skinTab = nil
	end]]
end
)

addEvent("skinsLogin", true)
addEventHandler("skinsLogin", root,
function()
	logged = true
	guiSetText(exactSkins, 'Your ID purchases so far: none')
	guiSetText(exactSkins2, '')
	guiSetText(exactSkins3, '')
	triggerServerEvent('getSkinPurchases', getLocalPlayer())
end
)






