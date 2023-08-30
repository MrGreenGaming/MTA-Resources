local colorBlinkDelay = 1000

function showText(red, green, blue, text, time, player)
    local showText_Display = textCreateDisplay()
    local showText_Text = textCreateTextItem(text, 0.5, 0.3, 2, red, green, blue, 255, 2.3, "center", "center", 255)
    textDisplayAddText(showText_Display, showText_Text)

    local hexColor = RGBToHex(red, green, blue)
    outputChatBox(hexColor .. text, player, red, green, blue, true)

    textDisplayAddObserver(showText_Display, player)

    local function setColorToWhite()
        textItemSetColor(showText_Text, 255, 255, 255, 255)
    end

    local function blinkText()
        textItemSetColor(showText_Text, red, green, blue, 255)
        setTimer(setColorToWhite, 600, 1)
    end

    for _ = colorBlinkDelay, time - colorBlinkDelay, colorBlinkDelay do
        setTimer(blinkText, _, 1)
    end

    setTimer(function(thePlayer)
        textDisplayRemoveObserver(showText_Display, thePlayer)
    end, time, 1, player)
end

function RGBToHex(red, green, blue, alpha)
	if((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) or (alpha and (alpha < 0 or alpha > 255))) then
		return nil
	end
	if(alpha) then
		return string.format("#%.2X%.2X%.2X%.2X", red,green,blue,alpha)
	else
			return string.format("#%.2X%.2X%.2X", red,green,blue)
	end
end
