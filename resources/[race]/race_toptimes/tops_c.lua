local tops = 8
local posx, posy = 0.55, 0.015
local sizex, sizey = 300, 46+15*(tops+3)
local image = 'backg1a.png'
local imageColor = tocolor(255,255,255,255)
local titleHeight = 38
local topsAreaHeight = 227
local personalTopHeight = 34
local monthlyTopHeight = 34
local textColor = tocolor(255,255,255)
local selfTextColor = tocolor(0,255,255)
local scaleX, scaleY = 1, 1
local font = 'default-bold'
local pos = {x=0.0,y=0.08}
local nick = {x=0.1,y=0.4}
local value = {x=0.5,y=0.7}
local date = {x=0.7,y=0.95}
local fadeTime = 300
local showTime = 15000

local resx, resy = guiGetScreenSize()
posx, posy = math.floor(posx*resx), math.floor(posy*resy)
local texture = dxCreateTexture(image)
local w,h = dxGetMaterialSize(texture)
local sw,sh = sizex/w,sizey/h
local target = dxCreateRenderTarget(sizex, sizey, true)
local times = {}
local monthlyTopTime
local alpha = 0
local fading = 0
local timer = nil
local tick
local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

addEvent('updateTopTimes', true)
addEventHandler('updateTopTimes', resourceRoot, function(t)
	times = t
	updateTexture()
end)

addEvent('updateMonthTime', true)
addEventHandler('updateMonthTime', resourceRoot, function(t)
	monthlyTopTime = t
	updateTexture()
end)

addEventHandler('onClientResourceStart', resourceRoot,
	function()
		triggerServerEvent('clientstarted', resourceRoot)
	end
)

addEventHandler('onClientMapStarting', getRootElement(),
	function(mapinfo)
		toggleTimes(true)
	end
)

addEvent('onClientPlayerFinish')
addEventHandler('onClientPlayerFinish', getRootElement(),
	function()
		toggleTimes(true)
	end
)

function toggleTimes(b)
	if timer then
		if isTimer(timer) then
			killTimer(timer)
		end
		timer = nil
	end
	if b or fading == -1 or (fading == 0 and alpha < 1) then
		fading = 1
		timer = setTimer(toggleTimes, showTime, 1)
	else
		fading = -1
	end
	tick = getTickCount()
end
addCommandHandler('showtops', function()
	toggleTimes(true)
end)
bindKey('F5', 'down', function() toggleTimes() end)

function updateTexture()
	dxSetRenderTarget(target, true)
	--dxDrawImage(0,0,sizex,sizey,texture,0,0,0,imageColor)
	dxDrawRectangle(0, 0, 446, 334, tocolor(0, 0, 0, 200), isPostGUI,false) --background
	dxDrawRectangle(0, 0, 446, 23, tocolor(11, 138, 25, 255), isPostGUI,false) --title
	dxDrawRectangle(0, 0, 446, 12.5, tocolor(11, 180, 25, 255), isPostGUI,false) --title glass effect
	dxDrawRectangle(0, 167, 446, 1, tocolor(255, 255, 255, 100), isPostGUI,false) --line1
	dxDrawRectangle(0, 188, 446, 1, tocolor(255, 255, 255, 100), isPostGUI,false) --line2
	dxDrawText('Top Times - ' .. string.sub((times.mapname or ''), 1, 35), 0, 0, w*sw, titleHeight*sh, textColor, scaleX, scaleY, font, 'center', 'center', true)
	local i = 1
	for k, r in ipairs(times) do
		local textColor = r.player == localPlayer and selfTextColor or textColor
		if k <= tops then
			dxDrawText(k..'.', w*pos.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*pos.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
			dxDrawText((r.mta_name), w*nick.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*nick.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'left', 'center', true, false, false, true)
			dxDrawText(times.kills and r.value..' kills' or timeMsToTimeText(r.value), w*value.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*value.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'center', 'center')
			dxDrawText(r.formatDate, w*date.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*date.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
			i = i + 1
		end
		if r.player == localPlayer then
			dxDrawText(k..'.', w*pos.x*sw, (titleHeight+topsAreaHeight)*sh, w*pos.y*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
			dxDrawText((r.mta_name), w*nick.x*sw, (titleHeight+topsAreaHeight)*sh, w*nick.y*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, textColor, scaleX, scaleY, font, 'left', 'center', true, false, false, true)
			dxDrawText(times.kills and r.value..' kills' or timeMsToTimeText(r.value), w*value.x*sw, (titleHeight+(tops)*topsAreaHeight/tops)*sh, w*value.y*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, textColor, scaleX, scaleY, font, 'center', 'center')
			dxDrawText(r.formatDate, w*date.x*sw, (titleHeight+(tops)*topsAreaHeight/tops)*sh, w*date.y*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
		end
	end
	local s = i
	for i = s,tops do
		dxDrawText(i..'.', w*pos.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*pos.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
		dxDrawText('-- Empty --', w*nick.x*sw, (titleHeight+(i-1)*topsAreaHeight/tops)*sh, w*nick.y*sw, (titleHeight+(i)*topsAreaHeight/tops)*sh, textColor, scaleX, scaleY, font, 'left', 'center')
	end
	if monthlyTopTime then
		local textColor = monthlyTopTime.player == localPlayer and selfTextColor or textColor
		dxDrawText(months[monthlyTopTime.month], w*pos.x*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, w*pos.y*sw, (titleHeight+topsAreaHeight+personalTopHeight+monthlyTopHeight)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
		dxDrawText((monthlyTopTime.mta_name), w*nick.x*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, w*nick.y*sw, (titleHeight+topsAreaHeight+personalTopHeight+monthlyTopHeight)*sh, textColor, scaleX, scaleY, font, 'left', 'center', true, false, false, true)
		dxDrawText(monthlyTopTime.kills and monthlyTopTime.value..' kills' or timeMsToTimeText(monthlyTopTime.value), w*value.x*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, w*value.y*sw, (titleHeight+topsAreaHeight+personalTopHeight+monthlyTopHeight)*sh, textColor, scaleX, scaleY, font, 'center', 'center')
		dxDrawText(monthlyTopTime.formatDate, w*date.x*sw, (titleHeight+topsAreaHeight+personalTopHeight)*sh, w*date.y*sw, (titleHeight+topsAreaHeight+personalTopHeight+monthlyTopHeight)*sh, textColor, scaleX, scaleY, font, 'right', 'center')
	end
	dxSetRenderTarget()
end
addEventHandler("onClientRestore",root,updateTexture)

addEventHandler('onClientRender', root, function()
	if fading ~= 0 then
		local t = getTickCount() + 1
		if fading == 1 then
			alpha = (t - tick)/(fadeTime)*255
		else
			alpha = (1-(t - tick)/(fadeTime))*255
		end
		if alpha <= 0 then
			alpha = 0
			fading = 0
		elseif alpha >= 255 then
			alpha = 255
			fading = 0
		end
	end
	if alpha > 0 then
		dxDrawImage(posx, posy, sizex, sizey, target, 0, 0, 0, tocolor(255,255,255,alpha))
	end
end)

function timeMsToTimeText( timeMs )

	local minutes	= math.floor( timeMs / 60000 )
	timeMs			= timeMs - minutes * 60000;

	local seconds	= math.floor( timeMs / 1000 )
	local ms		= timeMs - seconds * 1000;

	return string.format( '%2d:%02d:%03d', minutes, seconds, ms );
end

function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

