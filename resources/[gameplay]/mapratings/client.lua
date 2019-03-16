---------------------
-- /mapinfo window --
---------------------


alpha = 255
backgroundAlpha = 150
	
function sendMapReq(arg)
	triggerServerEvent('requestMapInfo', localPlayer,arg)
end

addEvent('onMapGather', true)
addEventHandler('onMapGather', localPlayer,
function(map,likes,dislikes,timesPlayed, author, description, lastTimePlayed, playerTime, nextmap_)
	info = {}
	mapName = map
		if mapName ~= "-not set-" then info.mapName = true end
	mapPlayerTime = playerTime
		if mapPlayerTime ~= "-not set-" then info.mapPlayerTime = true end
	mapLikes = likes
		if mapLikes ~= "-not set-" then info.mapLikes = true end
	mapDislikes = dislikes
		if mapDislikes ~= "-not set-" then info.mapDislikes = true end
	mapTimesPlayed = timesPlayed
		if mapTimesPlayed ~= "-not set-" then info.mapTimesPlayed = true end
	mapAuthor = author
		if mapAuthor ~= "-not set-" then info.mapAuthor = true end
	mapDescription = description
		if mapDescription ~= "-not set-" then info.mapDescription = true end
	mapLastTimePlayed = lastTimePlayed
		if mapLastTimePlayed ~= "-not set-" then info.mapLastTimePlayed = true end
	nextmap = string.sub((nextmap_ or ''), 1, 155)
	
	mapName = string.sub(mapName, 1, 35)
	mapAuthor = string.sub(mapAuthor, 1, 48)
	mapDescription = string.sub(mapDescription, 1, 106)
	tWidth = dxGetTextWidth(mapName, 1.75, "default-bold")
	lWidth = dxGetTextWidth("Likes: "..mapLikes,1.3, "arial")
	dWidth = dxGetTextWidth("Dislikes: "..mapDislikes,1.3, "arial")
	--info = true 
end
)


screenX, screenY = guiGetScreenSize()
--x,y,width,height = screenX/4, screenY*3/3.8, screenX/2, screenY-(screenY*3/3.8)-30
x,y,width,height = (screenX-500)/2, screenY*3/4, 500, 220
function show()
	if info then
		dxDrawRectangle(x,y,width,height, tocolor(0, 0 , 0, backgroundAlpha))
		if info.mapName then
			dxDrawText(mapName, x+26, y+14, x+width-24, y+34, tocolor(0, 0, 0, alpha), 1.75, "default-bold", "center", "center", true, false, false)
			dxDrawText(mapName, x+28, y+10, x+width-24, y+34, tocolor(0, 0, 0, alpha), 1.75, "default-bold", "center", "center", true, false, false)
			dxDrawText(mapName, x+24, y+6, x+width-24, y+34, tocolor(0, 0, 0, alpha), 1.75, "default-bold", "center", "center", true, false, false)
			dxDrawText(mapName, x+20, y+10, x+width-24, y+34, tocolor(0, 0, 0, alpha), 1.75, "default-bold", "center", "center", true, false, false)
			dxDrawText(mapName, x+24, y+10, x+width-24, y+34, tocolor(255, 255, 255,alpha), 1.75, "default-bold", "center", "center", true, false, false)
		end	
		if info.mapLikes then
			dxDrawText("Likes: "..mapLikes, x+26, y+65, x+width-28, y+80, tocolor(0,0,0,alpha), 1.3, "arial", "left", "center", true, false, false)
			dxDrawText("Likes: "..mapLikes, x+26, y+63, x+width-28, y+80, tocolor(0,0,0,alpha), 1.3, "arial", "left", "center", true, false, false)
			dxDrawText("Likes: "..mapLikes, x+25, y+64, x+width-28, y+80, tocolor(0,0,0,alpha), 1.3, "arial", "left", "center", true, false, false)
			dxDrawText("Likes: "..mapLikes, x+27, y+64, x+width-28, y+80, tocolor(0,0,0,alpha), 1.3, "arial", "left", "center", true, false, false)
			dxDrawText("Likes: "..mapLikes, x+26, y+64, x+width-28, y+80, tocolor(144, 238, 144,alpha), 1.3, "arial", "left", "center", true, false, false)
		end
		if info.mapDislikes then	
			dxDrawText("Dislikes: "..mapDislikes, x+26, y+83, x+width-28, y+100, tocolor(0,0,0,alpha), 1.3, "arial", "left", "center", true, false, false)
			dxDrawText("Dislikes: "..mapDislikes, x+26, y+85, x+width-28, y+100, tocolor(0,0,0,alpha), 1.3, "arial", "left", "center", true, false, false)
			dxDrawText("Dislikes: "..mapDislikes, x+25, y+84, x+width-28, y+100, tocolor(0,0,0,alpha), 1.3, "arial", "left", "center", true, false, false)
			dxDrawText("Dislikes: "..mapDislikes, x+27, y+84, x+width-28, y+100, tocolor(0,0,0,alpha), 1.3, "arial", "left", "center", true, false, false)
			dxDrawText("Dislikes: "..mapDislikes, x+26, y+84, x+width-28, y+100, tocolor(255, 160, 122, alpha), 1.3, "arial", "left", "center", true, false, false)
		end	
		if info.mapAuthor then	
			dxDrawText("Author: "..mapAuthor, x+20, y+40, x+width-20, y+55, tocolor(0,0,0,alpha), 1.3, "arial", "center", "center", true, false, false)
			dxDrawText("Author: "..mapAuthor, x+20, y+44, x+width-20, y+55, tocolor(0,0,0,alpha), 1.3, "arial", "center", "center", true, false, false)
			dxDrawText("Author: "..mapAuthor, x+22, y+42, x+width-20, y+55, tocolor(0,0,0,alpha), 1.3, "arial", "center", "center", true, false, false)
			dxDrawText("Author: "..mapAuthor, x+18, y+42, x+width-20, y+55, tocolor(0,0,0,alpha), 1.3, "arial", "center", "center", true, false, false)
			dxDrawText("Author: "..mapAuthor, x+20, y+42, x+width-20, y+55, tocolor(255, 255, 255, alpha), 1.3, "arial", "center", "center", true, false, false)
		end	
		if info.mapTimesPlayed then	
			dxDrawText("Times played: "..mapTimesPlayed, x+10+lWidth, y+63, x+width-23, y+80, tocolor(0,0,0,alpha), 1.3, "arial", "right", "center", true, false, false)
			dxDrawText("Times played: "..mapTimesPlayed, x+10+lWidth, y+65, x+width-23, y+80, tocolor(0,0,0,alpha), 1.3, "arial", "right", "center", true, false, false)
			dxDrawText("Times played: "..mapTimesPlayed, x+8+lWidth, y+64, x+width-23, y+80, tocolor(0,0,0,alpha), 1.3, "arial", "right", "center", true, false, false)
			dxDrawText("Times played: "..mapTimesPlayed, x+12+lWidth, y+64, x+width-23, y+80, tocolor(0,0,0,alpha), 1.3, "arial", "right", "center", true, false, false)
			dxDrawText("Times played: "..mapTimesPlayed, x+10+lWidth, y+64, x+width-23, y+80, tocolor(255, 255, 255, alpha), 1.3, "arial", "right", "center", true, false, false)
		end	
			
		if info.mapLastTimePlayed then	
			dxDrawText("Last time played: "..mapLastTimePlayed, x+10, y+height-19, x+width-10, y+height-5, tocolor(0,0,0,alpha), 1.2, "arial", "center", "center", true, false, false)
			dxDrawText("Last time played: "..mapLastTimePlayed, x+10, y+height-21, x+width-10, y+height-5, tocolor(0,0,0,alpha), 1.2, "arial", "center", "center", true, false, false)
			dxDrawText("Last time played: "..mapLastTimePlayed, x+9, y+height-20, x+width-10, y+height-5, tocolor(0,0,0,alpha), 1.2, "arial", "center", "center", true, false, false)
			dxDrawText("Last time played: "..mapLastTimePlayed, x+11, y+height-20, x+width-10, y+height-5, tocolor(0,0,0,alpha), 1.2, "arial", "center", "center", true, false, false)
			dxDrawText("Last time played: "..mapLastTimePlayed, x+10, y+height-20, x+width-10, y+height-5, tocolor(255, 255, 255, alpha), 1.2, "arial", "left", "center", true, false, false)
		end	
		-- if info.mapDescription then	
			dxDrawText("Description: "..mapDescription..'\n'..nextmap, x+26, y+110, x+width-23, y+height, tocolor(0,0,0,alpha), 1.3, "arial", "left", "top", true, true, false)
			dxDrawText("Description: "..mapDescription..'\n'..nextmap, x+26, y+112, x+width-23, y+height, tocolor(0,0,0,alpha), 1.3, "arial", "left", "top", true, true, false)
			dxDrawText("Description: "..mapDescription..'\n'..nextmap, x+25, y+111, x+width-23, y+height, tocolor(0,0,0,alpha), 1.3, "arial", "left", "top", true, true, false)
			dxDrawText("Description: "..mapDescription..'\n'..nextmap, x+27, y+111, x+width-23, y+height, tocolor(0,0,0,alpha), 1.3, "arial", "left", "top", true, true, false)
			dxDrawText("Description: "..mapDescription..'\n'..nextmap, x+26, y+111, x+width-23, y+height, tocolor(255, 255, 255, alpha), 1.3, "arial", "left", "top", true, true, false)
		-- end
		-- if info.mapPlayerTime then	
			-- dxDrawText("Personal best time: "..mapPlayerTime, x+10, y+height-21-23, x+width-10, y+height-5, tocolor(0,0,0,alpha), 1.2, "arial", "left", "center", true, false, false)
			-- dxDrawText("Personal best time: "..mapPlayerTime, x+10, y+height-19-23, x+width-10, y+height-5, tocolor(0,0,0,alpha), 1.2, "arial", "left", "center", true, false, false)
			-- dxDrawText("Personal best time: "..mapPlayerTime, x+9, y+height-20-23, x+width-10, y+height-5, tocolor(0,0,0,alpha), 1.2, "arial", "left", "center", true, false, false)
			-- dxDrawText("Personal best time: "..mapPlayerTime, x+11, y+height-20-23, x+width-10, y+height-5, tocolor(0,0,0,alpha), 1.2, "arial", "left", "center", true, false, false)
			-- dxDrawText("Personal best time: "..mapPlayerTime, x+10, y+height-20-23, x+width-10, y+height-5, tocolor(255, 255, 255, alpha), 1.2, "arial", "left", "center", true, false, false)
		-- end	
		if info.mapName then
			dxDrawLine(x+((width-tWidth)/2), y+34, ((x+(width-tWidth)/2)+tWidth), y+34, tocolor(104, 232, 44, 70), 3)
		end	
	end	
end

function stopShowing()
	isShow = false
	removeEventHandler('onClientRender', root, show) 
	if isTimer(timerAlpha) then killTimer(timerAlpha) end
end

isShow = false
function showmapinfo(commandname, ...)
	if #{...}>0 then
		arg = table.concat({...},' ')
	else arg = nil
	end	
	if not isShow then
		isShow = true
		--info = false
		sendMapReq(arg)
		timerAlpha = setTimer(stopShowing, 15000, 1)
		addEventHandler('onClientRender', root, show)
	else removeEventHandler('onClientRender', root, show) 
		isShow = false
		if isTimer(timerAlpha) then killTimer(timerAlpha) end
	end
end
addCommandHandler('mapinfo',showmapinfo)
bindKey('f5', 'down', function() showmapinfo() end)

addEvent('onClientMapStarting', true)
addEventHandler('onClientMapStarting', root, function() showmapinfo() end)


--------------------
-- nextmap window --
--------------------

drawNextText = ''
_nextWidth = 0
_nextHeight = 0
addEventHandler('onClientElementDataChange', root,
function(name, oldvalue)
	if source == getResourceRootElement() and name == 'gamemode.nextmap' then
		local what = getElementData(getResourceRootElement(), 'gamemode.nextmap')
		drawNextText = what
		_nextWidth = dxGetTextWidth(what, 0.45, 'bankgothic')
		_nextHeight = dxGetFontHeight(0.45, 'bankgothic') * 3
	end
end
)
g__sW, g__sH = guiGetScreenSize()
hidenext = true
addEventHandler("onClientRender",root,
    function()
		if _nextWidth == 0 or hidenext then return end
        dxDrawRectangle((g__sW-100)-(_nextWidth+20), 4, _nextWidth+20, _nextHeight+5, tocolor(0,0,0,100),false)
		dxDrawText(drawNextText, (g__sW-100)-(_nextWidth+20)+5, 5, (g__sW-100)-(_nextWidth+20)+_nextWidth+15, 5+_nextHeight+5, tocolor(0, 255, 0, 255), 0.45, 'bankgothic', 'center', 'center', true)
    end
)

if getElementData(getResourceRootElement(), 'gamemode.nextmap') then
	drawNextText = getElementData(getResourceRootElement(), 'gamemode.nextmap')
	_nextWidth = dxGetTextWidth(drawNextText, 0.45, 'bankgothic')
	_nextHeight = dxGetFontHeight(0.45, 'bankgothic') * 3
end

addCommandHandler('hidenext', function() hidenext = not hidenext; outputChatBox('Hidenext: ' .. tostring(hidenext)) end)


-- Exported function for settings menu, KaliBwoy
function showNextMapWindow()
	hidenext = false
end

function hideNextMapWindow()
	hidenext = true
end
