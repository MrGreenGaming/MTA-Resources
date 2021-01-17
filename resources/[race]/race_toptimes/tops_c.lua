local tops = 10
local posx, posy = 0.55, 0.015
local sizex, sizey = 350, 46+15*(tops+1)
local image = 'backg1a.png'
local imageColor = tocolor(255,255,255,255)
local titleHeight = 38
local topsAreaHeight = 230
local personalTopHeight = 34
local monthlyTopHeight = 34
local textColor = tocolor(255,255,255)
local selfTextColor = tocolor(0,255,255)
local scaleX, scaleY = 1, 1
local font = 'default-bold'
local pos = {x=0.0,y=0.08}
local nick = {x=0.16,y=0.4}
local flag = {x=0.095,y=0.0}
local value = {x=0.5,y=0.7}
local date = {x=0.7,y=0.95}
local fadeTime = 300
local showTime = 15000

local resx, resy = guiGetScreenSize()
posx, posy = math.floor(posx*resx), math.floor(posy*resy)
local texture = dxCreateTexture(image)
local w,h = dxGetMaterialSize(texture)
local sw,sh = sizex/w,sizey/h
local target = dxCreateRenderTarget(sizex, sizey, true)
local times = {}
local monthlyTopTime
local alpha = 0
local fading = 0
local timer = nil
local tick
local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

addEvent('updateTopTimes', true)
addEventHandler('updateTopTimes', resourceRoot, function(t)
	times = t
	updateTexture()
end)

addEvent('updateMonthTime', true)
addEventHandler('updateMonthTime', resourceRoot, function(t)
	monthlyTopTime = t
	updateTexture()
end)

addEventHandler('onClientResourceStart', resourceRoot,
	function()
		triggerServerEvent('clientstarted', resourceRoot)
	end
)

addEventHandler('onClientMapStarting', getRootElement(),
	function(mapinfo)
		toggleTimes(true)
	end
)

addEvent('onClientPlayerFinish')
addEventHandler('onClientPlayerFinish', getRootElement(),
	function()
		toggleTimes(true)
	end
)

function toggleTimes(b)
	if timer then
		if isTimer(timer) then
			killTimer(timer)
		end
		timer = nil
	end
	if b or fading == -1 or (fading == 0 and alpha < 1) then
		fading = 1
		timer = setTimer(toggleTimes, showTime, 1)
	else
		fading = -1
	end
	tick = getTickCount()
end
addCommandHandler('showtops', function()
	toggleTimes(true)
end)
bindKey('F5', 'down', function() toggleTimes() end)

function updateTexture()
	dxSetRenderTarget(target, true)
	--dxDrawImage(0,0,sizex,sizey,texture,0,0,0,imageColor)
	dxDrawRectangle(0, 0, 446, 334, tocolor(0, 0, 0, 200), isPostGUI,false) --background
	dxDrawRectangle(0, 0, 446, 23, tocolor(11, 138, 25, 255), isPostGUI,false) --title
	dxDrawRectangle(0, 0, 446, 12.5, tocolor(11, 180, 25, 255), isPostGUI,false) --title glass effect
	dxDrawRectangle(0, 167, 446, 1, tocolor(255, 255, 255, 100), isPostGUI,false) --line1
	dxDrawRectangle(0, 188, 446, 1, tocolor(255, 255, 255, 100), isPostGUI,false) --line2
	dxDrawText('Top Times - ' .. string.sub((times.mapname or ''), 1, 35), 0, 0, w*sw, titleHeight*sh, textColor, scaleX, scaleY, font, 'center', 'center', true)
	local i = 1
	for k, r in ipairs(times) do
		local textColor = r.player == localPlayer and selfTextColor or textColor
		-- Name handling
		local playerName = r.name or r.mta_name or "Unknown Player"
		if r.supernick and type(r.supernick) == "string" then
			local sn = fromJSON( r.supernick )
			if sn.supernick then
				playerName = sn.supernick
			end
		end


		if k <= tops then
			dxDrawText(k..'.', w*pos.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*pos.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
			dxDrawText((playerName), w*nick.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*nick.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'left', 'center', true, false, false, true)
			if r.country ~= nil and type(r.country) == 'string' then dxDrawImage(w*flag.x*sw, (titleHeight+(i-0.85)*topsAreaHeight/tops)*sh, 16, 11, ":admin/client/images/flags_new/"..string.lower(r.country)..".png") end
			dxDrawText(times.kills and r.value..' kills' or timeMsToTimeText(r.value), w*value.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*value.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'center', 'center')
			dxDrawText(r.formatDate, w*date.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*date.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
			i = i + 1
		end
		if r.player == localPlayer then
			dxDrawText(k..'.', w*pos.x*sw, (titleHeight+topsAreaHeight)*sh, w*pos.y*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
			dxDrawText((playerName), w*nick.x*sw, (titleHeight+topsAreaHeight)*sh, w*nick.y*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, textColor, scaleX, scaleY, font, 'left', 'center', true, false, false, true)
			if r.country ~= nil then dxDrawImage(w*flag.x*sw, (titleHeight+topsAreaHeight+6.5)*sh, 16, 11, ":admin/client/images/flags_new/"..string.lower(r.country)..".png") end
			dxDrawText(times.kills and r.value..' kills' or timeMsToTimeText(r.value), w*value.x*sw, (titleHeight+(tops)*topsAreaHeight/tops)*sh, w*value.y*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, textColor, scaleX, scaleY, font, 'center', 'center')
			dxDrawText(r.formatDate, w*date.x*sw, (titleHeight+(tops)*topsAreaHeight/tops)*sh, w*date.y*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
		end
	end
	local s = i
	for i = s,tops do
		dxDrawText(i..'.', w*pos.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*pos.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
		dxDrawText('-- Empty --', w*nick.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*nick.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'left', 'center')
	end
	if monthlyTopTime then
		local monthlyTopPlayerName = monthlyTopTime.name or monthlyTopTime.mta_name
		if monthlyTopTime.supernick and type(monthlyTopTime.supernick) == "string" and fromJSON(monthlyTopTime.supernick) then
			local sn = fromJSON(monthlyTopTime.supernick)
			if sn.supernick then
				monthlyTopPlayerName = sn.supernick
			end
		end
		local textColor = monthlyTopTime.player == localPlayer and selfTextColor or textColor
		dxDrawText(months[monthlyTopTime.month], w*pos.x*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, w*pos.y*sw, (titleHeight+topsAreaHeight+personalTopHeight+monthlyTopHeight)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
		dxDrawText((monthlyTopPlayerName), w*nick.x*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, w*nick.y*sw, (titleHeight+topsAreaHeight+personalTopHeight+monthlyTopHeight)*sh, textColor, scaleX, scaleY, font, 'left', 'center', true, false, false, true)
		if monthlyTopTime.country ~= nil and type(monthlyTopTime.country) == 'string' then dxDrawImage(w*flag.x*sw, (titleHeight+topsAreaHeight+personalTopHeight+7.6)*sh, 16, 11, ":admin/client/images/flags_new/"..string.lower(monthlyTopTime.country)..".png") end
		dxDrawText(monthlyTopTime.kills and monthlyTopTime.value..' kills' or timeMsToTimeText(monthlyTopTime.value), w*value.x*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, w*value.y*sw, (titleHeight+topsAreaHeight+personalTopHeight+monthlyTopHeight)*sh, textColor, scaleX, scaleY, font, 'center', 'center')
		dxDrawText(monthlyTopTime.formatDate, w*date.x*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, w*date.y*sw, (titleHeight+topsAreaHeight+personalTopHeight+monthlyTopHeight)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
	end
	dxSetRenderTarget()
end
addEventHandler("onClientRestore",root,updateTexture)

addEventHandler('onClientRender', root, function()
	if fading ~= 0 then
		local t = getTickCount() + 1
		if fading == 1 then
			alpha = (t - tick)/(fadeTime)*255
		else
			alpha = (1-(t - tick)/(fadeTime))*255
		end
		if alpha <= 0 then
			alpha = 0
			fading = 0
		elseif alpha >= 255 then
			alpha = 255
			fading = 0
		end
	end
	if alpha > 0 then
		dxDrawImage(posx, posy, sizex, sizey, target, 0, 0, 0, tocolor(255,255,255,alpha))
	end
end)

function timeMsToTimeText( timeMs )

	local minutes	= math.floor( timeMs / 60000 )
	timeMs			= timeMs - minutes * 60000;

	local seconds	= math.floor( timeMs / 1000 )
	local ms		= timeMs - seconds * 1000;

	return string.format( '%2d:%02d:%03d', minutes, seconds, ms );
end

function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

--------------------
-- Delete top GUI --
--------------------

local topsManager = {
	mapname = false,
	tops = false
}
confirmGUI = {
    button = {},
    window = {},
    combobox = {},
    label = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
		local screenW, screenH = guiGetScreenSize()
		confirmGUI.window[1] = guiCreateWindow((screenW - 672) / 2, (screenH - 528) / 2, 672, 528, "TopTimes Manager", false)
		guiSetVisible( confirmGUI.window[1], false )
        guiWindowSetSizable(confirmGUI.window[1], false)
        guiSetAlpha(confirmGUI.window[1], 0.94)

		guiSetInputMode("no_binds_when_editing") --Calls guiSetInputMode once and for all to not have to handle binds state dynamically

        confirmGUI.button[1] = guiCreateButton(460, 461, 150, 46, "Accept", false, confirmGUI.window[1])
		guiSetProperty(confirmGUI.button[1], "NormalTextColour", "FF0CFE00")
		addEventHandler('onClientGUIClick',confirmGUI.button[1], topsManagerAccepted, false)
		confirmGUI.button[2] = guiCreateButton(56, 463, 150, 46, "Cancel", false, confirmGUI.window[1])
		addEventHandler('onClientGUIClick',confirmGUI.button[2], topsManagerCanceled, false)
        guiSetProperty(confirmGUI.button[2], "NormalTextColour", "FFFD0000")
		confirmGUI.toplist = guiCreateGridList(56, 84, 246, 312, false, confirmGUI.window[1])
		guiGridListSetSortingEnabled(confirmGUI.toplist,false)
        guiGridListAddColumn(confirmGUI.toplist, "Pos", 0.2)
		guiGridListAddColumn(confirmGUI.toplist, "Name", 0.6)
		guiGridListAddColumn(confirmGUI.toplist, "ForumID", 0.2)
		guiGridListSetSelectionMode( confirmGUI.toplist, 0 )
        for i = 1, 3 do
            guiGridListAddRow(confirmGUI.toplist)
        end
		addEventHandler('onClientGUIClick',confirmGUI.toplist, adminClickedOnTopsList, false)
		
        confirmGUI.label[1] = guiCreateLabel(58, 48, 244, 36, "Select Top Time", false, confirmGUI.window[1])
        guiSetFont(confirmGUI.label[1], "default-bold-small")
        guiLabelSetColor(confirmGUI.label[1], 0, 255, 0)
        guiLabelSetVerticalAlign(confirmGUI.label[1], "center")
        confirmGUI.label[2] = guiCreateLabel(233, 471, 196, 28, "All actions are logged", false, confirmGUI.window[1])
        guiSetFont(confirmGUI.label[2], "default-small")
        guiLabelSetHorizontalAlign(confirmGUI.label[2], "center", false)
        guiLabelSetVerticalAlign(confirmGUI.label[2], "center")
        confirmGUI.mapnameLabel = guiCreateLabel(320, 87, 76, 32, "Map Name: ", false, confirmGUI.window[1])
        guiSetFont(confirmGUI.mapnameLabel, "default-bold-small")
        confirmGUI.playernameLabel = guiCreateLabel(320, 119, 76, 32, "Player Name: ", false, confirmGUI.window[1])
        guiSetFont(confirmGUI.playernameLabel, "default-bold-small")
        confirmGUI.forumidLabel = guiCreateLabel(320, 151, 76, 32, "Forum ID: ", false, confirmGUI.window[1])
        guiSetFont(confirmGUI.forumidLabel, "default-bold-small")
        confirmGUI.mapnameValue = guiCreateLabel(403, 87, 259, 32, "-", false, confirmGUI.window[1])
        confirmGUI.playernameValue = guiCreateLabel(403, 119, 259, 32, "-", false, confirmGUI.window[1])
        confirmGUI.forumidValue = guiCreateLabel(403, 151, 259, 32, "-", false, confirmGUI.window[1])
        confirmGUI.label[3] = guiCreateLabel(320, 183, 76, 32, "Position:", false, confirmGUI.window[1])
        guiSetFont(confirmGUI.label[3], "default-bold-small")
        confirmGUI.positionValue = guiCreateLabel(403, 183, 259, 32, "-", false, confirmGUI.window[1])
        confirmGUI.label[4] = guiCreateLabel(460, 428, 265, 23, "Please review before accepting", false, confirmGUI.window[1])
        guiSetFont(confirmGUI.label[4], "default-bold-small")
        guiLabelSetColor(confirmGUI.label[4], 253, 0, 0)
        guiLabelSetVerticalAlign(confirmGUI.label[4], "bottom")
		confirmGUI.button[3] = guiCreateButton(56, 400, 250, 25, "Update to current map", false, confirmGUI.window[1])
		addEventHandler( 'onClientGUIClick', confirmGUI.button[3], adminRequestedUpdatedTops, false )

        confirmGUI.label[5] = guiCreateLabel(320, 256, 342, 30, "ACTION:", false, confirmGUI.window[1])
        guiSetFont(confirmGUI.label[5], "default-bold-small")
        guiLabelSetColor(confirmGUI.label[5], 0, 255, 0)
        guiLabelSetVerticalAlign(confirmGUI.label[5], "bottom")
        confirmGUI.combobox[1] = guiCreateComboBox(319, 306, 291, 90, "Remove selected toptime", false, confirmGUI.window[1])
        guiComboBoxAddItem(confirmGUI.combobox[1], "Remove selected toptime")
        guiComboBoxAddItem(confirmGUI.combobox[1], "Remove ALL tops from player")
        guiComboBoxAddItem(confirmGUI.combobox[1], "Remove ALL tops in map")
        confirmGUI.label[6] = guiCreateLabel(319, 341, 131, 22, "Reason: ", false, confirmGUI.window[1])
        confirmGUI.reasonEditBox = guiCreateEdit(316, 363, 294, 33, "", false, confirmGUI.window[1])
        guiEditSetMaxLength(confirmGUI.reasonEditBox, 60)
        confirmGUI.label[7] = guiCreateLabel(320, 48, 342, 36, "Selected Top Info", false, confirmGUI.window[1])
        guiSetFont(confirmGUI.label[7], "default-bold-small")
        guiLabelSetVerticalAlign(confirmGUI.label[7], "center")    
    end
)
local ttm_topsTable = false

function adminRequestsTopsManager(mapname, topsTable)
	-- guiSetText( confirmGUI.memo[1], actionString )
	resetTopsManager()
	buildTopsManager(mapname, topsTable)
	ttm_topsTable = topsTable
	guiSetText( confirmGUI.mapnameValue, mapname )
	guiSetVisible( confirmGUI.window[1], true )
	showCursor(true)
end
addEvent( 'onAdminRequestOpenTopManager', true )
addEventHandler( 'onAdminRequestOpenTopManager', localPlayer, adminRequestsTopsManager )

function resetTopsManager()
	guiSetText(confirmGUI.mapnameValue, '-')
	guiSetText(confirmGUI.playernameValue, '-')
	guiSetText(confirmGUI.forumidValue, '-')
	guiSetText(confirmGUI.positionValue, '-')
	guiSetText(confirmGUI.reasonEditBox,'')
	guiGridListClear( confirmGUI.toplist )
	-- guiSetEnabled( confirmGUI.button[1], false )
	guiComboBoxSetSelected(confirmGUI.combobox[1], 0)
end

function buildTopsManager (mapname, topsTable)
	guiSetText(confirmGUI.mapnameValue, mapname or '-')

	-- Populate grid list
	for i,v in ipairs(topsTable) do
		-- Player name handling
		local topPlayerName = v.name or v.mta_name or tostring(v.forumid).." (forumid)"
		if v.supernick and type(v.supernick) == "string" and fromJSON( v.supernick ) then
			local sn =  fromJSON( v.supernick )
			if sn.supernick then
				topPlayerName = sn.supernick
			end
		end
		topPlayerName = topPlayerName:gsub( '#%x%x%x%x%x%x', '' )
		local row = guiGridListAddRow( confirmGUI.toplist, tostring(i), topPlayerName, v.forumid)
	end
end

function topsManagerAccepted (button)
	if button ~= 'left' then return end
	-- Check action
	local selectedActionIndex = guiComboBoxGetSelected(confirmGUI.combobox[1])
	local selectedAction = false
	if selectedActionIndex == -1 then
		outputChatBox('[TopTimes Manager] Please provide an action.', 255, 0, 0)
		return
	end

	if selectedActionIndex == 0 then
		-- Delete player top
		selectedAction = "deletePlayerTop"
	elseif selectedActionIndex == 1 then
		-- Delete ALL player tops
		selectedAction = "deleteAllPlayerTops"
	elseif selectedActionIndex == 2 then
		-- Delete ALL map tops
		selectedAction = "deleteAllMapTops"
	else
		outputChatBox('[TopTimes Manager] Something went wrong, please contact a developer.', 255, 0, 0)
		return
	end

	if selectedActionIndex ~= 2 then
		-- If not 'delete all map tops', check for other stuff
		-- Check selected player
		local selectedRow = guiGridListGetSelectedItem( confirmGUI.toplist )
		if selectedRow == -1 then
			outputChatBox('[TopTimes Manager] Select a player first.', 255, 0, 0)
			return
		end
		local pos = guiGridListGetItemText( confirmGUI.toplist, selectedRow, 1 )
		local name = guiGridListGetItemText( confirmGUI.toplist, selectedRow, 2 )
		local forumid = guiGridListGetItemText( confirmGUI.toplist, selectedRow, 3 )
		local mapname = guiGetText( confirmGUI.mapnameValue )
		local val = ttm_topsTable[selectedRow+1].value or 0
		-- outputDebugString(selectedRow..' - '..pos..' - '..name..' - '..forumid..' - '..mapname)
		if not pos or not name or not forumid or string.len(mapname) == 0 then
			outputChatBox('[TopTimes Manager] Something went wrong, please contact a developer.', 255, 0, 0)
			return
		end

		-- Check if a reason is given
		local reason = guiGetText( confirmGUI.reasonEditBox )
		if string.len(reason) == 0 then
			outputChatBox('[TopTimes Manager] Please provide a reason.', 255, 0, 0)
			return
		end


		triggerServerEvent('onAdminConfirmedToptimesDeletionAction', root, {value = tonumber(val), reason = reason, action = selectedAction,position = tonumber(pos), playername = name, forumid = tonumber(forumid), mapname = mapname})
		topsManagerCanceled()
	elseif selectedActionIndex == 2 then
		-- Delete all map action

		local theMapName = guiGetText(confirmGUI.mapnameValue)
		if not theMapName or string.len(theMapName) == 0 then
			outputChatBox('[TopTimes Manager] Could not find mapname, please contact a dev.', 255, 0, 0)
			return
		end

		local reason = guiGetText( confirmGUI.reasonEditBox )
		if string.len(reason) == 0 then
			outputChatBox('[TopTimes Manager] Please provide a reason.', 255, 0, 0)
			return
		end

		triggerServerEvent('onAdminConfirmedToptimesDeletionAction', root, {reason = reason, action = selectedAction, mapname = theMapName})
		topsManagerCanceled()
	end
end


function adminClickedOnTopsList(button)

	if button ~= 'left' then return end
	local selectedRow = guiGridListGetSelectedItem( confirmGUI.toplist )
	if selectedRow == -1 then
		outputChatBox('[TopTimes Manager] Select a player first.', 255, 0, 0)
		guiSetText(confirmGUI.playernameValue, "-")
		guiSetText(confirmGUI.forumidValue, "-")
		guiSetText(confirmGUI.positionValue, "-")
		return
	end

	local pos = guiGridListGetItemText( confirmGUI.toplist, selectedRow, 1 )
	local name = guiGridListGetItemText( confirmGUI.toplist, selectedRow, 2 )
	local forumid = guiGridListGetItemText( confirmGUI.toplist, selectedRow, 3 )
	guiSetText(confirmGUI.playernameValue, name)
	guiSetText(confirmGUI.forumidValue, forumid)
	guiSetText(confirmGUI.positionValue, pos)
end

function topsManagerCanceled ()
	guiSetVisible( confirmGUI.window[1], false )
	resetTopsManager()
	showCursor(false)
end

function adminRequestedUpdatedTops()
	triggerServerEvent( 'adminRequestedUpdatedTops', resourceRoot)
	outputChatBox('[TopTimes Manager] Updated tops to current map!', 0, 255, 0)
end
