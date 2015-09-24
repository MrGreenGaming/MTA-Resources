-----------------------
--    Shop by SDK    --
--   gcshop_c.lua    --
-----------------------
shop_GUI = nil
amount_GCS = 0;
forumID = nil
------------------------------------
-- Building and toggling the shop --
------------------------------------

addEvent('onShopInit')
function startUp()
	if not shop_GUI then
		shop_GUI = build_mainGCShopWindow()
		if shop_GUI then
			guiSetVisible(shop_GUI._root, false)
			bindKey('F6', 'down', 'gcshop')
			triggerServerEvent('onShopInit', localPlayer)
			triggerEvent('onShopInit', resourceRoot, shop_GUI['shopTabs'])
		end
	end
end
addEventHandler('onClientResourceStart', resourceRoot, startUp)

function toggleShop(l)
	
	if not shop_GUI or not guiGetVisible(shop_GUI._root) then
		showShop()
	else
		hideShop()
	end
end
addCommandHandler("gcshop", toggleShop, true)

addEvent('onShopToggle')
function showShop()
	if not shop_GUI then
		shop_GUI = build_mainGCShopWindow()
	else
		guiSetVisible(shop_GUI._root, true)
	end
	addEventHandler('onClientGUIClick', shop_GUI._root, focus)
	addEventHandler('onClientGUIChanged', shop_GUI._root, focus)
	showCursor(true)
	guiSetInputEnabled(false)
	guiSetInputMode('no_binds_when_editing');
	triggerEvent('onShopToggle', resourceRoot, true)

end

function hideShop()
	if not shop_GUI then
		return
	end
	if colorPicker.isSelectOpen then
		closedColorPicker()
	end
	guiSetVisible(shop_GUI._root, false)
	removeEventHandler('onClientGUIClick', shop_GUI._root, focus)
	removeEventHandler('onClientGUIChanged', shop_GUI._root, focus)
	guiSetInputEnabled(false)
	guiSetInputMode('no_binds_when_editing');
	showCursor(false)
	triggerEvent('onShopToggle', resourceRoot, false)
end

function focus()
	local focus = {}
	focus[shop_GUI['edit_user_gc']] = true
	focus[shop_GUI['edit_pass_gc']] = true
	guiSetInputEnabled( focus[source] == true )
	guiSetInputMode('no_binds_when_editing');
end


----------------------
--  Login/register  --
----------------------

local loggedInGC = false
function gcLogin ( forumID_, amount )
	guiSetText(shop_GUI["labelGreencoins"], 'Greencoins: ' .. tostring(tonumber(amount) or 0))
	guiLabelSetColor(shop_GUI["labelGreencoins"], 0x00, 0xAA, 0x00 )
	
	guiSetText(shop_GUI["labelLoginInfo"], "You successfully logged in!\n\nYour account is linked and will be auto logged in from now on!")
	guiSetText(shop_GUI["buttonLink"], "Logout")
	guiLabelSetColor(shop_GUI["labelLoginInfo"], 0x00, 0xFF, 0x00 )
	loggedInGC = true
	amount_GCS = tonumber(amount) or 0;
	forumID = forumID_;
end
addEvent("cShopGCLogin" , true )
addEventHandler("cShopGCLogin" , root, gcLogin )

function gcLoginFail(alreadyLoggedIn)
	guiSetText(shop_GUI["buttonLink"], "Login")
    if alreadyLoggedIn then
		guiSetText(shop_GUI["labelGreencoins"], '')
		guiSetText(shop_GUI["labelLoginInfo"], "You are already logged in!")
    else
		forumID = nil;
		guiSetText(shop_GUI["labelLoginInfo"], "Wrong email or password entered!\n\n(Have you set up your Green-Coins account?\nIf not, visit left4green.com -> Green-Coins to do so!)")
    end
	guiLabelSetColor(shop_GUI["labelLoginInfo"], 0xFF, 0x00, 0x00 )
end
addEvent("onLoginFail", true)
addEventHandler("onLoginFail", root, gcLoginFail)

function gcLogout(initShop)
	guiSetText(shop_GUI["buttonLink"], "Login")
	guiSetText(shop_GUI["labelGreencoins"], '')
	guiSetText(shop_GUI["labelLoginInfo"], "Not logged in!")
	guiLabelSetColor(shop_GUI["labelLoginInfo"], 0x00, 0xFF, 0x00 )
	loggedInGC = false
	forumID = nil;
end
addEvent("cShopGCLogout" , true )
addEventHandler("cShopGCLogout", root, gcLogout)		

function gcChange ( amount )
	if not amount then
		amount_GCS = 0;
		guiSetText(shop_GUI["labelGreencoins"], '')
	else
		amount_GCS = tonumber(amount) or 0;
		guiSetText(shop_GUI["labelGreencoins"], 'Greencoins: ' .. tostring(tonumber(amount) or 0))
	end
end
addEvent("onGCChange", true)
addEventHandler("onGCChange", root, gcChange)

function on_buttonLink_clicked(button, state, absoluteX, absoluteY)
	if (button ~= "left") or (state ~= "up") then
		return
	end
	local user = guiGetText ( shop_GUI["edit_user_gc"] )
	local pass = guiGetText ( shop_GUI["edit_pass_gc"] )
	if not loggedInGC then
		executeCommandHandler('gclogin', user .. ' ' .. pass )
	else
		executeCommandHandler('gclogout')
	end
end

function startMsg ()
	setTimer(	
		function()
			if not loggedInGC then
				outputChatBox ("Press F6 to get Green-Coins and buy items in the shop! ", 0, 255, 0)
			end
		end
		, 10000, 1)
end

addEventHandler("onClientResourceStart", getResourceRootElement(), startMsg)

addEvent("sb_showGCShop")
addEventHandler("sb_showGCShop",root,function()

	if not shop_GUI or not guiGetVisible(shop_GUI._root) then
		showShop()
		guiSetSelectedTab(shop_GUI["shopTabs"],shop_GUI["tab_home"])

	elseif guiGetVisible(shop_GUI._root) and guiGetSelectedTab(shop_GUI["shopTabs"]) ~= shop_GUI["tab_home"] then
		guiSetSelectedTab(shop_GUI["shopTabs"],shop_GUI["tab_home"])

	else
		hideShop()
	end
	
end)

addEvent("sb_showMyAccount")
addEventHandler("sb_showMyAccount",root,function()

	if not shop_GUI or not guiGetVisible(shop_GUI._root) then
		showShop()
		guiSetSelectedTab(shop_GUI["shopTabs"],shop_GUI["tab_login"])

	elseif guiGetVisible(shop_GUI._root) and guiGetSelectedTab(shop_GUI["shopTabs"]) ~= shop_GUI["tab_login"] then
		guiSetSelectedTab(shop_GUI["shopTabs"],shop_GUI["tab_login"])
	else
		hideShop()
	end

	
end)

