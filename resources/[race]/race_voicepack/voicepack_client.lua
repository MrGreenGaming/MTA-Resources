soundQueue = {
	-- [1] = filename -- Example Tree
}



function playAudio(filename)
	-- outputDebugString("play sound "..filename)
	if currentSound then -- Add to queue
		table.insert(soundQueue,filename)
	else
		currentSound = playSound("audio/"..filename)
	end
end

function handleQueue()
	if source == currentSound then
		currentSound = nil
	end
	if #soundQueue > 0 then
		playAudio(soundQueue[1])
		table.remove(soundQueue,1)
	end
end
addEventHandler("onClientSoundStopped",root,handleQueue)


addEvent("playClientAudio", true)
addEventHandler("playClientAudio", root, playAudio)

local anniversary = { day = 16, month = 9 }
addEventHandler('onClientResourceStart', resourceRoot,
	function()
		local time = getRealTime()
		if time.monthday == anniversary.day and time.month+1 == anniversary.month then
			return playAudio("party_horn-Mike_Koenig-76599891.mp3")
		end
		playAudio("raceon.mp3")
	end
)

addEvent("onClientPlayerOutOfTime", true)
addEventHandler('onClientPlayerOutOfTime', root,
	function()
		playAudio("timesup.mp3")
	end
)

