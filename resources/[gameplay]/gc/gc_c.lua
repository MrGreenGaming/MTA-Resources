local x, y = guiGetScreenSize()
local yPos = y/8*6
-- local yPos = y * 0.95
-- local xPos = x * 0.85
local alpha = 0
local FADING_ALPHA = 5
local gc = 0
local fade = 0
local green = 255
local pulse = false
local pulseAmount = 30
local pulses = 0
local pulseMaxRepetitions = 3
local pulseDir = "out"

local gc_name = ""
local gc_email = ""

function draw()
	--Fade in
	if fade == 1 then
		if alpha <= (255-FADING_ALPHA) then
			alpha = alpha+FADING_ALPHA
		else
			alpha = 255
			fade = 0
		end
	--Fade out
	elseif fade == 2 then
		if alpha >= FADING_ALPHA then
			alpha = alpha-FADING_ALPHA
		else
			alpha = 0
			fade = 0
		end
	end
	
	if pulse then
		if pulses < pulseMaxRepetitions then
			if green > 0 and pulseDir == "out" then
				green = green-pulseAmount
				if green <= 0 then
					green = 0
					pulseDir = "in"
				end
			elseif green < 255 then
				green = green+pulseAmount
				if green >= 255 then
					green = 255
					pulses = pulses + 1
					pulseDir = "out"
				end
			end
		else
			pulse = false
			pulses = 0
		end
	end

	--No need to draw
	if alpha == 0 then
		return
	end
	
	--Background
	local width = math.max(dxGetTextWidth("GreenCoins", 0.5, "bankgothic"), dxGetTextWidth(string.gsub( gc, "#%x%x%x%x%x%x", "" ), 0.5, "bankgothic"))
	local height = dxGetFontHeight(0.5, "bankgothic")*2+15
	
	local dy = 0.005 -- y distance between elements
	local fontHeight = dxGetFontHeight(3, 'sans') / y
	local xPos, yPos = (0.99 + 0.003) * x, (0.95 - fontHeight * 3 - dy * 3)*y -- origin point: bottom right
	
	-- dxDrawImage(xPos, yPos, width+20, height, "img/dot.png", 0, 0, 0, tocolor(0, 0, 0, math.max(alpha-75, 0)))
	dxDrawRectangle(xPos - width-20, yPos - height, width+20, height, tocolor(0, 0, 0, math.max(alpha-105, 0)))
	dxDrawText("GreenCoins", xPos - width-20, yPos-height, xPos, yPos+height/2, tocolor(255, 255, 255, alpha), 0.5, "bankgothic", "center", "top", false, false, false)
	dxDrawText(tostring(gc), xPos - width-20, yPos-height/2, xPos, yPos, tocolor(255, 255, 255, alpha), 0.5, "bankgothic", "center", "top", false, false, false, true)
end
addEventHandler("onClientRender", root, draw)

function toggleGCInfo(state)
	if state == false then
		if alpha > 0 then
			if alpha == 255 then
				fade = 2
			else
				alpha = 0
			end
		end
	elseif state == true then
		if alpha < 255 then
			if alpha == 0 then
				fade = 1
			else
				alpha = 255
			end
		end
	elseif fade == 0 then
		if alpha >= 255 then
			fade = 2
		else
			fade = 1
		end
	end
	return true
end
addCommandHandler("gc", toggleGCInfo)

function setGC(amount, notLoggedIn)
	gc = (notLoggedIn and '' or '#00FF00') .. comma_value(amount)
	pulse = true
	setElementData(getLocalPlayer(), "greencoins",tostring(gc), true)
end

addEvent("onGCChange", true)
addEventHandler("onGCChange", root, setGC)

function setVisible(state)
	if state == true then
		fade = 1
	elseif state == false then
		fade = 2
	end
end

addEvent("onGCSetVisible", true)
addEventHandler("onGCSetVisible", root, setVisible)

function loginSuccess(gcAmount, name, email)
	if gcAmount then
		setGC(gcAmount)
	end
	fade = 1
	if email then
		gc_name = name
		gc_email = email
		outputChatBox("[GC] You successfully logged in as " .. gc_name .. '/' .. gc_email ..".", 0, 255, 0)
	end
end

addEvent("onLoginSuccess", true)
addEventHandler("onLoginSuccess", root, loginSuccess)

function loginFail(alreadyLoggedIn, databaseDown)
	if alreadyLoggedIn then
		outputChatBox("[GC] You are already logged in as " .. gc_name .. '/' .. gc_email ..".", 255, 0, 0)
	elseif databaseDown then
		outputChatBox("[GC] GreenCoins database is not available at this moment. Please try again at a later moment.", 255, 0, 0)
	else
		outputChatBox("[GC] Wrong email or password entered.", 255, 0, 0)
	end
end

addEvent("onLoginFail", true)
addEventHandler("onLoginFail", root, loginFail)

function forumAvatar(player, data, forumid)
	if fileExists("img/photo-thumb-" .. forumid .. ".png") then
		fileDelete("img/photo-thumb-" .. forumid .. ".png")
	end
	-- outputDebugString("forumAvatarc " .. forumid)
	local myTexture = dxCreateTexture( data )
	if myTexture then
		-- outputDebugString("forumAvatarc2 " .. forumid)
		local file = fileCreate("img/photo-thumb-" .. forumid .. ".png")
		fileWrite(file, data)
		fileClose(file)
		setElementData(player,"forumAvatar",{type = "image",src = ":gc/img/photo-thumb-" .. forumid .. ".png",width = 20,height = 20}, false)
		exports.scoreboard:scoreboardForceUpdate()
		destroyElement(myTexture)
	end
end
addEvent("forumAvatar", true)
addEventHandler("forumAvatar", root, forumAvatar)


function gcLogin(cmdName, email, password)
	triggerServerEvent("onLogin", localPlayer, email, password)
end
addCommandHandler("gcLogin", gcLogin, false, false)

function gcLogout(cmdName)
	triggerServerEvent("onLogout", localPlayer)
end
addCommandHandler("gcLogout", gcLogout, false, false)

function logoutSuccess()
	setVisible(false)
	gc = 0
	gc_email = ""
	gc_name = ""
	setElementData(getLocalPlayer(), "greencoins", nil, true)
end
addEvent("onLogoutSuccess", true)
addEventHandler("onLogoutSuccess", root, logoutSuccess)

function clientStart()
	triggerServerEvent('onClientGreenCoinsStart', getLocalPlayer())
end
addEventHandler("onClientResourceStart", resourceRoot, clientStart)

-- http://lua-users.org/wiki/FormattingNumbers
function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
    if (k==0) then
      break
    end
  end
  return formatted
end

-- Exported function for settings menu, KaliBwoy
function e_showGC()
	if alpha < 255 then
		if alpha == 0 then
			fade = 1
		else
			alpha = 255
		end
	end
end

function e_hideGC()
	if alpha > 0 then
		if alpha == 255 then
			fade = 2
		else
			alpha = 0
		end
	end
end