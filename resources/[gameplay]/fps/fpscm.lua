local showFPS = true

local drawText, drawWidth, drawFont, drawScale, drawColor, shadowColor, FPSCalc = "", 0, "pricedown", 1, -1, 0xFF000000, 0
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
                    FPSCalc = 0
                    FPSTime = t + 1000
                end
				if not showFPS then return end
                dxDrawText(drawText, posX-drawWidth+2, posY+2, posX+2, posY+2, shadowColor, drawScale, drawFont, "right")
                dxDrawText(drawText, posX-drawWidth, posY, posX, posY, drawColor, drawScale, drawFont, "right")
            end
        )
    end
)
-- outputDebugString("fps:init")

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