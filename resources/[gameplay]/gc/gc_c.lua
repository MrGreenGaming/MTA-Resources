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

local gc_email = ""

function draw()
    -- fading
    if fade == 1 then
        if alpha <= 255-FADING_ALPHA then
            alpha = alpha+FADING_ALPHA
        else
            alpha = 255
            fade = 0
        end
    elseif fade == 2 then
        if alpha >= 0+FADING_ALPHA then
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
    
    -- bg
    local width = math.max(dxGetTextWidth("GreenCoins", 0.5, "bankgothic"), dxGetTextWidth(string.gsub( gc, "#%x%x%x%x%x%x", "" ), 0.5, "bankgothic"))
    local height = dxGetFontHeight(0.5, "bankgothic")*2+15
    
    -- dxDrawImage(x-width-40, yPos, width+20, height, "img/dot.png", 0, 0, 0, tocolor(0, 0, 0, math.max(alpha-75, 0)))
    -- dxDrawText("Greencoins", x-width-40, yPos, x-20, yPos-height/2, tocolor(255, 255, 255, alpha), 0.5, "bankgothic", "center", "top", false, false, false)
    -- dxDrawText(tostring(gc), x-width-40, yPos+height/2, x-20, yPos, tocolor(0, green, 0, alpha), 0.5, "bankgothic", "center", "top", false, false, false, true)
	
	local dy = 0.005									-- y distance between elements
	local fontHeight = dxGetFontHeight ( 3, 'sans' ) / y
	local xPos, yPos = (0.99 + 0.003) * x, (0.95 - fontHeight * 3 - dy * 3)*y						-- origin point: bottom right
	
    -- dxDrawImage(xPos, yPos, width+20, height, "img/dot.png", 0, 0, 0, tocolor(0, 0, 0, math.max(alpha-75, 0)))
	dxDrawRectangle ( xPos - width-20, yPos - height, width+20, height, tocolor ( 0 ,0,0,math.max(alpha-105, 0)))
    dxDrawText("GreenCoins", xPos - width-20, yPos-height, xPos, yPos+height/2, tocolor(255, 255, 255, alpha), 0.5, "bankgothic", "center", "top", false, false, false)
    dxDrawText(tostring(gc), xPos - width-20, yPos-height/2, xPos, yPos, tocolor(255, 255, 255, alpha), 0.5, "bankgothic", "center", "top", false, false, false, true)
    
end
addEventHandler("onClientRender", root, draw)

function toggleGCInfo( state )
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

function setGC ( amount, notLoggedIn )
    gc = (notLoggedIn and '' or '#00FF00') .. amount
    pulse = true
	setElementData(getLocalPlayer(), "greencoins",tostring(gc), true)
end

addEvent("onGCChange", true)
addEventHandler("onGCChange", root, setGC)

function setVisible( state )
    if state == true then
        fade = 1
    elseif state == false then
        fade = 2
    end
end

addEvent("onGCSetVisible", true)
addEventHandler("onGCSetVisible", root, setVisible)

function loginSuccess( gcAmount, email )
    if gcAmount then
        setGC(gcAmount)
    end
    fade = 1
	if email then
		gc_email = email
		outputChatBox("[GC] You successfully logged in! (" .. gc_email ..")", 0, 255, 0)
	end
end

addEvent("onLoginSuccess", true)
addEventHandler("onLoginSuccess", root, loginSuccess)

function loginFail(alreadyLoggedIn, databaseDown)
    if alreadyLoggedIn then
        outputChatBox("[GC] You are already logged in! (" .. gc_email ..")", 255, 0, 0)
    elseif databaseDown then
        outputChatBox("[GC] Greencoins database is down, could not login!", 255, 0, 0)
    else
        outputChatBox("[GC] Wrong email or password entered!", 255, 0, 0)
    end
end

addEvent("onLoginFail", true)
addEventHandler("onLoginFail", root, loginFail)

function gcLogin(cmdName, email, password)
    triggerServerEvent("onLogin", localPlayer, email, password)
end

addCommandHandler("gcLogin", gcLogin, false, false)

function gcLogout(cmdName)
    triggerServerEvent("onLogout", localPlayer)
end

addCommandHandler("gcLogout", gcLogout, false, false)

function logoutSuccess ()
    setVisible(false)
    gc = 0
	gc_email = ""
	setElementData(getLocalPlayer(), "greencoins", nil, true)
end

addEvent("onLogoutSuccess", true)
addEventHandler("onLogoutSuccess", root, logoutSuccess)

function clientStart ()
	triggerServerEvent('onClientGreenCoinsStart', getLocalPlayer())
end

addEventHandler("onClientResourceStart", resourceRoot, clientStart)

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

