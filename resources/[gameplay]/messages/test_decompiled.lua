--to call the function from serverside: exports.messages:outputGameMessage(text, visibleTo, size, r, g, b, priorityFromGettingQueued) 
--to call it from clientside: exports.messages:outputGameMessage(text, size, r, g, b, priorityFromGettingQueued)
--size, r, g, b, priorityFromGettingQueued are optional parameters
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
screenX,screenY = guiGetScreenSize()

textVar = nil
alpha = 255
textDelayTable = {}

function _getPlayerName(player)
	local name = getPlayerName(player)
	return string.gsub(name, '#%x%x%x%x%x%x', '' )
end

addCommandHandler('hidemsg', function() hidemsg = not hidemsg; outputChatBox('Hidemsg: ' .. tostring(hidemsg)) end)


function outputGameMessage(tex, size, r, g, b, priority)
	text = string.gsub(tex, '#%x%x%x%x%x%x', '' )
	if size == nil then size = 2.2 end
	if (r == nil) or (g == nil) or (b == nil) then 
		r = 255
		g = 255
		b = 255
	end	
	if hidemsg then
            outputChatBox("[Game Message] "..text,r,g,b)
        return
    end
	if priority then
			textVar = dxText:create(text, screenX/2, 0.2*screenY, false)
			textVar:scale(size)
			textVar:font("sans")
			textVar:type("border", 3)
			textVar:color(r, g, b, alpha)
			Animation.createAndPlay(textVar, Animation.presets.dxTextFadeIn(500), Animation.presets.dxTextFadeIn(500), Animation.presets.dxTextMoveResize(screenX/2, -100, 0.5, 7000, false, screenX/2, 0.2*screenY, size))
			setTimer(function(localText) dxText:create(localText) localText:destroy()  end, 9000, 1, textVar)
			return
	end
	if lastTick then
		k = 0
		for i,j in pairs(textDelayTable) do 
			if isTimer(j) then k = k + 1 end
		end
		if k == 0 then add = 0 end
		if (getTickCount() - lastTick > 500) and (k == 0) then
			textVar = dxText:create(text, screenX/2, 0.2*screenY, false)
			textVar:scale(size)
			textVar:font("sans")
			textVar:type("border", 3)
			textVar:color(r, g, b, alpha)
			Animation.createAndPlay(textVar, Animation.presets.dxTextFadeIn(500), Animation.presets.dxTextFadeIn(500), Animation.presets.dxTextMoveResize(screenX/2, -100, 0.5, 7000, false, screenX/2, 0.2*screenY, size))
			setTimer(function(localText) dxText:create(localText) localText:destroy()  end, 9000, 1, textVar)
			
			lastTick = getTickCount()
			add = 0
		else
			add = add + 500
			textDelayTable[text] = setTimer(
			function(txt, scale, rr, gg, bb) 
				textVar = dxText:create(txt, screenX/2, 0.2*screenY, false)
				textVar:scale(scale)
				textVar:font("sans")
				textVar:type("border", 3)
				textVar:color(rr, gg, bb, alpha)
				Animation.createAndPlay(textVar, Animation.presets.dxTextFadeIn(500), Animation.presets.dxTextFadeIn(500), Animation.presets.dxTextMoveResize(screenX/2, -100, 0.5, 7000, false, screenX/2, 0.2*screenY, scale))
				setTimer(function(localText) dxText:create(localText) localText:destroy()  end, 9000, 1, textVar)
			end, add, 1, text, size, r, g, b)
		end
	else 
			textVar = dxText:create(text, screenX/2, 0.2*screenY, false)
			textVar:scale(size)
			textVar:font("sans")
			textVar:type("border", 3)
			textVar:color(r, g, b, alpha)
			Animation.createAndPlay(textVar, Animation.presets.dxTextFadeIn(500), Animation.presets.dxTextFadeIn(500), Animation.presets.dxTextMoveResize(screenX/2, -100, 0.5, 7000, false, screenX/2, 0.2*screenY, size))
			setTimer(function(localText) dxText:create(localText) localText:destroy()  end, 9000, 1, textVar)
			lastTick = getTickCount()
			add = 0
	end		
end



--[[addEventHandler('onClientElementDataChange', getRootElement(),
function(dataChanged, oldValue)
	if (getLocalPlayer() == source) and (dataChanged == ("race rank")) then
		if timePassed == true then
			local newRank = getElementData(getLocalPlayer(), "race rank")
			if newRank == 1 then outputGameMessage("You are 1st")
				elseif newRank == 2 then outputGameMessage("You are 2nd")
				elseif newRank == 3 then outputGameMessage("You are 3rd")
				elseif newRank == 4 then outputGameMessage("You are 4th")
				elseif newRank == 5 then outputGameMessage("You are 5th")
			end
		end
	end	
end
)]]



addEvent("onGameMessageSend", true)
addEventHandler("onGameMessageSend", getRootElement(),
function(text, size, r, g, b)
	outputGameMessage(text, size, r, g, b)
end
)

addEventHandler('onClientPlayerWasted', getRootElement(),
function()
	if source == getLocalPlayer() then outputGameMessage("You've died!") return end
	local otherRank = getElementData(source, "race rank")
	local myRank = getElementData(getLocalPlayer(), "race rank")
	myRank = tostring(myRank)
	otherRank = tostring(otherRank)
	if type(otherRank) == 'string' and type(myRank) == 'string' then
		otherRank = tonumber(otherRank)
		myRank = tonumber(myRank)
		if timePassed and otherRank and myRank then
			if math.abs(otherRank - myRank) == 1 then
				local suffix
				local lastNumber = otherRank % 10
				if lastNumber == 1 then
					suffix = "st"
				elseif lastNumber == 2 then
					suffix = "nd"
				elseif lastNumber == 3 then
					suffix = "rd"
				else suffix = "th"
				end	
				if (otherRank == 11) or (otherRank == 12) or (otherRank == 13) then suffix = "th" end
				outputGameMessage(_getPlayerName(source).. " has just died! ".."Ranked: "..tostring(otherRank)..suffix)
			end	
		end	
	end
end
)

addEvent('onClientMapStopping', true)
addEventHandler('onClientMapStopping', root,
function()
	for i,j in pairs(textDelayTable) do 
			if isTimer(j) then
				killTimer(j) 
			end
	end	
	textDelayTable = {}
end
)

addEvent('getTimePassed' , true)
addEventHandler('getTimePassed', getRootElement(),
function(time, newMap)
	if time == "true" then timePassed = true
	elseif time == "false" then timePassed = false
	elseif time == false then timePassed = false
	end
end
)

-- Exported function for settings menu, KaliBwoy
function hideFloatMessages()
	hidemsg = true
end

function showFloatMessages()
	hidemsg = false
end