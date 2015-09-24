function theTool()
	local mode = getResourceFromName'race' and getResourceState(getResourceFromName'race')=='running' and exports.race:getRaceMode()
	if not (mode == "Sprint" or mode == "Never the same") or getElementData(localPlayer, 'markedblocker') then return end
	for _, p in ipairs(getElementsByType'player') do
		if getElementData(p, 'markedblocker') then
			local vehMe = getPedOccupiedVehicle(localPlayer)
			local vehBlocker = getPedOccupiedVehicle(p)
			if vehMe and vehBlocker then
				setElementCollidableWith(vehMe, vehBlocker, false)
				setElementAlpha(vehBlocker, 140)
			end
		end
	end
end
setTimer( theTool, 50, 0)

function onClientExplosion()
	if not (mode == "Sprint" or mode == "Never the same") or getElementData(localPlayer, 'markedblocker') then return end
	if getElementType(source) == "player" and getElementData(p, 'markedblocker') then
		cancelEvent()
	end
end
addEventHandler('onClientExplosion', root, onClientExplosion)

addEvent("onGameMessageSend2", true)
addEventHandler("onGameMessageSend2", getRootElement(),
function(text, lang)
	local URL = "http://translate.google.com/translate_tts?ie=UTF-8&tl=" .. lang .. "&q=" .. text
    -- Play the TTS. BASS returns the sound element even if it can not be played.
	-- playSound(URL)		-- disabled to wait out google ban
end
)
