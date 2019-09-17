addEvent('its_time_to_duel.mp3', true)
addEventHandler('its_time_to_duel.mp3', resourceRoot, function()
	playSound('files/its_time_to_duel.mp3')
end)

--------------------
-- Duel CountDown --
--------------------
local screenW, screenH = guiGetScreenSize()
local duelCountDownSeconds = false
addEvent('duelCountdown', true)
function setDuelCountDownSeconds(seconds)
	removeEventHandler('onClientRender', root, drawDuelCountDown)
	duelCountDownSeconds = tonumber(seconds) and seconds ~= 1 and seconds or false
	if duelCountDownSeconds then
		addEventHandler('onClientRender', root, drawDuelCountDown)
	end
end
addEventHandler('duelCountdown', resourceRoot, setDuelCountDownSeconds)
addEvent('onClientMapStarting', true)
addEventHandler ( "onClientMapStarting", localPlayer, function() setDuelCountDownSeconds(false) end)

function drawDuelCountDown()
	if not duelCountDownSeconds then
		removeEventHandler( 'onClientRender', root, drawDuelCountDown )
		 return 
	end
	dxDrawText("Duel will start in: "..duelCountDownSeconds.." seconds", 0, 0, screenW * 1.000 + 1, screenH * 1 + 1, tocolor(0, 0, 0, 255), 1.50, "bankgothic", "center", "center", false, false, false, false, false)
	dxDrawText("Duel will start in: "..duelCountDownSeconds.." seconds", 0, 0, screenW * 1.000, screenH * 1, tocolor(255, 255, 255, 255), 1.50, "bankgothic", "center", "center", false, false, false, false, false)
end

