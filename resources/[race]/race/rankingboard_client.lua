local sx,sy = guiGetScreenSize()

RankingBoard = {}
RankingBoard.__index = RankingBoard

RankingBoard.instances = {}


local screenWidth, screenHeight = guiGetScreenSize()
local topDistance = 250
local bottomDistance = 0.26*screenHeight
local posLeftDistance = 30
local nameLeftDistance = 60
local labelHeight = 16
local maxPositions = math.floor((screenHeight - topDistance - bottomDistance)/labelHeight)

local RenderTarget = dxCreateRenderTarget(screenWidth * 0.248, screenHeight * 0.281,true)


posLabel = {}
playerLabel = {}

function RankingBoard.create(id)
	-- RankingBoard.instances[id] = setmetatable({ id = id, direction = 'down', labels = {}, position = 0 }, RankingBoard)
	-- posLabel = {}
	-- playerLabel = {}
end

function RankingBoard.call(id, fn, ...)
	-- RankingBoard[fn](RankingBoard.instances[id], ...)
end

function RankingBoard:setDirection(direction, plrs)
	-- self.direction = direction
	-- if direction == 'up' then
	-- 	self.highestPos = plrs
	-- 	self.position = self.highestPos + 1
	-- end
end

function RankingBoard:add(name, time)
	-- local position
	-- local y
	-- local doBoardScroll = false
	-- if self.direction == 'down' then
	-- 	self.position = self.position + 1
	-- 	if self.position > maxPositions then
	-- 		return
	-- 	end
	-- 	y = topDistance + (self.position-1)*labelHeight
	-- elseif self.direction == 'up' then
	-- 	self.position = self.position - 1
	-- 	local labelPosition = self.position
	-- 	if self.highestPos > maxPositions then
	-- 		labelPosition = labelPosition - (self.highestPos - maxPositions)
	-- 		if labelPosition < 1 then
	-- 			labelPosition = 0
	-- 			doBoardScroll = true
	-- 		end
	-- 	elseif labelPosition < 1 then
	-- 		return
	-- 	end
	-- 	y = topDistance + (labelPosition-1)*labelHeight
	-- end
	-- posLabel[name], posLabelShadow = createShadowedLabelFromSpare(posLeftDistance, y, 20, labelHeight, tostring(self.position) .. ')', 'right')
	-- if time then
	-- 	if not self.firsttime then
	-- 		self.firsttime = time
	-- 		time = '' .. msToTimeStr(time)
	-- 	else
	-- 		time = '' .. msToTimeStr(time)
	-- 	end
	-- else
	-- 	time = ''
	-- end
	-- playerLabel[name], playerLabelShadow = createShadowedLabelFromSpare(nameLeftDistance, y, 250, labelHeight, name)
	-- table.insert(self.labels, posLabel[name])
	-- table.insert(self.labels, posLabelShadow)
	-- table.insert(self.labels, playerLabel[name])
	-- table.insert(self.labels, playerLabelShadow)
 --    playSoundFrontEnd(7)


	-- if doBoardScroll then
	-- 	-- guiSetAlpha(posLabel[name], 0)
	-- 	-- guiSetAlpha(posLabelShadow, 0)
	-- 	-- guiSetAlpha(playerLabel[name], 0)
	-- 	-- guiSetAlpha(playerLabelShadow, 0)
	-- -- 	local anim = Animation.createNamed('race.boardscroll', self)
	-- -- 	anim:addPhase({ from = 0, to = 1, time = 700, fn = RankingBoard.scroll, firstLabel = posLabel[name] })
	-- -- 	anim:addPhase({ fn = RankingBoard.destroyLastLabel, firstLabel = posLabel[name] })
	-- -- 	anim:play()
	-- end
end

function RankingBoard:scroll(param, phase)
	-- local firstLabelIndex = table.find(self.labels, phase.firstLabel)
	-- for i=firstLabelIndex,firstLabelIndex+3 do
	-- 	guiSetAlpha(self.labels[i], param)
	-- end
	-- local x, y
	-- for i=0,#self.labels/4-1 do
	-- 	for j=1,4 do
	-- 		x = (j <= 2 and posLeftDistance or nameLeftDistance)
	-- 		y = topDistance + ((maxPositions - i - 1) + param)*labelHeight
	-- 		if j % 2 == 0 then
	-- 			x = x + 1
	-- 			y = y + 1
	-- 		end
	-- 		guiSetPosition(self.labels[i*4+j], sx + x, y, false)
	-- 	end
	-- end
	-- for i=1,4 do
	-- 	guiSetAlpha(self.labels[i], 1 - param)
	-- end
end

function RankingBoard:destroyLastLabel(phase)
	-- for i=1,4 do
	-- 	destroyElementToSpare(self.labels[1])
	-- 	guiSetVisible(self.labels[1],false)
	-- 	table.remove(self.labels, 1)
	-- end
	-- local firstLabelIndex = table.find(self.labels, phase.firstLabel)
	-- for i=firstLabelIndex,firstLabelIndex+3 do
	-- 	guiSetAlpha(self.labels[i], 1)
	-- end
end

function RankingBoard:addMultiple(items)
	-- for i,item in ipairs(items) do
	-- 	self:add(item.name, item.time)
	-- end
end

function RankingBoard:clear()
	-- table.each(self.labels, destroyElementToSpare)
	-- self.labels = {}
end

function RankingBoard:destroy()
	-- self:clear()
	-- RankingBoard.instances[self.id] = nil
end



--
-- Label cache
--


local spareElems = {}
local donePrecreate = false


function RankingBoard.precreateLabels(count)
 --    donePrecreate = false
 --    while #spareElems/4 < count do
 --        local label, shadow = createShadowedLabel(10, 1, 20, 10, 'a' )
	-- 	--guiSetAlpha(label,0)
	-- 	guiSetAlpha(shadow,0)
		

		
	-- 	guiSetVisible(label, false)
	-- 	guiSetVisible(shadow, false)
 --        destroyElementToSpare(label)
 --        destroyElementToSpare(shadow)
	-- end
 --    donePrecreate = true
end

function destroyElementToSpare(elem)
    -- table.insertUnique( spareElems, elem )
    -- guiSetVisible(elem, false)
end

dxTextCache = {}
dxTextShadowCache = {}

function dxDrawColoredLabel(str, ax, ay, bx, by, color,tcolor,scale, font)
	-- local rax = ax
	-- if not dxTextShadowCache[str] then
	-- 	dxTextShadowCache[str] = string.gsub( str, '#%x%x%x%x%x%x', '' )
	-- end
	-- dxDrawText(dxTextShadowCache[str], ax+1,ay+1,ax+1,by,tocolor(0,0,0, 0.8 * tcolor[4]),scale,font, "left", "center", false,false,false) 
	-- if dxTextCache[str] then
	-- 	for id, text in ipairs(dxTextCache[str]) do
	-- 		local w = text[2] * ( scale / text[4]  )
	-- 		dxDrawText(text[1], ax + w, ay, ax + w, by, tocolor(text[3][1],text[3][2],text[3][3],tcolor[4]), scale, font, "left", "center", false,false,false)
	-- 	end
	-- else
	-- 	dxTextCache[str] = {}
	-- 	local pat = "(.-)#(%x%x%x%x%x%x)"
	-- 	local s, e, cap, col = str:find(pat, 1)
	-- 	local last = 1
	-- 	local r = tcolor[1]
	-- 	local g = tcolor[2]
	-- 	local b = tcolor[3]
	-- 	local textalpha = tcolor[4]
	-- 	while s do
	-- 		if cap == "" and col then
	-- 			r = tonumber("0x"..col:sub(1, 2))
	-- 			g = tonumber("0x"..col:sub(3, 4))
	-- 			b = tonumber("0x"..col:sub(5, 6))
	-- 			color = tocolor(r, g, b, textalpha) 
	-- 		end
	-- 		if s ~= 1 or cap ~= "" then
	-- 			local w = dxGetTextWidth(cap, scale, font)
	-- 			dxDrawText(cap, ax, ay, ax + w, by, color, scale, font, "left", "center")
	-- 			table.insert(dxTextCache[str], { cap, ax-rax, {r,g,b}, scale } )
	-- 			ax = ax + w
	-- 			r = tonumber("0x"..col:sub(1, 2))
	-- 			g = tonumber("0x"..col:sub(3, 4))
	-- 			b = tonumber("0x"..col:sub(5, 6))
	-- 			color = tocolor( r, g, b, textalpha)
	-- 		end
	-- 		last = e + 1
	-- 		s, e, cap, col = str:find(pat, last)
	-- 	end
	-- 	if last <= #str then
	-- 		cap = str:sub(last)
	-- 		local w = dxGetTextWidth(cap, scale, font)
	-- 		dxDrawText(cap, ax, ay, ax + w, by, color, scale, font, "left", "center")
	-- 		table.insert(dxTextCache[str], { cap, ax-rax, {r,g,b}, scale } )
	-- 	end
	-- end
end

local scale = 1
local font = "default"
function drawRankList()
	-- if not RenderTarget then return end
	-- dxSetRenderTarget(RenderTarget,true)
	-- for pos,playerLab in ipairs(playerLabel) do
	-- 	local xPos = pos * labelHeight
	-- 	dxDrawColoredLabel(guiGetText(playerLab),0,xPos,1000,xPos+labelHeight,tocolor(255,255,255,255),scale,font)
	-- end
	-- dxSetRenderTarget()
	
	-- dxDrawImage(screenW * 0.014, screenH * 0.394, screenW * 0.248, screenH * 0.281,RenderTarget)
end
addEventHandler("onClientRender", root, drawRankList)
-- local font = "default"
-- local scl = 1.2
-- addEventHandler("onClientRender", getRootElement(), 
-- function()
-- 	for id, elem in pairs(playerLabel) do
-- 		if guiGetVisible(elem) and string.len(guiGetText(elem)) > 4 then
-- 			local x,y = guiGetPosition(elem, false)
-- 			local a = guiGetAlpha(elem) * 255
-- 				if not getKeyState("tab") then
-- 				dxDrawColoredLabel(string.gsub(guiGetText(elem)," ", " ",1), 50,y,200,y+20, tocolor(255,255,255,a*0.8),{255,255,255,a*0.8}, scl, font, "left", "center", false,false,false)				
-- 			end
-- 			if x < 100 then guiSetPosition(elem, sx+100,y,false) end
-- 		end
-- 	end
-- 	for id, elem in pairs(posLabel) do
-- 		if guiGetVisible(elem) and string.len(guiGetText(elem)) <= 4 then
-- 			local x,y = guiGetPosition(elem, false )
-- 			local a = guiGetAlpha(elem) * 255
-- 			if not getKeyState("tab") then
-- 					dxDrawText(guiGetText(elem), 1,y+1,41,y+21, tocolor(0,0,0,math.floor(a*0.8)), scl, font, "right", "center", false,false,false)
-- 					dxDrawText(guiGetText(elem), 0,y,40,y+20, tocolor(255,255,255,a*0.85), scl, font, "right", "center", false,false,false)
-- 			end
-- 			if x < 100 then guiSetPosition(elem, sx+100,y,false) end
-- 		end
-- 	end
-- end)



function createShadowedLabelFromSpare(x, y, width, height, text, align)

    -- if #spareElems < 2 then
    --     if not donePrecreate then
    --         outputDebug( 'OPTIMIZATION', 'createShadowedLabel' )
    --     end
	   --  return createShadowedLabel(x, y, width, height, text, align)
    -- else
    --     local shadow = table.popLast( spareElems )
	   --  guiSetSize(shadow, width, height, false)
	   --  guiSetText(shadow, text)
	   --  --guiLabelSetColor(shadow, 0, 0, 0)
	   --  guiSetPosition(shadow, sx + x + 1, y + 1, false)
    --     guiSetVisible(shadow, false)

    --     local label = table.popLast( spareElems )
	   --  guiSetSize(label, width, height, false)
	   --  guiSetText(label, text)
	   --  --guiLabelSetColor(label, 255, 255, 255)
	   --  guiSetPosition(label, sx + x, y, false)
    --     guiSetVisible(label, true)
	   --  if align then
		  --   guiLabelSetHorizontalAlign(shadow, align)
		  --   guiLabelSetHorizontalAlign(label, align)
    --     else
		  --   guiLabelSetHorizontalAlign(shadow, 'left')
		  --   guiLabelSetHorizontalAlign(label, 'left')
	   --  end
    --     return label, shadow
    -- end
end

-- fileDelete("rankingboard_client.lua")