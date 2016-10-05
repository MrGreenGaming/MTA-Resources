local sw, sh = guiGetScreenSize()

local tooltips = {}
local color = { 0, 0, 0 }
local background = { 255, 255, 255 }
local font = { face = "default", size = 1, maxwidth = 300 }

function tooltipShow()
  --outputChatBox(getElementType(source))
  if getElementData(source, "tooltip-text") and getElementType(source):find("gui-", 1, true) then
    local x,y = guiGetPosition(source, false)
    local parent = getElementParent(source)
    while getElementType(parent) ~= "guiroot" do
      if getElementData(source, "tooltip-text") == getElementData(parent, "tooltip-text") then return false end
      local px, py = guiGetPosition(parent, false)
      x, y = x + px, y + py
      if getElementType(parent) == "gui-tab" then y = y + 24 end
      parent = getElementParent(parent)
    end
    local w,h = guiGetSize(source, false)
    x = x + w/2
    tooltips[source] = {}
    local fonts = getElementData(source, "tooltip-font")
    if fonts then
      tooltips[source].font = gettok(fonts, 1, " ") or font.face
      tooltips[source].fontsize = tonumber(gettok(fonts, 2, " ")) or font.size
    else 
      tooltips[source].font = font.face
      tooltips[source].fontsize = font.size
    end
    tooltips[source].text = getElementData(source, "tooltip-text")
    tooltips[source].w = math.ceil(dxGetTextWidth(tooltips[source].text, tooltips[source].fontsize, tooltips[source].font))
    tooltips[source].h = math.ceil(dxGetFontHeight(tooltips[source].fontsize, tooltips[source].font))
    if tooltips[source].w > font.maxwidth then
      tooltips[source].h = tooltips[source].h*math.ceil(tooltips[source].w/font.maxwidth)
      tooltips[source].w = font.maxwidth
    end
    tooltips[source].arrow = x
    tooltips[source].x = math.floor(math.min(math.max(x - tooltips[source].w/2, 16), sw - tooltips[source].w-16))
    tooltips[source].y = math.floor(y - tooltips[source].h - 12)
    if tooltips[source].y < 16 then
      tooltips[source].y = math.floor(y + h + 12)
      tooltips[source].bottom = true
    end
    tooltips[source].ticks = 1
    tooltips[source].step = 1
    -- color
    tooltips[source].br, tooltips[source].bg, tooltips[source].bb = unpack(background)
    local tcolor = getElementData(source, "tooltip-color")
    local bcolor = getElementData(source, "tooltip-background")
    if tcolor then 
      tooltips[source].r, tooltips[source].g, tooltips[source].b = getColorFromString(tcolor)
    else   
      tooltips[source].r, tooltips[source].g, tooltips[source].b = unpack(color)
    end  
    if bcolor then 
      tooltips[source].br, tooltips[source].bg, tooltips[source].bb = getColorFromString(bcolor)
    else   
      tooltips[source].br, tooltips[source].bg, tooltips[source].bb = unpack(background)
    end  
  end  
end  
addEventHandler("onClientMouseEnter", root, tooltipShow)

function tooltipHide(element)
  local e = isElement(element) and element or source
  if tooltips[e] then 
    tooltips[e].ticks = 10
    tooltips[e].step = -1
  end
end  
addEventHandler("onClientMouseLeave", root, tooltipHide)
addEventHandler("onClientGUIClick", root, tooltipHide)

function tooltipRender()
  for element, tooltip in pairs(tooltips) do
    if tooltip.ticks < 0 or not isElement(element) then 
      tooltips[element] = nil 
    else 
      local alpha = math.min(tooltip.ticks*25, 255)
      drawTooltip(tooltip, alpha)
      if tooltip.ticks < 255 then tooltip.ticks = tooltip.ticks + tooltip.step end
      if not guiGetVisible(element) then 
        tooltips[element] = nil
      end  
    end
  end
end  
addEventHandler("onClientRender", root, tooltipRender)

function drawTooltip(tooltip, alpha)
  local offset = math.max((254-alpha)/25, 0)
  -- corners
  dxDrawImageSection(tooltip.x-16, tooltip.y-16-offset, 16, 16, 0, 0, 16, 16, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  dxDrawImageSection(tooltip.x+tooltip.w, tooltip.y-16-offset, 16, 16, 32, 0, 16, 16, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  dxDrawImageSection(tooltip.x-16, tooltip.y+tooltip.h-offset, 16, 16, 0, 32, 16, 16, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  dxDrawImageSection(tooltip.x+tooltip.w, tooltip.y+tooltip.h-offset, 16, 16, 32, 32, 16, 16, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  -- v-sides
  dxDrawImageSection(tooltip.x, tooltip.y-16-offset, tooltip.w, 16, 16, 0, 16, 16, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  dxDrawImageSection(tooltip.x, tooltip.y+tooltip.h-offset, tooltip.w, 16, 16, 32, 16, 16, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  -- h-sides
  dxDrawImageSection(tooltip.x-16, tooltip.y-offset, 16, tooltip.h, 0, 16, 16, 16, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  dxDrawImageSection(tooltip.x+tooltip.w, tooltip.y-offset, 16, tooltip.h, 32, 16, 16, 16, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  -- center
  dxDrawImageSection(tooltip.x, tooltip.y-offset, tooltip.w, tooltip.h, 16, 16, 16, 16, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  -- arrow
  if tooltip.bottom then
    dxDrawImageSection(tooltip.arrow-16, tooltip.y-24-offset, 32, 24, 0, 48, 32, 24, "/images/sprite.png", 180, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  else
    dxDrawImageSection(tooltip.arrow-16, tooltip.y+tooltip.h-offset, 32, 24, 0, 48, 32, 24, "/images/sprite.png", 0, 0, 0, tocolor(tooltip.br,tooltip.bg,tooltip.bb,alpha), true)
  end  
  -- text
  --dxDrawText(tooltip.text, tooltip.x, tooltip.y+1-offset, tooltip.x+tooltip.w, tooltip.y+tooltip.h+1, tocolor(255,255,255,alpha), font.size, font.face, "left", "top", false, true, true)
  dxDrawText(tooltip.text, tooltip.x, tooltip.y-offset, tooltip.x+tooltip.w, tooltip.y+tooltip.h, tocolor(tooltip.r,tooltip.g,tooltip.b,alpha), tooltip.fontsize, tooltip.font, "left", "top", false, true, true)
end