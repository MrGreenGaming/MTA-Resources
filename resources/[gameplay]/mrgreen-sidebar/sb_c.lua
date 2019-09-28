-- Config
screenW,screenH = guiGetScreenSize()
scaleW = screenW/1920
scaleH = screenH/1080


sidebarLeft = screenW * 0
_sidebarLeft = sidebarLeft 


sidebarTop = screenH * 0
sidebarWidth = screenW * 0.2--380
sidebarHeight = screenH * 1
BGAlpha = 235
sidebarColor = tocolor(47, 76, 49, BGAlpha)
sidebarEaseDuration = 80 -- MS of easing speed

menuItemStartY = screenH * 0.2 --250
menuItemHeight = screenH * 0.05--65
menuItemTextScale = 1 * scaleW 
menuItemIconSpace = screenW * 0.032

menuItemOddColor = tocolor(0,0,0,30)
menuItemEvenColor = tocolor(0,0,0,55)
menuItemHoverColor = tocolor(255,255,255,5)

menuItemFont = "bankgothic"

-- Date and time
dateTimeTop = screenH*0.0
timeDateTextScale = 0.5 * scaleW
if timeDateTextScale < 0.35 then
	timeDateTextScale = 0.35
end
timeDateFont = "bankgothic"

-- -- Server/Room Name

serverName = ""
serverNameFont = "sans"
serverNameTextScale = 1 * scaleW
if serverNameTextScale < 0.75 then
	serverNameTextScale = 0.75
end
_serverNameTextScale = serverNameTextScale

serverNameHeight = screenH * 0.050
serverNameStartY = (screenH * 1) - serverNameHeight

-- Account Info
accountInfoStartHeight = 0.055 * screenH

usernameTextScale = 1.5 * scaleW
if usernameTextScale < 0.75 then
	usernameTextScale = 0.75
end
_usernameTextScale = usernameTextScale -- Cashe for originalye

gcTopStart = 0.05 * screenH --0.2 * screenH
gcFont = "bankgothic"
gcFontScale = 0.8 * scaleW
_gcFontScale = gcFontScale

usernameTextMarge = sidebarWidth/100*10 -- Space from borders of sidebar
usernameFont = "bankgothic"

-- setPlayerHudComponentVisible( "all", false )
-- Menu Items --
MenuItems = { -- Name, Icon
	{name = "Server Info", event = "sb_showServerInfo"},
	{name = "My Account", event = "sb_showMyAccount"},
	{name = "GC Shop", event = "sb_showGCShop"},
	{name = "Transfer GCs", event = "sb_transferGC"},
	{name = "Achievements", event = "sb_showAchievements"},
	{name = "My Stats", event = "sb_showStats"},
	{name = "Settings", event = "sb_showSettings"},
	{name = "PM", event = "sb_showPM"},
	{name = "Music Player", event = "sb_showMusicPlayer"},
	{name = "Help", event = "sb_showHelp"}
	
}


function setMenuTables()
	for i,item in ipairs(MenuItems) do
		local menuCountPos = (i-1)*menuItemHeight+menuItemStartY

		-- Set positions in table
		-- dxDrawRectangle(_sidebarLeft,sidebarTop+menuCountPos,sidebarWidth,menuItemHeight,mencol,true)
		MenuItems[i].x = _sidebarLeft
		MenuItems[i].y = sidebarTop+menuCountPos
		MenuItems[i].w = sidebarWidth
		MenuItems[i].h = menuItemHeight
	end
end
addEventHandler("onClientResourceStart",resourceRoot,setMenuTables)


-- Functions override --
_dxDrawRectangle = dxDrawRectangle


function drawSidebarBG()
	-- Draw Sidebar BG
	dxDrawRectangle(_sidebarLeft, sidebarTop, sidebarWidth, sidebarHeight, tocolor(0, 0, 0, BGAlpha), true)
	
	-- Draw Shadow Background
	local fadeAlpha = 150
	for i =0 , fadeAlpha do -- BG
		fadeAlpha = fadeAlpha-1
		if fadeAlpha > 0 then
			dxDrawRectangle( _sidebarLeft+sidebarWidth+i, 0, 1*scaleW, screenH * 1,tocolor(0,0,0,fadeAlpha),true )
		end
	end
	

end

function drawMenuItems()
	-- for i,item in ipairs(MenuItems) do
	for i = 1, #MenuItems do
		local item = MenuItems[i]

		local menuCountPos = (i-1)*menuItemHeight+menuItemStartY
		local mouseHover = isMouseHovering(_sidebarLeft,sidebarTop+menuCountPos,sidebarWidth,menuItemHeight)

		local hoverTextScale = 0
		-- Check for odd or even and hover colors
		local mencol = menuItemEvenColor
		if mouseHover then
			mencol = menuItemHoverColor
			hoverTextScale = 0.3 * scaleW 
		elseif i % 2 == 0 then
			mencol = menuItemEvenColor
		else
			mencol = menuItemOddColor
		end

		

		-- Draw menu item BG
		dxDrawRectangle(_sidebarLeft,sidebarTop+menuCountPos,sidebarWidth,menuItemHeight,mencol,true)

		-- Draw Text
		dxDrawText(item.name,_sidebarLeft+menuItemIconSpace,sidebarTop+menuCountPos,_sidebarLeft+sidebarWidth,sidebarTop+menuCountPos+menuItemHeight,tocolor(255,255,255,255),menuItemTextScale+hoverTextScale,menuItemFont,"left","center",true,false,true)
	end
end


local gcLastWidth = 0
function drawAccountInfo()
	

	-- Draw name getPlayerName(localPlayer):gsub("#%x%x%x%x%x%x","")
	local pName = getPlayerName(localPlayer):gsub("#%x%x%x%x%x%x","")
	
	-- Draw name
	
	dxDrawText(pName,_sidebarLeft,sidebarTop+ accountInfoStartHeight,_sidebarLeft+sidebarWidth,sidebarTop+menuItemHeight+ accountInfoStartHeight,tocolor(255,255,255,255),usernameTextScale,usernameFont,"center","center",true,false,true)


	-- Draw GC info
	local totalGC = getElementData(localPlayer,"greencoins")
	if not totalGC then totalGC = 0 end

	local gcString = tostring(totalGC).." GC"
	local gcWidth = dxGetTextWidth( gcString, _gcFontScale, gcFont )
	if gcLastWidth < gcWidth and gcWidth > sidebarWidth - usernameTextMarge then
		for i = _gcFontScale, 0.1*scaleW, -0.1*scaleW do -- Check for width in 0.1 increments 
			local textW = dxGetTextWidth( pName, i, gcFont )
			if textW < sidebarWidth - usernameTextMarge then
				_gcFontScale = i
				break
			end
		end
	end
	
	if _gcFontScale < 0.4 then
		_gcFontScale = 0.4
	end
	
	dxDrawText(gcString,_sidebarLeft,sidebarTop + gcTopStart+ accountInfoStartHeight,_sidebarLeft+sidebarWidth,sidebarTop+menuItemHeight+gcTopStart+ accountInfoStartHeight,tocolor(255,255,255,255),_gcFontScale,gcFont,"center","center",true,false,true,true)
end


function drawDateTime()
	local timestring = FormatDate("h:i\nd/m/Y" )

	dxDrawText(timestring,_sidebarLeft,dateTimeTop,_sidebarLeft+sidebarWidth,sidebarTop+menuItemHeight,tocolor(255,255,255,255),timeDateTextScale,timeDateFont,"center","top",true,false,true)
end

function drawRoomName()
	-- outputDebugString(_sidebarLeft.." "..serverNameStartY/screenH)
	dxDrawText(serverName,_sidebarLeft, serverNameStartY, _sidebarLeft + sidebarWidth,serverNameStartY + serverNameHeight,tocolor(255,255,255,255),serverNameTextScale,serverNameFont,"center","bottom",false,false,true )
end

sidebarShowing = false
function Draw()
	if not sidebarShowing then return end
	drawSidebarBG()
	drawMenuItems()
	drawAccountInfo()
	drawDateTime()
	drawRoomName()
end
addEventHandler("onClientRender",root,Draw)

function showSidebar()
	local nme = getPlayerName(localPlayer):gsub("#%x%x%x%x%x%x","")

	-- if nme == "KaliBwoy" or nme == "warp." or nme == "SDK" or nme == "Goldberg" then 
	

	if not sidebarShowing then
		sidebarShowing = true
		showCursor(true)
	else
		easeOut = true
		showCursor(false)
	end

	
	start = getTickCount


	if sidebarShowing and not easeOut then -- Open ease
		_sidebarLeft = sidebarLeft - sidebarWidth
		startPosition = sidebarLeft - sidebarWidth
		endPosition = sidebarLeft
		start = getTickCount()
		fullduration = getTickCount() + sidebarEaseDuration

		addEventHandler("onClientRender",root,sidebarEaseOpen)

	else -- Close ease
		_sidebarLeft = sidebarLeft
		startPosition = sidebarLeft
		endPosition = sidebarLeft - sidebarWidth
		start = getTickCount()
		fullduration = getTickCount() + sidebarEaseDuration


		addEventHandler("onClientRender",root,sidebarEaseClose)
	end
-- end
end
bindKey("f1","down",showSidebar )


-- EASING
function sidebarEaseOpen()
	local now = getTickCount()
	local elapsedTime = now - start
	local duration = fullduration - start
	local progress = elapsedTime / duration
 
	local width, height, _ = interpolateBetween ( 
		startPosition, 0, 0, 
		endPosition, 0, 0, 
		progress, "InQuad")

	_sidebarLeft = width
 

	if now >= fullduration then

		now = nil
		duration = nil
		start = nil
		removeEventHandler("onClientRender", getRootElement(), sidebarEaseOpen)

	end
end
 
function sidebarEaseClose()
	local now = getTickCount()
	local elapsedTime = now - start
	local duration = fullduration - start
	local progress = elapsedTime / duration
 
	local width, height, _ = interpolateBetween ( 
		startPosition, 0, 0, 
		endPosition, 0, 0, 
		progress, "OutQuad")
 

 

 
	_sidebarLeft = width


	if now >= fullduration then
		sidebarShowing = false
		easeOut = false
		now = nil
		duration = nil
		start = nil
		removeEventHandler("onClientRender", getRootElement(), sidebarEaseClose)

	end
end
--
function clickHandler(button,state,x,y)
	if sidebarShowing and button == "left" and state == "down" then
		local cursorx,cursory = getCursorPosition()
		local cursorx = cursorx*screenW
		local cursory = cursory*screenH

		for i,item in ipairs(MenuItems) do
			-- outputChatBox(tostring(item.x).." "..tostring(item.w).." "..tostring(item.y).." "..tostring(item.h))
			if cursorx>item.x and cursorx < item.x+item.w and cursory>item.y and cursory<item.y+item.h then
				if item.event then
					triggerEvent(item.event,root)
					showSidebar()
				end
				break
			end
		end
	end
end
addEventHandler("onClientClick",root,clickHandler)

function isMouseHovering(x,y,w,h)
	if not isCursorShowing() then return false end

	local cursorx, cursory = getCursorPosition()
	local cursorx = cursorx*screenW
	local cursory = cursory*screenH
	-- outputDebugString(x.." "..y.." "..w.." "..h.." CURSOR: "..cursorx.." "..cursory)
	return cursorx>x and cursorx<x+w and cursory>y and cursory<y+h 
end
	
function calculateNicknameWidth()
	local pName = getPlayerName(localPlayer):gsub("#%x%x%x%x%x%x","")
	local usernameWidth = dxGetTextWidth( pName, usernameTextScale, usernameFont )

	for i = _usernameTextScale, 0.1*scaleW, -0.1*scaleW do -- Check for width in 0.1 increments 
		local textW = dxGetTextWidth( pName, i, usernameFont )
		if textW < sidebarWidth - usernameTextMarge then
			usernameTextScale = i
			break
		end
	end
end
addEventHandler("onClientPlayerChangeNick",localPlayer,calculateNicknameWidth)
addEventHandler("onClientResourceStart",resourceRoot,calculateNicknameWidth)

addEventHandler("onClientResourceStart",resourceRoot,
	function()
		triggerServerEvent("getServerName",resourceRoot)
	end)

addEvent("receiveServerName",true)
addEventHandler("receiveServerName",resourceRoot,
	function(name)
		local nm = "MrGreenGaming "
		if string.find(name,"MIX") then
			nm = nm.."Race Mix"
		else
			nm = nm.."Race"
		end

		for i = _serverNameTextScale, 0.1*scaleW, -0.1*scaleW do -- Check for width in 0.1 increments 
			local textW = dxGetTextWidth( nm, i, serverNameFont )
			if textW < sidebarWidth - usernameTextMarge then
				serverNameTextScale = i
				break
			end
		end
		serverName = nm
	end

)




-- UTILS
function Check(funcname, ...)
    local arg = {...}
 
    if (type(funcname) ~= "string") then
        error("Argument type mismatch at 'Check' ('funcname'). Expected 'string', got '"..type(funcname).."'.", 2)
    end
    if (#arg % 3 > 0) then
        error("Argument number mismatch at 'Check'. Expected #arg % 3 to be 0, but it is "..(#arg % 3)..".", 2)
    end
 
    for i=1, #arg-2, 3 do
        if (type(arg[i]) ~= "string" and type(arg[i]) ~= "table") then
            error("Argument type mismatch at 'Check' (arg #"..i.."). Expected 'string' or 'table', got '"..type(arg[i]).."'.", 2)
        elseif (type(arg[i+2]) ~= "string") then
            error("Argument type mismatch at 'Check' (arg #"..(i+2).."). Expected 'string', got '"..type(arg[i+2]).."'.", 2)
        end
 
        if (type(arg[i]) == "table") then
            local aType = type(arg[i+1])
            for _, pType in next, arg[i] do
                if (aType == pType) then
                    aType = nil
                    break
                end
            end
            if (aType) then
                error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..table.concat(arg[i], "' or '").."', got '"..aType.."'.", 3)
            end
        elseif (type(arg[i+1]) ~= arg[i]) then
            error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..arg[i].."', got '"..type(arg[i+1]).."'.", 3)
        end
    end
end

local gWeekDays = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
function FormatDate(format, escaper, timestamp)
	Check("FormatDate", "string", format, "format", {"nil","string"}, escaper, "escaper", {"nil","string"}, timestamp, "timestamp")
 
	escaper = (escaper or "'"):sub(1, 1)
	local time = getRealTime(timestamp)
	local formattedDate = ""
	local escaped = false
 
	time.year = time.year + 1900
	time.month = time.month + 1
 
	local datetime = { d = ("%02d"):format(time.monthday), h = ("%02d"):format(time.hour), i = ("%02d"):format(time.minute), m = ("%02d"):format(time.month), s = ("%02d"):format(time.second), w = gWeekDays[time.weekday+1]:sub(1, 2), W = gWeekDays[time.weekday+1], y = tostring(time.year):sub(-2), Y = time.year }
 
	for char in format:gmatch(".") do
		if (char == escaper) then escaped = not escaped
		else formattedDate = formattedDate..(not escaped and datetime[char] or char) end
	end
 
	return formattedDate
end
