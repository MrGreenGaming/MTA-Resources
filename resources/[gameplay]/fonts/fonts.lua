fontLocations = {
    ["Century Gothic Bold"] = "fonts/Century Gothic Bold.ttf",
    ["OpenSans"] = "fonts/OpenSans.ttf",
  --["Font Name Example"] = "FontLocation/example.tff", -- EXAMPLE (dont forget to add it to meta.xml too)
}

fonts = {} -- the loader puts all font in this table, with the same name key as in fontLocations
function loadFonts()
    for name,location in pairs(fontLocations) do
        local theFont = dxCreateFont(location,1500)
        if not theFont then outputDebugString(name.." font failed to load.",2) end
        fonts[name] = theFont
    end
end
addEventHandler("onClientResourceStart",resourceRoot,loadFonts)

function getFont(fontName)
    if not fonts[fontName] then return false end
    return fonts[fontName]
end


-- addEventHandler("onClientRender", root,
--     function()
--         dxDrawText("This is a test!", 512, 188, 1255, 300, tocolor(255, 255, 255, 255), 0.5, fonts["Century Gothic Bold"], "center", "center", false, false, true, false, false)
--     end
-- )