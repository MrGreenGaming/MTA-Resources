CurrentEditRow = false


GUIEditor = {
    label = {},
    button = {},
    window = {},
    gridlist = {},
    memo = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
local screenW, screenH = guiGetScreenSize()
        GUIEditor.window[1] = guiCreateWindow((screenW - 555) / 2, (screenH - 439) / 2, 555, 439, "Manage Chatbox Ads", false)
        guiWindowSetSizable(GUIEditor.window[1], false)
        guiSetVisible( GUIEditor.window[1], false )

        GUIEditor.button[1] = guiCreateButton(456, 397, 82, 32, "Close", false, GUIEditor.window[1])
        guiSetProperty(GUIEditor.button[1], "NormalTextColour", "FFAAAAAA")
        GUIEditor.button[2] = guiCreateButton(246, 397, 82, 32, "Update", false, GUIEditor.window[1])
        guiSetProperty(GUIEditor.button[2], "NormalTextColour", "FFAAAAAA")
        GUIEditor.gridlist[1] = guiCreateGridList(67, 85, 441, 246, false, GUIEditor.window[1])
        guiGridListSetSortingEnabled( GUIEditor.gridlist[1], false )
        guiGridListAddColumn(GUIEditor.gridlist[1], "Ads", 0.9)
        GUIEditor.label[1] = guiCreateLabel(66, 25, 442, 50, "Here you can manage the chatbox ads.\nBe sure to update once you are done!", false, GUIEditor.window[1])
        guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
        GUIEditor.button[3] = guiCreateButton(67, 336, 67, 26, "Add", false, GUIEditor.window[1])
        guiSetProperty(GUIEditor.button[3], "NormalTextColour", "FFAAAAAA")
        GUIEditor.button[4] = guiCreateButton(440, 336, 67, 26, "Remove", false, GUIEditor.window[1])
        guiSetProperty(GUIEditor.button[4], "NormalTextColour", "FFAAAAAA")

		GUIEditor.button[8] = guiCreateButton(156, 336, 67, 26, "Edit", false, GUIEditor.window[1])
        guiSetProperty(GUIEditor.button[8], "NormalTextColour", "FFAAAAAA")


        GUIEditor.window[2] = guiCreateWindow(683, 321, 555, 439, "", false)
        guiSetVisible( GUIEditor.window[2], false )
        guiWindowSetSizable(GUIEditor.window[2], false)

        GUIEditor.memo[1] = guiCreateMemo(63, 89, 439, 240, "", false, GUIEditor.window[2])
        GUIEditor.button[6] = guiCreateButton(218, 341, 98, 32, "OK", false, GUIEditor.window[2])
        guiSetProperty(GUIEditor.button[6], "NormalTextColour", "FFAAAAAA")
        GUIEditor.button[7] = guiCreateButton(404, 341, 98, 32, "Cancel", false, GUIEditor.window[2])
        guiSetProperty(GUIEditor.button[7], "NormalTextColour", "FFAAAAAA")
        GUIEditor.label[2] = guiCreateLabel(59, 30, 443, 44, "Set the ad text.\nBe sure to keep it short! (Big messages will have multiple outputChatBox()'s' )", false, GUIEditor.window[2])
        guiLabelSetHorizontalAlign(GUIEditor.label[2], "center", false)    
    end
)

addEventHandler("onClientGUIClick", root, 
	function()
		if source == GUIEditor.button[1] then
			guiSetVisible(GUIEditor.window[1],false)
			showCursor(false)
		elseif source == GUIEditor.button[3] then
			editnewText("new")
			guiSetVisible(GUIEditor.window[1],false)
			guiSetVisible(GUIEditor.window[2],true)
		elseif source == GUIEditor.button[7] then
			CurrentEditRow = false
			guiSetVisible(GUIEditor.window[1],true)
			guiSetVisible(GUIEditor.window[2],false)
		elseif source == GUIEditor.button[4] then
			removeAd()
		elseif source == GUIEditor.button[6] then
			saveAd()
		elseif source == GUIEditor.button[8] then
			editAd()
		elseif source == GUIEditor.button[2] then
			updateAds()


		end end)

addEventHandler("onClientGUIFocus", root,
	function()
		if source == GUIEditor.memo[1] then
			guiSetInputMode( "no_binds" )
		end end)

addEventHandler("onClientGUIBlur", root,
	function()
		if source == GUIEditor.memo[1] then
			guiSetInputMode( "allow_binds" )
		end end)


function editAd()
	local item = guiGridListGetSelectedItem( GUIEditor.gridlist[1] )
	if item == -1 then return end
	CurrentEditRow = item

	editnewText("edit")

	local rowtext = guiGridListGetItemData( GUIEditor.gridlist[1], item,1 )
	guiSetText( GUIEditor.memo[1], rowtext )
	guiSetVisible(GUIEditor.window[1],false)
	guiSetVisible(GUIEditor.window[2],true)
end
function removeAd()
	local item = guiGridListGetSelectedItem( GUIEditor.gridlist[1] )
	if item == -1 then return end

	guiGridListRemoveRow( GUIEditor.gridlist[1], item )
end

function saveAd()
	guiGridListAutoSizeColumn(GUIEditor.gridlist[1],1)
	local text = guiGetText(GUIEditor.memo[1])
	if #text < 1 then outputChatBox("Message too short!",255,0,0) return end
	local text = string.gsub(text,"\n"," ") -- remove linebreaks

	if windowmode == "new" then
		local row = guiGridListAddRow( GUIEditor.gridlist[1] )
		guiGridListSetItemText( GUIEditor.gridlist[1], row, 1, text, false, false )
		guiGridListSetItemData( GUIEditor.gridlist[1], row, 1, text)
		outputChatBox("Message added to ad queue, don't forget to update!",0,255,0)
		guiSetVisible(GUIEditor.window[1],true)
		guiSetVisible(GUIEditor.window[2],false)
	elseif windowmode == "edit" then
		local row = CurrentEditRow
		guiGridListSetItemText( GUIEditor.gridlist[1], row, 1, text, false, false )
		guiGridListSetItemData( GUIEditor.gridlist[1], row, 1, text)
		outputChatBox("Message edited, don't forget to update!",0,255,0)
		guiSetVisible(GUIEditor.window[1],true)
		guiSetVisible(GUIEditor.window[2],false)
	end
end

addEvent("editChatboxAds", true)
addEventHandler("editChatboxAds", resourceRoot, 
	function(tbl)
		populateAdsGridlist(tbl)
		guiSetVisible(GUIEditor.window[1],true)
		showCursor(true)
		end)

function populateAdsGridlist(tbl)
	guiGridListClear( GUIEditor.gridlist[1] )
	for f, u in ipairs(tbl) do
		local row = guiGridListAddRow( GUIEditor.gridlist[1] )
		guiGridListSetItemText( GUIEditor.gridlist[1], row, 1, u, false, false )
		guiGridListSetItemData( GUIEditor.gridlist[1], row, 1, u)
	end
	guiGridListAutoSizeColumn(GUIEditor.gridlist[1],1)
end


function editnewText(td)
	if td == "edit" then
		windowmode = "edit"
		guiSetText( GUIEditor.window[2], "Edit chatbox ad" )
	elseif td == "new" then
		windowmode = "new"
		guiSetText(GUIEditor.memo[1],"")
		guiSetText( GUIEditor.window[2], "Add new chatbox ad" )
	end
end

function updateAds()
	local niuAdTable = {}
	local rowCount = guiGridListGetRowCount( GUIEditor.gridlist[1] )
	local rowCount = rowCount - 1
	


	for i=0,rowCount do

		local theText = guiGridListGetItemData( GUIEditor.gridlist[1], i, 1 )
		table.insert(niuAdTable,theText)
	end

	rowLoop = nil
	triggerServerEvent( "clientSendNewAds", root, niuAdTable )
	outputChatBox("New ad list updated and is now in queue!",0,255,0)
end


