local g_screenX,g_screenY = guiGetScreenSize()
local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement(getThisResource())
local g_Me = getLocalPlayer()

local DISTANCE_FRONT_BEHIND = 0.03
local TIME_TO_DISPLAY = 2000

local frontTick
local behindTick
local delayDisplayFrontShadow = dxText:create("", ((0.5*g_screenX + 1)/g_screenX), ((0.37*g_screenY + 1)/g_screenY), true, "default-bold")
local delayDisplayBehindShadow = dxText:create("", ((0.5*g_screenX + 1)/g_screenX), ((0.43*g_screenY + 1)/g_screenY), true, "default-bold")
delayDisplayFrontShadow:color(0, 0, 0)
delayDisplayBehindShadow:color(0, 0, 0)
local delayDisplayFront = dxText:create("", 0.5*g_screenX, 0.37*g_screenY, true, "default-bold")
local delayDisplayBehind = dxText:create("", 0.5*g_screenX, 0.43*g_screenY, true, "default-bold")
delayDisplayFront:color(255, 0, 0)
delayDisplayBehind:color(0, 255, 0)

addEvent("showDelay", true)
addEventHandler("showDelay", g_Root,
	function(delayTime, optional)
		if tonumber(optional) then
			local cps = getElementData(g_Me, "race.checkpoint") - optional
			if cps < 2 then
				cps = ""
			else
				cps = "(-"..cps.."CPs) "
			end
			delayDisplayBehindShadow:text("-"..msToTimeStr(delayTime).." "..cps..string.gsub(getPlayerName(source), "#%x%x%x%x%x%x", ""))
			delayDisplayBehindShadow:visible(true)
			delayDisplayBehind:text("-"..msToTimeStr(delayTime).." #FFFFFF"..cps..getPlayerName(source))
			delayDisplayBehind:visible(true)
			behindTick = getTickCount()
			setTimer(hideDelayDisplay, TIME_TO_DISPLAY, 1, false)
		elseif type(optional) == "table" then
			if delayTime < 0 then
				-- outputChatBox("-"..msToTimeStr(-delayTime).." current record")
				delayDisplayFrontShadow:text("+"..msToTimeStr(-delayTime).." record #"..optional[1])
				delayDisplayFrontShadow:color(0, 0, 0)
				delayDisplayFront:text("+"..msToTimeStr(-delayTime).." record #"..optional[1])
				delayDisplayFront:color(255, 255, 0)
			elseif delayTime > 0 then
				-- outputChatBox("+"..msToTimeStr(delayTime).." current record")
				delayDisplayFrontShadow:text("-"..msToTimeStr(delayTime).." record #"..optional[1])
				delayDisplayFrontShadow:color(0, 0, 0)
				delayDisplayFront:text("-"..msToTimeStr(delayTime).." record #"..optional[1])
				delayDisplayFront:color(0, 255, 255)
			end
			delayDisplayFrontShadow:visible(true)
			delayDisplayFront:visible(true)
			frontTick = getTickCount()
			setTimer(hideDelayDisplay, TIME_TO_DISPLAY, 1, true)
		else
            local cps = getElementData(source, "race.checkpoint") - getElementData(g_Me, "race.checkpoint")
			if cps < 2 then
				cps = ""
			else
				cps = "(+"..cps.."CPs) "
			end
			delayDisplayFrontShadow:text("+"..msToTimeStr(delayTime).." "..cps..string.gsub(getPlayerName(source), "#%x%x%x%x%x%x", ""))
			delayDisplayFrontShadow:color(0, 0, 0)
			delayDisplayFrontShadow:visible(true)
			delayDisplayFront:text("+"..msToTimeStr(delayTime).." #FFFFFF"..cps..getPlayerName(source))
			delayDisplayFront:color(255, 0, 0)
			delayDisplayFront:visible(true)
			frontTick = getTickCount()
			setTimer(hideDelayDisplay, TIME_TO_DISPLAY, 1, true)
		end
	end
)

function hideDelayDisplay(front)
	if front == "both" then
		delayDisplayFrontShadow:visible(false)
		delayDisplayBehindShadow:visible(false)
		delayDisplayFront:visible(false)
		delayDisplayBehind:visible(false)
	elseif front then
		local pastTime = getTickCount() - frontTick
		if pastTime >= TIME_TO_DISPLAY then
			delayDisplayFrontShadow:visible(false)
			delayDisplayFront:visible(false)
		else
			if pastTime < 50 then pastTime = 50 end
			setTimer(hideDelayDisplay, pastTime, 1, true)
			-- outputChatBox("front dalassen")
		end
	else
		local pastTime = getTickCount() - behindTick
		if pastTime >= TIME_TO_DISPLAY then
			delayDisplayBehindShadow:visible(false)
			delayDisplayBehind:visible(false)
		else
			if pastTime < 50 then pastTime = 50 end
			setTimer(hideDelayDisplay, pastTime, 1, false)
			-- outputChatBox("behind dalassen")
		end
	end
end

addEventHandler('onClientResourceStart', g_ResRoot,
	function()
		local settingsFile = xmlLoadFile("settings.xml")
		if settingsFile then
			local pos = xmlNodeGetAttributes(settingsFile)
			delayDisplayFrontShadow:position(((pos.x*g_screenX + 1)/g_screenX), (((pos.y - DISTANCE_FRONT_BEHIND)*g_screenY + 1)/g_screenY))
			delayDisplayBehindShadow:position(((pos.x*g_screenX + 1)/g_screenX), (((pos.y + DISTANCE_FRONT_BEHIND)*g_screenY + 1)/g_screenY))
			delayDisplayFront:position(pos.x, pos.y - DISTANCE_FRONT_BEHIND)
			delayDisplayBehind:position(pos.x, pos.y + DISTANCE_FRONT_BEHIND)
		else
			settingsFile = xmlCreateFile("settings.xml","settings")
			xmlNodeSetAttribute(settingsFile,"x",0.5)
			xmlNodeSetAttribute(settingsFile,"y",0.4)
		end
		xmlSaveFile(settingsFile)
		xmlUnloadFile(settingsFile)
	end
)

addCommandHandler("setdelaypos",
	function(cmd,x,y)
		if x and y then
			if tonumber(x) and tonumber(y) then
				delayDisplayFrontShadow:position(((x*g_screenX + 1)/g_screenX), (((y - DISTANCE_FRONT_BEHIND)*g_screenY + 1)/g_screenY), true)
				delayDisplayBehindShadow:position(((x*g_screenY + 1)/g_screenX), (((y + DISTANCE_FRONT_BEHIND)*g_screenY + 1)/g_screenY), true)
				delayDisplayFrontShadow:text("FRONT")
				delayDisplayBehindShadow:text("BEHIND")
				delayDisplayFrontShadow:color(0, 0, 0)
				delayDisplayBehindShadow:color(0, 0, 0)
				delayDisplayFrontShadow:visible(true)
				delayDisplayBehindShadow:visible(true)
				delayDisplayFront:position(x, y - DISTANCE_FRONT_BEHIND, true)
				delayDisplayBehind:position(x, y + DISTANCE_FRONT_BEHIND, true)
				delayDisplayFront:text("FRONT")
				delayDisplayBehind:text("BEHIND")
				delayDisplayFront:color(255, 0, 0)
				delayDisplayBehind:color(0, 255, 0)
				delayDisplayFront:visible(true)
				delayDisplayBehind:visible(true)
				setTimer(hideDelayDisplay, TIME_TO_DISPLAY, 1, "both")
				local settingsFile = xmlLoadFile("settings.xml")
				if settingsFile then
					xmlNodeSetAttribute(settingsFile,"x",x)
					xmlNodeSetAttribute(settingsFile,"y",y)
				end
				xmlSaveFile(settingsFile)
				xmlUnloadFile(settingsFile)
			else
				outputChatBox("WRONG PARAMETERS! Syntax is /setdelaypos x y", 255, 0, 0)
			end
		else
			outputChatBox("WRONG PARAMETERS! Syntax is /setdelaypos x y", 255, 0, 0)
		end
	end
)

function msToTimeStr(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	return minutes .. ':' .. seconds .. ':' .. centiseconds
end


-- Exported function for settings menu, KaliBwoy

function showCPDelays()
	triggerServerEvent( "onClientShowCPDelays", resourceRoot )
end

function hideCPDelays()
	triggerServerEvent( "onClientHideCPDelays", resourceRoot )
end
