SONGNAME = "music.mp3"
MESSAGE = "Press M to turn the music ON/OFF"
EXTRAMESSAGE = nil -- "If you press M you will get banned"

function startMusic()
	-- setRadioChannel(0)
	songOn = false
	song = playSound(SONGNAME,true)
	setSoundVolume(song,1)
	outputChatBox(MESSAGE)
	if (EXTRAMESSAGE) then
		outputChatBox(EXTRAMESSAGE,255,255,255,true)
	end
end

function makeRadioStayOff(cancel)
	if (not songOn) then
		return
	end
	setRadioChannel(0)
	if (cancel) then
		cancelEvent()
	end
end

function toggleSong()
	if songOn then
		setSoundVolume(song,1)
		songOn = false
	else
		setSoundVolume(song,0)
		songOn = true
		setRadioChannel(0)
	end
end

addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),startMusic)
addEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff,true)
addEventHandler("onClientPlayerVehicleEnter",getRootElement(),makeRadioStayOff,false)
addCommandHandler("togglemusic",toggleSong)
bindKey("m","down","togglemusic")
-- addEventHandler("onClientResourceStop",getResourceRootElement(getThisResource()),startMusic)
