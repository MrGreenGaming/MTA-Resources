
local locknickGUI = {
    tab = {},
    label = {},
    button = {},
    gridlist = {},
    glcolumn = {}
}
local thePanel = false
local slotsUsed,maxAmount,nickTable,locknickAllowed
function createLockNickGUI(tp)
    thePanel = tp
    locknickGUI.tab[1] = guiCreateTab("Locked Nicks", tp)

    locknickGUI.label[1] = guiCreateLabel(49, 17, 376, 23, "In this tab you can manage your locked nicknames.", false, locknickGUI.tab[1])
    guiSetFont(locknickGUI.label[1], "default-bold-small")
    locknickGUI.label[2] = guiCreateLabel(50, 47, 651, 67, "To lock your current nickname you have to click on \"Lock current nickname\". \nTo remove a locked nick, select the nick in the gridlist, then click on \"Remove selected nick\". \nIf you are in need of some extra locked nicknames, you can buy extra slots. Click on \"Buy extra lock nick slot\" to do so. \nTrolling and deliberate nickstealing can get you banned.", false, locknickGUI.tab[1])
    locknickGUI.gridlist[1] = guiCreateGridList(46, 139, 363, 267, false, locknickGUI.tab[1])
    guiGridListSetSortingEnabled(locknickGUI.gridlist[1],false)
    locknickGUI.glcolumn[1] = guiGridListAddColumn(locknickGUI.gridlist[1], "My Locked Nicknames", 0.9)
    locknickGUI.label[3] = guiCreateLabel(46, 118, 363, 21, "0/0 nickname slots in use", false, locknickGUI.tab[1])
    guiSetFont(locknickGUI.label[3], "default-bold-small")
    guiLabelSetHorizontalAlign(locknickGUI.label[3], "center", false)
    guiLabelSetVerticalAlign(locknickGUI.label[3], "center")

    locknickGUI.button[1] = guiCreateButton(425, 140, 171, 49, "Lock current nickname", false, locknickGUI.tab[1])
    guiSetProperty(locknickGUI.button[1], "NormalTextColour", "FFAAAAAA")


    locknickGUI.button[2] = guiCreateButton(426, 211, 170, 28, "Remove selected nickname", false, locknickGUI.tab[1])
    guiSetProperty(locknickGUI.button[2], "NormalTextColour", "FFAAAAAA")
    locknickGUI.label[4] = guiCreateLabel(420, 361, 400, 19, "Current price: 750 GC per extra slot (max: 10 slots)", false, locknickGUI.tab[1])
    locknickGUI.button[3] = guiCreateButton(422, 382, 164, 28, "Buy extra locknick slot", false, locknickGUI.tab[1])
    guiSetProperty(locknickGUI.button[3], "NormalTextColour", "FFAAAAAA")
    translateLockedNicksGUI()
end
addEventHandler('onShopInit', getResourceRootElement(), createLockNickGUI )
addCommandHandler('unlocknick',function() if not guiGetVisible(locknickGUI.tab[1]) then executeCommandHandler("gcshop") end guiSetSelectedTab(thePanel,locknickGUI.tab[1]) end)
addCommandHandler('locknick',function() if not guiGetVisible(locknickGUI.tab[1]) then executeCommandHandler("gcshop") end guiSetSelectedTab(thePanel,locknickGUI.tab[1]) end)

function translateLockedNicksGUI()
    guiSetText(locknickGUI.label[1], _("In this tab you can manage your locked nicknames."))
    guiSetText(locknickGUI.label[2], _('To lock your current nickname you have to click on "${btn1}". \nTo remove a locked nick, select the nick in the gridlist, then click on "${btn2}". \nIf you are in need of some extra locked nicknames, you can buy extra slots. Click on "${btn3}" to do so. \nTrolling and deliberate nickstealing can get you banned.') % {btn1=_("Lock current nickname"), btn2=_("Remove selected nick"), btn3=_("Buy extra lock nick slot")})
    guiGridListSetColumnTitle(locknickGUI.gridlist[1], locknickGUI.glcolumn[1], _("My Locked Nicknames"))
    guiSetText(locknickGUI.button[1], _("Lock current nickname"))
    guiSetText(locknickGUI.button[2], _("Remove selected nickname"))
    guiSetText(locknickGUI.label[4], _("Current price: ${price} GC per extra slot (max: ${slots} slots)") % {price=750, slots=10})
    guiSetText(locknickGUI.button[3], _("Buy extra locknick slot"))
    guiSetText(locknickGUI.label[3], _("${used}/${max} nickname slots in use") % {used=tostring(slotsUsed or 0), max=tostring(maxAmount or 10)})
end
addEventHandler("onClientPlayerLocaleChange", root, translateLockedNicksGUI)

function handleSlotAmountLabel()
    local label = locknickGUI.label[3]
    local used = slotsUsed
    local max = maxAmount

    guiSetText(label,_("${used}/${max} nickname slots in use") % {used=tostring(used), max=tostring(max)})
    if tonumber(used) >= tonumber(max) then
        -- make text red
        guiLabelSetColor(label,255,0,0)
    else
        guiLabelSetColor(label,0,255,0)
    end
end
addEvent("onPlayerLockNickSlotPurchase",true)
addEventHandler("onPlayerLockNickSlotPurchase",root,function() maxAmount = maxAmount + 1 handleSlotAmountLabel() end)

function populateLockNickGridList()
    local gl = locknickGUI.gridlist[1]
    local cl = locknickGUI.glcolumn[1]
    guiGridListClear(gl)
    for _,nick in ipairs(nickTable) do
        local row = guiGridListAddRow(gl)
        guiGridListSetItemText(gl,row,cl,tostring(nick),false,false)
    end
end

function receiveLocknickInfo(nT,amount)
    nickTable = nT
    slotsUsed = #nT
    maxAmount = amount
    handleSlotAmountLabel()
    populateLockNickGridList()
end
addEvent("serverSendLockedNickInfo",true)
addEventHandler("serverSendLockedNickInfo",root,receiveLocknickInfo)


local buttonSpamTimer = false
local buttonSpamCooldown = 750
function lockednicksButtonHandler()

    if source == locknickGUI.button[1] then -- locknick
        if slotsUsed >= maxAmount then outputChatBox(_("Maximum locked nicknames reached. Please buy more slots if you wish to lock more nicknames.")) return end
        triggerServerEvent("clientNickLockAction",resourceRoot,safeStringNick(getPlayerName(localPlayer)),true)


    elseif source == locknickGUI.button[2] then -- unlocknick
        local selnam = getSelectedLockedName()

        if not selnam or #selnam == 0 then outputChatBox(_("Please select a name before removing it"),255,0,0) return end

        if selnam then triggerServerEvent("clientNickLockAction",resourceRoot,selnam,false) end


    elseif source == locknickGUI.button[3] then -- buy more slots
         if isTimer(buttonSpamTimer) then outputChatBox(_("Please do not spam click buttons"),255,0,0) return end
         buttonSpamTimer = setTimer(function()end,buttonSpamCooldown,1)
        if maxAmount < 10 then -- Max 10 slots
            triggerServerEvent("onPlayerBuyLockedNickSlot",resourceRoot)
        else
            outputChatBox(_("Maximum amount of nickname slots reached (${max})") % {max=10},255,0,0)

        end

    end
end
addEventHandler("onClientGUIClick",root,lockednicksButtonHandler)


function getSelectedLockedName()
    return guiGridListGetItemText ( locknickGUI.gridlist[1], guiGridListGetSelectedItem ( locknickGUI.gridlist[1] ), 1 )
end


function safeStringNick(playerName)
    playerName = string.gsub(playerName, "?", "")
    playerName = string.gsub(playerName, "'", "")
    playerName = string.gsub (playerName, "#%x%x%x%x%x%x", "")
    return playerName
end


function receiveLocknickResults(nick,addOrRemove)
    if addOrRemove == "add" then
        table.insert(nickTable,nick)
        slotsUsed = #nickTable
        handleSlotAmountLabel()
        populateLockNickGridList()
    elseif addOrRemove == "remove" then
        local rem = false
        for k,n in ipairs(nickTable) do
            if n == nick then
                table.remove(nickTable,k)
                rem = true
                break
            end
        end
        if not rem then
            triggerServerEvent("clientRefreshNicks",localPlayer)
        else
            slotsUsed = #nickTable
            handleSlotAmountLabel()
            populateLockNickGridList()
        end
    end
end
addEvent("onServerSendLocknickResults",true)
addEventHandler("onServerSendLocknickResults",root,receiveLocknickResults)

function resetLockedNicksGUI()
    slotsUsed = false
    maxAmount = false
    nickTable = false
    locknickAllowed = false
    local gl = locknickGUI.gridlist[1]
    guiGridListClear(gl)
end
addEvent('cShopGCLogout',true)
addEventHandler('cShopGCLogout',root,resetLockedNicksGUI)


