local showFPS = true


local minFPS = getElementData(root,"anti_fpsMinimum") or false
local maxPing = getElementData(root,"anti_pinglimit") or false
addEventHandler("onClientElementDataChange",root,function(name) if name == "anti_pinglimit" then maxPing = getElementData(root,"anti_pinglimit") elseif name == "anti_fpsMinimum" then getElementData(root,"anti_fpsMinimum") end end)




local drawText, drawWidth, drawFont, drawScale, drawColor, shadowColor, FPSCalc, dangerColor = "", 0, "pricedown", 1, -1, 0xFF000000, 0
local ping,pingText,pingDrawWidth = 0,"",0
local pingHeightOffset = dxGetFontHeight( drawScale, "pricedown" ) -6
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
    function()
        FPSTime = getTickCount() + 1000
        local posX, posY = guiGetScreenSize()
        posX, posY = posX-8, 4
        addEventHandler("onClientRender", getRootElement(),
            function()
                local t = getTickCount()
                if t < FPSTime then
                    FPSCalc = FPSCalc + 1
                else
                    drawText = FPSCalc.." fps"
                    drawWidth = dxGetTextWidth(drawText, drawScale, drawFont)
                    setElementData(getLocalPlayer(), "fps", FPSCalc, true)
                    _FPSCalc = FPSCalc
                    FPSCalc = 0
                    FPSTime = t + 1000

                end

                if not showFPS then return end
                dxDrawText(drawText, posX-drawWidth+2, posY+2, posX+2, posY+2, shadowColor, drawScale, drawFont, "right")
                dxDrawText(drawText, posX-drawWidth, posY, posX, posY, getTextColor(_FPSCalc,"fps"), drawScale, drawFont, "right")

                -- Ping
                if getPlayerPing( localPlayer ) ~= ping then
                    ping = getPlayerPing( localPlayer )
                    pingText = ping.." ping"
                    pingDrawWidth = dxGetTextWidth(pingText, drawScale, drawFont)
                end

                dxDrawText(pingText, posX-pingDrawWidth+2, posY+2+pingHeightOffset, posX+2, posY+2, shadowColor, drawScale, drawFont, "right")
                dxDrawText(pingText, posX-pingDrawWidth, posY+pingHeightOffset, posX, posY, getTextColor(ping,"ping"), drawScale, drawFont, "right")
            end
        )
    end
)
-- outputDebugString("fps:init")

local dangerPercentage = 80 -- when to turn text to orange (over 100% = red) 
function getTextColor(n,theType)
    if tonumber(n) then
        if theType == "fps" and tonumber(minFPS) then

            if n < minFPS then
                return tocolor(255,0,0)
            else
                local danger = minFPS/100*(100-dangerPercentage)
                danger = danger+minFPS

                if n < danger then

                    return tocolor(255,200,0)
                end
            end

        elseif theType == "ping" and tonumber(maxPing) then
            if n > maxPing then
                return tocolor(255,0,0)
            else
                local danger = maxPing/100*dangerPercentage
                if n > danger then
                    tocolor(255,200,0)
                end
            end

        end
    end

    return tocolor(255,255,255)
end



function enableFPS ( b )
    showFPS = not not b
end

-- Exported function for settings menu, KaliBwoy
function e_showFPS()
    showFPS = true
end

function e_hideFPS()
    showFPS = false
end