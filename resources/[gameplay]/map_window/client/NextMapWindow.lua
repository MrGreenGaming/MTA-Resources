NextMapWindow = {}
local g__sW, g__sH = guiGetScreenSize()
local height = dxGetFontHeight(0.45, 'bankgothic') * 3
local hidenext = true

function NextMapWindow.draw()
    if hidenext then return end
    local windowString = "'" .. MapData.currentMapRatings.name .. "' L:" .. MapData.currentMapRatings.likes .. " D:" .. MapData.currentMapRatings.dislikes .. "\n" .. "'" .. MapData.nextMapRatings.name .. "' L:" .. MapData.nextMapRatings.likes .. " D:" .. MapData.nextMapRatings.dislikes
    local width = dxGetTextWidth(windowString, 0.45, 'bankgothic')

    dxDrawRectangle((g__sW-100)-(width+20), 4, width+20, height+5, tocolor(0,0,0,100),false)
    dxDrawText(windowString, (g__sW-100)-(width+20)+5, 5, (g__sW-100)-(width+20)+width+15, 5+height+5, tocolor(0, 255, 0, 255), 0.45, 'bankgothic', 'center', 'center', true)
end

function showNextMapWindow()
    hidenext = false
    removeEventHandler("onClientRender", root, NextMapWindow.draw)
    addEventHandler("onClientRender", root, NextMapWindow.draw)
end

function hideNextMapWindow()
    hidenext = true
    removeEventHandler("onClientRender", root, NextMapWindow.draw)
end

