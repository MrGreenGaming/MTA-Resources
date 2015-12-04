addEvent("onGameMessageSend2", true)
addEventHandler("onGameMessageSend2", getRootElement(),
function(text, lang)
	local URL = "http://translate.google.com/translate_tts?ie=UTF-8&tl=" .. lang .. "&q=" .. text
    -- Play the TTS. BASS returns the sound element even if it can not be played.
	-- playSound(URL)		-- disabled to wait out google ban
end
)
