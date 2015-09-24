function showText_Create(red, green, blue, text, time, thePlayer)
showText_Display = textCreateDisplay ()
showText_Text = textCreateTextItem ( "", 0.5, 0.3, 2, 0, 255, 0, 255, 2.3, "center", "center", 255 )
textDisplayAddText ( showText_Display, showText_Text )
end

function showText ( red, green, blue, text, time, thePlayer )
textItemSetColor ( showText_Text, red, green, blue, 255 )
textItemSetText ( showText_Text, text )
outputChatBox(RGBToHex(red, green, blue)..text, thePlayer, red, green, blue, true)
	
	if ( showText_timer	) then
		killTimer ( showText_timer )
	else
		if thePlayer == all then
			local players = getElementsByType( "player" )
			for k,v in ipairs(players) do
				textDisplayAddObserver ( showText_Display, v )
			end
		else
			textDisplayAddObserver ( showText_Display, thePlayer )
		end
	end
	
	showText_timer = setTimer( showText_Remove, time, 1 )
end

function showText_Remove()
showText_timer = nil
local players = getElementsByType( "player" )
	
	for k,v in ipairs(players) do
		textDisplayRemoveObserver( showText_Display, v )
	end
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

