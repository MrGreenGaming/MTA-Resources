local playersCountry = {}

--------------------------------------------------
-- Screen resolution for which GUI was designed --
--------------------------------------------------
local myScreenW, myScreenH = 1920, 1080

-------------------------------------
-- Screen resolution of the client --
-------------------------------------
local oldScreenW, oldScreenH = guiGetScreenSize()

-----------------------------------------------------------
-- Calculations to make GUI look good on all resolutions --
-----------------------------------------------------------
local ratio = math.min(myScreenH/oldScreenH, myScreenW/oldScreenW) 
local screenH = math.ceil(myScreenH*ratio) 
local screenW = math.ceil(myScreenW*ratio) 
local windowH = (515/myScreenH)*screenH
local headerH = (27/myScreenH)*screenH
if windowH+headerH > oldScreenH then
	local ratio_multipl = windowH/oldScreenH
	local ratio = (ratio/ratio_multipl)*0.7
	----------------------------------------------------------------------------
	-- New fake screen resolution which we'll use below to draw GUI correctly --
	----------------------------------------------------------------------------
	screenW = math.ceil(myScreenW*ratio)
	screenH = math.ceil(myScreenH*ratio) 
end


local windowW = (460/myScreenW)*screenW
local windowH = (515/myScreenH)*screenH
local windowPosX = 0.5*(oldScreenW-windowW)
local windowPosY = 0.5*(oldScreenH-windowH)
local headerH = (27/myScreenH)*screenH
local stripeW = windowW*0.65
local stripeH = (15/myScreenH)*screenH
local stripePosX = windowPosX+(windowW-stripeW)
local textIndent = (10/myScreenW)*screenW
local textColumn1W = windowW*0.25
local textPosX = stripePosX+textIndent
local textColumn2W = textPosX+textColumn1W

local avatarW = (100/myScreenW)*screenW
local avatarH = (100/myScreenH)*screenH
local avatarPosX = windowPosX+0.5*(windowW-stripeW-avatarW)
local avatarPosY = windowPosY+headerH*2.1
local textNameW = stripePosX-windowPosX
local textNamePosY = windowPosY+headerH*1.1
local textGCPosY = windowPosY+avatarH+headerH*2.1
local textGCH = headerH

local closeButtonW = (19/myScreenW)*screenW
local closeButtonH = (19/myScreenH)*screenH
local closeButtonIndent = (4/myScreenW)*screenW
local closeButtonX = windowPosX+windowW-closeButtonIndent-closeButtonW
local closeButtonY = windowPosY+closeButtonIndent
--[[
local gridlistIndent = (4/myScreenW)*screenW
local gridlistPosX = windowPosX+gridlistIndent
local gridlistPosY = textGCPosY+textGCH+gridlistIndent
local gridlistW = textNameW-2*gridlistIndent
local gridlistH = (windowPosY+windowH)-gridlistPosY-gridlistIndent
]]

local font0_opensans = exports.fonts:createCEGUIFont("OpenSans", math.floor(0.0148148148148148*screenH) )
local font1_opensans = exports.fonts:createCEGUIFont("OpenSans", math.floor(0.011*screenH) )
local font0_arial = exports.fonts:createCEGUIFont("Tahoma Bold", math.floor(0.008*screenH) )

GUIEditor = {
    label = {},
	window = {},
	image = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
		addEventHandler ( "onClientPlayerScoreboardClick", root, scoreboardClick )
		
		GUIEditor.label["parent"] = guiCreateLabel(0, 0, screenW, screenH, "", false)
		guiSetVisible(GUIEditor.label["parent"], false)
		
		GUIEditor.label["gc"] = guiCreateLabel(windowPosX, textGCPosY, textNameW, textGCH, "", false, GUIEditor.label["parent"])
		guiSetFont(GUIEditor.label["gc"], font1_opensans)
		guiLabelSetHorizontalAlign(GUIEditor.label["gc"], "center", false)
		guiSetProperty(GUIEditor.label["gc"], "AlwaysOnTop", "True")  
		guiLabelSetColor(GUIEditor.label["gc"], 0, 210, 0)
		
		GUIEditor.image["close_pressed"] = guiCreateStaticImage(closeButtonX, closeButtonY, closeButtonW, closeButtonH, "images/close_pressed.png", false, GUIEditor.label["parent"])
		guiSetProperty(GUIEditor.image["close_pressed"], "AlwaysOnTop", "True")
		guiSetVisible(GUIEditor.image["close_pressed"], false)
		
		GUIEditor.image["close"] = guiCreateStaticImage(closeButtonX, closeButtonY, closeButtonW, closeButtonH, "images/close.png", false, GUIEditor.label["parent"])
		guiSetProperty(GUIEditor.image["close"], "AlwaysOnTop", "True")
		
		addEventHandler ( "onClientGUIClick", GUIEditor.image["close_pressed"], function() guiSetVisible(GUIEditor.label["parent"], false) showCursor(false) end, false )
		
		addEventHandler( "onClientMouseEnter", resourceRoot, 
			function()
				if source == GUIEditor.image["close"] then
					guiSetVisible(GUIEditor.image["close_pressed"], true)
				end
			end
		)
		
		addEventHandler( "onClientMouseLeave", resourceRoot, 
			function()
				if source ~= GUIEditor.image["close"] then
					guiSetVisible(GUIEditor.image["close_pressed"], false)
				end
			end
		)

		GUIEditor.image["window"] = guiCreateStaticImage(windowPosX, windowPosY, windowW, windowH, "images/dot.png", false, GUIEditor.label["parent"])
		guiSetProperty(GUIEditor.image["window"], "ImageColours", "tl:FF0A0A0A tr:FF0A0A0A bl:FF0A0A0A br:FF0A0A0A")    
		
		GUIEditor.label["title"] = guiCreateLabel(windowPosX+closeButtonW+closeButtonIndent, windowPosY, windowW-closeButtonW*2-closeButtonIndent*2, headerH, "STATS", false, GUIEditor.label["parent"])
        guiSetFont(GUIEditor.label["title"], font0_opensans)
        guiLabelSetHorizontalAlign(GUIEditor.label["title"], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label["title"], "center")
		guiSetProperty(GUIEditor.label["title"], "AlwaysOnTop", "True")
		
		GUIEditor.image["header"] = guiCreateStaticImage(windowPosX, windowPosY, windowW, headerH, "images/header.png", false, GUIEditor.label["parent"])
		guiSetProperty(GUIEditor.image["header"], "AlwaysOnTop", "True")   
		guiSetProperty(GUIEditor.image["header"], "RiseOnClick", "False")     
		
		GUIEditor.image["avatarOverlay"] = guiCreateStaticImage(avatarPosX, avatarPosY, avatarW, avatarH, "images/avatarOverlay.png", false, GUIEditor.label["parent"])
		guiSetProperty(GUIEditor.image["avatarOverlay"], "AlwaysOnTop", "True")
		
		GUIEditor.image["avatar"] = guiCreateStaticImage(avatarPosX, avatarPosY, avatarW, avatarH, "images/avatar.png", false, GUIEditor.label["parent"])
		guiSetProperty(GUIEditor.image["avatar"], "AlwaysOnTop", "True")
		
		
		
        GUIEditor.label["name"] = guiCreateLabel(windowPosX, textNamePosY, textNameW, headerH, getPlayerName(localPlayer):gsub ( '#%x%x%x%x%x%x', '' ), false, GUIEditor.label["parent"])
        guiSetFont(GUIEditor.label["name"], font1_opensans)
        guiLabelSetHorizontalAlign(GUIEditor.label["name"], "center", false)
		guiSetProperty(GUIEditor.label["name"], "AlwaysOnTop", "True")   
		
		flag = guiCreateStaticImage(stripePosX, avatarPosY-7, (16/myScreenW)*screenW, (11/myScreenH)*screenH, "images/dot.png", false, GUIEditor.label["parent"])
		guiSetProperty(flag, "AlwaysOnTop", "True")
		guiSetProperty(flag, "ImageColours", "tl:00FFFFFF tr:00FFFFFF bl:00FFFFFF br:00FFFFFF")
		
		local p = 12.1
		
		for subgroupID=1, #subgroups do
			p = p + stripeH
			local subgroup = subgroups[subgroupID]
			GUIEditor.label[subgroup] = guiCreateLabel(stripePosX, windowPosY+p, stripeW, stripeH, subgroup, false, GUIEditor.label["parent"])
			--guiLabelSetColor(GUIEditor.label[subgroup], 0, 210, 0)    
			guiSetFont(GUIEditor.label[subgroup], font0_arial)
			guiLabelSetHorizontalAlign(GUIEditor.label[subgroup], "center", false)
			guiSetProperty(GUIEditor.label[subgroup], "AlwaysOnTop", "True")  
			
			
			GUIEditor.image[p] = guiCreateStaticImage(stripePosX, windowPosY+p, stripeW, stripeH, "images/dot.png", false, GUIEditor.label["parent"])
			guiSetProperty(GUIEditor.image[p], "ImageColours", "tl:FF222222 tr:FF222222 bl:FF222222 br:FF222222") 
			guiSetProperty(GUIEditor.image[p], "AlwaysOnTop", "True")
			guiSetProperty(GUIEditor.image[p], "RiseOnClick", "False")			
			
			local s = 0
			for i=1, #stats[subgroupID] do
				s = s + 1
				p = p + stripeH
				local statID = stats[subgroupID][i].id
				GUIEditor.label[statID] = guiCreateLabel(textPosX, windowPosY+p, textColumn1W, stripeH, stats[subgroupID][i].name..":", false, GUIEditor.label["parent"])
				guiSetFont(GUIEditor.label[statID], font0_arial)
				guiLabelSetHorizontalAlign(GUIEditor.label[statID], "left", false)
				guiSetProperty(GUIEditor.label[statID], "AlwaysOnTop", "True") 
			
				local posX = guiGetPosition(GUIEditor.label[statID], false)
				local textSizeColumn1 = guiLabelGetTextExtent(GUIEditor.label[statID])
				guiSetSize(GUIEditor.label[statID], textSizeColumn1, stripeH, false)
						
				GUIEditor.label["value"..statID] = guiCreateLabel(posX+textSizeColumn1, windowPosY+p, stripeW-textSizeColumn1-textIndent-textIndent, stripeH, "0", false, GUIEditor.label["parent"])
				guiSetFont(GUIEditor.label["value"..statID], font0_arial)
				guiLabelSetHorizontalAlign(GUIEditor.label["value"..statID], "right", false)
				guiSetProperty(GUIEditor.label["value"..statID], "AlwaysOnTop", "True")
				
				if (s % 2 ~= 0) then
					GUIEditor.image[p] = guiCreateStaticImage(stripePosX, windowPosY+p, stripeW, stripeH, "images/dot.png", false, GUIEditor.label["parent"])
					guiSetProperty(GUIEditor.image[p], "ImageColours", "tl:FF101010 tr:FF101010 bl:FF101010 br:FF101010")  
					guiSetProperty(GUIEditor.image[p], "AlwaysOnTop", "True")
					guiSetProperty(GUIEditor.image[p], "RiseOnClick", "False")
				end
			end
		end
    end
)


function receivePlayerStats( tbl, player )	
	if previousPlayer == player then
		guiSetVisible(GUIEditor.label["parent"], not guiGetVisible(GUIEditor.label["parent"]))
		showCursor(guiGetVisible(GUIEditor.label["parent"]))
		if guiGetVisible(GUIEditor.label["parent"]) == false then return end
	else
		guiSetVisible(GUIEditor.label["parent"], true)
		showCursor(true)
	end
	previousPlayer = player
	
	--Player Name
	local playerName = getPlayerName(player):gsub ( '#%x%x%x%x%x%x', '' )
	guiSetText(GUIEditor.label["name"], playerName:sub (1, 16) )
	guiSetText(GUIEditor.label["gc"], getElementData(player, "greencoins"):gsub ( '#%x%x%x%x%x%x', '' ).." GC")
	
	--Filling in player stats
	for k, v in pairs(tbl) do
		if isElement(GUIEditor.label[k]) then
			if k == "id5" then
				v = tbl["total_playtime"]
				setElementData(GUIEditor.label["value"..k], "tooltip-text", secondsToTimeDesc(v/1000), false)
				v = secondsToTimeDesc(v/1000, "hours")
			elseif k == "id4" then
				local this_session = tbl["temp_id4"]
				v = this_session+v
			elseif k == "id6" then
				local this_session = tbl["temp_id6"]
				v = this_session+v
			elseif k == "id12" then
				local this_session = tbl["temp_id12"]
				v = this_session+v
			elseif k == "id1" then
				local this_session = tbl["temp_id1"]
				v = this_session+v
			elseif k == "id7" then
				local this_session = tbl["temp_id7"]
				v = this_session+v
			elseif k == "id10" then
				local this_session = tbl["temp_id10"]
				v = this_session+v
			end
			guiSetText(GUIEditor.label["value"..k], v)
		end
	end
	
	--Player Country
	local country = getElementData(player, "flag-country")
	local countryFullName = getElementData(player, "fullCountryName")
	if country and countryFullName then
		playersCountry[player] = true
		guiSetText(GUIEditor.label["valuecountry"], string.sub(countryFullName, 1, 30) )
		local posX, posY = guiGetPosition(GUIEditor.label["valuecountry"], false)
		local w, h = guiGetSize(GUIEditor.label["valuecountry"], false)
		local textSize = guiLabelGetTextExtent(GUIEditor.label["valuecountry"])
		guiSetPosition(flag, posX-((18/myScreenW)*screenW)+(w-textSize), posY+( (stripeH-((11/myScreenH)*screenH))*0.5 ), false)
		guiStaticImageLoadImage(flag, country.flag)
		guiSetProperty(flag, "ImageColours", "tl:FFFFFFFF tr:FFFFFFFF bl:FFFFFFFF br:FFFFFFFF")
	else
		guiSetText(GUIEditor.label["valuecountry"], "-" )
	end	
	
	--Player Avatar
	local avatar = getElementData(player, "forumAvatar")
	if avatar and avatar.type == "image" and avatar.src then
		guiStaticImageLoadImage(GUIEditor.image["avatar"], avatar.src)
	else
		guiStaticImageLoadImage(GUIEditor.image["avatar"], "images/avatar.png")
	end
end
addEvent("sendPlayerStats", true)
addEventHandler("sendPlayerStats", root, receivePlayerStats)


function scoreboardClick ( row, x, y, columnName )
	if getElementType(source) == "player" and columnName == "forumAvatar" then
		triggerServerEvent("showGUI", resourceRoot, _, _, _, source)
		executeCommandHandler("Toggle scoreboard", "0")
	end
end


--[[
function showGUIanimated(key, keyState)
	if g_Window then return end
	
	g_Window = {}
	g_Window.startPos = { 0, screenH }
	g_Window.startTime = getTickCount()
	g_Window.endPos = { 0, 0 }
	g_Window.endTime = g_Window.startTime + 1000
	
	if guiGetVisible(GUIEditor.label["parent"]) then
		g_Window.startPos, g_Window.endPos = g_Window.endPos, g_Window.startPos
		setTimer(function() showGUI() end, 1000, 1)
	else
		showGUI()
	end
	event = addEventHandler("onClientRender", root, popWindowUp)
end
bindKey("F10", "down", showGUIanimated)

function popWindowUp()
	local now = getTickCount()
	local elapsedTime = now - g_Window.startTime
	local duration = g_Window.endTime - g_Window.startTime
	local progress = elapsedTime / duration

	local x1, y1 = unpack(g_Window.startPos)
	local x2, y2 = unpack(g_Window.endPos)
	local x, y = interpolateBetween ( 
		x1, y1, 0,
		x2, y2, 0, 
		progress, "OutBounce")
		
	guiSetPosition(GUIEditor.label["parent"], x, y, false)
	--guiSetSize(GUIEditor.label["parent"], w, h, false)

	if now >= g_Window.endTime then
		g_Window = nil
		removeEventHandler("onClientRender", root, popWindowUp)
	end
end]]