-----------------------
-- Shop by SDK    --
-- gcshop_c.lua    --
-----------------------
shop_GUI = nil
amount_GCS = 0
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
    focus[shop_GUI['edit_reg_user']] = true
    focus[shop_GUI['edit_reg_email']] = true
    focus[shop_GUI['edit_reg_pass']] = true
    focus[shop_GUI['edit_reg_pass2']] = true
    guiSetInputEnabled(focus[source] == true)
    guiSetInputMode('no_binds_when_editing');
end


----------------------
-- Login/register  --
----------------------

local loggedInGC = false
function gcLogin(forumID_, amount)
    guiSetText(shop_GUI["labelGreencoinsShadow1"], tostring(comma_value(tonumber(amount)) or 0) .. ' GreenCoins')
    guiLabelSetColor(shop_GUI["labelGreencoinsShadow1"], 0, 0, 0)

    guiSetText(shop_GUI["labelGreencoins"], tostring(comma_value(tonumber(amount)) or 0) .. ' GreenCoins')
    guiLabelSetColor(shop_GUI["labelGreencoins"], 0, 255, 0)


    guiSetText(shop_GUI["labelLoginInfo"], "You successfully logged in!\n\nYour account is linked and will be auto logged in from now on.")
    guiSetText(shop_GUI["buttonLink"], "Logout")
    guiLabelSetColor(shop_GUI["labelLoginInfo"], 0x00, 0xFF, 0x00)

    if shop_GUI["buttonRegister"] then
        guiSetEnabled(shop_GUI["buttonRegister"], false)
        guiSetText(shop_GUI["edit_reg_pass"], "")
        guiSetText(shop_GUI["edit_reg_pass2"], "")
        guiSetText(shop_GUI["labelRegisterInfo"], "You are logged in!\n\nYour account is linked and will be auto logged in from now on.")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0x00, 0xFF, 0x00)
    end

    loggedInGC = true
    amount_GCS = tonumber(amount) or 0;
    forumID = forumID_;
end

addEvent("cShopGCLogin", true)
addEventHandler("cShopGCLogin", root, gcLogin)

function gcLoginFail()
    guiSetText(shop_GUI["buttonLink"], "Login")
    loggedInGC = false
    forumID = nil
    guiSetText(shop_GUI["labelLoginInfo"], "Wrong username/emailaddress or password! There is a Lost Password functionality on the Forums.")
    guiLabelSetColor(shop_GUI["labelLoginInfo"], 0xFF, 0x00, 0x00)
end

addEvent("onLoginFail", true)
addEventHandler("onLoginFail", root, gcLoginFail)

function gcRegisterFail(errorMessage)
    if shop_GUI and shop_GUI["buttonRegister"] then
        guiSetEnabled(shop_GUI["buttonRegister"], true)
        guiSetText(shop_GUI["labelRegisterInfo"], tostring(errorMessage or "Registration failed. Please try again."))
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
    end
end

addEvent("onRegisterFail", true)
addEventHandler("onRegisterFail", root, gcRegisterFail)

function gcLogout(initShop)
    guiSetText(shop_GUI["buttonLink"], "Login")
    guiSetText(shop_GUI["labelGreencoinsShadow1"], '')
    guiSetText(shop_GUI["labelGreencoins"], '')
    guiSetText(shop_GUI["labelLoginInfo"], "Not logged in!")
    guiLabelSetColor(shop_GUI["labelLoginInfo"], 0x00, 0xFF, 0x00)
    if shop_GUI["buttonRegister"] then
        guiSetEnabled(shop_GUI["buttonRegister"], true)
        guiSetText(shop_GUI["labelRegisterInfo"], "")
    end
    loggedInGC = false
    forumID = nil
end

addEvent("cShopGCLogout", true)
addEventHandler("cShopGCLogout", root, gcLogout)

function gcChange(amount)
    if not amount then
        amount_GCS = 0
        guiSetText(shop_GUI["labelGreencoinsShadow1"], '')
        guiSetText(shop_GUI["labelGreencoins"], '')
    else
        amount_GCS = tonumber(amount) or 0
        guiSetText(shop_GUI["labelGreencoinsShadow1"], tostring(comma_value(tonumber(amount)) or 0) .. ' GreenCoins')
        guiSetText(shop_GUI["labelGreencoins"], tostring(comma_value(tonumber(amount)) or 0) .. ' GreenCoins')
    end
end

addEvent("onGCChange", true)
addEventHandler("onGCChange", root, gcChange)

function on_buttonLink_clicked(button, state, absoluteX, absoluteY)
    if (button ~= "left") or (state ~= "up") then
        return
    end
    local user = guiGetText(shop_GUI["edit_user_gc"])
    local pass = guiGetText(shop_GUI["edit_pass_gc"])
    if not loggedInGC then
        triggerServerEvent("onLogin", localPlayer, user, pass)
    else
        triggerServerEvent("onLogout", localPlayer)
    end
end

function on_buttonRegister_clicked(button, state, absoluteX, absoluteY)
    if (button ~= "left") or (state ~= "up") then
        return
    end
    if loggedInGC then
        guiSetText(shop_GUI["labelRegisterInfo"], "You are already logged in! Please logout first if you want to create a new account.")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end

    local username = guiGetText(shop_GUI["edit_reg_user"]) or ""
    local email = guiGetText(shop_GUI["edit_reg_email"]) or ""
    local pass = guiGetText(shop_GUI["edit_reg_pass"]) or ""
    local pass2 = guiGetText(shop_GUI["edit_reg_pass2"]) or ""

    if #username < 3 or #username > 150 then
        guiSetText(shop_GUI["labelRegisterInfo"], "Invalid Username: Must be at least 3 characters long.")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end
    if string.find(username, "%s") then
        guiSetText(shop_GUI["labelRegisterInfo"], "Username can not contain whitespaces.")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end
    if not string.match(username, "^[a-zA-Z0-9_]+$") then
        guiSetText(shop_GUI["labelRegisterInfo"], "Username can only contain numbers, letters and _")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end

    if #email < 4 or not string.find(email, "@", 1, true) or not string.find(email, ".", 1, true) then
        guiSetText(shop_GUI["labelRegisterInfo"], "Email is not valid.")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end

    if #pass < 8 or #pass > 150 then
        guiSetText(shop_GUI["labelRegisterInfo"], "Invalid Password: Must be at least 8 characters long.")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end
    if not string.find(pass, "[a-z]") then
        guiSetText(shop_GUI["labelRegisterInfo"], "Password must contain a lower case letter.")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end
    if not string.find(pass, "[A-Z]") then
        guiSetText(shop_GUI["labelRegisterInfo"], "Password must contain an upper case letter.")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end
    if not string.find(pass, "[^a-zA-Z]") then
        guiSetText(shop_GUI["labelRegisterInfo"], "Password must contain a number or special character.")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end
    if pass ~= pass2 then
        guiSetText(shop_GUI["labelRegisterInfo"], "Passwords do not match!")
        guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0x00, 0x00)
        return
    end

    guiSetEnabled(shop_GUI["buttonRegister"], false)
    guiSetText(shop_GUI["labelRegisterInfo"], "Registering account, please wait...")
    guiLabelSetColor(shop_GUI["labelRegisterInfo"], 0xFF, 0xFF, 0x00)

    triggerServerEvent("onRegister", localPlayer, username, pass, email)
end

function startMsg()
    setTimer(function()
        if not loggedInGC then
            outputChatBox("Press F6 to buy items in the GreenCoins shop.", 0, 255, 0)
        end
    end, 10000, 1)
end

addEventHandler("onClientResourceStart", getResourceRootElement(), startMsg)

addEvent("sb_showGCShop")
addEventHandler("sb_showGCShop", root, function()
    if not shop_GUI or not guiGetVisible(shop_GUI._root) then
        showShop()
        guiSetSelectedTab(shop_GUI["shopTabs"], shop_GUI["tab_home"])
    elseif guiGetVisible(shop_GUI._root) and guiGetSelectedTab(shop_GUI["shopTabs"]) ~= shop_GUI["tab_home"] then
        guiSetSelectedTab(shop_GUI["shopTabs"], shop_GUI["tab_home"])
    else
        hideShop()
    end
end)

addEvent("sb_showMyAccount")
addEventHandler("sb_showMyAccount", root, function()

    if not shop_GUI or not guiGetVisible(shop_GUI._root) then
        showShop()
        guiSetSelectedTab(shop_GUI["shopTabs"], shop_GUI["tab_login"])

    elseif guiGetVisible(shop_GUI._root) and guiGetSelectedTab(shop_GUI["shopTabs"]) ~= shop_GUI["tab_login"] then
        guiSetSelectedTab(shop_GUI["shopTabs"], shop_GUI["tab_login"])
    else
        hideShop()
    end
end)

--http://lua-users.org/wiki/FormattingNumbers
function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
        if k == 0 then
            break
        end
    end
    return formatted
end